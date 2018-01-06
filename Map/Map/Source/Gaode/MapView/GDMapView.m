//
//  GDMapView.m
//  ebm
//
//  Created by mac on 2017/4/19.
//  Copyright © 2017年 BM. All rights reserved.
//

#import "GDMapView.h"
#import <MAMapKit/MAMapKit.h>
#import "IMapDelegate.h"
#import "GDUserLocation.h"
#import "GDAnnotation.h"
#import "LineDashPolyline.h"
#import "MANaviPolyline.h"
#import "MMapAnnotationInfoM.h"
#import "GDPointAnnotation.h"
#import "GDPointAnnotation.h"
#import "IAnnotationView.h"
#import "GDAnimatedAnnotation.h"
#import "IAnnotationInfo.h"
#import <MapKit/MapKit.h>
#import "MapUtils.h"
#import "CommonUtility.h"
#import "IMapOverlayProperty.h"
#import "GDDistrictPolyline.h"
#import "GDUtils.h"
#import <GDAnnotationView.h>
#import <MMapConst.h>

@interface GDMapView ()<MAMapViewDelegate>

@property(nonatomic, weak) MAMapView *mapView;
@property(nonatomic, strong) id<IMapDelegate> delegate;

@property(nonatomic, weak) UIView *userLocationCustomView;///用户anno

@property(nonatomic, strong) NSMutableDictionary<NSString *, MAPointAnnotation *> *annotationCaches;///标注缓存

@end

@implementation GDMapView {
    id<IAnnotationView> _userLocationCustom;///自定义用户位置;
}

#pragma mark - LazyLoad

- (NSMutableDictionary *)annotationCaches {
    if (!_annotationCaches) {
        _annotationCaches = [NSMutableDictionary dictionary];
    }
    return _annotationCaches;
}

#pragma mark - Super

- (void)dealloc {
    NSLog(@"轨迹追踪销毁");
//    if (_traceCoordinate) {
//        free(_traceCoordinate);
//        _traceCoordinate = NULL;
//    }
}

#pragma mark - Init
#pragma mark - PrivateMethod
#pragma mark - PublicMethod

/**
 初始化
 */
- (instancetype)initWithFrame:(CGRect)frame parentView:(UIView *)parentView {
    self = [super init];
    if (self) {
        MAMapView *mapView = [[MAMapView alloc] initWithFrame:frame];
        [parentView addSubview:mapView];
        _mapView = mapView;
        _mapView.delegate = self;
        _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

/**
 获取地图viwe
 */
- (UIView *)getView {
    return _mapView;
}

/**
 获取自定义用户位置显示view
 */
- (void)addUserLocationCustomView:(id<IAnnotationView>)view {
    _userLocationCustom = view;
}

/**
 获取自定义用户位置显示view
 */
- (id<IAnnotationView>)getUserLocationCustomView {
    return _userLocationCustom;
}

/**
 获取用户当前位置
 */
- (CLLocation *)getUserLocation {
    return self.mapView.userLocation.location;
}

/**
 设置代理
 */
- (void)setDelegate:(id<IMapDelegate>)delegate {
    _delegate = delegate;
}

/**
 基础设置
 */
- (void)defaultSetting {
    //地图类型
    self.mapView.mapType = MAMapTypeStandard;
    //实时交通
    self.mapView.showTraffic = NO;
    //显示指南针
    self.mapView.showsCompass = NO;
    //显示用户位置
    self.mapView.showsUserLocation = YES;
    //用户位置跟踪模式
    [self.mapView setUserTrackingMode:MAUserTrackingModeFollow animated:YES];
    //比例尺
    self.mapView.showsScale = NO;
    //地图旋转手势
    self.mapView.rotateEnabled = NO;
    //地图倾斜手势
    self.mapView.rotateCameraEnabled = NO;
    //单击地图获取POI信息
    self.mapView.touchPOIEnabled = NO;
    //自定义定位样式
    self.mapView.customizeUserLocationAccuracyCircleRepresentation = YES;
    //    self.userTrackingMode = MAUserTrackingModeFollow;
    //是否显示室内地图
    self.mapView.showsIndoorMap = NO;
//    self.mapView.zoomLevel = 17.1;
    ///自定义地图样式
    NSString *path = [NSString stringWithFormat:@"%@/mystyle.data", [NSBundle mainBundle].bundlePath];
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data) {
        [self.mapView setCustomMapStyleWithWebData:data];
        [self.mapView setCustomMapStyleEnabled:YES];
    }
}

/**
 清除地图
 */
- (void)clearMapView {
    dispatch_main_sync_safe_map(^{
        self.mapView.showsUserLocation = NO;
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.mapView removeOverlays:self.mapView.overlays];
        self.mapView.delegate = nil;
        [self.mapView removeFromSuperview];
        _mapView = nil;
    });
}

/**
 * @brief 设置缩放级别（默认3-19，有室内地图时为3-20）
 * @param zoomLevel 要设置的缩放级别
 * @param animated 是否动画设置
 */
- (void)setZoomLevel:(CGFloat)zoomLevel animated:(BOOL)animated {
    [self.mapView setZoomLevel:zoomLevel animated:animated];
}

/**
 * @brief 获取缩放级别（默认3-19，有室内地图时为3-20）
 */
- (CGFloat)getZoomLevel {
    return self.mapView.zoomLevel;
}

/**
 * @brief 设置当前地图的中心点，改变该值时，地图的比例尺级别不会发生变化
 * @param coordinate 要设置的中心点
 * @param animated 是否动画设置
 */
- (void)setCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated {
    [self.mapView setCenterCoordinate:coordinate animated:animated];
}

/**
 定位到当前位置
 */
- (void)relocation {
    if (self.mapView.userLocation) {
        [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
    }
}

/**
 显示交通情况
 */
- (void)setShowTraffic:(BOOL)showTraffic {
    self.mapView.showTraffic = showTraffic;
}

/**
 * @brief 向地图窗口添加标注，需要实现MAMapViewDelegate的-mapView:viewForAnnotation:函数来生成标注对应的View
 * @param annotationInfo 要添加的标注
 */
- (BOOL)addAnnotationInfo:(MMapAnnotationInfoM *)annotationInfo {
    NSAssert(annotationInfo.identifier, @"identifier不能为空");
    id obj = [self.annotationCaches objectForKey:annotationInfo.identifier];
    if (obj) {
//        NSAssert(!obj, @"identifier已存在");
        return NO;
    }
    GDPointAnnotation *ann = [[GDPointAnnotation alloc] initWithInfoModel:annotationInfo];
    [_mapView addAnnotation:ann];
    [self.annotationCaches setObject:ann forKey:ann.identifier];
    return YES;
}

/**
 * @brief 向地图窗口添加一组标注，需要实现IMapDelegate的-mapView:viewForAnnotation:函数来生成标注对应的View
 * @param annotationInfos 要添加的标注数组
 */
- (void)addAnnotationInfos:(NSArray<MMapAnnotationInfoM *> *)annotationInfos {
//    NSMutableArray *annArr = [NSMutableArray array];
    for (MMapAnnotationInfoM *infoM in annotationInfos) {
        [self addAnnotationInfo:infoM];
//        NSAssert(infoM.identifier, @"identifier不能为空");
//        id obj = [self.annotationCaches objectForKey:infoM.identifier];
//        if (obj) {
//            //        NSAssert(!obj, @"identifier已存在");
//        }
//        GDPointAnnotation *ann = [[GDPointAnnotation alloc] initWithInfoModel:infoM];
//        [annArr addObject:ann];
//        [self.annotationCaches setObject:ann forKey:ann.identifier];
    }
//    [_mapView addAnnotations:annArr];
}

/**
 * @brief 移除标注
 * @param annotationIdentifier 要移除的标注ID
 */
- (id<IAnnotationInfo>)removeAnnotationInfo:(NSString *)annotationIdentifier animation:(BOOL)animation {
    NSAssert(annotationIdentifier, @"identifier不能为空");
    GDPointAnnotation *ann = (GDPointAnnotation *)[self.annotationCaches objectForKey:annotationIdentifier];
    [self.annotationCaches removeObjectForKey:annotationIdentifier];

    MAAnnotationView *carView = [_mapView viewForAnnotation:ann];
    [UIView animateWithDuration:animation?.5f:0 animations:^{
        carView.alpha = 0;
    } completion:^(BOOL finished) {
        dispatch_main_sync_safe_map(^{
            [_mapView removeAnnotation:ann];
        });
    }];
    return ann.infoM;
}

/**
 * @brief 移除一组标注
 * @param annotationIdentifiers 要移除的标注数组ID
 */
- (void)removeAnnotationInfos:(NSArray<NSString *> *)annotationIdentifiers animation:(BOOL)animation {
    for (NSString *identifier in annotationIdentifiers) {
        [self removeAnnotationInfo:identifier animation:animation];
    }
}

/**
 * @brief 向地图窗口添加标注，需要实现MAMapViewDelegate的-mapView:viewForAnnotation:函数来生成标注对应的View
 * @param annotationInfo 要添加的标注
 */
- (void)addAnimatedAnnotationInfo:(MMapAnnotationInfoM *)annotationInfo {
    NSAssert(annotationInfo.identifier, @"identifier不能为空");
    id obj = [self.annotationCaches objectForKey:annotationInfo.identifier];
//    NSAssert(!obj, @"identifier已存在");
    GDAnimatedAnnotation *ann = [[GDAnimatedAnnotation alloc] initWithInfoModel:annotationInfo];
    [_mapView addAnnotation:ann];
    [self.annotationCaches setObject:ann forKey:ann.identifier];
}

/**
 MMapAnnotationInfoM平滑移动标注位置
 */
- (void)moveAnnotationWithInfo:(MMapAnnotationInfoM *)info {
//    info.coordinate = _mapView.userLocation.coordinate;
    NSAssert(info.identifier, @"identifier不能为空");
    GDAnimatedAnnotation *anno = (GDAnimatedAnnotation *)[self.annotationCaches objectForKey:info.identifier];
    if (!anno) {
        [self addAnimatedAnnotationInfo:info];
        anno = (GDAnimatedAnnotation *)[self.annotationCaches objectForKey:info.identifier];
    }
    NSAssert([anno isKindOfClass:[GDAnimatedAnnotation class]], @"该标注为不可移动标注，请通过addAnimatedAnnotationInfo:添加可移动的标注");

    ///更新绑定的infoM
    anno.infoM = info;
    ///更新移动的角度
    anno.infoM.movingDirection = anno.movingDirection;
    NSArray *coordArr = [info getCoordinates];

    if (coordArr != nil && coordArr.count > 1) {
        CLLocationCoordinate2D coords[coordArr.count];
        for (int i = 0; i < coordArr.count; i++) {
            NSValue *coorValue = coordArr[i];
            CLLocationCoordinate2D coor = [coorValue MKCoordinateValue];
            coords[i].latitude = coor.latitude;
            coords[i].longitude = coor.longitude;
        }

//        CLLocationDirection oldDirection = anno.infoM.movingDirection;
//        CLLocationDirection newDirection = anno.movingDirection;
//        CLLocationDirection degree = [MapUtils calculateDirectionFromCoordinate:coords[0] to:coords[1]];
//        NSLog(@"degree: %f", degree);
//        GDMoveAnimation(^{
//            info.customView.transform = CGAffineTransformMakeRotation((degree*M_PI)/180.f);
//        }, ^(BOOL isFinish){
//
//        });

//        ///移动出地图视野是时移除标注
//        MAAnnotationView *carViwe = [_mapView viewForAnnotation:anno];
//        if (!carViwe) {
//            ///停止动画
//            for (MAAnnotationMoveAnimation *animation in [anno allMoveAnimations]) {
//                [animation cancel];
//            }
//            anno.coordinate = coords[0];
//            [self removeAnnotationInfo:anno.identifier animation:YES];
//            return;
//        }

//        anno.coordinate = coords[0];
//        NSLog(@"from:%f--%f,to:%f--%f", coords[0].latitude,coords[0].longitude, coords[1].latitude,coords[1].longitude);

        [anno addMoveAnimationWithKeyCoordinates:coords count:sizeof(coords)/sizeof(coords[0]) withDuration:4.9 withName:nil completeCallback:^(BOOL isFinished) {
            NSLog(@"移动完成");
//            if (coords) {
//                free(coords);
//            }
        }];
//        free(coords);

//        GDMoveAnimation(^{
//            info.customView.transform = CGAffineTransformMakeRotation((anno.movingDirection*M_PI)/180.f);
//        }, ^(BOOL isFinish){
//
//        });
    }
}

/**
 * @brief 移除Annotation
 */
- (void)removeAllAnnotation {
    [self.annotationCaches removeAllObjects];
    dispatch_main_sync_safe_map(^{
        [_mapView removeAnnotations:_mapView.annotations];
    });
}

/**
 通过annotationIdentifier获取id<IAnnotationInfo>
 */
- (id<IAnnotationInfo>)annotationInfoWithIdentifier:(NSString *)annotationIdentifier {
    NSAssert(annotationIdentifier, @"identifier不能为空");
    GDPointAnnotation *ann = (GDPointAnnotation *)[self.annotationCaches objectForKey:annotationIdentifier];
    return ann.infoM;
}

//- (NSDictionary<NSString *, id<IAnnotationInfo>> *)getAnnotationInfoCaches {
//    return self.annotationCaches;
//}

/**
 通过annotationIdentifier获取view
 */
- (UIView *)viewForAnnotationIdentifier:(NSString *)annotationIdentifier {
    NSAssert(annotationIdentifier, @"identifier不能为空");
    GDPointAnnotation *ann = (GDPointAnnotation *)[self.annotationCaches objectForKey:annotationIdentifier];
    if (ann.getCustomView) {
        return ann.getCustomView;
    }
    return [_mapView viewForAnnotation:ann];
}

/**
 * @brief 设定当前地图的经纬度范围，该范围可能会被调整为适合地图窗口显示的范围
 * @param rect 要设定的范围
 * @param animated 是否动画设置
 *
 */
- (void)setRegionWithView:(UIView *)view rect:(CGRect)rect animated:(BOOL)animated {
    MACoordinateRegion viewRegion = [self.mapView convertRect:rect toRegionFromView:view];
    MACoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustedRegion animated:animated];
}

/**
 * @brief 将指定view坐标系的坐标转换为经纬度
 * @param point 指定view坐标系的坐标
 * @param view 指定的view
 * @return 经纬度
 */
- (CLLocationCoordinate2D)convertPoint:(CGPoint)point toCoordinateFromView:(UIView *)view {
    return [self.mapView convertPoint:point toCoordinateFromView:view];
}

/**
 * @brief 移除Overlay
 */
- (void)removeAllOverlay {
    dispatch_main_sync_safe_map(^{
        [_mapView removeOverlays:_mapView.overlays];
    });
}

/**
 * @brief 设置可见地图矩形区域
 * @param insets 边缘插入
 * @param annotationInfos id<IAnnotationInfo>标注数组, 必须要2个以上才能使用
 * @param animated 是否动画效果
 */
- (void)setVisibleWithAnnotationInfos:(NSArray<id<IAnnotationInfo>> *)annotationInfos edgePadding:(UIEdgeInsets)insets animated:(BOOL)animated {
    NSMutableArray *arr = [NSMutableArray array];
    for (id<IAnnotationInfo> annInfo in annotationInfos) {
        GDPointAnnotation *point = [[GDPointAnnotation alloc] initWithInfoModel:annInfo];
        [arr addObject:point];
    }
    [_mapView setVisibleMapRect:[CommonUtility minMapRectForAnnotations:arr] edgePadding:insets animated:animated];
}

/**
 坐标点是否包含在Overlay内
 */
- (BOOL)isOverlayContainsPoint:(CLLocationCoordinate2D)coordinate  {
//    /* 把屏幕坐标转换为MAMapPoint坐标. */
//    MAMapPoint mapPoint = MAMapPointForCoordinate(coordinate);
//    /* overlay的线宽换算到MAMapPoint坐标系的宽度. */
//    double mapPointDistance = [self mapPointsPerPointInViewAtCurrentZoomLevel] * renderer.lineWidth;
//
//    /* 判断是否选中了overlay. */
//    if (isOverlayWithLineWidthContainsPoint(selectableOverlay.overlay, mapPointDistance, mapPoint) ) {
//
//    }
    return NO;
}

#pragma mark - Events
#pragma mark - LoadFromService
#pragma mark - Delegate

/*!
 @brief 位置或者设备方向更新后，会调用此函数
 @param mapView 地图View
 @param userLocation 用户定位信息(包括位置与设备方向等数据)
 @param updatingLocation 标示是否是location数据更新, YES:location数据更新 NO:heading数据更新
 */
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    BOOL respond = [_delegate respondsToSelector:@selector(mapView:didUpdateUserLocation:updatingLocation:degree:)];
    if (respond) {
        double degree = userLocation.heading.trueHeading - mapView.rotationDegree;
        [_delegate mapView:self didUpdateUserLocation:[[GDUserLocation alloc] initWihtGDObject:userLocation] updatingLocation:updatingLocation degree:degree];
    }
}
/*!
 @brief 地图区域即将改变时会调用此接口
 @param mapView 地图View
 @param animated 是否动画
 */
- (void)mapView:(MAMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
}
/*!
 @brief 地图区域改变完成后会调用此接口
 @param mapView 地图View
 @param animated 是否动画
 */
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
}

/**
 *  地图将要发生移动时调用此接口
 *
 *  @param mapView       地图view
 *  @param wasUserAction 标识是否是用户动作
 */
- (void)mapView:(MAMapView *)mapView mapWillMoveByUser:(BOOL)wasUserAction {
    BOOL respond = [_delegate respondsToSelector:@selector(mapView:mapWillMoveByUser:)];
    if (respond) {
        [_delegate mapView:self mapWillMoveByUser:wasUserAction];
    }
}

/**
 *  地图移动结束后调用此接口
 *
 *  @param mapView       地图view
 *  @param wasUserAction 标识是否是用户动作
 */
- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction {
    BOOL respond = [_delegate respondsToSelector:@selector(mapView:mapDidMoveByUser:)];
    if (respond) {
        [_delegate mapView:self mapDidMoveByUser:wasUserAction];
    }
}

/*!
 @brief 根据anntation生成对应的View
 @param mapView 地图View
 @param annotation 指定的标注
 @return 生成的标注View
 */
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {
    BOOL respond = [_delegate respondsToSelector:@selector(mapView:viewForAnnotation:)];
    if (respond) {
//        GDAnnotation *anno = [[GDAnnotation alloc] initWihtGDObject:annotation];
//        id<IAnnotationView> annView = [_delegate mapView:self viewForAnnotation:anno];
//        if (!annView) return nil;
    }
    ///用户位置
    if ([annotation isKindOfClass:[MAUserLocation class]]) {
        static NSString *identifier = @"userLocation";
        MAAnnotationView *annotationView = (MAAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        }
        if (_userLocationCustom) {
            [annotationView addSubview:[_userLocationCustom getCustomView]];
        }
        self.userLocationCustomView = annotationView;

        ///定位成功回调
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL respond = [_delegate respondsToSelector:@selector(mapViewDidFinishLocatingUser:userLocation:)];
            if (respond) {
                [_delegate mapViewDidFinishLocatingUser:self userLocation:mapView.userLocation.location];
            }
        });

        return annotationView;
    }
    ///一般标注
    else if ([annotation isKindOfClass:[GDPointAnnotation class]]) {
        static NSString *pointIdentifier = @"GDPointAnnotation";
        GDPointAnnotation *pa = (GDPointAnnotation *)annotation;
        if (pa.identifier && pa.identifier.length > 0) {
            pointIdentifier = pa.identifier;
        }

        GDAnnotationView *annotationView = (GDAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointIdentifier];
        if (annotationView == nil) {
            annotationView = [[GDAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pa.identifier];
        }

        if ([pa getCustomView]) {
            UIView *custom = [pa getCustomView];
            if (![annotationView.subviews containsObject:custom]) {
                ///防止custom触摸事件覆盖高德自带触摸事件处理操作
                custom.userInteractionEnabled = NO;
                annotationView.bounds = custom.bounds;
                //            custom.frame = annotationView.bounds;
                //            custom.center = annotationView.center;
                //            annotationView.backgroundColor = [UIColor redColor];
                [annotationView addSubview:custom];
                ///设置中心点偏移，使得标注底部中间点成为经纬度对应点
                annotationView.centerOffset = pa.infoM.centerOffset;
                annotationView.canShowCallout = NO;
            }
        } else {
            annotationView.image = pa.iconImage;
            ///设置中心点偏移，使得标注底部中间点成为经纬度对应点
            annotationView.centerOffset = CGPointMake(0, -18);
        }

        ///添加点击事件
//        if (pa.infoM.bDidClicked) {
//            UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
//            btn.frame = annotationView.bounds;
//            [annotationView addSubview:btn];
//
//            [btn bk_addTouchUpAction:^(id sender) {
//                [_mapView bringSubviewToFront:annotationView];
//                pa.infoM.bDidClicked();
//            }];
//        }

        if (pa.infoM.bringToFront) {
            [mapView bringSubviewToFront:annotationView];
        }

        ///是否支持标注拖动
        annotationView.draggable = NO;
        annotationView.canShowCallout = NO;
        //        annotationView.animatesDrop = YES;
        //        annotationView.icon.image = pa.iconImage;
        /// 设置中⼼心点偏移,使得标注底部中间点成为经纬度对应点,标注位置
//        annotationView.centerOffset = CGPointMake(0, -18);
        //        annotationView.selected = NO;
        //        annotationView.userInteractionEnabled = NO;
        //            [annotationView bringSubviewToFront:_mapView];
        return annotationView;
    }
    ///平滑移动的
    else if ([annotation isKindOfClass:[GDAnimatedAnnotation class]]) {
        static NSString *identifier = @"GDAnimatedAnnotation";
        GDAnimatedAnnotation *pa = (GDAnimatedAnnotation *)annotation;

        MAAnnotationView *annotationView = (MAAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pa.identifier];
        }
        if ([pa getCustomView]) {
            UIView *custom = [pa getCustomView];
            //                custom.frame = annotationView.bounds;
            custom.center = annotationView.center;
            [annotationView addSubview:custom];
        } else {
            annotationView.image = pa.iconImage;
        }

        annotationView.canShowCallout = NO;
        //        annotationView.animatesDrop = YES;
        annotationView.draggable = NO;
        //        annotationView.icon.image = pa.iconImage;
        /// 设置中⼼心点偏移,使得标注底部中间点成为经纬度对应点,标注位置
        //            annotationView.centerOffset = CGPointMake(0, -18);
        annotationView.centerOffset = pa.infoM.centerOffset;

        //        annotationView.selected = NO;
        //        annotationView.userInteractionEnabled = NO;
        //            [annotationView bringSubviewToFront:_mapView];
        return annotationView;

    }
    return nil;
}

/*!
 @brief 当mapView新添加annotation views时，调用此接口
 @param mapView 地图View
 @param views 新添加的annotation views
 */
- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    MAAnnotationView *aView = views.firstObject;
    aView.alpha = 0;
    [UIView animateWithDuration:.5 animations:^{
        aView.alpha = 1;
    }];
    
    BOOL respond = [_delegate respondsToSelector:@selector(mapView:didAddAnnotationViews:)];
    if (respond) {
        NSMutableArray *arr = [NSMutableArray array];
        for (MAAnnotationView *annView in views) {
            id<MAAnnotation> annotation = annView.annotation;
            ///用户位置
            if ([annotation isKindOfClass:[MAUserLocation class]]) {
            }
            ///一般标注
            else if ([annotation isKindOfClass:[GDPointAnnotation class]]) {
                GDPointAnnotation *pa = (GDPointAnnotation *)annotation;
                [arr addObject:pa.infoM];
            }
            ///平滑移动的
            else if ([annotation isKindOfClass:[GDAnimatedAnnotation class]]) {
                GDAnimatedAnnotation *pa = (GDAnimatedAnnotation *)annotation;
                [arr addObject:pa.infoM];
            }
        }
        [_delegate mapView:self didAddAnnotationViews:arr];
    }
}

/**
 * @brief 当选中一个annotation view时，调用此接口. 注意如果已经是选中状态，再次点击不会触发此回调。取消选中需调用-(void)deselectAnnotation:animated:
 * @param mapView 地图View
 * @param view 选中的annotation view
 */
- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view {
    id<MAAnnotation> annotation = view.annotation;
    id<IAnnotationInfo> infoM = nil;

    if (!annotation) {
        annotation = [self.annotationCaches objectForKey:view.reuseIdentifier];
    }

    if ([annotation isKindOfClass:[GDPointAnnotation class]]) {
        GDPointAnnotation *point = (GDPointAnnotation *)annotation;
        infoM = point.infoM;
    } else if ([annotation isKindOfClass:[GDAnimatedAnnotation class]]) {
        GDAnimatedAnnotation *point = (GDAnimatedAnnotation *)annotation;
        infoM = point.infoM;
    }

    ///选中回调
    if (infoM.bDidSelected) {
        infoM.bDidSelected(infoM);
    }
    ///带有点击事件时的操作
    else if (infoM.bDidClicked) {
        infoM.bDidClicked(infoM);
        ///取消选中，否则再次点击图标没反应
        [mapView deselectAnnotation:annotation animated:NO];
    }

    BOOL respond = [_delegate respondsToSelector:@selector(mapView:didSelectAnnotationView:)];
    if (respond) {
        [_delegate mapView:self didSelectAnnotationView:infoM];
    }
}

/**
 * @brief 当取消选中一个annotation view时，调用此接口
 * @param mapView 地图View
 * @param view 取消选中的annotation view
 */
- (void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view {
    id<MAAnnotation> infoAnno = [self.annotationCaches objectForKey:view.reuseIdentifier];
    id<IAnnotationInfo> infoM = nil;

    if ([infoAnno isKindOfClass:[GDPointAnnotation class]]) {
        GDPointAnnotation *point = (GDPointAnnotation *)infoAnno;
        infoM = point.infoM;
    } else if ([infoAnno isKindOfClass:[GDAnimatedAnnotation class]]) {
        GDAnimatedAnnotation *point = (GDAnimatedAnnotation *)infoAnno;
        infoM = point.infoM;
    }

    ///选中回调
    if (infoM.bDidDeselected) {
        infoM.bDidDeselected(infoM);
    }

    BOOL respond = [_delegate respondsToSelector:@selector(mapView:didDeselectAnnotationView:)];
    if (respond) {
        [_delegate mapView:self didDeselectAnnotationView:infoM];
    }
}

/**
 * @brief 在地图View将要启动定位时，会调用此函数
 * @param mapView 地图View
 */
- (void)mapViewWillStartLocatingUser:(MAMapView *)mapView {
//    [mapView setZoomLevel:17 animated:YES];
    BOOL respond = [_delegate respondsToSelector:@selector(mapViewWillStartLocatingUser:)];
    if (respond) {
        [_delegate mapViewWillStartLocatingUser:self];
    }
}

/**
 * @brief 在地图View停止定位后，会调用此函数
 * @param mapView 地图View
 */
- (void)mapViewDidStopLocatingUser:(MAMapView *)mapView {
    BOOL respond = [_delegate respondsToSelector:@selector(mapViewDidStopLocatingUser:)];
    if (respond) {
        [_delegate mapViewDidStopLocatingUser:self];
    }
}

/**
 * @brief 地图加载成功
 * @param mapView 地图View
 */
- (void)mapViewDidFinishLoadingMap:(MAMapView *)mapView {
    BOOL respond = [_delegate respondsToSelector:@selector(mapViewDidFinishLoadingMap:)];
    if (respond) {
        [_delegate mapViewDidFinishLoadingMap:self];
    }
}

/**
 * @brief 根据overlay生成对应的Renderer
 * @param mapView 地图View
 * @param overlay 指定的overlay
 * @return 生成的覆盖物Renderer
 */
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay {
    if ([overlay isKindOfClass:[LineDashPolyline class]]) {
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:((LineDashPolyline *)overlay).polyline];
        polylineRenderer.lineWidth   = 5;
        polylineRenderer.lineDash = NO;
        polylineRenderer.strokeColor = LEColor(15, 193, 57, 1);
        polylineRenderer.lineJoinType = kMALineJoinRound;//连接类型
        polylineRenderer.lineCapType = kMALineCapRound;//端点类型

        return polylineRenderer;
    }
    if ([overlay isKindOfClass:[MANaviPolyline class]]) {
        MANaviPolyline *naviPolyline = (MANaviPolyline *)overlay;
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:naviPolyline.polyline];

        polylineRenderer.lineWidth = 5;
        polylineRenderer.lineJoinType = kMALineJoinRound;//连接类型
        polylineRenderer.lineCapType = kMALineCapRound;//端点类型

        if (naviPolyline.type == MANaviAnnotationTypeWalking) {
//            polylineRenderer.strokeColor = self.naviRoute.walkingColor;
        }
        else if (naviPolyline.type == MANaviAnnotationTypeRailway) {
//            polylineRenderer.strokeColor = self.naviRoute.railwayColor;
        }
        else {
            polylineRenderer.strokeColor = [UIColor redColor];
        }

        return polylineRenderer;
    }
    if ([overlay isKindOfClass:[MAMultiPolyline class]]) {
//        MAMultiColoredPolylineRenderer * polylineRenderer = [[MAMultiColoredPolylineRenderer alloc] initWithMultiPolyline:overlay];
//        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
//
//        polylineRenderer.lineWidth = 8;
////        polylineRenderer.strokeColors = [self.naviRoute.multiPolylineColors copy];
//        polylineRenderer.strokeColor = BMColor(15, 193, 57, 1);
////        polylineRenderer.gradient = YES;
//        polylineRenderer.lineJoinType = kMALineJoinRound;//连接类型
//        polylineRenderer.lineCapType = kMALineCapRound;//端点类型

        MAMultiTexturePolylineRenderer * polylineRenderer = [[MAMultiTexturePolylineRenderer alloc] initWithMultiPolyline:overlay];
        polylineRenderer.lineWidth = 16.f;

        BOOL respond = [_delegate respondsToSelector:@selector(mapView:rendererForOverlayType:)];
        if (respond) {
            id<IMapOverlayProperty> property = [_delegate mapView:self rendererForOverlayType:IMapViewOverlayTypeDefault];

//            UIImage *bad = [UIImage imageNamed:@"MapImage.bundle/custtexture_bm"];
//            UIImage *slow = [UIImage imageNamed:@"MapImage.bundle/custtexture_slow.png"];
//            UIImage *green = [UIImage imageNamed:@"MapImage.bundle/custtexture_green.png"];

            UIImage *bad = property.loadStrokeTextureImage;
//            BOOL succ = [polylineRenderer loadStrokeTextureImages:@[bad]];
//            if (!succ) {
//                NSLog(@"loading texture image fail.");
//            }
            [polylineRenderer setStrokeTextureImages:@[bad]];
//            [polylineRenderer loadStrokeTextureImage:property.loadStrokeTextureImage];
//            [polylineRenderer loadTexture:property.loadStrokeTextureImage];
        }

        return polylineRenderer;
    }
    ///行政区域搜索结果边界线
    if ([overlay isKindOfClass:[GDDistrictPolyline class]]) {
        ///区域边界线
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:overlay];

        polylineRenderer.lineWidth   = 2.f;
        polylineRenderer.strokeColor = [UIColor grayColor];

        return polylineRenderer;
    }

    return nil;
}

/**
 * @brief 定位失败后，会调用此函数
 * @param mapView 地图View
 * @param error 错误号，参考CLError.h中定义的错误号:kCLErrorDenied
 */
- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    BOOL respond = [_delegate respondsToSelector:@selector(mapView:didFailToLocateUserWithError:)];
    if (respond) {
        [_delegate mapView:self didFailToLocateUserWithError:error];
    }

}

#pragma mark - StateMachine

@end
