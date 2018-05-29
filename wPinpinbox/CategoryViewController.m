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

//#define kUserImageViewNumber 6

@interface CategoryViewController () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, SFSafariViewControllerDelegate, YTPlayerViewDelegate>
{
    //NSMutableArray *albumExploreArray;
    UICollectionView *collectionView;
    UIPageControl *pageControl;
    MyLinearLayout *bannerVertLayout;
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

@property (weak, nonatomic) IBOutlet MyLinearLayout *userLayout;
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

@end

@implementation CategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //NSLog(@"self.categoryName: %@", self.categoryName);
    NSLog(@"CategoryViewController");
    NSLog(@"viewDidLoad");
    
    [self initialValueSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialValueSetup {
    NSLog(@"initialValueSetup");
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
    
    self.userLayout.userInteractionEnabled = YES;
    //self.userLayout.myCenterYOffset = 0;
    self.userLayout.orientation = 1;
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
    self.closeBtnHeight.constant = 0;
    self.closeBtn.hidden = YES;
    
    [LabelAttributeStyle changeGapString: self.creatorLabel content: @"創作人推薦"];
    [self.closeBtn setTitleColor: [UIColor firstGrey] forState: UIControlStateNormal];
    
    NSLog(@"self.categoryAreaId: %@", self.categoryAreaId);
    
    if ([self.categoryAreaId isEqualToString: @"-1"]) {
        NSLog(@"self.categoryAreaId isEqualToString: -1");
        NSLog(@"self.dic: %@", self.dic);
        [self setupData];
    } else {
        [self getCategoryArea];
    }
}

- (void)setupData {
    self.categoryName = @"拼星聞";
    self.albumArray = [NSMutableArray arrayWithArray: self.dic[@"data"][@"albumexplore"]];
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
    }];
}

#pragma mark - IBAction Methods
- (IBAction)backBtnPressed:(id)sender {
    //[self.navigationController popViewControllerAnimated: YES];
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
        self.closeBtnHeight.constant = 0;
        self.closeBtn.hidden = YES;
        //[self.userLayout layoutIfNeeded];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
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
            case 2208:
                printf("iPhone 6+/6S+/7+/8+");
                break;
            case 2436:
                NSLog(@"\n");
                printf("iPhone X");
                NSLog(@"UI Setting");
                //self.userLayout.myCenterYOffset = 20;
                //self.navBtn.myCenterYOffset = 20;
                self.navBarViewHeight.constant = navBarHeightConstant + 5;
                self.creatorLabelTopConstraint.constant = 90;
                self.closeBtnTopConstraint.constant = 90;
                break;
            default:
                printf("unknown");
                break;
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
                    
                    NSLog(@"dic: %@", dic);
                    
                    if ([dic[@"result"] isEqualToString: @"SYSTEM_OK"]) {
                        NSLog(@"dic data: %@", dic[@"data"]);
                        NSLog(@"dic data categoryarea: %@", dic[@"data"][@"categoryarea"]);
                        
//                        if (![dic[@"data"][@"categoryarea"][@"categoryarea"][@"name"] isEqual: [NSNull null]]) {
//                            self.categoryName = dic[@"data"][@"categoryarea"][@"categoryarea"][@"name"];
//                            NSLog(@"\n\nself.categoryName: %@", self.categoryName);
//                        }
                        
                        if (![dic[@"data"][@"categoryarea"][@"name"] isEqual: [NSNull null]]) {
                            self.categoryName = dic[@"data"][@"categoryarea"][@"name"];
                        }
                        
                        if (![dic[@"data"][@"categoryarea_style"] isEqual: [NSNull null]]) {
                            self.categoryareaStyleArray = [NSMutableArray arrayWithArray: dic[@"data"][@"categoryarea_style"]];
                        }
                        NSLog(@"self.categoryareaStyleArray: %@", self.categoryareaStyleArray);
                        
                        if (self.categoryareaStyleArray.count > 0) {
                            for (NSDictionary *styleDic1 in self.categoryareaStyleArray) {
                                NSLog(@"styleDic1: %@", styleDic1);
                                
                                if ([styleDic1[@"banner_type"] isEqualToString: @"creative"]) {
                                    NSLog(@"styleDic1 banner_type_data: %@", styleDic1[@"banner_type_data"]);
                                    self.categoryAreaArray = [NSMutableArray arrayWithArray: styleDic1[@"banner_type_data"]];
                                    [self addUserView];
                                } else {
                                    [self.bannerDataArray addObject: styleDic1];
                                }
                            }
                        }
                        
//                        if (![dic[@"data"][@"categoryarea"][@"user"] isEqual: [NSNull null]]) {
//                            self.categoryAreaArray = [NSMutableArray arrayWithArray: dic[@"data"][@"categoryarea"][@"user"]];
//                            NSLog(@"self.categoryAreaArray: %@", self.categoryAreaArray);
//                            [self addUserView];
//                        }
                        
                        if (![dic[@"data"][@"albumexplore"] isEqual: [NSNull null]]) {
                            self.albumArray = [NSMutableArray arrayWithArray: dic[@"data"][@"albumexplore"]];
                            
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
                        
                        [self.tableView reloadData];
                        [self.userCollectionView reloadData];
                    } else if ([dic[@"result"] isEqualToString: @"SYSTEM_ERROR"]) {
                        NSLog(@"SYSTEM_ERROR");
                        NSLog(@"失敗：%@",dic[@"message"]);
                        NSString *msg = dic[@"message"];
                        
                        if (msg == nil) {
                            msg = NSLocalizedString(@"Host-NotAvailable", @"");
                        }
                        [self showCustomErrorAlert: dic[@"message"]];
                        
                        
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
        UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 40, 40)];
        
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
        imageView.myLeftMargin = -15;
        imageView.myCenterYOffset = 0;
        //imageView.myTopMargin = imageView.myBottomMargin = 0;
        imageView.layer.cornerRadius = imageView.frame.size.width / 2;
        imageView.clipsToBounds = YES;
        imageView.layer.borderColor = [UIColor thirdGrey].CGColor;
        imageView.layer.borderWidth = 0.5;
        
        [self.userLayout addSubview: imageView];
    }
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
    
    CategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"CategoryCell" forIndexPath: indexPath];
    cell.albumExploreLabel.text = self.albumExploreArray[indexPath.row][@"name"];
    [LabelAttributeStyle changeGapString: cell.albumExploreLabel content: self.albumExploreArray[indexPath.row][@"name"]];
    NSLog(@"cell.albumExploreLabel.text: %@", cell.albumExploreLabel.text);
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
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
heightForHeaderInSection:(NSInteger)section {
    NSLog(@"");
    NSLog(@"heightForHeaderInSection");
    
    if (self.bannerDataArray.count > 0) {
        return 180;
    } else {
        return 45;
    }
}

- (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section {
    NSLog(@"");
    NSLog(@"viewForHeaderInSection");
    MyLinearLayout *bannerVertLayout = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Vert];
    bannerVertLayout.myTopMargin = 0;
    bannerVertLayout.myLeftMargin = bannerVertLayout.myRightMargin = 0;
//    bannerVertLayout.myBottomMargin = 0;
//    bannerVertLayout.backgroundColor = [UIColor blueColor];
//    bannerVertLayout.wrapContentHeight = YES;
    
    // The height should be the same as heightForHeaderInSection
    
    if (self.bannerDataArray.count > 0) {
        bannerVertLayout.heightDime.max(180);
        
        // Horizontal CollectionView Setting
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(self.view.bounds.size.width, 180);
        layout.minimumLineSpacing = 0;
        
        collectionView = [[UICollectionView alloc] initWithFrame: CGRectMake(0, 0, self.view.bounds.size.width, 180) collectionViewLayout: layout];
        collectionView.myTopMargin = 0;
        collectionView.myBottomMargin = 8;
        collectionView.myLeftMargin = collectionView.myRightMargin = 0;
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.tag = 3;
        collectionView.pagingEnabled = YES;
        
        [collectionView registerNib: [UINib nibWithNibName: @"BannerImageView" bundle: [NSBundle mainBundle]] forCellWithReuseIdentifier: @"BannerCell"];
        [collectionView registerNib: [UINib nibWithNibName: @"YoutubePlayer" bundle: [NSBundle mainBundle]] forCellWithReuseIdentifier: @"YoutubeCell"];
        
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.showsHorizontalScrollIndicator = NO;
        [bannerVertLayout addSubview: collectionView];
        
        pageControl = [[UIPageControl alloc] initWithFrame: CGRectMake(0, 0, 50, 30)];
        pageControl.myCenterXOffset = 0;
        pageControl.myTopMargin = pageControl.myBottomMargin = 8;
        pageControl.numberOfPages = self.bannerDataArray.count;
        pageControl.pageIndicatorTintColor = [UIColor secondGrey];
        pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
        pageControl.userInteractionEnabled = NO;
        [bannerVertLayout addSubview: pageControl];
    } else {
        bannerVertLayout.heightDime.max(45);
    }
    
    MyRelativeLayout *headerHorzLayout = [MyRelativeLayout new];
    headerHorzLayout.myTopMargin = 8;
    headerHorzLayout.myLeftMargin = headerHorzLayout.myRightMargin = 0;
    headerHorzLayout.myBottomMargin = 0;
    headerHorzLayout.wrapContentHeight = YES;
//    headerHorzLayout.backgroundColor = [UIColor redColor];
    
    UILabel *topicLabel = [UILabel new];
    topicLabel.myTopMargin = 0;
    topicLabel.myLeftMargin = 16;
    topicLabel.myRightMargin = 0.5;
    
    if (self.categoryName == nil) {
        self.categoryName = @"";
    }
    topicLabel.text = self.categoryName;
    topicLabel.textColor = [UIColor firstGrey];
    [LabelAttributeStyle changeGapString: topicLabel content: self.categoryName];
    topicLabel.font = [UIFont boldSystemFontOfSize: 48];
    [topicLabel sizeToFit];
    [headerHorzLayout addSubview: topicLabel];
    
    /*
    if (![self.categoryAreaId isEqualToString: @"-1"]) {
        UIButton *btn = [UIButton buttonWithType: UIButtonTypeCustom];
        [btn setTitle: @"全部" forState: UIControlStateNormal];
        [LabelAttributeStyle changeGapString: btn.titleLabel content: @"全部"];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize: 18];
        [btn setTitleColor: [UIColor firstGrey] forState: UIControlStateNormal];
        btn.myRightMargin = 16;
        btn.frame = CGRectMake(0, 0, 40, 40);
        btn.bottomPos.equalTo(topicLabel.bottomPos);
        
        [btn addTarget: self action: @selector(toCategoryDetailVC) forControlEvents: UIControlEventTouchUpInside];
        //btn.backgroundColor = [UIColor greenColor];
        //[btn sizeToFit];
        [headerHorzLayout addSubview: btn];
    }
     */
    
    [headerHorzLayout sizeToFit];
//    self.tableView.tableHeaderView = headerHorzLayout;
//    return headerHorzLayout;
    
    [bannerVertLayout addSubview: headerHorzLayout];
    [bannerVertLayout sizeToFit];
    
    self.tableView.tableHeaderView = bannerVertLayout;
    return bannerVertLayout;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"");
    NSLog(@"heightForRowAtIndexPath");
    return 280.0;
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
        NSLog(@"dic: %@", dic);
        
        if ([dic[@"album"][@"cover"] isEqual: [NSNull null]]) {
            cell.albumImageView.image = [UIImage imageNamed: @"bg200_no_image.jpg"];
        } else {
            [cell.albumImageView sd_setImageWithURL: [NSURL URLWithString: dic[@"album"][@"cover"]]];
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
        
//        if (indexPath.row == 0) {
//            cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"YoutubeCell" forIndexPath: indexPath];
//            NSDictionary *playerVars = @{@"playsinline" : @1};
//            [cell.playerView loadWithVideoId: @"U0gqIXmLIKk" playerVars: playerVars];
//        } else if (indexPath.row == 1) {
//            cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"YoutubeCell" forIndexPath: indexPath];
//            NSDictionary *playerVars = @{@"playsinline" : @1};
//            [cell.playerView loadWithVideoId: @"WXmdVEkJKGg" playerVars: playerVars];
//        } else if (indexPath.row == 2) {
//            cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"BannerCell" forIndexPath: indexPath];
//            cell.bannerImageView.image = [UIImage imageNamed: @"05"];
//        }
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
        
        AlbumDetailViewController *aDVC = [[UIStoryboard storyboardWithName: @"AlbumDetailVC" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumDetailViewController"];
        
        if (![dic[@"album"][@"album_id"] isEqual: [NSNull null]]) {
            NSLog(@"album_id: %@", dic[@"album"][@"album_id"]);
            aDVC.albumId = [dic[@"album"][@"album_id"] stringValue];
        }
        
        CATransition *transition = [CATransition animation];
        transition.duration = 0.5;
        transition.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        transition.subtype = kCATransitionFromTop;
        [self.navigationController.view.layer addAnimation: transition forKey: kCATransition];
        //[self.navigationController pushViewController: aDVC animated: NO];
        
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.myNav pushViewController: aDVC animated: NO];
    } else if (collectionView.tag == 3) {
        NSDictionary *bannerDic = self.bannerDataArray[indexPath.row];
        NSString *bannerType = bannerDic[@"banner_type"];
        NSString *videoUrl = bannerDic[@"banner_type_data"][@"url"];
        
        if ([bannerType isEqualToString: @"image"]) {
            SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL: [NSURL URLWithString: videoUrl] entersReaderIfAvailable: NO];
            safariVC.delegate = self;
            safariVC.preferredBarTintColor = [UIColor whiteColor];
            [self presentViewController: safariVC animated: YES completion: nil];
        }
    } else {
        NSDictionary *pictureDic = self.categoryAreaArray[indexPath.row];
        
        CreaterViewController *cVC = [[UIStoryboard storyboardWithName: @"CreaterVC" bundle: nil] instantiateViewControllerWithIdentifier: @"CreaterViewController"];
        cVC.userId = pictureDic[@"user_id"];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.myNav pushViewController: cVC animated: YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidScroll");
    NSLog(@"scrollView.contentOffset.y: %f", scrollView.contentOffset.y);
    
    BannerCollectionViewCell *cell = collectionView.visibleCells[0];
    
    if (scrollView.contentOffset.y != -48) {
        [cell.playerView stopVideo];
    }
    
    if (scrollView == collectionView) {
        pageControl.currentPage = scrollView.contentOffset.x / scrollView.frame.size.width;
    }
}

// Play Video when Scroll Banner
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidEndDecelerating");
    
    if (scrollView == collectionView) {
        BannerCollectionViewCell *cell = collectionView.visibleCells[0];
        [cell.playerView stopVideo];
        [cell.playerView playVideo];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        // Check video setting
        if (![[defaults objectForKey: @"isVideoPlayedAutomatically"] boolValue]) {
            [cell.playerView stopVideo];
        }
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

- (void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state {
    NSLog(@"didChangeToState");
    NSLog(@"state: %ld", (long)state);
    
    NSLog(@"self.tableView.contentOffset.y: %f", self.tableView.contentOffset.y);
    
    if (state == 2) {
        if (self.tableView.contentOffset.y > -72) {
            [playerView stopVideo];
        }
    }
}

- (void)playerView:(YTPlayerView *)playerView didChangeToQuality:(YTPlaybackQuality)quality {
    NSLog(@"didChangeToQuality");
}

- (void)playerView:(YTPlayerView *)playerView receivedError:(YTPlayerError)error {
    NSLog(@"receivedError");
}

#pragma mark - Custom Alert Method
- (void)showCustomErrorAlert: (NSString *)msg  {
    CustomIOSAlertView *errorAlertView = [[CustomIOSAlertView alloc] init];
    [errorAlertView setContainerView: [self createErrorContainerView: msg]];
    
    [errorAlertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    [errorAlertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    [errorAlertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    errorAlertView.arrangeStyle = @"Horizontal";
    
    /*
     [alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
     [alertView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor firstMain], [UIColor firstPink], [UIColor secondGrey], nil]];
     [alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor darkMain], [UIColor darkPink], [UIColor firstGrey], nil]];
     alertView.arrangeStyle = @"Vertical";
     */
    
    __weak CustomIOSAlertView *weakErrorAlertView = errorAlertView;
    [errorAlertView setOnButtonTouchUpInside:^(CustomIOSAlertView *customAlertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[customAlertView tag]);
        [weakErrorAlertView close];
    }];
    [errorAlertView setUseMotionEffects: YES];
    [errorAlertView show];
}

- (UIView *)createErrorContainerView: (NSString *)msg
{
    // TextView Setting
    UITextView *textView = [[UITextView alloc] initWithFrame: CGRectMake(10, 30, 280, 20)];
    //textView.text = @"帳號已經存在，請使用另一個";
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
    [imageView setImage:[UIImage imageNamed:@"icon_2_0_0_dialog_error"]];
    
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
    contentView.backgroundColor = [UIColor firstPink];
    
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

#pragma mark - Custom Method for TimeOut
- (void)showCustomTimeOutAlert: (NSString *)msg
                  protocolName: (NSString *)protocolName
{
    CustomIOSAlertView *alertTimeOutView = [[CustomIOSAlertView alloc] init];
    alertTimeOutView.parentView = self.view;
    [alertTimeOutView setContainerView: [self createTimeOutContainerView: msg]];
    
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertTimeOutView.arrangeStyle = @"Horizontal";
    
    alertTimeOutView.parentView = self.view;
    [alertTimeOutView setButtonTitles: [NSMutableArray arrayWithObjects: NSLocalizedString(@"TimeOut-CancelBtnTitle", @""), NSLocalizedString(@"TimeOut-OKBtnTitle", @""), nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertTimeOutView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstMain],nil]];
    [alertTimeOutView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor whiteColor], nil]];
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

- (UIView *)createTimeOutContainerView: (NSString *)msg
{
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
           withEvent:(UIEvent *)event
{
    NSLog(@"");
    NSLog(@"touchesBegan");
    NSLog(@"");
    
    UITouch *touch = [touches anyObject];
    
    NSLog(@"touch.view: %@", touch.view);
    NSLog(@"touch.view.tag: %ld", touch.view.tag);
    
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
