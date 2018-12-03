//
//  MapHelper.m
//  wPinpinbox
//
//  Created by Antelis on 2018/11/22.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "MapHelper.h"
#import <sys/utsname.h>

#define  allDeviceIDs @{@"iPod5,1": @"iPod Touch 5",@"iPod7,1": @"iPod Touch 6",@"iPhone3,1":@"iPhone 4",@"iPhone3,2":@"iPhone 4",@"iPhone3,3":@"iPhone 4",@"iPhone4,1":@"iPhone 4s",@"iPhone5,1":@"iPhone 5",@"iPhone5,2":  @"iPhone 5",@"iPhone5,4":  @"iPhone 5c",@"iPhone5,3":  @"iPhone 5c",@"iPhone6,1":  @"iPhone 5s",@"iPhone6,2":  @"iPhone 5s",@"iPhone7,2":@"iPhone 6",@"iPhone7,1":@"iPhone 6 Plus",@"iPhone8,1":@"iPhone 6s",@"iPhone8,2":@"iPhone 6s Plus",@"iPhone9,1":  @"iPhone 7",@"iPhone9,3":  @"iPhone 7",@"iPhone9,4":  @"iPhone 7 Plus",@"iPhone9,2":  @"iPhone 7 Plus",@"iPhone8,4":@"iPhone SE",@"iPhone10,1":@"iPhone 8",@"iPhone10,4":@"iPhone 8",@"iPhone10,2":@"iPhone 8 Plus",@"iPhone10,5":@"iPhone 8 Plus",@"iPhone10,3":@"iPhone X",@"iPhone10,6":@"iPhone X",@"iPhone11,8":@"iPhone XR",@"iPhone11,2":@"iPhone XS",@"iPhone11,4":@"iPhone XS Max",@"iPad2,1":@"iPad 2",@"iPad2,2":@"iPad 2",@"iPad2,3":@"iPad 2",@"iPad2,4":@"iPad 2",@"iPad3,1":@"iPad 3",@"iPad3,2":@"iPad 3",@"iPad3,3":@"iPad 3",@"iPad3,4":@"iPad 4",@"iPad3,5":@"iPad 4",@"iPad3,6":@"iPad 4",@"iPad4,1":@"iPad Air",@"iPad4,2":@"iPad Air",@"iPad4,3":@"iPad Air",@"iPad5,3": @"iPad Air 2",@"iPad5,4": @"iPad Air 2",@"iPad6,11":@"iPad 5",@"iPad6,12":@"iPad 5",@"iPad7,5": @"iPad 6",@"iPad7,6": @"iPad 6",@"iPad2,5":@"iPad Mini",@"iPad2,6":@"iPad Mini",@"iPad2,7":@"iPad Mini",@"iPad4,4":@"iPad Mini 2",@"iPad4,5":@"iPad Mini 2",@"iPad4,6":@"iPad Mini 2",@"iPad4,7":@"iPad Mini 3",@"iPad4,8":@"iPad Mini 3",@"iPad4,9":@"iPad Mini 3",@"iPad5,1":@"iPad Mini 4",@"iPad5,2":@"iPad Mini 4",@"iPad6,3": @"iPad Pro 9.7 Inch",@"iPad6,4": @"iPad Pro 9.7 Inch",@"iPad6,7": @"iPad Pro 12.9 Inch",@"iPad6,8": @"iPad Pro 12.9 Inch",@"iPad7,1": @"iPad Pro 12.9 Inch 2. Generation",@"iPad7,2": @"iPad Pro 12.9 Inch 2. Generation",@"iPad7,3": @"iPad Pro 10.5 Inch",@"iPad7,4": @"iPad Pro 10.5 Inch",@"AppleTV5,3":@"Apple TV",@"AppleTV6,2":@"Apple TV 4K",@"AudioAccessory1,1":@"HomePod"}

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



@implementation UIDevice(Model)
+ (NSString *)deviceModelName {
    NSString *model = nil;  //  detecting device model on simulator
    
#if TARGET_IPHONE_SIMULATOR
    model = [NSProcessInfo processInfo].environment[@"SIMULATOR_MODEL_IDENTIFIER"];  NSLog(@"%@",model);
#else
    //  detecting real device model
    struct utsname sysinfo;
    uname(&sysinfo);
    model = [NSString stringWithCString:sysinfo.machine encoding:NSUTF8StringEncoding];
    
#endif  //////////////////
    if (model != nil)
        return allDeviceIDs[model];
    
    return @"";
}
@end
