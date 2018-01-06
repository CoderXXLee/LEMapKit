//
//  LEMapEngine.h
//  ebm
//
//  Created by mac on 2017/4/19.
//  Copyright © 2017年 BM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMapFactory.h"

@interface LEMapEngine : NSObject

/**
 单例模式
 */
+ (instancetype)sharedInstance;

/**
 创建工厂
 */
- (id<IMapFactory>)getMapFactory;

/**
 获取key值，用于子类重写
 */
+ (NSString *)getGDMapKey;

@end
