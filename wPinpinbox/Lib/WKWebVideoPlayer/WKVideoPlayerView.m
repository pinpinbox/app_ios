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

@interface WKVideoPlayerView()<UIGestureRecognizerDelegate>
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSMutableArray *urls;
@property (nonatomic, strong) NSLayoutConstraint *widthheight;
//@property (nonatomic, strong) WKUserContentController *cntController;
@end

@implementation WKVideoPlayerView

- (id)initWithFrame:(CGRect)frame configuration:(nonnull WKWebViewConfiguration *)configuration {
    self = [super initWithFrame:frame configuration:configuration];
    return self;
}
- (id)initWithString:(NSString *)path configuration:(nonnull WKWebViewConfiguration *)configuration {
    CGFloat w = UIScreen.mainScreen.bounds.size.width;
    CGFloat h = w*0.5625;
    
    self = [self initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, h) configuration:configuration];
    if (self) {
        [self setVideoPath:path];
    }
    
    return self;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
    
}

- (void)setVideoPath:(NSString *)path {
    self.backgroundColor = [UIColor blackColor];
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
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    return YES;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"event  %@", event);
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
    
    
    NSString *iid = [link lastPathComponent];
    NSArray *yids = [iid componentsSeparatedByString:@"?"];
    iid = [NSString stringWithFormat:@"https://www.youtube.com/embed/%@?enablejsapi=1&playsinline=1",[yids firstObject]];
    NSString *scr = @"<head>     <meta name='viewport' content='initial-scale=1'>    <style type='text/css'> body { margin: 0; width:100%%; height:100%%;  background-color:#000000; }   html { width:100%%; height:100%%; background-color:#000000; }.embed-container iframe,.embed-container object,.embed-container embed position: absolute;top: 0;left: 0;width: 100%% !important;height: 100%% !important;} </style>    </head> <iframe id='player' width='100%%'             height='100%%'  src= %@ frameborder='0' autoplay='1' style='background: #000;'></iframe>        <script type=\"text/javascript\">        var tag = document.createElement('script');        tag.id='videoiframe';        tag.src = \"https://www.youtube.com/iframe_api\";        var firstScriptTag = document.getElementsByTagName('script')[0];        firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);        var player; function onYouTubeIframeAPIReady(){webkit.messageHandlers.callbackHandler.postMessage('APIisReady');  player = new YT.Player('player', {'events': { 'onReady':onPlayerReady,                   'onStateChange': onPlayerStateChange                    }});}        var done = false; function onPlayerReady(){webkit.messageHandlers.callbackHandler.postMessage('VideoIsReady');player.playVideo();} function onPlayerStateChange(event) {            console.log('YT.player changed:: '+event);            if (event.data == YT.PlayerState.PLAYING) {                webkit.messageHandlers.callbackHandler.postMessage('VideoIsPlaying');                console.log('VideoIsPlaying');                done = true;            } else if (event.data == YT.PlayerState.PAUSED) {                webkit.messageHandlers.callbackHandler.postMessage('VideoIsPaused');                console.log('VideoIsPaused');            } else if (event.data == YT.PlayerState.ENDED) {                webkit.messageHandlers.callbackHandler.postMessage('VideoIsEnded');                console.log('VideoIsEnded');            }        } </script>";
    
    return [NSString stringWithFormat:scr,iid];
    
}
- (NSString *)getVimeoString:(NSString *)link {
    return [NSString stringWithFormat:@"<head> <meta name=viewport content='width=device-width, initial-scale=1'><style type='text/css'> body { margin: 0; width:100%%; height:100%%;  background-color:#000000; }   html { width:100%%; height:100%%; background-color:#000000; }.embed-container iframe,.embed-container object,.embed-container embed position: absolute;top: 0;left: 0;width: 100%% !important;height: 100%% !important;} </style></head><iframe src='%@' width='100%%' height='100%%' frameborder='0' webkitallowfullscreen mozallowfullscreen allowfullscreen style='background: #000;'></iframe> <script src=\"https://player.vimeo.com/api/player.js\"></script><script>var iframe = document.querySelector('iframe');var player = new Vimeo.Player(iframe);player.on('play', function() {webkit.messageHandlers.callbackHandler.postMessage('Vimeo VideoIsPlaying'); console.log('playing');});player.on('loaded', function() {webkit.messageHandlers.callbackHandler.postMessage('Vimeo VideoIsReady');console.log('ready'); player.play();});player.on('pause',function() {webkit.messageHandlers.callbackHandler.postMessage('Vimeo VideoIsPaused');console.log('paused');});player.on('ended',function(){webkit.messageHandlers.callbackHandler.postMessage('VideoIsEnded');console.log('ended');});</script>", link];
}

- (void)setup {
    UITapGestureRecognizer *t =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleOuterTap:)];
    t.delegate = self;
    [self addGestureRecognizer:t];
    
    
    for (NSURL *url in self.urls) {
        if ([url.absoluteString containsString:@"youtu"]) {
            NSString *realLink = nil;
            if ([url.host containsString:@"youtube.com"]) {
                realLink = [url queryParam:@"v"];//[NSString stringWithFormat:@"https://www.youtube.com/embed/%@?rel=0",[url queryParam:@"v"]];
            } else if ([url.host containsString:@"youtu.be"]) {
                realLink = [url lastPathComponent];//[NSString stringWithFormat:@"https://www.youtube.com/embed/%@?rel=0",[url lastPathComponent]];
            }
            
            if (realLink && realLink.length > 1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *html = [self getYTString:realLink];
                    [self loadHTMLString:html baseURL:nil];
                    
                });
            }
        } else if ([url.absoluteString containsString:@"vimeo.com"]) {
            NSString *videoPath = url.lastPathComponent;
            NSString *realLink = [NSString stringWithFormat:@"https://player.vimeo.com/video/%@?autoplay=1&quality=108v0p",videoPath];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *html = [self getVimeoString:realLink];
                [self loadHTMLString:html baseURL:nil];
            });
            
        }
    }

}
- (void)handleOuterTap:(UITapGestureRecognizer *)tap {
    NSLog(@"handleOuterTap %@",tap);
}

@end


/*
 <head> <meta name=viewport content='width=device-width, initial-scale=1'><style type='text/css'> body { margin: 0;background: #fafafa;} </style></head><iframe src='%@' width='100%%' height='100%%' frameborder='0' webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe> <script src=\"https://player.vimeo.com/api/player.js\"></script><script>var iframe = document.querySelector('iframe');var player = new Vimeo.Player(iframe);player.on('play', function() {webkit.messageHandlers.callbackHandler.postMessage('Vimeo VideoIsPlaying');}); player.on('pause',function() {webkit.messageHandlers.callbackHandler.postMessage('Vimeo VideoIsPaused');});player.on('ended',function() {webkit.messageHandlers.callbackHandler.postMessage('Vimeo VideoIsPaused');});document.addEventListener(\"fullscreenchange\", function() {    if (!document.fullscreenElement) webkit.messageHandlers.callbackHandler.postMessage('VideoIsClosed');}, false); document.addEventListener(\"msfullscreenchange\", function() {    if (!document.msFullscreenElement) webkit.messageHandlers.callbackHandler.postMessage('VideoIsClosed'); }, false); document.addEventListener(\"mozfullscreenchange\", function() {    if (!document.mozFullScreen) webkit.messageHandlers.callbackHandler.postMessage('VideoIsClosed');}, false); document.addEventListener(\"webkitfullscreenchange\", function() {    if (!document.webkitIsFullScreen) webkit.messageHandlers.callbackHandler.postMessage('VideoIsClosed');}, false);</script>
 */

/*
 <head> <meta name=viewport content='width=device-width, initial-scale=1'><style type='text/css'> body { margin: 0;background: #fafafa;} </style></head><iframe src='%@' width='100%%' height='100%%' frameborder='0' webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe> <script src=\"https://player.vimeo.com/api/player.js\"></script><script>var iframe = document.querySelector('iframe');var player = new Vimeo.Player(iframe);player.on('play', function() {webkit.messageHandlers.callbackHandler.postMessage('Vimeo VideoIsPlaying');}); player.on('pause',function() {webkit.messageHandlers.callbackHandler.postMessage('Vimeo VideoIsPaused');});player.on('ended',function() {webkit.messageHandlers.callbackHandler.postMessage('Vimeo VideoIsPaused');});document.addEventListener(\"fullscreenchange\", function() {    if (!document.fullscreenElement) webkit.messageHandlers.callbackHandler.postMessage('VideoIsClosed');}, false); document.addEventListener(\"msfullscreenchange\", function() {    if (!document.msFullscreenElement) webkit.messageHandlers.callbackHandler.postMessage('VideoIsClosed'); }, false); document.addEventListener(\"mozfullscreenchange\", function() {    if (!document.mozFullScreen) webkit.messageHandlers.callbackHandler.postMessage('VideoIsClosed');}, false); document.addEventListener(\"webkitfullscreenchange\", function() {    if (!document.webkitIsFullScreen) webkit.messageHandlers.callbackHandler.postMessage('VideoIsClosed');}, false);</script>"
 */
