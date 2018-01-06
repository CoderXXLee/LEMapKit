//
//  BMMapEngine.m
//  ebm
//
//  Created by mac on 2017/6/7.
//  Copyright © 2017年 BM. All rights reserved.
//

#import "BMMapEngine.h"

static NSString *const GD_APP_KEY = @"高德开放平台申请的KEY";

@implementation BMMapEngine

/**
 获取高德key值，用于子类重写
 */
+ (NSString *)getGDMapKey {
    NSAssert(nil, @"请自行前往高德开放平台申请KEY");
    return GD_APP_KEY;
}

@end
