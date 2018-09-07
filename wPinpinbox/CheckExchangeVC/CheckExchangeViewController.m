//
//  CheckExchangeViewController.m
//  wPinpinbox
//
//  Created by David on 08/03/2018.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "CheckExchangeViewController.h"
#import "CheckExchangeCollectionViewCell.h"
#import "ExchangeStuff.h"

#import "boxAPI.h"
#import "wTools.h"
#import "CustomIOSAlertView.h"

#import "GlobalVars.h"
#import "UIColor+Extensions.h"
#import "UIView+Toast.h"

#import <SDWebImage/UIImageView+WebCache.h>

#import "LabelAttributeStyle.h"
#import "UIViewController+ErrorAlert.h"

@interface CheckExchangeViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    NSInteger columnCount;
    NSInteger miniInteriorSpacing;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
//@property (nonatomic, strong) NSMutableArray *checkExchangeArray;
//@property (strong, nonatomic) NSArray *exchangeStuffs;
//@property (strong, nonatomic) NSMutableArray *exchangeData;
@property (strong, nonatomic) NSMutableArray *hasExchangedData;
@property (strong, nonatomic) NSMutableArray *hasNotExchangedData;
@property (weak, nonatomic) UIImageView *zoomView;
@property (strong, nonatomic) CheckExchangeCollectionViewCell *selectedCell;

@end

@implementation CheckExchangeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"CheckExchangeViewController viewDidLoad");
    
    [self initialValueSetup];
    [self getBookmarkList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialValueSetup {
    columnCount = 2;
    miniInteriorSpacing = 16;
    
    if (self.hasExchanged) {
        self.hasExchangedData = [[NSMutableArray alloc] init];
    } else {
        self.hasNotExchangedData = [[NSMutableArray alloc] init];
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 1136:
                printf("iPhone 5 or 5S or 5C");
                self.collectionView.contentInset = UIEdgeInsetsMake(16.0, 0.0, 68.0, 0.0);
                break;
            case 1334:
                printf("iPhone 6/6S/7/8");
                self.collectionView.contentInset = UIEdgeInsetsMake(16.0, 0.0, 68.0, 0.0);
                break;
            case 1920:
                printf("iPhone 6+/6S+/7+/8+");
                self.collectionView.contentInset = UIEdgeInsetsMake(16.0, 0.0, 68.0, 0.0);
                break;
            case 2208:
                printf("iPhone 6+/6S+/7+/8+");
                self.collectionView.contentInset = UIEdgeInsetsMake(16.0, 0.0, 68.0, 0.0);
                break;
            case 2436:
                printf("iPhone X");
                self.collectionView.contentInset = UIEdgeInsetsMake(16.0, 0.0, 102.0, 0.0);
                break;
            default:
                printf("unknown");
                self.collectionView.contentInset = UIEdgeInsetsMake(16.0, 0.0, 68.0, 0.0);
                break;
        }
    }
    
    self.collectionView.showsVerticalScrollIndicator = NO;
    
}

#pragma mark - Get Bookmark List
- (void)getBookmarkList {
    NSLog(@"getBookmarkList");
    
    [wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *response = [boxAPI getBookmarkList: [wTools getUserToken] userId: [wTools getUserID]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"response from getBookmarkList");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"CheckExchangeViewController");
                    NSLog(@"getBookmarkList");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getBookmarkList"];
                } else {
                    NSLog(@"Get Real Response");
                    NSLog(@"Get response from getBookmarkList");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] isEqualToString: @"SYSTEM_OK"]) {
                        NSLog(@"SYSTEM_OK");
                        NSLog(@"dic: %@", dic);
                        
                        for (NSMutableDictionary *data in [dic objectForKey: @"data"]) {
                            NSLog(@"data: %@", data);
                            
                            if ([data[@"photo"][@"has_gained"] boolValue] == YES) {
                                NSLog(@"has_gained TRUE");
                                [self.hasExchangedData addObject: data];
                            } else {
                                NSLog(@"has_gained FALSE");
                                [self.hasNotExchangedData addObject: data];
                            }
//                            [self.exchangeData addObject: data];
                        }
                        
                        NSLog(@"self.hasExchangedData: %@", self.hasExchangedData);
                        NSLog(@"self.hasNotExchangedData: %@", self.hasNotExchangedData);
                        
                        [self.collectionView reloadData];
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

- (void)removeDicData:(NSMutableDictionary *)dic {
    NSLog(@"Before removing");
    NSLog(@"self.hasNotExchangedData: %@", self.hasNotExchangedData);
    NSLog(@"dic: %@", dic);
    
    NSMutableArray *tempArray = [NSMutableArray new];
    
    for (NSMutableDictionary *d in self.hasNotExchangedData) {
        NSLog(@"d: %@", d);
        
        if (d[@"photo"][@"photo_id"] == dic[@"photo"][@"photo_id"]) {
            [tempArray addObject: d];
//            [self.hasNotExchangedData removeObject: d];
        }
    }
    
    [self.hasNotExchangedData removeObjectsInArray: tempArray];
    [self.collectionView reloadData];
}

- (void)addDicData:(NSMutableDictionary *)dic {
    NSLog(@"Before adding");
    NSLog(@"self.hasExchangedData.count: %lu", (unsigned long)self.hasExchangedData.count);
    NSLog(@"self.hasExchangedData: %@", self.hasExchangedData);
    NSLog(@"dic: %@", dic);
    
    BOOL isNewDic = NO;
    
    for (NSMutableDictionary *d in self.hasExchangedData) {
        if (d[@"photo"][@"photo_id"] == dic[@"photo"][@"photo_id"]) {
            NSLog(@"dic data already exists");
        } else {
            NSLog(@"dic data didn't exist");
            NSLog(@"dic: %@", dic);
            isNewDic = YES;
        }
    }
    
    if (isNewDic) {
        [self.hasExchangedData addObject: dic];
    }
    
    NSLog(@"After adding");
    NSLog(@"self.hasExchangedData.count: %lu", (unsigned long)self.hasExchangedData.count);
    NSLog(@"self.hasExchangedData: %@", self.hasExchangedData);
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSLog(@"numberOfSectionsInCollectionView");
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    NSLog(@"numberOfItemsInSection");
    if (self.hasExchanged) {
        return self.hasExchangedData.count;
    } else {
        return self.hasNotExchangedData.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForItemAtIndexPath");
    CheckExchangeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"Cell" forIndexPath: indexPath];    

    NSDictionary *data;

    if (self.hasExchanged) {
        data = self.hasExchangedData[indexPath.row];
    } else {
        data = self.hasNotExchangedData[indexPath.row];
    }
    NSLog(@"data: %@", data);
    
    if ([data[@"photousefor"][@"image"] isEqual: [NSNull null]]) {
        cell.imageView.image = [UIImage imageNamed: @"bg200_no_image.jpg"];
    } else {
        [cell.imageView sd_setImageWithURL: [NSURL URLWithString: data[@"photousefor"][@"image"]] placeholderImage: [UIImage imageNamed: @"bg200_no_image.jpg"]];
    }
    
    if (![data[@"photousefor"][@"name"] isEqual: [NSNull null]]) {
        cell.nameLabel.text = data[@"photousefor"][@"name"];
    }
    
    if (self.hasExchanged) {
        cell.timeLabel.hidden = YES;
    } else {
        if (![data[@"photousefor"][@"endtime"] isEqual: [NSNull null]]) {
            cell.timeLabel.text = [wTools remainingTimeCalculation: data[@"photousefor"][@"endtime"]];
            cell.timeLabel.textColor = [UIColor firstPink];
        } else {
            cell.timeLabel.text = @"無期限";
            [LabelAttributeStyle changeGapString: cell.timeLabel content: cell.timeLabel.text];
            cell.timeLabel.textColor = [UIColor secondGrey];
        }
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate Methods
- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectItemAtIndexPath");
    
    self.selectedCell = (CheckExchangeCollectionViewCell *)[collectionView cellForItemAtIndexPath: indexPath];

    NSArray *array;
    
    if (self.hasExchanged) {
        array = self.hasExchangedData;
    } else {
        array = self.hasNotExchangedData;
    }

    if ([self.delegate respondsToSelector: @selector(didSelectCell:cell:exchangeDic:hasExchanged:)]) {
        [self.delegate didSelectCell: collectionView
                                cell: self.selectedCell
                         exchangeDic: array[indexPath.row]
                        hasExchanged: self.hasExchanged];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"sizeForItemAtIndexPath");
    
    CGFloat itemWidth = roundf((self.view.frame.size.width - (miniInteriorSpacing * (columnCount + 1))) / columnCount);
    NSLog(@"itemWidth: %f", itemWidth);
    
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
                itemWidth -= 0.5;
                break;
            default:
                printf("unknown");
                break;
        }
    }
    NSLog(@"itemWidth: %f", itemWidth);
    return CGSizeMake(itemWidth, itemWidth + 16);
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
    NSLog(@"insetForSectionAtIndex");
    UIEdgeInsets itemInset = UIEdgeInsetsMake(0, 16, 0, 16);
    return itemInset;
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
{
    CustomIOSAlertView *alertTimeOutView = [[CustomIOSAlertView alloc] init];
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
            if ([protocolName isEqualToString: @"getBookmarkList"]) {
                [weakSelf getBookmarkList];
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

@end
