//
//  AudioUploader.m
//  wPinpinbox
//
//  Created by Antelis on 2018/12/11.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "AudioUploader.h"
#import "boxAPI.h"

@interface AudioUploader()<NSURLSessionTaskDelegate>
@property (nonatomic) AudioUploaderProgressBlock uploadProgress;
@property (nonatomic) AudioUploaderResultBlock resultBlock;
@property (nonatomic) NSURL *audioItemURL;
@property (nonatomic) NSString *albumID;
@end
@implementation AudioUploader
- (id) initWithAudio:(NSURL *)itemURL albumID:(NSString *)albumID {

    self = [super init];
    if (self) {
        
        self.albumID = albumID;
        self.audioItemURL = itemURL;
        
    }
    return self;
}
- (void)startUpload:(NSMutableDictionary *)params
               path:(NSString *)path
        uploadblock:(AudioUploaderProgressBlock)uploadblock
  uploadResultBlock:(AudioUploaderResultBlock)resultblock {
    
    [boxAPI uploadMusicWithAlbumSettings:params path:path audioUrl:self.audioItemURL sessionDelegate:self completionBlock:^(NSDictionary *result, NSError *error) {
        
        if (resultblock)
            resultblock(result, error);
    }];
    
    self.resultBlock = resultblock;
    self.uploadProgress = uploadblock;
}
- (void)cacenlCurrentWork {
    _audioItemURL = nil;
    _albumID = nil;
    _uploadProgress = nil;
    _resultBlock = nil;
}
- (BOOL)isReady {
    return (_albumID && _audioItemURL);
}
- (NSString *)audioName {
    if (_audioItemURL)
        return [_audioItemURL lastPathComponent];
    return @"";
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    NSLog(@"AudioUploader : %lld/%lld (%f)",totalBytesSent,totalBytesExpectedToSend,(double)totalBytesSent/(double)totalBytesExpectedToSend);
    if (self.uploadProgress) {
        self.uploadProgress((NSUInteger)totalBytesSent, (NSUInteger)totalBytesExpectedToSend, @"");
    }
}
@end
