//
//  GDPointAnnotation.m
//  ebm
//
//  Created by mac on 2017/5/6.
//  Copyright © 2017年 BM. All rights reserved.
//

#import "GDPointAnnotation.h"
#import "MMapAnnotationInfoM.h"

@interface GDPointAnnotation ()

@end

@implementation GDPointAnnotation

/**
 初始化
 */
- (instancetype)initWithInfoModel:(MMapAnnotationInfoM *)infoM {
    if (self = [super init]) {
        _infoM = infoM;
        self.identifier = infoM.identifier;
        self.iconImage = infoM.iconImage;
        self.title = infoM.title;
        self.subtitle = infoM.subtitle;
        self.coordinate = infoM.coordinate;
        self.lockedToScreen = infoM.lockedToScreen;
        self.lockedScreenPoint = infoM.lockedScreenPoint;
    }
    return self;
}

/**
 返回自定义显示view
 */
- (UIView *)getCustomView {
    return _infoM.customView;
}

@end
