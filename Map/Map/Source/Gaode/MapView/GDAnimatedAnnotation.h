//
//  GDAnimatedAnnotation.h
//  ebm
//
//  Created by mac on 2017/5/10.
//  Copyright © 2017年 BM. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>
@protocol IAnnotationInfo;
@class MMapAnnotationInfoM;

@interface GDAnimatedAnnotation : MAAnimatedAnnotation

/**
 id
 */
@property (nonatomic, copy) NSString *identifier;

/**
 Annotation图标
 */
@property(nonatomic, strong) UIImage *iconImage;

/**
 绑定的模型
 */
@property(nonatomic, strong) id<IAnnotationInfo> infoM;

/**
 初始化
 */
- (instancetype)initWithInfoModel:(MMapAnnotationInfoM *)infoM;

/**
 返回自定义显示view
 */
- (UIView *)getCustomView;

@end
