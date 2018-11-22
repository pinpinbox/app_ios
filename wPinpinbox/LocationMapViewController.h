//
//  LocationMapViewController.h
//  wPinpinbox
//
//  Created by Antelis on 2018/11/14.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AddLocationDelegate
- (void)didSelectLocation:(NSString *)location;
@end

@interface MapPresentationController : UIPresentationController
@end
@interface MapAnimationTransitioning : NSObject<UIViewControllerAnimatedTransitioning>
- (id)initWithType:(BOOL)isPrensenting;
@end
@interface LocationMapViewController : UIViewController<UIViewControllerTransitioningDelegate>
@property (nonatomic) id<AddLocationDelegate> locationDelegate;
- (void)loadLocation:(NSString *)l;
- (IBAction)cancelAndDismiss:(id)sender;
- (void)addDismissTap;
- (void)handleDismissTap:(UITapGestureRecognizer *)tap;
- (void)addKeyboardNotification;
- (void)removeKeyboardNotification;
- (void)keyboardWasShown;
- (void)keyboardWillBeHidden:(NSNotification*)aNotification;
@end

NS_ASSUME_NONNULL_END
