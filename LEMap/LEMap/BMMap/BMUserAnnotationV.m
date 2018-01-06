//
//  BMUserAnnotationV.m
//  ebm
//
//  Created by mac on 2017/4/20.
//  Copyright © 2017年 BM. All rights reserved.
//

#import "BMUserAnnotationV.h"
#import "UIView+AutoLayout.h"

@implementation BMUserAnnotationV

#pragma mark - LazyLoad
#pragma mark - Super

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self buildUI];
    }
    return self;
}

#pragma mark - Init

- (void)buildUI {
    ///用户显示箭头框
    UIImageView *user = [[UIImageView alloc] init];
    //        user.center = CGPointMake(self.frame.size.width/2.f, self.frame.size.height/2.f);
    user.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:user];
    [user bringSubviewToFront:self];
    user.image = [UIImage imageNamed:@"map_point_location_regular_bg"];
    _userBorder = user;

    ///用户头像
    UIImageView *header = [[UIImageView alloc] init];
    //        user.center = CGPointMake(self.frame.size.width/2.f, self.frame.size.height/2.f);
    header.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:header];
    [header bringSubviewToFront:self];
    _avatar = header;

    [user autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [user autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [user autoSetDimensionsToSize:CGSizeMake(25, 25)];

    [header autoPinEdges:UIEdgeInsetsMake(3, 3, -3, -3) ofView:user];
    header.layer.cornerRadius = 19/2.f;
    header.layer.masksToBounds = YES;

    ///根据登录状态显示头像
    header.image = [UIImage imageNamed:@"map_point_location_regular_pic"];
}

#pragma mark - PrivateMethod
#pragma mark - PublicMethod

- (UIView *)getCustomView {
    return self;
}

#pragma mark - Events
#pragma mark - LoadFromService
#pragma mark - Delegate
#pragma mark - StateMachine

@end
