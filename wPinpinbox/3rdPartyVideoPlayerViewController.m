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
@property (nonatomic, strong) WKVideoPlayerView *videoView;
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
    WKVideoPlayerView *videoview = [[WKVideoPlayerView alloc] initWithString:self.videoPath configuration:[self getConfiguration]];
    
    videoview.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint
                                         constraintWithItem:videoview
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:self.view
                                         attribute:NSLayoutAttributeTop
                                         multiplier:1.0
                                         constant:0.0];
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:videoview
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1.0
                                                                       constant:0.0];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:videoview
                                                                       attribute:NSLayoutAttributeRight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1.0
                                                                        constant:0.0];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:videoview
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0
                                                                         constant:0.0];
    NSArray *constraints = @[topConstraint, leftConstraint, rightConstraint, bottomConstraint];
    
    [self.view addSubview:videoview];
    
    [self.view addConstraints:constraints];
    
    [videoview setVideoPath:self.videoPath];
    [self.view bringSubviewToFront:self.hint];
    [self.view sendSubviewToBack:videoview];
}

- (WKWebViewConfiguration *)getConfiguration {
    if (!self.wkvideoplayerConf) {
        self.wkvideoplayerConf =  [[WKWebViewConfiguration alloc] init];
        self.wkvideoplayerConf.allowsInlineMediaPlayback = YES;
        self.wkvideoplayerConf.mediaTypesRequiringUserActionForPlayback = NO;
        WKUserContentController *cntController = [[WKUserContentController alloc] init];
        
        [cntController addScriptMessageHandler:self name:@"callbackHandler"];
        self.wkvideoplayerConf.userContentController = cntController;

    }
    
    return self.wkvideoplayerConf;
}
- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
    if ([message.body isKindOfClass:[NSString class]]) {
        NSString *msg = (NSString *)message.body;
        [self.view bringSubviewToFront:self.close];
        if (!self.hint.hidden && [[msg lowercaseString] containsString:@"videoisready"])
            self.hint.hidden = YES;
//        NSLog(@"didReceiveScriptMessage %@",msg);
//
//        
//        if ([[msg lowercaseString] containsString:@"playing"]){
//            self.is3rdPartyVideoPlaying = YES;
//
//        } else {
//            self.is3rdPartyVideoPlaying = NO;
//        }
//        self.imageScrollCV.scrollEnabled = !self.is3rdPartyVideoPlaying;
//        NSLog(@"userContentController didreceive : %@",msg);
    }
}
- (void)closedVideoScreen:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIWindowDidBecomeHiddenNotification object:nil];
    // perhaps after dismiss call ContentCheckingVC to scroll to right cell.... //
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
    

