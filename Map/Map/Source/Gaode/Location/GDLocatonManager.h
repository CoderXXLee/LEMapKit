//
//  GDLocatonManager.h
//  Pods
//
//  Created by mac on 2017/6/6.
//
//

#import <Foundation/Foundation.h>
#import "IMapLocation.h"

@interface GDLocatonManager : NSObject<IMapLocation>

/**
 单例模式
 */
+ (instancetype)sharedInstance;

@end
