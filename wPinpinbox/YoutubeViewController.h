//
//  YoutubeViewController.h
//  wPinpinbox
//
//  Created by Angus on 2015/11/25.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTPlayerView.h"
#import "BookViewController.h"

@interface YoutubeViewController : UIViewController <YTPlayerViewDelegate>
//@property (weak, nonatomic) IBOutlet UIWebView *myWebView;
@property (weak, nonatomic) IBOutlet YTPlayerView *playerView;
@property (nonatomic) NSString *url;
@property(weak) BookViewController *bookVC;

@end