//
//  UserInfo.m
//  wPinpinbox
//
//  Created by appbuilder on 2018/12/18.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "UserInfo.h"
#import "GlobalVars.h"

@implementation UserInfo
+(NSUserDefaults *)userPrefs{
    
    static NSUserDefaults *userPrefs = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userPrefs = [[NSUserDefaults alloc] initWithSuiteName:AppGroup];
    });
    return userPrefs;
}

//id
+(NSString *)getUserId{
    NSUserDefaults *u = [UserInfo userPrefs];
    if ([u objectForKey:@"id"]) {
        return [u objectForKey:@"id"];
    }
    return @"";
}
//token
+(NSString *)getUserToken{
    NSUserDefaults *u = [UserInfo userPrefs];
    if ([u objectForKey:@"token"]) {
        return [u objectForKey:@"token"];
    }
    
    return @"";
}
+(void)setUserInfo:(NSString *)uid token:(NSString *)token {
    NSUserDefaults *u = [UserInfo userPrefs];
    [u setObject:uid forKey:@"id"];
    [u setObject:token forKey:@"token"];
    
    [u synchronize];
}

+ (void)resetUserInfo {
    NSUserDefaults *u = [UserInfo userPrefs];
    [u removeObjectForKey:@"id"];
    [u removeObjectForKey:@"token"];
    
    [u synchronize];
}
@end
