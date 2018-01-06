//
//  GDAnnotation.h
//  ebm
//
//  Created by mac on 2017/4/20.
//  Copyright © 2017年 BM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAnnotation.h"
#import "GDBaseObject.h"

@interface GDAnnotation : GDBaseObject<IAnnotation>

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

@end
