//
//  IUserLocation.h
//  ebm
//
//  Created by mac on 2017/4/20.
//  Copyright © 2017年 BM. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CLLocation;
@class CLHeading;

@protocol IUserLocation <NSObject>

///位置更新状态，如果正在更新位置信息，则该值为YES
@property (readonly, nonatomic, getter = isUpdating) BOOL updating;

///位置信息，如果MAMapView的showsUserLocation为NO，或者尚未定位成功，则该值为nil
@property (readonly, nonatomic, strong) CLLocation *location;

///heading信息
@property (readonly, nonatomic, strong) CLHeading *heading;

///定位标注点要显示的标题信息
@property (nonatomic, copy) NSString *title;

///定位标注点要显示的子标题信息
@property (nonatomic, copy) NSString *subtitle;

/**
 返回指定的定位数据
 */
- (id)getObject;

@end
