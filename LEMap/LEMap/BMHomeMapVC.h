//
//  BMHomeMapVC.h
//  ebm
//
//  Created by mac on 2017/4/20.
//  Copyright © 2017年 BM. All rights reserved.
//

#import "BMBaseMapVC.h"

@class RACCommand;

@interface BMHomeMapVC : BMBaseMapVC

/**
 搜索地址返回的model
 */
//@property(nonatomic, strong, readonly) MSearchAddressM *searchAddressM;

/**
 添加/移除站点事件：YES:添加；NO:移除
 */
@property(nonatomic, strong) RACCommand *addStationsCommand;

@end
