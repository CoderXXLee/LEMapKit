//
//  MapUtils.h
//  ebm
//
//  Created by mac on 2017/5/10.
//  Copyright © 2017年 BM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

//切换到主线程
#define dispatch_main_sync_safe_map(block)\
if ([NSThread isMainThread]) {\
block();\
}\
else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}

//动画
#define MoveAnimation(animationBlock, completionBlock)\
[UIView animateWithDuration:.5 delay:0 usingSpringWithDamping:.98 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseIn animations:animationBlock completion:completionBlock];

@interface MapUtils : NSObject

/**
 计算角度
 */
+ (CLLocationDirection)calculateCourseFromCoordinate:(CLLocationCoordinate2D)coord1 to:(CLLocationCoordinate2D)coord2;

/**
 计算角度
 */
+ (CLLocationDirection)calculateDirectionFromCoordinate:(CLLocationCoordinate2D)coord1 to:(CLLocationCoordinate2D)coord2;

@end
