//
//  RecentBrowsingViewController.m
//  wPinpinbox
//
//  Created by David on 5/23/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "RecentBrowsingViewController.h"
#import "UIColor+Extensions.h"
#import "RecentBrowsingTableViewCell.h"
#import <CoreData/CoreData.h>
#import "wTools.h"
#import "AppDelegate.h"
#import "boxAPI.h"
#import "CustomIOSAlertView.h"
#import "ContentCheckingViewController.h"
#import "GlobalVars.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIViewController+ErrorAlert.h"
#import "LabelAttributeStyle.h"

@interface RecentBrowsingViewController () <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarHeight;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong) NSMutableArray *browseArray;
@end

@implementation RecentBrowsingViewController

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    
    if ([delegate performSelector: @selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.delegate = self;
    [self initialValueSetup];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"");
    NSLog(@"RecentBrowsingViewController viewWillAppear");
    [super viewWillAppear:animated];
    
    [wTools setStatusBarBackgroundColor: [UIColor whiteColor]];
    
    for (UIView *v in self.tabBarController.view.subviews) {
        UIButton *btn = (UIButton *)[v viewWithTag: 104];
        btn.hidden = YES;
    }
    [self retrieveData];
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

#pragma mark - IBAction Methods
- (void)initialValueSetup {
    self.navBarView.backgroundColor = [UIColor barColor];
    self.tableView.showsVerticalScrollIndicator = NO;
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

- (void)retrieveData {
    NSLog(@"retrieveData");
    // Fetch the data from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName: @"Browse"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey: @"browseDate" ascending: NO];
    [fetchRequest setSortDescriptors: @[sortDescriptor]];
    self.browseArray = [[managedObjectContext executeFetchRequest: fetchRequest error: nil] mutableCopy];
    NSLog(@"self.browseArray.count: %lu", (unsigned long)self.browseArray.count);
    
    if ([wTools objectExists: self.browseArray]) {
        for (int i = 0; i < self.browseArray.count; i++) {
            NSManagedObject *browseData = [self.browseArray objectAtIndex: i];
            NSLog(@"%d data", i + 1);
            NSLog(@"albumId: %@", [NSString stringWithFormat: @"%@", [browseData valueForKey: @"albumId"]]);
            NSLog(@"author: %@", [NSString stringWithFormat: @"%@", [browseData valueForKey: @"author"]]);
            NSLog(@"descriptionInfo: %@", [NSString stringWithFormat: @"%@", [browseData valueForKey: @"descriptionInfo"]]);
            NSLog(@"imageFolderName: %@", [NSString stringWithFormat: @"%@", [browseData valueForKey: @"imageFolderName"]]);
            NSLog(@"title: %@", [NSString stringWithFormat: @"%@", [browseData valueForKey: @"title"]]);
            NSLog(@"browseDate: %@", [NSString stringWithFormat: @"%@", [browseData valueForKey: @"browseDate"]]);
            NSLog(@"imageUrlThumbnail: %@", [NSString stringWithFormat: @"%@", [browseData valueForKey: @"imageUrlThumbnail"]]);
        }
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    //[self.navigationController popViewControllerAnimated: YES];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav popViewControllerAnimated: YES];
}

#pragma mark - UITableViewDatasource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"self.browseArray.count: %lu", (unsigned long)self.browseArray.count);
    return self.browseArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForRowAtIndexPath");
    RecentBrowsingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"Cell" forIndexPath: indexPath];
    
    // Configure the cell...
    NSManagedObject *browseData = [self.browseArray objectAtIndex: indexPath.row];
    NSString *imageUrlThumbnail = [browseData valueForKey: @"imageUrlThumbnail"];
    cell.albumImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    if (![imageUrlThumbnail isKindOfClass: [NSNull class]]) {
        if (![imageUrlThumbnail isEqualToString: @""]) {
            //cell.albumImageView.imageURL = [NSURL URLWithString: imageUrlThumbnail];
            //[cell.albumImageView sd_setImageWithURL: [NSURL URLWithString: imageUrlThumbnail]];
            cell.albumImageView.contentMode = UIViewContentModeScaleAspectFill;
            [cell.albumImageView sd_setImageWithURL:[NSURL URLWithString: imageUrlThumbnail] placeholderImage:[UIImage imageNamed:@"bg200_no_image.jpg"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                if (error) {
                    cell.albumImageView.image = [UIImage imageNamed: @"bg_2_0_0_no_image"] ;
                } else
                    cell.albumImageView.image = image;
                
            }];
        } else {
            NSLog(@"imageUrlThumbnail: %@", imageUrlThumbnail);
            cell.albumImageView.image = [UIImage imageNamed: @"origin.jpg"];
        }
    } else {
        NSLog(@"imageUrlThumbnail is nil");
        cell.albumImageView.image = [UIImage imageNamed: @"origin.jpg"];
    }
    
    //cell.albumImageView.image = [UIImage imageNamed: @"05"];
    //cell.albumNameLabel.text = @"album";
    
    NSLog(@"browseData: %@", browseData);
    
    if (![[browseData valueForKey: @"title"] isEqual: [NSNull null]]) {
        cell.albumNameLabel.text = [browseData valueForKey: @"title"];
        [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: cell.albumNameLabel content: cell.albumNameLabel.text];
    }
    //cell.creatorNameLabel.text = @"creator";
    if (![[browseData valueForKey: @"author"] isEqual: [NSNull null]]) {
        cell.creatorNameLabel.text = [browseData valueForKey: @"author"];
        [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: cell.creatorNameLabel content: cell.creatorNameLabel.text];
    }        
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath");
    NSManagedObject *browseData = [self.browseArray objectAtIndex: indexPath.row];
    
    NSLog(@"browseData: %@", browseData);
    
    [self ToRetrievealbumpViewControlleralbumid: [browseData valueForKey: @"albumId"]];
}

- (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, tableView.bounds.size.width, 90)];
    
    UILabel *sectionHeaderTitle = [[UILabel alloc] initWithFrame: CGRectMake(16, 64, 200, 58)];
    sectionHeaderTitle.text = @"最近瀏覽";
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: sectionHeaderTitle content: sectionHeaderTitle.text];
    sectionHeaderTitle.font = [UIFont boldSystemFontOfSize: 48];
    sectionHeaderTitle.textColor = [UIColor firstGrey];
    sectionHeaderTitle.backgroundColor = [UIColor clearColor];
    [headerView addSubview: sectionHeaderTitle];
    self.tableView.tableHeaderView = headerView;
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section {
    CGFloat height;
    /*
    if (notificationData.count == 0) {
        height = 0;
    } else {
        height = 32;
    }
    */
    height = 58;
    
    return height;
}

#pragma mark - Call Protocol
- (void)ToRetrievealbumpViewControlleralbumid:(NSString *)albumid {
    NSLog(@"ToRetrievealbumpViewControlleralbumid");
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
        NSString *response = [boxAPI retrievealbump: albumid
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
            if (response != nil) {
                NSLog(@"response from retrievealbump");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"RecentBrowsingViewController");
                    NSLog(@"ToRetrievealbumpViewControlleralbumid");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"retrievealbump"
                                         albumId: albumid];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        NSLog(@"result bool value is YES");
                        NSLog(@"dic data photo: %@", dic[@"data"][@"photo"]);
                        NSLog(@"dic data user name: %@", dic[@"data"][@"user"][@"name"]);
                        
                        if ([wTools objectExists: albumid]) {
                            ContentCheckingViewController *contentCheckingVC = [[UIStoryboard storyboardWithName: @"ContentCheckingVC" bundle: nil] instantiateViewControllerWithIdentifier: @"ContentCheckingViewController"];
                            contentCheckingVC.albumId = albumid;
                            
                            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                            [appDelegate.myNav pushViewController: contentCheckingVC animated: YES];
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
            }
        });
    });
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
            if ([protocolName isEqualToString: @"retrievealbump"]) {
                [weakSelf ToRetrievealbumpViewControlleralbumid: albumId];
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
