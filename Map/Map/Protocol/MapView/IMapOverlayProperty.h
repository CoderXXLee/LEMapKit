//
//  IMapViewOverlayProperty.h
//  Pods
//
//  Created by mac on 2017/7/4.
//
//

#import <Foundation/Foundation.h>
@import UIKit;

///设置overlay绘制的属性
@protocol IMapOverlayProperty <NSObject>

/**
 纹理图片
 */
@property(nonatomic, strong) UIImage *loadStrokeTextureImage;

@end
