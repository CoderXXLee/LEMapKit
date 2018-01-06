//
//  IMapNavi.h
//  Pods
//
//  Created by mac on 2017/6/19.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void(^bMapNaviPlayNaviSoundString)(NSString *soundString, BOOL *isSpeaking);

@protocol IMapNavi <NSObject>

/**
 终点坐标
 */
@property(nonatomic, assign) CLLocationCoordinate2D endCoor;

/**
 导航播报回调
 */
@property(nonatomic, copy) bMapNaviPlayNaviSoundString bPlayNaviSound;

/**
 获取控制器
 */
- (UIViewController *)getViewController;

@end
