//
//  WKVideoPlayerView.m
//  WKWebVideoPlayer
//
//  Created by Antelis on 2018/11/11.
//  Copyright © 2018 Antelis. All rights reserved.
//

#import "WKVideoPlayerView.h"


#pragma mark - Utility classe extensions -
@interface NSURL (queryParams)
- (NSString *)queryParam:(NSString *)param;
@end

@implementation NSURL (quertParams)
- (NSString *)queryParam:(NSString *)param; {
    NSURLComponents *u = [NSURLComponents componentsWithString:self.absoluteString];
    if (u == nil) return @"";
    NSMutableString *result = [NSMutableString stringWithString:@""];
    [u.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.name isEqualToString:param]) {
            [result setString: obj.value];
            *stop = YES;
        }
    }];
    
    return result;
    
}
@end



@implementation NSString (extractURLs)
- (NSArray *)findURLs {
    NSError *error = nil;
    NSMutableArray *urls = [NSMutableArray array];
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    
    if (detector && !error) {
        
        [detector enumerateMatchesInString:self options:0 range:NSMakeRange(0, self.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            if (result && result.URL != nil) {
                [urls addObject:result.URL];
            }
        }];
    }
    
    return urls;
}
@end

#pragma mark -
@interface WKVideoPlayerView()
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSMutableArray *urls;
@end
@implementation WKVideoPlayerView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    return self;
}
- (id)initWithString:(NSString *)path {
    CGFloat w = UIScreen.mainScreen.bounds.size.width;
    CGFloat h = w*0.5625;
    self = [self initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, h)];
    if (self) {
        [self setVideoPath:path];
    }
    
    return self;
}
- (void)setVideoPath:(NSString *)path {
    
    self.path = path;
    self.urls = [NSMutableArray arrayWithArray:[path findURLs]];
    [self.scrollView setScrollEnabled:NO];
    [self setup];
}
- (BOOL)isURLsContained {
    if (self.urls.count) {
        for (NSURL *url in self.urls) {
            if([url.absoluteString containsString:@"youtu"] || [url.absoluteString containsString:@"vimeo.com"])
                return YES;
        
        }
    }
    
    return NO;
}

- (NSString *)stringWithURLs {
    
    NSString *res = self.path;
    if (self.urls.count) {
        for (NSURL *url in self.urls) {
            NSString *u = [NSString stringWithFormat:@"\%@", url.absoluteString];
            res = [res stringByReplacingOccurrencesOfString:u withString:@""];
        }
        
    }
    
    return res;
}
- (NSString *)getYTString:(NSString *)link {
    return [NSString stringWithFormat:@"<head> <meta name=viewport content='width=device-width, initial-scale=1'><style type='text/css'> body { margin: 0; background: #fafafa;} </style></head><iframe src='%@' width='100%%' height='100%%' frameborder='0' allow='accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture'></iframe>",link];
    
}
- (NSString *)getVimeoString:(NSString *)link {
    return [NSString stringWithFormat:@"<head> <meta name=viewport content='width=device-width, initial-scale=1'><style type='text/css'> body { margin: 0;background: #fafafa;} </style></head><iframe src='%@' width='100%%' height='100%%' frameborder='0' webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>", link];
}

- (void)setup {
    for (NSURL *url in self.urls) {
        if ([url.absoluteString containsString:@"youtu"]) {
            NSString *realLink = nil;
            if ([url.host containsString:@"youtube.com"]) {
                realLink = [NSString stringWithFormat:@"https://www.youtube.com/embed/%@?rel=0",[url queryParam:@"v"]];
            } else if ([url.host containsString:@"youtu.be"]) {
                realLink = [NSString stringWithFormat:@"https://www.youtube.com/embed/%@?rel=0",[url lastPathComponent]];
            }
            
            if (realLink && realLink.length > 1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *html = [self getYTString:realLink];
                    [self loadHTMLString:html baseURL:nil];
                });
            }
        } else if ([url.absoluteString containsString:@"vimeo.com"]) {
            NSString *videoPath = url.lastPathComponent;
            NSString *realLink = [NSString stringWithFormat:@"https://player.vimeo.com/video/%@",videoPath];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *html = [self getVimeoString:realLink];
                [self loadHTMLString:html baseURL:nil];
            });
            
        }
    }

}

@end
