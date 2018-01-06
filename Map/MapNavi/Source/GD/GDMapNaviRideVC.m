//
//  GDMapRideNaviVC.m
//  Pods
//
//  Created by mac on 2017/6/20.
//
//

#import "GDMapNaviRideVC.h"
#import "AMapNaviKit.h"

@interface GDMapNaviRideVC ()<AMapNaviRideManagerDelegate, AMapNaviRideViewDelegate>

@property (nonatomic, strong) AMapNaviRideManager *driveManager;
@property (nonatomic, strong) AMapNaviRideView *driveView;

@property (nonatomic, strong) AMapNaviPoint *startPoint;
@property (nonatomic, strong) AMapNaviPoint *endPoint;

@property(nonatomic, assign, readonly) BOOL isSpeaking;///导航播报回调是否在播报语音中

@end

@implementation GDMapNaviRideVC

#pragma mark - LazyLoad
#pragma mark - Super

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self initProperties];
    [self initDriveView];
    [self initDriveManager];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self calculateRoute];
}

- (void)viewWillLayoutSubviews {
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    //    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
    //        interfaceOrientation = self.interfaceOrientation;
    //    }

    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        [self.driveView setIsLandscape:NO];
    }
    else if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        [self.driveView setIsLandscape:YES];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)dealloc {
    NSLog(@"驾车导航销毁");
    self.bPlayNaviSound = nil;
}

#pragma mark - Init

- (void)initProperties {
    //为了方便展示,选择了固定的起终点
    self.startPoint = [AMapNaviPoint locationWithLatitude:39.993135 longitude:116.474175];
    self.endPoint = [AMapNaviPoint locationWithLatitude:self.endCoor.latitude longitude:self.endCoor.longitude];
}

- (void)initDriveManager {
    if (self.driveManager == nil) {
        self.driveManager = [[AMapNaviRideManager alloc] init];
        [self.driveManager setDelegate:self];

        //将driveView添加为导航数据的Representative，使其可以接收到导航诱导数据
        [self.driveManager addDataRepresentative:self.driveView];
    }
}

- (void)initDriveView {
    if (self.driveView == nil) {
        self.driveView = [[AMapNaviRideView alloc] initWithFrame:self.view.bounds];
        self.driveView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.driveView setDelegate:self];

        [self.view addSubview:self.driveView];

        self.driveView.trackingMode = AMapNaviViewTrackingModeCarNorth;
    }
}

#pragma mark - PublicMethod

/**
 获取控制器
 */
- (UIViewController *)getViewController {
    return self;
}

#pragma mark - PrivateMethod

- (void)calculateRoute {
    //进行路径规划
    //    [self.driveManager calculateDriveRouteWithStartPoints:@[self.startPoint] endPoints:@[self.endPoint] wayPoints:nil drivingStrategy:AMapNaviDrivingStrategySingleDefault];
    [self.driveManager calculateRideRouteWithEndPoint:self.endPoint];
}

#pragma mark - Events
#pragma mark - LoadFromService

#pragma mark - AMapNaviRideManager Delegate

/**
 * @brief 发生错误时,会调用代理的此方法
 * @param rideManager 骑行导航管理类
 * @param error 错误信息
 */
- (void)rideManager:(AMapNaviRideManager *)rideManager error:(NSError *)error {
    NSLog(@"error:{%ld - %@}", (long)error.code, error.localizedDescription);
}

/**
 * @brief 骑行路径规划成功后的回调函数
 * @param rideManager 骑行导航管理类
 */
- (void)rideManagerOnCalculateRouteSuccess:(AMapNaviRideManager *)rideManager {
    NSLog(@"onCalculateRouteSuccess");
    //算路成功后进行模拟导航
//    [self.driveManager startEmulatorNavi];
    [self.driveManager startGPSNavi];
}

/**
 * @brief 骑行路径规划失败后的回调函数
 * @param rideManager 骑行导航管理类
 * @param error 错误信息,error.code参照AMapNaviCalcRouteState
 */
- (void)rideManager:(AMapNaviRideManager *)rideManager onCalculateRouteFailure:(NSError *)error {
    NSLog(@"onCalculateRouteFailure:{%ld - %@}", (long)error.code, error.localizedDescription);
}

/**
 * @brief 启动导航后回调函数
 * @param rideManager 骑行导航管理类
 * @param naviMode 导航类型，参考AMapNaviMode
 */
- (void)rideManager:(AMapNaviRideManager *)rideManager didStartNavi:(AMapNaviMode)naviMode {
    NSLog(@"didStartNavi");
}

/**
 * @brief 出现偏航需要重新计算路径时的回调函数.偏航后将自动重新路径规划,该方法将在自动重新路径规划前通知您进行额外的处理.
 * @param rideManager 骑行导航管理类
 */
- (void)rideManagerNeedRecalculateRouteForYaw:(AMapNaviRideManager *)rideManager {
    NSLog(@"needRecalculateRouteForYaw");
}

/**
 * @brief 导航播报信息回调函数
 * @param rideManager 骑行导航管理类
 * @param soundString 播报文字
 * @param soundStringType 播报类型,参考AMapNaviSoundType
 */
- (void)rideManager:(AMapNaviRideManager *)rideManager playNaviSoundString:(NSString *)soundString soundStringType:(AMapNaviSoundType)soundStringType {
    NSLog(@"playNaviSoundString:{%ld:%@}", (long)soundStringType, soundString);

    if (self.bPlayNaviSound) {
        self.bPlayNaviSound(soundString, &(_isSpeaking));
    }

    //    [[SpeechSynthesizer sharedSpeechSynthesizer] speakString:soundString];
}

/**
 * @brief 模拟导航到达目的地停止导航后的回调函数
 * @param rideManager 骑行导航管理类
 */
- (void)rideManagerDidEndEmulatorNavi:(AMapNaviRideManager *)rideManager {
    NSLog(@"didEndEmulatorNavi");
}

/**
 * @brief 导航到达目的地后的回调函数
 * @param rideManager 骑行导航管理类
 */
- (void)rideManagerOnArrivedDestination:(AMapNaviRideManager *)rideManager {
    NSLog(@"onArrivedDestination");
}


#pragma mark - AMapNaviRideViewDelegate

/**
 * @brief 导航界面关闭按钮点击时的回调函数
 * @param rideView 骑行导航界面
 */
- (void)rideViewCloseButtonClicked:(AMapNaviRideView *)rideView {
    //停止导航
    [self.driveManager stopNavi];
    [self.driveManager removeDataRepresentative:self.driveView];

    //停止语音
    //    [[SpeechSynthesizer sharedSpeechSynthesizer] stopSpeak];

    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 * @brief 导航界面更多按钮点击时的回调函数
 * @param rideView 骑行导航界面
 */
- (void)rideViewMoreButtonClicked:(AMapNaviRideView *)rideView {

}

/**
 * @brief 导航界面转向指示View点击时的回调函数
 * @param rideView 骑行导航界面
 */
- (void)rideViewTrunIndicatorViewTapped:(AMapNaviRideView *)rideView {
    NSLog(@"TrunIndicatorViewTapped");
}

/**
 * @brief 导航界面显示模式改变后的回调函数
 * @param rideView 骑行导航界面
 * @param showMode 显示模式
 */
- (void)rideView:(AMapNaviRideView *)rideView didChangeShowMode:(AMapNaviRideViewShowMode)showMode {
    NSLog(@"didChangeShowMode:%ld", (long)showMode);
}

@end
