//
//  WKVideoPlayerView.h
//  WKWebVideoPlayer
//
//  Created by Antelis on 2018/11/11.
//  Copyright © 2018 Antelis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (extractURLs)
- (NSArray *)findURLs;
@end

@interface WKVideoPlayerView : WKWebView
- (id)initWithString:(NSString *)path configuration:(nonnull WKWebViewConfiguration *)configuration;
- (BOOL)isURLsContained;
- (NSString *)stringWithURLs;
- (void)setVideoPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
