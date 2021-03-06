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
- (void)loadVideoTimedOut{
    if (self.handleTimedOutBlock) {
        self.handleTimedOutBlock();
    }
}
- (nullable WKNavigation *)loadHTMLString:(NSString *)string baseURL:(nullable NSURL *)baseURL {
    //  Add a timed-out notification, because video in iframe may be failed to load from time to time....
    [NSTimer scheduledTimerWithTimeInterval: 120.0
                                     target: self
                                   selector: @selector(loadVideoTimedOut)
                                   userInfo: nil
                                    repeats: NO];
    return [super loadHTMLString:string baseURL:baseURL];
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
            if([url.absoluteString containsString:@"youtu"] || [url.absoluteString containsString:@"vimeo.com"]||[url.absoluteString containsString:@"facebook"])
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
//  html for YT video
- (NSString *)getYTString:(NSString *)link {
    
    
    NSString *iid = [link lastPathComponent];
    NSArray *yids = [iid componentsSeparatedByString:@"?"];
    iid = [NSString stringWithFormat:@"https://www.youtube.com/embed/%@?enablejsapi=1&playsinline=1",[yids firstObject]];
    NSString *scr = @"<head>     <meta name='viewport' content='initial-scale=1'>    <style type='text/css'> body { margin: 0; width:100%%; height:100%%;  background-color:#000000; }   html { width:100%%; height:100%%; background-color:#000000; }.embed-container iframe,.embed-container object,.embed-container embed position: absolute;top: 0;left: 0;width: 100%% !important;height: 100%% !important;} </style>    </head> <iframe id='player' width='100%%'             height='100%%'  src= %@ frameborder='0' autoplay='1' style='background: #000;'></iframe>        <script type=\"text/javascript\">        var tag = document.createElement('script');        tag.id='videoiframe';        tag.src = \"https://www.youtube.com/iframe_api\";        var firstScriptTag = document.getElementsByTagName('script')[0];        firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);        var player; function onYouTubeIframeAPIReady(){webkit.messageHandlers.callbackHandler.postMessage('APIisReady');  player = new YT.Player('player', {'events': { 'onReady':onPlayerReady,                   'onStateChange': onPlayerStateChange                    }});}        var done = false; function onPlayerReady(){webkit.messageHandlers.callbackHandler.postMessage('VideoIsReady');player.playVideo();} function onPlayerStateChange(event) {            console.log('YT.player changed:: '+event);            if (event.data == YT.PlayerState.PLAYING) {                webkit.messageHandlers.callbackHandler.postMessage('VideoIsPlaying');                console.log('VideoIsPlaying');                done = true;            } else if (event.data == YT.PlayerState.PAUSED) {                webkit.messageHandlers.callbackHandler.postMessage('VideoIsPaused');                console.log('VideoIsPaused');            } else if (event.data == YT.PlayerState.ENDED) {                webkit.messageHandlers.callbackHandler.postMessage('VideoIsEnded');                console.log('VideoIsEnded');            }        } function stopPlayer() { player.stopVideo();}</script>";
    
    return [NSString stringWithFormat:scr,iid];
    
}
//  html for Vimeo video
- (NSString *)getVimeoString:(NSString *)link {
    return [NSString stringWithFormat:@"<head> <meta name=viewport content='width=device-width, initial-scale=1'><style type='text/css'> body { margin: 0; width:100%%; height:100%%;  background-color:#000000; }   html { width:100%%; height:100%%; background-color:#000000; }.embed-container iframe,.embed-container object,.embed-container embed position: absolute;top: 0;left: 0;width: 100%% !important;height: 100%% !important;} </style></head><iframe src='%@' width='100%%' height='100%%' frameborder='0' webkitallowfullscreen mozallowfullscreen allowfullscreen style='background: #000;'></iframe> <script src=\"https://player.vimeo.com/api/player.js\"></script><script>var iframe = document.querySelector('iframe');var player = new Vimeo.Player(iframe);player.on('play', function() {webkit.messageHandlers.callbackHandler.postMessage('Vimeo VideoIsPlaying'); console.log('playing');});player.on('loaded', function() {webkit.messageHandlers.callbackHandler.postMessage('Vimeo VideoIsReady');console.log('ready'); player.play();});player.on('pause',function() {webkit.messageHandlers.callbackHandler.postMessage('Vimeo VideoIsPaused');console.log('paused');});player.on('ended',function(){webkit.messageHandlers.callbackHandler.postMessage('VideoIsEnded');console.log('ended');}); function stopPlayer() {player.pause();} </script>", link];
}
- (NSString *)getFBVideoString:(NSString *)link {
    // get fb app id from plist
    NSString *FBApp = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FacebookAppID"];
    if (!FBApp)
        FBApp = @"472973216191275";
    NSString *src = @"<!DOCTYPE html><head><title>_</title><style type='text/css'> body { margin: 0; width:100%%; height:100%%; background-color:#000000; }</style></head><body><div id=\"fb-root\"></div><script> var my_video_player; window.fbAsyncInit = function() {FB.init({appId:'%@',xfbml:true,version:'v2.6'}); FB.Event.subscribe('xfbml.ready', function(msg) {if (msg.type === 'video') {my_video_player = msg.instance; my_video_player.subscribe('startedPlaying', function(e) {webkit.messageHandlers.callbackHandler.postMessage(' VideoIsReady');}); my_video_player.play();}});};(function(d, s, id) {  var js, fjs = d.getElementsByTagName(s)[0];  if (d.getElementById(id)) return;  js = d.createElement(s); js.id = id;  js.src = \"https://connect.facebook.net/en_US/sdk.js\";  fjs.parentNode.insertBefore(js, fjs); }(document, 'script', 'facebook-jssdk')); function stopPlayer() { my_video_player.pause(); } </script> <div style='width:100%%;height:100%%;display: flex;vertical-align: middle;align-items:center;' ><div style='width:100%%; ' class=\"fb-video\" data-href=\"%@\" data-width=\"auto\" data-autoplay=\"true\" data-allowfullscreen=\"true\" data-show-text=\"false\"></div></div></body></html>";
    return [NSString stringWithFormat:src,FBApp, link];
}
//  find video id from path and compose html
- (void)setup {
    
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
            NSString *realLink = [NSString stringWithFormat:@"https://player.vimeo.com/video/%@?autoplay=1&quality=1080p",videoPath];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *html = [self getVimeoString:realLink];
                [self loadHTMLString:html baseURL:nil];
            });
            
        } else if ([url.absoluteString containsString:@"facebook"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *html = [self getFBVideoString:url.absoluteString];
                [self loadHTMLString:html baseURL:[NSURL URLWithString:@"https://www.apple.com"]];
            });
            
        }
    }

}

//  pause video on web page from native code
- (void)pauseVid {
    [self evaluateJavaScript:@"stopPlayer();" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
        NSLog(@"evaluateJavaScript %@", error);
    }];
}
@end
