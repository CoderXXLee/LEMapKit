//
//  ISearchAddressM.h
//  ebm
//
//  Created by mac on 2017/4/22.
//  Copyright © 2017年 BM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol ISearchAddressM <NSObject>

/**
 经度
 */
@property(nonatomic, assign) CLLocationDegrees longitude;

/**
 纬度
 */
@property(nonatomic, assign) CLLocationDegrees latitude;

/**
 地址简称
 */
@property (nonatomic, copy) NSString *showAddress;

/**
 地址全称
 */
@property (nonatomic, copy) NSString *formattedAddress;

/**
 城市代码
 */
@property (nonatomic, copy) NSString *cityCode;

@end
