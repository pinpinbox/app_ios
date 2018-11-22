//
//  MapHelper.h
//  wPinpinbox
//
//  Created by Antelis on 2018/11/22.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;
NS_ASSUME_NONNULL_BEGIN

@interface MapHelper : NSObject
+ (NSString *)getLocationQuery:(NSString *)place encoding:(BOOL)encoding;
+ (CLLocationCoordinate2D)retrieveLocationCoordinate:(NSDictionary *)data;
+ (NSString *)retrieveLocationName:(NSDictionary *)data;

+ (void)searchLocation:(NSString *)location CompletionBlock:(void(^)(MKMapItem * _Nullable item, NSError * _Nullable error))block;
@end

NS_ASSUME_NONNULL_END
