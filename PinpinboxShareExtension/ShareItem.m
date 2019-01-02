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

@interface ShareItem()
@property (nonatomic) id<ItemContentDelegate> itemDelegate;
@end

@implementation ShareItem
- (id)initWithItemProvider:(NSItemProvider *)item type:(NSString *)type itemDelegate:(id<ItemContentDelegate>)itemDelegate{
    self = [super init];
    if (self) {
        self.itemDelegate = itemDelegate;
        self.hasVideo = NO;
        self.thumbIsDark = NO;
        self.vidDuration = 0;
        self.objType = type;
        self.shareItem = item;
        
        [self postLoadShareItem];
    }
    return self;
}
- (void)postLoadShareItem {
    __block typeof(self) wself = self;
    [self.shareItem loadItemForTypeIdentifier:self.objType options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
        if (!error) {
            if ([wself.objType isEqualToString:(__bridge  NSString *)kUTTypeText]) {

                @try {
                    
                    NSString *text = (NSString *)item;
                    if (![text hasPrefix:@"file://"]) {
                        NSURL *url = [NSURL URLWithString:text];
                        [wself setUrl:url];
                    }
                    
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
            NSString *th = [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/hqdefault.jpg",videoID];
            self.thumbURL = [NSURL URLWithString:th];
            self.hasVideo = YES;
        } else if ([_url.absoluteString containsString:@"vimeo"]) {
            self.hasVideo = YES;
            NSString *videoPath = _url.lastPathComponent;
            NSString *realLink = [NSString stringWithFormat:@"https://vimeo.com/api/oembed.json?url=https://vimeo.com/%@&width=960",videoPath];
            NSURL *url = [NSURL URLWithString:[realLink stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
            NSData *data = [NSData dataWithContentsOfURL:url];
            if (url  && data) {
                NSError *e1 = nil;
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&e1];
                if (!e1 && dict ) {
                    NSString *tpath = dict[@"thumbnail_url"];
                    if (tpath) {
                        self.thumbURL = [NSURL URLWithString:tpath];
                        return;
                    }
                    
                }
                
            }
            //  nothing found
            self.thumbnail = [UIImage imageNamed:@"videobase.jpg"];
            
        } else if ([_url.absoluteString containsString:@"facebook"]) {
            self.thumbnail = [UIImage imageNamed:@"videobase.jpg"];
            self.hasVideo = YES;
        } else {
            self.hasVideo = NO;
            if ([self.shareItem hasItemConformingToTypeIdentifier:@"public.file-url"] && [self.shareItem hasItemConformingToTypeIdentifier:@"public.image"]) {
                self.objType = (__bridge NSString *)kUTTypeImage;
                [self setThumbnail:[UIImage imageWithContentsOfFile:[self.url path]]];
                
            } else {
                //  other invalid format : ordinary URL, pure text, or text file
               // [self loadThumbnailOtherway];
                if (self.itemDelegate)
                    [self.itemDelegate processInvalidItem:self];
            }
        }
    } else if ([_objType isEqualToString:(__bridge NSString *)kUTTypeMovie]){
        self.hasVideo = YES;//[_objType isEqualToString:(__bridge NSString *)kUTTypeMovie];
        [self.shareItem loadPreviewImageWithOptions:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
            if (!error && item) {
                [wself setThumbnail:(UIImage *)item];
            } else {
                //[wself setThumbnail:[UIImage imageNamed:@"videobase.jpg"]];
            }
        }];
    } else if ([_objType isEqualToString:(__bridge NSString *)kUTTypeImage]) {
        self.hasVideo = NO;
        self.thumbnail = [UIImage imageWithContentsOfFile:[self.url path]];
    } else if ([_objType isEqualToString:(__bridge NSString *)kUTTypePDF]) {
        self.hasVideo = NO;
        [self loadThumbnailOtherway];
    }
}
- (void)loadThumbnailOtherway {
    __block typeof(self) wself = self;
    [self.shareItem loadPreviewImageWithOptions:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
        if (!error && item) {
            [wself setThumbnail:(UIImage *)item];
        } else {
            
            [wself.url startAccessingSecurityScopedResource];
            
            NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] init];
            __block NSError *error;
            [coordinator coordinateReadingItemAtURL:self.url options:0 error:&error byAccessor:^(NSURL *newURL) {
                NSDictionary *thumbs = nil;
                thumbs = [newURL resourceValuesForKeys:@[NSURLThumbnailDictionaryKey] error:&error]; //getResourceValue:&thumbs forKey:NSURLThumbnailDictionaryKey error:&error];
                if (thumbs && thumbs[NSURLThumbnailDictionaryKey]) {
                    NSLog(@"%@",thumbs);
                    NSDictionary *t =  thumbs[NSURLThumbnailDictionaryKey];
                    UIImage *tt = t[NSThumbnail1024x1024SizeKey];
                    if (tt)
                        [wself setThumbnail:tt];
                    else
                        [wself setThumbnail:[UIImage imageNamed:@"videobase.jpg"]];
                } else
                    [wself setThumbnail:[UIImage imageNamed:@"videobase.jpg"]];
            }];
            
            [wself.url stopAccessingSecurityScopedResource];
            
            
        }
    }];
}
- (void)setUrl:(NSURL *)url {
    _url = url;
    
    if ([_objType isEqualToString:(__bridge NSString *)kUTTypeMovie]) {
        AVURLAsset *sourceAsset = [AVURLAsset URLAssetWithURL:url options:nil];
        CMTime duration = sourceAsset.duration;
        _vidDuration = CMTimeGetSeconds(duration);
        if (_vidDuration >= 31.0) {
            if (self.itemDelegate)
                [self.itemDelegate processInvalidItem:self];
            return;
        }
        AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:sourceAsset];
        NSError *err = nil;
        
        CGImageRef c = [generator copyCGImageAtTime:CMTimeMake(1.0, 1000) actualTime:nil error:&err];
        if (!err && c) {
            self.thumbnail = [UIImage imageWithCGImage:c];
            [self inspectThumbnailTone:self.thumbnail];
        }
        
    }
}
- (void)setThumbnail:(UIImage *)thumbnail  {
    _thumbnail = thumbnail;
    [self inspectThumbnailTone:thumbnail];
}
- (void)inspectThumbnailTone:(UIImage *)thumbnail {
    if (!thumbnail) return;
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

// 1. Vimeo has redirect URL in app ?? found no other cases
// XXX 2. https://vimeo.com/api/oembed.json?url=[URL]&width=960 seemed returned JSON!
// 3. YT live test is necessary
// 4. PDF upload process
// slide net ??? https://www.slideshare.net/developers
//  new album

