//
//  BMBaseMapVC.h
//  ebm
//
//  Created by mac on 2017/4/19.
//  Copyright © 2017年 BM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewImpHeaders.h"
#import "BMMapEngine.h"

@interface BMBaseMapVC : UIViewController<IMapDelegate>

@property(nonatomic, strong, readonly) id<IMapView> mapView;

/**
 返回当前位置
 */
@property(nonatomic, weak, readonly) UIButton *reLocationBtn;

/**
 实时路况按钮
 */
@property(nonatomic, weak, readonly) UIButton *trafficBtn;

/*!
 *  展示大头针，默认NO
 */
@property(nonatomic, assign) BOOL showPin;

/**
 显示大头针
 */
- (void)showPinForMap:(BOOL)show animated:(BOOL)animated;

/**
 设置大头针图标
 */
- (void)setPinForMapImage:(UIImage *)image;

/**
 显示用户当前位置按钮
 */
- (void)showReLocationWithPoint:(CGPoint)point;

/**
 释放
 */
- (void)releaseViewController;

@end
