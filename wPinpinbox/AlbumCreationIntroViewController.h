//
//  AlbumCreationIntroViewController.h
//  wPinpinbox
//
//  Created by Antelis on 2018/11/26.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface IntroPresentationController : UIPresentationController
@end
@interface IntroAnimationTransitioning : NSObject<UIViewControllerAnimatedTransitioning>

@end


@interface AlbumCreationIntroViewController : UIViewController<UIViewControllerTransitioningDelegate>
- (void)setStep1Rect:(CGRect) rect1 step2Rect:(CGRect)rect2 step3Rect:(CGRect)rect3;
@end

NS_ASSUME_NONNULL_END
