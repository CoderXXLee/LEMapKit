//
//  GDBaseObject.h
//  ebm
//
//  Created by mac on 2017/4/20.
//  Copyright © 2017年 BM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GDBaseObject : NSObject

@property(nonatomic, strong, readonly) id obj;

/**
 初始化
 */
- (instancetype)initWihtGDObject:(id)obj;

@end
