//
//  MemberCenterViewController.m
//  wPinpinbox
//
//  Created by David on 1/8/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "MemberCenterViewController.h"
#import "wTools.h"
#import "boxAPI.h"
#import "Remind.h"

@interface MemberCenterViewController ()
{
    NSDictionary *myData;
}
@end

@implementation MemberCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"viewDidLoad");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"viewWillAppear");
    
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
                    
                    NSString *profilePic = myData[@"profilepic"];
                    
                    if (![profilePic isKindOfClass: [NSNull class]]) {
                        if ([profilePic isEqualToString: @""]) {
                            [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: self.headShotImageView];
                            self.headShotImageView.imageURL = [NSURL URLWithString: profilePic];
                        }
                    } else {
                        NSLog(@"profilePic is null");
                        
                        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: self.headShotImageView];
                        self.headShotImageView.image = [UIImage imageNamed: @"member_back_head.png"];
                    }
                    
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

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cellForRowAtIndexPath");
    NSLog(@"indexPath.row: %ld", (long)indexPath.row);
    
    MemberCenterHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"HeaderCell" forIndexPath: indexPath];
    
    if (myData) {
        NSLog(@"myData: %@", myData);
        
        cell.headShotImageView.image = [UIImage imageNamed: @"user_photo.png"];
        cell.headShotImageView.imageURL = nil;
        
        [[cell.headShotImageView layer] setMasksToBounds: YES];
        [[cell.headShotImageView layer] setCornerRadius: cell.headShotImageView.bounds.size.height / 2];
        
        NSString *profilePic = myData[@"profilepic"];
        
        if (![profilePic isKindOfClass: [NSNull class]]) {
            if (![profilePic isEqualToString: @""]) {
                [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: cell.headShotImageView];
                cell.headShotImageView.imageURL = [NSURL URLWithString: myData[@"profilepic"]];
            }
        } else {
            NSLog(@"profilepic is null");
            
            [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: cell.headShotImageView];
            cell.headShotImageView.image = [UIImage imageNamed: @"member_back_head.png"];
        }
    }
    
    return cell;
}
*/

/*
-(void)reloadpic:(NSString *)urlstr{
    if ([urlstr isEqual:[NSNull null]]) {
        picimageview.image = [UIImage imageNamed: @"member_back_head.png"];
        return;
    }
    
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: picimageview];
    picimageview.imageURL=[NSURL URLWithString:urlstr];
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
