//
//  BMBaseMapVC.m
//  ebm
//
//  Created by mac on 2017/4/19.
//  Copyright © 2017年 BM. All rights reserved.
//

#import "BMBaseMapVC.h"
#import "UIView+AutoLayout.h"
#import "BMUserAnnotationV.h"
#import "UIView+Extension.h"
#import "BMMapOverlayProperty.h"
#import "UIInfomationView.h"
#import "BMBaseMapConst.h"

@interface BMBaseMapVC ()

@property(nonatomic, strong) id<IMapFactory> factory;
@property(nonatomic, strong) id<IMapLocation> locationService;
@property(nonatomic, strong) id<IMapSearch> mapSearch;

@property (nonatomic, strong) UIImageView *pinForMap; ///地图上的起点图标

@end

@implementation BMBaseMapVC

#pragma mark - LazyLoad

- (void)setShowPin:(BOOL)showPin {
    _showPin = showPin;
    if (showPin) {
        if (!self.pinForMap) {
            [self initPinForMap];
        } else {
            [self.view addSubview:self.pinForMap];
        }
        self.pinForMap.hidden = !showPin;
    } else {
        if (self.pinForMap) {
            [self.pinForMap removeFromSuperview];
        }
    }
}

#pragma mark - Super

- (void)viewDidLoad {
    [super viewDidLoad];
    ///初始化地图
    [self initMapView];
    ///初始化大头针
    [self initPinForMap];
//    [self showReLocationWithPoint:CGPointMake([UIScreen mainScreen].bounds.size.width-56, 200)];
    ///定位授权改变监听
//    [self listenLocationAuthorization];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

#pragma mark - Init

/**
 初始化地图
 */
- (void)initMapView {
    _factory = [[BMMapEngine sharedInstance] getMapFactory];
    id<IMapView> mapView = [_factory createMapViewWithParentView:self.view frame:self.view.bounds delegate:self];
    _mapView = mapView;
    ///基础配置
    [mapView defaultSetting];

    BMUserAnnotationV *userAnno = [[BMUserAnnotationV alloc] init];
    userAnno.indetifier = @"AnnotationTypeENUMUserLocation";
    [mapView addUserLocationCustomView:userAnno];
}

/**
 添加大头针
 */
- (void)initPinForMap {
    UIImageView *pinForMap = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    pinForMap.center = CGPointMake(self.view.center.x, self.view.center.y);
    pinForMap.hidden = YES;
    self.pinForMap = pinForMap;
    [pinForMap setContentMode:UIViewContentModeScaleAspectFit];
    pinForMap.image = [UIImage imageNamed:@"redPin"];
    pinForMap.layer.zPosition = 996;
    [self.view addSubview:pinForMap];
}

/**
 定位授权改变监听
 */
- (void)listenLocationAuthorization {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted == status) {
        [UIInfomationView showAlertViewWithTitle:@"请允许该应用访问您的地理位置" message:@"我们需要获取您的位置以便自动匹配您附近的配送员，快速下单" cancelButtonTitle:@"取消" otherButtonTitles:@[@"设置"] clickAtIndex:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
        }];
    }
}

#pragma mark - PrivateMethod

/**
 添加阴影效果
 */
- (void)setupShadow:(UIView *)view {
    //添加阴影效果
    view.layer.shadowOffset = CGSizeMake(0, 0);//设置阴影偏移
    view.layer.shadowOpacity = .2;//阴影透明度
}

#pragma mark - PublicMethod

/**
 返回用户当前位置按钮
 */
- (void)showReLocationWithPoint:(CGPoint)point {
    UIButton *reLocationBtn = [[UIButton alloc] init];
    _reLocationBtn = reLocationBtn;
    [self.view addSubview:reLocationBtn];
    [reLocationBtn setBackgroundImage:[UIImage imageNamed:@"map_location_nor"] forState:UIControlStateNormal];
    [reLocationBtn addTarget:self action:@selector(reLocation) forControlEvents:UIControlEventTouchUpInside];
    reLocationBtn.frame = (CGRect){point, CGSizeMake(37, 37)};

    //添加阴影效果
    [self setupShadow:reLocationBtn];

    ///初始化交通按钮
    [self initTraffic];
}

/*!
 *  设置实时路况按钮
 */
- (void)initTraffic {
    //实时路况按钮
    UIButton *trafficBtn = [[UIButton alloc] init];
    _trafficBtn = trafficBtn;
    [trafficBtn setImage:[UIImage imageNamed:@"map_lukuang"] forState:UIControlStateSelected];
    [trafficBtn setImage:[UIImage imageNamed:@"map_lukuang_nor"] forState:UIControlStateNormal];
    trafficBtn.selected = NO;
    [self.mapView setShowTraffic:trafficBtn.isSelected];
    [trafficBtn addTarget:self action:@selector(trafficBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:trafficBtn];

    trafficBtn.frame = self.reLocationBtn.frame;
    trafficBtn.y -= 8 + trafficBtn.height;

    ///添加阴影效果
    [self setupShadow:trafficBtn];
}

/**
 设置大头针图标
 */
- (void)setPinForMapImage:(UIImage *)image {
    self.pinForMap.image = image;
    self.pinForMap.width = image.size.width;
    self.pinForMap.height = image.size.height;
    self.pinForMap.transform = CGAffineTransformMakeScale(0.7, 0.7);
    ///设置中心点偏移，使得标注底部中间点成为经纬度对应点
    self.pinForMap.center = CGPointMake(self.view.center.x, self.view.center.y - 10 + _BMMapExtendLength);
}

/**
 显示大头针
 */
- (void)showPinForMap:(BOOL)show animated:(BOOL)animated {
    self.showPin = show;
    self.pinForMap.alpha = show?1:0;
}

/**
 释放
 */
- (void)releaseViewController {
    [self.mapView clearMapView];
    _mapView = nil;
}

#pragma mark - Events

/**
 返回用户当前位置
 */
- (void)reLocation {
    [self.mapView relocation];
}

/*!
 *  实时路况按钮
 */
- (void)trafficBtn:(UIButton *)btn {
    btn.selected = !btn.isSelected;
    [self.mapView setShowTraffic:btn.selected];
}

#pragma mark - LoadFromService
#pragma mark - Delegate

///**
// 在UIViewController派生类中重写此方法来处理“返回”按钮单击事件
// */
//- (BOOL)navigationShouldPopOnBackButtonWithGesture:(BOOL)gesture {
//    [self releaseViewController];
//    if (gesture) {
//    }
//    return YES;
//}

/**
 控制器返回后回调
 */
- (void)navigationDidPop {
    [self releaseViewController];
}

/**IMapView delegate**/

- (id<IMapOverlayProperty>)mapView:(id<IMapView>)mapView rendererForOverlayType:(IMapViewOverlayType)type {
    BMMapOverlayProperty *property = [BMMapOverlayProperty new];
    ///在6sP上，若纹理图标有三倍图，在地图上将无法显示，猜测是三倍图标过大引起的
    property.loadStrokeTextureImage = [UIImage imageNamed:@"map_wl_sw_main"];
    return property;
}

/**
 * @brief 定位失败后，会调用此函数
 * @param mapView 地图View
 * @param error 错误号，参考CLError.h中定义的错误号:kCLErrorDenied
 */
- (void)mapView:(id<IMapView>)mapView didFailToLocateUserWithError:(NSError *)error {
    ///未获取定位权限
    if (error.code == kCLErrorDenied) {
        [UIInfomationView showAlertViewWithTitle:@"请允许该应用访问您的地理位置" message:@"我们需要获取您的位置以便自动匹配您附近的配送员，快速下单" cancelButtonTitle:@"取消" otherButtonTitles:@[@"设置"] clickAtIndex:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
        }];
    }
}

#pragma mark - StateMachine

@end
