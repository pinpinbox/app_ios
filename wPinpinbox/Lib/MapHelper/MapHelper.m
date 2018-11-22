//
//  MapHelper.m
//  wPinpinbox
//
//  Created by Antelis on 2018/11/22.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "MapHelper.h"
#define mapboxkey @"sk.eyJ1IjoiYW50aHkwMTExIiwiYSI6ImNqb3Fzank4NzA3cDgzcGxoNGt0Z3JiMWYifQ.lpjmNxrbXh5L6WZ4bETD9Q"
@implementation MapHelper
+ (NSString *)getLocationQuery:(NSString *)place encoding:(BOOL)encoding {
    
    NSString *ss = @"https://api.mapbox.com/geocoding/v5/mapbox.places/%@.json?limit=3&access_token=%@";
    NSString *target = [NSString stringWithFormat:ss,place, mapboxkey];
    if (encoding)
        return [target stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    return target;
    
}
+ (CLLocationCoordinate2D)retrieveLocationCoordinate:(NSDictionary *)data {
    
    NSArray *features = data[@"features"];
    if (features && features.count) {
        NSDictionary *loc = [features firstObject];
        NSDictionary *gl =loc[@"geometry"];
        NSArray *cord = gl[@"coordinates"];
        if (cord && cord.count == 2) {
            CLLocationDegrees lo = [cord[0] doubleValue];
            CLLocationDegrees la = [cord[1] doubleValue];
            return CLLocationCoordinate2DMake(la, lo);
        }
    }
    return CLLocationCoordinate2DMake(0, 0);
}
+ (NSString *)retrieveLocationName:(NSDictionary *)data {
    
    NSArray *features = data[@"features"];
    if (features && features.count) {
        NSDictionary *loc = [features firstObject];
        if (loc[@"text"])
            return loc[@"text"];
    }

    
    return @"";
}
+ (void)searchLocation:(NSString *)location CompletionBlock:(void(^)(MKMapItem * _Nullable item, NSError * _Nullable error))block {
    if (location && location.length > 0 && block) {
        MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
        request.naturalLanguageQuery = location;
        MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
        
        [search startWithCompletionHandler:^(MKLocalSearchResponse * _Nullable response, NSError * _Nullable error) {
            if (!error && response) {
                
                NSArray *res = response.mapItems;
                MKMapItem *first = [res firstObject];
                block(first, nil);
            } else {
                NSLog(@"MKLocalSearch Error %@",error);
                block(nil, error);
            }
            
        }];
    } else if (block) {
        block(nil, [NSError errorWithDomain:@"" code:3333 userInfo:@{NSLocalizedDescriptionKey:@"Location can not be empty"}]);
    }
    
}
@end
