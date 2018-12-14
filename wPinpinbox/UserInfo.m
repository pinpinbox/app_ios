//
//  UserInfo.m
//  wPinpinbox
//
//  Created by Antelis on 2018/12/13.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo
//id
+(NSString *)getUserID{
    NSUserDefaults *userPrefs = [[NSUserDefaults alloc] initWithSuiteName:@"group.pinpinbox"];//[NSUserDefaults standardUserDefaults];
    if ([userPrefs objectForKey:@"id"]) {
        return [userPrefs objectForKey:@"id"];
    }
    return @"";
}
//token
+(NSString *)getUserToken{
    NSUserDefaults *userPrefs = [[NSUserDefaults alloc] initWithSuiteName:@"group.pinpinbox"];//[NSUserDefaults standardUserDefaults];
    if ([userPrefs objectForKey:@"token"]) {
        return [userPrefs objectForKey:@"token"];
    }
    
    return @"";
}

@end
