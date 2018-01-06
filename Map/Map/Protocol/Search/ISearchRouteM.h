//
//  ISearchAddressM.h
//  ebm
//
//  Created by mac on 2017/4/22.
//  Copyright © 2017年 BM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol ISearchRouteM <NSObject>

/**
 经度
 */
- (CLLocationDegrees)getLongitude;

/**
 纬度
 */
- (CLLocationDegrees)getLatitude;

@end
