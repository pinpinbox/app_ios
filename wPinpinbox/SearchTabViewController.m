//
//  SearchTabViewController.m
//  wPinpinbox
//
//  Created by David on 4/23/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "SearchTabViewController.h"
#import "ScanCodeViewController.h"
#import "UIColor+Extensions.h"
#import "boxAPI.h"
#import "wTools.h"
#import "JCCollectionViewWaterfallLayout.h"
#import "SearchTabCollectionViewCell.h"
#import "SearchTabHorizontalCollectionViewCell.h"
#import "SearchTabCollectionReusableView.h"
#import "AsyncImageView.h"
#import "CreaterViewController.h"
#import "QrcordViewController.h"
#import "AlbumDetailViewController.h"
#import "CustomIOSAlertView.h"
#import "GlobalVars.h"
#import "NSString+MD5.h"
#import  <SystemConfiguration/SCNetworkReachability.h>
#import "AppDelegate.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "LabelAttributeStyle.h"
#import "UIViewController+ErrorAlert.h"

static NSString *hostURL = @"www.pinpinbox.com";

@interface SearchTabViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, JCCollectionViewWaterfallLayoutDelegate, UITextFieldDelegate>
{
    BOOL isAlbumLoading;
    BOOL isAlbumReloading;
    NSInteger nextAlbumId;
    
    BOOL isUserLoading;
    BOOL isUserReloading;
    NSInteger nextUserId;
    
    NSMutableArray *albumData;
    NSMutableArray *userData;
    
    UILabel *userRecommendationLabel;
    UILabel *albumRecommendationLabel;
    
    UITextField *selectTextField;
    
    UIView *noInfoVertView;
    UIView *noInfoHorzView;
    
    BOOL isSearching;
    BOOL isNoInfoVertViewCreate;
    BOOL isNoInfoHorzViewCreate;        
    
    NSInteger columnCount;
    NSInteger miniInteriorSpacing;
}
@property (nonatomic, strong) JCCollectionViewWaterfallLayout *jccLayout;

@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (weak, nonatomic) IBOutlet UICollectionView *albumCollectionView;
@property (weak, nonatomic) UICollectionView *userCollectionView;
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIButton *cancelTextBtn;

@property (weak, nonatomic) IBOutlet UIButton *scanBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarHeight;
@end

@implementation SearchTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initialValueSetup];
    [self showUserRecommendedList];
    //[self showAlbumRecommendedList];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"");
    NSLog(@"SearchTabViewController viewWillAppear");
//    [wTools setStatusBarBackgroundColor: [UIColor whiteColor]];
    
    for (UIView *view in self.tabBarController.view.subviews) {
        UIButton *btn = (UIButton *)[view viewWithTag: 104];
        btn.hidden = NO;
    }
    self.scanBtn.backgroundColor = [UIColor thirdGrey];
    
    [self.albumCollectionView reloadData];
    [self.userCollectionView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [wTools setStatusBarBackgroundColor: [UIColor clearColor]];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)initialValueSetup {
    //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    //[self.view addGestureRecognizer:tap];
    
    self.albumCollectionView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0);
    self.albumCollectionView.showsVerticalScrollIndicator = NO;
    
    columnCount = 2;
    miniInteriorSpacing = 16;
    
    nextAlbumId = 0;
    isAlbumLoading = NO;
    isAlbumReloading = NO;
    
    nextUserId = 0;
    isUserLoading = NO;
    isUserReloading = NO;
    
    isSearching = NO;
    isNoInfoVertViewCreate = NO;;
    isNoInfoHorzViewCreate = NO;
    
    albumData = [NSMutableArray new];
    userData = [NSMutableArray new];
    
    self.navBarView.backgroundColor = [UIColor barColor];
    
    // JCCollectionViewWaterfallLayout
    self.jccLayout = (JCCollectionViewWaterfallLayout *)self.albumCollectionView.collectionViewLayout;
    self.jccLayout.headerHeight = 250;
    
    // Search View
    self.searchView.layer.cornerRadius = 8;
    
    // Search TextField
    self.searchTextField.textColor = [UIColor blackColor];
    
    UIToolbar *numberToolBar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, 0, 320, 40)];
    numberToolBar.barStyle = UIBarStyleDefault;
    numberToolBar.items = [NSArray arrayWithObjects:
                           //[[UIBarButtonItem alloc] initWithTitle: @"取消" style: UIBarButtonItemStylePlain target: self action: @selector(cancelNumberPad)],
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil],
                           [[UIBarButtonItem alloc] initWithTitle: @"完成" style: UIBarButtonItemStyleDone target: self action: @selector(dismissKeyboard)], nil];
    
    self.searchTextField.inputAccessoryView = numberToolBar;
    
    // CancelTextBtn Setting
    self.cancelTextBtn.layer.cornerRadius = 8;
    
    [self.cancelTextBtn addTarget: self
                           action: @selector(cancelButtonHighlight:)
                 forControlEvents: UIControlEventTouchDown];
    [self.cancelTextBtn addTarget: self
                           action: @selector(cancelButtonNormal:)
                 forControlEvents: UIControlEventTouchUpInside];
    
    self.cancelTextBtn.hidden = YES;
    
    // ScanBtn Setting
    self.scanBtn.layer.cornerRadius = kCornerRadius;
    
    [self.scanBtn addTarget: self
                           action: @selector(scanButtonHighlight:)
                 forControlEvents: UIControlEventTouchDown];
    [self.scanBtn addTarget: self
                           action: @selector(scanButtonNormal:)
                 forControlEvents: UIControlEventTouchUpInside];        
}

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

#pragma mark - Web Service
- (void)showUserRecommendedList {
    NSLog(@"showUserRecommendedList");
    userRecommendationLabel.text = @"創作人推薦";
    
    [wTools ShowMBProgressHUD];
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        wself->isUserLoading = YES;
        
        NSString *response = @"";
        
        NSMutableDictionary *data = [NSMutableDictionary new];
        [data setObject: @"user" forKey: @"type"];
        [data setObject: @"0,16" forKey: @"limit"];

        response = [boxAPI getRecommendedList: [wTools getUserID]
                                        token: [wTools getUserToken]
                                         data: data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"showUserRecommendedList");
                NSLog(@"response from getRecommendedList");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"SearchTableViewController");
                    NSLog(@"showUserRecommendedList");
                    [wself dismissKeyboard];
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"showUserRecommendedList"
                                            text: @""
                                         albumId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    //
                    
                    if (![dic[@"result"] boolValue]) {
                        return ;
                    }
                    
                    //判斷目前table和 搜尋結果是否相同
                    if (![data[@"type"] isEqualToString: @"user"]) {
                        return;
                    }
                    
                    [wself processResult:dic];
                }
            }
        });
    });
}
- (void)processResult:(NSDictionary *)dic {
    if ([dic[@"result"] intValue] == 1) {
        NSLog(@"dic result boolValue is 1");
        
        if (nextUserId >= 0) {
            isUserLoading = NO;
        } else {
            isUserLoading = YES;
        }
        NSLog(@"");
        NSLog(@"");
        
        userData = [NSMutableArray arrayWithArray:dic[@"data"]];
        nextUserId = userData.count;
        
        [self.userCollectionView reloadData];
        
        [self showAlbumRecommendedList];
    } else if ([dic[@"result"] intValue] == 0) {
        NSLog(@"失敗：%@",dic[@"message"]);
        [self showCustomErrorAlert: dic[@"message"]];
    } else {
        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
    }
}
- (void)showAlbumRecommendedList {
    NSLog(@"showAlbumRecommendedList");
    albumRecommendationLabel.text = @"人氣精選";
    
    [wTools ShowMBProgressHUD];
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        wself->isAlbumLoading = YES;
        
        NSString *response = @"";
        
        NSMutableDictionary *data = [NSMutableDictionary new];
        [data setObject: @"album" forKey: @"type"];
        [data setObject: @"0,16" forKey: @"limit"];

        response = [boxAPI getRecommendedList: [wTools getUserID]
                                        token: [wTools getUserToken]
                                         data: data];
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"showAlbumRecommendedList");
                NSLog(@"response from getRecommendedList");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"SearchTableViewController");
                    NSLog(@"showAlbumRecommendedList");
                    [self dismissKeyboard];
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"showAlbumRecommendedList"
                                            text: @""
                                         albumId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if (![dic[@"result"] boolValue]) {
                        return ;
                    }
                    //判斷目前table和 搜尋結果是否相同
                    if (![data[@"type"] isEqualToString: @"album"]) {
                        return;
                    }
                    [wself processSearchResult:dic];
                }
            }
        });
    });
}
- (void)processSearchResult:(NSDictionary *)dic {
    
    if ([dic[@"result"] intValue] == 1) {
        NSLog(@"dic result boolValue is 1");
        
        if (nextAlbumId >= 0) {
            isAlbumLoading = NO;
        } else {
            isAlbumLoading = YES;
        }
        albumData = [NSMutableArray arrayWithArray:dic[@"data"]];
        nextAlbumId = albumData.count;
        
        [self.albumCollectionView reloadData];
    } else if ([dic[@"result"] intValue] == 0) {
        NSLog(@"失敗：%@",dic[@"message"]);
        [self showCustomErrorAlert: dic[@"message"]];
    } else {
        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
    }
}
#pragma mark - UIButton Selector Methods
- (void)cancelButtonHighlight: (UIButton *)sender
{
    NSLog(@"cancelButtonHighlight");
    sender.backgroundColor = [UIColor thirdMain];
    self.cancelTextBtn.hidden = YES;
    
    self.searchTextField.text = @"";
    isSearching = NO;
    noInfoHorzView.hidden = YES;
    noInfoVertView.hidden = YES;
    
    [self showUserRecommendedList];
    //[self showAlbumRecommendedList];
}

- (void)cancelButtonNormal: (UIButton *)sender {
    NSLog(@"cancelButtonNormal");
    sender.backgroundColor = [UIColor clearColor];
}

- (void)scanButtonHighlight: (UIButton *)sender {
    NSLog(@"scanButtonHighlight");
    sender.backgroundColor = [UIColor thirdMain];
}

- (void)scanButtonNormal: (UIButton *)sender {
    NSLog(@"scanButtonNormal");
    sender.backgroundColor = [UIColor clearColor];
}

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    NSLog(@"");
    NSLog(@"");
    NSLog(@"numberOfItemsInSection");
    NSLog(@"albumData.count: %lu", (unsigned long)albumData.count);
    NSLog(@"userData.count: %lu", (unsigned long)userData.count);
    
    if (collectionView.tag == 1) {
        NSLog(@"collectionView.tag: %ld", (long)collectionView.tag);
        NSLog(@"albumData.count: %lu", (unsigned long)albumData.count);
        
        return albumData.count;
    } else {
        NSLog(@"collectionView.tag: %ld", (long)collectionView.tag);
        NSLog(@"userData.count: %lu", (unsigned long)userData.count);
        
        return userData.count;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"");
    NSLog(@"viewForSupplementaryElementOfKind");
    
    SearchTabCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind: kind withReuseIdentifier: @"SearchHeaderId" forIndexPath: indexPath];
    
    self.userCollectionView = headerView.userCollectionView;
    
    userRecommendationLabel = headerView.userRecommendationLabel;
    [LabelAttributeStyle changeGapString: userRecommendationLabel content: userRecommendationLabel.text];
    
    albumRecommendationLabel = headerView.albumRecommendationLabel;
    [LabelAttributeStyle changeGapString: albumRecommendationLabel content: albumRecommendationLabel.text];
    
    [self.albumCollectionView.collectionViewLayout invalidateLayout];
    
    return headerView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"");
    NSLog(@"");
    NSLog(@"cellForItemAtIndexPath");
    
    if (collectionView.tag == 1) {
        NSLog(@"collectionView.tag: %ld", (long)collectionView.tag);
        
        NSLog(@"albumRecommendationLabel: %@", albumRecommendationLabel);
        
        if (isSearching) {
            albumRecommendationLabel.text = @"找到的作品";
            [LabelAttributeStyle changeGapString: albumRecommendationLabel content: albumRecommendationLabel.text];
        } else {
            albumRecommendationLabel.text = @"人氣精選";
            [LabelAttributeStyle changeGapString: albumRecommendationLabel content: albumRecommendationLabel.text];
        }
        
        SearchTabCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SearchCell" forIndexPath: indexPath];
        
        cell.contentView.subviews[0].backgroundColor = nil;
        
        if (albumData.count == 0) {
            noInfoVertView.hidden = NO;
        } else if (albumData.count > 0) {
            noInfoVertView.hidden = YES;
        }
        
        NSDictionary *albumDic = albumData[indexPath.row][@"album"];
        //NSLog(@"albumDic: %@", albumDic);
        
        if ([albumDic[@"cover"] isEqual: [NSNull null]]) {
            cell.coverImageView.image = [UIImage imageNamed: @"bg200_no_image.jpg"];
        } else {
            [cell.coverImageView sd_setImageWithURL: [NSURL URLWithString: albumDic[@"cover"]]];
        }
        
        // UserForView Info Setting
        BOOL gotAudio = [albumDic[@"usefor"][@"audio"] boolValue];
        BOOL gotVideo = [albumDic[@"usefor"][@"video"] boolValue];
        BOOL gotExchange = [albumDic[@"usefor"][@"exchange"] boolValue];
        BOOL gotSlot = [albumDic[@"usefor"][@"slot"] boolValue];
        
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
            NSLog(@"gotExchange or gotSlot");
            
            cell.userInfoView.hidden = NO;
            [cell.btn3 setImage: [UIImage imageNamed: @"ic200_gift_dark"] forState: UIControlStateNormal];
            
            CGRect rect = cell.userInfoView.frame;
            rect.size.width = 28 * 1;
            cell.userInfoView.frame = rect;
        }
        
        // AlbumNameLabel Setting
        if (![albumDic[@"name"] isEqual: [NSNull null]]) {
            cell.albumNameLabel.text = albumDic[@"name"];
            [LabelAttributeStyle changeGapString: cell.albumNameLabel content: cell.albumNameLabel.text];
        }
        NSLog(@"cell.albumNameLabel.text: %@", cell.albumNameLabel.text);
        
        NSLog(@"cell.imgBgView.frame: %@", NSStringFromCGRect(cell.imgBgView.frame));
        
        return cell;
    } else {
        NSLog(@"collectionView.tag: %ld", (long)collectionView.tag);
        //NSLog(@"userData: %@", userData);
        
        if (isSearching) {
            userRecommendationLabel.text = @"找到的創作人";
        } else {
            userRecommendationLabel.text = @"創作人推薦";
        }
        if (userData.count == 0) {
            noInfoHorzView.hidden = NO;
        } else if (userData.count > 0) {
            noInfoHorzView.hidden = YES;
        }
        NSDictionary *userDic = userData[indexPath.row][@"user"];
        
        SearchTabHorizontalCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"horizontalCell" forIndexPath: indexPath];
        
        cell.contentView.backgroundColor = nil;
//        cell.userPictureImageView.imageURL = nil;
        
        if (![userDic isKindOfClass: [NSNull class]]) {
            if ([userDic[@"picture"] isEqual: [NSNull null]]) {
                cell.userPictureImageView.image = [UIImage imageNamed: @"member_back_head.png"];
            } else {
                [cell.userPictureImageView sd_setImageWithURL: [NSURL URLWithString: userDic[@"picture"]]
                                             placeholderImage: [UIImage imageNamed: @"member_back_head.png"]];                
            }
            cell.userNameLabel.text = userDic[@"name"];
            [LabelAttributeStyle changeGapString: cell.userNameLabel content: cell.userNameLabel.text];
        } else {
            NSLog(@"userData is nil");
        }
        return cell;
    }
}

#pragma mark - UICollectionViewDelegate Methods

- (BOOL)collectionView:(UICollectionView *)collectionView
shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath: indexPath];
    NSLog(@"cell.contentView.subviews: %@", cell.contentView.subviews);
    
    //cell.contentView.subviews[0].backgroundColor = [UIColor thirdMain];
    
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectItemAtIndexPath");
    
    NSLog(@"%ld", (long)collectionView.tag);
    
//    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath: indexPath];
    
    if (collectionView.tag == 1) {
        NSLog(@"");
        NSLog(@"");
        NSLog(@"self.albumCollectionView");
        //NSLog(@"cell.contentView.subviews: %@", cell.contentView.subviews);
//        cell.contentView.subviews[0].backgroundColor = [UIColor thirdMain];
        //NSLog(@"cell.contentView.bounds: %@", NSStringFromCGRect(cell.contentView.bounds));
        
        //NSDictionary *albumDic = albumData[indexPath.row][@"album"];
        //NSLog(@"albumDic: %@", albumDic);
        
        NSString *albumId = [albumData[indexPath.row][@"album"][@"album_id"] stringValue];
        [self ToRetrievealbumpViewControlleralbumid: albumId];
    } else {
        NSLog(@"");
        NSLog(@"");
        NSLog(@"self.userCollectionView");
        
        //cell.contentView.subviews[0].backgroundColor = [UIColor thirdMain];
        //cell.contentView.backgroundColor = [UIColor thirdMain];
        NSDictionary *userDic = userData[indexPath.row][@"user"];
        
        CreaterViewController *cVC = [[UIStoryboard storyboardWithName: @"CreaterVC" bundle: nil] instantiateViewControllerWithIdentifier: @"CreaterViewController"];
        cVC.userId = userDic[@"user_id"];
        //[self.navigationController pushViewController: cVC animated: YES];
        
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.myNav pushViewController: cVC animated: YES];
    }
}

- (void)collectionView:(UICollectionView *)collectionView
didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
//    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath: indexPath];
    //cell.contentView.backgroundColor = nil;
    //cell.contentView.subviews[0].backgroundColor = nil;
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"willDisplayCell");
    NSLog(@"indexPath.item: %ld", (long)indexPath.item);
    
    if (indexPath.item == (albumData.count - 1)) {
        
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"");
    NSLog(@"sizeForItemAtIndexPath");
    
    CGFloat itemWidth = roundf((self.view.frame.size.width - (miniInteriorSpacing * (columnCount + 1))) / columnCount);
    
    if (collectionView.tag == 1) {
        NSDictionary *data = albumData[indexPath.row][@"album"];
        
        //NSLog(@"data: %@", data);
        NSLog(@"data name: %@", data[@"name"]);
        
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
        
        if (![data[@"album"][@"name"] isEqual: [NSNull null]]) {
            albumNameStr = data[@"album"][@"name"];
        }
        
        finalSize = CGSizeMake(finalSize.width, finalSize.height + [self calculateHeightForLbl: albumNameStr width: itemWidth - 16] * 2);
        
        NSLog(@"size: %@",NSStringFromCGSize(finalSize));
        
        return finalSize;
        //return CGSizeMake(finalSize.width, finalSize.height * scale);
    } else {
        NSLog(@"self.albumCollectionView.frame: %@", NSStringFromCGRect(self.albumCollectionView.frame));
        return CGSizeMake(96, 130);
    }
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

// Horizontal Cell Spacing
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    NSLog(@"minimumInteritemSpacingForSectionAtIndex");
    
    return 16.0f;
}

// Vertical Cell Spacing
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    NSLog(@"minimumLineSpacingForSectionAtIndex");
    
    return 24.0f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
//    NSLog(@"insetForSectionAtIndex");
    UIEdgeInsets itemInset = UIEdgeInsetsMake(0, 16, 0, 16);
    return itemInset;
}

#pragma mark - JCCollectionViewWaterfallLayoutDelegate
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
 heightForHeaderInSection:(NSInteger)section
{
//    NSLog(@"heightForHeaderInSection");
    return self.jccLayout.headerHeight;
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [selectTextField resignFirstResponder];
    
    if (self.albumCollectionView.tag == 1) {
        if (isAlbumLoading) {
            NSLog(@"isLoading: %d", isAlbumLoading);
            return;
        }
    }
    if (self.albumCollectionView.tag == 200) {
        if (isUserLoading) {
            NSLog(@"isLoading: %d", isUserLoading);
            return;
        }
    }
}

#pragma mark - UITextField Delegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    selectTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    selectTextField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    NSLog(@"shouldChangeCharactersInRange");
    NSString *resultString = [textField.text stringByReplacingCharactersInRange: range
                                                                     withString: string];    
//    NSLog(@"textField.text: %@", textField.text);
//    NSLog(@"resultString: %@", resultString);
    
    if ([resultString isEqualToString: @""]) {
        NSLog(@"no text");
        self.cancelTextBtn.hidden = YES;
        
        noInfoHorzView.hidden = YES;
        noInfoVertView.hidden = YES;
    } else {
        NSLog(@"has text");
        self.cancelTextBtn.hidden = NO;
    }
    
    [self callProtocol: resultString];
    
    return YES;
}

#pragma mark - Search Session
- (void)callProtocol: (NSString *)text {
    NSLog(@"callProtocol");
    NSLog(@"text: %@", text);
    
    if ([text isEqualToString: @""]) {
        isSearching = NO;
        
        [self showUserRecommendedList];
        //[self showAlbumRecommendedList];
    } else {
        isSearching = YES;
        [self filterUserContentForSearchText: text];
        //[self filterAlbumContentForSearchText: text];
    }
    NSLog(@"isSearching: %d", isSearching);
}

- (void)filterUserContentForSearchText: (NSString *)text {
    NSLog(@"filterUserContentForSearchText");
    NSLog(@"text: %@", text);
    
    NSString *string = text;
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        wself->isUserLoading = YES;
        
        NSString *response = @"";
        
        NSMutableDictionary *data = [NSMutableDictionary new];
        [data setObject: @"user" forKey: @"searchtype"];
        [data setObject: string forKey: @"searchkey"];
        [data setObject: @"0,32" forKey: @"limit"];
        
        response = [boxAPI search: [wTools getUserID]
                            token: [wTools getUserToken]
                             data: data];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (response != nil) {
                NSLog(@"filterUserContentForSearchText");
                NSLog(@"response from search");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"SearchTableViewController");
                    NSLog(@"filterUserContentForSearchText");
                    
                    [wself dismissKeyboard];
                    
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"filterUserContentForSearchText"
                                            text: text
                                         albumId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if (![dic[@"result"] boolValue]) {
                        return ;
                    }
                    //判斷回傳是否一樣
                    if (![text isEqualToString:string]) {
                        return;
                    }
                    //判斷目前table和 搜尋結果是否相同
                    if (![data[@"searchtype"] isEqualToString: @"user"]) {
                        return;
                    }
                    
                    [wself processFilterUserContent:dic text:text];
                }
            }
        });
    });
}
- (void)processFilterUserContent:(NSDictionary *)dic text:(NSString *)text{
    
    if ([dic[@"result"] intValue] == 1) {
        NSLog(@"dic result boolValue is 1");
        
        if (nextUserId >= 0) {
            isUserLoading = NO;
        } else {
            isUserLoading = YES;
        }
        
        NSLog(@"");
        NSLog(@"");
        
        userData = [NSMutableArray arrayWithArray:dic[@"data"]];
        nextUserId = userData.count;
        
        //                        NSLog(@"userData: %@", userData);
        NSLog(@"userData.count: %lu", (unsigned long)userData.count);
        
        if (userData.count == 0) {
            if (!isNoInfoHorzViewCreate) {
                [self addNoInfoViewOnHorizontalCollectionView: @"沒有符合關鍵字的創作人"];
            }
            noInfoHorzView.hidden = NO;
        } else if (userData.count > 0) {
            noInfoHorzView.hidden = YES;
        }
        
        [self.userCollectionView reloadData];
        
        [self filterAlbumContentForSearchText: text];
    } else if ([dic[@"result"] intValue] == 0) {
        NSLog(@"失敗：%@",dic[@"message"]);
        [self showCustomErrorAlert: dic[@"message"]];
    } else {
        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
    }
}
- (void)filterAlbumContentForSearchText: (NSString *)text {
    NSLog(@"filterAlbumContentForSearchText");
    NSLog(@"text: %@", text);
    
    NSString *string = text;
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        wself->isAlbumLoading = YES;
        
        NSString *response = @"";
        
        NSMutableDictionary *data = [NSMutableDictionary new];
        [data setObject: @"album" forKey: @"searchtype"];
        [data setObject: string forKey: @"searchkey"];
        [data setObject: @"0,32" forKey: @"limit"];
        
        response = [boxAPI search: [wTools getUserID]
                            token: [wTools getUserToken]
                             data: data];
        __strong typeof(wself) sself = wself;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (response != nil) {
                NSLog(@"filterAlbumContentForSearchText");
                NSLog(@"response from search");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"SearchTableViewController");
                    NSLog(@"filterAlbumContentForSearchText");
                    
                    [sself dismissKeyboard];
                    
                    [sself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"filterAlbumContentForSearchText"
                                            text: text
                                         albumId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    if (![dic[@"result"] boolValue]) {
                        return ;
                    }
                    //判斷回傳是否一樣
                    if (![text isEqualToString:string]) {
                        return;
                    }
                    //判斷目前table和 搜尋結果是否相同
                    if (![data[@"searchtype"] isEqualToString: @"album"]) {
                        return;
                    }
                    [wself filterAlbumContentWithResult:dic];
                }
            }
        });
    });
}
- (void)filterAlbumContentWithResult:(NSDictionary *) dic{
    
    if ([dic[@"result"] intValue] == 1) {
        NSLog(@"dic result boolValue is 1");
        
        if (nextAlbumId >= 0) {
            isAlbumLoading = NO;
        } else {
            isAlbumLoading = YES;
        }
        NSLog(@"");
        NSLog(@"");
        
        albumData = [NSMutableArray arrayWithArray:dic[@"data"]];
        nextAlbumId = albumData.count;
        
        if (albumData.count == 0) {
            if (!isNoInfoVertViewCreate) {
                [self addNoInfoViewOnVerticalCollectionView: @"沒有符合關鍵字的作品"];
            }
            noInfoVertView.hidden = NO;
        } else if (albumData.count > 0) {
            noInfoVertView.hidden = YES;
        }
        
        [self.albumCollectionView reloadData];
    } else if ([dic[@"result"] intValue] == 0) {
        NSLog(@"失敗：%@",dic[@"message"]);
        [self showCustomErrorAlert: dic[@"message"]];
    } else {
        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
    }
}
#pragma mark - Method Only Called Once
- (void)addNoInfoViewOnHorizontalCollectionView:(NSString *)msg {
    NSLog(@"addNoInfoViewOnHorizontalCollectionView");
    
    if (!isNoInfoHorzViewCreate) {
        noInfoHorzView = [[UIView alloc] initWithFrame: CGRectMake(16, 20, self.view.bounds.size.width - 32, 100)];
        noInfoHorzView.backgroundColor = [UIColor secondGrey];
        noInfoHorzView.layer.cornerRadius = 32;
        noInfoHorzView.clipsToBounds = YES;
        noInfoHorzView.hidden = YES;
        
        [self.userCollectionView addSubview: noInfoHorzView];
        [self.userCollectionView bringSubviewToFront: noInfoHorzView];
        
        MyFrameLayout *frameLayout = [self createFrameLayout];
        [noInfoHorzView addSubview: frameLayout];
        
        UILabel *label = [self createLabel: msg];
        [frameLayout addSubview: label];
    }
    
    isNoInfoHorzViewCreate = YES;
}

- (void)addNoInfoViewOnVerticalCollectionView:(NSString *)msg {
    NSLog(@"addNoInfoViewOnVerticalCollectionView");
    
    if (!isNoInfoVertViewCreate) {
        noInfoVertView = [[UIView alloc] initWithFrame: CGRectMake(16, 260, self.view.bounds.size.width - 32, 100)];
        noInfoVertView.backgroundColor = [UIColor secondGrey];
        noInfoVertView.layer.cornerRadius = 32;
        noInfoVertView.clipsToBounds = YES;
        noInfoVertView.hidden = YES;
        
        [self.albumCollectionView addSubview: noInfoVertView];
        [self.albumCollectionView bringSubviewToFront: noInfoVertView];
        
        MyFrameLayout *frameLayout = [self createFrameLayout];
        [noInfoVertView addSubview: frameLayout];
        
        UILabel *label = [self createLabel: msg];
        [frameLayout addSubview: label];
    }
    
    isNoInfoVertViewCreate = YES;
}

- (MyFrameLayout *)createFrameLayout
{
    MyFrameLayout *frameLayout = [MyFrameLayout new];
    frameLayout.myMargin = 0;
    frameLayout.myCenterXOffset = 0;
    frameLayout.myCenterYOffset = 0;
    frameLayout.padding = UIEdgeInsetsMake(32, 32, 32, 32);
    
    return frameLayout;
}

- (UILabel *)createLabel: (NSString *)title
{
    UILabel *label = [UILabel new];
    label.text = title;
    label.font = [UIFont systemFontOfSize: 17];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    
    [label sizeToFit];
    
    label.myCenterXOffset = 0;
    label.myCenterYOffset = 0;
    
    return label;
}

#pragma mark - IBAction Method

- (IBAction)toScanCode:(id)sender {
    QrcordViewController *qVC = [[UIStoryboard storyboardWithName: @"QRCodeVC" bundle: nil] instantiateViewControllerWithIdentifier: @"QrcordViewController"];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav pushViewController: qVC animated: YES];
    /*
    ScanCodeViewController *scanCodeVC = [[UIStoryboard storyboardWithName: @"Main" bundle: [NSBundle mainBundle]] instantiateViewControllerWithIdentifier: @"ScanCodeViewController"];
    [self.navigationController pushViewController: scanCodeVC animated: YES];
     */
}

#pragma mark - Call Protocol
- (void)ToRetrievealbumpViewControlleralbumid:(NSString *)albumid {
    NSLog(@"ToRetrievealbumpViewControlleralbumid");
    [wTools ShowMBProgressHUD];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSString *response = [boxAPI retrievealbump: albumid
                                                uid: [wTools getUserID]
                                              token: [wTools getUserToken]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"response from retrievealbump");
                //NSLog(@"respone: %@", respone);
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"SearchTableViewController");
                    NSLog(@"ToRetrievealbumpViewControlleralbumid");
                    
                    [self dismissKeyboard];
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"retrievealbump"
                                            text: @""
                                         albumId: albumid];
                } else {
                    NSLog(@"Get Real Response");
                    
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        NSLog(@"result bool value is YES");
                        
                        
                        NSLog(@"dic data photo: %@", dic[@"data"][@"photo"]);
                        
                        NSLog(@"dic data user name: %@", dic[@"data"][@"user"][@"name"]);
                        
                        AlbumDetailViewController *aDVC = [[UIStoryboard storyboardWithName: @"AlbumDetailVC" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumDetailViewController"];
                        aDVC.data = [dic[@"data"] mutableCopy];
                        aDVC.albumId = albumid;
                        aDVC.snapShotImage = [wTools normalSnapshotImage: self.view];
                        
                        CATransition *transition = [CATransition animation];
                        transition.duration = 0.5;
                        transition.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
                        transition.type = kCATransitionMoveIn;
                        transition.subtype = kCATransitionFromTop;
                        
                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        [appDelegate.myNav.view.layer addAnimation: transition forKey: kCATransition];
                        [appDelegate.myNav pushViewController: aDVC animated: NO];
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗：%@",dic[@"message"]);
                        [self showCustomErrorAlert: dic[@"message"]];
                    } else {
                        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            }
        });
    });
}

#pragma mark - Custom Error Alert Method
- (void)showCustomErrorAlert: (NSString *)msg
{
    [UIViewController showCustomErrorAlertWithMessage:msg onButtonTouchUpBlock:^(CustomIOSAlertView *customAlertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[customAlertView tag]);
        [customAlertView close];
    }];
    
}
/*
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
*/
#pragma mark - Custom Method for TimeOut
- (void)showCustomTimeOutAlert: (NSString *)msg
                  protocolName: (NSString *)protocolName
                          text: (NSString *)text
                       albumId: (NSString *)albumId
{
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
            if ([protocolName isEqualToString: @"showUserRecommendedList"]) {
                [weakSelf showUserRecommendedList];
            } else if ([protocolName isEqualToString: @"showAlbumRecommendedList"]) {
                [weakSelf showAlbumRecommendedList];
            } else if ([protocolName isEqualToString: @"filterUserContentForSearchText"]) {
                [weakSelf filterUserContentForSearchText: text];
            } else if ([protocolName isEqualToString: @"filterAlbumContentForSearchText"]) {
                [weakSelf filterAlbumContentForSearchText: text];
            } else if ([protocolName isEqualToString: @"retrievealbump"]) {
                [weakSelf ToRetrievealbumpViewControlleralbumid: albumId];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
