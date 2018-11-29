//
//  3rdPartyVideoPlayerViewController.h
//  wPinpinbox
//
//  Created by Antelis on 2018/11/28.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface  PlayerVCPresenterVC : UIPresentationController

@end
@interface PlayerVCAnimationTransitioning : NSObject<UIViewControllerAnimatedTransitioning>

@end
@interface ThirdPartyVideoPlayerViewController : UIViewController<UIViewControllerTransitioningDelegate>
- (void)setVideoPath:(NSString *)path;
@end

NS_ASSUME_NONNULL_END
