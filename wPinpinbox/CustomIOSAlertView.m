//
//  CustomIOSAlertView.m
//  CustomIOSAlertView
//
//  Created by Richard on 20/09/2013.
//  Copyright (c) 2013-2015 Wimagguc.
//
//  Lincesed under The MIT License (MIT)
//  http://opensource.org/licenses/MIT
//

#import "CustomIOSAlertView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Extensions.h"

const static CGFloat kCustomIOSAlertViewDefaultButtonHeight       = 50;
const static CGFloat kCustomIOSAlertViewDefaultButtonSpacerHeight = 5;
const static CGFloat kCustomIOSAlertViewCornerRadius              = 16;
const static CGFloat kCustomIOS7MotionEffectExtent                = 10.0;

#define kCustomIOS7DefaultButtonColor [UIColor colorWithRed:0.670f green:0.670f blue:0.670f alpha:1.0f]

const static CGFloat kCustomIOS7AlertViewDefaultButtonHeight       = 48;
const static CGFloat kCustomIOS7AlertViewDefaultButtonSpacerHeight = 8;
const static CGFloat kCustomIOS7AlertViewCornerRadius              = 10;

@implementation CustomIOSAlertView

CGFloat buttonHeight = 0;
CGFloat buttonSpacerHeight = 0;

@synthesize parentView, containerView, dialogView, onButtonTouchUpInside;
@synthesize delegate;
@synthesize buttonColors;
@synthesize buttonTitles;
@synthesize buttonTitlesColor;
@synthesize buttonTitlesHighlightColor;
@synthesize useMotionEffects;
@synthesize closeOnTouchUpOutside;

@synthesize useImages;
@synthesize buttonImages;

- (id)initWithParentView: (UIView *)_parentView
{
    self = [self init];
    if (_parentView) {
        self.frame = _parentView.frame;
        self.parentView = _parentView;
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);

        delegate = self;
        useMotionEffects = false;
        closeOnTouchUpOutside = false;
        buttonTitles = @[@"Close"];
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

// Create the dialog view, and animate opening the dialog
- (void)show
{
    dialogView = [self createContainerView];
  
    dialogView.layer.shouldRasterize = YES;
    dialogView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
  
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];

#if (defined(__IPHONE_7_0))
    if (useMotionEffects) {
        [self applyMotionEffects];
    }
#endif

    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];

    [self addSubview:dialogView];

    // Can be attached to a view or to the top most window
    // Attached to a view:
    if (parentView != NULL) {        
        [parentView addSubview:self];

    // Attached to the top most window
    } else {

        // On iOS7, calculate with orientation
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
            
            UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
            switch (interfaceOrientation) {
                case UIInterfaceOrientationLandscapeLeft:
                    self.transform = CGAffineTransformMakeRotation(M_PI * 270.0 / 180.0);
                    break;
                    
                case UIInterfaceOrientationLandscapeRight:
                    self.transform = CGAffineTransformMakeRotation(M_PI * 90.0 / 180.0);
                    break;
                    
                case UIInterfaceOrientationPortraitUpsideDown:
                    self.transform = CGAffineTransformMakeRotation(M_PI * 180.0 / 180.0);
                    break;
                    
                default:
                    break;
            }
            
            [self setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];

        // On iOS8, just place the dialog in the middle
        } else {

            CGSize screenSize = [self countScreenSize];
            CGSize dialogSize = [self countDialogSize];
            CGSize keyboardSize = CGSizeMake(0, 0);

            dialogView.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - keyboardSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);

        }

        [[[[UIApplication sharedApplication] windows] firstObject] addSubview:self];
    }

    dialogView.layer.opacity = 0.5f;
    dialogView.layer.transform = CATransform3DMakeScale(1.3f, 1.3f, 1.0);
    __block typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 weakSelf.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f];
                         weakSelf.dialogView.layer.opacity = 1.0f;
                         weakSelf.dialogView.layer.transform = CATransform3DMakeScale(1, 1, 1);
					 }
					 completion:NULL
     ];

}

// Button has been touched
- (IBAction)customIOS7dialogButtonTouchUpInside:(id)sender
{
    //UIButton *btn = (UIButton *)sender;
    //btn.backgroundColor = [UIColor blackColor];
    
    if (delegate != NULL) {
        [delegate customIOS7dialogButtonTouchUpInside:self clickedButtonAtIndex:[sender tag]];
    }

    if (onButtonTouchUpInside != NULL) {
        onButtonTouchUpInside(self, (int)[sender tag]);
    }
}

// Default button behaviour
- (void)customIOS7dialogButtonTouchUpInside: (CustomIOSAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Button Clicked! %d, %d", (int)buttonIndex, (int)[alertView tag]);
    //[self close];
}

// Dialog close animation then cleaning and removing the view from the parent
- (void)close
{
    CATransform3D currentTransform = dialogView.layer.transform;

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        CGFloat startRotation = [[dialogView valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
        CATransform3D rotation = CATransform3DMakeRotation(-startRotation + M_PI * 270.0 / 180.0, 0.0f, 0.0f, 0.0f);

        dialogView.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1));
    }

    dialogView.layer.opacity = 1.0f;
    __block typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
					 animations:^{
						 weakSelf.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
                         weakSelf.dialogView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6f, 0.6f, 1.0));
                         weakSelf.dialogView.layer.opacity = 0.0f;
					 }
					 completion:^(BOOL finished) {
                         for (UIView *v in [self subviews]) {
                             [v removeFromSuperview];
                         }
                         [self removeFromSuperview];
					 }
	 ];
}

- (void)setSubView: (UIView *)subView
{
//    NSLog(@"subView: %@", NSStringFromCGRect(subView.frame));
    containerView = subView;
}

// Creates the container view here: create the dialog, then add the custom content and buttons
- (UIView *)createContainerView
{
    if ([buttonTitles count] > 0) {
//        NSLog(@"buttonTitles.count: %lu", (unsigned long)buttonTitles.count);
//        NSLog(@"buttonTitles.count is > 0");
        buttonHeight       = kCustomIOS7AlertViewDefaultButtonHeight;
        buttonSpacerHeight = kCustomIOS7AlertViewDefaultButtonSpacerHeight;
    } else {
//        NSLog(@"buttonTitles.count: %lu", (unsigned long)buttonTitles.count);
//        NSLog(@"buttonTitles.count is <= 0");
        buttonHeight = 0;
        buttonSpacerHeight = 0;
    }
    
    if (containerView == NULL) {
        containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 150)];
    }

    CGFloat dialogWidth = containerView.frame.size.width;
    //CGFloat dialogHeight = containerView.frame.size.height + (buttonHeight + buttonSpacerHeight) * [buttonTitles count];
    CGFloat dialogHeight = 0;
    
    if ([self.arrangeStyle isEqualToString: @"Horizontal"]) {
        dialogHeight = containerView.frame.size.height + (buttonHeight + buttonSpacerHeight) + 16;
    }
    if ([self.arrangeStyle isEqualToString: @"Vertical"]) {
        dialogHeight = containerView.frame.size.height + (buttonHeight + buttonSpacerHeight) * [buttonTitles count] + 16;
    }
    
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
//    NSLog(@"screenHeight: %f", screenHeight);
    
    CGSize screenSize = [self countScreenSize];
//    NSLog(@"screenSize: %@", NSStringFromCGSize(screenSize));
    
    CGSize dialogSize = [self countDialogSize];
//    NSLog(@"dialogSize: %@", NSStringFromCGSize(dialogSize));

    // For the black background
    //[self setFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    [self setFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
//    NSLog(@"self frame: %@", NSStringFromCGRect(self.frame));
    
    UIView *dialogContainer;
    
//    NSLog(@"");
//    NSLog(@"dialogSize.height: %f", dialogSize.height);
//    NSLog(@"dialogHeight: %f", dialogHeight);
//    NSLog(@"");
    
    // This is the dialog's container; we attach the custom content and the buttons to this one
    if ([buttonTitles count] == 1) {
        dialogContainer = [[UIView alloc] initWithFrame:CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height)];
    } else if ([buttonTitles count] > 1) {
        // dialogHeight + 10 => 10 is for the gap between upper view and the bottom button
        dialogContainer = [[UIView alloc] initWithFrame:CGRectMake((screenWidth - dialogWidth) / 2, (screenHeight - dialogHeight) / 2, dialogWidth, dialogHeight)];
    }
    
    // First, we style the dialog to match the iOS7 UIAlertView >>>
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = dialogContainer.bounds;
    /*
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[[UIColor colorWithRed:218.0/255.0 green:218.0/255.0 blue:218.0/255.0 alpha:1.0f] CGColor],
                       (id)[[UIColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:233.0/255.0 alpha:1.0f] CGColor],
                       (id)[[UIColor colorWithRed:218.0/255.0 green:218.0/255.0 blue:218.0/255.0 alpha:1.0f] CGColor],
                       nil];
     */
    
    gradient.backgroundColor = [UIColor whiteColor].CGColor;
    
    CGFloat cornerRadius = kCustomIOSAlertViewCornerRadius;
    gradient.cornerRadius = cornerRadius;
    [dialogContainer.layer insertSublayer:gradient atIndex:0];
    
    dialogContainer.layer.cornerRadius = cornerRadius;
    dialogContainer.layer.borderColor = [[UIColor colorWithRed:198.0/255.0 green:198.0/255.0 blue:198.0/255.0 alpha:1.0f] CGColor];
    dialogContainer.layer.borderWidth = 0;
    dialogContainer.layer.shadowRadius = cornerRadius + 5;
    dialogContainer.layer.shadowOpacity = 0.1f;
    dialogContainer.layer.shadowOffset = CGSizeMake(0 - (cornerRadius+5)/2, 0 - (cornerRadius+5)/2);
    dialogContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    dialogContainer.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:dialogContainer.bounds cornerRadius:dialogContainer.layer.cornerRadius].CGPath;
    
    // There is a line above the button
//    NSLog(@"Y-Axis: %f", dialogContainer.bounds.size.height - buttonHeight - buttonSpacerHeight);
//    NSLog(@"dialogContainer.bounds.size.height: %f", dialogContainer.bounds.size.height);
//    NSLog(@"buttonHeight: %f", buttonHeight);
//    NSLog(@"buttonSpacerHeight: %f", buttonSpacerHeight);
    
    /*
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, dialogContainer.bounds.size.height - buttonHeight - buttonSpacerHeight, dialogContainer.bounds.size.width, buttonSpacerHeight)];
    lineView.backgroundColor = [UIColor colorWithRed:198.0/255.0 green:198.0/255.0 blue:198.0/255.0 alpha:1.0f];
    [dialogContainer addSubview:lineView];
    // ^^^
    */
    
//    NSLog(@"");
//    NSLog(@"containerView.frame: %@", NSStringFromCGRect(containerView.frame));
//    
//    NSLog(@"containerView.frame.size.height: %f", containerView.frame.size.height);
//    NSLog(@"dialogHeight: %f", dialogHeight);
//    NSLog(@"dialogContainer.frame.size.height: %f", dialogContainer.frame.size.height);
//    NSLog(@"dialogSize.height: %f", dialogSize.height);
    CGRect rect = containerView.frame;
    rect.size.height = dialogHeight - 55;
    containerView.frame = rect;
    
//    NSLog(@"");
//    NSLog(@"containerView.frame: %@", NSStringFromCGRect(containerView.frame));
    
    // Add the custom container if there is any
    [dialogContainer addSubview:containerView];

    // Add the buttons too
    
    if (useImages) {
//        NSLog(@"use image for button");
        [self addImageButtonsToView: dialogContainer];
    } else {
//        NSLog(@"use text for button");
        [self addButtonsToView:dialogContainer];
    }

    return dialogContainer;
}

// Helper function: add buttons to container
- (void)addButtonsToView: (UIView *)container
{
    if (buttonTitles==NULL) { return; }

    CGFloat oneButtonWidth = container.bounds.size.width / [buttonTitles count];
    CGFloat buttonWidth = 116;
    
    if ([buttonTitles count] == 1) {
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [closeButton setFrame:CGRectMake(0, container.bounds.size.height - buttonHeight, oneButtonWidth, buttonHeight)];
        
        [closeButton addTarget:self action:@selector(customIOS7dialogButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setTag: 0];
        
        [closeButton setTitle:[buttonTitles objectAtIndex: 0] forState:UIControlStateNormal];
        [closeButton setTitleColor: [buttonTitlesColor objectAtIndex: 0] forState: UIControlStateNormal];
        [closeButton setTitleColor: [buttonTitlesHighlightColor objectAtIndex: 0] forState: UIControlStateHighlighted];
        
        //[closeButton setTitleColor:[UIColor colorWithRed:0.0f green:0.5f blue:1.0f alpha:1.0f] forState:UIControlStateNormal];
        //[closeButton setTitleColor:[UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.5f] forState:UIControlStateHighlighted];
        [closeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
        closeButton.titleLabel.numberOfLines = 0;
        closeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [closeButton.layer setCornerRadius:kCustomIOSAlertViewCornerRadius];
        
        [container addSubview:closeButton];
    } else if ([buttonTitles count] > 1) {
        if ([self.arrangeStyle isEqualToString: @"Horizontal"]) {
            for (int i=0; i<[buttonTitles count]; i++) {
                
                UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
                
                [closeButton setFrame:CGRectMake(22 + i * buttonWidth + 22 * i, container.bounds.size.height - buttonHeight - 10, buttonWidth, buttonHeight)];
//                NSLog(@"i: %d", i);
//                NSLog(@"closebutton: %@", NSStringFromCGRect(closeButton.frame));
                
                [closeButton addTarget:self action:@selector(customIOS7dialogButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
                [closeButton setTag:i];
                [closeButton setTitle:[buttonTitles objectAtIndex:i] forState:UIControlStateNormal];\
                
                //[closeButton setBackgroundColor: kCustomIOS7DefaultButtonColor];
                if([buttonColors count] > i && [buttonColors objectAtIndex:i])
                    [closeButton setBackgroundColor:[buttonColors objectAtIndex:i]];
                else
                    [closeButton setBackgroundColor:kCustomIOS7DefaultButtonColor];
                
                if ([buttonTitlesColor count] > i && [buttonTitlesColor objectAtIndex: i])
                {
                    [closeButton setTitleColor: [buttonTitlesColor objectAtIndex: i] forState: UIControlStateNormal];
                    [closeButton setTitleColor: [buttonTitlesHighlightColor objectAtIndex: i] forState: UIControlStateHighlighted];
                }
                
                else
                    [closeButton setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
                
                //[closeButton setTitleColor:[UIColor colorWithRed:0.0f green:0.5f blue:1.0f alpha:1.0f] forState:UIControlStateNormal];
                //[closeButton setTitleColor:[UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.5f] forState:UIControlStateHighlighted];
                [closeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
                closeButton.titleLabel.numberOfLines = 0;
                closeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
                //[closeButton.layer setCornerRadius:kCustomIOSAlertViewCornerRadius];
                [closeButton.layer setCornerRadius: 8];
                
                [container addSubview:closeButton];
            }
        }
        
        if ([self.arrangeStyle isEqualToString: @"Vertical"]) {
            for (int i = 0; i < [buttonTitles count]; i++)
            {
                UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
                
                [closeButton setFrame:CGRectMake(25, container.bounds.size.height - ([buttonTitles count] - i) * (buttonHeight + buttonSpacerHeight) - 7, self.containerView.bounds.size.width - 50, buttonHeight)];
                
                [closeButton addTarget:self action:@selector(customIOS7dialogButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
                [closeButton setTag:i];
                [closeButton setTitle:[buttonTitles objectAtIndex:i] forState:UIControlStateNormal];
                
                if([buttonColors count] > i && [buttonColors objectAtIndex:i])
                    [closeButton setBackgroundColor:[buttonColors objectAtIndex:i]];
                else
                    [closeButton setBackgroundColor:kCustomIOS7DefaultButtonColor];
                
                if ([buttonTitlesColor count] > i && [buttonTitlesColor objectAtIndex: i])
                {
                    [closeButton setTitleColor: [buttonTitlesColor objectAtIndex: i] forState: UIControlStateNormal];
                    [closeButton setTitleColor: [buttonTitlesHighlightColor objectAtIndex: i] forState: UIControlStateHighlighted];
                }
                
                else
                    [closeButton setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
                
                //[closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                //[closeButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
                [closeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
                [closeButton.layer setCornerRadius:kCustomIOS7AlertViewCornerRadius];
                
                [container addSubview:closeButton];
            }
        }
    }
    
    /*
    if ([buttonTitles count] > 2) {
        NSLog(@"buttonTitles.count: %d", buttonTitles.count);
        NSLog(@"buttonTitles.count > 2");
    } else {
        NSLog(@"buttonTitles.count: %d", buttonTitles.count);
        NSLog(@"buttonTitles.count <= 2");
    }
     */
}

// Helper function: add buttons to container
- (void)addImageButtonsToView: (UIView *)container
{
    NSLog(@"addButtonsToView img");
    
    if (buttonImages==NULL) { return; }
    
    CGFloat buttonWidth = container.bounds.size.width / [buttonImages count];
    
    for (int i=0; i<[buttonImages count]; i++) {
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [closeButton setFrame:CGRectMake(i * buttonWidth + 35, container.bounds.size.height - buttonHeight, 50, 50)];
        
        [closeButton addTarget:self action:@selector(customIOS7dialogButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setTag:i];
        
        //[closeButton setTitle:[buttonTitles objectAtIndex:i] forState:UIControlStateNormal];
        
        [closeButton setImage: [buttonImages objectAtIndex: i] forState: UIControlStateNormal];
        [closeButton setTitleColor:[UIColor colorWithRed:0.0f green:0.5f blue:1.0f alpha:1.0f] forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.5f] forState:UIControlStateHighlighted];
        [closeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
        [closeButton.layer setCornerRadius:kCustomIOSAlertViewCornerRadius];
        
        [container addSubview:closeButton];
    }
}


// Helper function: count and return the dialog's size
- (CGSize)countDialogSize
{
    CGFloat dialogWidth = containerView.frame.size.width;
    CGFloat dialogHeight = containerView.frame.size.height + buttonHeight + buttonSpacerHeight;

    return CGSizeMake(dialogWidth, dialogHeight);
}

// Helper function: count and return the screen's size
- (CGSize)countScreenSize
{
    if (buttonTitles!=NULL && [buttonTitles count] > 0) {
        buttonHeight       = kCustomIOSAlertViewDefaultButtonHeight;
        buttonSpacerHeight = kCustomIOSAlertViewDefaultButtonSpacerHeight;
    } else {
        buttonHeight = 0;
        buttonSpacerHeight = 0;
    }

    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;

    // On iOS7, screen width and height doesn't automatically follow orientation
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            CGFloat tmp = screenWidth;
            screenWidth = screenHeight;
            screenHeight = tmp;
        }
    }
    
    return CGSizeMake(screenWidth, screenHeight);
}

#if (defined(__IPHONE_7_0))
// Add motion effects
- (void)applyMotionEffects {

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        return;
    }

    UIInterpolatingMotionEffect *horizontalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
                                                                                                    type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalEffect.minimumRelativeValue = @(-kCustomIOS7MotionEffectExtent);
    horizontalEffect.maximumRelativeValue = @( kCustomIOS7MotionEffectExtent);

    UIInterpolatingMotionEffect *verticalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
                                                                                                  type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalEffect.minimumRelativeValue = @(-kCustomIOS7MotionEffectExtent);
    verticalEffect.maximumRelativeValue = @( kCustomIOS7MotionEffectExtent);

    UIMotionEffectGroup *motionEffectGroup = [[UIMotionEffectGroup alloc] init];
    motionEffectGroup.motionEffects = @[horizontalEffect, verticalEffect];

    [dialogView addMotionEffect:motionEffectGroup];
}
#endif

- (void)dealloc
{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];

    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    
}

// Rotation changed, on iOS7
- (void)changeOrientationForIOS7 {

    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    CGFloat startRotation = [[self valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
    CGAffineTransform rotation;
    
    switch (interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            rotation = CGAffineTransformMakeRotation(-startRotation + M_PI * 270.0 / 180.0);
            break;
            
        case UIInterfaceOrientationLandscapeRight:
            rotation = CGAffineTransformMakeRotation(-startRotation + M_PI * 90.0 / 180.0);
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
            rotation = CGAffineTransformMakeRotation(-startRotation + M_PI * 180.0 / 180.0);
            break;
            
        default:
            rotation = CGAffineTransformMakeRotation(-startRotation + 0.0);
            break;
    }
    __block typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         weakSelf.dialogView.transform = rotation;
                         
                     }
                     completion:nil
     ];
    
}

// Rotation changed, on iOS8
- (void)changeOrientationForIOS8: (NSNotification *)notification {

    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    __block typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         CGSize dialogSize = [weakSelf countDialogSize];
                         CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
                         weakSelf.frame = CGRectMake(0, 0, screenWidth, screenHeight);
                         weakSelf.dialogView.frame = CGRectMake((screenWidth - dialogSize.width) / 2, (screenHeight - keyboardSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
                     }
                     completion:nil
     ];
    

}

// Handle device orientation changes
- (void)deviceOrientationDidChange: (NSNotification *)notification
{
    // If dialog is attached to the parent view, it probably wants to handle the orientation change itself
    if (parentView != NULL) {
        return;
    }

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        [self changeOrientationForIOS7];
    } else {
        [self changeOrientationForIOS8:notification];
    }
}

// Handle keyboard show/hide changes
- (void)keyboardWillShow: (NSNotification *)notification
{
    CGSize screenSize = [self countScreenSize];
    CGSize dialogSize = [self countDialogSize];
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation) && NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) {
        CGFloat tmp = keyboardSize.height;
        keyboardSize.height = keyboardSize.width;
        keyboardSize.width = tmp;
    }
    __block typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
					 animations:^{
                         weakSelf.dialogView.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - keyboardSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
					 }
					 completion:nil
	 ];
}

- (void)keyboardWillHide: (NSNotification *)notification
{
    CGSize screenSize = [self countScreenSize];
    CGSize dialogSize = [self countDialogSize];
    __block typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
					 animations:^{
                         weakSelf.dialogView.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
					 }
					 completion:nil
	 ];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!closeOnTouchUpOutside) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    if ([touch.view isKindOfClass:[CustomIOSAlertView class]]) {
        [self close];
    }
}

@end
