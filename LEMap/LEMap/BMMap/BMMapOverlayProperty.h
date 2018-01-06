//
//  BMMapOverlayProperty.h
//  ebm_driver
//
//  Created by mac on 2017/7/4.
//  Copyright © 2017年 ebm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMapOverlayProperty.h"

@interface BMMapOverlayProperty : NSObject<IMapOverlayProperty>

/**
 纹理图片
 */
@property(nonatomic, strong) UIImage *loadStrokeTextureImage;

@end
