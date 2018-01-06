//
//  GDUtils.m
//  ebm
//
//  Created by mac on 2017/4/21.
//  Copyright © 2017年 BM. All rights reserved.
//

#import "GDUtils.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import "MSearchAddressM.h"
#import <NSString+MCategory.h>

/*!
 判断polyline是否在点point附近
 @param polyline  输入polyline
 @param point     输入点point
 @param threshold 判断距离门限
 @return 若polyline在point附近返回YES，否则NO
 */
BOOL isMAPolylineNearPointAtDistanceThreshold(MAPolyline *polyline, MAMapPoint point, double threshold)
{
    for (int i = 1; i<polyline.pointCount; i++)
    {
        double distance = distanceBetweenPointAndLineFromPointAtoPointB(point, polyline.points[i-1], polyline.points[i]);
        if (distance < threshold)
        {
            return YES;
        }
    }

    return NO;
}

/*!
 判断点是否在overlay的图形中
 @param overlay 指定的overlay
 @param point   指定的点
 @param mapPointDistance 提供overlay的线宽（需换算到MAMapPoint坐标系）
 @return 若点在overlay中，返回YES，否则NO
 */
BOOL isOverlayWithLineWidthContainsPoint(id<MAOverlay> overlay, double mapPointDistance, MAMapPoint mapPoint)
{
    /* 将point转换为经纬度和MapPoint. */
    CLLocationCoordinate2D coordinate = MACoordinateForMapPoint(mapPoint);

    /* 判断point是否在overlay内*/
    if([overlay isKindOfClass:[MACircle class]])
    {
        return MACircleContainsCoordinate(coordinate, ((MACircle *)overlay).coordinate, ((MACircle *)overlay).radius);
    }
    else if ([overlay isKindOfClass:[MAPolygon class]])
    {
        return MAPolygonContainsPoint(mapPoint, ((MAPolygon *)overlay).points, ((MAPolygon *)overlay).pointCount);
    }
    else if ([overlay isKindOfClass:[MAPolyline class]])
    {
        /*响应距离门限. */
        double distanceThreshold = mapPointDistance * 4;

        return isMAPolylineNearPointAtDistanceThreshold((MAPolyline *)overlay, mapPoint, distanceThreshold);
    }

    return NO;
}

#pragma mark - math

/*!
 计算点P到线段AB的距离
 @param pointP 点P
 @param pointA 线段起点A
 @param pointB 线段终点B
 @return 点P到线段AB的距离
 */
double distanceBetweenPointAndLineFromPointAtoPointB(MAMapPoint pointP, MAMapPoint pointA, MAMapPoint pointB)
{
    MAMapPoint vectorAP = vectorFromPointToPoint(pointA, pointP);//AP
    MAMapPoint vectorPB = vectorFromPointToPoint(pointP, pointB);//PB
    MAMapPoint vectorAB = vectorFromPointToPoint(pointA, pointB);//AB

    double ABxAP = vectorAMutiplyVectorB(vectorAB, vectorAP);

    /* 若点p到线段AB的垂足在延长线上，返回点P到线段端点的距离. */
    if ( ABxAP < 0)
    {
        return sqrt(squareLengthOfVector(vectorAP));
    }

    if (vectorAMutiplyVectorB(vectorPB, vectorAB) < 0)
    {
        return sqrt(squareLengthOfVector(vectorPB));
    }

    /*点P在线段AB上的垂足为C，计算向量PC的长度，即为点P到线段AB的距离. */
    double coefficient  = ABxAP / squareLengthOfVector(vectorAB);
    MAMapPoint vectorAC = MAMapPointMake(vectorAB.x * coefficient, vectorAB.y * coefficient);
    MAMapPoint vectorCP = MAMapPointMake(vectorAP.x - vectorAC.x , vectorAP.y - vectorAC.y);

    return sqrt(squareLengthOfVector(vectorCP));
}

/*!
 计算点到点的向量
 @param fromPoint 向量起点
 @param toPoint   向量终点
 @return 向量
 */
MAMapPoint vectorFromPointToPoint(MAMapPoint fromPoint, MAMapPoint toPoint)
{
    return MAMapPointMake(toPoint.x - fromPoint.x, toPoint.y - fromPoint.y);
}

/*!
 计算向量长度的平方
 @param vector 向量
 @return 长度的平方
 */
double squareLengthOfVector(MAMapPoint vector)
{
    return vector.x * vector.x + vector.y * vector.y;
}

/*!
 计算向量的点积
 @param a 向量A
 @param b 向量B
 @return 向量A 点乘 向量B
 */
double vectorAMutiplyVectorB(MAMapPoint a, MAMapPoint b)
{
    return a.x * b.x + a.y * b.y;
}

@implementation GDUtils

/**
 将coordinatesForString按照token进行拆分，生成CLLocationCoordinate2D数组

 @param string "longitude,latitude<token分隔符>longitude,latitude<token分隔符>"
 @param coordinateCount 数组长度
 @param token 分隔符,示例：";"
 @return CLLocationCoordinate2D
 */
+ (CLLocationCoordinate2D *)coordinatesForString:(NSString *)string coordinateCount:(NSUInteger *)coordinateCount parseToken:(NSString *)token {
    if (string == nil) {
        return NULL;
    }
    if (token == nil) {
        token = @",";
    }
    NSString *str = @"";
    if (![token isEqualToString:@","]) {
        str = [string stringByReplacingOccurrencesOfString:token withString:@","];
    } else {
        str = [NSString stringWithString:string];
    }
    NSArray *components = [str componentsSeparatedByString:@","];
    NSUInteger count = [components count] / 2;
    if (coordinateCount != NULL) {
        *coordinateCount = count;
    }
    CLLocationCoordinate2D *coordinates = (CLLocationCoordinate2D*)malloc(count * sizeof(CLLocationCoordinate2D));

    for (int i = 0; i < count; i++) {
        coordinates[i].longitude = [[components objectAtIndex:2 * i]     doubleValue];
        coordinates[i].latitude  = [[components objectAtIndex:2 * i + 1] doubleValue];
    }

    return coordinates;
}

/*!
 *  @brief  将AMapStep数组生成MAPolyline
 *  在地图上添加折线对象 [self.mapView addOverlay:commonPolyline];
 */
+ (MAPolyline *)spolylineWithRouteSearch:(NSArray<AMapStep *> *)steps {
    //坐标点数组
    NSMutableArray *points = [NSMutableArray array];
    for (int i = 0; i < steps.count; i++) {
        AMapStep *step = steps[i];
        //        NSLog(@"%@", step.instruction);
        //获取坐标变换点的字符串：102.733261,25.079782;102.732758,25.080057
        NSString *polyline = step.polyline;
        //获取前一个经纬度，最后后一个经纬度不需要获取
        NSArray *polylines = [polyline componentsSeparatedByString:@";"];
        [points addObjectsFromArray:polylines];
    }
    //构造折线数据对象
    CLLocationCoordinate2D commonPolylineCoords[points.count];
    for (int i = 0; i < points.count; i++) {
        NSString *fromPointStr = points[i];
        //将经纬度拆分
        NSArray *from = [fromPointStr componentsSeparatedByString:@","];
        //取出纬度字符串
        NSString *lat = from.lastObject;
        //取出经度字符串
        NSString *lon = from.firstObject;
        //添加到CLLocationCoordinate2D中
        commonPolylineCoords[i].latitude = lat.floatValue;
        commonPolylineCoords[i].longitude = lon.floatValue;
    }
    //构造折线对象
    MAPolyline *commonPolyline = [MAMultiPolyline polylineWithCoordinates:commonPolylineCoords count:points.count drawStyleIndexes:@[@10, @60]];
    return commonPolyline;
}

/**
 将坐标集合 @property (nonatomic, copy) NSString *polyline;进行拆分生成MAPolyline

 @param coordinateString "longitude,latitude;longitude,latitude;"
 @return MAPolyline [self.mapView addOverlay:commonPolyline];
 */
+ (MAPolyline *)polylineForCoordinateString:(NSString *)coordinateString {
    if (coordinateString.length == 0) {
        return nil;
    }
    NSUInteger count = 0;
    CLLocationCoordinate2D *coordinates = [self coordinatesForString:coordinateString coordinateCount:&count parseToken:@";"];

    MAPolyline *polyline = [MAPolyline polylineWithCoordinates:coordinates count:count];
    (void)free(coordinates), coordinates = NULL;

    return polyline;
}

/*!
 *  搜索地址格式化
 */
+ (MSearchAddressM *)formattedAddressWithResponse:(AMapReGeocodeSearchResponse *)response {
    if (!response) return nil;
    AMapAddressComponent *address = response.regeocode.addressComponent;
    AMapStreetNumber *street = address.streetNumber;//门牌信息，当POI与AOI都没有时才显示
    //    AMapAOI *aoi = response.regeocode.aois.firstObject;//具体地址，优先显示
    //    AMapPOI *poi = response.regeocode.pois.firstObject;//附近的地区名，有aoi时不显示，次显示
    NSString *showName = [NSString stringWithFormat:@"%@%@", street.street, street.number];
    //    LELog(@"门牌号：%@", showName);
    if (!showName || showName.isEmpty) {
        if (!showName || showName.isEmpty) {
            showName = address.neighborhood;
            if (!showName || showName.isEmpty) {
                showName = address.township;
                if (!showName || showName.isEmpty) {
                    showName = address.district;
                }
            }
        }
    }
    NSString *formattedAddress = [NSString stringWithFormat:@"%@%@%@%@", address.city, address.district, address.township, showName];//response.regeocode.formattedAddress

    MSearchAddressM *model = [MSearchAddressM new];
    //    NSString *showName = response.regeocode.formattedAddress;
    NSRange range = [showName rangeOfString:@"市"];
    if (!range.length) {
        range = [showName rangeOfString:@"省"];
    }
    if (range.length) {
        showName = [showName substringFromIndex:(range.location+range.length)];
    }

    NSString *formatterStr = response.regeocode.formattedAddress;
    //    LELog(@"formattedAddress:%@", response.regeocode.formattedAddress);
    //    NSRange range0 = [formatterStr rangeOfString:@"号"];
    NSRange range1 = [formatterStr rangeOfString:@"街道"];
    NSRange range2 = [formatterStr rangeOfString:@"区"];
    NSRange range3 = [formatterStr rangeOfString:@"县"];
    NSRange range4 = [formatterStr rangeOfString:@"市"];

    NSRange rangeStr = range1;
    NSRange ranges[4] = {range1, range2, range3, range4};
    int i = 0;
    while ((rangeStr.length == 0 || rangeStr.length == NSNotFound) && i<4) {
        rangeStr = ranges[i];
        i++;
    }

    //    if (!range1.length) {
    //        rangeStr = range2;
    //    }
    NSString *start = nil;
    if (rangeStr.length > 0 && rangeStr.length != NSNotFound) {
        //        NSString *end = [formatterStr substringFromIndex:(range1.location+range1.length)];
        //        start = [formatterStr substringToIndex:(rangeStr.location+rangeStr.length)];
        //        formatterStr = [start appendingString:end];
        start = [formatterStr substringFromIndex:(rangeStr.location+rangeStr.length)];
        //        NSRange range = [start rangeOfString:@"号"];
        //        if (!range.length) {
        //            start = [[NSString stringWithFormat:@"%@%@", street.street, street.number] appendingString:start];
        //        }
    }
    //    LELog(@"formatterStr: %@", start);

    model.showAddress = start;
    //    model.showName = showName;
    model.formattedAddress = formattedAddress;
    //    model.coordinate = CLLocationCoordinate2DMake(street.location.latitude, street.location.longitude);
    model.latitude = street.location.latitude;
    model.longitude = street.location.longitude;
    model.cityCode = address.citycode;
    return model;
}

+ (CLLocationDirection)calculateCourseFromMapPoint:(MAMapPoint)p1 to:(MAMapPoint)p2
{
    //20级坐标y轴向下，需要反过来。
    MAMapPoint dp = MAMapPointMake(p2.x - p1.x, p1.y - p2.y);

    if (dp.y == 0)
    {
        return dp.x < 0? 270.f:0.f;
    }

    double dir = atan(dp.x/dp.y) * 180.f / M_PI;

    if (dp.y > 0)
    {
        if (dp.x < 0)
        {
            dir = dir + 360.f;
        }

    }else
    {
        dir = dir + 180.f;
    }

    return dir;
}

+ (CLLocationDirection)calculateCourseFromCoordinate:(CLLocationCoordinate2D)coord1 to:(CLLocationCoordinate2D)coord2
{
    MAMapPoint p1 = MAMapPointForCoordinate(coord1);
    MAMapPoint p2 = MAMapPointForCoordinate(coord2);

    return [self calculateCourseFromMapPoint:p1 to:p2];
}

+ (CLLocationDirection)fixNewDirection:(CLLocationDirection)newDir basedOnOldDirection:(CLLocationDirection)oldDir
{
    //the gap between newDir and oldDir would not exceed 180.f degrees
    CLLocationDirection turn = newDir - oldDir;
    if(turn > 180.f)
    {
        return newDir - 360.f;
    }
    else if (turn < -180.f)
    {
        return newDir + 360.f;
    }
    else
    {
        return newDir;
    }

}

@end
