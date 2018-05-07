//
//  YoutubeViewController.m
//  wPinpinbox
//
//  Created by Angus on 2015/11/25.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "YoutubeViewController.h"

@interface YoutubeViewController ()

@end
#define degreesToRadians(x) ((x) * (M_PI / 180.0));

@implementation YoutubeViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.playerView.center = self.view.center;
}

- (void)viewDidLoad {
    [super viewDidLoad];
   //[[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
   // self.view.transform = CGAffineTransformMakeRotation(90*(M_PI/180.0));
    
    self.playerView.delegate = self;
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.playerView.center = self.view.center;    
    
    // Filter the string
    //NSArray *youtubeURL = [_url componentsSeparatedByString: @"="];
    //NSString *videoID = [youtubeURL objectAtIndex: 1];
    
    NSString *videoID = [self extractYoutubeIdFromLink: self.url];
    
    NSLog(@"Youtube URL: %@", videoID);
    
    [self.playerView loadWithVideoId: videoID];
    
    /*
    NSString *youTubeVideoHTML = @"<!DOCTYPE html><html><head><style>body{margin:0px 0px 0px 0px;}</style></head> <body> <div id=\"player\"></div> <script> var tag = document.createElement('script'); tag.src = \"http://www.youtube.com/player_api\"; var firstScriptTag = document.getElementsByTagName('script')[0]; firstScriptTag.parentNode.insertBefore(tag, firstScriptTag); var player; function onYouTubePlayerAPIReady() { player = new YT.Player('player', { width:'%0.0f', height:'%0.0f', videoId:'%@', events: { 'onReady': onPlayerReady, } }); } function onPlayerReady(event) { event.target.playVideo(); } </script> </body> </html>";
    
    
    //_url=@"https://youtu.be/V9UYMPLzwbg";
    NSArray *arr=[_url componentsSeparatedByString:@"/"];
    if ([arr count]!=4) {
        
        //設定網址
        NSURL *url = [NSURL URLWithString:_url];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        [_myWebView loadRequest:requestObj];
        return;
        
        return;
    }
    NSString *html =  [NSString stringWithFormat:youTubeVideoHTML,  _myWebView.frame.size.width,  _myWebView.frame.size.height, arr[3]];

    
    
    _myWebView.opaque=NO;
    _myWebView.mediaPlaybackRequiresUserAction=NO;
    
    [ _myWebView loadHTMLString:html baseURL:[[NSBundle mainBundle] resourceURL]];
     */
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _bookVC.videoPlay = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)extractYoutubeIdFromLink:(NSString *)link
{
    NSString *regexString = @"((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)";
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern: regexString options: NSRegularExpressionCaseInsensitive error: nil];
    NSArray *array = [regExp matchesInString: link options: 0 range: NSMakeRange(0, link.length)];
    
    if (array.count > 0) {
        NSTextCheckingResult *result = array.firstObject;
        return [link substringWithRange: result.range];
    }
    return nil;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
 
- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView
{
    NSLog(@"playerViewDidBecomeReady");
    
    NSLog(@"_bookVC.audioSwitch: %d", _bookVC.audioSwitch);
    
    // The music is playing
    // At the beginning, audioSwitch is On, after pressing will be set to NO;
    if (!_bookVC.audioSwitch) {
        NSLog(@"bookVC.audioSwitch is ON");
        _bookVC.videoPlay = YES;
        
        [_bookVC playCheck];
    }
    
    playerView.center = self.view.center;
}

- (void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state
{
    NSLog(@"state: %ld", (long)state);
    
    if (state == kYTPlayerStatePlaying || state == kYTPlayerStateBuffering || state == kYTPlayerStatePaused) {
        NSLog(@"kYTPlayerStatePlaying");
        
        playerView.center = self.view.center;
    }
}

@end
