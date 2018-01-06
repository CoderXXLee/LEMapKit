//
//  GDMapNaviVC.m
//  Pods
//
//  Created by mac on 2017/6/19.
//
//

#import "GDMapNaviVC.h"
#import "AMapNaviKit.h"

@interface GDMapNaviVC ()<AMapNaviDriveManagerDelegate, AMapNaviDriveViewDelegate>

@property (nonatomic, strong) AMapNaviDriveManager *driveManager;
@property (nonatomic, strong) AMapNaviDriveView *driveView;

@property (nonatomic, strong) AMapNaviPoint *startPoint;
@property (nonatomic, strong) AMapNaviPoint *endPoint;

@property(nonatomic, assign, readonly) BOOL isSpeaking;///导航播报回调是否在播报语音中

@end

@implementation GDMapNaviVC

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
//    self.startPoint = [AMapNaviPoint locationWithLatitude:39.993135 longitude:116.474175];
    self.endPoint = [AMapNaviPoint locationWithLatitude:self.endCoor.latitude longitude:self.endCoor.longitude];
}

- (void)initDriveManager {
    if (self.driveManager == nil) {
        self.driveManager = [[AMapNaviDriveManager alloc] init];
        [self.driveManager setDelegate:self];

        //将driveView添加为导航数据的Representative，使其可以接收到导航诱导数据
        [self.driveManager addDataRepresentative:self.driveView];
    }
}

- (void)initDriveView {
    if (self.driveView == nil) {
        self.driveView = [[AMapNaviDriveView alloc] initWithFrame:self.view.bounds];
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
    [self.driveManager calculateDriveRouteWithEndPoints:@[self.endPoint] wayPoints:nil drivingStrategy:(AMapNaviDrivingStrategySingleAvoidCongestion)];
}

#pragma mark - Events
#pragma mark - LoadFromService

#pragma mark - AMapNaviDriveManager Delegate

- (void)driveManager:(AMapNaviDriveManager *)driveManager error:(NSError *)error {
    NSLog(@"error:{%ld - %@}", (long)error.code, error.localizedDescription);
}

- (void)driveManagerOnCalculateRouteSuccess:(AMapNaviDriveManager *)driveManager {
    NSLog(@"onCalculateRouteSuccess");

    //算路成功后进行模拟导航
//    [self.driveManager startEmulatorNavi];
    [self.driveManager startGPSNavi];
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager onCalculateRouteFailure:(NSError *)error {
    NSLog(@"onCalculateRouteFailure:{%ld - %@}", (long)error.code, error.localizedDescription);
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager didStartNavi:(AMapNaviMode)naviMode {
    NSLog(@"didStartNavi");
}

- (void)driveManagerNeedRecalculateRouteForYaw:(AMapNaviDriveManager *)driveManager {
    NSLog(@"needRecalculateRouteForYaw");
}

- (void)driveManagerNeedRecalculateRouteForTrafficJam:(AMapNaviDriveManager *)driveManager {
    NSLog(@"needRecalculateRouteForTrafficJam");
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager onArrivedWayPoint:(int)wayPointIndex {
    NSLog(@"onArrivedWayPoint:%d", wayPointIndex);
}

- (BOOL)driveManagerIsNaviSoundPlaying:(AMapNaviDriveManager *)driveManager {
    //    return [[SpeechSynthesizer sharedSpeechSynthesizer] isSpeaking];
    return self.isSpeaking;
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager playNaviSoundString:(NSString *)soundString soundStringType:(AMapNaviSoundType)soundStringType {
    NSLog(@"playNaviSoundString:{%ld:%@}", (long)soundStringType, soundString);

    if (self.bPlayNaviSound) {
        self.bPlayNaviSound(soundString, &(_isSpeaking));
    }

    //    [[SpeechSynthesizer sharedSpeechSynthesizer] speakString:soundString];
}

- (void)driveManagerDidEndEmulatorNavi:(AMapNaviDriveManager *)driveManager {
    NSLog(@"didEndEmulatorNavi");
}

- (void)driveManagerOnArrivedDestination:(AMapNaviDriveManager *)driveManager {
    NSLog(@"onArrivedDestination");
}

#pragma mark - AMapNaviWalkViewDelegate

- (void)driveViewCloseButtonClicked:(AMapNaviDriveView *)driveView {
    //停止导航
    [self.driveManager stopNavi];
    [self.driveManager removeDataRepresentative:self.driveView];

    //停止语音
    //    [[SpeechSynthesizer sharedSpeechSynthesizer] stopSpeak];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)driveViewMoreButtonClicked:(AMapNaviDriveView *)driveView {
    //配置MoreMenu状态
}

- (void)driveViewTrunIndicatorViewTapped:(AMapNaviDriveView *)driveView {
    NSLog(@"TrunIndicatorViewTapped");
}

- (void)driveView:(AMapNaviDriveView *)driveView didChangeShowMode:(AMapNaviDriveViewShowMode)showMode {
    NSLog(@"didChangeShowMode:%ld", (long)showMode);
}

@end
