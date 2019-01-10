//
//  CategoryViewController.m
//  wPinpinbox
//
//  Created by David on 15/01/2018.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "CategoryViewController.h"
#import "CategoryTableViewCell.h"
#import "CategoryCollectionViewCell.h"
#import "CategoryDetailViewController.h"
#import "AlbumDetailViewController.h"
#import "UserCollectionViewCell.h"
#import "CreaterViewController.h"

#import "BannerCollectionViewCell.h"

#import "UIColor+Extensions.h"
#import "wTools.h"
#import "boxAPI.h"
#import "GlobalVars.h"
#import "CustomIOSAlertView.h"
#import "AppDelegate.h"
#import "MyLinearLayout.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIColor+HexString.h"
#import "LabelAttributeStyle.h"
#import "UIView+Toast.h"
#import <SafariServices/SafariServices.h>
#import "UIViewController+ErrorAlert.h"

//#define kUserImageViewNumber 6

@interface CategoryViewController () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, SFSafariViewControllerDelegate, YTPlayerViewDelegate, UIGestureRecognizerDelegate>
{
    //NSMutableArray *albumExploreArray;
    UICollectionView *collectionView;
    
    MyLinearLayout *bannerVertLayout;
    
    CGFloat bannerHeight;
    UIPageControl *pageControl;
    
    UIButton *actionButton;
    UILabel *infoLabel;
    UIView *actionBase;
    
}
//@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (nonatomic, strong) NSString *categoryName;

@property (weak, nonatomic) IBOutlet MyRelativeLayout *navBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarViewHeight;
@property (weak, nonatomic) IBOutlet UIButton *navBtn;
@property (strong, nonatomic) NSMutableArray *albumArray;
@property (strong, nonatomic) NSMutableArray *horzAlbumArray;
@property (strong, nonatomic) NSMutableArray *albumExploreArray;
@property (strong, nonatomic) NSMutableArray *categoryAreaArray;
@property (strong, nonatomic) NSMutableArray *categoryareaStyleArray;
@property (strong, nonatomic) NSMutableArray *bannerDataArray;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;

@property (weak, nonatomic) IBOutlet UIView *userLayout;//MyLinearLayout *userLayout;
//@property (weak, nonatomic) MyLinearLayout *userLayout;
@property (weak, nonatomic) IBOutlet UIView *userBgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userBgViewHeight;
@property (weak, nonatomic) IBOutlet UICollectionView *userCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *creatorLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *creatorLabelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *creatorLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeBtnHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeBtnTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableTopConstraint;
@end

@implementation CategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //NSLog(@"self.categoryName: %@", self.categoryName);
    NSLog(@"CategoryViewController");
    NSLog(@"viewDidLoad");
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.delegate = self;
    
    [self initialValueSetup];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.enabled = YES;
    
    if ([[[UIDevice currentDevice] systemVersion] compare:@"11.0" options:NSNumericSearch] == NSOrderedAscending){
        self.tableTopConstraint.constant = -20;
    }
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

- (void)initialValueSetup {
    NSLog(@"initialValueSetup");
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    NSLog(@"screenWidth: %f", screenWidth);
    bannerHeight = 211;//screenWidth * 540 / 960;
    NSLog(@"bannerHeight: %f", bannerHeight);
    
    self.navBarView.backgroundColor = [UIColor barColor];
    self.tableView.showsVerticalScrollIndicator = NO;
//    self.navBarView.myLeftMargin = self.navBarView.myRightMargin = 0;
//    self.navBarView.myTopMargin = 0;
//    //self.navBarView.backgroundColor = [UIColor redColor];
//    self.navBarView.heightDime.max(70);
    
    self.navBtn.myLeftMargin = 8;
    self.navBtn.myRightMargin = 0.5;
    self.navBtn.heightDime.max(42);
    self.navBtn.widthDime.max(42);
    self.navBtn.myBottomMargin = 4;
    //self.navBtn.myCenterYOffset = 0;
    
    self.userLayout.userInteractionEnabled = NO;
    //self.userLayout.myCenterYOffset = 0;
    //self.userLayout.orientation = 1;
    self.userLayout.wrapContentWidth = YES;
    self.userLayout.myRightMargin = 16;
    self.userLayout.backgroundColor = [UIColor clearColor];
    self.userLayout.myBottomMargin = 2;
    //self.userLayout.topPos.equalTo(self.navBtn.topPos);
    //self.userLayout.bottomPos.equalTo(self.navBtn.bottomPos);
    
    self.albumArray = [[NSMutableArray alloc] init];
    self.horzAlbumArray = [[NSMutableArray alloc] init];
    self.albumExploreArray = [[NSMutableArray alloc] init];
    self.categoryAreaArray = [[NSMutableArray alloc] init];
    self.categoryareaStyleArray = [[NSMutableArray alloc] init];
    self.bannerDataArray = [[NSMutableArray alloc] init];
    
    self.tableView.hidden = YES;
    self.tableView.contentInset = UIEdgeInsetsMake(48, 0, 0, 0);
    self.tableView.separatorColor = [UIColor clearColor];
    NSLog(@"self.tableView.contentOffset.y: %f", self.tableView.contentOffset.y);
    //self.tableView.backgroundColor = [UIColor redColor];
    
    self.contentOffsetDictionary = [NSMutableDictionary dictionary];
    
    // UserView Section
    //self.userBgView.hidden = YES;
    self.userBgViewHeight.constant = 0;
    self.creatorLabelHeight.constant = 0;
    self.creatorLabel.hidden = YES;
    self.closeBtnHeight.constant = 0;
    self.closeBtn.hidden = YES;
    
    [LabelAttributeStyle changeGapString: self.creatorLabel content: @"創作人推薦"];
    [self.closeBtn setTitleColor: [UIColor firstGrey] forState: UIControlStateNormal];
    
    NSLog(@"self.categoryAreaId: %@", self.categoryAreaId);
    
    if ([self.categoryAreaId isEqualToString: @"-1"]) {
    //    NSLog(@"self.categoryAreaId isEqualToString: -1");
    //    NSLog(@"self.dic: %@", self.dic);
        [self setupData];
        [self setupCategoryArea:self.dic];
    } else {
        [self getCategoryArea];
    }
}

- (void)setupCategoryArea:(NSDictionary *)cdic {
    if (![cdic[@"data"][@"categoryarea_style"] isEqual: [NSNull null]]) {
        self.categoryareaStyleArray = [NSMutableArray arrayWithArray: cdic[@"data"][@"categoryarea_style"]];
    }
    if (self.categoryareaStyleArray.count > 0) {
        for (NSDictionary *styleDic1 in self.categoryareaStyleArray) {
            NSLog(@"styleDic1: %@", styleDic1);
            
            if ([styleDic1[@"banner_type"] isEqualToString: @"creative"]) {
                NSLog(@"styleDic1 banner_type_data: %@", styleDic1[@"banner_type_data"]);
                
                if (styleDic1[@"banner_type"] != nil) {
                    self.categoryAreaArray = [NSMutableArray arrayWithArray: styleDic1[@"banner_type_data"]];
                }
                if (self.categoryAreaArray.count != 0) {
                    self.userLayout.userInteractionEnabled = YES;
                    [self addUserView];
                } else {
                    self.userLayout.userInteractionEnabled = NO;
                }
            } else {
                [self.bannerDataArray addObject: styleDic1];
            }
        }
    }
    
    if (![cdic[@"data"][@"albumexplore"] isEqual: [NSNull null]]) {
        self.albumArray = [NSMutableArray arrayWithArray: cdic[@"data"][@"albumexplore"]];
        NSLog(@"self.albumArray.count: %lu", (unsigned long)self.albumArray.count);
        NSLog(@"self.albumArray: %@", self.albumArray);
        [self.albumExploreArray removeAllObjects];
        [self.horzAlbumArray removeAllObjects];
        
        for (NSDictionary *dic1 in self.albumArray) {
            NSLog(@"dic1 album: %@", dic1[@"album"]);
            [self.horzAlbumArray addObject: dic1[@"album"]];
            [self.albumExploreArray addObject: dic1[@"albumexplore"]];
        }
        NSLog(@"self.albumExploreArray: %@", self.albumExploreArray);
        NSLog(@"self.horzAlbumArray: %@", self.horzAlbumArray);
        self.tableView.hidden = NO;
    }
    [self setupTableViewHeader];
    [self.tableView reloadData];
    [self.userCollectionView reloadData];
}

- (void)setupData {
    self.categoryName = self.categoryNameStr;
    self.albumArray = [NSMutableArray arrayWithArray: self.dic[@"data"][@"albumexplore"]];
    NSLog(@"self.albumArray: %@", self.albumArray);
    [self.albumExploreArray removeAllObjects];
    [self.horzAlbumArray removeAllObjects];
    
    if (![wTools objectExists: self.albumArray]) {
        return;
    }
    for (NSDictionary *dic1 in self.albumArray) {
        NSLog(@"dic1 album: %@", dic1[@"album"]);
        [self.horzAlbumArray addObject: dic1[@"album"]];
        [self.albumExploreArray addObject: dic1[@"albumexplore"]];
    }
    NSLog(@"self.albumExploreArray: %@", self.albumExploreArray);
    NSLog(@"self.horzAlbumArray: %@", self.horzAlbumArray);
    [self setupTableViewHeader];
    self.tableView.hidden = NO;
    [self.tableView reloadData];
    [self.userCollectionView reloadData];
}

- (void)userTapped {
    NSLog(@"userTapped");
//    CGRect rect = CGRectMake(self.userBgView.frame.origin.x, self.userBgView.frame.origin.y, self.userBgView.frame.size.width, self.userBgView.frame.size.height);
//    NSLog(@"Before");
//    NSLog(@"rect.origin.x: %f", rect.origin.x);
//    rect.origin.x += self.userBgView.frame.size.width;
//    NSLog(@"After");
//    NSLog(@"rect.origin.x: %f", rect.origin.x);
//
//    NSLog(@"Before");
//    NSLog(@"self.userBgView.frame.origin.x: %f", self.userBgView.frame.origin.x);
    
    [UIView animateWithDuration: 0.5 animations:^{
//        self.userBgView.frame = rect;
//        NSLog(@"After");
//        NSLog(@"self.userBgView.frame.origin.x: %f", self.userBgView.frame.origin.x);
        self.userLayout.alpha = 0;
        self.userBgViewHeight.constant = 270;
        self.creatorLabelHeight.constant = 29;
        self.closeBtnHeight.constant = 34;
        self.closeBtn.hidden = NO;
        //[self.userLayout layoutIfNeeded];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.creatorLabel.hidden = NO;
    }];
}

#pragma mark - IBAction Methods
- (IBAction)backBtnPressed:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav popViewControllerAnimated: YES];
}

- (IBAction)closeUserCollectionView:(id)sender {
    NSLog(@"closeUserCollectionView");
    [UIView animateWithDuration: 0.5 animations:^{
        self.userLayout.alpha = 1.0;
        self.userLayout.tag = 100;
        self.userBgViewHeight.constant = 0;
        self.creatorLabelHeight.constant = 0;
        self.creatorLabel.hidden = YES;
        self.closeBtnHeight.constant = 0;
        self.closeBtn.hidden = YES;
        //[self.userLayout layoutIfNeeded];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

- (void)viewDidLayoutSubviews {
    NSLog(@"viewDidLayoutSubviews ");
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                
        int screenHeight = (int)[[UIScreen mainScreen] nativeBounds].size.height;
        switch (screenHeight){
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
            //case 2436:
            default:
                NSLog(@"\n");
                printf("iPhone X");
                //self.userLayout.myCenterYOffset = 20;
                //self.navBtn.myCenterYOffset = 20;
                //if (screenHeight >= 2436)
                {
                    self.navBarViewHeight.constant = navBarHeightConstant + 5;
                    self.creatorLabelTopConstraint.constant = 90;
                    self.closeBtnTopConstraint.constant = 90;
                }
                break;
//            default:
//                printf("unknown");
//                break;
        }
    }
}

- (void)getCategoryArea {
    NSLog(@"");
    NSLog(@"getCategoryArea");
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason);
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI getCategoryArea: self.categoryAreaId
                                               token: [wTools getUserToken]
                                              userId: [wTools getUserID]];
        
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
                NSLog(@"response from getCategoryArea");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"CategoryViewController");
                    NSLog(@"getCategoryArea");
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getCategoryArea"];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] isEqualToString: @"SYSTEM_OK"]) {
                        NSLog(@"dic data: %@", dic[@"data"]);
                        NSLog(@"dic data categoryarea: %@", dic[@"data"][@"categoryarea"]);
                        
                        if (![dic[@"data"][@"categoryarea"][@"name"] isEqual: [NSNull null]]) {
                            self.categoryName = dic[@"data"][@"categoryarea"][@"name"];
                        }
                        [self setupCategoryArea:dic];
                    } else if ([dic[@"result"] isEqualToString: @"SYSTEM_ERROR"]) {
                        NSLog(@"SYSTEM_ERROR");
                        NSLog(@"失敗：%@",dic[@"message"]);
                        if ([wTools objectExists: dic[@"message"]]) {
                            [self showCustomErrorAlert: dic[@"message"]];
                        } else {
                            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                        }
                    } else if ([dic[@"result"] isEqualToString: @"TOKEN_ERROR"]) {
                        NSLog(@"TOKEN_ERROR");
                        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                        style.messageColor = [UIColor whiteColor];
                        style.backgroundColor = [UIColor thirdPink];
                        
                        [self.view makeToast: @"用戶驗證異常請重新登入"
                                    duration: 2.0
                                    position: CSToastPositionBottom
                                       style: style];
                        
                        [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                         target: self
                                                       selector: @selector(logOut)
                                                       userInfo: nil
                                                        repeats: NO];
                    }
                }
            }
        });
    });
}

- (void)logOut {
    [wTools logOut];
}

- (void)addUserView {
    NSLog(@"addUserView");
    NSInteger userImageViewNumber = 0;
    
    if (self.categoryAreaArray.count > 6) {
        userImageViewNumber = 6;
    } else {
        userImageViewNumber = self.categoryAreaArray.count;
    }
    
    for (int i = 0; i < userImageViewNumber; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 32, 32)];
        
        NSDictionary *pictureDic = self.categoryAreaArray[i];
        NSLog(@"pictureDic: %@", pictureDic);
        
        if ([pictureDic[@"picture"] isEqual: [NSNull null]]) {
            NSLog(@"picture is null");
            imageView.image = [UIImage imageNamed: @"member_back_head.png"];
        } else {
            NSLog(@"picture is not null");
            //[imageView sd_setImageWithURL: [NSURL URLWithString: pictureDic[@"picture"]]];
            [imageView sd_setImageWithURL: [NSURL URLWithString: pictureDic[@"picture"]]
                         placeholderImage: [UIImage imageNamed: @"member_back_head.png"]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
        });
        //imageView.myRightMargin = -16*(i+1);
        imageView.myCenterYOffset = 0;
        imageView.myTopMargin = imageView.myBottomMargin = 0;
        imageView.layer.cornerRadius = imageView.frame.size.width / 2;
        imageView.clipsToBounds = YES;
        imageView.layer.borderColor = [UIColor thirdGrey].CGColor;
        imageView.layer.borderWidth = 0.5;
        
        [self.userLayout addSubview: imageView];
        NSLayoutConstraint *l = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTrailing
                                                             relatedBy:NSLayoutRelationEqual toItem:self.userLayout attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-16*(userImageViewNumber-i)+16];
        l.active = YES;
        NSLayoutConstraint *l1 = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual toItem:self.userLayout attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        l1.active = YES;
        NSLayoutConstraint *l0 = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:32];
        l0.active = YES;
        NSLayoutConstraint *l01 = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:32];
        l01.active = YES;
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [imageView addConstraints:@[l0,l01]];
        [_userLayout addConstraints:@[l,l1]];
        
    }
}
- (void)setBtnText:(NSString *)btntext infoText:(NSString *)infotext {
    infoLabel.text = @"";
    if (btntext && btntext.length > 0) {
        [actionButton setTitle:btntext forState:UIControlStateNormal];
        if (infotext)
            infoLabel.text = infotext;
        
        actionBase.hidden = NO;
    } else {
        actionBase.hidden = YES;
    }
}

- (void)handlePageControlValueChanged {
    long index = pageControl.currentPage;
    NSLog(@"self.bannerDataArray: %@", self.bannerDataArray);
    
    if (self.bannerDataArray.count > index) {
        NSDictionary *bannerDic = self.bannerDataArray[index];
        
        NSString *btnText = bannerDic[@"banner_type_data"][@"btntext"];
        NSString *vidtext = bannerDic[@"banner_type_data"][@"videotext"];
        
        [self setBtnText:btnText infoText: vidtext];
        actionButton.tag = index;
        [actionBase setNeedsLayout];
        [pageControl setNeedsLayout];
    }
}

- (IBAction)handleBannerActionButtonTap:(id) sender {
    UIButton *btn = (UIButton *)sender;
    if (btn && btn.tag >= 0 && btn.tag < self.bannerDataArray.count) {
        NSDictionary *bannerDic = self.bannerDataArray[btn.tag];
        NSString *link = bannerDic[@"banner_type_data"][@"link"];
        
        //  check if bannerDic[@"banner_type_data"][@"link"] is redirecting to an album //
        NSArray *albumKey = [sharingLinkWithoutAutoPlay componentsSeparatedByString:@"%@"];
        if (albumKey.count) {
            NSString *key = (NSString *)albumKey.firstObject;
            if ([link hasPrefix:key]) {
                NSString *aid = [link substringFromIndex:key.length];
                if (aid && aid.length) {
                    [self presentAlbumDetailVC:aid];
                    return ;
                }
            }
        }
        NSArray *creativeKey = [userIdSharingLink componentsSeparatedByString:@"%@"];
        if (creativeKey.count) {
            NSString *key = (NSString *)creativeKey.firstObject;
            if ([link hasPrefix:key]) {
                NSString *uid = [link substringFromIndex:key.length];
                if (uid && uid.length) {
                    [self presentUserVC:uid];
                    return ;
                }
            }
        }
        //  ordinary links
        if (link && link.length > 0) {
            NSURL *url = [NSURL URLWithString:link];
            if (url) {
                SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL: url entersReaderIfAvailable: NO];
                safariVC.delegate = self;
                safariVC.preferredBarTintColor = [UIColor whiteColor];
                [self presentViewController: safariVC animated: YES completion: nil];
            }
        }
    }
}

//  present AlbumDetailViewController by albumid
- (void)presentAlbumDetailVC:(NSString *)albumid {
    AlbumDetailViewController *aDVC = [[UIStoryboard storyboardWithName: @"AlbumDetailVC" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumDetailViewController"];
    aDVC.albumId = albumid;//[dic[@"album"][@"album_id"] stringValue];
    aDVC.snapShotImage = [wTools normalSnapshotImage: self.view];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav.view.layer addAnimation: transition forKey: kCATransition];
    [appDelegate.myNav pushViewController: aDVC animated: NO];
}

//  present CreaterViewController by userId
- (void)presentUserVC:(NSString *)uid {
    CreaterViewController *cVC = [[UIStoryboard storyboardWithName: @"CreaterVC" bundle: nil] instantiateViewControllerWithIdentifier: @"CreaterViewController"];
    cVC.userId = uid;
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav.view.layer addAnimation: transition forKey: kCATransition];
    [appDelegate.myNav pushViewController: cVC animated: NO];
}

#pragma mark - UITableViewDatasource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"");
    NSLog(@"numberOfSectionsInTableView");
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    NSLog(@"");
    NSLog(@"numberOfRowsInSection");
    NSLog(@"self.albumExploreArray.count: %lu", (unsigned long)self.albumExploreArray.count);
    return self.albumExploreArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"");
    NSLog(@"cellForRowAtIndexPath");
    NSLog(@"self.albumExploreArray: %@", self.albumExploreArray);
    
    CategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"CategoryCell" forIndexPath: indexPath];
    if ([wTools objectExists: self.albumExploreArray[indexPath.row][@"name"]]) {
        cell.albumExploreLabel.text = self.albumExploreArray[indexPath.row][@"name"];
        [LabelAttributeStyle changeGapString: cell.albumExploreLabel content: self.albumExploreArray[indexPath.row][@"name"]];
        NSLog(@"cell.albumExploreLabel.text: %@", cell.albumExploreLabel.text);
    }
    NSLog(@"indexPath.row: %ld", (long)indexPath.row);
    cell.strData = self.albumExploreArray[indexPath.row][@"url"];
    NSLog(@"cell.strData: %@", cell.strData);
    
    if (!cell.strData || [cell.strData isKindOfClass: [NSNull class]]) {
        //cell.moreBtn.hidden = YES;
        [cell setMoreBtnHidden:YES];
    } else {
        //cell.moreBtn.hidden = NO;
        [cell setMoreBtnHidden:NO];
    }
    cell.customBlock = ^(NSString *strData) {
        NSLog(@"cell.customBlock");
        NSLog(@"strData: %@", strData);
        [self checkStrDataAndNavigate: strData];
    };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)checkStrDataAndNavigate:(NSString *)strData {
    if ([strData containsString: @"http://"] || [strData containsString: @"https://"]) {
        NSArray *strArray = [strData componentsSeparatedByString: @"?"];
        NSLog(@"strArray: %@", strArray);
        
        if (strArray.count > 1) {
            if ([strData containsString: @"categoryarea_id"] && [strData containsString: @"category_id"]) {
                NSLog(@"strData contains string categoryarea_id && categoryarea_id");
                NSLog(@"strArray: %@", strArray);
                
                strArray = [strArray[1] componentsSeparatedByString: @"&"];
                NSLog(@"strArray: %@", strArray);
                
                NSString *categoryAreaIdStr;
                NSString *categoryIdStr;
                
                for (int i = 0; i < strArray.count; i++) {
                    NSString *s = strArray[i];
                    NSLog(@"s: %@", s);
                    
                    if ([s containsString: @"categoryarea_id"]) {
                        NSLog(@"s containsString categoryarea_id");
                        NSArray *array = [s componentsSeparatedByString: @"="];
                        NSLog(@"array: %@", array);
                        
                        if ([array[0] isEqualToString: @"categoryarea_id"]) {
                            categoryAreaIdStr = array[1];
                        }
                    } else if ([s containsString: @"category_id"]) {
                        NSLog(@"s containsString category_id");
                        NSArray *array = [s componentsSeparatedByString: @"="];
                        NSLog(@"array: %@", array);
                        
                        if ([array[0] isEqualToString: @"category_id"]) {
                            categoryIdStr = array[1];
                        }
                    }
                }
                NSLog(@"categoryAreaIdStr: %@", categoryAreaIdStr);
                NSLog(@"categoryIdStr: %@", categoryIdStr);
                
                if (categoryAreaIdStr != nil && categoryIdStr == nil) {
                    NSLog(@"categoryAreaIdStr != nil && categoryIdStr == nil");
                    
                    if ([strArray containsObject: @"explore"]) {
                        CategoryDetailViewController *cDVC = [[UIStoryboard storyboardWithName: @"CategoryDetailVC" bundle: nil] instantiateViewControllerWithIdentifier: @"CategoryDetailViewController"];
                        cDVC.categoryAreaId = [categoryAreaIdStr intValue];
                        cDVC.categoryName = self.categoryName;
                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        [appDelegate.myNav pushViewController: cDVC animated: YES];
                    } else {
                        CategoryViewController *categoryVC = [[UIStoryboard storyboardWithName: @"CategoryVC" bundle: nil] instantiateViewControllerWithIdentifier: @"CategoryViewController"];
                        categoryVC.categoryAreaId = categoryAreaIdStr;
                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        [appDelegate.myNav pushViewController: categoryVC animated: YES];
                    }
                } else {
                    [self toSafariWebVC: strData];
                }
            } else {
                if (!([strArray[1] rangeOfString: @"categoryarea_id"].location == NSNotFound)) {
                    NSLog(@"strArray[1] rangeOfString: categoryarea_id");
                    strArray = [strArray[1] componentsSeparatedByString: @"="];
                    NSLog(@"strArray: %@", strArray);
                    
                    if ([strArray[0] isEqualToString: @"categoryarea_id"]) {
                        CategoryDetailViewController *cDVC = [[UIStoryboard storyboardWithName: @"CategoryDetailVC" bundle: nil] instantiateViewControllerWithIdentifier: @"CategoryDetailViewController"];
                        cDVC.categoryAreaId = [strArray[1] intValue];
                        cDVC.categoryName = self.categoryName;
                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        [appDelegate.myNav pushViewController: cDVC animated: YES];
                    } else {
                        [self toSafariWebVC: strData];
                    }
                } else if (!([strArray[1] rangeOfString: @"user_id"].location == NSNotFound)) {
                    NSLog(@"strArray[1] rangeOfString: user_id");
                    strArray = [strArray[1] componentsSeparatedByString: @"="];
                    NSLog(@"strArray: %@", strArray);
                    
                    if ([strArray[0] isEqualToString: @"user_id"]) {
                        CreaterViewController *cVC = [[UIStoryboard storyboardWithName: @"CreaterVC" bundle: nil] instantiateViewControllerWithIdentifier: @"CreaterViewController"];
                        cVC.userId = strArray[1];
                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        [appDelegate.myNav pushViewController: cVC animated: YES];
                    } else {
                        [self toSafariWebVC: strData];
                    }
                } else if (!([strArray[1] rangeOfString: @"album_id"].location == NSNotFound)) {
                    NSLog(@"strArray[1] rangeOfString: album_id");
                    strArray = [strArray[1] componentsSeparatedByString: @"="];
                    NSLog(@"strArray: %@", strArray);
                    
                    if ([strArray[0] isEqualToString: @"album_id"]) {
                        AlbumDetailViewController *aDVC = [[UIStoryboard storyboardWithName: @"AlbumDetailVC" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumDetailViewController"];
                        aDVC.albumId = strArray[1];
                        aDVC.snapShotImage = [wTools normalSnapshotImage: self.view];
                        
                        CATransition *transition = [CATransition animation];
                        transition.duration = 0.5;
                        transition.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
                        transition.type = kCATransitionMoveIn;
                        transition.subtype = kCATransitionFromTop;
                        
                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        [appDelegate.myNav.view.layer addAnimation: transition forKey: kCATransition];
                        [appDelegate.myNav pushViewController: aDVC animated: NO];
                    } else {
                        [self toSafariWebVC: strData];
                    }
                } else {
                    [self toSafariWebVC: strData];
                }
            }
        } else {
            [self toSafariWebVC: strData];
        }
    } else {
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor thirdPink];
        
        [self.view makeToast: NSLocalizedString(@"ProfileText-validateSocialLink", @"")
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
    }
}

- (void)toSafariWebVC:(NSString *)urlString {
    NSLog(@"toSafariWebVC");
    NSLog(@"urlString: %@", urlString);
    NSURL *url = [NSURL URLWithString: urlString];    
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL: url entersReaderIfAvailable: NO];
    safariVC.preferredBarTintColor = [UIColor whiteColor];
    [self presentViewController: safariVC animated: YES completion: nil];
}

- (void)setupTableViewHeader {
    NSLog(@"");
    NSLog(@"viewForHeaderInSection");
    MyLinearLayout *bannerVertLayout = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Vert];
    //MyFloatLayout *bannerVertLayout = [MyFloatLayout floatLayoutWithOrientation:MyLayoutViewOrientation_Vert];
    bannerVertLayout.wrapContentHeight = YES;
    bannerVertLayout.myTopMargin = 0;
    bannerVertLayout.myLeftMargin = bannerVertLayout.myRightMargin = 0;
    bannerVertLayout.myBottomMargin = 0;
    
    NSLog(@"bannerHeight: %f", bannerHeight);
    
    if (self.bannerDataArray.count > 0) {
        NSLog(@"bannerHeight: %f", bannerHeight);
        bannerVertLayout.heightDime.min(316).max(352);//160);
        
        // Horizontal CollectionView Setting
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(self.view.bounds.size.width, bannerHeight);
        layout.minimumLineSpacing = 0;
        
        collectionView = [[UICollectionView alloc] initWithFrame: CGRectMake(0, 0, self.view.bounds.size.width, bannerHeight) collectionViewLayout: layout];
        collectionView.myTopMargin = 0;
        collectionView.myBottomMargin = 0;
        collectionView.myLeftMargin = collectionView.myRightMargin = 0;
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.tag = 3;
        collectionView.pagingEnabled = YES;
        collectionView.wrapContentHeight = YES;
        
        [collectionView registerNib: [UINib nibWithNibName: @"BannerImageView" bundle: [NSBundle mainBundle]] forCellWithReuseIdentifier: @"BannerCell"];
        [collectionView registerNib: [UINib nibWithNibName: @"YoutubePlayer" bundle: [NSBundle mainBundle]] forCellWithReuseIdentifier: @"YoutubeCell"];
        
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.showsHorizontalScrollIndicator = NO;
        [bannerVertLayout addSubview: collectionView];
        
        //  button and link desc under the banner //
        actionBase = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 36)];
        actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        actionBase.backgroundColor = [UIColor whiteColor];
        actionButton.frame = CGRectMake(self.view.bounds.size.width-96, 0, 96, 36);
        actionButton.backgroundColor = [UIColor colorWithRed:0  green:0.67 blue:0.76 alpha:1];
        [actionButton addTarget:self action:@selector(handleBannerActionButtonTap:) forControlEvents:UIControlEventTouchUpInside];
        
        infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 8, self.view.bounds.size.width-96-32, 24)];
        infoLabel.textColor = [UIColor firstGrey];
        infoLabel.backgroundColor = [UIColor clearColor];
        infoLabel.font = [UIFont systemFontOfSize:14];
        infoLabel.myTopMargin = 8;
        [actionBase addSubview:infoLabel];
        [actionBase addSubview:actionButton];
        actionBase.myBottomMargin = 8;
        actionBase.heightDime.min(0).max(36);
        CALayer *line = [[CALayer alloc] init];
        line.backgroundColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.6].CGColor;//[UIColor grayColor].CGColor;
        line.frame = CGRectMake(0, actionBase.frame.size.height-1, actionBase.frame.size.width-96, 0.5);
        [actionBase.layer addSublayer:line];
        [bannerVertLayout addSubview:actionBase];
        
        pageControl = [[UIPageControl alloc] initWithFrame: CGRectMake(0, 0, 50, 10)];
        pageControl.myCenterXOffset = 0;
        pageControl.myTopMargin = 4;
        pageControl.myBottomMargin = 4;
        pageControl.numberOfPages = self.bannerDataArray.count;
        pageControl.pageIndicatorTintColor = [UIColor secondGrey];
        pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
        pageControl.userInteractionEnabled = NO;
        [bannerVertLayout addSubview: pageControl];
        
        [self handlePageControlValueChanged];
        
    } else {
        bannerVertLayout.heightDime.max(105);
    }
    
    UILabel *topicLabel = [UILabel new];
    topicLabel.myTopMargin = 0;
    topicLabel.myLeftMargin = 16;
    
    if (self.categoryName == nil) {
        self.categoryName = @"";
    }
    [wTools sendScreenTrackingWithScreenName:[NSString stringWithFormat:@"分類(%@)",_categoryName]];
    topicLabel.text = self.categoryName;
    topicLabel.textColor = [UIColor firstGrey];
    [LabelAttributeStyle changeGapString: topicLabel content: self.categoryName];
    topicLabel.font = [UIFont boldSystemFontOfSize: 42];
    [topicLabel sizeToFit];
    UIView *space = [[UIView alloc] initWithFrame:CGRectMake(0, 0, topicLabel.frame.size.width, 25)];
    space.backgroundColor = [UIColor clearColor];
    space.userInteractionEnabled = NO;
    [bannerVertLayout addSubview: space];
    [bannerVertLayout addSubview: topicLabel];
    
    [bannerVertLayout sizeToFit];
    //
    bannerVertLayout.backgroundColor = [UIColor whiteColor];
    
    self.tableView.tableHeaderView = bannerVertLayout;
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView
  willDisplayCell:(CategoryTableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"");
    NSLog(@"willDisplayCell");
    [cell setCollectionViewDataSourceDelegate: self indexPath: indexPath];
    NSInteger index = cell.collectionView.indexPath.row;
    CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index) stringValue]] floatValue];
    [cell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 250;//280.0;
}

#pragma mark - UICollectionViewDatasource Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    NSLog(@"");
    NSLog(@"numberOfItemsInSection");
    
    // BannerCollectionView
    if (collectionView.tag == 1) {
        NSArray *collectionViewArray = self.horzAlbumArray[[(HorzAlbumCollectionView *)collectionView indexPath].row];
        return collectionViewArray.count;
    } else if (collectionView.tag == 3) {
        NSLog(@"self.bannerDataArray.count: %lu", (unsigned long)self.bannerDataArray.count);
        return self.bannerDataArray.count;
    } else {
        NSLog(@"self.categoryAreaArray.count: %lu", (unsigned long)self.categoryAreaArray.count);
        return self.categoryAreaArray.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"");
    NSLog(@"cellForItemAtIndexPath");
    
//    NSLog(@"self.tableView.tableHeaderView.bounds.size.height: %f", self.tableView.tableHeaderView.bounds.size.height);
    
    if (collectionView.tag == 1) {
        NSLog(@"collectionView.tag == 1");
        CategoryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"HorzAlbumCell" forIndexPath: indexPath];
        NSLog(@"self.horzAlbumArray: %@", self.horzAlbumArray);
        NSArray *collectionViewArray = self.horzAlbumArray[[(HorzAlbumCollectionView *)collectionView indexPath].row];
        NSLog(@"collectionViewArray: %@", collectionViewArray);
        NSDictionary *dic = collectionViewArray[indexPath.item];
        
        if ([dic[@"album"][@"cover"] isEqual: [NSNull null]]) {
            cell.albumImageView.image = [UIImage imageNamed: @"bg200_no_image.jpg"];
        } else {
            //[cell.albumImageView sd_setImageWithURL: [NSURL URLWithString: dic[@"album"][@"cover"]]];
            
            [cell.albumImageView sd_setImageWithURL:[NSURL URLWithString: dic[@"album"][@"cover"]] placeholderImage:[UIImage imageNamed:@"bg200_no_image.jpg"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                if (error) {
                    cell.albumImageView.image = [UIImage imageNamed: @"bg_2_0_0_no_image"] ;
                } else
                    cell.albumImageView.image = image;
                
            }];
            
            cell.albumImageView.backgroundColor = [UIColor colorFromHexString: dic[@"album"][@"cover_hex"]];
        }
        
        if (![dic[@"album"][@"name"] isEqual: [NSNull null]]) {
            cell.albumNameLabel.text = dic[@"album"][@"name"];
            [LabelAttributeStyle changeGapString: cell.albumNameLabel content: dic[@"album"][@"name"]];
        }
        
        // UserForView Info Setting
        BOOL gotAudio = [dic[@"album"][@"usefor"][@"audio"] boolValue];
        BOOL gotVideo = [dic[@"album"][@"usefor"][@"video"] boolValue];
        BOOL gotExchange = [dic[@"album"][@"usefor"][@"exchange"] boolValue];
        BOOL gotSlot = [dic[@"album"][@"usefor"][@"slot"] boolValue];
        
        [cell.btn1 setImage: nil forState: UIControlStateNormal];
        [cell.btn2 setImage: nil forState: UIControlStateNormal];
        [cell.btn3 setImage: nil forState: UIControlStateNormal];
        
        cell.userInfoView.hidden = YES;
        
        if (gotAudio) {
            cell.userInfoView.hidden = NO;
            [cell.btn3 setImage: [UIImage imageNamed: @"ic200_audio_play_dark"] forState: UIControlStateNormal];
            CGRect rect = cell.userInfoView.frame;
            rect.size.width = 28 * 1;
            cell.userInfoView.frame = rect;
            
            if (gotVideo) {
                [cell.btn3 setImage: [UIImage imageNamed: @"ic200_video_dark"] forState: UIControlStateNormal];
                [cell.btn2 setImage: [UIImage imageNamed: @"ic200_audio_play_dark"] forState: UIControlStateNormal];
                CGRect rect = cell.userInfoView.frame;
                rect.size.width = 28 * 2;
                cell.userInfoView.frame = rect;
                
                if (gotExchange || gotSlot) {
                    [cell.btn1 setImage: [UIImage imageNamed: @"ic200_audio_play_dark"] forState: UIControlStateNormal];
                    [cell.btn2 setImage: [UIImage imageNamed: @"ic200_video_dark"] forState: UIControlStateNormal];
                    [cell.btn3 setImage: [UIImage imageNamed: @"ic200_gift_dark"] forState: UIControlStateNormal];
                    
                    CGRect rect = cell.userInfoView.frame;
                    rect.size.width = 28 * 3;
                    cell.userInfoView.frame = rect;
                }
            }
        } else if (gotVideo) {
            cell.userInfoView.hidden = NO;
            [cell.btn3 setImage: [UIImage imageNamed: @"ic200_video_dark"] forState: UIControlStateNormal];
            CGRect rect = cell.userInfoView.frame;
            rect.size.width = 28 * 1;
            cell.userInfoView.frame = rect;
            
            if (gotExchange || gotSlot) {
                [cell.btn3 setImage: [UIImage imageNamed: @"ic200_gift_dark"] forState: UIControlStateNormal];
                [cell.btn2 setImage: [UIImage imageNamed: @"ic200_video_dark"] forState: UIControlStateNormal];
                CGRect rect = cell.userInfoView.frame;
                rect.size.width = 28 * 2;
                cell.userInfoView.frame = rect;
            }
        } else if (gotExchange || gotSlot) {
            cell.userInfoView.hidden = NO;
            [cell.btn3 setImage: [UIImage imageNamed: @"ic200_gift_dark"] forState: UIControlStateNormal];
            CGRect rect = cell.userInfoView.frame;
            rect.size.width = 28 * 1;
            cell.userInfoView.frame = rect;
        }
        return cell;
    } else if (collectionView.tag == 3) {
        NSLog(@"collectionView.tag == 3");
        BannerCollectionViewCell *cell;
        NSLog(@"self.bannerDataArray: %@", self.bannerDataArray);
        
        if (self.bannerDataArray.count > 0) {
            NSDictionary *bannerDic = self.bannerDataArray[indexPath.row];
            NSString *bannerType = bannerDic[@"banner_type"];
            NSString *videoUrl = bannerDic[@"banner_type_data"][@"url"];
            NSString *imageUrl = bannerDic[@"image"];
            
            if ([bannerType isEqualToString: @"video"]) {
                cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"YoutubeCell" forIndexPath: indexPath];
                NSDictionary *playerVars = @{@"playsinline" : @1};
                [cell.playerView loadWithVideoId: videoUrl playerVars: playerVars];
                cell.playerView.delegate = self;
            } else if ([bannerType isEqualToString: @"image"]) {
                cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"BannerCell" forIndexPath: indexPath];
                [cell.bannerImageView sd_setImageWithURL: [NSURL URLWithString: imageUrl]
                                        placeholderImage: [UIImage imageNamed: @"bg200_no_image.jpg"]];                
            }
        }
        return cell;
    } else {
        NSLog(@"collectionView.tag: %ld", (long)collectionView.tag);
        UserCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"UserCell" forIndexPath: indexPath];
        NSLog(@"self.categoryAreaArray: %@", self.categoryAreaArray);
        NSDictionary *pictureDic = self.categoryAreaArray[indexPath.row];
        
        if ([pictureDic[@"picture"] isEqual: [NSNull null]]) {
            NSLog(@"picture is null");
            cell.userImageView.image = [UIImage imageNamed: @"member_back_head.png"];
        } else {
            NSLog(@"picture is not null");
            //[cell.userImageView sd_setImageWithURL: [NSURL URLWithString: pictureDic[@"picture"]]];
            [cell.userImageView sd_setImageWithURL: [NSURL URLWithString: pictureDic[@"picture"]]
                                  placeholderImage: [UIImage imageNamed: @"member_back_head.png"]];
        }
        if (![pictureDic[@"name"] isEqual: [NSNull null]]) {
            cell.userNameLabel.text = pictureDic[@"name"];
        }
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView
didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath: indexPath];
    cell.contentView.layer.cornerRadius = kCornerRadius;
    //cell.contentView.backgroundColor = [UIColor thirdMain];
}

- (void)collectionView:(UICollectionView *)collectionView
didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
//    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath: indexPath];
    //cell.contentView.backgroundColor = nil;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView.tag == 1) {
        NSArray *collectionViewArray = self.horzAlbumArray[[(HorzAlbumCollectionView *)collectionView indexPath].row];
        NSDictionary *dic = collectionViewArray[indexPath.item];
        
        if (![dic[@"album"][@"album_id"] isEqual: [NSNull null]]) {
            NSLog(@"album_id: %@", dic[@"album"][@"album_id"]);
            [self presentAlbumDetailVC:[dic[@"album"][@"album_id"] stringValue]];
        }
    } else if (collectionView.tag == 3) {
        NSDictionary *bannerDic = self.bannerDataArray[indexPath.row];
        NSString *bannerType = bannerDic[@"banner_type"];
        NSString *videoUrl = bannerDic[@"banner_type_data"][@"url"];
        
        if (![wTools objectExists: videoUrl]) {
            return;
        }
        
        if ([bannerType isEqualToString: @"image"]) {
            SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL: [NSURL URLWithString: videoUrl] entersReaderIfAvailable: NO];
            safariVC.delegate = self;
            safariVC.preferredBarTintColor = [UIColor whiteColor];
            [self presentViewController: safariVC animated: YES completion: nil];
        }
    } else {
        NSDictionary *pictureDic = self.categoryAreaArray[indexPath.row];
        
        if (![wTools objectExists: pictureDic[@"user_id"]]) {
            return;
        }
        
        CreaterViewController *cVC = [[UIStoryboard storyboardWithName: @"CreaterVC" bundle: nil] instantiateViewControllerWithIdentifier: @"CreaterViewController"];
        cVC.userId = pictureDic[@"user_id"];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.myNav pushViewController: cVC animated: YES];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    NSLog(@"minimumLineSpacingForSectionAtIndex");
    if (collectionView.tag == 1) {
        return 16.0;
    } else if (collectionView.tag == 2) {
        return 16.0;
    } else {
        return 0.0f;
    }    
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidScroll");
    NSLog(@"scrollView.contentOffset.y: %f", scrollView.contentOffset.y);
    if (!collectionView || collectionView.visibleCells.count < 1) return ;

    BannerCollectionViewCell *cell = collectionView.visibleCells[0];
    
    CGFloat yAxis = 0;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        int screenHeight = (int)[[UIScreen mainScreen] nativeBounds].size.height;
        switch (screenHeight) {
            case 1136:
                printf("iPhone 5 or 5S or 5C");
                yAxis = -48;
                break;
            case 1334:
                printf("iPhone 6/6S/7/8");
                yAxis = -48;
                break;
            case 1920:
                printf("iPhone 6+/6S+/7+/8+");
                yAxis = -48;
                break;
            case 2208:
                printf("iPhone 6+/6S+/7+/8+");
                yAxis = -48;
                break;
            //case 2436:
            default:
                //printf("iPhone X");
                yAxis = -48;
                //if (screenHeight >= 2436)

                yAxis = -72;
                break;
//            default:
//                printf("unknown");
//                yAxis = -48;
//                break;
        }
    }
    if (scrollView.contentOffset.y != yAxis) {
        [cell.playerView stopVideo];
    }
    if (scrollView == collectionView) {
        pageControl.currentPage = scrollView.contentOffset.x / scrollView.frame.size.width;
    }
}

// Play Video when Scroll Banner
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidEndDecelerating");
    
    if (scrollView == collectionView && collectionView.visibleCells.count > 0) {        
        BannerCollectionViewCell *cell = collectionView.visibleCells[0];
        [cell.playerView stopVideo];
        [cell.playerView playVideo];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        // Check video setting
        if (![[defaults objectForKey: @"isVideoPlayedAutomatically"] boolValue]) {
            [cell.playerView stopVideo];
        }
        [self handlePageControlValueChanged];
    }
}

#pragma mark -
- (void)toCategoryDetailVC {
    NSLog(@"toCategoryDetailVC");
    CategoryDetailViewController *cDVC = [[UIStoryboard storyboardWithName: @"CategoryDetailVC" bundle: nil] instantiateViewControllerWithIdentifier: @"CategoryDetailViewController"];
    cDVC.categoryAreaId = [self.categoryAreaId intValue];
    cDVC.categoryName = self.categoryName;
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav pushViewController: cDVC animated: YES];
}

#pragma mark - YTPlayerView Delegate Methods
- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView {
    NSLog(@"playerViewDidBecomeReady");
    [playerView playVideo];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Check video setting
    if (![[defaults objectForKey: @"isVideoPlayedAutomatically"] boolValue]) {
        [playerView stopVideo];
    }
}

- (void)playerView:(YTPlayerView *)playerView
  didChangeToState:(YTPlayerState)state {
    NSLog(@"didChangeToState");
    NSLog(@"state: %ld", (long)state);
    NSLog(@"self.tableView.contentOffset.y: %f", self.tableView.contentOffset.y);
    
//    kYTPlayerStateUnstarted,
//    kYTPlayerStateEnded,
//    kYTPlayerStatePlaying,
//    kYTPlayerStatePaused,
//    kYTPlayerStateBuffering,
//    kYTPlayerStateQueued,
//    kYTPlayerStateUnknown
    
    // state == 2 -> kYTPlayerStatePlaying
    if (state == 2) {
        CGFloat yAxis = 0;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            int screenHeight = (int)[[UIScreen mainScreen] nativeBounds].size.height;
            switch (screenHeight) {
                case 1136:
                    printf("iPhone 5 or 5S or 5C");
                    yAxis = -48;
                    break;
                case 1334:
                    printf("iPhone 6/6S/7/8");
                    yAxis = -48;
                    break;
                case 1920:
                    printf("iPhone 6+/6S+/7+/8+");
                    yAxis = -48;
                    break;
                case 2208:
                    printf("iPhone 6+/6S+/7+/8+");
                    yAxis = -48;
                    break;
                //case 2436:
                default:
                    printf("iPhone X");
                    yAxis = -48;
                    //if (screenHeight >= 2436)
//                    yAxis = -72;
                    break;
//                default:
//                    printf("unknown");
//                    yAxis = -48;
//                    break;
            }
        }
        // Meaning user scrolls down, video will be stopped
        // Video only plays when y axis is the original value
        NSLog(@"self.tableView.contentOffset.y: %f", self.tableView.contentOffset.y);
        NSLog(@"yAxis: %f", yAxis);
        
        if (self.tableView.contentOffset.y > yAxis) {
            [playerView stopVideo];
        }
    }
}

- (void)playerView:(YTPlayerView *)playerView
didChangeToQuality:(YTPlaybackQuality)quality {
    NSLog(@"didChangeToQuality");
}

- (void)playerView:(YTPlayerView *)playerView
     receivedError:(YTPlayerError)error {
    NSLog(@"receivedError");
}

#pragma mark - Custom Alert Method
- (void)showCustomErrorAlert: (NSString *)msg  {
    [UIViewController showCustomErrorAlertWithMessage:msg onButtonTouchUpBlock:^(CustomIOSAlertView *customAlertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[customAlertView tag]);
        [customAlertView close];
    }];
}

#pragma mark - Custom Method for TimeOut
- (void)showCustomTimeOutAlert: (NSString *)msg
                  protocolName: (NSString *)protocolName {
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
            if ([protocolName isEqualToString: @"getCategoryArea"]) {
                [weakSelf getCategoryArea];
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches
           withEvent:(UIEvent *)event {
    NSLog(@"");
    NSLog(@"touchesBegan");
    NSLog(@"");
    UITouch *touch = [touches anyObject];
    
    NSLog(@"touch.view: %@", touch.view);
    NSLog(@"touch.view.tag: %d", (int)touch.view.tag);
    
    if (touch.view.tag == 100) {
        [self userTapped];
    }
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
