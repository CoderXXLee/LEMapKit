//
//  IMapSearch.h
//  ebm
//
//  Created by mac on 2017/4/19.
//  Copyright © 2017年 BM. All rights reserved.
//

@import UIKit;
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@class MSearchAddressM;
@protocol ISearchRouteM, IMapView;

@protocol IMapSearch <NSObject>

/**
 地理编码查询

 @param address 地址,必填
 @param city 查询城市，可选值：cityname（中文或中文全拼）、citycode、adcode.
 */
- (void)geocodeWithAddress:(NSString *)address city:(NSString *)city onGeocodeSearchDone:(void(^)(NSError *error, MSearchAddressM *searchAddress))completion;

/*!
 *  逆地理编码查询
 */
- (void)reGeocodeWithLocation:(CLLocationCoordinate2D)loc onReGeocodeSearchDone:(void(^)(MSearchAddressM *response))completion;

/*!
 *  通过关键字搜索
 *  city:查询城市，可选值：cityname（中文或中文全拼）、citycode、adcode.
 */
- (void)searchTipsWithKey:(NSString *)key city:(NSString *)city searchResult:(void(^)(NSError *error, NSArray<MSearchAddressM *> *searchMArr))searchTipsBlock;

/**
 绘制从起点到终点的最佳路线，驾车

 @param points 途经点
 @param mapView 地图
 @param completion 是否规划成功block
 */
- (void)drivingSearchRouteWithPoint:(NSArray<id<ISearchRouteM>> *)points mapView:(id<IMapView>)mapView identifier:(NSString *)identifier onRouteSearchDone:(void(^)(BOOL isSuccess, NSString *identifier, CGFloat distance))completion;

/**
 绘制从起点到终点的最佳路线，骑行
 只支持起点到终点，不支持多途经点

 @param points 途经点
 @param mapView 地图
 @param completion 是否规划成功block
 */
- (void)searchRouteRideWithPoint:(NSArray<id<ISearchRouteM>> *)points mapView:(id<IMapView>)mapView identifier:(NSString *)identifier onRouteSearchDone:(void(^)(BOOL isSuccess, NSString *identifier, CGFloat distance))completion;

/**
 添加规划的线路到地图上，首先调用上面的驾车/骑行规划线路

 @param mapView 地图，不为空
 @param identifier 不为空，规划线路时设置的ID
 @param insets 不知道高德是如何设置的：UIEdgeInsetsMake([UIScreen mainScreen].bounds.size.height*3/4.f, 50, 0, 50)
 @param show 是否在地图上显示线路
 */
- (void)addNaviRouteToMapView:(id<IMapView>)mapView identifier:(NSString *)identifier edgePadding:(UIEdgeInsets)insets showOverlays:(BOOL)show;

/**
 添加规划的线路到地图上，首先要规划线路

 @param mapView 地图，不为空
 @param identifier ID不为空
 @param insets 不进行调整
 */
- (void)addNaviRouteToMapView:(id<IMapView>)mapView identifier:(NSString *)identifier visibleEdgePadding:(UIEdgeInsets)insets showOverlays:(BOOL)show;

/**
 根据identifier移除线路规划缓存
 */
- (void)removeSearchRouteCache:(NSString *)identifier;

/**
 搜索行政区域
 */
- (void)searchDistrictWithName:(NSString *)name mapView:(id<IMapView>)mapView onDistrictSearchDone:(void(^)(BOOL isSuccess, NSArray *polylineArr))completion;

@end
