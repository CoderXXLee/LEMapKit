//
//  IAnnotationView.h
//  ebm
//
//  Created by mac on 2017/4/20.
//  Copyright © 2017年 BM. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol IAnnotation;
@class UIView;

@protocol IAnnotationView <NSObject>

/**
 标识符
 */
@property(nonatomic, copy) NSString *indetifier;

/**
 返回自定义显示view
 */
- (UIView *)getCustomView;

/**
 * @brief 初始化并返回一个annotation view
 * @param annotation      关联的annotation对象
 * @param reuseIdentifier 如果要重用view,传入一个字符串,否则设为nil,建议重用view
 * @return 初始化成功则返回annotation view,否则返回nil
 */
//- (id)initWithAnnotation:(id<IAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier;

@end
