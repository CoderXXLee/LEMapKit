//
//  GDDistrictPolyline.m
//  Pods
//
//  Created by mac on 2017/8/1.
//
//

#import "GDDistrictPolyline.h"
#import "CommonUtility.h"

@implementation GDDistrictPolyline

/**
 将坐标集合 @property (nonatomic, copy) NSString *polyline;进行拆分生成MAPolyline

 @param coordinateString "longitude,latitude;longitude,latitude;"
 @return MAPolyline [self.mapView addOverlay:commonPolyline];
 */
+ (GDDistrictPolyline *)polylineForCoordinateString:(NSString *)coordinateString {
    if (coordinateString.length == 0) {
        return nil;
    }
    NSUInteger count = 0;
    CLLocationCoordinate2D *coordinates = [CommonUtility coordinatesForString:coordinateString coordinateCount:&count parseToken:@";"];

    GDDistrictPolyline *polyline = [GDDistrictPolyline polylineWithCoordinates:coordinates count:count];
    (void)(free(coordinates)), coordinates = NULL;

    return polyline;
}

@end
