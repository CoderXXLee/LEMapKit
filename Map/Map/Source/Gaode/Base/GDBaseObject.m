//
//  GDBaseObject.m
//  ebm
//
//  Created by mac on 2017/4/20.
//  Copyright © 2017年 BM. All rights reserved.
//

#import "GDBaseObject.h"

@interface GDBaseObject ()

@end

@implementation GDBaseObject

/**
 初始化
 */
- (instancetype)initWihtGDObject:(id)obj {
    if (self = [super init]) {
        _obj = obj;
    }
    return self;
}

@end
