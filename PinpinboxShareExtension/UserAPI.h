//
//  UserAPI.h
//  PinpinboxShareExtension
//
//  Created by Antelis on 2018/12/14.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserAPI : NSObject
#pragma mark - for Share extension
+ (void)userProfileWithCompletionBlock:(void(^)(NSDictionary *result, NSError *error))completionBlock;
+ (void)loadAlbumListWithCompletionBlock:(NSInteger)curCount  completionBlock:(void(^)(NSDictionary *result, NSError *error))completionBlock;
+ (void)refreshTokenWithCompletionBlock:(void(^)(NSDictionary *result, NSError *error))completionBlock;
+ (void)postPreCheck:(NSString *)album_id completionBlock:(void(^)(NSDictionary *result, NSError *error))completionBlock;
+ (NSString *)insertPhotoWithAlbum_id:(NSString *)album_id imageData:(NSData *)imageData completionBlock:(void(^)(NSDictionary *result, NSString *taskId,NSError *error))completionBlock;
+ (NSString *)insertVideoWithAlbum_id:(NSString *)album_id videopath:(NSString *)videopath completionBlock:(void(^)(NSDictionary *result, NSString *taskId,NSError *error))completionBlock;
+ (void)loadImageWithURL:(NSURL *)url completionBlock:(void(^)( UIImage * _Nullable image ))completionBlock;
@end

NS_ASSUME_NONNULL_END
