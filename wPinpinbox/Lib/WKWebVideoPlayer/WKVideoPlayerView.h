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
//  inspect url from string
@interface NSString (extractURLs)
- (NSArray *)findURLs;
@end

@interface WKVideoPlayerView : WKWebView
//  init WKVideoPlayerView with video path and WKWebViewConfiguration
- (id)initWithString:(NSString *)path configuration:(nonnull WKWebViewConfiguration *)configuration;
//  check if url is valid
- (BOOL)isURLsContained;
- (NSString *)stringWithURLs;
//  set videopath and reload
- (void)setVideoPath:(NSString *)path;
//  pause video
- (void)pauseVid;
@end

NS_ASSUME_NONNULL_END
