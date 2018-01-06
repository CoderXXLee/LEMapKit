//
//  GDUtils.h
//  ebm
//
//  Created by mac on 2017/4/21.
//  Copyright © 2017年 BM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MAMapKit/MAMapKit.h>

@class MAPolyline;
@class AMapStep;
@class MSearchAddressM;
@class AMapReGeocodeSearchResponse;
@protocol MAOverlay;

/*!
 判断点是否在overlay图形中
 @param overlay 指定的overlay
 @param mapPoint   指定的点
 @param mapPointDistance 提供overlay的线宽（需换算到MAMapPoint坐标系）
 @return 若点在overlay中，返回YES，否则NO
 */
BOOL isOverlayWithLineWidthContainsPoint(id<MAOverlay> overlay, double mapPointDistance, MAMapPoint mapPoint);

/*!
 判断polyline是否在点point附近
 @param polyline  输入polyline
 @param point     输入点point
 @param threshold 判断距离门限
 @return 若polyline在point附近返回YES，否则NO
 */
BOOL isMAPolylineNearPointAtDistanceThreshold(MAPolyline *polyline, MAMapPoint point, double threshold);

#pragma mark - math

/*!
 计算点P到线段AB的距离
 @param pointP 点P
 @param pointA 线段起点A
 @param pointB 线段终点B
 @return 点P到线段AB的距离
 */
double distanceBetweenPointAndLineFromPointAtoPointB(MAMapPoint pointP, MAMapPoint pointA, MAMapPoint pointB);

/*!
 计算点到点的向量
 @param fromPoint 向量起点
 @param toPoint   向量终点
 @return 向量
 */
MAMapPoint vectorFromPointToPoint(MAMapPoint fromPoint, MAMapPoint toPoint);

/*!
 计算向量长度的平方
 @param vector 向量
 @return 长度的平方
 */
double squareLengthOfVector(MAMapPoint vector);

/*!
 计算向量的点积
 @param a 向量A
 @param b 向量B
 @return 向量A 点乘 向量B
 */
double vectorAMutiplyVectorB(MAMapPoint a, MAMapPoint b);

@interface GDUtils : NSObject

/*!
 *  @brief  将AMapStep数组生成MAPolyline
 *  在地图上添加折线对象 [self.mapView addOverlay:commonPolyline];
 */
+ (MAPolyline *)spolylineWithRouteSearch:(NSArray<AMapStep *> *)steps;

/**
 将坐标集合 @property (nonatomic, copy) NSString *polyline;进行拆分生成MAPolyline

 @param coordinateString "longitude,latitude;longitude,latitude;"
 @return MAPolyline [self.mapView addOverlay:commonPolyline];
 */
+ (MAPolyline *)polylineForCoordinateString:(NSString *)coordinateString;

/*!
 *  搜索地址格式化
 */
+ (MSearchAddressM *)formattedAddressWithResponse:(AMapReGeocodeSearchResponse *)response;

@end
