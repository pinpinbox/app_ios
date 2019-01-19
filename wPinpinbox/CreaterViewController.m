//
//  CreaterViewController.m
//  wPinpinbox
//
//  Created by David on 4/23/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "CreaterViewController.h"

#import "MyLayout.h"
#import "UIColor+Extensions.h"
#import "boxAPI.h"
#import "wTools.h"
#import "LabelAttributeStyle.h"
#import "UIView+Toast.h"
#import "JCCollectionViewWaterfallLayout.h"
#import "CreatorCollectionViewCell.h"
#import "CreatorCollectionReusableView.h"
#import "AsyncImageView.h"
#import <SafariServices/SafariServices.h>
#import "CustomIOSAlertView.h"
#import "OldCustomAlertView.h"
#import "AlbumDetailViewController.h"
#import "GlobalVars.h"
#import "AppDelegate.h"
#import "UIColor+HexString.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BuyPPointViewController.h"
#import "MessageboardViewController.h"
#import "UIViewController+ErrorAlert.h"

#import "YAlbumDetailContainerViewController.h"

static NSString *sharingLink = @"http://www.pinpinbox.com/index/album/content/?album_id=%@%@";
//static NSString *userIdSharingLink = @"http://www.pinpinbox.com/index/creative/content/?user_id=%@%@";
static NSString *autoPlayStr = @"&autoplay=1";

@interface CreaterViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, JCCollectionViewWaterfallLayoutDelegate, UIGestureRecognizerDelegate, MessageboardViewControllerDelegate,SFSafariViewControllerDelegate>
{
    NSMutableArray *pictures;
    BOOL isLoading;
    NSInteger  nextId;
    BOOL isReloading;
    
    NSDictionary *userDic;
    NSDictionary *followDic;
    NSDictionary *sponsorDic;
    
    CGFloat createNameLabelHeight;
    CGFloat nameLabelHeight;
    CGFloat descriptionLabelHeight;
    
    NSInteger socialLinkInt;
    NSInteger sponsorInt;
    
    NSString *profilePicUrlString;
    
    NSInteger columnCount;
    NSInteger miniInteriorSpacing;
    
    CGFloat coverImageHeight;
    CGFloat creativeNameLabelHeight;
    CGFloat linkBgViewHeight;
    
    // For Showing Message of Getting Point
    NSString *missionTopicStr;
    NSString *rewardType;
    NSString *rewardValue;
    NSString *eventUrl;
    
    NSString *restriction;
    NSString *restrictionValue;
    NSUInteger numberOfCompleted;
    
    OldCustomAlertView *alertView;

    UIView *noInfoView;
    BOOL isNoInfoViewCreate;
}

@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarHeight;

@property (nonatomic, strong) JCCollectionViewWaterfallLayout *jccLayout;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (weak, nonatomic) IBOutlet UIButton *followBtn;

@property (nonatomic) MessageboardViewController *customMessageActionSheet;
@property (nonatomic) UIVisualEffectView *effectView;

@end

@implementation CreaterViewController

#pragma mark - View Related
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"");
    NSLog(@"CreaterViewController");
    NSLog(@"viewDidLoad");
    NSLog(@"self.userId: %@", self.userId);
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.delegate = self;
    
    [self initialValueSetup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"");
    NSLog(@"viewWillAppear");
    
    for (UIView *view in self.tabBarController.view.subviews) {
        UIButton *btn = (UIButton *)[view viewWithTag: 104];
        btn.hidden = YES;
    }
    [self loadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.enabled = YES;
    [wTools sendScreenTrackingWithScreenName:@"用戶專區"];
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

#pragma mark -
- (void)initialValueSetup {
    NSLog(@"");
    NSLog(@"initialValueSetup");
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 1136:
                printf("iPhone 5 or 5S or 5C");
                self.navBarHeight.constant = 48;
                self.collectionView.contentInset = UIEdgeInsetsMake(48, 0, 0, 0);
                break;
            case 1334:
                printf("iPhone 6/6S/7/8");
                self.navBarHeight.constant = 48;
                self.collectionView.contentInset = UIEdgeInsetsMake(48, 0, 0, 0);
                break;
            case 1920:
                printf("iPhone 6+/6S+/7+/8+");
                self.navBarHeight.constant = 48;
                self.collectionView.contentInset = UIEdgeInsetsMake(48, 0, 0, 0);
                break;
            case 2208:
                printf("iPhone 6+/6S+/7+/8+");
                self.navBarHeight.constant = 48;
                self.collectionView.contentInset = UIEdgeInsetsMake(48, 0, 0, 0);
                break;
            case 2436:
                printf("iPhone X");
                self.navBarHeight.constant = 48;
                self.collectionView.contentInset = UIEdgeInsetsMake(48, 0, 0, 0);
                break;
            default:
                printf("unknown");
                self.navBarHeight.constant = 48;
                self.collectionView.contentInset = UIEdgeInsetsMake(48, 0, 0, 0);
                break;
        }
    }

    nextId = 0;
    isLoading = NO;
    isReloading = NO;
    
    pictures = [NSMutableArray new];
    userDic = [NSDictionary new];
    followDic = [NSDictionary new];
    sponsorDic = [NSDictionary new];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget: self
                            action: @selector(refresh)
                  forControlEvents: UIControlEventValueChanged];
    [self.collectionView addSubview: self.refreshControl];
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    self.navBarView.backgroundColor = [UIColor barColor];
    
    columnCount = 2;
    miniInteriorSpacing = 16;
    
    self.customMessageActionSheet = [[MessageboardViewController alloc] init];
    self.customMessageActionSheet.delegate = self;
    
    noInfoView.hidden = YES;
    isNoInfoViewCreate = NO;
}
 
- (void)refresh {
    NSLog(@"");
    NSLog(@"refresh");
    
    if (!isReloading) {
        isReloading = YES;
        nextId = 0;
        isLoading = NO;
        [self loadData];
    }
}

#pragma mark - Web Service
- (void)loadData {
    NSLog(@"");
    NSLog(@"loadData");
    NSLog(@"follow: %d", self.follow);
    
    // If isLoading is NO then run the following code
    if (!isLoading) {
        if (nextId == 0) {
            NSLog(@"nextId: %ld", (long)nextId);
        }
        isLoading = YES;
        [self getCreator];
    }
}

- (void)getCreator {
    NSLog(@"");
    NSLog(@"getCreator");
    [wTools ShowMBProgressHUD];
    
    NSMutableDictionary *data = [NSMutableDictionary new];
    NSString *limit = [NSString stringWithFormat:@"%ld,%d",(long)nextId, 16];
    [data setValue: limit forKey: @"limit"];
    [data setObject: self.userId forKey: @"authorid"];
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSString *respnose = [boxAPI getcreative: [wTools getUserID]
                                           token: [wTools getUserToken]
                                            data: data];
        
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
            if (respnose != nil) {
                NSLog(@"response from getCreative is not nil");
                
                if ([respnose isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"CreaterViewController");
                    NSLog(@"getCreator");
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getcreative"
                                         albumId: @""];
                    
                    wself->isReloading = NO;
                } else {
                    NSLog(@"Get Real Response");
                    NSLog(@"response from getCreative");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respnose dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    [wself processCreatorResult:dic];
                }
            } else {
                [wself.refreshControl endRefreshing];
                wself->isReloading = NO;
            }
            [wself.refreshControl endRefreshing];
            wself->isReloading = NO;
        });
    });
}

- (void)processCreatorResult:(NSDictionary *)dic {
    if ([dic[@"result"] intValue] == 1) {
        userDic = dic[@"data"][@"user"];
        sponsorInt = [dic[@"data"][@"userstatistics"][@"besponsored"] intValue];
        NSLog(@"sponsorInt: %ld", (long)sponsorInt);
        
        if (nextId == 0) {
//            pictures = [NSMutableArray new];
            [pictures removeAllObjects];
        }
        
//        if (![wTools objectExists: dic[@"data"][@"album"]]) {
//            return;
//        }
        
        int s = 0;
        
        for (NSMutableDictionary *picture in [dic objectForKey:@"data"][@"album"]) {
            s++;
            [pictures addObject: picture];
        }
        nextId = nextId + s;
        
        NSLog(@"dic data follow: %@", dic[@"data"][@"follow"]);
        followDic = dic[@"data"][@"follow"];
        _follow = [dic[@"data"][@"follow"][@"follow"] boolValue];
        sponsorDic = dic[@"data"][@"userstatistics"];
        
        self.followBtn = [self changeFollowBtn: self.followBtn];
        
        if ([[NSString stringWithFormat:@"%@", _userId] isEqualToString:[wTools getUserID]]) {
            self.followBtn.hidden = YES;
        }
        
        [self.collectionView reloadData];
        [self.refreshControl endRefreshing];
        
        if (nextId >= 0)
            isLoading = NO;
        
        if (s == 0) {
            isLoading = YES;
        }
        [self layoutSetup];
        
        if (pictures.count == 0) {
            if (!isNoInfoViewCreate) {
                [self addNoInfoViewOnCollectionView: @"沒有作品展示"];
            }
            noInfoView.hidden = NO;
        } else if (pictures.count > 0) {
            noInfoView.hidden = YES;
        }
        
        isReloading = NO;
    } else if ([dic[@"result"] intValue] == 0) {
        NSLog(@"失敗：%@",dic[@"message"]);
        if ([wTools objectExists: dic[@"message"]]) {
            [self showCustomErrorAlert: dic[@"message"]];
        } else {
            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
        }
        [self.refreshControl endRefreshing];
        isReloading = NO;
    } else {
        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
        [self.refreshControl endRefreshing];
        isReloading = NO;
    }
}

- (void)addNoInfoViewOnCollectionView:(NSString *)msg {
    NSLog(@"addNoInfoViewOnCollectionView");
    if (!isNoInfoViewCreate) {
        noInfoView = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Vert];
        noInfoView.myTopMargin = 520;
        noInfoView.myLeftMargin = noInfoView.myRightMargin = 64;
        noInfoView.backgroundColor = [UIColor thirdGrey];
        noInfoView.layer.cornerRadius = 16;
        noInfoView.clipsToBounds = YES;
        [self.collectionView addSubview: noInfoView];
        
        MyFrameLayout *frameLayout = [self createFrameLayout];
        [noInfoView addSubview: frameLayout];
        
        UILabel *label = [self createLabel: msg];
        [frameLayout addSubview: label];
    }
    isNoInfoViewCreate = YES;
}

- (MyFrameLayout *)createFrameLayout {
    MyFrameLayout *frameLayout = [MyFrameLayout new];
    frameLayout.wrapContentHeight = YES;
    frameLayout.myMargin = 0;
    frameLayout.myCenterXOffset = 0;
    frameLayout.myCenterYOffset = 0;
    frameLayout.padding = UIEdgeInsetsMake(32, 32, 32, 32);
    return frameLayout;
}

- (UILabel *)createLabel: (NSString *)title {
    UILabel *label = [UILabel new];
    label.wrapContentHeight = YES;
    label.myLeftMargin = label.myRightMargin = 8;
    label.numberOfLines = 0;
    label.text = title;
    [LabelAttributeStyle changeGapStringAndLineSpacingCenterAlignment: label content: label.text];
    label.font = [UIFont systemFontOfSize: 17];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor firstGrey];
    [label sizeToFit];
    return label;
}

#pragma mark - JCCLayout Setup
- (void)layoutSetup {
    NSLog(@"");
    NSLog(@"layoutSetup");
    // ScrollView contentInset Top is navigationBar Height 64
    self.jccLayout = (JCCollectionViewWaterfallLayout *)self.collectionView.collectionViewLayout;
    NSLog(@"self.jccLayout.headerHeight: %f", self.jccLayout.headerHeight);
    
    // Social Link
    NSLog(@"socialLink: %@", userDic[@"sociallink"]);
    
    socialLinkInt = 0;
    
    if (![userDic[@"sociallink"] isKindOfClass: [NSNull class]]) {
        if (![userDic[@"sociallink"][@"facebook"] isEqualToString: @""])
            socialLinkInt++;
        if (![userDic[@"sociallink"][@"google"] isEqualToString: @""])
            socialLinkInt++;
        if (![userDic[@"sociallink"][@"instagram"] isEqualToString: @""])
            socialLinkInt++;
        if (![userDic[@"sociallink"][@"linkedin"] isEqualToString: @""])
            socialLinkInt++;
        if (![userDic[@"sociallink"][@"pinterest"] isEqualToString: @""])
            socialLinkInt++;
        if (![userDic[@"sociallink"][@"twitter"] isEqualToString: @""])
            socialLinkInt++;
        if (![userDic[@"sociallink"][@"web"] isEqualToString: @""])
            socialLinkInt++;
        if (![userDic[@"sociallink"][@"youtube"] isEqualToString: @""])
            socialLinkInt++;
    }
    NSLog(@"socialLinkInt: %ld", (long)socialLinkInt);
    self.jccLayout.headerHeight = 300;
}

#pragma mark - Helper Method
- (CGFloat)coverImageHeightCalculation {
    NSLog(@"coverImageHeightCalculation");
    NSLog(@"self.collectionView.frame.size.width: %f", self.collectionView.frame.size.width);
    CGFloat height = (self.collectionView.frame.size.width * 450) / 960;
    NSLog(@"height: %f", height);
    return height;
}

- (CGFloat)headerHeightCalculation {
    CGFloat headerHeight = 0;
    //headerHeight += coverImageHeight + 32 * 3 + creativeNameLabelHeight + 32 + 67 + 32;
    headerHeight += coverImageHeight + 32 + 32 * 2;
    
    if (![userDic[@"sociallink"] isEqual: [NSNull null]]) {
        if (socialLinkInt != 0) {
            NSLog(@"socialLinkInt: %ld", (long)socialLinkInt);
            headerHeight += 61.5;
        }
    }
    // linkBgView
    headerHeight += 67 + 32;
    
    if (![userDic[@"sociallink"] isEqual: [NSNull null]]) {
        if (socialLinkInt != 0) {
            NSLog(@"socialLinkInt: %ld", (long)socialLinkInt);
            headerHeight += 32;
        } else if (socialLinkInt == 0) {
            NSLog(@"socialLinkInt: %ld", (long)socialLinkInt);
        }
    } else {
        NSLog(@"userDic socialLink: %@", userDic[@"sociallink"]);
    }
//    headerHeight += 1 + 32 + 26.5 + 16;
    headerHeight += 1 + 26.5 + 16;
    
    // Add 20 for banner doesn't look to be compressed
    headerHeight += 20;
    
    return headerHeight;
}

- (NSString *)numberConversion: (NSInteger)number {
    NSLog(@"number: %ld", (long)number);
    NSString *numberStr;
    
    if (number >= 1000000) {
        number = number / 100000;
        numberStr = [NSString stringWithFormat: @"%ldM", (long)number];
    } else if (number >= 1000) {
        number = number / 1000;
        numberStr = [NSString stringWithFormat: @"%ldK", (long)number];
    } else {
        numberStr = [NSString stringWithFormat: @"%ld", (long)number];
    }
    NSLog(@"numberStr: %@", numberStr);
    
    return numberStr;
}

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSLog(@"");
    NSLog(@"numberOfSectionsInCollectionView");
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    NSLog(@"");
    NSLog(@"numberOfItemsInSection");
    NSLog(@"pictures.count: %lu", (unsigned long)pictures.count);
    return pictures.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"");
    NSLog(@"viewForSupplementaryElementOfKind");
    NSLog(@"userDic: %@", userDic);
    NSLog(@"followDic: %@", followDic);
    CreatorCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind: kind withReuseIdentifier: @"headerId" forIndexPath: indexPath];
    [LabelAttributeStyle changeGapStringAndLineSpacingCenterAlignment: headerView.viewedLabel content: headerView.viewedLabel.text];
    [LabelAttributeStyle changeGapStringAndLineSpacingCenterAlignment: headerView.likeLabel content: headerView.likeLabel.text];
    [LabelAttributeStyle changeGapStringAndLineSpacingCenterAlignment: headerView.sponsoredLabel content: headerView.sponsoredLabel.text];
    
    NSLog(@"cover: %@", userDic[@"cover"]);
    
    // Cover Image
    if ([userDic[@"cover"] isEqual: [NSNull null]]) {
        NSLog(@"cover is null");
        headerView.coverImageView.image = [UIImage imageNamed: @"bg200_user_default"];
    } else {
        NSLog(@"cocer is not null");
        [headerView.coverImageView sd_setImageWithURL: [NSURL URLWithString: userDic[@"cover"]]
                                     placeholderImage: [UIImage imageNamed: @"bg200_user_default"]];
    }
//    headerView.coverImageHeightConstraint.constant = [self coverImageHeightCalculation];
//    coverImageHeight = headerView.coverImageHeightConstraint.constant;
    headerView.coverImageBgVHeightConstraint.constant = [self coverImageHeightCalculation];
    coverImageHeight = headerView.coverImageBgVHeightConstraint.constant;
    
    if (headerView.gradientView.layer.sublayers.count > 0) {
        for (CALayer *layer in headerView.gradientView.layer.sublayers) {
            [layer removeFromSuperlayer];
        }
    }
    
    // Graident Effect for Gradient View
    CAGradientLayer *gradientLayer;
    gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, coverImageHeight);
    gradientLayer.colors = @[(id)[UIColor colorFromHexString: @"#32000000"].CGColor, (id)[UIColor colorFromHexString: @"#000000"].CGColor];
    [headerView.gradientView.layer insertSublayer: gradientLayer atIndex: 0];
    headerView.gradientView.alpha = 0.5;
    
    NSLog(@"headerView.gradientView.layer.sublayers: %@", headerView.gradientView.layer.sublayers);
    
    // User Picture ImageView
    headerView.userPictureImageView.backgroundColor = [UIColor thirdGrey];
    NSString *profilePic = [wTools stringisnull: userDic[@"picture"]];
    NSLog(@"profilePic: %@", profilePic);
    NSLog(@"profilePicUrlString: %@", profilePicUrlString);
    
    if (profilePicUrlString != nil) {
        NSLog(@"profilePicUrlString is not null");
        if (![profilePicUrlString isEqualToString: @""]) {
            if (![profilePicUrlString isEqualToString: profilePic]) {
                profilePic = profilePicUrlString;
            }
        }
    }
    if (profilePic != nil) {
        NSLog(@"profilePic is not NSNull class");
        
        if (![profilePic isEqualToString: @""]) {
            [headerView.userPictureImageView sd_setImageWithURL: [NSURL URLWithString: profilePic]];
        } else {
            headerView.userPictureImageView.image = [UIImage imageNamed: @"member_back_head.png"];
        }
    }
    
    // User Name Label
    if (![userDic[@"name"] isEqual: [NSNull null]]) {
        headerView.userNameLabel.text = userDic[@"name"];
        [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: headerView.userNameLabel content: headerView.userNameLabel.text];
    }
    
    // Creative Name Label
    if (![userDic[@"creative_name"] isEqual: [NSNull null]]) {
        headerView.creativeNameLabel.text = userDic[@"creative_name"];
        [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: headerView.creativeNameLabel content: headerView.creativeNameLabel.text];
        
        if ([userDic[@"creative_name"] isEqualToString: @""]) {
            headerView.gradientView.hidden = YES;
        } else {
            headerView.gradientView.hidden = NO;
        }
    } else {
        headerView.gradientView.hidden = YES;
    }
    
    // Number Section
    if (![userDic[@"viewed"] isEqual: [NSNull null]]) {
        headerView.viewedNumberLabel.text = [self numberConversion: [userDic[@"viewed"] integerValue]];
    }
    if (![followDic[@"count_from"] isEqual: [NSNull null]]) {
        headerView.likeNumberLabel.text = [self numberConversion: [followDic[@"count_from"] integerValue]];
    }
    if (![sponsorDic[@"besponsored"] isEqual: [NSNull null]]) {
        if ([sponsorDic[@"besponsored"] integerValue] == 0) {
            NSLog(@"besponsored == 0");
            headerView.sponsoredStackView.hidden = YES;
        } else if ([sponsorDic[@"besponsored"] integerValue] > 0) {
            NSLog(@"besponsored > 0");
            headerView.sponsoredStackView.hidden = NO;
            headerView.sponsoredNumberLabel.text = [self numberConversion: [sponsorDic[@"besponsored"] integerValue]];
        }
    }
    
    // Link Section
    NSString *linkLabelStr;
    
    if (![userDic[@"sociallink"] isEqual: [NSNull null]]) {
        if (socialLinkInt != 0) {
            // linkBgView has to set up first, otherwise the subViews element can't show up
            // because there is no container
            headerView.linkLabel.hidden = NO;
            headerView.linkBgView.hidden = NO;
            headerView.linkBgViewHeight.constant = 61.5;
            headerView.linkBgViewBottomConstraint.constant = 32;
            
            NSLog(@"socialLinkInt: %ld", (long)socialLinkInt);
            
            //linkLabelStr = [NSString stringWithFormat: @"%@的連結", userDic[@"name"]];
            linkLabelStr = [NSString stringWithFormat: @"連結"];
            headerView.linkLabel.text = linkLabelStr;
            [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: headerView.linkLabel content: headerView.linkLabel.text];
            
            if ([wTools objectExists: userDic[@"sociallink"][@"facebook"]]) {
                if ([userDic[@"sociallink"][@"facebook"] isEqualToString: @""]) {
                    headerView.fbBtn.hidden = YES;
                } else {
                    headerView.fbBtn.hidden = NO;
                }
            }
            if ([wTools objectExists: userDic[@"sociallink"][@"google"]]) {
                if ([userDic[@"sociallink"][@"google"] isEqualToString: @""]) {
                    headerView.googlePlusBtn.hidden = YES;
                } else {
                    headerView.googlePlusBtn.hidden = NO;
                }
            }
            if ([wTools objectExists: userDic[@"sociallink"][@"instagram"]]) {
                if ([userDic[@"sociallink"][@"instagram"] isEqualToString: @""]) {
                    headerView.igBtn.hidden = YES;
                } else {
                    headerView.igBtn.hidden = NO;
                }
            }
            if ([wTools objectExists: userDic[@"sociallink"][@"linkedin"]]) {
                if ([userDic[@"sociallink"][@"linkedin"] isEqualToString: @""]) {
                    headerView.linkedInBtn.hidden = YES;
                } else {
                    headerView.linkedInBtn.hidden = NO;
                }
            }
            if ([wTools objectExists: userDic[@"sociallink"][@"pinterest"]]) {
                if ([userDic[@"sociallink"][@"pinterest"] isEqualToString: @""]) {
                    headerView.pinterestBtn.hidden = YES;
                } else {
                    headerView.pinterestBtn.hidden = NO;
                }
            }
            if ([wTools objectExists: userDic[@"sociallink"][@"twitter"]]) {
                if ([userDic[@"sociallink"][@"twitter"] isEqualToString: @""]) {
                    headerView.twitterBtn.hidden = YES;
                } else {
                    headerView.twitterBtn.hidden = NO;
                }
            }
            if ([wTools objectExists: userDic[@"sociallink"][@"web"]]) {
                if ([userDic[@"sociallink"][@"web"] isEqualToString: @""]) {
                    headerView.webBtn.hidden = YES;
                } else {
                    headerView.webBtn.hidden = NO;
                }
            }
            if ([wTools objectExists: userDic[@"sociallink"][@"youtube"]]) {
                if ([userDic[@"sociallink"][@"youtube"] isEqualToString: @""]) {
                    headerView.youtubeBtn.hidden = YES;
                } else {
                    headerView.youtubeBtn.hidden = NO;
                }
            }
        } else if (socialLinkInt == 0) {
            NSLog(@"socialLinkInt: %ld", (long)socialLinkInt);
            headerView.linkLabel.hidden = YES;
            headerView.linkBgView.hidden = YES;
            headerView.linkBgViewHeight.constant = 0;
            headerView.linkBgViewBottomConstraint.constant = 0;
        }
    } else {
        NSLog(@"userDic socialLink: %@", userDic[@"sociallink"]);
        headerView.linkLabel.hidden = YES;
        headerView.linkBgView.hidden = YES;
        headerView.linkBgViewHeight.constant = 0;
        headerView.linkBgViewBottomConstraint.constant = 0;
    }
    linkBgViewHeight = headerView.linkBgView.frame.size.height;
    NSLog(@"linkBgViewHeight: %f", linkBgViewHeight);
    
    self.jccLayout.headerHeight = [self headerHeightCalculation];
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    return headerView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"");
    NSLog(@"cellForItemAtIndexPath");
    CreatorCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"Creator" forIndexPath: indexPath];
    NSDictionary *data = pictures[indexPath.row];
    cell.contentView.subviews[0].backgroundColor = nil;
    
    if ([data[@"cover"] isEqual: [NSNull null]]) {
        cell.coverImageView.image = [UIImage imageNamed: @"bg_2_0_0_no_image"];
        //cell.coverImageView.image = [UIImage imageNamed: @"bg200_no_image.jpg"];
    } else {
        [cell.coverImageView sd_setImageWithURL: [NSURL URLWithString: data[@"cover"]]];
        
        if ([wTools objectExists: data[@"cover_hex"]]) {
            cell.coverImageView.backgroundColor = [UIColor colorFromHexString: data[@"cover_hex"]];
        } else {
            cell.coverImageView.backgroundColor = [UIColor clearColor];
        }
        /*
        [cell.coverImageView sd_setImageWithURL:[NSURL URLWithString: data[@"cover"]] placeholderImage:[UIImage imageNamed:@"bg_2_0_0_no_image"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (error) {
            cell.coverImageView.image = [UIImage imageNamed: @"bg_2_0_0_no_image"] ;
        } else
            cell.coverImageView.image = image;
        }];
        cell.coverImageView.backgroundColor = [UIColor colorFromHexString: data[@"cover_hex"]];
         */
    }
    
    // UserForView Info Setting
    BOOL gotAudio = [data[@"usefor"][@"audio"] boolValue];
    NSLog(@"gotAudio: %d", gotAudio);
    
    BOOL gotVideo = [data[@"usefor"][@"video"] boolValue];
    NSLog(@"gotVideo: %d", gotVideo);
    
    BOOL gotExchange = [data[@"usefor"][@"exchange"] boolValue];
    NSLog(@"gotExchange: %d", gotExchange);
    
    BOOL gotSlot = [data[@"usefor"][@"slot"] boolValue];
    NSLog(@"gotSlot: %d", gotSlot);
    
    [cell.btn1 setImage: nil forState: UIControlStateNormal];
    [cell.btn2 setImage: nil forState: UIControlStateNormal];
    [cell.btn3 setImage: nil forState: UIControlStateNormal];
    
    cell.userInfoView.hidden = YES;
    
    if (gotAudio) {
        NSLog(@"gotAudio");
        cell.userInfoView.hidden = NO;
        [cell.btn3 setImage: [UIImage imageNamed: @"ic200_audio_play_dark"] forState: UIControlStateNormal];
        
        CGRect rect = cell.userInfoView.frame;
        rect.size.width = 28 * 1;
        cell.userInfoView.frame = rect;
        
        if (gotVideo) {
            NSLog(@"gotAudio");
            NSLog(@"gotVideo");
            [cell.btn3 setImage: [UIImage imageNamed: @"ic200_video_dark"] forState: UIControlStateNormal];
            [cell.btn2 setImage: [UIImage imageNamed: @"ic200_audio_play_dark"] forState: UIControlStateNormal];
            
            CGRect rect = cell.userInfoView.frame;
            rect.size.width = 28 * 2;
            cell.userInfoView.frame = rect;
            
            if (gotExchange || gotSlot) {
                NSLog(@"gotAudio");
                NSLog(@"gotVideo");
                NSLog(@"gotExchange or gotSlot");
                [cell.btn1 setImage: [UIImage imageNamed: @"ic200_audio_play_dark"] forState: UIControlStateNormal];
                [cell.btn2 setImage: [UIImage imageNamed: @"ic200_video_dark"] forState: UIControlStateNormal];
                [cell.btn3 setImage: [UIImage imageNamed: @"ic200_gift_dark"] forState: UIControlStateNormal];
                
                CGRect rect = cell.userInfoView.frame;
                rect.size.width = 28 * 3;
                cell.userInfoView.frame = rect;
            }
        }
    } else if (gotVideo) {
        NSLog(@"gotVideo");
        cell.userInfoView.hidden = NO;
        [cell.btn3 setImage: [UIImage imageNamed: @"ic200_video_dark"] forState: UIControlStateNormal];
        
        CGRect rect = cell.userInfoView.frame;
        rect.size.width = 28 * 1;
        cell.userInfoView.frame = rect;
        
        if (gotExchange || gotSlot) {
            NSLog(@"gotVideo");
            NSLog(@"gotExchange or gotSlot");
            [cell.btn3 setImage: [UIImage imageNamed: @"ic200_gift_dark"] forState: UIControlStateNormal];
            [cell.btn2 setImage: [UIImage imageNamed: @"ic200_video_dark"] forState: UIControlStateNormal];
            
            CGRect rect = cell.userInfoView.frame;
            rect.size.width = 28 * 2;
            cell.userInfoView.frame = rect;
        }
    } else if (gotExchange || gotSlot) {
        NSLog(@"gotExchange or gotSlot");
        cell.userInfoView.hidden = NO;
        [cell.btn3 setImage: [UIImage imageNamed: @"ic200_gift_dark"] forState: UIControlStateNormal];
        
        CGRect rect = cell.userInfoView.frame;
        rect.size.width = 28 * 1;
        cell.userInfoView.frame = rect;
    }
    // AlbumNameLabel Setting
    if (![data[@"name"] isEqual: [NSNull null]]) {
        cell.albumNameLabel.text = data[@"name"];
        [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: cell.albumNameLabel content: cell.albumNameLabel.text];        
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate Methods
- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CreatorCollectionViewCell *cell = (CreatorCollectionViewCell *) [collectionView cellForItemAtIndexPath: indexPath];
    NSLog(@"cell.contentView.subviews: %@", cell.contentView.subviews);
    NSLog(@"cell.contentView.bounds: %@", NSStringFromCGRect(cell.contentView.bounds));
    NSDictionary *data = pictures[indexPath.row];
    NSString *albumId = [data[@"album_id"] stringValue];
    
    CGRect source = [collectionView convertRect:cell.coverImageView.frame fromView:cell];
    source = [self.view convertRect:source fromView:collectionView];
    
    if ([wTools objectExists: albumId]) {
        [self ToRetrievealbumpViewControlleralbumid: albumId  sourceRect:source sourceImageView:cell.coverImageView];
    }
}
 
- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    //UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath: indexPath];
    //cell.contentView.backgroundColor = nil;
    //cell.contentView.subviews[0].backgroundColor = nil;
}


#pragma mark - UICollectionViewDelegateFlowLayout Methods
// Horizontal Cell Spacing
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    NSLog(@"");
    NSLog(@"minimumInteritemSpacingForSectionAtIndex");
    return 16.0f;
}

// Vertical Cell Spacing
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    NSLog(@"");
    NSLog(@"minimumLineSpacingForSectionAtIndex");
    return 24.0f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    NSLog(@"");
    NSLog(@"insetForSectionAtIndex");
    UIEdgeInsets itemInset = UIEdgeInsetsMake(0, 16, 0, 16);
    return itemInset;
}

#pragma mark - JCCollectionViewWaterfallLayoutDelegate
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
 heightForHeaderInSection:(NSInteger)section {
    NSLog(@"");
    NSLog(@"heightForHeaderInSection");
    return self.jccLayout.headerHeight;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"");
    NSLog(@"sizeForItemAtIndexPath");
    CGFloat itemWidth = roundf((self.view.frame.size.width - (miniInteriorSpacing * (columnCount + 1))) / columnCount);
    NSDictionary *data = pictures[indexPath.row];
    
    // Check Width & Height return value is nil or not
    NSNumber *coverWidth = data[@"cover_width"];
    NSNumber *coverHeight = data[@"cover_height"];
    
    NSInteger resultWidth;
    NSInteger resultHeight;
    
    if ([coverWidth isEqual: [NSNull null]]) {
        resultWidth = (self.view.bounds.size.width - 48) / 2;
    } else {
        resultWidth = [coverWidth integerValue];
    }
    
    if ([coverHeight isEqual: [NSNull null]]) {
        resultHeight = resultWidth;
    } else {
        resultHeight = [coverHeight integerValue];
    }
    
    CGFloat scale = [UIScreen mainScreen].scale;
    
    CGFloat widthForCoverImg = (self.view.bounds.size.width - 48) / 2;
    CGFloat heightForCoverImg = (resultHeight * widthForCoverImg) / resultWidth;
    
    if (heightForCoverImg < (36 * scale)) {
        heightForCoverImg = 36 * scale;
    }
    
    CGSize finalSize = CGSizeMake(widthForCoverImg, heightForCoverImg);
    finalSize = CGSizeMake(itemWidth, floorf(finalSize.height * itemWidth / finalSize.width));
    NSString *albumNameStr;
    
    if (![data[@"name"] isEqual: [NSNull null]]) {
        albumNameStr = data[@"name"];
    }
    finalSize = CGSizeMake(finalSize.width, finalSize.height + [self calculateHeightForLbl: albumNameStr width: itemWidth - 16]);
    
    NSLog(@"size :%@",NSStringFromCGSize(finalSize));
    
    return finalSize;
}

- (float)calculateHeightForLbl:(NSString *)text
                         width:(float)width {
    CGSize constraint = CGSizeMake(width,20000.0f);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [text boundingRectWithSize:constraint
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}
                                            context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    return size.height + 16;
}

#pragma mark - UIScrollViewDelegate Methods
- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"willDisplayCell");
    if (indexPath.item == (pictures.count - 1)) {
        NSLog(@"indexPath.item == (pictures.count - 1)");
        [self loadData];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidScroll");
    // Below code will call loadData twice when viewController just appears
    
    if (!isLoading) {
        NSLog(@"Is Not Loading");
        CGFloat bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
        if (bottomEdge > scrollView.contentSize.height) {
            NSLog(@"We are at the bottom");
//            [self loadData];
        }
    }
    /*
    // getting the scroll offset
    CGFloat bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    NSLog(@"bottomEdge: %f", bottomEdge);
    NSLog(@"scrollView.contentSize.height: %f", scrollView.contentSize.height);
    
    NSLog(@"isLoading: %d", isLoading);
    
    if (bottomEdge > scrollView.contentSize.height) {
        NSLog(@"We are at the bottom");
        [self loadData];
    }
     */
}

/*
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGPoint targetPoint = *targetContentOffset;
    CGPoint currentPoint = scrollView.contentOffset;
    
    if (targetPoint.y > currentPoint.y) {
        NSLog(@"up");
    } else {
        NSLog(@"down");
        [self loadData];
    }
}
*/
 
#pragma mark - IBAction Methods
- (IBAction)messageBtnPressed:(id)sender {
    [wTools setStatusBarBackgroundColor: [UIColor clearColor]];
    self.customMessageActionSheet.topicStr = @"留言板";
    self.customMessageActionSheet.type = @"user";
    self.customMessageActionSheet.typeId = self.userId;
    self.customMessageActionSheet.userName = @"";
    
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle: UIBlurEffectStyleDark];
    
    [UIView animateWithDuration: kAnimateActionSheet animations:^{
        self.effectView = [[UIVisualEffectView alloc] initWithEffect: blurEffect];
    }];
    
    self.effectView.frame = self.view.frame;
    self.effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.effectView.myLeftMargin = self.effectView.myRightMargin = 0;
    self.effectView.myTopMargin = self.effectView.myBottomMargin = 0;
    self.effectView.alpha = 0.9;
    
    // Call customMessageActionSheet methods first
    [self.customMessageActionSheet initialValueSetup];
    [self.customMessageActionSheet getMessage];
}

#pragma mark - MessageBoardViewControllerDelegate Methods
- (void)gotMessageData {
    NSLog(@"gotMessageData");
    // CustomActionSheet Setting
    // Below method will call viewDidLoad
    [self.view addSubview: self.effectView];
    [self.view addSubview: self.customMessageActionSheet.view];
}

#pragma mark - DDAUIActionSheetViewController Method
- (void)actionSheetViewDidSlideOut:(MessageboardViewController *)controller {
    NSLog(@"actionSheetViewDidSlideOut");
    //[self.fxBlurView removeFromSuperview];
    [wTools setStatusBarBackgroundColor: [UIColor clearColor]];
    [self.effectView removeFromSuperview];
    self.effectView = nil;
}

- (IBAction)myPageBtnPressed:(id)sender {
    NSLog(@"myPageBtnPressed");
    //https://w3.pinpinbox.com/index/creative/content/?user_id=151
    NSString *pageStr = [NSString stringWithFormat: @"index/creative/content/?user_id=%@&appview=true", self.userId];
    NSString *urlString = [NSString stringWithFormat: @"%@%@", pinpinbox, pageStr];
    
    NSLog(@"urlString: %@", urlString);
    
    NSURL *url = [NSURL URLWithString: urlString];
    
    if (![wTools objectExists: url]) {
        return;
    }
    
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL: url entersReaderIfAvailable: NO];
    safariVC.preferredBarTintColor = [UIColor whiteColor];
    [self presentViewController: safariVC animated: YES completion: nil];
}

- (UIButton *)changeFollowBtn: (UIButton *)followBtn {
    NSLog(@"changeFollowBtn");
    NSLog(@"_follow: %d", _follow);
    
    if (_follow) {
        NSLog(@"if follow is true");
        [followBtn setTitle: @"取消關注" forState: UIControlStateNormal];
        [followBtn setTitleColor: [UIColor secondGrey] forState: UIControlStateNormal];
        followBtn.backgroundColor = [UIColor clearColor];
        followBtn.layer.cornerRadius = kCornerRadius;
        followBtn.clipsToBounds = YES;
        followBtn.layer.masksToBounds = NO;
        followBtn.layer.borderColor = [UIColor secondGrey].CGColor;
        followBtn.layer.borderWidth = 1.0;
    } else {
        NSLog(@"if follow is false");
        [followBtn setTitle: @"關注" forState: UIControlStateNormal];
        [followBtn setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
        followBtn.backgroundColor = [UIColor firstPink];
        followBtn.layer.cornerRadius = kCornerRadius;
        followBtn.clipsToBounds = YES;
        followBtn.layer.masksToBounds = NO;
        followBtn.layer.borderWidth = 0;
    }
    return followBtn;
}

- (IBAction)shareBtnPress:(id)sender {
    NSLog(@"shareBtnPress");
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:[NSArray arrayWithObjects: [NSString stringWithFormat: userIdSharingLink, self.userId, autoPlayStr], nil] applicationActivities:nil];
    [self presentViewController: activityVC animated: YES completion: nil];
}

- (IBAction)linkBtnPress:(UIButton *)sender {
    NSLog(@"sender.tag: %ld", (long)sender.tag);
    NSLog(@"userDic: %@", userDic);
    NSString *socialLink;
    
    if (sender.tag == 1)
        socialLink = userDic[@"sociallink"][@"facebook"];
    if (sender.tag == 2)
        socialLink = userDic[@"sociallink"][@"google"];
    if (sender.tag == 3)
        socialLink = userDic[@"sociallink"][@"instagram"];
    if (sender.tag == 4)
        socialLink = userDic[@"sociallink"][@"linkedin"];
    if (sender.tag == 5)
        socialLink = userDic[@"sociallink"][@"pinterest"];
    if (sender.tag == 6)
        socialLink = userDic[@"sociallink"][@"twitter"];
    if (sender.tag == 7)
        socialLink = userDic[@"sociallink"][@"web"];
    if (sender.tag == 8)
        socialLink = userDic[@"sociallink"][@"youtube"];
    
    NSLog(@"socialLink: %@", socialLink);
    
    if (![socialLink isEqual: [NSNull null]]) {
        if (![socialLink isEqualToString: @""]) {
            if ([socialLink containsString: @"http://"] || [socialLink containsString: @"https://"]) {
                NSURL *url = [NSURL URLWithString: socialLink];
                
                SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL: url entersReaderIfAvailable: NO];
                safariVC.preferredBarTintColor = [UIColor whiteColor];
                [self presentViewController: safariVC animated: YES completion: nil];
            } else {
                NSLog(@"socialLink: %@", socialLink);
                CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                style.messageColor = [UIColor whiteColor];
                style.backgroundColor = [UIColor thirdPink];
                
                [self.view makeToast: NSLocalizedString(@"ProfileText-validateSocialLink", @"")
                            duration: 2.0
                            position: CSToastPositionBottom
                               style: style];
            }
        } else {
            NSLog(@"socialLink is equalTostring empty");
        }
    } else {
        NSLog(@"socialLink is null");
    }
}

- (IBAction)backBtnPress:(id)sender {
    //[self.navigationController popViewControllerAnimated: YES];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav popViewControllerAnimated: YES];
}

- (IBAction)followBtnPress:(id)sender {
    UIButton *followBtn = (UIButton *)sender;
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSString *respnose = [boxAPI changefollowstatus: [wTools getUserID]
                                                  token: [wTools getUserToken]
                                               authorid: self.userId];
        
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
            if (respnose != nil) {
                NSLog(@"response from changefollowstatus");
                
                if ([respnose isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"CreaterViewController");
                    NSLog(@"followBtnPress");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"changefollowstatus"
                                         albumId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respnose dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        [self refresh];
                        NSDictionary *d = dic[@"data"];
                        
                        if ([d[@"followstatus" ] boolValue]) {
                            [followBtn setTitle:NSLocalizedString(@"AuthorText-inAtt", @"") forState:UIControlStateNormal];

                            followBtn.backgroundColor = [UIColor clearColor];
                            followBtn.layer.cornerRadius = kCornerRadius;
                            followBtn.clipsToBounds = YES;
                            followBtn.layer.masksToBounds = NO;
                            followBtn.layer.borderColor = [UIColor secondGrey].CGColor;
                            followBtn.layer.borderWidth = 2.0;
                        } else {
                            [followBtn setTitle:NSLocalizedString(@"AuthorText-att", @"") forState:UIControlStateNormal];

                            followBtn.backgroundColor = [UIColor firstPink];
                            followBtn.layer.cornerRadius = kCornerRadius;
                            followBtn.clipsToBounds = YES;
                            followBtn.layer.masksToBounds = NO;
                            followBtn.layer.borderWidth = 0;
                        }
                        
                        [self checkPoint];
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
            }
        });
    });
}

- (void)checkPoint {
    NSLog(@"checkPoint");
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
        NSString *response = [boxAPI doTask2: [wTools getUserID]
                                       token: [wTools getUserToken]
                                    task_for: @"follow_user"
                                    platform: @"apple"
                                        type: @"user"
                                     type_id: wself.userId];
        
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
                NSLog(@"response from doTask2");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");                    
                    NSLog(@"checkPoint");
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                     protocolName: @"doTask2"
                                          albumId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    [wself processCheckPointResult:data];
                }
            }
        });
    });
}

- (void)processCheckPointResult:(NSDictionary *)data {
    if ([data[@"result"] intValue] == 1) {
        missionTopicStr = data[@"data"][@"task"][@"name"];
        NSLog(@"name: %@", missionTopicStr);
        
        rewardType = data[@"data"][@"task"][@"reward"];
        NSLog(@"reward type: %@", rewardType);
        
        rewardValue = data[@"data"][@"task"][@"reward_value"];
        NSLog(@"reward value: %@", rewardValue);
        
        eventUrl = data[@"data"][@"event"][@"url"];
        NSLog(@"event: %@", eventUrl);
        
        restriction = data[@"data"][@"task"][@"restriction"];
        NSLog(@"restriction: %@", restriction);
        
        restrictionValue = data[@"data"][@"task"][@"restriction_value"];
        NSLog(@"restrictionValue: %@", restrictionValue);
        
        numberOfCompleted = [data[@"data"][@"task"][@"numberofcompleted"] unsignedIntegerValue];
        NSLog(@"numberOfCompleted: %lu", (unsigned long)numberOfCompleted);
        
        [self showAlertViewForGettingPoint];
        //[self getPointStore];
    } else if ([data[@"result"] intValue] == 2) {
        NSLog(@"message: %@", data[@"message"]);
    } else if ([data[@"result"] intValue] == 0) {
        NSLog(@"失敗： %@", data[@"message"]);
    } else if ([data[@"result"] intValue] == 3) {
        NSLog(@"data result intValue: %d", [data[@"result"] intValue]);
    } else {
        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
    }
}

#pragma mark - Custom AlertView for Getting Point
- (void)showAlertViewForGettingPoint {
    NSLog(@"Show Alert View");
    // Custom AlertView shows up when getting the point
    alertView = [[OldCustomAlertView alloc] init];
    [alertView setContainerView: [self createPointView]];
    [alertView setButtonTitles: [NSMutableArray arrayWithObject: @"確     認"]];
    [alertView setUseMotionEffects: true];
    [alertView show];
}

- (UIView *)createPointView {
    NSLog(@"createPointView");
    UIView *pointView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 250, 250)];
    
    // Mission Topic Label
    UILabel *missionTopicLabel = [[UILabel alloc] initWithFrame: CGRectMake(10, 15, 200, 10)];
    //missionTopicLabel.text = @"收藏相本得點";
    missionTopicLabel.text = missionTopicStr;
    
    NSLog(@"Topic Label Text: %@", missionTopicStr);
    [pointView addSubview: missionTopicLabel];
    
    if ([restriction isEqualToString: @"personal"]) {
        UILabel *restrictionLabel = [[UILabel alloc] initWithFrame: CGRectMake(10, 45, 200, 10)];
        restrictionLabel.textColor = [UIColor firstGrey];
        restrictionLabel.text = [NSString stringWithFormat: @"次數：%lu / %@", (unsigned long)numberOfCompleted, restrictionValue];
        NSLog(@"restrictionLabel.text: %@", restrictionLabel.text);
        
        [pointView addSubview: restrictionLabel];
    }
    
    // Gift Image
    UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(50, 90, 100, 100)];
    imageView.image = [UIImage imageNamed: @"icon_present"];
    imageView.center = CGPointMake(pointView.frame.size.width / 2, pointView.frame.size.height / 2);
    [pointView addSubview: imageView];
    
    // Message Label
    UILabel *messageLabel = [[UILabel alloc] initWithFrame: CGRectMake(10, 200, 200, 10)];
    
    NSString *congratulate = @"恭喜您獲得 ";
    //NSString *number = @"1 ";
    
    NSLog(@"Reward Value: %@", rewardValue);
    NSString *end = @"P!";
    
    /*
     if ([rewardType isEqualToString: @"point"]) {
     congratulate = @"恭喜您獲得 ";
     number = @"5 ";
     // number = rewardValue;
     end = @"P!";
     }
     */
    
    messageLabel.text = [NSString stringWithFormat: @"%@%@%@", congratulate, rewardValue, end];
    [pointView addSubview: messageLabel];
    
    if ([eventUrl isEqual: [NSNull null]] || eventUrl == nil) {
        NSLog(@"eventUrl is equal to null or eventUrl is nil");
    } else {
        // Activity Button
        UIButton *activityButton = [UIButton buttonWithType: UIButtonTypeCustom];
        [activityButton addTarget: self action: @selector(showTheActivityPage) forControlEvents: UIControlEventTouchUpInside];
        activityButton.frame = CGRectMake(150, 220, 100, 10);
        [activityButton setTitle: @"活動連結" forState: UIControlStateNormal];
        [activityButton setTitleColor: [UIColor colorWithRed: 26.0/255.0 green: 196.0/255.0 blue: 199.0/255.0 alpha: 1.0]
                             forState: UIControlStateNormal];
        [pointView addSubview: activityButton];
    }
    
    return pointView;
}

- (void)showTheActivityPage {
    NSLog(@"showTheActivityPage");
    
    //NSString *activityLink = @"http://www.apple.com";
    NSLog(@"eventUrl: %@", eventUrl);
    NSString *activityLink = eventUrl;
    
    NSURL *url = [NSURL URLWithString: activityLink];
    
    // Close for present safari view controller, otherwise alertView will hide the background
    [alertView close];
    
    SFSafariViewController *safariVC1 = [[SFSafariViewController alloc] initWithURL: url entersReaderIfAvailable: NO];
    safariVC1.delegate = self;
    safariVC1.preferredBarTintColor = [UIColor whiteColor];
    [self presentViewController: safariVC1 animated: YES completion: nil];
}

#pragma mark - SFSafariViewController delegate methods
- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    // Done button pressed
    NSLog(@"show");
    [alertView show];
}

#pragma mark - Call Protocol
- (void)ToRetrievealbumpViewControlleralbumid:(NSString *)albumid
                                   sourceRect:(CGRect)sourceRect
                              sourceImageView:(UIImageView *) sourceImageView {
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *respnose = [boxAPI retrievealbump: albumid
                                               uid: [wTools getUserID]
                                             token: [wTools getUserToken]];
        
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
            if (respnose != nil) {
                NSLog(@"response from retrievealbump");
                
                if ([respnose isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"CreaterViewController");
                    NSLog(@"ToRetrievealbumpViewControlleralbumid");
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"retrievealbump"
                                         albumId: albumid];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [respnose dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        NSLog(@"result bool value is YES");
                        NSLog(@"dic data photo: %@", dic[@"data"][@"photo"]);
                        NSLog(@"dic data user name: %@", dic[@"data"][@"user"][@"name"]);
                        
                        if (![wTools objectExists: dic[@"data"]]) {
                            return;
                        }
                        
                        if (![wTools objectExists: albumid]) {
                            return;
                        }
                        
                        YAlbumDetailContainerViewController *aDVC = [YAlbumDetailContainerViewController albumDetailVCWithAlbumID:albumid albumInfo:dic[@"data"] sourceRect:sourceRect sourceImageView:sourceImageView];
                        aDVC.fromVC = @"creatorVC";
                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        [appDelegate.myNav pushViewController: aDVC animated: YES];
                        

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
            }
        });
    });
}

- (IBAction)buyPointBtnPressed:(id)sender {
    NSLog(@"buyPointBtnPressed");
    BuyPPointViewController *buyPPVC = [[UIStoryboard storyboardWithName: @"BuyPointVC" bundle: nil] instantiateViewControllerWithIdentifier: @"BuyPPointViewController"];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav pushViewController: buyPPVC animated: YES];
}

#pragma mark - Custom Error Alert Method
- (void)showCustomErrorAlert: (NSString *)msg {
    [UIViewController showCustomErrorAlertWithMessage:msg onButtonTouchUpBlock:^(CustomIOSAlertView *customAlertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[customAlertView tag]);
        [customAlertView close];
    }];
}

#pragma mark - Custom Method for TimeOut
- (void)showCustomTimeOutAlert: (NSString *)msg
                  protocolName: (NSString *)protocolName
                       albumId: (NSString *)albumId {
    CustomIOSAlertView *alertTimeOutView = [[CustomIOSAlertView alloc] init];
    alertTimeOutView.parentView = self.view;
    //[alertTimeOutView setContainerView: [self createTimeOutContainerView: msg]];
    [alertTimeOutView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
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
            if ([protocolName isEqualToString: @"changefollowstatus"]) {
                [weakSelf followBtnPress: nil];
            } else if ([protocolName isEqualToString: @"getcreative"]) {
                [weakSelf getCreator];
            } //else if ([protocolName isEqualToString: @"retrievealbump"]) {
              //  [weakSelf ToRetrievealbumpViewControlleralbumid: albumId];
            //}
            else if ([protocolName isEqualToString: @"doTask2"]) {
                [weakSelf checkPoint];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
