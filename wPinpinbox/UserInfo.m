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
+ (NSUserDefaults  *)userPrefs {
    static NSUserDefaults *userPrefs = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userPrefs = [[NSUserDefaults alloc] initWithSuiteName:AppGroupID];
    });
    
    return userPrefs;
}

+ (NSString *)getUserId {
    NSUserDefaults *u = [UserInfo userPrefs];
    return [u objectForKey:@"id"] ? [u objectForKey:@"id"] : @"";
}
+ (NSString *)getUserToken {
    NSUserDefaults *u = [UserInfo userPrefs];
    return [u objectForKey:@"token"] ? [u objectForKey:@"token"] : @"";
}
+ (void)setUserInfo:(NSString *)uid token:(NSString *)token {
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
