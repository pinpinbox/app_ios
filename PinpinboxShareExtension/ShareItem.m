//
//  ShareItem.m
//  PinpinboxShareExtension
//
//  Created by Antelis on 2018/12/17.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "ShareItem.h"
#import "NSURL+Param.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

@implementation ShareItem
- (id)initWithItemProvider:(NSItemProvider *)item type:(NSString *)type {
    self = [super init];
    if (self) {
        self.hasVideo = NO;
        self.thumbIsDark = NO;
        self.vidDuration = 0;
        self.objType = type;
        self.shareItem = item;
    }
    return self;
}
- (void)postLoadShareItem {
    __block typeof(self) wself = self;
    [self.shareItem loadItemForTypeIdentifier:self.objType options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
        if (!error) {
            if ([wself.objType isEqualToString:(__bridge  NSString *)kUTTypeText]) {
                NSString *text = (NSString *)item;
                @try {
                    NSURL *url = [NSURL URLWithString:text];
                    [wself setUrl:url];
                    
                } @catch (NSException *exception) {
                    NSLog(@"Failed to retrieve URL %@",[exception description]);
                }
            } else {
                NSURL *url = (NSURL *)item;
                if (url && [url isKindOfClass:[NSURL class]])
                    [wself setUrl:url];
            }
                
            
            [wself tryLoadThumbnail];
        } else {
            
        }
        
    }];
}
- (void)tryLoadThumbnail {
    
    __block typeof(self) wself = self;
    if ([_objType isEqualToString:(__bridge NSString *)kUTTypeURL] ||
        [_objType isEqualToString:(__bridge NSString *)kUTTypeText]) {
        NSString *videoID = nil;
        NSString *path = [_url absoluteString];
        if ([path containsString:@"youtu"]) {
            
            if ([_url.host containsString:@"youtube.com"]) {
                videoID = [_url queryParam:@"v"];
            } else if ([_url.host containsString:@"youtu.be"]) {
                videoID = [_url lastPathComponent];
            }
            NSString *th = [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/1.jpg",videoID];
            self.thumbURL = [NSURL URLWithString:th];
            self.hasVideo = YES;
        } else if ([_url.absoluteString containsString:@"vimeo.com"]) {
            NSString *videoPath = _url.lastPathComponent;
            NSString *realLink = [NSString stringWithFormat:@"https://vimeo.com/api/oembed.json?url=https://vimeo.com/%@&width=960",videoPath];
            NSURL *u = [NSURL URLWithString:[realLink stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
            if (u) {
                self.thumbURL = u;
                
            }
            self.hasVideo = YES;
        } else if ([_url.absoluteString containsString:@"facebook"]) {
            self.thumbnail = [UIImage imageNamed:@"videobase.jpg"];
            self.hasVideo = YES;
        } else {
            
            self.hasVideo = NO;
            if ([self.shareItem hasItemConformingToTypeIdentifier:@"public.file-url"] && [self.shareItem hasItemConformingToTypeIdentifier:@"public.image"]) {
                self.objType = (__bridge NSString *)kUTTypeImage;
                [self setThumbnail:[UIImage imageWithContentsOfFile:[self.url path]]];
                
            } else {
                //  other ordinary URL or text
            
                [self.shareItem loadPreviewImageWithOptions:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
                    if (!error && item) {
                        [wself setThumbnail:(UIImage *)item];
                    } else {
                        [wself setThumbnail:[UIImage imageNamed:@"videobase.jpg"]];
                    }
                }];
            }
        }
    } else if ([_objType isEqualToString:(__bridge NSString *)kUTTypeMovie]){
        self.hasVideo = YES;//[_objType isEqualToString:(__bridge NSString *)kUTTypeMovie];
        [self.shareItem loadPreviewImageWithOptions:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
            if (!error && item) {
                [wself setThumbnail:(UIImage *)item];
            } else {
                [wself setThumbnail:[UIImage imageNamed:@"videobase.jpg"]];
            }
        }];
    } else if ([_objType isEqualToString:(__bridge NSString *)kUTTypeImage]) {
        self.hasVideo = NO;
        self.thumbnail = [UIImage imageWithContentsOfFile:[self.url path]];
    }
}
- (void)setUrl:(NSURL *)url {
    _url = url;
    
    if ([_objType isEqualToString:(__bridge NSString *)kUTTypeMovie]) {
        AVURLAsset *sourceAsset = [AVURLAsset URLAssetWithURL:url options:nil];
        CMTime duration = sourceAsset.duration;
        _vidDuration = CMTimeGetSeconds(duration);
    }
}
- (void)setThumbnail:(UIImage *)thumbnail  {
    _thumbnail = thumbnail;
    
    [self inspectThumbnailTone:thumbnail];
}
- (void)inspectThumbnailTone:(UIImage *)thumbnail {
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGDataProviderRef provider = CGImageGetDataProvider(thumbnail.CGImage);
        CFDataRef data = CGDataProviderCopyData(provider);
        if (data) {
            UInt8 *ptr = (UInt8 *)CFDataGetBytePtr(data);
            NSInteger length = CFDataGetLength(data);
            int th = (thumbnail.size.height*thumbnail.size.width*45) /100;
            int darkp = 0;
            double luma = 0.0;
            for (int i = 0 ; i < length; i+=4) {
                UInt8 r = ptr[i];
                UInt8 g = ptr[i+1];
                UInt8 b = ptr[i+2];
                luma = (0.2126 * (double)r+0.7152 *(double)g+0.0722 * (double)b);
                if (luma < 150) {
                    darkp += 1;
                    if (darkp > th) {
                        
                        CFRelease(data);
                        wself.thumbIsDark = YES;
                        
                        return;
                    }
                    
                }
            }
            
        }
        
        CFRelease(data);
        wself.thumbIsDark = NO;
    });
}
- (void)loadThumbnailWithPostload:(id<ItemPostLoadDelegate>) postload {
    __block typeof(self) wself = self;
    if (_thumbnail) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //imgView.image = wself.thumbnail;
            if (postload)
                [postload loadCompleted:wself.thumbnail type:wself.objType hasVideo:wself.hasVideo isDark:wself.thumbIsDark];
        });
        
    } else if (_thumbURL) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:wself.thumbURL];
            if (data) {
                UIImage *image = [UIImage imageWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    wself.thumbnail = image;
                    if (postload)
                        [postload loadCompleted:wself.thumbnail type:wself.objType hasVideo:self.hasVideo isDark:self.thumbIsDark];
                });
            }
        });
    } else {
        [self postLoadShareItem];
        [self performSelector:@selector(loadThumbnailWithPostload:) withObject:postload afterDelay:3];
    }
}
@end
