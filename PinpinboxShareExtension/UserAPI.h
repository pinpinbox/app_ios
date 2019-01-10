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

@protocol UploadProgressDelegate
- (void)uploadProgress:(NSString *)taskUUID progress:(CGFloat)progress;
@end

@interface UserAPI : NSObject
#pragma mark - for Share extension
+ (void)updateAlbumContentWithAlbumId:(NSString *)albumid CompletionBlock:(void(^)(NSDictionary *result, NSError *error))completionBlock;
+ (void)insertNewAlbumWithSettings:(NSDictionary *)settings CompletionBlock:(void(^)(NSDictionary *result, NSError *error))completionBlock;
+ (void)getAlbumSettingOptionsWithCompletionBlock:(void(^)(NSDictionary *result, NSError *error))completionBlock;
+ (void)userProfileWithCompletionBlock:(void(^)(NSDictionary *result, NSError *error))completionBlock;
+ (void)loadAlbumListWithCompletionBlock:(NSInteger)curCount rank:(NSString *)rank completionBlock:(void(^)(NSDictionary *result, NSError *error))completionBlock;
+ (void)postPreCheck:(NSString *)album_id completionBlock:(void(^)(NSDictionary *result, NSError *error))completionBlock;
+ (void)insertPhotoWithAlbum_id:(NSString *)album_id taskId:(NSString *)taskId imageData:(NSData *)imageData progressDelegate:(id<UploadProgressDelegate>)progressDelegate completionBlock:(void(^)(NSDictionary *result, NSString *taskId,NSError *error))completionBlock;
+ (void)insertVideoWithAlbum_id:(NSString *)album_id taskId:(NSString *)taskId videopath:(NSString *)videopath progressDelegate:(id<UploadProgressDelegate>)progressDelegate completionBlock:(void(^)(NSDictionary *result, NSString *taskId,NSError *error))completionBlock;
+ (void)insertVideoWithAlbum_id:(NSString *)album_id
                         taskId:(NSString *)taskId
                         videoURLPath:(NSString *)videoURLpath
                     progressDelegate:(id<UploadProgressDelegate>)progressDelegate
                      completionBlock:(void(^)(NSDictionary *result, NSString *taskId,NSError *error))completionBlock;

+ (void)loadImageWithURL:(NSURL *)url completionBlock:(void(^)( UIImage * _Nullable image ))completionBlock;
+ (NSString *)signGenerator2:(NSDictionary *)parameters;
@end

NS_ASSUME_NONNULL_END
