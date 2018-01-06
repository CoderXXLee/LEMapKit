//
//  GDSearchManager.h
//  ebm
//
//  Created by mac on 2017/4/22.
//  Copyright © 2017年 BM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMapSearch.h"
#import <AMapSearchKit/AMapSearchKit.h>

/** 搜索结果block */
typedef void(^bGDSearchDone)(NSError *error, id request, id response);

@interface GDSearchManager : NSObject<IMapSearch>

/**
 单例模式
 */
+ (instancetype)sharedInstance;

/*!
 *  根据搜索类型发起搜索
 *
 *  @param request  AMapSearchObject
 *  @param block bGDSearchDone
 */
- (void)searchForRequest:(id)request completionBlock:(bGDSearchDone)block;

@end
