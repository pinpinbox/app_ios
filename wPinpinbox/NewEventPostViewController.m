//
//  NewEventPostViewController.m
//  wPinpinbox
//
//  Created by David Lee on 2017/9/22.
//  Copyright © 2017年 Angus. All rights reserved.
//

#import "NewEventPostViewController.h"
#import "UIColor+Extensions.h"
#import "MyLinearLayout.h"
#import <SafariServices/SafariServices.h>
#import "wTools.h"
#import "boxAPI.h"
#import "CustomIOSAlertView.h"
#import "OldCustomAlertView.h"
#import "DDAUIActionSheetViewController.h"
#import "AlbumCreationViewController.h"
#import "UIView+Toast.h"

#import "NewExistingAlbumViewController.h"
#import "ChooseTemplateViewController.h"
#import "GlobalVars.h"
#import "AppDelegate.h"
#import "VotingViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "LabelAttributeStyle.h"
#import "UIColor+HexString.h"
#import "UIViewController+ErrorAlert.h"
#import "UserInfo.h"

#define kFontSize 18

@interface NewEventPostViewController () <DDAUIActionSheetViewControllerDelegate, UIGestureRecognizerDelegate> {
//    Setup2ViewController *s2VC;
    ChooseTemplateViewController *chooseTemplateVC;
    CustomIOSAlertView *alertViewForButton;
    NSMutableDictionary *dict;
    BOOL checkPost;
    NSMutableArray *existedAlbumArray;
    NSInteger currentContributionNumber;
    CGFloat imageHeight;
}
@property (weak, nonatomic) IBOutlet UIButton *eventPostBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *eventPostBtnHeight;
@property (weak, nonatomic) IBOutlet UIView *toolBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolBarViewHeight;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet MyLinearLayout *vertLayout;

@property (nonatomic) DDAUIActionSheetViewController *customPostActionSheet;
@property (nonatomic) UIVisualEffectView *effectView;

@property (weak, nonatomic) IBOutlet UIView *goVotingView;
@property (weak, nonatomic) IBOutlet UIImageView *arrowVoteImage;
@property (weak, nonatomic) IBOutlet UIButton *goVotingBtn;
@end

@implementation NewEventPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"NewEventPostViewController viewDidLoad");
    NSLog(@"self.prefixText: %@", self.prefixText);
    NSLog(@"self.contributionNumber: %ld", (long)self.contributionNumber);
    NSLog(@"self.specialUrl: %@", self.specialUrl);
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.delegate = self;
    self.toolBarView.hidden = YES;
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
    
    if (self.eventFinished) {
        [self initialValueSetup];
    } else {
        [self getExistedAlbum];
    }
    [wTools sendScreenTrackingWithScreenName:@"活動頁面"];
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

- (IBAction)goVotingBtnPress:(id)sender {
    VotingViewController *votingVC = [[UIStoryboard storyboardWithName: @"VotingVC" bundle: nil] instantiateViewControllerWithIdentifier: @"VotingViewController"];
    votingVC.eventId = self.eventId;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.myNav pushViewController: votingVC animated: YES];
    
    /*
    if (!self.eventFinished) {
        VotingViewController *votingVC = [[UIStoryboard storyboardWithName: @"VotingVC" bundle: nil] instantiateViewControllerWithIdentifier: @"VotingViewController"];
        votingVC.eventId = self.eventId;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.myNav pushViewController: votingVC animated: YES];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"" message: @"活動結束" preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction *okBtn = [UIAlertAction actionWithTitle: @"OK" style: UIAlertActionStyleDefault handler: nil];
        [alert addAction: okBtn];
        [self presentViewController: alert animated: YES completion: nil];
    }
     */
}

- (void)goVotingHighlight: (UIButton *)sender {
    NSLog(@"goVotingHighlight");
    //self.goVotingView.backgroundColor = [UIColor thirdMain];
}

- (void)goVotingNormal: (UIButton *)sender {
    NSLog(@"goVotingNormal");
    //self.goVotingView.backgroundColor = [UIColor clearColor];
}

- (void)initialValueSetup {
    NSLog(@"initialValueSetup");
    NSLog(@"self.templateArray: %@", self.templateArray);
    
    for (UIView *subViews in self.vertLayout.subviews) {
        [subViews removeFromSuperview];
    }
    
    self.toolBarView.hidden = NO;
    
    self.arrowVoteImage.transform = CGAffineTransformMakeRotation(M_PI);
    
    self.goVotingView.backgroundColor = [UIColor clearColor];
    self.goVotingView.layer.cornerRadius = kCornerRadius;
    
    [self.goVotingBtn addTarget: self action: @selector(goVotingHighlight:) forControlEvents: UIControlEventTouchDown];
    [self.goVotingBtn addTarget: self action: @selector(goVotingNormal:) forControlEvents: UIControlEventTouchUpInside];
    [self.goVotingBtn addTarget: self action: @selector(goVotingNormal:) forControlEvents: UIControlEventTouchUpOutside];
    
    // CustomActionSheet
    self.customPostActionSheet = [[DDAUIActionSheetViewController alloc] init];
    self.customPostActionSheet.delegate = self;
    self.customPostActionSheet.topicStr = @"請選擇投稿方式";
    
    if (self.eventFinished) {
        self.eventPostBtn.layer.cornerRadius = kCornerRadius;
        [self.eventPostBtn setTitle: @"活動已結束" forState: UIControlStateNormal];
        [self.eventPostBtn setTitleColor: [UIColor thirdGrey] forState: UIControlStateNormal];
        self.eventPostBtn.layer.borderColor = [UIColor thirdGrey].CGColor;
        self.eventPostBtn.layer.borderWidth = 1.0;
        self.eventPostBtn.backgroundColor = [UIColor clearColor];
        
        self.eventPostBtn.userInteractionEnabled = NO;
    } else {
        [self.eventPostBtn setTitleColor: [UIColor firstGrey] forState: UIControlStateNormal];
        self.eventPostBtn.layer.borderColor = [UIColor clearColor].CGColor;
        self.eventPostBtn.layer.borderWidth = 0;
        self.eventPostBtn.backgroundColor = [UIColor firstMain];
        
        self.eventPostBtn.userInteractionEnabled = YES;
    }
    self.eventPostBtnHeight.constant = kToolBarButtonHeight;
    self.toolBarView.backgroundColor = [UIColor barColor];
    self.toolBarView.myLeftMargin = self.toolBarView.myRightMargin = 0;
    self.toolBarView.myBottomMargin = 0;
    
    
    // Image W:H 18:14
    UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 268.8)];
    NSLog(@"self.imageUrl: %@", self.imageUrl);
    imageView.myLeftMargin = imageView.myRightMargin = 0;
    imageView.myTopMargin = 0;
    imageView.myBottomMargin = 16;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.image = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString: self.imageUrl]]];
    imageView.wrapContentHeight = YES;
    imageView.accessibilityIdentifier = @"imageView";
    [self.vertLayout addSubview: imageView];
    
    NSLog(@"imageView: %@", imageView);
    
    MyLinearLayout *horzLayout = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Horz];
    horzLayout.myLeftMargin =  horzLayout.myRightMargin = 16;
    horzLayout.myTopMargin = horzLayout.myBottomMargin = 8;
    //horzLayout.backgroundColor = [UIColor redColor];
    horzLayout.wrapContentHeight = YES;
    [self.vertLayout addSubview: horzLayout];
    
    // ExchangeBtn
    if (currentContributionNumber > 0) {
        if (![self.specialUrl isEqual: [NSNull null]]) {
            UIButton *exchangeBtn = [UIButton buttonWithType: UIButtonTypeSystem];
            //    exchangeBtn.showsTouchWhenHighlighted = YES;
            //    exchangeBtn.adjustsImageWhenHighlighted = YES;
            //    exchangeBtn.adjustsImageWhenDisabled = YES;
            
            //    [exchangeBtn addTarget: self
            //                    action: @selector(showExchangeInfoTouchDown:)
            //          forControlEvents: UIControlEventTouchDown];
            
            [exchangeBtn addTarget: self
                            action: @selector(showExchangeInfoTouchUpInside:)
                  forControlEvents: UIControlEventTouchUpInside];
            
            //    [exchangeBtn addTarget: self
            //                    action: @selector(showExchangeInfoTouchUpOutside:)
            //          forControlEvents: UIControlEventTouchUpOutside];
            
            exchangeBtn.frame = CGRectMake(0, 0, 112, 36);
            [exchangeBtn setTitle: @"我要兌換" forState: UIControlStateNormal];
            [exchangeBtn setTitleEdgeInsets: UIEdgeInsetsMake(0, 16, 0, 16)];
            [exchangeBtn setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
            exchangeBtn.backgroundColor = [UIColor colorFromHexString: @"fd9b64"];
            exchangeBtn.titleLabel.font = [UIFont systemFontOfSize: 16];
            [LabelAttributeStyle changeGapString: exchangeBtn.titleLabel content: @"我要兌換"];
            exchangeBtn.myLeftMargin = 0;
            exchangeBtn.myRightMargin = 0.5;
            exchangeBtn.layer.cornerRadius = kCornerRadius;
            exchangeBtn.clipsToBounds = YES;
            
            [horzLayout addSubview: exchangeBtn];
        }
    }
    
    UILabel *popularityLabel = [UILabel new];
    //popularityLabel.myTopMargin = popularityLabel.myRightMargin = popularityLabel.myBottomMargin = 16;
    popularityLabel.myLeftMargin = 0.5;
    popularityLabel.myRightMargin = 0;
    popularityLabel.myCenterYOffset = 0;
    popularityLabel.text = [NSString stringWithFormat: @"人氣：%ld", (long)self.popularityNumber];
    popularityLabel.textColor = [UIColor firstGrey];
    popularityLabel.font = [UIFont systemFontOfSize: 17];
    [popularityLabel sizeToFit];
    //[self.vertLayout addSubview: popularityLabel];
    [horzLayout addSubview: popularityLabel];
    
    UILabel *topicLabel = [UILabel new];
    topicLabel.myTopMargin = topicLabel.myBottomMargin = 16;
    topicLabel.myLeftMargin = topicLabel.myRightMargin = 16;
    topicLabel.font = [UIFont boldSystemFontOfSize: 28];
    topicLabel.textColor = [UIColor firstGrey];
    if ([wTools objectExists: self.name]) {
        topicLabel.text = self.name;
        [LabelAttributeStyle changeGapString: topicLabel content: self.name];
    }
    topicLabel.numberOfLines = 0;
    topicLabel.wrapContentHeight = YES;
    [self.vertLayout addSubview: topicLabel];
    
    UILabel *contentLabel = [UILabel new];
    contentLabel.myTopMargin = contentLabel.myBottomMargin = 16;
    contentLabel.myLeftMargin = contentLabel.myRightMargin = 16;
    contentLabel.font = [UIFont systemFontOfSize: 18];
    contentLabel.textColor = [UIColor firstGrey];
    if ([wTools objectExists: self.evtTitle]) {
        contentLabel.text = self.evtTitle;
        [LabelAttributeStyle changeGapString: contentLabel content: self.evtTitle];
    }
    contentLabel.numberOfLines = 0;
    contentLabel.wrapContentHeight = YES;
    [self.vertLayout addSubview: contentLabel];
    
    UILabel *activityLabel = [UILabel new];
    activityLabel.myTopMargin = 16;
    activityLabel.myRightMargin = 16;
    activityLabel.text = @"活動詳情";
    [LabelAttributeStyle changeGapString: activityLabel content: @"活動詳情"];
    activityLabel.textColor = [UIColor firstMain];
    activityLabel.font = [UIFont boldSystemFontOfSize: 18];
    [activityLabel sizeToFit];
    [self.vertLayout addSubview: activityLabel];
    
    UITapGestureRecognizer *activityTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(activityLabelTap)];
    activityLabel.userInteractionEnabled = YES;
    [activityLabel addGestureRecognizer: activityTap];
    
    self.vertLayout.wrapContentHeight = YES;
    
    NSLog(@"self.scrollView.contentSize: %@", NSStringFromCGSize(self.scrollView.contentSize));
}

- (void)showExchangeInfoTouchDown:(UIButton *)sender {
    NSLog(@"showExchangeInfoTouchDown");
    //sender.backgroundColor = [UIColor thirdMain];
}

- (void)showExchangeInfoTouchUpInside:(UIButton *)sender {
    NSLog(@"showExchangeInfoTouchUpInside");
    //sender.backgroundColor = [UIColor clearColor];
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL: [NSURL URLWithString: self.specialUrl] entersReaderIfAvailable: NO];
    safariVC.preferredBarTintColor = [UIColor whiteColor];
    [self presentViewController: safariVC animated: YES completion: nil];
}

- (void)showExchangeInfoTouchUpOutside:(UIButton *)sender {
    NSLog(@"showExchangeInfoTouchUpOutside");
    //sender.backgroundColor = [UIColor clearColor];
}

- (void)activityLabelTap {
    NSLog(@"activityLabelTap");
    NSURL *URL = [NSURL URLWithString: self.urlString];
    
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL: URL entersReaderIfAvailable: NO];
    safariVC.preferredBarTintColor = [UIColor whiteColor];
    [self presentViewController: safariVC animated: YES completion: nil];
}

- (void)viewDidLayoutSubviews {
    NSLog(@"\nviewDidLayoutSubviews");
    for (UIView *v1 in self.vertLayout.subviews) {
        //NSLog(@"v1.accessibilityIdentifierl: %@", v1.accessibilityIdentifier);

        if ([v1.accessibilityIdentifier isEqualToString: @"bgView"]) {
            NSLog(@"v1.accessibilityIdentifierl: %@", v1.accessibilityIdentifier);
            [v1 updateConstraints];
//            CGRect rect = v1.frame;
//            rect.size.height = imageHeight;
//            v1.frame = rect;

            NSLog(@"v1: %@", v1);

            for (UIView *v2 in v1.subviews) {
                NSLog(@"v2.accessibilityIdentifier: %@", v2.accessibilityIdentifier);
                NSLog(@"v2: %@", v2);
            }
        }
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 1136:
                printf("iPhone 5 or 5S or 5C");
                self.toolBarViewHeight.constant = kToolBarViewHeight;
                break;
            case 1334:
                printf("iPhone 6/6S/7/8");
                self.toolBarViewHeight.constant = kToolBarViewHeight;
                break;
            case 1920:
                printf("iPhone 6+/6S+/7+/8+");
                self.toolBarViewHeight.constant = kToolBarViewHeight;
                break;
            case 2208:
                printf("iPhone 6+/6S+/7+/8+");
                self.toolBarViewHeight.constant = kToolBarViewHeight;
                break;
            case 2436:
                printf("iPhone X");
                self.toolBarViewHeight.constant = kToolBarViewHeightForX;
                break;
            default:
                printf("unknown");
                self.toolBarViewHeight.constant = kToolBarViewHeight;
                break;
        }
    }
}

#pragma mark - IBAction Methods

- (IBAction)backBtnPress:(id)sender {
    //[self.navigationController popViewControllerAnimated: YES];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav popViewControllerAnimated: YES];
}

- (IBAction)eventPostBtnPress:(id)sender {
    NSLog(@"");
    NSLog(@"eventPostBtnPress");
    NSLog(@"self.eventFinished: %d", self.eventFinished);
    
    if (!self.eventFinished) {
        //[self getExistedAlbum];
        NewExistingAlbumViewController *newExistingAlbumVC = [[UIStoryboard storyboardWithName: @"NewExistingAlbumVC" bundle: nil] instantiateViewControllerWithIdentifier: @"NewExistingAlbumViewController"];
        newExistingAlbumVC.templateArray = self.templateArray;
        newExistingAlbumVC.eventId = self.eventId;
        newExistingAlbumVC.contributionNumber = self.contributionNumber;
        newExistingAlbumVC.prefixText = self.prefixText;
        newExistingAlbumVC.specialUrl = self.specialUrl;
        
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.myNav pushViewController: newExistingAlbumVC animated: YES];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"" message: @"活動結束" preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction *okBtn = [UIAlertAction actionWithTitle: @"OK" style: UIAlertActionStyleDefault handler: nil];
        [alert addAction: okBtn];
        [self presentViewController: alert animated: YES completion: nil];
    }
}

- (void)getExistedAlbum {
    NSLog(@"getExistedAlbum");
    existedAlbumArray = [[NSMutableArray alloc] init];
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    NSString *limit = [NSString stringWithFormat: @"%d, %d", 0, 10000];
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *response = [boxAPI getcalbumlist: [UserInfo getUserID]
                                             token: [UserInfo getUserToken]
                                              rank: @"mine"
                                             limit: limit];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [wTools HideMBProgressHUD];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog( @"NSException caught");
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason);
                return;
            }
            if (response != nil) {
                NSLog(@"response from getcalbumlist");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"NewEventPostViewController");
                    NSLog(@"getExistedAlbum");
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getExistedAlbum"];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    NSLog(@"getcalbumlist");
                    [wself processExistAlbums:dic];
                }
            }
        });
    });
}
- (void)processExistAlbums:(NSDictionary *)dic {
    if ([dic[@"result"] intValue] == 1) {
        NSArray *array = dic[@"data"];
        NSLog(@"array: %@", array);
        
        if (![wTools objectExists: array]) {
            return;
        }
        
        for (int i = 0; i < array.count; i++) {
            NSString *act = array[i][@"album"][@"act"];
            NSInteger zipped = [array[i][@"album"][@"zipped"] intValue];
            
            if (![wTools objectExists: act]) {
                return;
            }
            
            if (([act isEqualToString: @"open"]) && (zipped == 1)) {
                NSLog(@"self.templateArray: %@", self.templateArray);
                
                for (int j = 0; j < self.templateArray.count; j++) {
                    NSString *currentTemplateId = [array[i][@"template"][@"template_id"] stringValue];
                    
                    if (![wTools objectExists: currentTemplateId]) {
                        return;
                    }
                    
                    if ([currentTemplateId isEqualToString: [self.templateArray[j] stringValue]]) {
                        //NSLog(@"same template");
                        //NSLog(@"array[i]: %@", array[i]);
                        
                        NSMutableDictionary *dict1 = [[NSMutableDictionary alloc] init];
                        [dict1 setValue: array[i][@"album"][@"album_id"] forKey: @"albumId"];
                        [dict1 setValue: array[i][@"album"][@"cover"] forKey: @"cover"];
                        [dict1 setValue: array[i][@"album"][@"description"] forKey: @"description"];
                        [dict1 setValue: array[i][@"album"][@"name"] forKey: @"name"];
                        
                        NSArray *eventArray = [[NSArray alloc] init];
                        eventArray = array[i][@"event"];
                        NSLog(@"eventArray: %@", eventArray);
                        NSLog(@"eventArray.count: %lu", (unsigned long)eventArray.count);
                        
                        NSMutableArray *eventArrayData = [[NSMutableArray alloc] init];
                        
                        for (int k = 0; k < eventArray.count; k++) {
                            [eventArrayData addObject: array[i][@"event"][k]];
                        }
                        //NSLog(@"eventArrayData: %@", eventArrayData);
                        
                        [dict1 setValue: eventArrayData forKey: @"eventArrayData"];
                        
                        [existedAlbumArray addObject: dict1];
                    }
                }
            }
        }
        NSLog(@"existedAlbumArray: %@", existedAlbumArray);
        NSLog(@"existedAlbumArray.count: %lu", (unsigned long)existedAlbumArray.count);
        
        currentContributionNumber = 0;
        
        if (![wTools objectExists: existedAlbumArray]) {
            return;
        }
        
        for (NSDictionary *d1 in existedAlbumArray) {
            NSLog(@"eventArrayData: %@", d1[@"eventArrayData"]);
            NSArray *array = d1[@"eventArrayData"];
            
            if (![wTools objectExists: array]) {
                return;
            }
            
            for (NSDictionary *d2 in array) {
                NSLog(@"self.eventId: %ld", (long)[self.eventId integerValue]);
                NSLog(@"event_id: %ld", (long)[d2[@"event_id"] integerValue]);
                
                if ([self.eventId integerValue] == [d2[@"event_id"] integerValue]) {
                    NSLog(@"Event Id is the same");
                    NSLog(@"contributionstatus: %ld", (long)[d2[@"contributionstatus"] integerValue]);
                    
                    if ([d2[@"contributionstatus"] integerValue] == 1) {
                        currentContributionNumber++;
                    }
                }
            }
        }
        NSLog(@"currentContributionNumber: %ld", (long)currentContributionNumber);
        
        if (currentContributionNumber > 0) {
            NSLog(@"currentContributionNumber > 0");
            [self.eventPostBtn setTitle: @"投稿/撤下" forState: UIControlStateNormal];
        } else {
            [self.eventPostBtn setTitle: @"立即投稿" forState: UIControlStateNormal];
        }
        NSLog(@"currentContributionNumber: %ld", (long)currentContributionNumber);
        [self initialValueSetup];
    } else if ([dic[@"result"] intValue] == 0) {
        NSLog(@"失敗：%@",dic[@"message"]);
        if ([wTools objectExists: dic[@"message"]]) {
            [self showCustomErrorAlert: dic[@"message"]];
        } else {
            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
        }
    } else {
        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
    }
}

#pragma mark - CustomActionSheet
- (void)showPostMode {
    NSLog(@"showPostMode");
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle: UIBlurEffectStyleDark];
    [UIView animateWithDuration: 0.5 animations:^{
        self.effectView = [[UIVisualEffectView alloc] initWithEffect: blurEffect];
    }];
    
    self.effectView.frame = self.view.frame;
    self.effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.effectView.myLeftMargin = self.effectView.myRightMargin = 0;
    self.effectView.myTopMargin = self.effectView.myBottomMargin = 0;
    self.effectView.alpha = 0.8;
    
    [self.view addSubview: self.effectView];
    [self.view addSubview: self.customPostActionSheet.view];
    [self.customPostActionSheet viewWillAppear: NO];
    
    [self.customPostActionSheet addSelectItem: @"" title: @"建立新作品" btnStr: @"" tagInt: 1 identifierStr: @"createNewAlbum"];
    [self.customPostActionSheet addSelectItem: @"" title: @"選擇現有作品" btnStr: @"" tagInt: 2 identifierStr: @"chooseExistedAlbum"];
    
    __weak typeof(self) weakSelf = self;
    
    self.customPostActionSheet.customViewBlock = ^(NSInteger tagId, BOOL isTouchDown, NSString *identifierStr) {
        NSLog(@"");
        NSLog(@"customPostActionSheet.customViewBlock executes");
        NSLog(@"tagId: %ld", (long)tagId);
        NSLog(@"isTouchDown: %d", isTouchDown);
        NSLog(@"identifierStr: %@", identifierStr);
        
        if ([identifierStr isEqualToString: @"createNewAlbum"]) {
            [weakSelf createNewAlbum];
        } else if ([identifierStr isEqualToString: @"chooseExistedAlbum"]) {
            [weakSelf chooseOldAlbum];
        }
    };
}

#pragma mark - DDAUIActionSheetViewController Method
- (void)actionSheetViewDidSlideOut:(DDAUIActionSheetViewController *)controller {
    NSLog(@"actionSheetViewDidSlideOut");
    //[self.fxBlurView removeFromSuperview];
    [self.effectView removeFromSuperview];
    self.effectView = nil;
}

#pragma mark -
- (void)createNewAlbum {
    [self checkPostedAlbum];
}

- (void)chooseOldAlbum {
    [alertViewForButton close];
    NewExistingAlbumViewController *newExistingAlbumVC = [[UIStoryboard storyboardWithName: @"NewExistingAlbumVC" bundle: nil] instantiateViewControllerWithIdentifier: @"NewExistingAlbumViewController"];
    newExistingAlbumVC.templateArray = self.templateArray;
    newExistingAlbumVC.eventId = self.eventId;
    newExistingAlbumVC.contributionNumber = self.contributionNumber;
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav pushViewController: newExistingAlbumVC animated: YES];
}

#pragma mark - Calling API Methods
- (void)processCheckPosted:(NSDictionary *)dic {
    if ([dic[@"result"] intValue] == 1) {
        NSArray *array = dic[@"data"];
        NSLog(@"array.count: %lu", (unsigned long)array.count);
        //NSLog(@"dic data: %@", array);
        
        if (![wTools objectExists: array]) {
            return;
        }
        
        for (int i = 0; i < array.count; i++) {
            NSString *act = array[i][@"album"][@"act"];
            
            if (![wTools objectExists: act]) {
                return;
            }
            
            if ([act isEqualToString: @"open"]) {
                NSLog(@"array: %@", array[i]);
                
                NSArray *eventArray = [[NSArray alloc] init];
                eventArray = array[i][@"event"];
                
                if (![wTools objectExists: eventArray]) {
                    return;
                }
                
                for (int k = 0; k < eventArray.count; k++) {
                    BOOL contributionStatus = [array[i][@"event"][k][@"contributionstatus"] boolValue];
                    NSString *eventIdCheck = array[i][@"event"][k][@"event_id"];
                    NSLog(@"contributionStatus: %d", contributionStatus);
                    
                    if (![wTools objectExists: eventIdCheck]) {
                        return;
                    }
                    
                    if ([eventIdCheck intValue] == [_eventId intValue]) {
                        NSLog(@"match eventId");
                        
                        if (contributionStatus) {
                            NSLog(@"joined post activity already");
                            NSLog(@"contributionStatus: %d", contributionStatus);
                            
                            checkPost = YES;
                            
                            dict = [[NSMutableDictionary alloc] init];
                            [dict setValue: array[i][@"album"][@"album_id"] forKey: @"albumId"];
                            [dict setValue: array[i][@"album"][@"cover"] forKey: @"cover"];
                            [dict setValue: array[i][@"album"][@"description"] forKey: @"description"];
                            [dict setValue: array[i][@"album"][@"name"] forKey: @"name"];
                            
                            NSLog(@"match eventId, posted already, dict:%@", dict);
                        }
                    }
                }
            }
        }
        
        NSLog(@"checkPost: %d", checkPost);
        
        if (checkPost) {
            [self showPostedInfo];
        } else {
            NSNumber *eventTemplateId = [self.templateArray objectAtIndex: 0];
            NSLog(@"eventTemplateId: %@", eventTemplateId);
            
            // Because the return value of element of Array is int
            if ([eventTemplateId intValue] == 0) {
                [self addNewFastMod];
            } else {
                [self toChooseTempalteVC];
            }
        }
    } else if ([dic[@"result"] intValue] == 0) {
        NSLog(@"失敗：%@",dic[@"message"]);
        if ([wTools objectExists: dic[@"message"]]) {
            [self showCustomErrorAlert: dic[@"message"]];
        } else {
            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
        }
    } else {
        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
    }
}

- (void)checkPostedAlbum {
    NSLog(@"checkPostedAlbum");
    
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    
    NSString *limit = [NSString stringWithFormat: @"%d, %d", 0, 10000];
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *response = [boxAPI getcalbumlist: [UserInfo getUserID]
                                             token: [UserInfo getUserToken]
                                              rank: @"mine"
                                             limit: limit];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [wTools HideMBProgressHUD];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog( @"NSException caught" );
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason );
                return;
            }
            if (response != nil) {
                NSLog(@"response from getcalbumlist");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"NewEventPostViewController");
                    NSLog(@"checkPostedAlbum");
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"checkPostedAlbum"];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    [wself processCheckPosted:dic];
                }
            }
        });
    });
}

- (void)toChooseTempalteVC {
    chooseTemplateVC = [[UIStoryboard storyboardWithName: @"ChooseTemplateVC" bundle: nil] instantiateViewControllerWithIdentifier: @"ChooseTemplateViewController"];
    chooseTemplateVC.rank = @"hot";
    chooseTemplateVC.event_id = self.eventId;
    chooseTemplateVC.postMode = YES;
    checkPost = NO;
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav pushViewController: chooseTemplateVC animated: YES];
}

- (void)showPostedInfo {
    OldCustomAlertView *alertView = [[OldCustomAlertView alloc] init];    
    [alertView setContainerView: [self createViewForPost]];
    [alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"取消", @"確定", nil]];
    
    __weak OldCustomAlertView *weakAlertView = alertView;
    [alertView setOnButtonTouchUpInside:^(OldCustomAlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
        [weakAlertView close];
        
        if (buttonIndex == 0) {
            
        } else if (buttonIndex == 1) {
            NSLog(@"Yes");
            [self postAlbum];
        }
    }];
    [alertView setUseMotionEffects: true];
    [alertView show];
}

- (UIView *)createViewForPost {
    UIView *view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 280, 220)];
    UIView *bgView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 280, 200)];
    
    //UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 10, bgView.bounds.size.width / 2, bgView.bounds.size.height)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(30, 30, 100, 100)];
    imageView.image = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString: [dict valueForKey: @"cover"]]]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    NSString *albumName = @"作品名稱";
    NSString *albumDescription = @"作品介紹";
    
    UITextView *textView = [[UITextView alloc] init];
    textView.font = [UIFont fontWithName: @"TrebuchetMS-Bold" size: 15.0f];
    textView.textColor = [UIColor firstGrey];
    textView.backgroundColor = [UIColor clearColor];
    textView.frame = CGRectMake(145, 10, bgView.bounds.size.width / 2, bgView.bounds.size.height - 50);
    textView.text = [NSString stringWithFormat: @"%@:\n%@\n\n\n%@:\n%@", albumName, [dict valueForKey: @"name"], albumDescription, [dict valueForKey: @"description"]];
    textView.userInteractionEnabled = NO;
    
    [bgView addSubview: imageView];
    [bgView addSubview: textView];
    
    UILabel *postLabel = [[UILabel alloc] initWithFrame: CGRectMake(8, view.bounds.size.height / 2 + 50,  view.bounds.size.width - 16, 70)];
    postLabel.textColor = [UIColor firstPink];
    postLabel.text = @"投稿作品數量已達上限，是否確認撤下該作品並建立新作品？（若確定，則原作品的投票數將會歸零）";;
    [LabelAttributeStyle changeGapString: postLabel content: @"投稿作品數量已達上限，是否確認撤下該作品並建立新作品？（若確定，則原作品的投票數將會歸零）"];
    //postLabel.textAlignment = NSTextAlignmentCenter;
    postLabel.font = [UIFont systemFontOfSize: 14.0f];
    postLabel.numberOfLines = 0;
    //postLabel.adjustsFontSizeToFitWidth = YES;
    
    [view addSubview: postLabel];
    [view addSubview: bgView];
    
    return view;
}

- (void)postAlbum {
    NSLog(@"postAlbum");
    
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *aid = [wself->dict valueForKey: @"albumId"];
        NSString *response = [boxAPI switchstatusofcontribution: [UserInfo getUserID]
                                                          token: [UserInfo getUserToken]
                                                       event_id: wself->_eventId
                                                       album_id: aid];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [wTools HideMBProgressHUD];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog( @"NSException caught" );
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason );
                return;
            }
            if (response != nil) {
                NSLog(@"response from switchstatusofcontribution");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"NewEventPostViewController");
                    NSLog(@"postAlbum");
                    
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"switchstatusofcontribution"];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        NSLog(@"post album success");
                        if (![wTools objectExists: dic[@"data"][@"event"][@"contributionstatus"]]) {
                            return;
                        }
                        int contributionCheck = [dic[@"data"][@"event"][@"contributionstatus"] boolValue];
                        NSLog(@"contributionCheck: %d", contributionCheck);
                        
                        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                        style.messageColor = [UIColor whiteColor];
                        style.backgroundColor = [UIColor secondGrey];
                        
                        [wself.view makeToast: @"取消投稿"
                                    duration: 2.0
                                    position: CSToastPositionBottom
                                       style: style];
                        
                        if (wself->checkPost) {
                            //[self.navigationController pushViewController: s2VC animated: YES];
                            NSNumber *eventTemplateId = [self.templateArray objectAtIndex: 0];
                            
                            NSLog(@"eventTemplateId: %@", eventTemplateId);
                            
                            // Because the return value of element of Array is int
                            if ([eventTemplateId intValue] == 0) {
                                [wself addNewFastMod];
                            } else {
                                [wself toChooseTempalteVC];
                                //[self.navigationController pushViewController: s2VC animated: YES];
                                //AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                                //[appDelegate.myNav pushViewController: s2VC animated: YES];
                            }
                        }
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗： %@", dic[@"message"]);
                        if ([wTools objectExists: dic[@"message"]]) {
                            [wself showCustomErrorAlert: dic[@"message"]];
                        } else {
                            [wself showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                        }
                    } else {
                        [wself showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            }
        });
    });
}

//快速套版
- (void)addNewFastMod {
    NSLog(@"addNewFastMod");
    
    //新增相本id
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI insertalbumofdiy: [UserInfo getUserID]
                                               token: [UserInfo getUserToken]
                                         template_id: @"0"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [wTools HideMBProgressHUD];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog( @"NSException caught" );
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason );
                return;
            }
            if (response != nil) {
                NSLog(@"response from insertalbumofdiy");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"NewEventPostViewController");
                    NSLog(@"addNewFastMod");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"insertalbumofdiy"];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([dic[@"result"]boolValue]) {
                        NSLog(@"get result value from insertalbumofdiy");
                        NSString *tempAlbumId = [dic[@"data"] stringValue];
                        
                        if (![wTools objectExists: tempAlbumId]) {
                            return;
                        }
                        if (![wTools objectExists: self.eventId]) {
                            return;
                        }
                        AlbumCreationViewController *albumCreationVC = [[UIStoryboard storyboardWithName: @"AlbumCreationVC" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumCreationViewController"];
                        albumCreationVC.albumid = tempAlbumId;
                        albumCreationVC.templateid = @"0";
                        albumCreationVC.choice = @"Fast";
                        albumCreationVC.event_id = self.eventId;
                        albumCreationVC.postMode = YES;
                        albumCreationVC.isNew = YES;
                        //[self.navigationController pushViewController: albumCreationVC animated: YES];
                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        [appDelegate.myNav pushViewController: albumCreationVC animated: YES];
                    } else {
                        NSLog(@"失敗： %@", dic[@"message"]);
                        if ([wTools objectExists: dic[@"message"]]) {
                            [self showCustomErrorAlert: dic[@"message"]];
                        } else {
                            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                        }
                    }
                }
            }
        });
    });
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Custom Error Alert Method
- (void)showCustomErrorAlert: (NSString *)msg {
    [UIViewController showCustomErrorAlertWithMessage:msg onButtonTouchUpBlock:^(CustomIOSAlertView *customAlertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[customAlertView tag]);
        [customAlertView close];
    }];
}

#pragma mark - Custom Method for TimeOut
- (void)showCustomTimeOutAlert: (NSString *)msg
                  protocolName: (NSString *)protocolName {
    CustomIOSAlertView *alertTimeOutView = [[CustomIOSAlertView alloc] init];    
    [alertTimeOutView setContainerView: [self createTimeOutContainerView: msg]];
    
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertTimeOutView.arrangeStyle = @"Horizontal";
    
    alertTimeOutView.parentView = self.view;
    [alertTimeOutView setButtonTitles: [NSMutableArray arrayWithObjects: NSLocalizedString(@"TimeOut-CancelBtnTitle", @""), NSLocalizedString(@"TimeOut-OKBtnTitle", @""), nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertTimeOutView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor clearColor], [UIColor clearColor],nil]];
    [alertTimeOutView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstGrey], nil]];
    [alertTimeOutView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    //alertView.arrangeStyle = @"Vertical";
    
    __weak typeof(self) weakSelf = self;
    __weak CustomIOSAlertView *weakAlertTimeOutView = alertTimeOutView;
    [alertTimeOutView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertTimeOutView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertTimeOutView tag]);
        [weakAlertTimeOutView close];
        
        if (buttonIndex == 0) {
            
        } else {
            if ([protocolName isEqualToString: @"getExistedAlbum"]) {
                [weakSelf getExistedAlbum];
            } else if ([protocolName isEqualToString: @"checkPostedAlbum"]) {
                [weakSelf checkPostedAlbum];
            } else if ([protocolName isEqualToString: @"switchstatusofcontribution"]) {
                [weakSelf postAlbum];
            } else if ([protocolName isEqualToString: @"insertalbumofdiy"]) {
                [weakSelf addNewFastMod];
            }                        
        }
    }];
    [alertTimeOutView setUseMotionEffects: YES];
    [alertTimeOutView show];
}

- (UIView *)createTimeOutContainerView: (NSString *)msg {
    // TextView Setting
    UITextView *textView = [[UITextView alloc] initWithFrame: CGRectMake(10, 30, 280, 20)];
    textView.text = msg;
    textView.backgroundColor = [UIColor clearColor];
    textView.textColor = [UIColor whiteColor];
    textView.font = [UIFont systemFontOfSize: 16];
    textView.editable = NO;
    
    // Adjust textView frame size for the content
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits: CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    
    NSLog(@"newSize.height: %f", newSize.height);
    
    // Set the maximum value for newSize.height less than 400, otherwise, users can see the content by scrolling
    if (newSize.height > 300) {
        newSize.height = 300;
    }
    
    // Adjust textView frame size when the content height reach its maximum
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    textView.frame = newFrame;
    
    CGFloat textViewY = textView.frame.origin.y;
    NSLog(@"textViewY: %f", textViewY);
    
    CGFloat textViewHeight = textView.frame.size.height;
    NSLog(@"textViewHeight: %f", textViewHeight);
    NSLog(@"textViewY + textViewHeight: %f", textViewY + textViewHeight);
    
    
    // ImageView Setting
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(200, -8, 128, 128)];
    [imageView setImage:[UIImage imageNamed:@"icon_2_0_0_dialog_pinpin.png"]];
    
    CGFloat viewHeight;
    
    if ((textViewY + textViewHeight) > 96) {
        if ((textViewY + textViewHeight) > 450) {
            viewHeight = 450;
        } else {
            viewHeight = textViewY + textViewHeight;
        }
    } else {
        viewHeight = 96;
    }
    NSLog(@"demoHeight: %f", viewHeight);
    
    
    // ContentView Setting
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, viewHeight)];
    //contentView.backgroundColor = [UIColor firstPink];
    contentView.backgroundColor = [UIColor firstMain];
    
    // Set up corner radius for only upper right and upper left corner
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect: contentView.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(13.0, 13.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.view.bounds;
    maskLayer.path  = maskPath.CGPath;
    contentView.layer.mask = maskLayer;
    
    // Add imageView and textView
    [contentView addSubview: imageView];
    [contentView addSubview: textView];
    
    NSLog(@"");
    NSLog(@"contentView: %@", NSStringFromCGRect(contentView.frame));
    NSLog(@"");
    
    return contentView;
}

@end
