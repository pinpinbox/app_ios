//
//  CategoryDetailViewController.m
//  wPinpinbox
//
//  Created by David on 5/30/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "CategoryDetailViewController.h"
#import "CategoryDetailCollectionViewCell.h"

#import "MyLayout.h"
#import "UIColor+Extensions.h"
#import "boxAPI.h"
#import "wTools.h"
#import "AsyncImageView.h"
#import "JCCollectionViewWaterfallLayout.h"
#import "CreaterViewController.h"
#import "AlbumDetailViewController.h"
#import "UIColor+HexString.h"
#import "CustomIOSAlertView.h"
#import "GlobalVars.h"
#import "AppDelegate.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "customLayout.h"
#import "LabelAttributeStyle.h"
#import "UIViewController+ErrorAlert.h"
#import "YAlbumDetailContainerViewController.h"

@interface CategoryDetailViewController () <customLayoutDelegate, UIGestureRecognizerDelegate> {
    BOOL isLoading;
    NSInteger nextId;
    NSMutableArray *categoryArray;
    NSInteger columnCount;
    NSInteger miniInteriorSpacing;
}
@property (nonatomic, strong) JCCollectionViewWaterfallLayout *jccLayout;
@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarHeight;
@end

@implementation CategoryDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"CategoryDetailViewController");
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.delegate = self;
    
    [self initialValueSetup];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self.collectionView reloadData];
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

#pragma mark -
- (void)initialValueSetup {
    nextId = 0;
    isLoading = NO;
    
    categoryArray = [NSMutableArray new];
    self.titleLabel.text = self.categoryName;
    self.navBarView.backgroundColor = [UIColor barColor];    
    self.collectionView.contentInset = UIEdgeInsetsMake(72, 0, 0, 0);
    
    columnCount = 2;
    miniInteriorSpacing = 16;
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

#pragma mark -
- (void)loadData{
    NSLog(@"loadData");
    if (!isLoading) {
        if (nextId == 0) {
            NSLog(@"nextId: %ld", (long)nextId);
        }
        isLoading = YES;
        [self retrieveHotRank];
    }
}

- (void)retrieveHotRank {
    NSLog(@"retrieveHotRank");
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    NSMutableDictionary *data = [NSMutableDictionary new];
    NSString *limit = [NSString stringWithFormat: @"%ld,%d", (long)nextId, 16];
    [data setValue: limit forKey: @"limit"];
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI retrieveHotRank: [wTools getUserID]
                                               token: [wTools getUserToken]
                                      categoryAreaId: wself.categoryAreaId
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
            if (response != nil) {
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"CategoryDetailViewController");
                    NSLog(@"retrieveHotRank");
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"retrieveHotRank"];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    [wself processHotRankResult:dic];
                }
            }
        });
    });
}

- (void)processHotRankResult:(NSDictionary *)dic {
    if ([dic[@"result"] intValue] == 1) {
        NSLog(@"dic data: %@", dic[@"data"]);
        NSLog(@"Before");
        NSLog(@"nextId: %ld", (long)nextId);
        
        if (nextId == 0) {
            categoryArray = [NSMutableArray new];
        }
        if (![wTools objectExists: dic[@"data"]]) {
            return;
        }
        // s for counting how much data is loaded
        int s = 0;
        
        for (NSMutableDictionary *picture in [dic objectForKey: @"data"]) {
            s++;
            [categoryArray addObject: picture];
        }
        NSLog(@"After");
        NSLog(@"nextId: %ld", (long)nextId);
        NSLog(@"s: %d", s);
        // If data keeps loading then the nextId is accumulating
        nextId = nextId + s;
        
        // If nextId is bigger than 0, that means there are some data loaded already.
        if (nextId >= 0) {
            isLoading = NO;
        }
        // If s is 0, that means dic data is empty.
        if (s == 0) {
            isLoading = YES;
        }
        NSLog(@"self.collectionView reloadData");
        [self.collectionView reloadData];
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

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return categoryArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"");
    NSLog(@"cellForItemAtIndexPath");
    CategoryDetailCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"CategoryDetailCell" forIndexPath: indexPath];
    NSDictionary *data = categoryArray[indexPath.row];
    NSLog(@"data: %@", data);
    
    cell.contentView.subviews[0].backgroundColor = nil;
    
    if ([data[@"album"][@"cover"] isEqual: [NSNull null]]) {
        cell.coverImageView.image = [UIImage imageNamed: @"bg200_no_image.jpg"];
    } else {
        [cell.coverImageView sd_setImageWithURL: [NSURL URLWithString: data[@"album"][@"cover"]]];
        cell.coverImageView.backgroundColor = [UIColor colorFromHexString: data[@"album"][@"cover_hex"]];
    }
    // UserForView Info Setting
    BOOL gotAudio = [data[@"album"][@"usefor"][@"audio"] boolValue];
    NSLog(@"gotAudio: %d", gotAudio);
    
    BOOL gotVideo = [data[@"album"][@"usefor"][@"video"] boolValue];
    NSLog(@"gotVideo: %d", gotVideo);
    
    BOOL gotExchange = [data[@"album"][@"usefor"][@"exchange"] boolValue];
    NSLog(@"gotExchange: %d", gotExchange);
    
    BOOL gotSlot = [data[@"album"][@"usefor"][@"slot"] boolValue];
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
    if (![data[@"album"][@"name"] isEqual: [NSNull null]]) {
        cell.albumNameLabel.text = data[@"album"][@"name"];
        [LabelAttributeStyle changeGapString: cell.albumNameLabel content: data[@"album"][@"name"]];
    }
    return cell;
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
    CategoryDetailCollectionViewCell *cell = (CategoryDetailCollectionViewCell *)[collectionView cellForItemAtIndexPath: indexPath];
    NSLog(@"cell.contentView.subviews: %@", cell.contentView.subviews);
    //cell.contentView.backgroundColor =
    cell.contentView.subviews[0].backgroundColor = [UIColor thirdMain];
    NSLog(@"cell.contentView.bounds: %@", NSStringFromCGRect(cell.contentView.bounds));
    
    NSDictionary *data = categoryArray[indexPath.row];
    NSLog(@"data: %@", data);
    
    NSString *albumId = [data[@"album"][@"album_id"] stringValue];
    
    if (![wTools objectExists: albumId]) {
        return;
    }
    
    CGRect source = [self.view convertRect:cell.frame fromView:collectionView];
    YAlbumDetailContainerViewController *aDVC = [YAlbumDetailContainerViewController albumDetailVCWithAlbumID:albumId sourceRect:source sourceImageView:cell.coverImageView noParam:NO];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav pushViewController: aDVC animated: YES];
    
//    AlbumDetailViewController *aDVC = [[UIStoryboard storyboardWithName: @"AlbumDetailVC" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumDetailViewController"];
//    //aDVC.data = [dic[@"data"] mutableCopy];
//    aDVC.albumId = albumId;
//    aDVC.snapShotImage = [wTools normalSnapshotImage: self.view];
//
//    CATransition *transition = [CATransition animation];
//    transition.duration = 0.5;
//    transition.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
//    transition.type = kCATransitionMoveIn;
//    transition.subtype = kCATransitionFromTop;
//
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [appDelegate.myNav.view.layer addAnimation: transition forKey: kCATransition];
//    [appDelegate.myNav pushViewController: aDVC animated: NO];
    
    
}

- (void)collectionView:(UICollectionView *)collectionView
didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    //UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath: indexPath];
    //cell.contentView.backgroundColor = nil;
    //cell.contentView.subviews[0].backgroundColor = nil;
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"");
    NSLog(@"sizeForItemAtIndexPath");
    CGFloat itemWidth = roundf((self.view.frame.size.width - (miniInteriorSpacing * (columnCount + 1))) / columnCount);
    NSDictionary *data = categoryArray[indexPath.row];
    
    // Check Width & Height return value is nil or not
    NSNumber *coverWidth = data[@"album"][@"cover_width"];
    NSNumber *coverHeight = data[@"album"][@"cover_height"];
    
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
    NSLog(@"itemWidth: %f", itemWidth);
    CGSize finalSize = CGSizeMake(widthForCoverImg, heightForCoverImg);
    NSLog(@"widthForCoverImg: %f", widthForCoverImg);
    
    finalSize = CGSizeMake(itemWidth, floorf(finalSize.height * itemWidth / finalSize.width));
    NSString *albumNameStr;
    
    if (![data[@"album"][@"name"] isEqual: [NSNull null]]) {
        albumNameStr = data[@"album"][@"name"];
    }
    finalSize = CGSizeMake(finalSize.width, finalSize.height + [self calculateHeightForLbl: albumNameStr width: itemWidth - 16]);
    NSLog(@"finalSize :%@",NSStringFromCGSize(finalSize));
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
        insetForSectionAtIndex:(NSInteger)section {
    UIEdgeInsets itemInset = UIEdgeInsetsMake(0, 16, 0, 16);
    return itemInset;
}

#pragma mark - UIScrollView Delegate Method
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidScroll");
    // getting the scroll offset
    CGFloat bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    NSLog(@"bottomEdge: %f", bottomEdge);
    NSLog(@"scrollView.contentSize.height: %f", scrollView.contentSize.height);
    
    if (bottomEdge >= scrollView.contentSize.height) {
        NSLog(@"We are at the bottom");
        [self loadData];
    }
}

#pragma mark - IBAction
- (IBAction)backBtnPress:(id)sender {
    //[self.navigationController popViewControllerAnimated: YES];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav popViewControllerAnimated: YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Custom Alert Method
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
            if ([protocolName isEqualToString: @"retrieveHotRank"]) {
                [weakSelf retrieveHotRank];
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
