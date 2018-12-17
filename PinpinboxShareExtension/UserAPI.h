//
//  UserAPI.h
//  PinpinboxShareExtension
//
//  Created by Antelis on 2018/12/14.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserAPI : NSObject
#pragma mark - for Share extension
+ (void)userProfileWithCompletionBlock:(void(^)(NSDictionary *result, NSError *error))completionBlock;
+ (void)loadAlbumListWithCompletionBlock:(NSInteger)curCount  completionBlock:(void(^)(NSDictionary *result, NSError *error))completionBlock;
@end

NS_ASSUME_NONNULL_END
