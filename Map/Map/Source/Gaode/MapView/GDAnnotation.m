//
//  GDAnnotation.m
//  ebm
//
//  Created by mac on 2017/4/20.
//  Copyright © 2017年 BM. All rights reserved.
//

#import "GDAnnotation.h"
#import <MAMapKit/MAMapKit.h>

@implementation GDAnnotation

#pragma mark - LazyLoad
#pragma mark - Super
#pragma mark - Init
#pragma mark - PrivateMethod
#pragma mark - PublicMethod

- (id<MAAnnotation>)getObject {
    return self.obj;
}

/**
 获取Annotation的类型
 @return 类型
 */
- (AnnotationTypeENUM)getAnnotationType {
    id<MAAnnotation> anno = [self getObject];
    if ([anno isKindOfClass:[MAUserLocation class]]) {
        return AnnotationTypeENUMUserLocation;
    }
    return AnnotationTypeENUMDefault;
}

#pragma mark - Events
#pragma mark - LoadFromService
#pragma mark - Delegate
#pragma mark - StateMachine

@end
