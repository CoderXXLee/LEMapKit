//
//  IMapView.h
//  ebm
//
//  Created by mac on 2017/4/19.
//  Copyright © 2017年 BM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@protocol IMapDelegate;
@protocol IAnnotationInfo, IAnnotationView;
@class MMapAnnotationInfoM;

@protocol IMapView <NSObject>

/**
 获取地图view，添加到父view中
 */
- (UIView *)getView;

/**
 构造方法需要指定MapView大小
 */
- (instancetype)initWithFrame:(CGRect)frame parentView:(UIView *)parentView;

/**
 设置代理
 */
- (void)setDelegate:(id<IMapDelegate>)delegate;

/**
 基础设置
 */
- (void)defaultSetting;

/**
 清除地图
 */
- (void)clearMapView;

/**
 获取自定义用户位置显示view
 */
- (void)addUserLocationCustomView:(id<IAnnotationView>)view;

/**
 获取自定义用户位置显示view
 */
- (id<IAnnotationView>)getUserLocationCustomView;

/**
 获取用户当前位置
 */
- (CLLocation *)getUserLocation;

/**
 * @brief 设置缩放级别（默认3-19，有室内地图时为3-20）
 * @param zoomLevel 要设置的缩放级别
 * @param animated 是否动画设置
 */
- (void)setZoomLevel:(CGFloat)zoomLevel animated:(BOOL)animated;

/**
 * @brief 获取缩放级别（默认3-19，有室内地图时为3-20）
 */
- (CGFloat)getZoomLevel;

/**
 * @brief 设置当前地图的中心点，改变该值时，地图的比例尺级别不会发生变化
 * @param coordinate 要设置的中心点
 * @param animated 是否动画设置
 */
- (void)setCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated;

/**
 定位到当前位置
 */
- (void)relocation;

/**
 是否显示交通
 */
- (void)setShowTraffic:(BOOL)showTraffic;

/**
 * @brief 向地图窗口添加标注，需要实现MAMapViewDelegate的-mapView:viewForAnnotation:函数来生成标注对应的View
 * @param annotationInfo 要添加的标注
 * @return 添加是否成功
 */
- (BOOL)addAnnotationInfo:(MMapAnnotationInfoM *)annotationInfo;

/**
 * @brief 向地图窗口添加一组标注，需要实现IMapDelegate的-mapView:viewForAnnotation:函数来生成标注对应的View
 * @param annotationInfos 要添加的标注数组
 */
- (void)addAnnotationInfos:(NSArray<MMapAnnotationInfoM *> *)annotationInfos;

/**
 * @brief 移除标注
 * @param annotationIdentifier 要移除的标注ID
 */
- (id<IAnnotationInfo>)removeAnnotationInfo:(NSString *)annotationIdentifier animation:(BOOL)animation;

/**
 * @brief 移除一组标注
 * @param annotationIdentifiers 要移除的标注数组ID
 */
- (void)removeAnnotationInfos:(NSArray<NSString *> *)annotationIdentifiers animation:(BOOL)animation;

/**
 * @brief 向地图窗口添加标注，需要实现MAMapViewDelegate的-mapView:viewForAnnotation:函数来生成标注对应的View
 * @param annotationInfo 要添加的标注
 */
- (void)addAnimatedAnnotationInfo:(MMapAnnotationInfoM *)annotationInfo;

/**
 MMapAnnotationInfoM平滑移动标注位置
 */
- (void)moveAnnotationWithInfo:(MMapAnnotationInfoM *)info;

/**
 * @brief 移除Annotation
 */
- (void)removeAllAnnotation;

/**
 通过annotationIdentifier获取id<IAnnotationInfo>
 */
- (id<IAnnotationInfo>)annotationInfoWithIdentifier:(NSString *)annotationIdentifier;

/**
 通过annotationIdentifier获取view
 */
- (UIView *)viewForAnnotationIdentifier:(NSString *)annotationIdentifier;

/**
 * @brief 设定当前地图的经纬度范围，该范围可能会被调整为适合地图窗口显示的范围
 * @param rect 要设定的范围
 * @param animated 是否动画设置
 *
 */
- (void)setRegionWithView:(UIView *)view rect:(CGRect)rect animated:(BOOL)animated;

/**
 * @brief 将指定view坐标系的坐标转换为经纬度
 * @param point 指定view坐标系的坐标
 * @param view 指定的view
 * @return 经纬度
 */
- (CLLocationCoordinate2D)convertPoint:(CGPoint)point toCoordinateFromView:(UIView *)view;

/**
 * @brief 移除所以Overlay
 */
- (void)removeAllOverlay;

/**
 * @brief 设置可见地图矩形区域
 * @param insets 边缘插入
 * @param annotationInfos id<IAnnotationInfo>标注数组, 必须要2个以上才能使用
 * @param animated 是否动画效果
 */
- (void)setVisibleWithAnnotationInfos:(NSArray<id<IAnnotationInfo>> *)annotationInfos edgePadding:(UIEdgeInsets)insets animated:(BOOL)animated;

@end
