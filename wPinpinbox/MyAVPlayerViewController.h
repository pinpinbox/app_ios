//
//  MyAVPlayerViewController.h
//  wPinpinbox
//
//  Created by David on 7/13/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import <AVKit/AVKit.h>

@protocol MyAVPlayerViewControllerDelegate <NSObject>

- (void)didDismissViewController:(AVPlayerViewController *)avPlayerVC;

@end

@interface MyAVPlayerViewController : AVPlayerViewController


@end
