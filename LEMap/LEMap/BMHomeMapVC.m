//
//  BMHomeMapVC.m
//  ebm
//
//  Created by mac on 2017/4/20.
//  Copyright © 2017年 BM. All rights reserved.
//

#import "BMHomeMapVC.h"
#import "BMUserAnnotationV.h"
#import "MapSearchImpHeaders.h"
#import <ReactiveObjC.h>
#import "MSearchAddressM.h"
#import "MMapAnnotationInfoM.h"
#import "UIInfomationView.h"
#import "BMBaseMapConst.h"

@interface BMHomeMapVC ()

/**
 定位按钮是否点击了
 */
@property(nonatomic, assign) BOOL isReLocation;

//@property(nonatomic, strong) BMUserAnnotationV *userLocationCustomView;

@property(nonatomic, strong) NSMutableDictionary *carInfos;///缓存车辆
@property (nonatomic, strong) NSArray *cityStations;///同城配站点数组

@end

@implementation BMHomeMapVC

#pragma mark - LazyLoad

- (RACCommand *)addStationsCommand {
    if (!_addStationsCommand) {
        @weakify(self)
        _addStationsCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            @strongify(self)
            ///添加
            if ([input boolValue]) {
            }
            ///移除
            else if (self.cityStations) {
                [self.mapView removeAnnotationInfos:self.cityStations animation:YES];
            }
            return [RACSignal empty];
        }];
    }
    return _addStationsCommand;
}

#pragma mark - Super

- (void)viewDidLoad {
    [super viewDidLoad];

    ///显示大头针
    self.showPin = NO;
    //    [self setPinForMapImage:[UIImage imageNamed:@"redPin"]];
    [self setPinForMapImage:[UIImage imageNamed:@"map_annotation"]];

    ///显示定位按钮
    [self showReLocationWithPoint:CGPointMake([UIScreen mainScreen].bounds.size.width-42, [UIScreen mainScreen].bounds.size.height-80)];

    @weakify(self)
    [[self.reLocationBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        self.isReLocation = YES;
        ///缩放级别
        [self.mapView setZoomLevel:17.1 animated:YES];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - Init
#pragma mark - PrivateMethod

#pragma mark - PublicMethod

#pragma mark - Events
#pragma mark - LoadFromService

#pragma mark - Delegate

/*!
 @brief 位置或者设备方向更新后，会调用此函数
 @param mapView 地图View
 @param userLocation 用户定位信息(包括位置与设备方向等数据)
 @param updatingLocation 标示是否是location数据更新, YES:location数据更新 NO:heading数据更新
 */
- (void)mapView:(id<IMapView>)mapView didUpdateUserLocation:(id<IUserLocation>)userLocation updatingLocation:(BOOL)updatingLocation degree:(CGFloat)degree {
    if (updatingLocation) {
        
    }
    ///改变用户角度
    BMUserAnnotationV *customView = (BMUserAnnotationV *)[mapView getUserLocationCustomView];
    if (!updatingLocation && customView != nil) {
        [UIView animateWithDuration:0.1 animations:^{
            customView.userBorder.transform = CGAffineTransformMakeRotation((degree+30) * M_PI / 180.f );
        }];
    }
}

/*!
 @brief 地图区域即将改变时会调用此接口
 @param mapView 地图View
 @param animated 是否动画
 */
- (void)mapView:(id<IMapView>)mapView regionWillChangeAnimated:(BOOL)animated {}

/*!
 @brief 地图区域改变完成后会调用此接口
 @param mapView 地图View
 @param animated 是否动画
 */
- (void)mapView:(id<IMapView>)mapView regionDidChangeAnimated:(BOOL)animated {}

/**
 *  地图将要发生移动时调用此接口
 *
 *  @param mapView       地图view
 *  @param wasUserAction 标识是否是用户动作
 */
- (void)mapView:(id<IMapView>)mapView mapWillMoveByUser:(BOOL)wasUserAction {
    if (wasUserAction || self.isReLocation) {
    }
}

/**
 *  地图移动结束后调用此接口
 *
 *  @param mapView       地图view
 *  @param wasUserAction 标识是否是用户动作
 */
- (void)mapView:(id<IMapView>)mapView mapDidMoveByUser:(BOOL)wasUserAction {
    CLLocationCoordinate2D coordinate = [mapView convertPoint:[[mapView getView] center] toCoordinateFromView:self.view];
    if (wasUserAction || self.isReLocation) {
        ///地址反编译
        [[[[LEMapEngine sharedInstance] getMapFactory] getMapSearch] reGeocodeWithLocation:coordinate onReGeocodeSearchDone:^(MSearchAddressM *response) {
        }];
        self.isReLocation = NO;
    }
}

/*!
 @brief 根据anntation生成对应的View
 @param mapView 地图View
 @param annotation 指定的标注
 @return 生成的标注View
 */
- (id<IAnnotationView>)mapView:(id<IMapView>)mapView viewForAnnotation:(id<IAnnotation>)annotation {
    ///自定义userLocation对应的annotationView.
    if ([annotation getAnnotationType] == AnnotationTypeENUMUserLocation) {
        BMUserAnnotationV *user = [[BMUserAnnotationV alloc] init];
        user.indetifier = @"AnnotationTypeENUMUserLocation";
//        self.userLocationCustomView = user;
        return user;
    }
    return nil;
}

/*!
 @brief 当mapView新添加annotation views时，调用此接口
 @param mapView 地图View
 @param views 新添加的annotation views
 */
- (void)mapView:(id<IMapView>)mapView didAddAnnotationViews:(NSArray *)views {

}

/**
 * @brief 在地图View将要启动定位时，会调用此函数
 * @param mapView 地图View
 */
- (void)mapViewWillStartLocatingUser:(id<IMapView>)mapView {
    ///缩放级别
    [self.mapView setZoomLevel:14 animated:YES];
}

/**
 * @brief 在地图View停止定位后，会调用此函数
 * @param mapView 地图View
 */
- (void)mapViewDidStopLocatingUser:(id<IMapView>)mapView {
}

/**
 * @brief userLocation定位结束回调
 * @param mapView 地图View
 */
- (void)mapViewDidFinishLocatingUser:(id<IMapView>)mapView userLocation:(CLLocation *)locaction {
    ///获取当前用户城市编码，用于限制同城下单
    if (locaction) {
        ///地址反编译
//        [[[[LEMapEngine sharedInstance] getMapFactory] getMapSearch] reGeocodeWithLocation:locaction.coordinate onReGeocodeSearchDone:^(MSearchAddressM *response) {
//            if (response.cityCode && !response.cityCode.isEmpty) {
//                LEUserDefaultsAddObj(response.cityCode, @"CityCode")
//            }
//        }];
    }
}

/**
 * @brief 地图加载成功
 * @param mapView 地图View
 */
- (void)mapViewDidFinishLoadingMap:(id<IMapView>)mapView {
}

#pragma mark - StateMachine

@end
