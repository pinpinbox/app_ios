//
//  MyAlbumCollectionViewController.m
//  wPinpinbox
//
//  Created by David on 6/18/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "MyAlbumCollectionViewController.h"
#import "wTools.h"
#import "boxAPI.h"
#import "AsyncImageView.h"
#import "MBProgressHUD.h"
#import "MyAlbumCollectionTableViewCell.h"
#import "MyLinearLayout.h"
#import "CustomIOSAlertView.h"
#import "UIColor+Extensions.h"
#import "GlobalVars.h"
#import "AppDelegate.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIViewController+ErrorAlert.h"
#import "UserInfo.h"

@interface MyAlbumCollectionViewController () <UITableViewDelegate, UITableViewDataSource> {
    BOOL isLoading;
    BOOL isReloading;
    NSInteger nextId;
    
    NSMutableArray *dataArray;
    BOOL isCellSubViewHidden;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation MyAlbumCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"MyAlbumCollectionViewController");
    NSLog(@"viewDidLoad");
    [self initialValueSetup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"MyAlbumCollectionViewController");
    NSLog(@"viewWillAppear");
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialValueSetup {
    isCellSubViewHidden = YES;
    
    nextId = 0;
    isLoading = NO;
    isReloading = NO;
    
    dataArray = [NSMutableArray new];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget: self
                            action: @selector(refresh)
                  forControlEvents: UIControlEventValueChanged];
    [self.tableView addSubview: self.refreshControl];
}

- (void)refresh {
    if (!isReloading) {
        @try {
            [MBProgressHUD showHUDAddedTo: self.view animated: YES];
        } @catch (NSException *exception) {
            // Print exception information
            NSLog( @"NSException caught" );
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
            return;
        }
        isReloading = YES;
        nextId = 0;
        isLoading = NO;
        [self loadData];
    }
}

- (void)loadData {
    if (!isLoading) {
        if (nextId == 0) {
            NSLog(@"nextId is: %ld", (long)nextId);
        }
        isLoading = YES;
        [self getcalbumlist];
    }
}

- (void)getcalbumlist {
    NSString *limit = [NSString stringWithFormat: @"%ld,%d", (long)nextId, 10];
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //NSArray *array = @[@"mine", @"other", @"cooperation"];
        NSString *response = [boxAPI getcalbumlist: [wTools getUserID]
                                             token: [wTools getUserToken]
                                              rank: @"mine"
                                             limit: limit];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [MBProgressHUD hideHUDForView: self.view animated: YES];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog( @"NSException caught" );
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason );
                return;
            }
            if (response != nil) {
                NSLog(@"response: %@", response);
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"MyAlbumCollectionViewController");
                    NSLog(@"getcalbumlist");
                    
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getcalbumlist"
                                         albumId: @""];
                    [wself.refreshControl endRefreshing];
                    wself->isReloading = NO;
                } else {
                    NSLog(@"Get Real Response");NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    [wself processCalbumList:dic];
                }
            } else {
                [wself.refreshControl endRefreshing];
                wself->isReloading = NO;
            }
        });
    });
}

- (void)processCalbumList : (NSDictionary *)dic {
    if ([dic[@"result"] intValue] == 1) {
        NSLog(@"get result from getcalbumlist");
        
        if (nextId == 0) {
            dataArray = [NSMutableArray new];
        }
        int s = 0;
        
        if ([wTools objectExists: dic[@"data"]]) {
            for (NSMutableDictionary *collectDic in [dic objectForKey: @"data"]) {
                s++;
                [dataArray addObject: collectDic];
            }
            nextId = nextId + s;
            
            NSLog(@"dataArray: %@", dataArray);
            NSLog(@"dataArray.count: %lu", (unsigned long)dataArray.count);
            
            [self.refreshControl endRefreshing];
            [self.tableView reloadData];
            
            if (nextId >= 0) {
                isLoading = NO;
            }
            if (s == 0) {
                isLoading = YES;
            }
            isReloading = NO;
        }
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

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    NSLog(@"dataArray.count: %lu", (unsigned long)dataArray.count);
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForRowAtIndexPath");    
    MyAlbumCollectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"cell" forIndexPath: indexPath];
    NSDictionary *dic = [dataArray[indexPath.row] copy];
    NSString *imageUrl = dic[@"album"][@"cover"];
    NSString *name = dic[@"album"][@"name"];
    NSString *time = dic[@"album"][@"insertdate"];
    NSInteger cooperationStatistics = [dic[@"cooperationstatistics"][@"count"] integerValue];
    NSLog(@"cooperationStatistics: %ld", (long)cooperationStatistics);
    
    if (![imageUrl isKindOfClass: [NSNull class]]) {
        if (![imageUrl isEqualToString: @""]) {
            [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: cell.albumImageView];
            //cell.albumImageView.imageURL = [NSURL URLWithString: imageUrl];
            [cell.albumImageView sd_setImageWithURL: [NSURL URLWithString: imageUrl]];
        }
    } else {
        NSLog(@"imageUrl is nil");
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: cell.albumImageView];
        cell.albumImageView.image = [UIImage imageNamed: @"bg200_no_image.jpg"];
    }
    
    if (![time isEqual: [NSNull null]]) {
        cell.timeLabel.text = time;
    }
    if (![name isEqual: [NSNull null]]) {
        cell.albumNameLabel.text = name;
    }
    
    if (cooperationStatistics == 0) {
        NSLog(@"cooperationStatistics == 0");
        cell.cooperativeImageView.hidden = YES;
        cell.cooperativeNumberLabel.hidden = YES;
        cell.cooperativeNumberLabel.text = [NSString stringWithFormat: @"%ld", (long)cooperationStatistics];
    } else {
        NSLog(@"cooperationStatistics != 0");
        cell.cooperativeImageView.hidden = NO;
        cell.cooperativeNumberLabel.hidden = NO;
        cell.cooperativeNumberLabel.text = [NSString stringWithFormat: @"%ld", (long)cooperationStatistics];
    }
    
    cell.userId = dic[@"album"][@"album_id"];
    cell.albumId = dic[@"user"][@"user_id"];
    __block typeof(self) wself = self;
    cell.customBlock = ^(BOOL select, NSString *userId, NSString *albumId) {
        NSLog(@"select: %d", select);
        NSLog(@"userId: %@", userId);
        NSLog(@"albumId: %@", albumId);
        wself->isCellSubViewHidden = !(wself->isCellSubViewHidden);
        [wself.tableView reloadData];
    };
    cell.cellSubView.hidden = isCellSubViewHidden;
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath");
    NSDictionary *dic = [dataArray[indexPath.row] copy];
    
    if ([self.delegate respondsToSelector: @selector(toReadBookController:)]) {
        NSLog(@"self.delegate respondsToSelector toReadBookController");
        if ([wTools objectExists: dic[@"album"][@"album_id"]]) {
            [self.delegate toReadBookController: [dic[@"album"][@"album_id"] stringValue]];
        }
    }
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"willDisplayCell");
    
    if (indexPath.item == (dataArray.count - 1)) {
        [self loadData];
    }
}

#pragma mark - Custom Alert Method
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
    //[alertTimeOutView setContainerView: [self createTimeOutContainerView: msg]];
    [alertTimeOutView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertTimeOutView.arrangeStyle = @"Horizontal";
    
    alertTimeOutView.parentView = self.view;
    [alertTimeOutView setButtonTitles: [NSMutableArray arrayWithObjects: NSLocalizedString(@"TimeOut-CancelBtnTitle", @""), NSLocalizedString(@"TimeOut-OKBtnTitle", @""), nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertTimeOutView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor whiteColor],nil]];
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
            if ([protocolName isEqualToString: @"getcalbumlist"]) {
                [weakSelf getcalbumlist];
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
    
    //NSLog(@"");
    NSLog(@"contentView: %@", NSStringFromCGRect(contentView.frame));
    //NSLog(@"");
    
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
