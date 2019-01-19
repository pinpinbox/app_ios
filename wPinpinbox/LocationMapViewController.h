//
//  LocationMapViewController.h
//  wPinpinbox
//
//  Created by Antelis on 2018/11/14.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;
NS_ASSUME_NONNULL_BEGIN

@protocol AddLocationDelegate
- (void)didSelectLocation:(NSString *)location;
@end

@interface LeftPaddingTextfield : UITextField
@end

@interface MapPresentationController : UIPresentationController
@end
@interface MapAnimationTransitioning : NSObject<UIViewControllerAnimatedTransitioning>
- (id)initWithType:(BOOL)isPrensenting;
@end
@interface LocationMapViewController : UIViewController<UIViewControllerTransitioningDelegate>
@property (nonatomic) id<AddLocationDelegate> locationDelegate;
@property (nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
- (void)loadLocation:(NSString *)l;
- (IBAction)cancelAndDismiss:(id)sender;
- (void)cancelAndDismiss;
- (void)addDismissTap;
- (void)handleDismissTap:(UITapGestureRecognizer *)tap;
- (void)addKeyboardNotification;
- (void)removeKeyboardNotification;
- (void)keyboardWasShown:(NSNotification*)aNotification;
- (void)keyboardWillBeHidden:(NSNotification*)aNotification;
@end

NS_ASSUME_NONNULL_END
