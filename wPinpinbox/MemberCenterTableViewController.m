//
//  MemberCenterTableViewController.m
//  wPinpinbox
//
//  Created by David on 1/9/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "MemberCenterTableViewController.h"
#import "wTools.h"
#import "boxAPI.h"
#import "Remind.h"

#import "RecommendViewController.h"

#define kYAxis 191
#define kGap 9
#define kRowHeight 70

@interface MemberCenterTableViewController ()
{
    NSDictionary *myData;
    
    CGFloat firstRowHeight;
}
@end

@implementation MemberCenterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // NavigationBar Text Setup
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:18 weight:UIFontWeightLight], NSForegroundColorAttributeName: [UIColor whiteColor]};
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"viewWillAppear");
    
    [UIView animateWithDuration: 1.0 animations:^{
        self.view.alpha = 0;
        self.view.alpha = 1;
    }];
    
    [self reloadMyData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@"viewDidAppear");
}

- (void)reloadMyData {
    [wTools ShowMBProgressHUD];
    
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI getprofile: [userPrefs objectForKey: @"id"] token: [userPrefs objectForKey: @"token"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                NSLog(@"dic: %@", dic);
                
                if ([dic[@"result"] intValue] == 1) {
                    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
                    NSMutableDictionary *dataIc = [[NSMutableDictionary alloc] initWithDictionary: dic[@"data"] copyItems: YES];
                    
                    for (NSString *key in [dataIc allKeys]) {
                        id objective = [dataIc objectForKey: key];
                        
                        if ([objective isKindOfClass: [NSNull class]]) {
                            [dataIc setObject: @"" forKey: key];
                        }
                    }
                    
                    [userPrefs setValue: dataIc forKey: @"profile"];
                    [userPrefs synchronize];
                    
                    myData = [dataIc mutableCopy];
                    
                    NSLog(@"myData: %@", myData);
                    
                    // Membmer Data Setting
                    self.nameLabel.text = myData[@"nickname"];
                    
                    NSString *viewNumberStr = [NSString stringWithFormat: @"%@", myData[@"viewed"]];
                    self.viewNumberLabel.text = viewNumberStr;
                    
                    NSString *followedNumberStr = [myData[@"follow"] stringValue];
                    self.followNumberLabel.text = followedNumberStr;
                    
                    NSString *profilePic = myData[@"profilepic"];
                    NSLog(@"profilePic: %@", profilePic);
                    
                    // ImageView Setting
                    [[self.headShotImageView layer] setMasksToBounds: YES];
                    [[self.headShotImageView layer] setCornerRadius: self.headShotImageView.bounds.size.height / 2];
                    
                    self.headShotBgImageView.alpha = 0.2;
                    
                    if (![profilePic isKindOfClass: [NSNull class]]) {
                        NSLog(@"profilePic is not NSNull class");
                        
                        if (![profilePic isEqualToString: @""]) {
                            NSLog(@"profilePic is not equal to string empty");
                            [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: self.headShotImageView];
                            self.headShotImageView.imageURL = [NSURL URLWithString: profilePic];
                            
                            [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: self.headShotBgImageView];
                            self.headShotBgImageView.imageURL = [NSURL URLWithString: profilePic];
                        }
                    } else {
                        NSLog(@"profilePic is null");
                        
                        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: self.headShotImageView];
                        self.headShotImageView.image = [UIImage imageNamed: @"member_back_head.png"];
                        
                        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: self.headShotBgImageView];
                        self.headShotBgImageView.image = [UIImage imageNamed: @"member_back_head.png"];
                    }
                    
                    // TextView Setting
                    self.introTextView.text = myData[@"selfdescription"];
                    
                    CGFloat fixedWidth = self.introTextView.frame.size.width;
                    CGFloat originalHeight = self.introTextView.frame.size.height;
                    
                    NSLog(@"originalHeight: %f", originalHeight);
                    
                    CGSize newSize = [self.introTextView sizeThatFits: CGSizeMake(fixedWidth, MAXFLOAT)];
                    NSLog(@"newSize.height: %f", newSize.height);
                    
                    CGRect newFrame = self.introTextView.frame;
                    newFrame.size = CGSizeMake(fmax(newSize.width, fixedWidth), newSize.height);
                    NSLog(@"newFrame.height: %f", newFrame.size.height);
                    
                    self.introTextView.frame = newFrame;
                    NSLog(@"self.introTextView.frame.size.height: %f", self.introTextView.frame.size.height);
                    
                    self.introTextView.scrollEnabled = NO;
                    
                    firstRowHeight = kYAxis + self.introTextView.frame.size.height + kGap;
                    
                    NSLog(@"firstRowHeight: %f", firstRowHeight);
                    
                    [self.tableView reloadData];
                } else if ([dic[@"result"] intValue] == 0) {
                    Remind *rv = [[Remind alloc] initWithFrame: self.view.bounds];
                    [rv addtitletext: dic[@"message"]];
                    [rv addBackTouch];
                    [rv showView: self.view];
                    
                    NSLog(@"失敗: %@", dic[@"message"]);
                } else {
                    Remind *rv = [[Remind alloc] initWithFrame: self.view.bounds];
                    [rv addtitletext: NSLocalizedString(@"Host-NotAvailable", @"")];
                    [rv addBackTouch];
                    [rv showView: self.view];
                }
            }
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return firstRowHeight;
    } else {
        return kRowHeight;
    }
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString: @"showRecommendViewController"]) {
        RecommendViewController *rv = segue.destinationViewController;
        rv.working = YES;
    }
}

@end
