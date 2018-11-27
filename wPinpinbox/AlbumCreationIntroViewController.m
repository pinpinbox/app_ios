//
//  AlbumCreationIntroViewController.m
//  wPinpinbox
//
//  Created by Antelis on 2018/11/26.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "AlbumCreationIntroViewController.h"
#import "InfoBubbleView.h"

@interface IntroPresentationController ()
@property (nonatomic) UIVisualEffectView *dimmyView;
@end

@interface IntroAnimationTransitioning()
@property (nonatomic) BOOL isPresenting;
@end

@interface AlbumCreationIntroViewController ()
@property (nonatomic) IBOutlet InfoBubbleView *step1Intro;
@property (nonatomic) IBOutlet InfoBubbleView *step2Intro;
@property (nonatomic) IBOutlet InfoBubbleView *step3Intro;
@property (nonatomic) CGRect step1Rect;
@property (nonatomic) CGRect step2Rect;
@property (nonatomic) CGRect step3Rect;
@property (nonatomic) IBOutlet UIButton *proceedBtn;
- (void)startAnimationSequence;
@end

@implementation IntroPresentationController
- (void)presentationTransitionDidEnd:(BOOL)completed {
    
    AlbumCreationIntroViewController *p = (AlbumCreationIntroViewController *)self.presentedViewController;
    [p startAnimationSequence];
}
@end
@implementation IntroAnimationTransitioning
- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    AlbumCreationIntroViewController *to = (AlbumCreationIntroViewController *) [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    [to setNeedsStatusBarAppearanceUpdate];
    __block BOOL ispresent = self.isPresenting;
    if (!ispresent) {
        to = (AlbumCreationIntroViewController *) [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        //to.view.transform = CGAffineTransformIdentity;
        to.view.alpha = 1;
    } else {
        //to.view.transform = CGAffineTransformMakeTranslation(0, 325);
        to.view.alpha = 0;
        [transitionContext.containerView addSubview:to.view];
    }
    
    [UIView animateWithDuration: [self transitionDuration:transitionContext]
                          delay:0.0
         usingSpringWithDamping:1.0
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveLinear animations:^{
                            
                            if (ispresent)
                                to.view.alpha = 1;
                            else
                                to.view.alpha = 0;
                            
                        } completion:^(BOOL finished) {
                            [transitionContext completeTransition:finished];
                        }];
    
}
    
    
@end


@implementation AlbumCreationIntroViewController
- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.transitioningDelegate = self;
    self.modalPresentationCapturesStatusBarAppearance = YES;
    
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *t = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToDismiss:)];
    [self.view addGestureRecognizer:t];
    self.proceedBtn.layer.borderColor = [UIColor lightTextColor].CGColor;
    CGRect t1 = CGRectMake(0.5, 1, self.proceedBtn.frame.size.width, self.proceedBtn.frame.size.height);//CGRectOffset(self.proceedBtn.frame,0.5,1);
    UIView *base = [[UIView alloc] initWithFrame:t1];
    base.backgroundColor = [UIColor clearColor];
    [self.proceedBtn addSubview:base];
    [self.proceedBtn sendSubviewToBack:base];
    base.layer.cornerRadius = t1.size.height/2;
    base.layer.borderColor = [UIColor darkGrayColor].CGColor;
    base.layer.borderWidth = 1;
    _proceedBtn.hidden = YES;
}
- (void)tapToDismiss:(UITapGestureRecognizer *)tap {
    [self dismissViewControllerAnimated:YES completion:nil];
    [[NSUserDefaults standardUserDefaults] setObject:@"finished" forKey:@"editorIntro"];
}

- (void)updateInfoBubble:(InfoBubbleView *)bubble withRect:(CGRect)rect {
    CGSize s = bubble.frame.size;
    switch (bubble.tipPosition) {
        case InfoBubbleTipTopLeft: {
            bubble.frame = CGRectMake(rect.origin.x, rect.origin.y+rect.size.height-10, s.width, s.height);
        }
            break;
        case InfoBubbleTipTopRight:
            bubble.frame = CGRectMake(rect.origin.x+rect.size.width-s.width, rect.origin.y+rect.size.height-10, s.width, s.height);
            break;
        case InfoBubbleTipBottomLeft:
            bubble.frame = CGRectMake(rect.origin.x, rect.origin.y-s.height+10, s.width, s.height);
            break;
        case InfoBubbleTipBottomRight:
            bubble.frame = CGRectMake(rect.origin.x+rect.size.width-s.width, rect.origin.y-s.height+10, s.width, s.height);
            break;
    }
}
- (void)setStep1Rect:(CGRect) rect1 step2Rect:(CGRect)rect2 step3Rect:(CGRect)rect3 {
    self.step1Intro.tipPosition = InfoBubbleTipBottomLeft;
    self.step2Intro.tipPosition = InfoBubbleTipTopRight;
    self.step3Intro.tipPosition = InfoBubbleTipTopRight;
    self.step1Rect = CGRectOffset(rect1, 0, -20);
    [self updateInfoBubble:self.step1Intro withRect:self.step1Rect];
    self.step2Rect = CGRectOffset(rect2, 0, 0);//-20);
    [self updateInfoBubble:self.step2Intro withRect:self.step2Rect];
    self.step3Rect = CGRectOffset(rect3, 0, 0);//-20);
    [self updateInfoBubble:self.step3Intro withRect:self.step3Rect];
    
}
- (void)setItemMask:(CGRect)rect bubbleView:(InfoBubbleView *)bubble {
    
//    self.step1Intro.hidden = YES;
//    self.step2Intro.hidden = YES;
//    self.step3Intro.hidden = YES;
    
    UIBezierPath *p = [UIBezierPath bezierPathWithOvalInRect:rect];
    [p setUsesEvenOddFillRule:YES];
    
    CAShapeLayer *mask = self.view.layer.mask;
    if (!mask) {
        mask = [[CAShapeLayer alloc] init];
        [self.view.layer setMask:mask];
        [mask setBackgroundColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.6].CGColor];
    }
    
    CGMutablePathRef maskPath = CGPathCreateMutable();
    CGPathAddRect(maskPath, NULL, self.view.frame);
    CGPathAddPath(maskPath, NULL, p.CGPath);
    
    mask.fillRule =  kCAFillRuleEvenOdd;
    
    [mask setPath:maskPath];
    bubble.alpha = 1;
    
    
}
- (void)animSequenceFinished {
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:0.0 options:0 animations:^{
        self.step3Intro.hidden = YES;
        self.proceedBtn.hidden = NO;
        self.view.layer.mask = nil;
    } completion:nil];
}
- (void)animSequence3 {
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:0.0 options:0 animations:^{
        self.step2Intro.hidden = YES;
        [self setItemMask:self.step3Rect bubbleView:self.step3Intro];
    } completion:^(BOOL finished) {
      [self performSelector:@selector(animSequenceFinished) withObject:nil afterDelay:0.5];
    }];
    //
}
- (void)animSequence2 {
    [UIView animateWithDuration:0.75 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:0.0 options:0 animations:^{
        self.step1Intro.hidden = YES;
        [self setItemMask:self.step2Rect bubbleView:self.step2Intro];
    } completion:^(BOOL finished) {
        [self performSelector:@selector(animSequence3) withObject:nil afterDelay:0.5];
    }];

}
- (void)startAnimationSequence {
    
    [UIView animateWithDuration:0.75 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:0.0 options:0 animations:^{
        [self setItemMask:self.step1Rect bubbleView:self.step1Intro];
        
    } completion:^(BOOL finished) {
        [self performSelector:@selector(animSequence2) withObject:nil afterDelay:0.7];
    }];
//    [UIView animateKeyframesWithDuration:5 delay:0.2 options:UIViewKeyframeAnimationOptionBeginFromCurrentState animations:^{
//
//        [UIView addKeyframeWithRelativeStartTime:0.1 relativeDuration:0.2 animations:^{
//
//        }];
//        [UIView addKeyframeWithRelativeStartTime:0.4 relativeDuration:0.2 animations:^{
//            sself.step1Intro.hidden = YES;
//            [sself setItemMask:sself.step2Rect bubbleView:sself.step2Intro];
//        }];
//        [UIView addKeyframeWithRelativeStartTime:0.7 relativeDuration:0.2 animations:^{
//            sself.step2Intro.hidden = YES;
//            [sself setItemMask:sself.step3Rect bubbleView:sself.step3Intro];
//        }];
//
//    } completion:^(BOOL finished) {
//
//    }];
    
}
#pragma mark UIViewControllerTransitioningDelegat functions
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    IntroAnimationTransitioning *at = [[IntroAnimationTransitioning alloc] init];
    at.isPresenting = YES;
    return at;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    IntroAnimationTransitioning *at = [[IntroAnimationTransitioning alloc] init];
    at.isPresenting = NO;
    return at;
}
- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(nullable UIViewController *)presenting sourceViewController:(UIViewController *)source {
    
    return [[IntroPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

@end
