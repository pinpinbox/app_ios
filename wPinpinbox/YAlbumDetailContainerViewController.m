//
//  YAlbumDetailContainerViewController.m
//  wPinpinbox
//
//  Created by Antelis on 2019/1/8.
//  Copyright © 2019 Angus. All rights reserved.
//

#import "YAlbumDetailContainerViewController.h"
#import "YAlbumDetailViewController.h"
#import "AppDelegate.h"


// VC transition animation controller
@interface ZoomAnimator : NSObject <UIViewControllerAnimatedTransitioning>
@property(weak, nonatomic) id<ZoomTransitionDelegate> fromDelegate;
@property(weak, nonatomic) id<ZoomTransitionDelegate> toDelegate;
//  temp cell image
@property(nonatomic) UIImageView *transitionImageView;
@property(nonatomic) BOOL isPresenting;
- (void)animateZoomInTransition:(id<UIViewControllerContextTransitioning>) transitionContext;
- (void)animateZoomOutTransition:(id<UIViewControllerContextTransitioning>) transitionContext;
@end

// VC Transition with user interaction, pan or drag
@interface  ZoomDismissalInteractionController : NSObject <UIViewControllerInteractiveTransitioning>
@property(nonatomic) id<UIViewControllerContextTransitioning> __nullable transitionContext;
@property(nonatomic) id<UIViewControllerAnimatedTransitioning> animator;
@property(nonatomic) BOOL isEasyOut; //  TRUE: dismiss by right-to-left pan, FALSE: drag down to dismiss
@property(nonatomic) CGRect fromReferenceImageViewFrame;
@property(nonatomic) CGRect toReferenceImageViewFrame;
@end

@interface YAlbumDetailVCTransitionController : NSObject <UINavigationControllerDelegate, UIViewControllerTransitioningDelegate>
@property(nonatomic) BOOL isInteractive; //  TRUE: Using pan / drag to dismiss, FALSE: controlled by zoom in/ zoom out effect
@property(nonatomic) BOOL isEasyOut; //  TRUE: dismiss by right-to-left pan, FALSE: drag down to dismiss
@property(nonatomic) ZoomAnimator *animator;
@property(nonatomic) ZoomDismissalInteractionController *interactionController;
@property(weak, nonatomic) id<ZoomTransitionDelegate> fromDelegate;
@property(weak, nonatomic) id<ZoomTransitionDelegate> toDelegate;

@end

@interface YAlbumDetailContainerViewController ()<UIGestureRecognizerDelegate>
@property (nonatomic) UIPanGestureRecognizer *pangesture;
@property (nonatomic) NSDictionary *info;
@end

#pragma mark -
@implementation ZoomAnimator
- (CGRect)calculateZoomedFrame:(UIImage *)sourceimage forView:(UIView *)view {
    if (sourceimage) {
        CGFloat viewratio = view.frame.size.width/sourceimage.size.width;
        CGFloat h = sourceimage.size.height*viewratio;
        
        return CGRectMake(0, 0, view.frame.size.width, h);
        
    }
    
    return CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    
}
//  Transition to present AlbumDetail
- (void)animateZoomInTransition:(id<UIViewControllerContextTransitioning>) transitionContext {
    UIView *v = transitionContext.containerView;
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIImageView *sourceImageView = [self.fromDelegate sourceImageView:self];
    UIImageView *destImageView = [self.toDelegate referenceImageView:self];
    CGRect source = [self.fromDelegate sourceImageViewFrameInTransitioningView:self];
    
    if (!fromVC || !toVC) return;
    
    
    destImageView.hidden = YES;
    [v addSubview:toVC.view];
    //  VC transition without source image //
    if (sourceImageView == nil) {
        self.transitionImageView = nil;
        toVC.view.transform = CGAffineTransformMakeTranslation(0, toVC.view.frame.size.height);
        toVC.view.alpha = 1;
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0
             usingSpringWithDamping:0.8 initialSpringVelocity:0
                            options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                                toVC.view.transform = CGAffineTransformIdentity;
                            } completion:^(BOOL finished) {
                                if (self.transitionImageView) {
                                    self.transitionImageView.alpha = 0;
                                    [self.transitionImageView removeFromSuperview];
                                    sourceImageView.hidden = NO;
                                }
                                destImageView.hidden = NO;
                                
                                [transitionContext completeTransition:YES];
                                [self.toDelegate transitionDidEndWith: self];
                                
                            }];
    } else {
        // VC transition with source image//
        toVC.view.alpha = 0;
        // but it might be nil (remote loading failure...)
        UIImage *img = sourceImageView.image;
        if (!self.transitionImageView) {
            if (img)
                self.transitionImageView = [[UIImageView alloc] initWithImage:img];
            else
                self.transitionImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_2_0_0_no_image"]];
            self.transitionImageView.contentMode = UIViewContentModeScaleAspectFill;
            self.transitionImageView.clipsToBounds = YES;
            self.transitionImageView.frame = source;
        }
        [v addSubview : self.transitionImageView];
        sourceImageView.hidden = YES;
        
        CGRect finalresult =[self calculateZoomedFrame:img forView:destImageView];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0
             usingSpringWithDamping:0.8 initialSpringVelocity:0
                            options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                                self.transitionImageView.frame = finalresult;
                                toVC.view.alpha = 1.0;
                                
                            } completion:^(BOOL finished) {
                                self.transitionImageView.alpha = 0;
                                [self.transitionImageView removeFromSuperview];
                                sourceImageView.hidden = NO;
                                destImageView.hidden = NO;
                                
                                [transitionContext completeTransition:YES];
                                [self.toDelegate transitionDidEndWith: self];
                                
                            }];
    }
}
//  Transition to dismiss AlbumDetail by pressing dismiss button
- (void)animateZoomOutTransition:(id<UIViewControllerContextTransitioning>) transitionContext {
    
    UIView *v = transitionContext.containerView;
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIImageView *sourceImageView = [self.fromDelegate referenceImageView:self];
    CGRect source = [self.fromDelegate referenceImageViewFrameInTransitioningView:self];
    CGRect dest = [self.fromDelegate sourceImageViewFrameInTransitioningView:self];
    
    UIImage *referenceImage = sourceImageView.image;
    
    if (self.transitionImageView == nil) {
        self.transitionImageView = [[UIImageView alloc] initWithImage:referenceImage];
        self.transitionImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.transitionImageView.clipsToBounds = YES;
        self.transitionImageView.frame = source;
    }
    self.transitionImageView.alpha = 1;
    [v addSubview : self.transitionImageView];
    
    [v insertSubview:toVC.view belowSubview:fromVC.view];
    
    sourceImageView.hidden = YES;
    [v bringSubviewToFront:self.transitionImageView];
    [UIView animateWithDuration:0.3 delay:0 options:0 animations:^{
        self.transitionImageView.frame = dest;
        fromVC.view.alpha = 0;
        toVC.view.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        [self.transitionImageView removeFromSuperview];
        [transitionContext completeTransition:YES];
        [self.toDelegate transitionDidEndWith:self];
    }];
}
//  Duration for presenting / dismiss transition animation
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    if (self.isPresenting)
        return 0.5;
    return 0.75;
}
//  triggering VC transition animation
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    if (self.isPresenting)
        [self animateZoomInTransition:transitionContext];
    else
        [self animateZoomOutTransition:transitionContext];
}
@end
#pragma mark - VC Transition with user interaction, pan or drag
@implementation ZoomDismissalInteractionController

- (void)startInteractiveTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
    self.transitionContext = transitionContext;
    UIView *containerView = transitionContext.containerView;
    ZoomAnimator *animator = self.animator;
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    [containerView insertSubview:toVC.view belowSubview:fromVC.view];
    
    if (self.isEasyOut) {
        animator.transitionImageView.alpha = 0;
        if (animator.transitionImageView)
            [animator.transitionImageView removeFromSuperview];
        return;
    } else {
        animator.transitionImageView.alpha = 1;
    }
    
    
    self.fromReferenceImageViewFrame = [animator.fromDelegate referenceImageViewFrameInTransitioningView:animator];
    self.toReferenceImageViewFrame = [animator.toDelegate sourceImageViewFrameInTransitioningView:animator];
    UIImageView *fromImage = [animator.fromDelegate referenceImageView:animator];
    
    UIImage *reference = fromImage.image;
    
    if (animator.transitionImageView == nil) {
        animator.transitionImageView = [[UIImageView alloc] initWithImage:reference];
        animator.transitionImageView.contentMode = UIViewContentModeScaleAspectFill;
    } else {
        animator.transitionImageView.image = reference;
    }
    animator.transitionImageView.transform = CGAffineTransformIdentity;
    animator.transitionImageView.clipsToBounds = YES;
    animator.transitionImageView.frame = self.fromReferenceImageViewFrame;
    
    [containerView addSubview : animator.transitionImageView];
    
}

- (void)didPanWith:(UIPanGestureRecognizer *)gestureRecognizer {
    
    
    UIViewController *fromVC = [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if (!fromVC || !toVC) return;
    
    if (self.isEasyOut) {
        [self panDismissWithGesture:gestureRecognizer];
    } else {
        [self dragDismissWithGesture:gestureRecognizer];
    }
}
//  moving the whole view by pan
- (void)panDismissWithGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    
    ZoomAnimator *animator = self.animator;
    animator.transitionImageView.alpha = 0;
    UIViewController *fromVC = [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGPoint translatedPoint = [gestureRecognizer translationInView:fromVC.view];
    CGFloat delta = translatedPoint.x > 0 ? 0 : translatedPoint.x;
//    if (translatedPoint.x > 0) {
//        delta = 0-(arc4random()%5+1);
//        NSLog(@"right pan %f,%f",translatedPoint.x,translatedPoint.y);
//        return;
//
//    }
    
    CGFloat alpha = [self backgroundAlphForEasyOut:fromVC.view withPanningVerticalDelta:delta];
    toVC.view.alpha = 1-alpha;
    
    fromVC.view.transform = CGAffineTransformMakeTranslation(delta,0);//translatedPoint.x, 0);
    
    [self.transitionContext updateInteractiveTransition:(1-alpha) ];
    CGFloat dx = fabs(translatedPoint.x);
    switch(gestureRecognizer.state ) {
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled: {
            
            CGFloat width = fromVC.view.frame.size.width;
            
            [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                fromVC.view.transform = CGAffineTransformMakeTranslation(-width, 0);
                toVC.view.alpha = 1.0;
            } completion:^(BOOL finished) {
                
                [animator.transitionImageView removeFromSuperview];
                //animator.transitionImageView = nil;
                [self.transitionContext finishInteractiveTransition];
                [self.transitionContext completeTransition:YES];
                [animator.toDelegate transitionDidEndWith:animator];
                self.transitionContext = nil;
                
            }];
            
            break;
        }
        case UIGestureRecognizerStateEnded: {
            CGPoint v = [gestureRecognizer velocityInView:fromVC.view];
            // canceled
            if (v.x > 0 || dx < (fromVC.view.frame.size.width/2)) {
                
                [UIView animateWithDuration:[self.animator transitionDuration:self.transitionContext] delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                    fromVC.view.transform = CGAffineTransformIdentity;
                    
                } completion:^(BOOL finished) {
                    
                    [animator.transitionImageView removeFromSuperview];
                    toVC.view.alpha = 1;
                    self.isEasyOut = NO;
                    [self.transitionContext cancelInteractiveTransition];
                    [self.transitionContext completeTransition:NO];
                    [animator.toDelegate transitionDidEndWith:animator];
                    self.transitionContext = nil;
                }];
                return;
            }
            
            CGFloat width = fromVC.view.frame.size.width;
            
            [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                fromVC.view.transform = CGAffineTransformMakeTranslation(-width, 0);
                toVC.view.alpha = 1.0;
            } completion:^(BOOL finished) {
                
                [animator.transitionImageView removeFromSuperview];
                //animator.transitionImageView = nil;
                [self.transitionContext finishInteractiveTransition];
                [self.transitionContext completeTransition:YES];
                [animator.toDelegate transitionDidEndWith:animator];
                self.transitionContext = nil;
                
            }];
            
            break;
        }
        default:{
            
        }
    }
}
//  dragging the header image with scale & alpha
- (void)dragDismissWithGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    
    ZoomAnimator *animator = self.animator;
    animator.transitionImageView.alpha = 1;
    
    UIViewController *fromVC = [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect sourceFrame = [animator.fromDelegate referenceImageViewFrameInTransitioningView:animator];
    CGRect destFrame = [animator.toDelegate sourceImageViewFrameInTransitioningView:animator];
    UIImageView *fromImage = [animator.fromDelegate referenceImageView:animator];
    UIImageView *sourceImage = [animator.fromDelegate sourceImageView:animator];
    
    sourceImage.hidden = YES;
    
    CGPoint anchor = CGPointMake(CGRectGetMidX(sourceFrame),CGRectGetMidY(sourceFrame) );
    CGPoint translatedPoint = [gestureRecognizer translationInView:sourceImage];
    
    //  when landscape mode?
    CGFloat verticaldelta = translatedPoint.y < 0 ? 0 : translatedPoint.y;
    
    CGFloat alpha = [self backgroundAlphFor:fromVC.view withPanningVerticalDelta:verticaldelta];
    CGFloat scale = [self scaleFor:fromVC.view withPanningVerticalDelta:verticaldelta];
    //NSLog(@"alpha %f, scale %f ,%f",alpha, scale,translatedPoint.y);
    fromVC.view.alpha = alpha;
    UIImageView *transitionImageView = animator.transitionImageView;
    transitionImageView.transform = CGAffineTransformMakeScale(scale, scale);
    CGPoint newCenter = CGPointMake(anchor.x+translatedPoint.x, anchor.y+translatedPoint.y - transitionImageView.frame.size.height*(1-scale)/2.0);
    transitionImageView.center = newCenter;
    
    sourceImage.hidden = YES;
    [self.transitionContext updateInteractiveTransition:(1-scale) ];
    
    switch(gestureRecognizer.state ) {
        case UIGestureRecognizerStateEnded: {
            CGPoint v = [gestureRecognizer velocityInView:fromVC.view];
            // canceled
            if (v.y < 0 || newCenter.y < anchor.y) {
                [UIView animateWithDuration:[self.animator transitionDuration:self.transitionContext] delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                    transitionImageView.frame = sourceFrame;
                    fromVC.view.alpha = 1.0;
                    
                } completion:^(BOOL finished) {
                    sourceImage.hidden = NO;
                    fromImage.hidden = NO;
                    [animator.transitionImageView removeFromSuperview];
                    //animator.transitionImageView = nil;
                    [self.transitionContext cancelInteractiveTransition];
                    [self.transitionContext completeTransition:NO];
                    [animator.toDelegate transitionDidEndWith:animator];
                    self.transitionContext = nil;
                }];
                return;
            }
            
            
            [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                fromVC.view.alpha = 0;
                transitionImageView.frame = destFrame;
                transitionImageView.layer.cornerRadius = 6;
                transitionImageView.alpha = 0.8;
                toVC.view.alpha = 1.0;
            } completion:^(BOOL finished) {
                sourceImage.hidden = NO;
                fromImage.hidden = NO;
                [animator.transitionImageView removeFromSuperview];
                //animator.transitionImageView = nil;
                [self.transitionContext finishInteractiveTransition];
                [self.transitionContext completeTransition:YES];
                [animator.toDelegate transitionDidEndWith:animator];
                self.transitionContext = nil;
                
            }];
            
            break;
        }
        default:{
            
        }
    }
    
}
//  calculating alpha of toVC for pan-dismiss
- (CGFloat)backgroundAlphForEasyOut:(UIView *)view withPanningVerticalDelta:(CGFloat)delta {
    
    CGFloat startingAlpha = 1.0, finalAlpha = 0, totalAvailableAlpha = startingAlpha - finalAlpha;
    CGFloat maximumDelta = view.bounds.size.width / 2.0;
    CGFloat deltaAsPercentageOfMaximun = fmin( fabs(delta) / maximumDelta , 1.0);
    return startingAlpha - (deltaAsPercentageOfMaximun * totalAvailableAlpha);
}
//  calculating alpha of toVC & fromVC for drag-dismiss
- (CGFloat)backgroundAlphFor:(UIView *)view withPanningVerticalDelta:(CGFloat)delta {
    
    CGFloat startingAlpha = 1.0, finalAlpha = 0, totalAvailableAlpha = startingAlpha - finalAlpha;
    CGFloat maximumDelta = view.bounds.size.height / 2.0;
    CGFloat deltaAsPercentageOfMaximun = fmin( fabs(delta) / maximumDelta , 1.0);
    return startingAlpha - (deltaAsPercentageOfMaximun * totalAvailableAlpha);
}
//  calculating scale of transitionImageView
- (CGFloat)scaleFor:(UIView *)view withPanningVerticalDelta:(CGFloat)delta {

    CGFloat startingScale = 1.0, finalScale = 0.5,
    totalAvailableScale = startingScale - finalScale;
    
    CGFloat maximumDelta = view.bounds.size.height / 2.0;
    CGFloat deltaAsPercentageOfMaximun = fmin(fabs(delta) / maximumDelta, 1.0);
    
    return startingScale - (deltaAsPercentageOfMaximun * totalAvailableScale);
}

@end
#pragma mark -
@implementation YAlbumDetailVCTransitionController
- (id)init {
    self = [super init];
    if (self) {
        self.isEasyOut = NO;
        self.animator = [[ZoomAnimator alloc] init];
        self.interactionController = [[ZoomDismissalInteractionController alloc] init];
    }
    return self;
}
- (void)didPanWith:(UIPanGestureRecognizer *)pan {
    self.interactionController.isEasyOut = self.isEasyOut;
    [self.interactionController didPanWith:pan];
}
//  UINavigationControllerDelegate
- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController {
    if (!self.isInteractive) {
        return nil;
    }
    
    self.interactionController.animator = self.animator;
    return self.interactionController;
}
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSLog(@"didShowViewController %@",viewController);
}

- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC {
    
    if (operation == UINavigationControllerOperationPush) {
        self.animator.isPresenting = YES;
        self.animator.fromDelegate = self.fromDelegate;
        self.animator.toDelegate = self.toDelegate;
    } else {
        self.animator.isPresenting = NO;
        self.animator.fromDelegate = self.fromDelegate;
        self.animator.toDelegate = self.toDelegate;
    }
    return self.animator;
}

//  UIViewControllerTransitioningDelegate
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.animator.isPresenting = YES;
    self.animator.fromDelegate = self.fromDelegate;
    self.animator.toDelegate = self.toDelegate;
    
    return self.animator;
    
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    
    self.animator.isPresenting = NO;
    self.animator.fromDelegate = self.fromDelegate;
    self.animator.toDelegate = self.toDelegate;
    return self.animator;
}


- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    
    if (!self.isInteractive) {
        return nil;
    }
    
    self.interactionController.animator = animator;
    return self.interactionController;
}

@end



#pragma mark -
@implementation YAlbumDetailContainerViewController

#pragma mark
+ (YAlbumDetailContainerViewController *)albumDetailVCWithAlbumID:(NSString *)albumid
                                                        albumInfo:(NSDictionary * _Nullable )albumInfo {
    
    YAlbumDetailContainerViewController *aDVC = [[UIStoryboard storyboardWithName: @"AlbumDetailVC" bundle: nil] instantiateViewControllerWithIdentifier: @"YAlbumDetailContainerViewController"];
    if ( !albumid) {
        @throw [NSException exceptionWithName:@"Invalid Parameter" reason:@"Parameter \"album id\" is empty" userInfo:nil];
        return nil;
    }
        
    aDVC.info = albumInfo;
    aDVC.sourceRect = CGRectZero;
    aDVC.album_id = albumid;
    aDVC.sourceView = nil;
    aDVC.zoomTransitionController.toDelegate = aDVC;
    aDVC.zoomTransitionController.fromDelegate = aDVC;
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.delegate = aDVC.zoomTransitionController;
    
    return aDVC;
}

+ (YAlbumDetailContainerViewController *)albumDetailVCWithAlbumID:(NSString *)albumid
                                                        albumInfo:(NSDictionary *)albumInfo
                                                       sourceRect:(CGRect)sourceRect
                                                  sourceImageView:(UIImageView * _Nullable )sourceImageView {
    if ( !albumid) {
        @throw [NSException exceptionWithName:@"Invalid Parameter" reason:@"Parameter \"album id\" is empty" userInfo:nil];
        return nil;
    }
    YAlbumDetailContainerViewController *aDVC = [[UIStoryboard storyboardWithName: @"AlbumDetailVC" bundle: nil] instantiateViewControllerWithIdentifier: @"YAlbumDetailContainerViewController"];
    aDVC.info = albumInfo;

    aDVC.sourceRect = sourceRect;
    aDVC.album_id = albumid;
    aDVC.sourceView = sourceImageView;
    aDVC.zoomTransitionController.toDelegate = aDVC;
    aDVC.zoomTransitionController.fromDelegate = aDVC;
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.delegate = aDVC.zoomTransitionController;
    
    return aDVC;
}
+ (YAlbumDetailContainerViewController *)albumDetailVCWithAlbumID:(NSString *)albumid
                                                       sourceRect:(CGRect)sourceRect
                                                  sourceImageView:(UIImageView *)sourceImageView
                                                          noParam:(BOOL)noParam {
    if ( !albumid) {
        @throw [NSException exceptionWithName:@"Invalid Parameter" reason:@"Parameter \"album id\" is empty" userInfo:nil];
        return nil;
    }
    
    YAlbumDetailContainerViewController *aDVC = [[UIStoryboard storyboardWithName: @"AlbumDetailVC" bundle: nil] instantiateViewControllerWithIdentifier: @"YAlbumDetailContainerViewController"];
    
    aDVC.sourceRect = sourceRect;
    aDVC.album_id = albumid;
    aDVC.noparam = noParam;
    aDVC.sourceView = sourceImageView;
    aDVC.zoomTransitionController.toDelegate = aDVC;
    aDVC.zoomTransitionController.fromDelegate = aDVC;
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.delegate = aDVC.zoomTransitionController;
    
    return aDVC;
    
}
#pragma mark

- (void)awakeFromNib {
    [super awakeFromNib];
    if (!self.zoomTransitionController) {
        _noparam = NO;
        self.zoomTransitionController = [[YAlbumDetailVCTransitionController alloc] init];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.zoomTransitionController) {
        _noparam = NO;
        self.zoomTransitionController = [[YAlbumDetailVCTransitionController alloc] init];
        
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"embedAlbumDetail"] ) {
        self.currentDetailVC = (YAlbumDetailViewController *)segue.destinationViewController;
        if (self.info)
            [self.currentDetailVC setupAlbumWithInfo:self.info albumId:self.album_id];
        self.currentDetailVC.noparam = self.noparam;
        self.currentDetailVC.fromVC = self.fromVC;
        self.pangesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanWith:)];
        self.pangesture.delegate = self;
        [self.currentDetailVC.view addGestureRecognizer:self.pangesture];
        
        //UITapGestureRecognizer *btntap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapDismiss:)];
        //[self.currentDetailVC.dismissBtn addGestureRecognizer:btntap];
        [self.currentDetailVC.dismissBtn addTarget:self action:@selector(didTapDismiss:) forControlEvents:UIControlEventTouchUpInside];
    }
}
#pragma mark -
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *p = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint location = [p locationInView:self.view];
        
        CGPoint velocity = [p velocityInView:self.view];
        if (velocity.y < 0) return ![self.currentDetailVC isPointInHeader:location];
        //  do nothing when messageboard or actionsheet is visible //
        return [self.currentDetailVC isPanValid];
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if (otherGestureRecognizer == self.currentDetailVC.baseView.panGestureRecognizer) {
        if (self.currentDetailVC.baseView.contentOffset.y == 0) {
            return YES;
        }
    }
    
    return NO;
}
- (void)didTapDismiss:(id)sender {//:(UITapGestureRecognizer *)tap {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.delegate = self.zoomTransitionController;
    [appDelegate.myNav popViewControllerAnimated:YES];
    
}
- (void)didPanWith:(UIPanGestureRecognizer *) gestureRecognizer {
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            CGPoint an = [gestureRecognizer locationInView:self.currentDetailVC.view];
            CGPoint delta = [gestureRecognizer velocityInView:self.currentDetailVC.view];
            
            //  check wheather drag-to-dismiss (isEasyOut == false) or pan-to-dismiss (isEasyOut == true) //
            if (fabs(delta.x) > fabs(delta.y)) {
                
                // simply a left to right horizontal pan, do nothing
                if (delta.x > 0) return ;
                
                self.zoomTransitionController.isEasyOut = YES;
            } else {
                BOOL inHeader = [self.currentDetailVC isPointInHeader:an];
                if (delta.y < 0 && !inHeader) return;
                self.zoomTransitionController.isEasyOut = !inHeader;
            }
            self.currentDetailVC.baseView.scrollEnabled = NO;
            self.zoomTransitionController.isInteractive = YES;
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            appDelegate.myNav.delegate = self.zoomTransitionController;
            [appDelegate.myNav popViewControllerAnimated:YES];
            
            break;
        }
        case UIGestureRecognizerStateFailed :
        case UIGestureRecognizerStateCancelled : {
            self.currentDetailVC.baseView.scrollEnabled = YES;
            break;
        }
         case UIGestureRecognizerStateEnded: {
             self.currentDetailVC.baseView.scrollEnabled = YES;
             if (self.zoomTransitionController.isInteractive) {
                 
                 self.zoomTransitionController.isInteractive = NO;
                 [self.zoomTransitionController didPanWith:gestureRecognizer];
        }
             break;
         }
        default: {
            if (self.zoomTransitionController.isInteractive) {
                [self.zoomTransitionController didPanWith:gestureRecognizer];
            }
        }
    }
}
#pragma mark
- (void)transitionWillStartWith:(ZoomAnimator *)zoomAnimator {
    
}
- (void)transitionDidEndWith:(ZoomAnimator *)zoomAnimator {
    if (zoomAnimator.isPresenting) {
        [wTools setStatusBarBackgroundColor: [UIColor clearColor]];
        //  load album detail
        if (self.sourceView)
            [self.currentDetailVC setHeaderPlaceholder:self.sourceView.image];
        
        //  Sometimes preVC would get albumdata first instead of querying albumdata in albumdetailVC
        if (self.info)
            [self.currentDetailVC setupAlbumWithInfo:self.info albumId:self.album_id];
        else
            [self.currentDetailVC setAlubumId:self.album_id];
        
        [self.currentDetailVC setContentBtnVisible];
        self.currentDetailVC.isMessageShowing =  self.getMessagePush;
        
    }
    self.zoomTransitionController.isInteractive = NO;
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.delegate = nil;
    
    self.currentDetailVC.baseView.scrollEnabled = YES;
    
}
- (UIImageView *)sourceImageView:(ZoomAnimator *)zoomAnimator {
    return self.sourceView;
}
- (UIImageView *)referenceImageView:(ZoomAnimator *)zoomAnimator {
    return [self.currentDetailVC albumCoverView];
}
- (CGRect)sourceImageViewFrameInTransitioningView:(ZoomAnimator *)zoomAnimator {
    if (self.sourceView == nil)
        return [self.currentDetailVC.view convertRect:self.currentDetailVC.dismissBtn.frame fromView:self.currentDetailVC.dismissBtn];
    return self.sourceRect;
}
- (CGRect)referenceImageViewFrameInTransitioningView:(ZoomAnimator *)zoomAnimator {
    UIImageView *v =  [self.currentDetailVC albumCoverView];
    if (v) {
        CGRect dest = [self.currentDetailVC.view convertRect:v.frame fromView:v];
        return dest;
    }
    return self.currentDetailVC.view.frame;
}

@end
