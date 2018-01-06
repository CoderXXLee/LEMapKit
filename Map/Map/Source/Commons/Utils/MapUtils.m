//
//  MapUtils.m
//  ebm
//
//  Created by mac on 2017/5/10.
//  Copyright © 2017年 BM. All rights reserved.
//

#import "MapUtils.h"

#define toDeg(X) (X*180.0/M_PI)

@implementation MapUtils

/**
 计算角度
 */
+ (CLLocationDirection)calculateCourseFromCoordinate:(CLLocationCoordinate2D)coord1 to:(CLLocationCoordinate2D)coord2 {
    //20级坐标y轴向下，需要反过来。
    CLLocationCoordinate2D dp = CLLocationCoordinate2DMake(coord2.latitude - coord1.latitude, coord1.longitude - coord2.longitude);

    if (dp.longitude == 0) {
        return dp.latitude < 0? 270.f:0.f;
    }

    double dir = atan(dp.latitude/dp.longitude) * 180.f / M_PI;

    if (dp.longitude > 0) {
        if (dp.latitude < 0) {
            dir = dir + 360.f;
        }

    } else {
        dir = dir + 180.f;
    }

    return dir;
}

///**
// 计算角度
// */
//+ (CLLocationDirection)calculateDirectionFromCoordinate:(CLLocationCoordinate2D)coord1 to:(CLLocationCoordinate2D)coord2 {
//    double cos_c = (cos(90 - coord2.latitude)*cos(90 - coord1.latitude)) + (sin(90 - coord2.latitude)*sin(90 - coord1.latitude)*cos(coord2.longitude-coord1.longitude));
//
//    double sin_c = sqrt(1 - pow(cos_c, 2));
//
//    double z = asin((sin(90 - coord2.latitude)*sin(coord2.longitude - coord1.longitude))/sin_c);
//    z = toDeg(z);
//    if (!isnan(z)) return z;
//    return 0;
//}

/**
 计算角度
 */
+ (CLLocationDirection)calculateDirectionFromCoordinate:(CLLocationCoordinate2D)coord1 to:(CLLocationCoordinate2D)coord2 {
//    CLLocationCoordinate2D dp = CLLocationCoordinate2DMake(coord2.latitude - coord1.latitude, coord1.longitude - coord2.longitude);
//
//    if (dp.longitude == 0) {
//        return dp.latitude < 0? 270.f:0.f;
//    }
//
//    double dir = atan(dp.latitude/dp.longitude) * 180.f / M_PI;
//
//    if (dp.longitude > 0) {
//        if (dp.latitude < 0) {
//            dir = dir + 360.f;
//        }
//
//    } else {
//        dir = dir + 180.f;
//    }

    double dpa = atan2(fabs(coord1.longitude - coord2.longitude), fabs(coord1.latitude - coord2.latitude));
    if (coord2.longitude >= coord1.longitude) {
        if (coord2.latitude > coord1.latitude) {

        } else {
            dpa = M_PI - dpa;
        }
    } else {
        if (coord2.latitude >= coord1.latitude) {
            dpa = 2*M_PI - dpa;
        } else {
            dpa = M_PI + dpa;
        }
    }
    dpa = dpa * 180.f / M_PI;
    
    return dpa;
}

//public static double GetAngle(string x1, string y1, string x2, string y2)
//{
//    double X1 = 0, Y1 = 0, X2 = 0, Y2 = 0;
//    X1 = Convert.ToDouble(x1);
//    Y1 = Convert.ToDouble(y1);
//    X2 = Convert.ToDouble(x2);
//    Y2 = Convert.ToDouble(y2);
//
//    double dRotateAngle = Math.Atan2(Math.Abs(X1 - X2), Math.Abs(Y1 - Y2));
//    if (X2 >= X1)
//    {
//
//        if (Y2 >= Y1)
//        {
//        }
//        else
//        {
//            dRotateAngle = Math.PI - dRotateAngle;
//        }
//    }
//    else
//    {
//
//        if (Y2 >= Y1)
//        {
//            dRotateAngle = 2 * Math.PI - dRotateAngle;
//        }
//        else
//        {
//            dRotateAngle = Math.PI + dRotateAngle;
//        }
//    }
//    dRotateAngle = dRotateAngle * 180 / Math.PI;
//    return dRotateAngle;
//}

@end
