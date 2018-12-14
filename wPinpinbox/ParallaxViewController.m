//
//  ParallaxViewController.m
//  ParralaxDetailView
//
//  Created by apple on 29/04/16.
//  Copyright © 2016 ClickApps. All rights reserved.
//

#import "ParallaxViewController.h"
#import "UIColor+HexString.h"
#import "UIColor+Extensions.h"
#import "wTools.h"

#define HEADER_IMAGE_HEIGHT  300;

@interface ParallaxViewController () <UIScrollViewDelegate>

/**
 @property scrollDirectionValue
 @description holding value to determine scroll direction
 */
@property(nonatomic, assign) float scrollDirectionValue;

/**
 @property yoffset
 @description set scroll contentoffset based on this offest value
 */
@property(nonatomic, assign) float yoffset;


/**
 @property alphaValue
 @description alpha to  fade in fade out nav color
 */
@property(nonatomic, assign) CGFloat alphaValue;
/**
 @property bottomViewTopConstraint
 @description constraint for aligning bottom view as per our post imageview height
 */
@property(nonatomic, weak) IBOutlet NSLayoutConstraint *bottomViewTopConstraint;

@property (nonatomic, assign) CGFloat lastContentOffset;

@end

@implementation ParallaxViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSLog(@"viewDidLoad ParallaxViewController");
    //self.contentViewHeight.constant = self.contentViewHeight.constant +100;
    UIView *view = [[[NSBundle mainBundle]loadNibNamed:@"ParallaxViewController" owner:self options:nil] objectAtIndex:0];
    view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self.view insertSubview:view atIndex:0];

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    self.bottomScroll.delegate = self;
    self.headerImageViewHeight.constant = HEADER_IMAGE_HEIGHT;
    self.bottomViewTopConstraint.constant = self.headerImageViewHeight.constant;
    self.contentViewHeight.constant = [UIScreen mainScreen].bounds.size.height - HEADER_IMAGE_HEIGHT;

    //self.topScroll.showsVerticalScrollIndicator = NO;
    self.bottomScroll.showsVerticalScrollIndicator = NO;
    self.topScroll.userInteractionEnabled = YES;
    
    // Graident Effect for HeaderBgView
    CAGradientLayer *headerBgVGradient;
    headerBgVGradient = [CAGradientLayer layer];
    headerBgVGradient.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.gradientView.frame.size.height);
    headerBgVGradient.colors = @[(id)[UIColor colorFromHexString: @"#32000000"].CGColor, (id)[UIColor colorFromHexString: @"#000000"].CGColor];
    [self.gradientView.layer insertSublayer: headerBgVGradient atIndex: 0];
    self.gradientView.alpha = 0.5;
    
    [self likeViewSetup];
    [self messageViewSetup];
    [self sponsorViewSetup];
    
    // Label Setting
//    self.headerLikedNumberLabel.font = [UIFont systemFontOfSize: 28];
//    self.headerViewedNumberLabel.font = [UIFont systemFontOfSize: 16];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear");
    [wTools setStatusBarBackgroundColor: [UIColor clearColor]];
//    [wTools setStatusBarBackgroundColor: [UIColor clearColor]];
    //[self.topScroll setContentOffset:CGPointMake(0, 0) animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
//        [wTools setStatusBarBackgroundColor: [UIColor clearColor]];
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [wTools setStatusBarBackgroundColor: [UIColor whiteColor]];
//    UIWindow *statusBarWindow = (UIWindow *)[[UIApplication sharedApplication] valueForKey: @"statusBarWindow"];
    //statusBarWindow.alpha = 1.0;
    //[self setStatusBarBackgroundColor: [UIColor whiteColor]];
//    [wTools setStatusBarBackgroundColor: [UIColor colorWithRed: 1.0 green: 1.0 blue: 1.0 alpha: 0.0]];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGPoint offset = self.topScroll.contentOffset;
    offset.y = - self.topScroll.contentInset.top;
    [self.topScroll setContentOffset:offset animated:YES];
}

- (void)likeViewSetup {
    // likeView Setting
//    self.likeView.backgroundColor = [UIColor whiteColor];
//
//    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect: self.likeView.bounds byRoundingCorners: (UIRectCornerTopLeft | UIRectCornerBottomLeft) cornerRadii: CGSizeMake(16, 16)];
//    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
//    maskLayer.frame = self.likeView.bounds;
//    maskLayer.path = maskPath.CGPath;
//    self.likeView.layer.mask = maskLayer;
//
//    self.headerLikedNumberLabel.textColor = [UIColor secondGrey];
//    self.headerLikedNumberLabel.font = [UIFont boldSystemFontOfSize: 18.0];
    
    UITapGestureRecognizer *likeViewTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(likeViewTapped:)];
    [self.likeView addGestureRecognizer: likeViewTap];
}

- (void)messageViewSetup {
    // messageView Setting
//    self.messageView.backgroundColor = [UIColor whiteColor];
//
//    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect: self.messageView.bounds byRoundingCorners: (UIRectCornerTopLeft | UIRectCornerBottomLeft) cornerRadii: CGSizeMake(16, 16)];
//    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
//    maskLayer.frame = self.messageView.bounds;
//    maskLayer.path = maskPath.CGPath;
//    self.messageView.layer.mask = maskLayer;
//
//    self.headerMessageNumberLabel.textColor = [UIColor secondGrey];
//    self.headerMessageNumberLabel.font = [UIFont boldSystemFontOfSize: 18.0];
    
    UITapGestureRecognizer *messageViewTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(messageViewTapped:)];
    [self.messageView addGestureRecognizer: messageViewTap];        
}

- (void)sponsorViewSetup {
    // messageView Setting
//    self.sponsorView.backgroundColor = [UIColor whiteColor];
//
//    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect: self.sponsorView.bounds byRoundingCorners: (UIRectCornerTopLeft | UIRectCornerBottomLeft) cornerRadii: CGSizeMake(16, 16)];
//    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
//    maskLayer.frame = self.sponsorView.bounds;
//    maskLayer.path = maskPath.CGPath;
//    self.sponsorView.layer.mask = maskLayer;
//
//    self.sponsorNumberLabel.textColor = [UIColor secondGrey];
//    self.sponsorNumberLabel.font = [UIFont boldSystemFontOfSize: 18.0];
    
    UITapGestureRecognizer *sponsorViewTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(sponsorViewTapped:)];
    [self.sponsorView addGestureRecognizer: sponsorViewTap];
    self.sponsorView.hidden = YES;
}

- (void)likeViewTapped:(UITapGestureRecognizer *)gesturerecognizer {
    NSLog(@"ParallaxVC");
    NSLog(@"likeViewTapped");
}

- (void)messageViewTapped:(UITapGestureRecognizer *)gesturerecognizer {
    NSLog(@"ParallaxVC");
    NSLog(@"messageViewTapped");
}

- (void)sponsorViewTapped:(UITapGestureRecognizer *)gesturerecognizer {
    NSLog(@"ParallaxVC");
    NSLog(@"sponsorViewTapped");
}

- (void)tapDetected:(UITapGestureRecognizer *)gesturerecognizer {
    NSLog(@"tapDetected");
    NSLog(@"gesturerecognizer view: %@", [gesturerecognizer view]);
}

- (void)adjustContentViewHeight{
    self.bottomViewTopConstraint.constant = self.headerImageViewHeight.constant;
    self.contentViewHeight.constant = [UIScreen mainScreen].bounds.size.height -  self.headerImageViewHeight.constant;
}

- (IBAction)headerImgBtnPress:(id)sender {
    NSLog(@"ParallaxVC");
    NSLog(@"headerImgBtnPress");
}

- (IBAction)horzLikeBtnPress:(id)sender {
    NSLog(@"ParallaxVC");
    NSLog(@"horzLikeBtnPress");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"");
    NSLog(@"ParallaxViewController");
    NSLog(@"scrollViewDidScroll");
    NSString *scrollDirection;
    
    NSLog(@"self.lastContentOffset: %f", self.lastContentOffset);
    NSLog(@"scrollView.contentOffset.y: %f", scrollView.contentOffset.y);
    
    if (self.lastContentOffset > scrollView.contentOffset.y) {
        NSLog(@"scroll up");
        scrollDirection = @"ScrollUp";
    } else if (self.lastContentOffset < scrollView.contentOffset.y) {
        NSLog(@"scroll down");
        scrollDirection = @"ScrollDown";
    } else if (self.lastContentOffset == scrollView.contentOffset.y) {
        NSLog(@"scroll up");
        scrollDirection = @"ScrollUp";
    }
    NSLog(@"scrollDirection: %@", scrollDirection);
    
    CGFloat offset = scrollView.contentOffset.y;
    NSLog(@"offset: %f", offset);
    
    if ([self.delegate respondsToSelector: @selector(checkYOffset:scrollDirection:)]) {
        [self.delegate checkYOffset: offset scrollDirection: scrollDirection];
    }
    
    self.lastContentOffset = scrollView.contentOffset.y;
    if (self.lastContentOffset < 0) {
        self.lastContentOffset = 0;
    }
    
    CGFloat percentage = offset / self.headerImageViewHeight.constant;
    NSLog(@"self.headerImageViewHeight.constant: %f", self.headerImageViewHeight.constant);
    NSLog(@"percentage: %f", percentage);
    
    CGFloat value = self.headerImageViewHeight.constant*percentage; // negative when scrolling up more than the top
    NSLog(@"value: %f", value);
    
    /* if (value > scrollDirectionValue || value == scrollDirectionValue) {
     //moving upward
     //  alphaValue=fabs(percentage);
     }
     else {
     // NSLog(@"Moving Downward");
     //alphaValue=2-fabs(percentage);
     }*/
    
    NSLog(@"fabs(percentage): %f", fabs(percentage));
    self.alphaValue = fabs(percentage);
    
    NSLog(@"\nself.alphaValue\n: %f", self.alphaValue);
    
//    UIWindow *statusBarWindow = (UIWindow *)[[UIApplication sharedApplication] valueForKey: @"statusBarWindow"];
//    statusBarWindow.alpha = self.alphaValue;
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey: @"statusBarWindow"] valueForKey: @"statusBar"];
    statusBar.backgroundColor = [UIColor colorWithRed: 1.0 green: 1.0 blue: 1.0 alpha: self.alphaValue * 0.01];
    
    self.headerImageView.alpha = 1 - self.alphaValue;
    self.scrollDirectionValue = value;
    
    if (percentage < 0.00) {
        //self.yoffset = self.bottomScroll.contentOffset.y * 0.3;
        [self.bottomScroll setContentOffset:CGPointMake(0, 0)];
    }
    else {
        self.yoffset = self.bottomScroll.contentOffset.y * 0.3;
        NSLog(@"self.yoffset: %f", self.yoffset);
        NSLog(@"scrollView.contentOffset.x: %f", scrollView.contentOffset.x);
        [self.topScroll setContentOffset:CGPointMake(scrollView.contentOffset.x,self.yoffset) animated:NO];
    }
}

@end
