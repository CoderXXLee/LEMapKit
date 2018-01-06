//
//  BMUserAnnotationV.h
//  ebm
//
//  Created by mac on 2017/4/20.
//  Copyright © 2017年 BM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAnnotationView.h"

@interface BMUserAnnotationV : UIView<IAnnotationView>

/**
 标识符
 */
@property(nonatomic, copy) NSString *indetifier;

/**
 用户头像
 */
@property(nonatomic, weak, readonly) UIImageView *avatar;

/**
 头像外部的边框
 */
@property(nonatomic, weak, readonly) UIImageView *userBorder;

@end
