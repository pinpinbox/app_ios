//
//  3rdPartyVideoPlayerViewController.m
//  wPinpinbox
//
//  Created by Antelis on 2018/11/28.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "3rdPartyVideoPlayerViewController.h"
#import "WKVideoPlayerView.h"
@interface PlayerVCAnimationTransitioning()
@property (nonatomic) BOOL isPresenting;
@end
@interface ThirdPartyVideoPlayerViewController ()<WKScriptMessageHandler>
@property (nonatomic, strong) WKVideoPlayerView *videoview;
@property (nonatomic, strong) NSString *videoPath;
@property (nonatomic, strong) WKWebViewConfiguration *wkvideoplayerConf;
@property (nonatomic) IBOutlet UIButton *close;
@property (nonatomic) IBOutlet UIView *hint;
@end

@implementation  PlayerVCPresenterVC
- (CGRect)frameOfPresentedViewInContainerView {
    return [UIScreen mainScreen].bounds;
}
@end

@implementation PlayerVCAnimationTransitioning

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    ThirdPartyVideoPlayerViewController *to = (ThirdPartyVideoPlayerViewController *) [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    [to setNeedsStatusBarAppearanceUpdate];
    __block BOOL ispresent = self.isPresenting;
    if (!ispresent) {
        to = (ThirdPartyVideoPlayerViewController *) [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        to.view.alpha = 1;
    } else {
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

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

@end


@implementation ThirdPartyVideoPlayerViewController
- (id)initWithCoder:(NSCoder *)aDecoder {
 
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;
        self.modalPresentationCapturesStatusBarAppearance = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closedVideoScreen:) name:UIWindowDidBecomeHiddenNotification object:nil];
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
#pragma mark
-(void)setVideoPath:(NSString *)path {
    _videoPath = path;
    [self prepareVideoPlayerView];
}
#pragma mark
- (void)prepareVideoPlayerView {
    self.videoview = [[WKVideoPlayerView alloc] initWithString:self.videoPath configuration:[self getConfiguration]];
    
    self.videoview.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint
                                         constraintWithItem:self.videoview
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:self.view
                                         attribute:NSLayoutAttributeTop
                                         multiplier:1.0
                                         constant:0.0];
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.videoview
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1.0
                                                                       constant:0.0];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.videoview
                                                                       attribute:NSLayoutAttributeRight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1.0
                                                                        constant:0.0];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.videoview
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0
                                                                         constant:0.0];
    NSArray *constraints = @[topConstraint, leftConstraint, rightConstraint, bottomConstraint];
    self.videoview.alpha = 0;
    [self.view addSubview:self.videoview];
    
    [self.view addConstraints:constraints];
    
    [self.videoview setVideoPath:self.videoPath];
    __block typeof(self) wself = self;
    self.videoview.handleTimedOutBlock = ^{
        if (!wself.hint.hidden) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [wself closedVideoScreen:nil];
            });
        }
    };
    [self.view bringSubviewToFront:self.hint];
    [self.view sendSubviewToBack:self.videoview];
}
// WKWebViewConfiguration for setting up embedded video player
- (WKWebViewConfiguration *)getConfiguration {
    if (!self.wkvideoplayerConf) {
        self.wkvideoplayerConf =  [[WKWebViewConfiguration alloc] init];
        //  for video autoplay in WKWebView
        self.wkvideoplayerConf.allowsInlineMediaPlayback = YES;
        self.wkvideoplayerConf.mediaTypesRequiringUserActionForPlayback = NO;
        WKUserContentController *cntController = [[WKUserContentController alloc] init];
        
        [cntController addScriptMessageHandler:self name:@"callbackHandler"];
        
        self.wkvideoplayerConf.userContentController = cntController;

    }
    
    return self.wkvideoplayerConf;
}
//  receive video status from JS
- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
    if ([message.body isKindOfClass:[NSString class]]) {
        NSString *msg = (NSString *)message.body;
        [self.view bringSubviewToFront:self.close];
        if (!self.hint.hidden && [[msg lowercaseString] containsString:@"videoisready"]){
            self.hint.hidden = YES;
            self.videoview.alpha = 1;
        }
    }
}

//  dismiss this VC when user stopped the video
- (void)closedVideoScreen:(NSNotification *)notification {
    //  remove UIWindowDidBecomeHiddenNotification target
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIWindowDidBecomeHiddenNotification object:nil];
    //  pause the video first
    [self.videoview pauseVid];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)dismissPlayer:(id)sender {
    [self closedVideoScreen:nil];
}

#pragma mark UIViewControllerTransitioningDelegat functions
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    PlayerVCAnimationTransitioning *at = [[PlayerVCAnimationTransitioning alloc] init];
    at.isPresenting = YES;
    return at;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    PlayerVCAnimationTransitioning *at = [[PlayerVCAnimationTransitioning alloc] init];
    at.isPresenting = NO;
    return at;
}
- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(nullable UIViewController *)presenting sourceViewController:(UIViewController *)source {
    
    return [[PlayerVCPresenterVC alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}
@end
    

