//
//  GDMapNaviVC.h
//  Pods
//
//  Created by mac on 2017/6/19.
//
//

#import <UIKit/UIKit.h>
#import "IMapNavi.h"

@interface GDMapNaviVC : UIViewController <IMapNavi>

/**
 终点坐标
 */
@property(nonatomic, assign) CLLocationCoordinate2D endCoor;

/**
 导航播报回调
 */
@property(nonatomic, copy) bMapNaviPlayNaviSoundString bPlayNaviSound;

@end
