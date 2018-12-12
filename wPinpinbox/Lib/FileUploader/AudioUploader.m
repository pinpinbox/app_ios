//
//  AudioUploader.m
//  wPinpinbox
//
//  Created by Antelis on 2018/12/11.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "AudioUploader.h"
@interface AudioUploader()
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
- (void)startUpload:(AudioUploaderProgressBlock)uploadblock
  uploadResultBlock:(AudioUploaderResultBlock)resultblock {
    
    self.resultBlock = resultblock;
    self.uploadProgress = uploadblock;
}
- (void)cacenlCurrentWork {
    _audioItemURL = nil;
    _albumID = nil;
    _uploadProgress = nil;
    _resultBlock = nil;
}

@end
