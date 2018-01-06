//
//  IMapDelegate.h
//  ebm
//
//  Created by mac on 2017/4/20.
//  Copyright © 2017年 BM. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IMapView;
@protocol IUserLocation;
@protocol IAnnotation, IAnnotationInfo;
@protocol IAnnotationView, IMapOverlayProperty;
@class CLLocation;

/**
 地图规划线路类型
 */
typedef NS_ENUM(NSInteger, IMapViewOverlayType) {
    ///默认
    IMapViewOverlayTypeDefault = 0,
    ///不行的路
    IMapViewOverlayTypeLineDash = 1
};

@protocol IMapDelegate <NSObject>

@optional

/*!
 @brief 位置或者设备方向更新后，会调用此函数
 @param mapView 地图View
 @param userLocation 用户定位信息(包括位置与设备方向等数据)
 @param updatingLocation 标示是否是location数据更新, YES:location数据更新 NO:heading数据更新
 @param degree 手机陀螺仪旋转角度
 */
- (void)mapView:(id<IMapView>)mapView didUpdateUserLocation:(id<IUserLocation>)userLocation updatingLocation:(BOOL)updatingLocation degree:(CGFloat)degree;

/*!
 @brief 地图区域即将改变时会调用此接口
 @param mapView 地图View
 @param animated 是否动画
 */
- (void)mapView:(id<IMapView>)mapView regionWillChangeAnimated:(BOOL)animated;

/*!
 @brief 地图区域改变完成后会调用此接口
 @param mapView 地图View
 @param animated 是否动画
 */
- (void)mapView:(id<IMapView>)mapView regionDidChangeAnimated:(BOOL)animated;

/**
 *  地图将要发生移动时调用此接口
 *
 *  @param mapView       地图view
 *  @param wasUserAction 标识是否是用户动作
 */
- (void)mapView:(id<IMapView>)mapView mapWillMoveByUser:(BOOL)wasUserAction;

/**
 *  地图移动结束后调用此接口
 *
 *  @param mapView       地图view
 *  @param wasUserAction 标识是否是用户动作
 */
- (void)mapView:(id<IMapView>)mapView mapDidMoveByUser:(BOOL)wasUserAction;

/*!
 @brief 根据anntation生成对应的View
 @param mapView 地图View
 @param annotation 指定的标注
 @return 生成的标注View
 */
- (id<IAnnotationView>)mapView:(id<IMapView>)mapView viewForAnnotation:(id<IAnnotation>)annotation;

/*!
 @brief 当mapView新添加annotation views时，调用此接口
 @param mapView 地图View
 @param views 新添加的annotation views
 */
- (void)mapView:(id<IMapView>)mapView didAddAnnotationViews:(NSArray *)views;

/**
 * @brief 当选中一个annotation view时，调用此接口. 注意如果已经是选中状态，再次点击不会触发此回调。取消选中需调用-(void)deselectAnnotation:animated:
 * @param mapView 地图View
 * @param view 选中的annotation view
 */
- (void)mapView:(id<IMapView>)mapView didSelectAnnotationView:(id<IAnnotationInfo>)view;

/**
 * @brief 当取消选中一个annotation view时，调用此接口
 * @param mapView 地图View
 * @param view 取消选中的annotation view
 */
- (void)mapView:(id<IMapView>)mapView didDeselectAnnotationView:(id<IAnnotationInfo>)view;

/**
 * @brief 在地图View将要启动定位时，会调用此函数
 * @param mapView 地图View
 */
- (void)mapViewWillStartLocatingUser:(id<IMapView>)mapView;

/**
 * @brief 在地图View停止定位后，会调用此函数
 * @param mapView 地图View
 */
- (void)mapViewDidStopLocatingUser:(id<IMapView>)mapView;

/**
 * @brief userLocation定位结束回调
 * @param mapView 地图View
 */
- (void)mapViewDidFinishLocatingUser:(id<IMapView>)mapView userLocation:(CLLocation *)locaction;

/**
 * @brief 地图加载成功
 * @param mapView 地图View
 */
- (void)mapViewDidFinishLoadingMap:(id<IMapView>)mapView;

/**
 规划线路属性

 @param mapView 地图View
 @param type 类型
 */
- (id<IMapOverlayProperty>)mapView:(id<IMapView>)mapView rendererForOverlayType:(IMapViewOverlayType)type;

/**
 * @brief 定位失败后，会调用此函数
 * @param mapView 地图View
 * @param error 错误号，参考CLError.h中定义的错误号:kCLErrorDenied
 */
- (void)mapView:(id<IMapView>)mapView didFailToLocateUserWithError:(NSError *)error;

@end
