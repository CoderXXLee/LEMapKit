//
//  MMapAnnotationInfoM.h
//  ebm
//
//  Created by mac on 2017/5/6.
//  Copyright © 2017年 BM. All rights reserved.
//

@import UIKit;
#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import "IAnnotationInfo.h"

@interface MMapAnnotationInfoM : NSObject<IAnnotationInfo>

/**
 id
 */
@property (nonatomic, copy) NSString *identifier;

/**
 Annotation图标
 */
@property(nonatomic, strong) UIImage *iconImage;

/**
 标题
 */
@property (nonatomic, copy) NSString *title;

/**
 副标题
 */
@property (nonatomic, copy) NSString *subtitle;

/**
 经纬度
 */
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

/**
 是否固定在屏幕一点, 注意，拖动或者手动改变经纬度，都会导致设置失效
 */
@property (nonatomic, assign, getter = isLockedToScreen) BOOL lockedToScreen;

/**
 固定屏幕点的坐标
 */
@property (nonatomic, assign) CGPoint lockedScreenPoint;

/**
 移动的角度,值随MAAnimatedAnnotation中的movingDirection的改变而改变
 */
@property (nonatomic, assign) CLLocationDirection movingDirection;

/**
 annotationView的中心默认位于annotation的坐标位置，可以设置centerOffset改变view的位置，正的偏移使view朝右下方移动，负的朝左上方，单位是屏幕坐标:CGPointMake(0, -18)
 */
@property (nonatomic) CGPoint centerOffset;

/**
 AnnotationView自定义显示的view
 */
@property(nonatomic, strong) __kindof UIView *customView;

/**
 点击回调
 */
@property(nonatomic, copy) void(^bDidClicked)(id<IAnnotationInfo> info);

/**
 选中回调，与bDidClicked只能二选一
 */
@property(nonatomic, copy) void(^bDidSelected)(id<IAnnotationInfo> info);

/**
 取消选中回调
 */
@property(nonatomic, copy) void(^bDidDeselected)(id<IAnnotationInfo> info);

/**
 置到父view的最上层
 */
@property(nonatomic, assign) BOOL bringToFront;

/**
 绑定的model模型
 */
@property(nonatomic, strong) id obj;

/**
 获取移动动画的Annotation的CLLocationCoordinate2D数组
 */
- (NSArray *)getCoordinates;

@end
