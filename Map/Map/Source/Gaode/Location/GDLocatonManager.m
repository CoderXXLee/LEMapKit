//
//  GDLocatonManager.m
//  Pods
//
//  Created by mac on 2017/6/6.
//
//

#import "GDLocatonManager.h"
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <MMapConst.h>

@interface GDLocatonManager ()<AMapLocationManagerDelegate>

@property(nonatomic, strong) AMapLocationManager *locationManager;///搜索

@property(nonatomic, strong) NSMapTable *mapTable;///存储bGDSearchDone响应结果

@end

@implementation GDLocatonManager

static GDLocatonManager *_instance = nil;

#pragma mark - LazyLoad
#pragma mark - Super

/**
 当我们调用alloc时候回调改方法(保证唯一性)
 */
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    if(_instance == nil){
        static dispatch_once_t once;
        dispatch_once(&once, ^{
            _instance = [super allocWithZone:zone];
//            [_instance configSearchManager];
        });
    }
    return _instance;
}

#pragma mark - Init
#pragma mark - PublicMethod

/**
 单例模式
 */
+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _instance = [[GDLocatonManager alloc] init];
//        [instance configSearchManager];
    });
    return _instance;
}

#pragma mark - Protocol 实现

/*!
 *  后台持续定位配置
 */
- (void)configPausesLocation {
    [self configLocationManager];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    ///设置定位最小更新距离方法如下，单位米。当两次定位距离满足设置的最小更新距离时，SDK会返回符合要求的定位结果。
    self.locationManager.distanceFilter = 10;
    [self.locationManager setDelegate:self];
    ///连续定位是否返回逆地理信息，默认NO。
    self.locationManager.locatingWithReGeocode = NO;

    ///iOS 9（不包含iOS 9） 之前设置允许后台定位参数，保持不会被系统挂起
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];

    ///iOS 9（包含iOS 9）之后新特性：将允许出现这种场景，同一app中多个locationmanager：一些只能在前台定位，另一些可在后台定位，并可随时禁止其后台定位。
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
        self.locationManager.allowsBackgroundLocationUpdates = YES;
    }
}

/*!
 *  单次定位配置
 */
- (void)configSingleManager {
    [self configLocationManager];
    // 带逆地理信息的一次定位（返回坐标和地址信息）
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    //   定位超时时间，可修改，最小2s
    self.locationManager.locationTimeout = 3;
    //   逆地理请求超时时间，可修改，最小2s
    self.locationManager.reGeocodeTimeout = 3;
    //    self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
}

/*!
 *  开始持续定位
 */
- (BOOL)startUpdatingLocation {
    if ([self checkAuthorizationStatus]) {
        LELog(@"开始持续定位");
        [self.locationManager startUpdatingLocation];
        return YES;
    } else {
//        LEAlertViewPlain(@"请允许该应用访问您的地理位置");
        return NO;
    }
}

/*!
 *  停止持续定位
 */
- (void)stopUpdatingLocation {
    LELog(@"停止持续定位");
    [self.locationManager stopUpdatingLocation];
}

/**
 持续定位回调
 注意使用时只有最后一次调用该方法的地方返回数据
 */
- (void)updatingLocationResponseBlock:(bIMapUpdatingLocationResponse)responseBlock {
    [_mapTable setObject:responseBlock forKey:@"updatingLocationResponseBlock"];
}

/**
 单次定位
 */
- (void)singleLocation:(bIMapUpdatingLocationResponse)responseBlock {
    BOOL suc = [self startUpdatingLocation];
    if (!suc) {
        responseBlock(LEError(@"未开启定位授权", -2001), nil);
    } else {
        [_mapTable setObject:responseBlock forKey:@"singleLocationBlock"];
    }
}

/**
 定位状态改变回调
 */
- (void)didChangeAuthorizationStatus:(bIMapdidChangeAuthorizationStatus)statusBlock {
    [_mapTable setObject:statusBlock forKey:@"authorizationStatusBlock"];
}

#pragma mark - PrivateMethod

/*!
 *  @brief  定位配置
 */
- (void)configLocationManager {
    if (!self.locationManager) {
        self.locationManager = [[AMapLocationManager alloc] init];
        self.locationManager.delegate = self;
        _mapTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsCopyIn];
    }
}

/*!
 *  检查定位服务状态
 */
- (BOOL)checkAuthorizationStatus {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted == status) {
        //        LEAlertViewPlain(@"请允许该应用访问您的地理位置");
        return NO;
    }
    return YES;
}

#pragma mark - Events
#pragma mark - LoadFromService
#pragma mark - Delegate

/**
 *  @brief 当定位发生错误时，会调用代理的此方法。
 *  @param manager 定位 AMapLocationManager 类。
 *  @param error 返回的错误，参考 CLError 。
 */
- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error {
    bIMapUpdatingLocationResponse block = [_mapTable objectForKey:@"updatingLocationResponseBlock"];
    if (block) {
        block(error, nil);
    }
    bIMapUpdatingLocationResponse single = [_mapTable objectForKey:@"singleLocationBlock"];
    if (single) {
        single(error, nil);
        [_mapTable removeObjectForKey:@"singleLocationBlock"];
    }
}

/**
 *  @brief 连续定位回调函数.注意：如果实现了本方法，则定位信息不会通过amapLocationManager:didUpdateLocation:方法回调。
 *  @param manager 定位 AMapLocationManager 类。
 *  @param location 定位结果。
 *  @param reGeocode 逆地理信息。
 */
- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode {
    NSLog(@"持续定位数据返回：%@", location);
    bIMapUpdatingLocationResponse block = [_mapTable objectForKey:@"updatingLocationResponseBlock"];
    if (block) {
        block(nil, location);
    }
    
    ///单次定位
    bIMapUpdatingLocationResponse single = [_mapTable objectForKey:@"singleLocationBlock"];
    if (single) {
        single(nil, location);
        [_mapTable removeObjectForKey:@"singleLocationBlock"];
        ///未开启持续定位，单次定位后关闭
        if (!block) {
            [self stopUpdatingLocation];
        }
    }

}

/**
 *  @brief 定位权限状态改变时回调函数
 *  @param manager 定位 AMapLocationManager 类。
 *  @param status 定位权限状态。
 */
- (void)amapLocationManager:(AMapLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    bIMapdidChangeAuthorizationStatus block = [_mapTable objectForKey:@"authorizationStatusBlock"];
    if (block) {
        block(status);
    }
    if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted == status) {
//        LEAlertViewPlain(@"请允许该应用访问您的地理位置");
    }
}

/**
 *  @brief 开始监控region回调函数
 *  @param manager 定位 AMapLocationManager 类。
 *  @param region 开始监控的region。
 */
- (void)amapLocationManager:(AMapLocationManager *)manager didStartMonitoringForRegion:(AMapLocationRegion *)region {}

/**
 *  @brief 进入region回调函数
 *  @param manager 定位 AMapLocationManager 类。
 *  @param region 进入的region。
 */
- (void)amapLocationManager:(AMapLocationManager *)manager didEnterRegion:(AMapLocationRegion *)region {}

/**
 *  @brief 离开region回调函数
 *  @param manager 定位 AMapLocationManager 类。
 *  @param region 离开的region。
 */
- (void)amapLocationManager:(AMapLocationManager *)manager didExitRegion:(AMapLocationRegion *)region {}

/**
 *  @brief 查询region状态回调函数
 *  @param manager 定位 AMapLocationManager 类。
 *  @param state 查询的region的状态。
 *  @param region 查询的region。
 */
- (void)amapLocationManager:(AMapLocationManager *)manager didDetermineState:(AMapLocationRegionState)state forRegion:(AMapLocationRegion *)region {}

/**
 *  @brief 监控region失败回调函数
 *  @param manager 定位 AMapLocationManager 类。
 *  @param region 失败的region。
 *  @param error 错误信息，参考 AMapLocationErrorCode 。
 */
- (void)amapLocationManager:(AMapLocationManager *)manager monitoringDidFailForRegion:(AMapLocationRegion *)region withError:(NSError *)error {

}

#pragma mark - StateMachine

@end
