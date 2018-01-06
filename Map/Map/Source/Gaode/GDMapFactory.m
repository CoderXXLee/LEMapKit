
//
//  GDMapFactory.m
//  ebm
//
//  Created by mac on 2017/4/19.
//  Copyright © 2017年 BM. All rights reserved.
//

#import "GDMapFactory.h"
#import "GDMapView.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "IMapDelegate.h"
#import "GDSearchManager.h"
#import "GDLocatonManager.h"
//#import "BMMapNaviVC.h"

@implementation GDMapFactory

#pragma mark - LazyLoad
#pragma mark - Super
#pragma mark - Init
#pragma mark - PrivateMethod
#pragma mark - PublicMethod

/**
 初始化工厂方法
 */
- (instancetype)initWithAppKey:(NSString*)appKey {
    if (self = [super init]) {
        [AMapServices sharedServices].apiKey = appKey;
    }
    return self;
}

/**
 创建地图
 */
- (id<IMapView>)createMapViewWithParentView:(UIView *)parentView frame:(CGRect)frame delegate:(id<IMapDelegate>)delegate {
    GDMapView *mapview = [[GDMapView alloc] initWithFrame:frame parentView:parentView];
    [mapview setDelegate:delegate];
    return mapview;
}

/**
 定位
 */
- (id<IMapLocation>)getMapLocation {
    return [GDLocatonManager sharedInstance];
}

/**
 搜索
 */
- (id<IMapSearch>)getMapSearch {
    return [GDSearchManager sharedInstance];
}

/**
 导航
 */
//- (id<IMapNavi>)getMapNavi {
//    return [[BMMapNaviVC alloc] init];
//}

#pragma mark - Events
#pragma mark - LoadFromService
#pragma mark - Delegate
#pragma mark - StateMachine

@end
