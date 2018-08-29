//
//  YoutubePlayerViewController.h
//  wPinpinbox
//
//  Created by David on 2018/8/24.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTPlayerView.h"

@class YoutubePlayerViewController;

@protocol YoutubePlayerViewControllerDelegate <NSObject>
- (void)youtubePlayerViewControllerDidDisappeared:(YoutubePlayerViewController *)controller currentPage:(NSInteger)currentPage;
@end

@interface YoutubePlayerViewController : UIViewController <YTPlayerViewDelegate>
@property (weak) id <YoutubePlayerViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet YTPlayerView *playerView;
@property (nonatomic) NSInteger currentPage;
@property (strong, nonatomic) NSString *videoUrlString;
@end
