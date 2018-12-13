//
//  AudioUploader.h
//  wPinpinbox
//
//  Created by Antelis on 2018/12/11.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^AudioUploaderProgressBlock)(NSUInteger currentUploaded, NSUInteger totalSize, NSString *desc);
typedef void(^AudioUploaderResultBlock)(NSError * _Nullable error);



@interface AudioUploader : NSObject
- (id) initWithAudio:(NSURL *)itemURL albumID:(NSString *)albumID;
- (void)startUpload:(NSMutableDictionary *)params
        uploadblock:(AudioUploaderProgressBlock)uploadblock
  uploadResultBlock:(AudioUploaderResultBlock)resultblock;
- (void)cacenlCurrentWork;
- (BOOL)isReady;
@property (nonatomic, readonly) NSString *audioName;
@end

NS_ASSUME_NONNULL_END
