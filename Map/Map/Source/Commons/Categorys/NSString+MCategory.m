//
//  NSString+MCategory.m
//  Map
//
//  Created by mac on 2018/1/6.
//

#import "NSString+MCategory.h"

@implementation NSString (MCategory)

/**
 截取字符串前后空格
 */
- (NSString *)trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

/**
 是否为空
 */
- (BOOL)isEmpty {
    if (self != nil && ![@"" isEqualToString:self.trim]) {
        return NO;
    }
    return YES;
}

@end
