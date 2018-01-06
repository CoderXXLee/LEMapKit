//
//  ILocationService.h
//  ebm
//
//  Created by mac on 2017/4/19.
//  Copyright © 2017年 BM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void(^bIMapUpdatingLocationResponse)(NSError *error, CLLocation *location);///持续定位返回block
typedef void(^bIMapdidChangeAuthorizationStatus)(CLAuthorizationStatus status);///定位授权改变回调block

@protocol IMapLocation <NSObject>

/*!
 *  后台持续定位配置
 */
- (void)configPausesLocation;

/*!
 *  单次定位配置
 */
- (void)configSingleManager;

/*!
 *  开始持续定位
 */
- (BOOL)startUpdatingLocation;

/*!
 *  停止持续定位
 */
- (void)stopUpdatingLocation;

/**
 持续定位回调
 注意使用时只有最后一次调用该方法的地方返回数据
 */
- (void)updatingLocationResponseBlock:(bIMapUpdatingLocationResponse)responseBlock;

/**
 单次定位
 */
- (void)singleLocation:(bIMapUpdatingLocationResponse)responseBlock;

/**
 定位状态改变回调
 */
- (void)didChangeAuthorizationStatus:(bIMapdidChangeAuthorizationStatus)statusBlock;

@end
