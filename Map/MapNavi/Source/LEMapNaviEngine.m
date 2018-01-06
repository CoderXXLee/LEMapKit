//
//  LEMapNaviEngine.m
//  Pods
//
//  Created by mac on 2017/6/19.
//
//

#import "LEMapNaviEngine.h"
#import "GDMapNaviVC.h"
#import <CoreLocation/CoreLocation.h>
#import "GDMapNaviRideVC.h"

/**
 导航类型
 */
typedef NS_ENUM(NSInteger, IMapNaviRouteType) {
    ///骑行
    IMapNaviRouteTypeRide = 0,
    ///驾车
    IMapNaviRouteTypeDrive = 1
};

@interface LEMapNaviEngine ()

@property(nonatomic, weak) GDMapNaviVC *driveNaviVC;

@end

@implementation LEMapNaviEngine

static LEMapNaviEngine *instance = nil;

#pragma mark - LazyLoad

#pragma mark - Super

/**
 当我们调用alloc时候回调改方法(保证唯一性)
 */
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    if(instance == nil){
        static dispatch_once_t once;
        dispatch_once(&once, ^{
            instance = [super allocWithZone:zone];
        });
    }
    return instance;
}

#pragma mark - Init
#pragma mark - PublicMethod

/**
 单例模式
 */
+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

/**
 开始驾车导航
 @param coor 终点坐标
 */
- (void)startDriveNaviWithEndPoint:(CLLocationCoordinate2D)coor viewController:(UIViewController *)vc playNaviSoundString:(bMapNaviPlayNaviSoundString)sound {
    GDMapNaviVC *naviVC = [[GDMapNaviVC alloc] init];
    self.driveNaviVC = naviVC;
    naviVC.endCoor = coor;
    naviVC.bPlayNaviSound = sound;
    [vc presentViewController:naviVC animated:YES completion:nil];
}

/**
 开始骑行导航
 @param coor 终点坐标
 */
- (void)startRideNaviWithEndPoint:(CLLocationCoordinate2D)coor viewController:(UIViewController *)vc playNaviSoundString:(bMapNaviPlayNaviSoundString)sound {
    GDMapNaviRideVC *naviVC = [[GDMapNaviRideVC alloc] init];
//    self.driveNaviVC = naviVC;
    naviVC.endCoor = coor;
    naviVC.bPlayNaviSound = sound;
    [vc presentViewController:naviVC animated:YES completion:nil];
}

/**
 创建导航
 */
+ (id<IMapNavi>)getMapNavi {
    return [[GDMapNaviVC alloc] init];
}

#pragma mark - PrivateMethod
#pragma mark - Events
#pragma mark - LoadFromService
#pragma mark - Delegate
#pragma mark - StateMachine

@end
