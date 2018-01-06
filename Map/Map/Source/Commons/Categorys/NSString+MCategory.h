//
//  NSString+MCategory.h
//  Map
//
//  Created by mac on 2018/1/6.
//

#import <Foundation/Foundation.h>

@interface NSString (MCategory)

/**
 截取字符串前后空格
 */
- (NSString *)trim;

/**
 是否为空
 */
- (BOOL)isEmpty;

@end
