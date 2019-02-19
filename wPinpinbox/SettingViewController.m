//
//  SettingViewController.m
//  wPinpinbox
//
//  Created by David Lee on 2017/9/29.
//  Copyright © 2017年 Angus. All rights reserved.
//

#import "SettingViewController.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "UIColor+Extensions.h"
#import "MyLayout.h"
#import "TouchDetectedScrollView.h"
#import <SafariServices/SafariServices.h>
#import "AboutPinpinBoxViewController.h"
#import "wTools.h"
#import "GlobalVars.h"
#import "LabelAttributeStyle.h"

#define kLineHeight 1 / [UIScreen mainScreen].scale//0.5
#define kLayoutHeight 48
#define kCellGap 20

@interface SettingViewController () <TouchDetectedScrollViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic) BOOL isAudioPlayedAutomatically;
@property (nonatomic) BOOL isVideoPlayedAutomatically;
@property (nonatomic) UIView *audioSelectedView;
@property (nonatomic) UIView *videoSelectedView;
@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarHeight;

@property (weak, nonatomic) IBOutlet TouchDetectedScrollView *scrollView;
@property (weak, nonatomic) IBOutlet MyLinearLayout *vertLayout;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.delegate = self;
    [self initialValueSetup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    for (UIView *view in self.tabBarController.view.subviews) {
        UIButton *btn = (UIButton *)[view viewWithTag: 104];
        btn.hidden = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.enabled = NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    NSLog(@"viewDidLayoutSubviews");
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 1136:
                printf("iPhone 5 or 5S or 5C");
                break;
            case 1334:
                printf("iPhone 6/6S/7/8");
                break;
            case 1920:
                printf("iPhone 6+/6S+/7+/8+");
                break;
            case 2208:
                printf("iPhone 6+/6S+/7+/8+");
                break;
            case 2436:
                printf("iPhone X");
                self.navBarHeight.constant = navBarHeightConstant;
                break;
            default:
                printf("unknown");
                break;
        }
    }
}


- (void)initialValueSetup {
    NSLog(@"");
    self.navBarView.backgroundColor = [UIColor barColor];
    [self UISetup];
}

- (void)UISetup {
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleTapFromView:)];
    singleTap.numberOfTapsRequired = 1;
    
    // Topic Label
    UILabel *topicLabel = [UILabel new];
    topicLabel.myTopMargin = topicLabel.myBottomMargin = 16;
    topicLabel.myLeftMargin = 16;
    topicLabel.myBottomMargin = kCellGap;
    topicLabel.font = [UIFont boldSystemFontOfSize: 48];
    topicLabel.text = @"設定";
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: topicLabel content: topicLabel.text];
    topicLabel.textColor = [UIColor firstGrey];
    [topicLabel sizeToFit];
    topicLabel.wrapContentHeight = YES;
    [self.vertLayout addSubview: topicLabel];
    
    // Line View
    UIView *lineView2 = [UIView new];
    lineView2.myTopMargin = kCellGap;
    lineView2.myLeftMargin = lineView2.myRightMargin = 0;
    lineView2.myBottomMargin = 0;
    lineView2.backgroundColor = [UIColor secondGrey];
    lineView2.myHeight = kLineHeight;
    [self.vertLayout addSubview: lineView2];
    
    // Audio Playing Section
    MyLinearLayout *audioPlayLayout = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Horz];
    audioPlayLayout.myTopMargin = 0;
    audioPlayLayout.myLeftMargin = audioPlayLayout.myRightMargin = 0;
    audioPlayLayout.myBottomMargin = 0;
    audioPlayLayout.myHeight = kLayoutHeight;
    audioPlayLayout.tag = 2;
    audioPlayLayout.userInteractionEnabled = YES;
    [self.vertLayout addSubview: audioPlayLayout];
    
    UILabel *audioPlayLabel = [UILabel new];
    audioPlayLabel.myLeftMargin = 16;
    audioPlayLabel.text = @"自動播放音效 (作品)";
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: audioPlayLabel content: audioPlayLabel.text];
    audioPlayLabel.textColor = [UIColor firstGrey];
    audioPlayLabel.font = [UIFont systemFontOfSize: 17];
    [audioPlayLabel sizeToFit];
    audioPlayLabel.myCenterYOffset = 0;
    
    [audioPlayLayout addSubview: audioPlayLabel];
    
    //UIView *audioSelectedView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 25, 25)];
    self.audioSelectedView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 25, 25)];
    self.audioSelectedView.myRightMargin = 16;
    self.audioSelectedView.myLeftMargin = 0.5;
    self.audioSelectedView.myCenterYOffset = 0;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.isAudioPlayedAutomatically = [[defaults objectForKey: @"isAudioPlayedAutomatically"] boolValue];
    
    NSLog(@"self.isAudioPlayedAutomatically: %d", self.isAudioPlayedAutomatically);
    
    if (self.isAudioPlayedAutomatically) {
        self.audioSelectedView.backgroundColor = [UIColor thirdMain];
    } else {
        self.audioSelectedView.backgroundColor = [UIColor clearColor];
    }
    
    self.audioSelectedView.layer.cornerRadius = kCornerRadius;
    self.audioSelectedView.layer.borderColor = [UIColor secondGrey].CGColor;
    self.audioSelectedView.layer.borderWidth = 0.5;
    self.audioSelectedView.tag = 200;
    [audioPlayLayout addSubview: self.audioSelectedView];
    
    [audioPlayLayout addGestureRecognizer: singleTap];
    
    UIView *lineView3 = [UIView new];
    lineView3.myTopMargin = 0;
    lineView3.myLeftMargin = lineView3.myRightMargin = 0;
    lineView3.myBottomMargin = 0;
    lineView3.backgroundColor = [UIColor secondGrey];
    lineView3.myHeight = kLineHeight;
    [self.vertLayout addSubview: lineView3];
    
    // Video Playing Section
    MyLinearLayout *videoPlayLayout = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Horz];
    videoPlayLayout.myTopMargin = 0;
    videoPlayLayout.myLeftMargin = videoPlayLayout.myRightMargin = 0;
    videoPlayLayout.myBottomMargin = 0;
    videoPlayLayout.myHeight = kLayoutHeight;
    videoPlayLayout.tag = 3;
    videoPlayLayout.userInteractionEnabled = YES;
    [self.vertLayout addSubview: videoPlayLayout];
    
    UILabel *videoPlayLabel = [UILabel new];
    videoPlayLabel.myLeftMargin = 16;
    videoPlayLabel.text = @"自動播放影片 (分類輪播)";
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: videoPlayLabel content: videoPlayLabel.text];
    videoPlayLabel.textColor = [UIColor firstGrey];
    videoPlayLabel.font = [UIFont systemFontOfSize: 17];
    [videoPlayLabel sizeToFit];
    videoPlayLabel.myCenterYOffset = 0;
    [videoPlayLayout addSubview: videoPlayLabel];
    
    //UIView *audioSelectedView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 25, 25)];
    self.videoSelectedView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 25, 25)];
    self.videoSelectedView.myRightMargin = 16;
    self.videoSelectedView.myLeftMargin = 0.5;
    self.videoSelectedView.myCenterYOffset = 0;
    
    self.isVideoPlayedAutomatically = [[defaults objectForKey: @"isVideoPlayedAutomatically"] boolValue];
        
    NSLog(@"self.isVideoPlayedAutomatically: %d", self.isVideoPlayedAutomatically);
    
    if (self.isVideoPlayedAutomatically) {
        self.videoSelectedView.backgroundColor = [UIColor thirdMain];
    } else {
        self.videoSelectedView.backgroundColor = [UIColor clearColor];
    }
    
    self.videoSelectedView.layer.cornerRadius = kCornerRadius;
    self.videoSelectedView.layer.borderColor = [UIColor secondGrey].CGColor;
    self.videoSelectedView.layer.borderWidth = 0.5;
    self.videoSelectedView.tag = 300;
    [videoPlayLayout addSubview: self.videoSelectedView];
    
    [videoPlayLayout addGestureRecognizer: singleTap];
    
    UIView *lineView4 = [UIView new];
    lineView4.myTopMargin = 0;
    lineView4.myLeftMargin = lineView4.myRightMargin = 0;
    lineView4.myBottomMargin = kCellGap;
    lineView4.backgroundColor = [UIColor secondGrey];
    lineView4.myHeight = kLineHeight;
    [self.vertLayout addSubview: lineView4];
    
    // Line View
    UIView *lineView5 = [UIView new];
    lineView5.myTopMargin = kCellGap;
    lineView5.myLeftMargin = lineView5.myRightMargin = 0;
    lineView5.myBottomMargin = 0;
    lineView5.backgroundColor = [UIColor secondGrey];
    lineView5.myHeight = kLineHeight;
    [self.vertLayout addSubview: lineView5];
    
    // PlatformRule Section
    MyLinearLayout *platformRuleLayout = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Horz];
    platformRuleLayout.myTopMargin = 0;
    platformRuleLayout.myLeftMargin = platformRuleLayout.myRightMargin = 0;
    platformRuleLayout.myBottomMargin = 0;
    platformRuleLayout.myHeight = kLayoutHeight;
    platformRuleLayout.tag = 4;
    platformRuleLayout.userInteractionEnabled = YES;
    [self.vertLayout addSubview: platformRuleLayout];
    
    UILabel *platformRuleLabel = [UILabel new];
    platformRuleLabel.myLeftMargin = 16;
    platformRuleLabel.text = @"平台規範";
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: platformRuleLabel content: platformRuleLabel.text];
    platformRuleLabel.textColor = [UIColor firstGrey];
    platformRuleLabel.font = [UIFont systemFontOfSize: 17];
    [platformRuleLabel sizeToFit];
    platformRuleLabel.myCenterYOffset = 0;
    
    [platformRuleLayout addSubview: platformRuleLabel];
    [platformRuleLayout addGestureRecognizer: singleTap];
    
    //    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget: self action: @selector(handleLongPress:)];
    //    longPress.numberOfTouchesRequired = 1;
    //    longPress.minimumPressDuration = 3;
    //    [platformRuleLayout addGestureRecognizer: longPress];
    
    UIView *lineView6 = [UIView new];
    lineView6.myTopMargin = 0;
    lineView6.myLeftMargin = lineView6.myRightMargin = 0;
    lineView6.myBottomMargin = 0;
    lineView6.backgroundColor = [UIColor secondGrey];
    lineView6.myHeight = kLineHeight;
    [self.vertLayout addSubview: lineView6];
    
    // About Section
    MyLinearLayout *aboutLayout = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Horz];
    aboutLayout.myTopMargin = 0;
    aboutLayout.myLeftMargin = aboutLayout.myRightMargin = 0;
    aboutLayout.myBottomMargin = 0;
    aboutLayout.myHeight = kLayoutHeight;
    aboutLayout.tag = 5;
    aboutLayout.userInteractionEnabled = YES;
    [self.vertLayout addSubview: aboutLayout];
    
    [aboutLayout addGestureRecognizer: singleTap];
    
    UILabel *aboutLabel = [UILabel new];
    aboutLabel.myLeftMargin = 16;
    aboutLabel.text = @"關於pinpinbox";
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: aboutLabel content: aboutLabel.text];
    aboutLabel.textColor = [UIColor firstGrey];
    aboutLabel.font = [UIFont systemFontOfSize: 17];
    [aboutLabel sizeToFit];
    aboutLabel.myCenterYOffset = 0;
    [aboutLayout addSubview: aboutLabel];
    
    UIView *lineView7 = [UIView new];
    lineView7.myTopMargin = 0;
    lineView7.myLeftMargin = lineView7.myRightMargin = 0;
    lineView7.myBottomMargin = kCellGap;
    lineView7.backgroundColor = [UIColor secondGrey];
    lineView7.myHeight = kLineHeight;
    [self.vertLayout addSubview: lineView7];
    
    UIView *lineView8 = [UIView new];
    lineView8.myTopMargin = kCellGap;
    lineView8.myLeftMargin = lineView8.myRightMargin = 0;
    lineView8.myBottomMargin = 0;
    lineView8.backgroundColor = [UIColor secondGrey];
    lineView8.myHeight = kLineHeight;
    [self.vertLayout addSubview: lineView8];
    
    // Log Out Section
    // About Section
    MyLinearLayout *logOutLayout = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Horz];
    logOutLayout.myTopMargin = 0;
    logOutLayout.myLeftMargin = logOutLayout.myRightMargin = 0;
    logOutLayout.myBottomMargin = 0;
    logOutLayout.myHeight = kLayoutHeight;
    logOutLayout.tag = 6;
    logOutLayout.userInteractionEnabled = YES;
    [self.vertLayout addSubview: logOutLayout];
    
    [logOutLayout addGestureRecognizer: singleTap];
    
    UILabel *logOutLabel = [UILabel new];
    logOutLabel.myLeftMargin = 16;
    logOutLabel.text = @"登出";
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: logOutLabel content: logOutLabel.text];    
    logOutLabel.textColor = [UIColor firstPink];
    logOutLabel.font = [UIFont systemFontOfSize: 17];
    [logOutLabel sizeToFit];
    logOutLabel.myCenterYOffset = 0;
    [logOutLayout addSubview: logOutLabel];
    
    UIView *lineView9 = [UIView new];
    lineView9.myTopMargin = 0;
    lineView9.myLeftMargin = lineView9.myRightMargin = 0;
    lineView9.myBottomMargin = 0;
    lineView9.backgroundColor = [UIColor secondGrey];
    lineView9.myHeight = kLineHeight;
    [self.vertLayout addSubview: lineView9];
        
    self.vertLayout.wrapContentHeight = YES;
    
    __block CGFloat h;
    
    [self.vertLayout setEndLayoutBlock:^{
        NSLog(@"self.vertLayout.frame: %@", NSStringFromCGRect(self.vertLayout.frame));
        h = self.vertLayout.frame.size.height;
    }];
    
    self.scrollView.detectedDelegate = self;
    
    CGFloat top = 0;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 1136:
                printf("iPhone 5 or 5S or 5C");
                top = 44;
                break;
            case 1334:
                printf("iPhone 6/6S/7/8");
                top = 44;
                break;
            case 1920:
                printf("iPhone 6+/6S+/7+/8+");
                top = 44;
                break;
            case 2208:
                printf("iPhone 6+/6S+/7+/8+");
                top = 44;
                break;
            case 2436:
                printf("iPhone X");
                top = 74;
                break;
            default:
                printf("unknown");
                top = 44;
                break;
        }
    }
    
    self.scrollView.contentInset = UIEdgeInsetsMake(top, 0, 0, 0);
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, h);
    self.scrollView.backgroundColor = [UIColor clearColor];
    NSLog(@"self.scrollView.contentSize: %@", NSStringFromCGSize(self.scrollView.contentSize));
}

#pragma mark - UITapGestureRecognizer Selector Handler Method
// The method below will be called when finger lifts only applies to the situation
// when user presses the view for a long time
- (void)handleTapFromView: (UITapGestureRecognizer *)gesture {
    NSLog(@"");
    NSLog(@"handleTapFromView");
    NSLog(@"gesture: %@", gesture);
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        NSLog(@"gesture.state == UIGestureRecognizerStateBegan");
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        NSLog(@"gesture.state == UIGestureRecognizerStateEnded");
        
        gesture.view.backgroundColor = [UIColor clearColor];
        
        switch (gesture.view.tag) {
            case 4:
            {
                [self toPlatformRulePage: @"https://www.pinpinbox.com/index/index/terms/"];
            }
                break;
            case 5:
            {
                NSLog(@"To aboutView");
                [self toAboutVC];
            }
                break;
            case 6:
            {
                NSLog(@"deleteAllCoreData");
                [wTools deleteAllCoreData];
                NSLog(@"Log Out");
                [wTools logOut];
            }
                break;
            default:
                break;
        }
    } else if (gesture.state == UIGestureRecognizerStateCancelled) {
        NSLog(@"gesture.state == UIGestureRecognizerStateCancelled");
    }
    
    //self.scrollView.userInteractionEnabled = YES;
}

- (void)didTouchBegin:(TouchDetectedScrollView *)controller
              touches:(NSSet *)touches
            withEvent:(UIEvent *)event
{
    NSLog(@"");
    NSLog(@"SettingViewController");
    NSLog(@"didTouchBegin");
    
    UITouch *touch = [touches anyObject];
    NSLog(@"touch.view: %@", touch.view);
    NSLog(@"touch.view.tag: %ld",(long)touch.view.tag);
    
    if (touch.view.tag != 0) {
        touch.view.backgroundColor = [UIColor thirdMain];
    }
}

- (void)didTouchCancel:(TouchDetectedScrollView *)controller
               touches:(NSSet *)touches
             withEvent:(UIEvent *)event
{
    NSLog(@"");
    NSLog(@"SettingViewController");
    NSLog(@"touchesCancelled");
    
    UITouch *touch = [touches anyObject];
    NSLog(@"touch.view: %@", touch.view);
    NSLog(@"touch.view.tag: %ld",(long)touch.view.tag);
    
    if (touch.view.tag != 0) {
        touch.view.backgroundColor = [UIColor clearColor];
    }
}

- (void)didTouchEnd:(TouchDetectedScrollView *)controller
            touches:(NSSet *)touches
          withEvent:(UIEvent *)event
{
    NSLog(@"");
    NSLog(@"SettingViewController");
    NSLog(@"didTouchEnd");
    
    UITouch *touch = [touches anyObject];
    NSLog(@"touch.view: %@", touch.view);
    NSLog(@"touch.view.tag: %ld",(long)touch.view.tag);

    CGPoint location = [touch locationInView: touch.view];
    NSLog(@"location: %@", NSStringFromCGPoint(location));
    
    if (touch.view.tag != 0) {
        touch.view.backgroundColor = [UIColor clearColor];
    }
    
    switch (touch.view.tag) {
        case 2:
        {
            if (CGRectContainsPoint(touch.view.bounds, location)) {
                NSLog(@"in the touch.view.tag == 2");
                [self setupAudioPlayAutomatically];
            }
        }
            break;
        case 200:
        {
            if (CGRectContainsPoint(touch.view.bounds, location)) {
                NSLog(@"in the touch.view.tag == 200");
                [self setupAudioPlayAutomatically];
            }
        }
            break;
        case 3:
        {
            if (CGRectContainsPoint(touch.view.bounds, location)) {
                NSLog(@"in the touch.view.tag == 3");
                [self setupVideoPlayAutomatically];
            }
        }
            break;
        case 300:
        {
            if (CGRectContainsPoint(touch.view.bounds, location)) {
                NSLog(@"in the touch.view.tag == 300");
                [self setupVideoPlayAutomatically];
            }
        }
            break;
        case 4:
        {
            NSLog(@"case 4");
            if (CGRectContainsPoint(touch.view.bounds, location)) {
                NSLog(@"in the touch.view.tag == 4");
                
                [self toPlatformRulePage: @"https://www.pinpinbox.com/index/index/terms/"];
            }
        }
            break;
        case 5:
        {
            if (CGRectContainsPoint(touch.view.bounds, location)) {
                NSLog(@"in the touch.view.tag == 5");
                
                [self toAboutVC];
            }
        }
            break;
        case 6:
        {
            if (CGRectContainsPoint(touch.view.bounds, location)) {
                NSLog(@"in the touch.view.tag == 6");
                [DGHUDView stop];
                [wTools deleteAllCoreData];
                [wTools logOut];
            }
        }
        default:
            break;
    }
}

- (void)setupAudioPlayAutomatically {
    self.isAudioPlayedAutomatically = !self.isAudioPlayedAutomatically;
    
    if (self.isAudioPlayedAutomatically) {
        self.audioSelectedView.backgroundColor = [UIColor thirdMain];
    } else {
        self.audioSelectedView.backgroundColor = [UIColor clearColor];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: [NSNumber numberWithBool: self.isAudioPlayedAutomatically] forKey: @"isAudioPlayedAutomatically"];
    [defaults synchronize];
    
    NSLog(@"isAudioPlayedAutomatically: %d", [[defaults objectForKey: @"isAudioPlayedAutomatically"] boolValue]);
}

- (void)setupVideoPlayAutomatically {
    self.isVideoPlayedAutomatically = !self.isVideoPlayedAutomatically;
    
    if (self.isVideoPlayedAutomatically) {
        self.videoSelectedView.backgroundColor = [UIColor thirdMain];
    } else {
        self.videoSelectedView.backgroundColor = [UIColor clearColor];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: [NSNumber numberWithBool: self.isVideoPlayedAutomatically] forKey: @"isVideoPlayedAutomatically"];
    [defaults synchronize];
    
    NSLog(@"isVideoPlayedAutomatically: %d", [[defaults objectForKey: @"isVideoPlayedAutomatically"] boolValue]);
}

- (IBAction)backBtnPress:(id)sender {
    //[self.navigationController popViewControllerAnimated: YES];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav popViewControllerAnimated: YES];
}

- (void)toAboutVC
{
    NSLog(@"toAboutVC");
    //AboutPinpinBoxViewController *aboutVC = [[UIStoryboard storyboardWithName: @"Main" bundle: nil] instantiateViewControllerWithIdentifier: @"AboutPinpinBoxViewController"];
    AboutPinpinBoxViewController *aboutVC = [[UIStoryboard storyboardWithName: @"AboutPinpinBoxVC" bundle: nil] instantiateViewControllerWithIdentifier: @"AboutPinpinBoxViewController"];
    //[self.navigationController pushViewController: aboutVC animated: YES];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav pushViewController: aboutVC animated: YES];
}

- (void)toPlatformRulePage:(NSString *)urlString
{
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL: [NSURL URLWithString: urlString]];
    safariVC.preferredBarTintColor = [UIColor whiteColor];
    [self presentViewController: safariVC animated: YES completion: nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
