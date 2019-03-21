//
//  MoreTabViewController.m
//  wPinpinbox
//
//  Created by David on 2018/7/3.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "MoreTabViewController.h"
#import "AppDelegate.h"
#import "TouchDetectedScrollView.h"
#import "MyLayout.h"
#import "LabelAttributeStyle.h"

#import "InfoEditViewController.h"
#import "AlbumCollectionViewController.h"
#import "FollowListsViewController.h"
#import "RecentBrowsingViewController.h"
#import "BuyPPointViewController.h"
#import "ExchangeListViewController.h"
#import "SettingViewController.h"

#import "MyLinearLayout.h"
#import "UIColor+Extensions.h"
#import <SafariServices/SafariServices.h>
#import "GlobalVars.h"

#define kLineHeight 1 / [UIScreen mainScreen].scale
#define kLayoutHeight 49
#define kCellGap 20

@interface MoreTabViewController () <TouchDetectedScrollViewDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarHeight;

@property (weak, nonatomic) IBOutlet TouchDetectedScrollView *scrollView;
@property (weak, nonatomic) IBOutlet MyLinearLayout *vertLayout;
@end

@implementation MoreTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initialValueSetup];
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
                self.navBarHeight.constant = 48;
                break;
            case 1334:
                printf("iPhone 6/6S/7/8");
                self.navBarHeight.constant = 48;
                break;
            case 1920:
                printf("iPhone 6+/6S+/7+/8+");
                self.navBarHeight.constant = 48;
                break;
            case 2208:
                printf("iPhone 6+/6S+/7+/8+");
                self.navBarHeight.constant = 48;
                break;
            case 2436:
                printf("iPhone X");
                self.navBarHeight.constant = navBarHeightConstant;
                break;
            default:
                printf("unknown");
                self.navBarHeight.constant = 48;
                break;
        }
    }
}

- (void)initialValueSetup {
    NSLog(@"");
    self.navBarView.backgroundColor = [UIColor barColor];
    [self UISetup];
}

- (void)setupTopicLabel {
    UILabel *topicLabel = [UILabel new];
    topicLabel.myTopMargin = 32;
    topicLabel.myBottomMargin = 8;
    topicLabel.myLeftMargin = topicLabel.myRightMargin = 16;
    topicLabel.font = [UIFont boldSystemFontOfSize: 18];
    topicLabel.text = @"創造內容價值 獲得贊助回饋";
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: topicLabel content: topicLabel.text];
    topicLabel.textColor = [UIColor firstGrey];
    [topicLabel sizeToFit];
    topicLabel.wrapContentHeight = YES;
    [self.vertLayout addSubview: topicLabel];
}

- (void)setupAboutBtn {
    UIButton *aboutBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    aboutBtn.myTopMargin = 0;
    aboutBtn.myLeftMargin = aboutBtn.myRightMargin = 16;
    aboutBtn.myBottomMargin = 0;
    aboutBtn.wrapContentWidth = YES;
    aboutBtn.myHeight = 40;
    aboutBtn.layer.cornerRadius = kCornerRadius;
    aboutBtn.backgroundColor = [UIColor firstMain];
    aboutBtn.titleLabel.font = [UIFont systemFontOfSize: 16.0];
    [aboutBtn setTitle: @"立即了解" forState: UIControlStateNormal];
    [aboutBtn addTarget: self action: @selector(toAboutPage) forControlEvents: UIControlEventTouchUpInside];
    [LabelAttributeStyle changeGapStringAndLineSpacingCenterAlignment: aboutBtn.titleLabel content: aboutBtn.titleLabel.text];
    [self.vertLayout addSubview: aboutBtn];
}

- (UIView *)createLineView {
    UIView *lineView = [UIView new];
    lineView.myTopMargin = lineView.myBottomMargin = 0;
    lineView.myLeftMargin = lineView.myRightMargin = 0;
    lineView.backgroundColor = [UIColor secondGrey];
    lineView.myHeight = kLineHeight;
    return lineView;
}

- (MyLinearLayout *)createHorzLayout:(NSInteger)tag {
    MyLinearLayout *horzLayout = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Horz];
    horzLayout.myTopMargin = 0;
    horzLayout.myLeftMargin = horzLayout.myRightMargin = 0;
    horzLayout.myBottomMargin = 0;
    horzLayout.myHeight = kLayoutHeight;
    horzLayout.tag = tag;
    horzLayout.userInteractionEnabled = YES;
    return horzLayout;
}

- (UILabel *)createLabel:(NSString *)title {
    UILabel *label = [UILabel new];
    label.myTopMargin = label.myBottomMargin = 0;
    label.myLeftMargin = 16;
    label.text = title;
    label.textColor = [UIColor firstGrey];
    label.font = [UIFont systemFontOfSize: 16];
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: label content: label.text];
    [label sizeToFit];
    return label;
}

- (void)UISetup {
    [self setupTopicLabel];
    [self setupAboutBtn];
    
    // lineView1
    UIView *lineView1 = [UIView new];
    lineView1.myTopMargin = 16;
    lineView1.myBottomMargin = 0;
    lineView1.myLeftMargin = lineView1.myRightMargin = 0;
    lineView1.backgroundColor = [UIColor secondGrey];
    lineView1.myHeight = kLineHeight;
    [self.vertLayout addSubview: lineView1];
    
    // InfoEdit
    MyLinearLayout *infoEditLayout = [self createHorzLayout: 1];
    UILabel *infoEditLabel = [self createLabel: @"編輯資訊"];
    [infoEditLayout addSubview: infoEditLabel];
    [self.vertLayout addSubview: infoEditLayout];
    
    // lineView2
    UIView *lineView2 = [self createLineView];
    [self.vertLayout addSubview: lineView2];
    
    // AlbumManagement
    MyLinearLayout *albumManagementLayout = [self createHorzLayout: 2];
    UILabel *albumManagementLabel = [self createLabel: @"作品管理"];
    [albumManagementLayout addSubview: albumManagementLabel];
    [self.vertLayout addSubview: albumManagementLayout];
    
    // lineView3
    UIView *lineView3 = [self createLineView];
    [self.vertLayout addSubview: lineView3];
    
    // FollowList
    MyLinearLayout *followListLayout = [self createHorzLayout: 3];
    UILabel *followListLabel = [self createLabel: @"關注清單"];
    [followListLayout addSubview: followListLabel];
    [self.vertLayout addSubview: followListLayout];
    
    // lineView4
    UIView *lineView4 = [self createLineView];
    [self.vertLayout addSubview: lineView4];
    
    // RecentBrowsing
    MyLinearLayout *recentBrowsingLayout = [self createHorzLayout: 4];
    UILabel *recentBrowsingLabel = [self createLabel: @"最近瀏覽"];
    [recentBrowsingLayout addSubview: recentBrowsingLabel];
    [self.vertLayout addSubview: recentBrowsingLayout];
    
    // lineView5
    UIView *lineView5 = [self createLineView];
    [self.vertLayout addSubview: lineView5];
    
    // BuyPPoint
    MyLinearLayout *buyPPointLayout = [self createHorzLayout: 5];
    UILabel *buyPPointLabel = [self createLabel: @"購買P點"];
    [buyPPointLayout addSubview: buyPPointLabel];
    [self.vertLayout addSubview: buyPPointLayout];
    
    // lineView6
    UIView *lineView6 = [self createLineView];
    [self.vertLayout addSubview: lineView6];
    
    // ExchangeList
    MyLinearLayout *exchangeListLayout = [self createHorzLayout: 6];
    UILabel *exchangeListLabel = [self createLabel: @"兌換清單"];
    [exchangeListLayout addSubview: exchangeListLabel];
    [self.vertLayout addSubview: exchangeListLayout];
    
    // lineView7
    UIView *lineView7 = [self createLineView];
    [self.vertLayout addSubview: lineView7];
    
    // SettingVC
    MyLinearLayout *settingLayout = [self createHorzLayout: 7];
    UILabel *settingLabel = [self createLabel: @"設定"];
    [settingLayout addSubview: settingLabel];
    [self.vertLayout addSubview: settingLayout];
    
    // lineView8
    UIView *lineView8 = [self createLineView];
    [self.vertLayout addSubview: lineView8];
    
    
    self.vertLayout.wrapContentHeight = YES;
    
    __block CGFloat h;
    
    [self.vertLayout setEndLayoutBlock:^{
        NSLog(@"self.vertLayout.frame: %@", NSStringFromCGRect(self.vertLayout.frame));
        h = self.vertLayout.frame.size.height;
    }];
    self.scrollView.detectedDelegate = self;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, h);
    self.scrollView.backgroundColor = [UIColor clearColor];
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
            case 1:
            {
            
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
    NSLog(@"MoreTabVC");
    NSLog(@"didTouchBegin");
    
    UITouch *touch = [touches anyObject];
    NSLog(@"touch.view: %@", touch.view);
    NSLog(@"touch.view.tag: %d", (int)touch.view.tag);
    NSLog(@"touch.view.accessibilityIdentifier: %@", touch.view.accessibilityIdentifier);
    
    if (touch.view.tag != 0) {
        touch.view.backgroundColor = [UIColor thirdMain];
    }
}

- (void)didTouchCancel:(TouchDetectedScrollView *)controller
               touches:(NSSet *)touches
             withEvent:(UIEvent *)event
{
    NSLog(@"");
    NSLog(@"MoreTabVC");
    NSLog(@"touchesCancelled");
    
    UITouch *touch = [touches anyObject];
    NSLog(@"touch.view: %@", touch.view);
    NSLog(@"touch.view.tag: %d", (int)touch.view.tag);
    
    if (touch.view.tag != 0) {
        touch.view.backgroundColor = [UIColor clearColor];
    }
}

- (void)didTouchEnd:(TouchDetectedScrollView *)controller
            touches:(NSSet *)touches
          withEvent:(UIEvent *)event
{
    NSLog(@"");
    NSLog(@"MoreTabVC");
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
        case 1:
        {
            NSLog(@"case 1");
            if (CGRectContainsPoint(touch.view.bounds, location)) {
                NSLog(@"in the touch.view.tag == 1");
                InfoEditViewController *infoEditVC = [[UIStoryboard storyboardWithName: @"InfoEditVC" bundle: [NSBundle mainBundle]] instantiateViewControllerWithIdentifier: @"InfoEditViewController"];
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [appDelegate.myNav pushViewController: infoEditVC animated: YES];
            } else {
                NSLog(@"outside the touch.view.tag == 1");
            }
        }
            break;
        case 2:
        {
            NSLog(@"case 2");
            if (CGRectContainsPoint(touch.view.bounds, location)) {
                NSLog(@"in the touch.view.tag == 2");
                AlbumCollectionViewController *albumCollectionVC = [[UIStoryboard storyboardWithName: @"AlbumCollectionVC" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumCollectionViewController"];
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate.myNav pushViewController: albumCollectionVC animated: YES];
            } else {
                NSLog(@"outside the touch.view.tag == 2");
            }
        }
            break;
        case 3:
        {
            NSLog(@"case 3");
            if (CGRectContainsPoint(touch.view.bounds, location)) {
                NSLog(@"in the touch.view.tag == 3");
                FollowListsViewController *followListVC = [[UIStoryboard storyboardWithName: @"FollowListsVC" bundle: nil] instantiateViewControllerWithIdentifier: @"FollowListsViewController"];
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [appDelegate.myNav pushViewController: followListVC animated: YES];
            } else {
                NSLog(@"outside the touch.view.tag == 3");
            }
        }
            break;
        case 4:
        {
            if (CGRectContainsPoint(touch.view.bounds, location)) {
                NSLog(@"in the touch.view.tag == 4");
                RecentBrowsingViewController *rbVC = [[UIStoryboard storyboardWithName: @"RecentBrowsingVC" bundle: nil] instantiateViewControllerWithIdentifier: @"RecentBrowsingViewController"];
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [appDelegate.myNav pushViewController: rbVC animated: YES];
            } else {
                NSLog(@"outside the touch.view.tag == 4");
            }
        }
            break;
        case 5:
        {
            if (CGRectContainsPoint(touch.view.bounds, location)) {
                NSLog(@"in the touch.view.tag == 5");
                BuyPPointViewController *buyPPVC = [[UIStoryboard storyboardWithName: @"BuyPointVC" bundle: nil] instantiateViewControllerWithIdentifier: @"BuyPPointViewController"];
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [appDelegate.myNav pushViewController: buyPPVC animated: YES];
            } else {
                NSLog(@"outside the touch.view.tag == 5");
            }
        }
            break;
        case 6:
        {
            if (CGRectContainsPoint(touch.view.bounds, location)) {
                NSLog(@"in the touch.view.tag == 6");
                ExchangeListViewController *exchangeListVC = [[UIStoryboard storyboardWithName: @"ExchangeListVC" bundle: nil] instantiateViewControllerWithIdentifier: @"ExchangeListViewController"];
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [appDelegate.myNav pushViewController: exchangeListVC animated: YES];
            } else {
                NSLog(@"outside the touch.view.tag == 6");
            }
        }
            break;
        case 7:
        {
            if (CGRectContainsPoint(touch.view.bounds, location)) {
                NSLog(@"in the touch.view.tag == 7");
                SettingViewController *settingVC = [[UIStoryboard storyboardWithName: @"SettingVC" bundle: nil] instantiateViewControllerWithIdentifier: @"SettingViewController"];
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [appDelegate.myNav pushViewController: settingVC animated: YES];
            } else {
                NSLog(@"outside the touch.view.tag == 7");
            }
        }
            break;
        default:
            break;
    }
}

- (void)toAboutPage {
    NSString *urlString = aboutPageLink;
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL: [NSURL URLWithString: urlString]
                                                           entersReaderIfAvailable: NO];
//    safariVC.delegate = self;
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
