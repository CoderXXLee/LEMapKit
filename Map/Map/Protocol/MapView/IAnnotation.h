//
//  IAnnotation.h
//  ebm
//
//  Created by mac on 2017/4/20.
//  Copyright © 2017年 BM. All rights reserved.
//

@import UIKit;
#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>

///添加到地图上的Annotation的类型
typedef NS_ENUM(NSInteger, AnnotationTypeENUM) {
    AnnotationTypeENUMDefault = 0,
    AnnotationTypeENUMUserLocation///用户位置
};

@protocol IAnnotation <NSObject>

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
 AnnotationView自定义显示的view
 */
@property(nonatomic, strong) UIView *customView;

/**
 返回指定的与当前地图相关的模型数据
 */
- (id)getObject;

/**
 获取Annotation的类型
 @return 类型
 */
- (AnnotationTypeENUM)getAnnotationType;
@end
