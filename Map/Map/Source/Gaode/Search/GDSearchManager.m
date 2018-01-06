//
//  GDSearchManager.m
//  ebm
//
//  Created by mac on 2017/4/22.
//  Copyright © 2017年 BM. All rights reserved.
//

#import "GDSearchManager.h"
#import "GDUtils.h"
#import "MSearchAddressM.h"
#import "ISearchRouteM.h"
#import "MapViewImpHeaders.h"
#import <MAMapKit/MAMapKit.h>
#import "MANaviRoute.h"
#import "CommonUtility.h"
#import "GDDistrictPolyline.h"

@interface GDSearchManager ()<AMapSearchDelegate>

@property(nonatomic, strong) AMapSearchAPI *routeSearcher;///搜索

@property(nonatomic, strong) NSMapTable *mapTable;///存储bGDSearchDone响应结果

@end

@implementation GDSearchManager

static GDSearchManager *instance = nil;

#pragma mark - LazyLoad
#pragma mark - Super

/**
 当我们调用alloc时候回调改方法(保证唯一性)
 */
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    if(instance == nil){
        static dispatch_once_t once;
        dispatch_once(&once, ^{
            instance = [super allocWithZone:zone];
            [instance configSearchManager];
        });
    }
    return instance;
}

#pragma mark - Init

/*!
 *  @brief  地图搜索配置
 */
- (void)configSearchManager {
    ///初始化检索对象
    _routeSearcher = [[AMapSearchAPI alloc] init];
    _routeSearcher.delegate = self;
    _mapTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsCopyIn];
}

#pragma mark - PublicMethod

/**
 单例模式
 */
+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[GDSearchManager alloc] init];
        [instance configSearchManager];
    });
    return instance;
}

/*!
 *  根据搜索类型发起搜索
 *
 *  @param request  AMapSearchObject
 *  @param block bGDSearchDone
 */
- (void)searchForRequest:(id)request completionBlock:(bGDSearchDone)block {
    if ([request isKindOfClass:[AMapPOIKeywordsSearchRequest class]]) {
        [_routeSearcher AMapPOIKeywordsSearch:request];
    }
    else if ([request isKindOfClass:[AMapDrivingRouteSearchRequest class]]) {
        [_routeSearcher AMapDrivingRouteSearch:request];
    }
    else if ([request isKindOfClass:[AMapRidingRouteSearchRequest class]]) {
        [_routeSearcher AMapRidingRouteSearch:request];
    }
    else if ([request isKindOfClass:[AMapInputTipsSearchRequest class]]) {
        [_routeSearcher AMapInputTipsSearch:request];
    }
    else if ([request isKindOfClass:[AMapGeocodeSearchRequest class]]) {
        [_routeSearcher AMapGeocodeSearch:request];
    }
    else if ([request isKindOfClass:[AMapReGeocodeSearchRequest class]]) {
        [_routeSearcher AMapReGoecodeSearch:request];
    }
    else if ([request isKindOfClass:[AMapPOIAroundSearchRequest class]]) {
        [_routeSearcher AMapPOIAroundSearch:request];
    }
    ///行政区域搜索
    else if ([request isKindOfClass:[AMapDistrictSearchRequest class]]) {
        [_routeSearcher AMapDistrictSearch:request];
    }
    else {
        NSLog(@"unsupported request");
        return;
    }
    [_mapTable setObject:block forKey:request];
}

#pragma mark - Protocol 协议方法实现

/*!
 *  逆地理编码查询
 */
- (void)reGeocodeWithLocation:(CLLocationCoordinate2D)loc onReGeocodeSearchDone:(void(^)(MSearchAddressM *response))completion {
    ///构造AMapReGeocodeSearchRequest对象，设置参数
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    regeo.location = [AMapGeoPoint locationWithLatitude:loc.latitude longitude:loc.longitude];
    regeo.requireExtension = YES;
    [self searchForRequest:regeo completionBlock:^(NSError *error, id request, id response) {
        if (error) {
            NSLog(@"反地理编码失败");
        }
        else if (completion) {
            MSearchAddressM *address = [GDUtils formattedAddressWithResponse:response];
            address.latitude = loc.latitude;
            address.longitude = loc.longitude;
            completion(address);

        }
        else {
        }
    }];
}

/**
 地理编码查询

 @param address 地址,必填
 @param city 查询城市，可选值：cityname（中文或中文全拼）、citycode、adcode.
 */
- (void)geocodeWithAddress:(NSString *)address city:(NSString *)city onGeocodeSearchDone:(void(^)(NSError *error, MSearchAddressM *searchAddress))completion {
    ///构造AMapReGeocodeSearchRequest对象，设置参数
    AMapGeocodeSearchRequest *regeo = [[AMapGeocodeSearchRequest alloc] init];
    regeo.address = address;
    if (city) {
        regeo.city = city;
    }
    [self searchForRequest:regeo completionBlock:^(NSError *error, id request, AMapGeocodeSearchResponse *response) {
        if (error) {
            NSLog(@"地理编码失败");
            if (completion) {
                completion(error, nil);
            }
        }
        else if (completion) {
            AMapGeocode *gecode = response.geocodes.firstObject;
            if (gecode) {
                MSearchAddressM *address = [MSearchAddressM new];
                address.latitude = gecode.location.latitude;
                address.longitude = gecode.location.longitude;
                address.formattedAddress = gecode.formattedAddress;
                address.showAddress = gecode.formattedAddress;
                address.cityCode = gecode.citycode;
                completion(nil, address);
            } else {
                completion(nil, nil);
            }

        }
    }];
}

/*!
 *  通过关键字搜索
 *  city:查询城市，可选值：cityname（中文或中文全拼）、citycode、adcode.
 */
- (void)searchTipsWithKey:(NSString *)key city:(NSString *)city searchResult:(void(^)(NSError *error, NSArray<MSearchAddressM *> *searchMArr))searchTipsBlock {
    if (key.length == 0) {
        return;
    }

    AMapInputTipsSearchRequest *tips = [[AMapInputTipsSearchRequest alloc] init];
    tips.cityLimit = YES; ///是否限制城市
    tips.city = city;
    tips.keywords = key;

    [self searchForRequest:tips completionBlock:^(NSError *error, id request, id response) {
        NSMutableArray *arr = nil;
        if (!error) {
            arr = [NSMutableArray array];
            AMapInputTipsSearchResponse *aResponse = (AMapInputTipsSearchResponse *)response;
            [aResponse.tips enumerateObjectsUsingBlock:^(AMapTip * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                MSearchAddressM *location = [[MSearchAddressM alloc] init];
                location.showAddress = obj.name;
                //                    location.coordinate = CLLocationCoordinate2DMake(obj.location.latitude, obj.location.longitude);
                location.latitude = obj.location.latitude;
                location.longitude = obj.location.longitude;
                location.formattedAddress = obj.address;
                location.cityCode = obj.adcode;
                [arr addObject:location];
            }];
        }

        if (searchTipsBlock) {
            searchTipsBlock(error, arr);
        }
    }];
}

/*!
 *  @brief  绘制从起点到终点的最佳路线，驾车
 */
- (void)drivingSearchRouteWithPoint:(NSArray<id<ISearchRouteM>> *)points mapView:(id<IMapView>)mapView identifier:(NSString *)identifier onRouteSearchDone:(void(^)(BOOL isSuccess, NSString *identifier, CGFloat distance))completion {
    NSAssert(identifier, @"identifier不能为空");
    ///解析points
    AMapGeoPoint *origin;
    AMapGeoPoint *destination;
    NSArray *wayPoints;
    [self getOriginPoint:&origin destinationPoint:&destination wayPoints:&wayPoints forPoints:points];

    ///构造AMapDrivingRouteSearchRequest对象，设置驾车路径规划请求参数
    AMapDrivingRouteSearchRequest *searchrequest = [[AMapDrivingRouteSearchRequest alloc] init];
    searchrequest.origin = origin;
    searchrequest.destination = destination;
    searchrequest.strategy = 10;///速度优先
    searchrequest.requireExtension = YES;
    if (wayPoints && wayPoints.count > 0) {
        searchrequest.waypoints = wayPoints;
    }

    ///发起路径搜索
    [self searchForRequest:searchrequest completionBlock:^(NSError *error, id request, AMapRouteSearchResponse *response) {
        BOOL isSuc = NO;
        CGFloat distance = 0;
        if (!error) {
            isSuc = YES;
            ///缓存搜索结果
            [_mapTable setObject:@{@"request": searchrequest, @"response": response} forKey:identifier];
            NSArray<AMapPath *> *paths = response.route.paths;
            for (AMapPath *path in paths) {
                distance += path.distance;
            }
        }
        if (completion) {
            completion(isSuc, identifier, distance);
        }
    }];
}

/*!
 *  @brief  绘制从起点到终点的最佳路线，骑行
    只支持起点到终点，不支持多途经点
 */
- (void)searchRouteRideWithPoint:(NSArray<id<ISearchRouteM>> *)points mapView:(id<IMapView>)mapView identifier:(NSString *)identifier onRouteSearchDone:(void(^)(BOOL isSuccess, NSString *identifier, CGFloat distance))completion {
    NSAssert(identifier, @"identifier不能为空");
    ///解析points
    AMapGeoPoint *origin;
    AMapGeoPoint *destination;
    NSArray *wayPoints;
    [self getOriginPoint:&origin destinationPoint:&destination wayPoints:&wayPoints forPoints:points];

    ///构造AMapRidingRouteSearchRequest对象，设置骑行路径规划请求参数
    AMapRidingRouteSearchRequest *searchrequest = [[AMapRidingRouteSearchRequest alloc] init];
    searchrequest.origin = origin;
    searchrequest.destination = destination;
//    searchrequest.type = 2;///速度优先
//    if (wayPoints && wayPoints.count > 0) {
//        request.waypoints = wayPoints;
//    }

    ///发起路径搜索
    [self searchForRequest:searchrequest completionBlock:^(NSError *error, id request, AMapRouteSearchResponse *response) {
        BOOL isSuc = NO;
        CGFloat distance = 0;
        if (!error) {
            isSuc = YES;
            ///缓存搜索结果
            [_mapTable setObject:@{@"request": searchrequest, @"response": response} forKey:identifier];
            NSArray<AMapPath *> *paths = response.route.paths;
            for (AMapPath *path in paths) {
                distance += path.distance;
            }
        }
        if (completion) {
            completion(isSuc, identifier, distance);
        }
    }];
}

/**
 添加规划的线路到地图上，首先要规划线路

 @param mapView 地图，不为空
 @param identifier ID不为空
 @param insets 不知道高德是如何设置的：UIEdgeInsetsMake([UIScreen mainScreen].bounds.size.height*3/4.f, 50, 0, 50)
 */
- (void)addNaviRouteToMapView:(id<IMapView>)mapView identifier:(NSString *)identifier edgePadding:(UIEdgeInsets)insets showOverlays:(BOOL)show {
    NSAssert(identifier, @"identifier不能为空");

    ///@{@"request": searchrequest, @"response": response}
    NSDictionary *search = [_mapTable objectForKey:identifier];
    AMapDrivingRouteSearchRequest *request = search[@"request"];
    AMapRouteSearchResponse *response = search[@"response"];

    if (response) {
        MAMapView *mapview = (MAMapView *)[mapView getView];
        ///根据已经规划的路径，起点，终点，规划类型，是否显示实时路况，生成显示方案
        MANaviRoute *naviRoute = [MANaviRoute naviRouteForPath:response.route.paths[0] withNaviType:MANaviAnnotationTypeDrive showTraffic:YES startPoint:request.origin endPoint:request.destination];
        naviRoute.anntationVisible = NO;///不显示anntation
        ///显示到地图上
        if (show) {
            [naviRoute addToMapView:mapview];
        }

        //            //取出方案列表中的第一套方案数据
        //            AMapPath *path = response.route.paths.firstObject;
        //            //导航路段 AMapStep数组
        //            NSArray *steps = path.steps;
        //            MAPolyline *line = [GDUtils spolylineWithRouteSearch:steps];
        //            [mapview addOverlay:line];

        ///缩放地图使其适应polylines的展示.UIEdgeInsetsMake(300, 20, 300, 20)
        MAMapRect mapRect = [CommonUtility mapRectForOverlays:naviRoute.routePolylines];
        mapRect = [mapview mapRectThatFits:mapRect edgePadding:insets];
        [mapview setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsZero animated:YES];
    }
}

/**
 添加规划的线路到地图上，首先要规划线路

 @param mapView 地图，不为空
 @param identifier ID不为空
 @param insets 不进行调整
 */
- (void)addNaviRouteToMapView:(id<IMapView>)mapView identifier:(NSString *)identifier visibleEdgePadding:(UIEdgeInsets)insets showOverlays:(BOOL)show {
    NSAssert(identifier, @"identifier不能为空");

    ///@{@"request": searchrequest, @"response": response}
    NSDictionary *search = [_mapTable objectForKey:identifier];
    AMapDrivingRouteSearchRequest *request = search[@"request"];
    AMapRouteSearchResponse *response = search[@"response"];

    if (response) {
        MAMapView *mapview = (MAMapView *)[mapView getView];
        ///根据已经规划的路径，起点，终点，规划类型，是否显示实时路况，生成显示方案
        MANaviRoute *naviRoute = [MANaviRoute naviRouteForPath:response.route.paths[0] withNaviType:MANaviAnnotationTypeDrive showTraffic:YES startPoint:request.origin endPoint:request.destination];
        naviRoute.anntationVisible = NO;///不显示anntation
        ///显示到地图上
        if (show) {
            [naviRoute addToMapView:mapview];
        }

        ///缩放地图使其适应polylines的展示.UIEdgeInsetsMake(300, 20, 300, 20)
        MAMapRect mapRect = [CommonUtility mapRectForOverlays:naviRoute.routePolylines];
        //        mapRect = [mapview mapRectThatFits:mapRect edgePadding:insets];
        [mapview setVisibleMapRect:mapRect edgePadding:insets animated:YES];
    }
}

/**
 根据identifier移除线路规划缓存
 */
- (void)removeSearchRouteCache:(NSString *)identifier {
    NSAssert(identifier, @"identifier不能为空");
    [_mapTable removeObjectForKey:identifier];
}

/**
 搜索行政区域
 */
- (void)searchDistrictWithName:(NSString *)name mapView:(id<IMapView>)mapView onDistrictSearchDone:(void(^)(BOOL isSuccess, NSArray *polylineArr))completion {
    AMapDistrictSearchRequest *dist = [[AMapDistrictSearchRequest alloc] init];
    dist.keywords = name;
    dist.requireExtension = YES;

    [self searchForRequest:dist completionBlock:^(NSError *error, id request, AMapDistrictSearchResponse *response) {
        NSArray *polylineArr = [self handleDistrictResponse:response];
        ///添加到地图
        MAMapView *maMapView = (MAMapView *)[mapView getView];
        [maMapView addOverlays:polylineArr];
    }];
}

#pragma mark - PrivateMethod

- (void)performBlockWithRequest:(id)request withResponse:(id)response {
    bGDSearchDone block = [_mapTable objectForKey:request];
    if (block) {
        block(nil, request, response);
    }
    [_mapTable removeObjectForKey:request];
}

/**
 解析NSArray<ISearchRouteM> *arr获取起点与目的地

 @param origin 解析结果：出发地
 @param destination 解析结果：目的地
 @param points 解析的目标
 */
- (void)getOriginPoint:(AMapGeoPoint **)origin destinationPoint:(AMapGeoPoint **)destination wayPoints:(NSArray<AMapGeoPoint *> **)wayPoints forPoints:(NSArray<id<ISearchRouteM>> *)points {
    NSMutableArray *waypoints = [NSMutableArray array];
    if (points && points.count > 0) {
        for (int i = 1; i < points.count-1; i++) {
            id<ISearchRouteM> model = points[i];
            AMapGeoPoint *point = [AMapGeoPoint locationWithLatitude:[model getLatitude] longitude:[model getLongitude]];
            [waypoints addObject:point];
        }
    }
    *wayPoints = waypoints;
    ///订单信息
    id<ISearchRouteM> start = points.firstObject;
    id<ISearchRouteM> end = points.lastObject;

    *origin = [AMapGeoPoint locationWithLatitude:[start getLatitude] longitude:[start getLongitude]];
    *destination = [AMapGeoPoint locationWithLatitude:[end getLatitude] longitude:[end getLongitude]];
}

/**
 搜索结果行政区域数据处理
 */
- (NSArray *)handleDistrictResponse:(AMapDistrictSearchResponse *)response {
    if (response == nil) {
        return nil;
    }

    NSMutableArray *polylineArr = [NSMutableArray array];
    for (AMapDistrict *dist in response.districts) {
        MAPointAnnotation *poiAnnotation = [[MAPointAnnotation alloc] init];

        poiAnnotation.coordinate = CLLocationCoordinate2DMake(dist.center.latitude, dist.center.longitude);
        poiAnnotation.title      = dist.name;
        poiAnnotation.subtitle   = dist.adcode;

//        [self.mapView addAnnotation:poiAnnotation];

        if (dist.polylines.count > 0) {
            MAMapRect bounds = MAMapRectZero;

            for (NSString *polylineStr in dist.polylines) {
                GDDistrictPolyline *polyline = [GDDistrictPolyline polylineForCoordinateString:polylineStr];
//                [self.mapView addOverlay:polyline];
                bounds = MAMapRectUnion(bounds, polyline.boundingMapRect);
                [polylineArr addObject:polyline];
            }

#if 0 //如果要显示带填充色的polygon，打开此开关
            for (NSString *polylineStr in dist.polylines) {
                NSUInteger tempCount = 0;
                CLLocationCoordinate2D *coordinates = [CommonUtility coordinatesForString:polylineStr coordinateCount:&tempCount parseToken:@";"];

                MAPolygon *polygon = [MAPolygon polygonWithCoordinates:coordinates count:tempCount];
                free(coordinates);
//                [self.mapView addOverlay:polygon];
            }
#endif

//            [self.mapView setVisibleMapRect:bounds animated:YES];
        }

        ///sub
//        for (AMapDistrict *subdist in dist.districts) {
//            MAPointAnnotation *subAnnotation = [[MAPointAnnotation alloc] init];
//
//            subAnnotation.coordinate = CLLocationCoordinate2DMake(subdist.center.latitude, subdist.center.longitude);
//            subAnnotation.title      = subdist.name;
//            subAnnotation.subtitle   = subdist.adcode;
//
////            [self.mapView addAnnotation:subAnnotation];
//        }
    }
    return polylineArr;
}

#pragma mark - Events
#pragma mark - LoadFromService
#pragma mark - AMapSearchDelegate

/**
 *  当请求发生错误时，会调用代理的此方法.
 *
 *  @param request 发生错误的请求.
 *  @param error   返回的错误.
 */
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {
    bGDSearchDone block = [_mapTable objectForKey:request];
    if (block) {
        block(error, request, nil);
    }
    [_mapTable removeObjectForKey:request];
}

/**
 *  POI查询回调函数
 *
 *  @param request  发起的请求，具体字段参考 AMapPOISearchBaseRequest 及其子类。
 *  @param response 响应结果，具体字段参考 AMapPOISearchResponse 。
 */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response {
    [self performBlockWithRequest:request withResponse:response];
}

/*!
 *  实现路径搜索的回调函数
 */
- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response {
    [self performBlockWithRequest:request withResponse:response];
}

/**
 *  输入提示查询回调函数
 *
 *  @param request  发起的请求，具体字段参考 AMapInputTipsSearchRequest 。
 *  @param response 响应结果，具体字段参考 AMapInputTipsSearchResponse 。
 */
- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response {
    [self performBlockWithRequest:request withResponse:response];
}

/**
 *  地理编码查询回调函数
 *
 *  @param request  发起的请求，具体字段参考 AMapGeocodeSearchRequest 。
 *  @param response 响应结果，具体字段参考 AMapGeocodeSearchResponse 。
 */
- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response {
    [self performBlockWithRequest:request withResponse:response];
}

/*!
 *  实现逆地理编码的回调函数
 */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response {
    [self performBlockWithRequest:request withResponse:response];
}

/**
 * @brief 行政区域查询回调函数
 * @param request  发起的请求，具体字段参考 AMapDistrictSearchRequest 。
 * @param response 响应结果，具体字段参考 AMapDistrictSearchResponse 。
 */
- (void)onDistrictSearchDone:(AMapDistrictSearchRequest *)request response:(AMapDistrictSearchResponse *)response {
    [self performBlockWithRequest:request withResponse:response];
}

@end
