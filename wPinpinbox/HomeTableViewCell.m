//
//  HomeTableViewCell.m
//  wPinpinbox
//
//  Created by Angus on 2015/10/22.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "HomeTableViewCell.h"
#import "wTools.h"

#import "AppDelegate.h"
#import "boxAPI.h"
#import "CustomIOSAlertView.h"
#import <SafariServices/SafariServices.h>
#import <FBSDKShareKit/FBSDKShareLinkContent.h>
#import <FBSDKShareKit/FBSDKShareDialog.h>

static NSString *sharingLink = @"http://www.pinpinbox.com/index/album/content/?album_id=%@%@";
static NSString *autoPlayStr = @"&autoplay=1";

@interface HomeTableViewCell () <FBSDKSharingDelegate>
{
    AppDelegate *app;
    
    // For Showing Message of Getting Point
    NSString *missionTopicStr;
    NSString *rewardType;
    NSString *rewardValue;
    NSString *eventUrl;
    
    CustomIOSAlertView *alertView;
    CustomIOSAlertView *alertViewForSharing;
    
    NSString *albumType;
}

@end

@implementation HomeTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [[_v1ForCover layer] setMasksToBounds:YES];
    [[_v2ForPreview1 layer] setMasksToBounds:YES];
    [[_v3ForPreview2 layer] setMasksToBounds:YES];
    [[_v4ForPreview3 layer] setMasksToBounds: YES];
    [[_v1ForOnlyP1 layer] setMasksToBounds: YES];
    
    bgview.backgroundColor=[UIColor whiteColor];
    bgview.layer.cornerRadius=2.5;
  //  bgview.layer.masksToBounds=YES;
    bgview.layer.shadowColor=[UIColor blackColor].CGColor;
    bgview.layer.shadowOffset=CGSizeMake(1.0, 1.0);
    bgview.layer.shadowOpacity=0.5;
    bgview.layer.shadowRadius=5.0;
    bgview.layer.cornerRadius=5.0;
    bgview.layer.borderWidth=1.0;
    bgview.layer.borderColor=[UIColor whiteColor].CGColor;
    
    app = [[UIApplication sharedApplication] delegate];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)albumbtn:(id)sender {
    NSLog(@"album_id: %@", _album_id);
    [wTools ToRetrievealbumpViewControlleralbumid:_album_id];
}

- (IBAction)userbtn:(id)sender {
    //[wTools showCreativeViewuserid:_user_id  isfollow:YES];
    if (_customBlock) {
        _customBlock(_userBtn.selected, _user_id);
    }
}

#pragma mark - Sharing Methods

- (IBAction)sharebtn:(id)sender {
    NSLog(@"Share Button in HomeTableViewCell");
    
    //[wTools Activitymessage:[NSString stringWithFormat:@"%@ http://w3.pinpinbox.com/index/album/content/?album_id=%@",_album_name.text,_album_id]];
    
    /*
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString: [NSString stringWithFormat:@"http://w3.pinpinbox.com/index/album/content/?album_id=%@", _album_id]];
    [FBSDKShareDialog showFromViewController: app.menu
                                 withContent: content
                                    delegate: nil];
     */
    
    [self checkTaskComplete];
}

- (void)checkTaskComplete
{
    NSLog(@"checkTask");
    
    [wTools ShowMBProgressHUD];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *response = [boxAPI checkTaskCompleted: [wTools getUserID] token: [wTools getUserToken] task_for: @"share_to_fb" platform: @"apple"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"%@", response);
                NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                if ([data[@"result"] intValue] == 1) {
                    
                    // Task is completed, so calling the original sharing function
                    [wTools Activitymessage:[NSString stringWithFormat: sharingLink , _album_id, autoPlayStr]];
                    
                } else if ([data[@"result"] intValue] == 2) {
                    
                    // Task is not completed, so pop ups alert view
                    [self showSharingAlertView];
                    
                } else if ([data[@"result"] intValue] == 0) {
                    
                    NSString *errorMessage = data[@"message"];
                    NSLog(@"errorMessage: %@", errorMessage);
                }
            }
        });
    });
}

- (void)showSharingAlertView
{
    NSLog(@"showSharingAlertView");
    
    alertViewForSharing = [[CustomIOSAlertView alloc] init];
    [alertViewForSharing setContainerView: [self createSharingButtonView]];
    [alertViewForSharing setButtonTitles: [NSMutableArray arrayWithObject: @"取     消"]];
    [alertViewForSharing setUseMotionEffects: true];
    
    [alertViewForSharing show];
}

- (UIView *)createSharingButtonView
{
    NSLog(@"createSharingButtonView");
    
    // Parent View
    UIView *sharingButtonView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 250, 220)];
    
    // Topic Label View
    UILabel *topicLabel = [[UILabel alloc] initWithFrame: CGRectMake(25, 25, 200, 10)];
    topicLabel.text = @"選擇分享方式";
    topicLabel.textAlignment = NSTextAlignmentCenter;
    
    // 1st UIButton View
    UIButton *buttonFB = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [buttonFB addTarget: self action: @selector(fbSharing) forControlEvents: UIControlEventTouchUpInside];
    [buttonFB setTitle: @"獎勵分享 (facebook)" forState: UIControlStateNormal];
    buttonFB.frame = CGRectMake(25, 65, 200, 50);
    [buttonFB setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    buttonFB.backgroundColor = [UIColor colorWithRed: 32.0/255.0 green: 191.0/255.0 blue: 193.0/255.0 alpha: 1.0];
    buttonFB.layer.cornerRadius = 10;
    buttonFB.clipsToBounds = YES;
    
    // 2nd UIButton View
    UIButton *buttonNormal = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [buttonNormal addTarget: self action: @selector(normalSharing) forControlEvents: UIControlEventTouchUpInside];
    [buttonNormal setTitle: @" 一 般 分 享 " forState: UIControlStateNormal];
    buttonNormal.frame = CGRectMake(25, 150, 200, 50);
    [buttonNormal setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    buttonNormal.backgroundColor = [UIColor colorWithRed: 32.0/255.0 green: 191.0/255.0 blue: 193.0/255.0 alpha: 1.0];
    buttonNormal.layer.cornerRadius = 10;
    buttonNormal.clipsToBounds = YES;
    
    [sharingButtonView addSubview: topicLabel];
    [sharingButtonView addSubview: buttonFB];
    [sharingButtonView addSubview: buttonNormal];
    
    return sharingButtonView;
}

- (void)fbSharing
{
    NSLog(@"fbSharing");
    
    [alertViewForSharing close];
    
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString: [NSString stringWithFormat: sharingLink, _album_id, autoPlayStr]];
    [FBSDKShareDialog showFromViewController: app.menu
                                 withContent: content
                                    delegate: self];
}

- (void)normalSharing
{
    NSLog(@"normalSharing");
    
    [alertViewForSharing close];
    
    [wTools Activitymessage:[NSString stringWithFormat: sharingLink, _album_id, autoPlayStr]];
}

#pragma mark - FBSDKSharing Delegate Methods

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
    NSLog(@"Sharing Complete");
    
    // Check whether getting Sharing Point or not
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL share_to_fb = [defaults objectForKey: @"share_to_fb"];
    NSLog(@"Check whether getting sharing point or not");
    NSLog(@"share_to_fb: %d", (int)share_to_fb);
    
    if (share_to_fb) {
        NSLog(@"Getting Sharing Point Already");
    } else {
        albumType = @"share_to_fb";
        [self checkPoint];
    }
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    NSLog(@"Sharing didFailWithError");
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    NSLog(@"Sharing Did Cancel");
}


#pragma mark - Check Point Method

- (void)checkPoint
{
    NSLog(@"checkPoint");
    
    //[wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *response = [boxAPI doTask2: [wTools getUserID] token: [wTools getUserToken] task_for: albumType platform: @"apple" type: @"album" type_id: _album_id];
        
        NSLog(@"User ID: %@", [wTools getUserID]);
        NSLog(@"Token: %@", [wTools getUserToken]);
        NSLog(@"Task_For: %@", albumType);
        NSLog(@"Album ID: %@", _album_id);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //[wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"%@", response);
                NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                if ([data[@"result"] intValue] == 1) {
                    
                    missionTopicStr = data[@"data"][@"task"][@"name"];
                    NSLog(@"name: %@", missionTopicStr);
                    
                    rewardType = data[@"data"][@"task"][@"reward"];
                    NSLog(@"reward type: %@", rewardType);
                    
                    rewardValue = data[@"data"][@"task"][@"reward_value"];
                    NSLog(@"reward value: %@", rewardValue);
                    
                    eventUrl = data[@"data"][@"event"][@"url"];
                    NSLog(@"event: %@", eventUrl);
                    
                    [self showAlertView];
                    
                    [self getPointStore];
                    
                } else if ([data[@"result"] intValue] == 2) {
                    NSLog(@"message: %@", data[@"message"]);
                    
                    if ([albumType isEqualToString: @"collect_free_album"]) {
                        // Save data for first collect album
                        BOOL collect_free_album = YES;
                        
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        [defaults setObject: [NSNumber numberWithBool: collect_free_album]
                                     forKey: @"collect_free_album"];
                        [defaults synchronize];
                    }
                    
                    if ([albumType isEqualToString: @"collect_pay_album"]) {
                        // Save data for first collect paid album
                        BOOL collect_pay_album = YES;
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        [defaults setObject: [NSNumber numberWithBool: collect_pay_album]
                                     forKey: @"collect_pay_album"];
                        [defaults synchronize];
                    }
                    
                    if ([albumType isEqualToString: @"share_to_fb"]) {
                        BOOL share_to_fb = YES;
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        [defaults setObject: [NSNumber numberWithBool: share_to_fb]
                                     forKey: @"share_to_fb"];
                        [defaults synchronize];
                    }
                    
                } else if ([data[@"result"] intValue] == 0) {
                    NSString *errorMessage = data[@"message"];
                    NSLog(@"error messsage: %@", errorMessage);
                }
            }
        });
    });
}

- (void)getPointStore
{
    NSLog(@"getPointStore");
    
    //[MBProgressHUD showHUDAddedTo: self.view animated: YES];
    
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *respone=[boxAPI getpointstore:[userPrefs objectForKey:@"id"] token:[userPrefs objectForKey:@"token"]];
        
        NSString *pointstr=[boxAPI geturpoints:[userPrefs objectForKey:@"id"] token:[userPrefs objectForKey:@"token"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[wTools HideMBProgressHUD];
            
            NSLog(@"%@",respone);
            
            if (respone!=nil) {
                NSLog(@"");
                NSLog(@"");
                NSLog(@"response from getPointStore: %@", respone);
                
                NSLog(@"pointstr: %@", pointstr);
                
                NSDictionary *pointdic=(NSDictionary *)[NSJSONSerialization JSONObjectWithData:[pointstr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                NSInteger point = [pointdic[@"data"] integerValue];
                NSLog(@"point: %ld", (long)point);
                
                NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
                [userPrefs setObject: [NSNumber numberWithInteger: point] forKey: @"pPoint"];
                [userPrefs synchronize];
            }
        });
    });
}

#pragma mark - Custom AlertView for Getting Point
- (void)showAlertView
{
    NSLog(@"Show Alert View");
    
    // Custom AlertView shows up when getting the point
    alertView = [[CustomIOSAlertView alloc] init];
    [alertView setContainerView: [self createPointView]];
    [alertView setButtonTitles: [NSMutableArray arrayWithObject: @"確     認"]];
    [alertView setUseMotionEffects: true];
    
    [alertView show];
}

- (UIView *)createPointView
{
    NSLog(@"createPointView");
    
    UIView *pointView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 250, 250)];
    
    // Mission Topic Label
    UILabel *missionTopicLabel = [[UILabel alloc] initWithFrame: CGRectMake(5, 15, 200, 10)];
    //missionTopicLabel.text = @"收藏相本得點";
    missionTopicLabel.text = missionTopicStr;
    
    NSLog(@"Topic Label Text: %@", missionTopicStr);
    [pointView addSubview: missionTopicLabel];
    
    // Gift Image
    UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(50, 40, 150, 150)];
    imageView.image = [UIImage imageNamed: @"icon_present"];
    [pointView addSubview: imageView];
    
    // Message Label
    UILabel *messageLabel = [[UILabel alloc] initWithFrame: CGRectMake(5, 200, 200, 10)];
    
    NSString *congratulate = @"恭喜您獲得 ";
    //NSString *number = @"1 ";
    
    NSLog(@"Reward Value: %@", rewardValue);
    NSString *end = @"P!";
    
    /*
     if ([rewardType isEqualToString: @"point"]) {
     congratulate = @"恭喜您獲得 ";
     number = @"5 ";
     // number = rewardValue;
     end = @"P!";
     }
     */
    
    messageLabel.text = [NSString stringWithFormat: @"%@%@%@", congratulate, rewardValue, end];
    [pointView addSubview: messageLabel];
    
    if ([eventUrl isEqual: [NSNull null]] || eventUrl == nil) {
        NSLog(@"eventUrl is equal to null or eventUrl is nil");
    } else {
        // Activity Button
        UIButton *activityButton = [UIButton buttonWithType: UIButtonTypeCustom];
        [activityButton addTarget: self action: @selector(showTheActivityPage) forControlEvents: UIControlEventTouchUpInside];
        activityButton.frame = CGRectMake(150, 220, 100, 10);
        [activityButton setTitle: @"活動連結" forState: UIControlStateNormal];
        [activityButton setTitleColor: [UIColor colorWithRed: 26.0/255.0 green: 196.0/255.0 blue: 199.0/255.0 alpha: 1.0]
                             forState: UIControlStateNormal];
        [pointView addSubview: activityButton];
    }
    
    return pointView;
}

- (void)showTheActivityPage
{
    NSLog(@"showTheActivityPage");
    
    //NSString *activityLink = @"http://www.apple.com";
    NSString *activityLink = eventUrl;
    
    NSURL *url = [NSURL URLWithString: activityLink];
    
    // Close for present safari view controller, otherwise alertView will hide the background
    [alertView close];
    
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL: url entersReaderIfAvailable: NO];
    safariVC.delegate = app.menu;
    safariVC.preferredBarTintColor = [UIColor whiteColor];
    [app.menu presentViewController: safariVC animated: YES completion: nil];
}

#pragma mark - SFSafariViewController delegate methods
- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller
{
    // Done button pressed
    
    NSLog(@"show");
    [alertView show];
}

#pragma mark -

-(IBAction)message:(id)sender{
    [wTools messageboard:_album_id];
}

@end
