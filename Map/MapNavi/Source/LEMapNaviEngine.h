//
//  LEMapNaviEngine.h
//  Pods
//
//  Created by mac on 2017/6/19.
//
//

#import <Foundation/Foundation.h>
#import "IMapNavi.h"

@interface LEMapNaviEngine : NSObject

/**
 单例模式
 */
+ (instancetype)sharedInstance;

/**
 开始驾车导航
 @param coor 终点坐标
 */
- (void)startDriveNaviWithEndPoint:(CLLocationCoordinate2D)coor viewController:(UIViewController *)vc playNaviSoundString:(bMapNaviPlayNaviSoundString)sound;

/**
 开始骑行导航
 @param coor 终点坐标
 */
- (void)startRideNaviWithEndPoint:(CLLocationCoordinate2D)coor viewController:(UIViewController *)vc playNaviSoundString:(bMapNaviPlayNaviSoundString)sound;

/**
 创建导航
 */
+ (id<IMapNavi>)getMapNavi;

@end
