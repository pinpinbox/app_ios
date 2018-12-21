//
//  UserInfo.h
//  wPinpinbox
//
//  Created by appbuilder on 2018/12/18.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserInfo : NSObject
+ (NSString *)getUserId;
+ (NSString *)getUserToken;
+ (void)setUserInfo:(NSString *)uid token:(NSString *)token;
+ (void)resetUserInfo;

@end

NS_ASSUME_NONNULL_END
