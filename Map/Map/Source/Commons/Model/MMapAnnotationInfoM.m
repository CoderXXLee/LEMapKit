//
//  MMapAnnotationInfoM.m
//  ebm
//
//  Created by mac on 2017/5/6.
//  Copyright © 2017年 BM. All rights reserved.
//

#import "MMapAnnotationInfoM.h"
#import <MapKit/MapKit.h>
#import <NSString+MCategory.h>

@interface MMapAnnotationInfoM ()

@property(nonatomic, strong) NSMutableArray *locations;
@end

@implementation MMapAnnotationInfoM

- (NSMutableArray *)locations {
    if (!_locations) {
        _locations = [NSMutableArray array];
    }
    return _locations;
}

/**
 获取移动动画的Annotation的CLLocationCoordinate2D数组
 */
- (NSArray *)getCoordinates {
//    NSTimeInterval s = .4;
    int count = 2;

    NSValue *coorValue = [NSValue valueWithMKCoordinate:self.coordinate];
//    CLLocationCoordinate2D *coors = malloc([array count] * sizeof(CLLocationCoordinate2D));
    if (self.locations.count >= count) {
//        CLLocationCoordinate2D *coords[count];
//        CLLocationCoordinate2D *coords = malloc([self.locations count] * sizeof(CLLocationCoordinate2D));
        //计算定位间隔
//        CLLocation *start = self.locations.firstObject;
//        CLLocation *end = self.locations.lastObject;
//        s = end.timestamp.timeIntervalSince1970 - start.timestamp.timeIntervalSince1970;//时间间隔

//        for (int i = 0; i < self.locations.count; i++) {
//            NSValue *coorValue = self.locations[i];
//            CLLocationCoordinate2D coor = [coorValue MKCoordinateValue];
//            coords[i].latitude = coor.latitude;
//            coords[i].longitude = coor.longitude;
//        }

        [self.locations removeObjectAtIndex:0];
        [self.locations addObject:coorValue];
        return self.locations;
    } else {
        [self.locations addObject:coorValue];
    }
    return nil;
}

@end
