//
//  IMapFactory.h
//  ebm
//
//  Created by mac on 2017/4/19.
//  Copyright © 2017年 BM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "IMapView.h"
#import "IMapLocation.h"
#import "IMapSearch.h"
#import "IMapDelegate.h"

@protocol IMapFactory <NSObject>

/**
 初始化工厂方法
 */
- (instancetype)initWithAppKey:(NSString*)appKey;

/**
 创建地图试图
 */
- (id<IMapView>)createMapViewWithParentView:(UIView *)parentView frame:(CGRect)frame delegate:(id<IMapDelegate>)delegate;

/**
 定位
 */
- (id<IMapLocation>)getMapLocation;

/**
 搜索
 */
- (id<IMapSearch>)getMapSearch;

/**
 导航
 */
//- (id<IMapNavi>)getMapNavi;

//导航
@end
