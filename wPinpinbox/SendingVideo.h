//
//  SendingVideo.h
//  wPinpinbox
//
//  Created by David on 2017/10/25.
//  Copyright © 2017年 Angus. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SendingVideo;
@protocol SendingVideoDelegate <NSObject>
- (void)sendingVideoSucceeded: (SendingVideo *)sendingVideo;
- (void)sendingVideoFailed: (SendingVideo *)sendingVideo;
@end

@interface SendingVideo : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>
@property (weak) id <SendingVideoDelegate> delegate;
@property (nonatomic) NSURLSessionDataTask *dataTask;

- (void)insertVideoOfDiy: (NSString *)uid
                   token: (NSString *)token
                album_id: (NSString *)album_id
                    file: (NSData *)videoData;
@end
