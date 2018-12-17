//
//  UserInfo.h
//  wPinpinbox
//
//  Created by Antelis on 2018/12/13.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserInfo : NSObject
//userInfo
+ (NSString *)getUserID;
+ (NSString *)getUserToken;
+ (void)setUserInfo:(NSString *)uid token:(NSString *)token;
+ (void)resetUserInfo;

@end

NS_ASSUME_NONNULL_END
