//
//  GDDistrictPolyline.h
//  Pods
//
//  Created by mac on 2017/8/1.
//
//

#import <MAMapKit/MAMapKit.h>

@interface GDDistrictPolyline : MAPolyline

/**
 将坐标集合 @property (nonatomic, copy) NSString *polyline;进行拆分生成MAPolyline

 @param coordinateString "longitude,latitude;longitude,latitude;"
 @return MAPolyline [self.mapView addOverlay:commonPolyline];
 */
+ (GDDistrictPolyline *)polylineForCoordinateString:(NSString *)coordinateString;

@end
