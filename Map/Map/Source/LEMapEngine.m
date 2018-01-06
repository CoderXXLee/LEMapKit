//
//  LEMapEngine.m
//  ebm
//
//  Created by mac on 2017/4/19.
//  Copyright © 2017年 BM. All rights reserved.
//

#import "LEMapEngine.h"
#import "GDMapView.h"
#import "GDMapFactory.h"

@interface LEMapEngine ()

@property (nonatomic) NSMutableArray* array;
@property (nonatomic) id<IMapFactory> factory;

@end

@implementation LEMapEngine

static LEMapEngine *instance = nil;

/**
 单例模式
 */
+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

/**
 当我们调用alloc时候回调改方法(保证唯一性)
 */
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    if(instance == nil){
        static dispatch_once_t once;
        dispatch_once(&once, ^{
            instance = [super allocWithZone:zone];
        });
    }
    return instance;
}

/**
 创建工厂
 */
- (id<IMapFactory>)getMapFactory {
    if (!_factory) {
        _factory = [[GDMapFactory alloc] initWithAppKey:[[self class] getGDMapKey]];
    }
    return _factory;
}

/**
 获取key值，用于子类重写
 */
+ (NSString *)getGDMapKey {
    return nil;
}

@end
