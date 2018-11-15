//
//  LocationMapViewController.h
//  wPinpinbox
//
//  Created by Antelis on 2018/11/14.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MapPresentationController : UIPresentationController
@end
@interface MapAnimationTransitioning : NSObject<UIViewControllerAnimatedTransitioning>
@end

@interface LocationMapViewController : UIViewController<UIViewControllerTransitioningDelegate>

@end

NS_ASSUME_NONNULL_END
