//
//  VideoViewController.m
//  wPinpinbox
//
//  Created by Angus on 2015/11/25.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "VideoViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface VideoViewController ()
{
    MPMoviePlayerController *player;
    __weak IBOutlet UIButton *btn;
}
@end

@implementation VideoViewController

-(IBAction)play:(id)sender{
    btn.hidden=YES;
    [player play];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];        
    
    [player play];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
    // Do any additional setup after loading the view from its nib.
    
    //設定影片檔路徑
    NSString *path = _videofile;
    NSURL *url = [NSURL fileURLWithPath:path];
    
    //player為MPMoviePlayerController型態的指標
    player = [[MPMoviePlayerController alloc] initWithContentURL:url];
    
    //旋轉90度
    player.view.transform = CGAffineTransformMakeRotation(1.5707964);
    
    //使用Observer製作完成播放時要執行的動作
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:player];
    
    //設定影片比例的縮放、重複、控制列等參數
    player.scalingMode = MPMovieScalingModeAspectFit;
    player.controlStyle = MPMovieControlStyleFullscreen;
    player.view.transform = CGAffineTransformMakeRotation(0*(M_PI/180.0));
    
    //將影片加至主畫面上
    player.view.frame = self.view.bounds;
    [videoView addSubview:player.view];
}

//自行定義影片播放完成的函式
- (void)moviePlayBackDidFinish:(NSNotification *)notification {
    
    //btn.hidden=NO;
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:player];
    [player stop];
}

- (void)didReceiveMemoryWarning {
      [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}
*/
@end
