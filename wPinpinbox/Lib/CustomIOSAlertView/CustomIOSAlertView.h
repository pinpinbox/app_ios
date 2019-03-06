//
//  CustomIOSAlertView.h
//  CustomIOSAlertView
//
//  Created by Richard on 20/09/2013.
//  Copyright (c) 2013-2015 Wimagguc.
//
//  Lincesed under The MIT License (MIT)
//  http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>

#define kMinAlertViewContentHeight 96
#define kMinAlertViewActionHeight 72
#define kAlertContentBackgroundImageSize 128
#define kAlertContentBackgroundImageInset 16
extern const CGFloat kCustomIOSAlertViewDefaultButtonSpacerHeight;

@protocol CustomIOSAlertViewDelegate

- (void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface CustomIOSAlertView : UIView<CustomIOSAlertViewDelegate>

@property (nonatomic, retain) UIView *parentView;    // The parent view this 'dialog' is attached to
@property (nonatomic, retain) UIView *dialogView;    // Dialog's container view
@property (nonatomic, retain) UIView *containerView; // Container within the dialog (place your ui elements here)

@property (nonatomic, assign) id<CustomIOSAlertViewDelegate> delegate;
@property (nonatomic, retain) NSArray *buttonColors;
@property (nonatomic, retain) NSArray *buttonTitles;
@property (nonatomic, retain) NSArray *buttonTitlesColor;
@property (nonatomic, retain) NSArray *buttonTitlesHighlightColor;
@property (nonatomic, assign) BOOL useMotionEffects;
@property (nonatomic, assign) BOOL closeOnTouchUpOutside;       // Closes the AlertView when finger is lifted outside the bounds.

@property (nonatomic, copy) NSString *arrangeStyle;

@property (nonatomic, assign) BOOL useImages;
@property (nonatomic, retain) NSArray *buttonImages;

@property (copy) void (^onButtonTouchUpInside)(CustomIOSAlertView *alertView, int buttonIndex) ;

- (id)init;

/*!
 DEPRECATED: Use the [CustomIOSAlertView init] method without passing a parent view.
 */
- (id)initWithParentView: (UIView *)_parentView __attribute__ ((deprecated));

- (void)show;
- (void)close;

- (IBAction)customIOS7dialogButtonTouchUpInside:(id)sender;
- (void)setOnButtonTouchUpInside:(void (^)(CustomIOSAlertView *alertView, int buttonIndex))onButtonTouchUpInside;

- (void)deviceOrientationDidChange: (NSNotification *)notification;
- (void)dealloc;

//  if badgeName is nil , use icon_2_0_0_dialog_error as default badge image
- (void)setContentViewWithMsg:(NSString *)message contentBackgroundColor:(UIColor *)cntBackgroundColor badgeName:(NSString *)badgeName;
- (void)setContentViewWithIconName:(NSString *)iconName message:(NSString *)message contentBackground:(UIColor *)cntBackgroundColor badgeName:(NSString *)badgeName;
@end
