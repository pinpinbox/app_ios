//
//  NotificationCenterTableViewController.m
//  wPinpinbox
//
//  Created by David on 12/29/16.
//  Copyright © 2016 Angus. All rights reserved.
//

#import "NotificationCenterTableViewController.h"
#import "NotificationCenterTableViewCell.h"
#import "boxAPI.h"
#import "wTools.h"
#import "CreativeViewController.h"
#import "RetrievealbumpViewController.h"
#import "Remind.h"
#import "CustomIOSAlertView.h"
#import "FastViewController.h"
#import "AlbumDetailViewController.h"
#import "AppDelegate.h"

@interface NotificationCenterTableViewController () <UIScrollViewDelegate>
{
    NSMutableArray *notificationData;
    
    BOOL isLoading;
    BOOL isReload;
    NSInteger nextId;
}
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation NotificationCenterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // NavigationBar Text Setup
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:18 weight:UIFontWeightLight], NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    // Loading Data Parameters Setup
    nextId = 0;
    isLoading = NO;
    isReload = NO;
    
    notificationData = [NSMutableArray new];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget: self action: @selector(refresh) forControlEvents: UIControlEventValueChanged];
    [self.tableView addSubview: self.refreshControl];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [wTools HideMBProgressHUD];
    [self loadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [wTools HideMBProgressHUD];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refresh {
    if (!isReload) {
        isReload = YES;
        
        nextId = 0;
        isLoading = NO;
        
        [self loadData];
    }
}

- (void)loadData {
    NSLog(@"loadData");
    
    if (!isLoading) {
        if (nextId == 0) {
            NSLog(@"nextId is: %ld", (long)nextId);
        }
        [wTools ShowMBProgressHUD];
        isLoading = YES;
        NSString *limit = [NSString stringWithFormat: @"%ld,%ld", (long)nextId, 10];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            NSString *response = @"";
            response = [boxAPI getPushQueue: [wTools getUserID] token: [wTools getUserToken] limit: limit];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [wTools HideMBProgressHUD];
                
                if (response != nil) {
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    NSLog(@"dic: %@", dic);
                    
                    if ([dic[@"result"] boolValue]) {
                        
                        if (nextId == 0)
                            [notificationData removeAllObjects];
                        
                        // s for counting how much data is loaded
                        int s = 0;
                        
                        for (NSMutableDictionary *notifData in [dic objectForKey: @"data"]) {
                            s++;
                            [notificationData addObject: notifData];
                        }
                        
                        // If data keeps loading then the nextId is accumulating
                        nextId = nextId + s;
                        NSLog(@"nextId is: %ld", (long)nextId);
                        
                        // If nextId is bigger than 0, that means there are some data loaded already.
                        if (nextId >= 0)
                            isLoading = NO;
                        
                        // If s is 0, that means dic data is empty.
                        if (s == 0) {
                            isLoading = YES;
                        }
                        
                        [self.refreshControl endRefreshing];
                        [self.tableView reloadData];
                        
                        isReload = NO;
                        
                        [wTools HideMBProgressHUD];
                    } else {
                        [self.refreshControl endRefreshing];
                        NSLog(@"失敗: %@", dic[@"message"]);
                    }
                } else {
                    [self.refreshControl endRefreshing];
                }
            });
        });
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"notificationData.count: %lu", (unsigned long)notificationData.count);
    return notificationData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForRowAtIndexPath");
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"Cell" forIndexPath:indexPath];
    
    NotificationCenterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"Cell" forIndexPath: indexPath];
    
    NSLog(@"indexPath.row: %ld", (long)indexPath.row);
    
    NSDictionary *dic = [notificationData[indexPath.row] mutableCopy];
    //NSLog(@"dic: %@", dic);
    
    NSString *imageUrl = dic[@"pushqueue"][@"image_url"];
    NSString *message = dic[@"pushqueue"][@"message"];
    
    //[self timeCompared: dic[@"pushqueue"][@"inserttime"]];
    //NSString *insertTime = dic[@"pushqueue"][@"inserttime"];
    NSString *insertTime = [self hourCalculation: dic[@"pushqueue"][@"inserttime"]];
    
    // Configure the cell...
    // Cell thumbnailImageView Setup
    cell.thumbnailImageView.image = [UIImage imageNamed: @"member_back_head.png"];
    cell.thumbnailImageView.imageURL = nil;
    
    cell.thumbnailImageView.layer.cornerRadius = cell.thumbnailImageView.bounds.size.height / 2;
    cell.thumbnailImageView.clipsToBounds = YES;
    
    if (![imageUrl isKindOfClass: [NSNull class]]) {
        if (![imageUrl isEqualToString: @""]) {
            [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: cell.thumbnailImageView];
            cell.thumbnailImageView.imageURL = [NSURL URLWithString: imageUrl];
        }
    } else {
        NSLog(@"imageURL is nil");
        
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: cell.thumbnailImageView];
        cell.thumbnailImageView.image = [UIImage imageNamed: @"member_back_head.png"];
    }
    
    cell.infoLabel.text = message;
    cell.timeLabel.text = insertTime;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {    
    NSLog(@"didSelectRowAtIndexPath");
    NSLog(@"notificationData: %@", notificationData[indexPath.row]);
    
    NSString *type = notificationData[indexPath.row][@"pushqueue"][@"target2type"];
    NSString *type_id = [notificationData[indexPath.row][@"pushqueue"][@"target2type_id"] stringValue];
    
    if ([type isEqualToString: @"user"]) {
        NSLog(@"type: %@", type);
        CreativeViewController *cvc = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"CreativeViewController"];
        cvc.userid = type_id;
        
        [self.navigationController pushViewController: cvc animated: YES];
    }
    if ([type isEqualToString: @"albumqueue"]) {
        NSLog(@"type: %@", type);
        [self ToRetrievealbumpViewControlleralbumid: type_id];
    }
    if ([type isEqualToString: @"albumqueue@messageboard"]) {
        NSLog(@"type: %@", type);
        AlbumDetailViewController *aDVC = [[UIStoryboard storyboardWithName: @"AlbumDetailVC" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumDetailViewController"];
        aDVC.albumId = type_id;
        aDVC.getMessagePush = YES;
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
    if ([type isEqualToString: @"albumcooperation"]) {
        if ([notificationData[indexPath.row][@"cooperation"] isKindOfClass: [NSNull class]]) {
            NSLog(@"作品已經被移除或是已取消跟作品的共用關係");
            NSString *msg = @"作品已經被移除或是已取消跟作品的共用關係";
            [self showAlertView: msg];
        } else {
            if ([notificationData[indexPath.row][@"cooperation"][@"identity"] isEqualToString: @"viewer"]) {
                NSLog(@"identity is viewer");
                
                NSLog(@"目前權限為瀏覽者，即將前往我的收藏(想做內容編輯可以通知作者更改一下你的權限唷)");
                NSString *msg = @"目前權限為瀏覽者，即將前往我的收藏(想做內容編輯可以通知作者更改一下你的權限唷)";
                [self showAlertView: msg];
            } else {
                FastViewController *fVC = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"FastViewController"];
                fVC.selectrow = [wTools userbook];
                fVC.albumid = type_id;
                
                NSString *templateId = [notificationData[indexPath.row][@"template"][@"template_id"] stringValue];
                
                fVC.templateid = [NSString stringWithFormat: @"%@", templateId];
                
                if ([templateId isEqualToString: @"0"]) {
                    fVC.booktype = 0;
                    fVC.choice = @"Fast";
                } else {
                    fVC.booktype = 1000;
                    fVC.choice = @"Template";
                }
                
                // Data Storing for FastViewController popToHomeViewController Directly
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                BOOL fromHomeVC = NO;
                [defaults setObject: [NSNumber numberWithBool: fromHomeVC]
                             forKey: @"fromHomeVC"];
                [defaults synchronize];
                
                [self.navigationController pushViewController: fVC animated: YES];
            }
        }
    }
    
    [tableView deselectRowAtIndexPath: indexPath animated: YES];
}

#pragma mark - Custom AlertView
- (void)showAlertView: (NSString *)msg
{
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    [alertView setContainerView: [self createView: msg]];
    [alertView setButtonTitles: [NSMutableArray arrayWithObject: @"確     認"]];
    [alertView setUseMotionEffects: true];
    
    [alertView show];
}

- (UIView *)createView: (NSString *)msg
{
    UIView *view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 250, 220)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(50, 0, 150, 150)];
    imageView.image = [UIImage imageNamed: @"dialog_error_dark.png"];
    [view addSubview: imageView];
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame: CGRectMake(20, 150, 210, 50)];
    messageLabel.text = msg;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.numberOfLines = 0;
    //messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    messageLabel.adjustsFontSizeToFitWidth = YES;
    
    [view addSubview: messageLabel];
    
    return view;
}

- (void)ToRetrievealbumpViewControlleralbumid: (NSString *)albumid
{
    [wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *respone=[boxAPI retrievealbump:albumid uid:[wTools getUserID] token:[wTools getUserToken]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [wTools HideMBProgressHUD];
            
            if (respone!=nil)
            {
                NSLog(@"check response");
                NSLog(@"respone: %@", respone);
                
                //NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [respone dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                if ([dic[@"result"]boolValue])
                {
                    NSLog(@"result bool value is YES");
                    NSLog(@"dic: %@", dic);
                    
                    NSLog(@"dic data photo: %@", dic[@"data"][@"photo"]);
                    
                    NSLog(@"dic data user name: %@", dic[@"data"][@"user"][@"name"]);
                    
                    RetrievealbumpViewController *rev = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"RetrievealbumpViewController"];
                    rev.data=[dic[@"data"] mutableCopy];
                    
                    NSLog(@"rev.data: %@", rev.data);
                    
                    rev.albumid=albumid;
                    //[app.myNav pushViewController:rev animated:YES];
                    [self.navigationController pushViewController: rev animated: YES];
                }
                else
                {
                    NSLog(@"失敗：%@",dic[@"message"]);
                    Remind *rv=[[Remind alloc]initWithFrame: self.view.bounds];
                    [rv addtitletext:dic[@"message"]];
                    [rv addBackTouch];
                    [rv showView: self.view];
                }
            }
        });
    });
}

// Time Calculation Function
- (NSString *)hourCalculation: (NSString *)postDate {
    NSLog(@"hourCalculation");
    NSLog(@"postDate: %@", postDate);
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSDate *expDate = [dateFormat dateFromString: postDate];
    NSLog(@"expDate: %@", expDate);
    
    
    NSTimeZone *currentTimeZone = [NSTimeZone localTimeZone];
    NSTimeZone *utcTimeZone = [NSTimeZone timeZoneWithAbbreviation: @"UTC"];
    
    NSInteger currentGMTOffset = [currentTimeZone secondsFromGMTForDate: expDate];
    NSInteger gmtOffset = [utcTimeZone secondsFromGMTForDate: expDate];
    NSTimeInterval gmtInterval = currentGMTOffset - gmtOffset;
    
    NSDate *destinationDate = [[NSDate alloc] initWithTimeInterval: gmtInterval sinceDate: expDate];
    NSLog(@"destinationDate: %@", destinationDate);
    NSDate *currentDate = [[NSDate alloc] initWithTimeInterval: gmtInterval sinceDate: [NSDate date]];
    
    //NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation: @"GMT"];
    //[dateFormat setTimeZone: gmt];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components: (NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond) fromDate: destinationDate toDate: currentDate options: 0];
    NSString *time;
    
    NSLog(@"NSDate date: %@", [NSDate date]);
    NSLog(@"components: %@", components);
    
    if (components.year != 0) {
        if (components.year == 1) {
            time = [NSString stringWithFormat: @"%ld 年", (long)components.year];
        } else {
            time = [NSString stringWithFormat: @"%ld 年", (long)components.year];
        }
    } else if (components.month != 0) {
        if (components.month == 1) {
            time = [NSString stringWithFormat: @"%ld 月", (long)components.month];
        } else {
            time = [NSString stringWithFormat: @"%ld 月", (long)components.month];
        }
    } else if (components.weekday != 0) {
        if (components.weekday == 1) {
            time = [NSString stringWithFormat: @"%ld 週", (long)components.weekday];
        } else {
            time = [NSString stringWithFormat: @"%ld 週", (long)components.weekday];
        }
    } else if (components.day != 0) {
        if (components.day == 1) {
            time = [NSString stringWithFormat: @"%ld 天", (long)components.day];
        } else {
            time = [NSString stringWithFormat: @"%ld 天", (long)components.day];
        }
    } else if (components.hour != 0) {
        if (components.hour == 1) {
            time = [NSString stringWithFormat: @"%ld 小時", (long)components.hour];
        } else {
            time = [NSString stringWithFormat: @"%ld 小時", (long)components.hour];
        }
    } else if (components.minute != 0) {
        if (components.minute == 1) {
            time = [NSString stringWithFormat: @"%ld 分鐘", (long)components.minute];
        } else {
            time = [NSString stringWithFormat: @"%ld 分鐘", (long)components.minute];
        }
    } else if (components.second >= 0) {
        if (components.second == 0) {
            time = [NSString stringWithFormat: @"1 秒"];
        } else {
            time = [NSString stringWithFormat: @"%ld 秒", (long)components.second];
        }
    }
    
    NSLog(@"time: %@", time);
    
    return [NSString stringWithFormat: @"%@前", time];
}

#pragma mark - UIScrollViewDelegate Method
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidScroll");
    
    if (isLoading) {
        return;
    }
    
    if ((scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height * 2)) {
        [self loadData];
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
