//
//  PagetextViewController.m
//  wPinpinbox
//
//  Created by Angus on 2015/12/14.
//  Copyright © 2015年 Angus. All rights reserved.
//

#import "PagetextViewController.h"
#import "wTools.h"
//#import "MessageboardViewController.h"
#import "SelectBarViewController.h"
#import "boxAPI.h"
#import "wTools.h"
#import "Remind.h"
#import "Page_mapTableViewCell.h"

#import "CustomIOSAlertView.h"
#import <SafariServices/SafariServices.h>
#import <FBSDKShareKit/FBSDKShareLinkContent.h>
#import <FBSDKShareKit/FBSDKShareDialog.h>
#import "UIColor+Extensions.h"

static NSString *sharingLink = @"http://www.pinpinbox.com/index/album/content/?album_id=%@%@";
static NSString *autoPlayStr = @"&autoplay=1";

@interface PagetextViewController () <SFSafariViewControllerDelegate>
{
    NSMutableArray *dataarr;
    
    BOOL isedit;
    
    int ispage;
    
    NSArray *reportintentlist;
    float lon;
    float lat;
    
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

@implementation PagetextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"PagetextViewController");
    NSLog(@"viewDidLoad");
    NSLog(@"bookdata: %@", _bookdata);
    
    lon =0.0;
    lat =0.0;
    dataarr=[NSMutableArray new];
    
    //
    NSMutableDictionary *dic=nil;
    dic=[NSMutableDictionary new];
    [dic setObject:@"0" forKey:@"type"];
    [dic setObject:_pagedata[@"name"] forKey:@"text"];
    [dataarr addObject:dic];
    
    dic=[NSMutableDictionary new];
    [dic setObject:@"1" forKey:@"type"];
    [dic setObject:_pagedata[@"description"] forKey:@"text"];
    NSLog(@"page data description: %@", _pagedata[@"description"]);
    [dataarr addObject:dic];
    
    dic=[NSMutableDictionary new];
    [dic setObject:@"2" forKey:@"type"];
    [dataarr addObject:dic];
    
    dic=[NSMutableDictionary new];
    [dic setObject:@"0" forKey:@"type"];
    [dic setObject:@"相本介紹" forKey:@"text"];
    [dataarr addObject:dic];
    
    dic=[NSMutableDictionary new];
    [dic setObject:@"1" forKey:@"type"];
    
    /*
    if (_bookdata[@"title"] == NULL) {
        NSLog(@"bookdata album name: %@", _bookdata[@"album"][@"name"]);
        [dic setObject:_bookdata[@"album"][@"name"] forKey:@"text"];
    } else {
        NSLog(@"bookdata title: %@", _bookdata[@"title"]);
        [dic setObject:_bookdata[@"title"] forKey:@"text"];
    }
    */
    
    NSLog(@"before description set up");
    
    if (_fromInfoTxt) {
        [dic setObject: _bookdata[@"description"] forKey: @"text"];
    } else {
        [dic setObject: _bookdata[@"album"][@"description"] forKey: @"text"];
    }
    
    NSLog(@"after description set up");
    
    [dataarr addObject:dic];
    
    dic=[NSMutableDictionary new];
    [dic setObject:@"3" forKey:@"type"];
    
    if (_bookdata[@"author"] == NULL) {
        NSLog(@"bookdata user name: %@", _bookdata[@"user"][@"name"]);
        [dic setObject: _bookdata[@"user"][@"name"] forKey: @"text"];
    } else {
        NSLog(@"bookdata author: %@", _bookdata[@"author"]);
        [dic setObject:_bookdata[@"author"] forKey:@"text"];
    }
    
    [dic setObject:[NSString stringWithFormat:@"建立日期：%@",_bookdata[@"inserttime"]] forKey:@"text2"];
    [dataarr addObject:dic];
    
    dic=[NSMutableDictionary new];
    [dic setObject:@"4" forKey:@"type"];
    [dataarr addObject:dic];
    
    if ([_type isEqualToString:@"0"]) {
        
    }else{
        
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden: YES];
    
    _bookvc.fromPageText = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden: NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)back:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    return dataarr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dic=dataarr[indexPath.row];
    switch ([dic[@"type"] intValue]) {
        case 0://標題
            return 65;
            break;
        case 1://延展文字
        {
            NSString *myString=[NSString stringWithFormat:@"%@",dic[@"text"]];
            
            NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:14]};
            CGSize size = [myString boundingRectWithSize:CGSizeMake(284, MAXFLOAT) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
            
            return size.height+10;
        }
            break;
        case 2://按鈕條
            return 82;
            break;
        case 3://info
            return 89;
            break;
        case 4://地圖
            return 127;
            break;
        default:
            break;
    }
    return 220;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForRowAtIndexPath");
    
    // NSString *identifier = [NSString stringWithFormat:@"HomeTableViewCell_%@", [[[pictures objectAtIndex:indexPath.row] objectForKey:@"album"]objectForKey:@"album_id" ]];
    NSString *CellIdentifier=@"";
    
    NSLog(@"dataarr: %@", dataarr);
    
    NSDictionary *dic = dataarr[indexPath.row];
    
    NSLog(@"dic: %@", dic);
    
    switch ([dic[@"type"] intValue]) {
        case 0://標題
            CellIdentifier=@"Pagetext_titleTableViewCell";
            break;
        case 1://延展文字
            CellIdentifier=@"Page_textTableViewCell";
            break;
        case 2://按鈕條
            CellIdentifier=@"Page_btnTableViewCell";
            break;
        case 3://info
            CellIdentifier=@"Page_infoTableViewCell";
            break;
        case 4://地圖
            CellIdentifier=@"Page_mapTableViewCell";
            break;
        default:
            break;
    }
    
    UITableViewCell *cell=nil;
    cell= [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:CellIdentifier bundle:nil] forCellReuseIdentifier:CellIdentifier];
        cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
       
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.backgroundColor=[UIColor clearColor];
    
    switch ([dic[@"type"] intValue]) {
        case 0://標題
        case 1://延展文字
        {
            UILabel *lab=(UILabel *)[cell viewWithTag:1000];
            lab.text=dic[@"text"];
        }
            break;
        case 2://按鈕條
        {
            if (!isedit ||ispage!=_page) {
                UIScrollView *sc=(UIScrollView *)[cell viewWithTag:1000];
                for (UIView *v in [sc subviews]) {
                    [v removeFromSuperview];
                }
                isedit=YES;
                
                float size=60;
                //三顆按鈕
                UIButton *btn1=[wTools W_Button:self frame:CGRectMake(10, 0, size, size) imgname:@"3-11abutton_voice_click.png" SELL:@selector(btn1:) tag:0];
                [btn1 setImage:[UIImage imageNamed:@"3-11abutton_voice.png"] forState:UIControlStateSelected];
                [sc addSubview:btn1];
                
                if (!_isplay) {
                    btn1.selected=YES;
                }
                
                
//                UIButton *btn2=[wTools W_Button:self frame:CGRectMake(10+(size+5), 0, size, size) imgname:@"3-11abutton_message.png" SELL:@selector(btn2:) tag:0];
//                [btn2 setImage:[UIImage imageNamed:@"3-11abutton_message_click.png"] forState:UIControlStateHighlighted];
//                [sc addSubview:btn2];
                
                UIButton *btn3=[wTools W_Button:self frame:CGRectMake(10+(size+5), 0, size, size) imgname:@"3-11abutton_share.png" SELL:@selector(btn3:) tag:0];
                [btn3 setImage:[UIImage imageNamed:@"3-11abutton_share_click.png"] forState:UIControlStateHighlighted];
                [sc addSubview:btn3];
                
                //新增按鈕
                NSArray *btnarr=_pagedata[@"hyperlink"];
                
                NSLog(@"btnArr: %@", btnarr);
                                
                if (![btnarr isKindOfClass:[NSNull class]]) {
                    for (int i = 0; i < [btnarr count]; i++) {
                        UIButton *btn = [wTools W_Button: self frame: CGRectMake(10 + (size + 5) * (i + 2), 0, size, size) imgname: @"" SELL: @selector(btnadd:) tag:i];
                        
                        NSString *url = btnarr[i][@"url"];
                        NSLog(@"url: %@", url);
                        
                        if (![url isEqualToString: @""]) {
                            NSLog(@"url is not empty");
                            
                            NSString *infoPath = [_file stringByAppendingPathComponent:btnarr[i][@"icon"]];
                            //UIImage *image = [UIImage imageWithContentsOfFile: infoPath];
                            NSLog(@"infoPath: %@", infoPath);
                            NSString *subString = [[infoPath componentsSeparatedByString: @"/"] lastObject];
                            NSLog(@"subString: %@", subString);
                            UIImage *image = [UIImage imageNamed: @"hyperlink"];
                            [btn setImage: image forState: UIControlStateNormal];
                            [sc addSubview: btn];
                        }
                    }
                    
                    sc.contentSize=CGSizeMake(10 + (size + 5) * (3 + btnarr.count), 0);
                }else{
                    sc.contentSize=CGSizeMake(10 + (size + 5) * (3), 0);
                }
            }
        }
            break;
        case 3://info
        {
            UILabel *lab=(UILabel *)[cell viewWithTag:1000];

            lab.text=dic[@"text"];
            lab=(UILabel *)[cell viewWithTag:1001];
            lab.text=dic[@"text2"];
            
            UIButton *btn=(UIButton *)[cell viewWithTag:1002];
            [btn addTarget:self action:@selector(insertreport:) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
        case 4://地圖
        {
            Page_mapTableViewCell *mapcell=(Page_mapTableViewCell*)cell;
            if (_localdata) {
                if (_localdata[@"results"]) {
                    NSArray *result=_localdata[@"results"];
                    if (result.count>0) {
                        NSDictionary *dic=result[0];
                        NSDictionary *location=dic[@"geometry"][@"location"];
                        lat=[location[@"lat"] floatValue];
                        lon=[location[@"lng"] floatValue];
                        [mapcell showloc:lat :lon];
                    }
                }
            }
        }
            break;
        default:
            break;
    }
    
    return cell;
}

-(void)btn1:(UIButton *)sender{
    //聲音
    if (sender.selected) {
        NSLog(@"sender is selected");
        _bookvc.audioSwitch = YES;
    } else {
        NSLog(@"sender is not selected");
        _bookvc.audioSwitch = NO;
    }
    [_bookvc playbool: nil];
    
    sender.selected = !sender.selected;    
}

//-(void)btn2:(id)sender{
//    MessageboardViewController *messagev=[[MessageboardViewController alloc]initWithNibName:@"MessageboardViewController" bundle:nil];
//    messagev.title=@"留言板";
//    messagev.alid=_bookdata[@"albumid"];
//    [self.navigationController pushViewController:messagev animated:YES];
//}

-(void)btn3:(id)sender{
//    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:[NSArray arrayWithObjects:@"內容", nil] applicationActivities:nil];
//    [self presentViewController:activityVC animated:YES completion:nil];
    
    //[wTools Activitymessage:[NSString stringWithFormat:@"%@ http://www.pinpinbox.com/index/album/content/?album_id=%@",_bookdata[@"title"],[_bookdata[@"albumid"] stringValue]]];
    
    /*
    NSString *msg = [NSString stringWithFormat:@"%@ http://www.pinpinbox.com/index/album/content/?album_id=%@",_bookdata[@"title"],[_bookdata[@"albumid"] stringValue]];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems: [NSArray arrayWithObjects: msg, nil] applicationActivities: nil];
    [self presentViewController: activityVC animated: YES completion: nil];
     */
    
    [self checkTaskComplete];
}

-(void)btnadd:(UIButton *)sender {
//    NSArray *btnarr=_pagedata[@"hyperlink"];
//    NSString *urlstr=btnarr[sender.tag][@"url"];
//    NSString *title=btnarr[sender.tag][@"text"];
//    
//    MessageboardViewController *messagev=[[MessageboardViewController alloc]initWithNibName:@"MessageboardViewController" bundle:nil];
//    messagev.title=title;
//    messagev.url=urlstr;
//    
//    [self.navigationController pushViewController:messagev animated:YES];
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
                    [wTools Activitymessage:[NSString stringWithFormat: sharingLink , _albumId, autoPlayStr]];
                    
                } else if ([data[@"result"] intValue] == 2) {
                    // Task is not completed, so pop ups alert view
                    [self showSharingAlertView];
                    
                } else if ([data[@"result"] intValue] == 0) {
                    NSString *errorMessage = data[@"message"];
                    NSLog(@"errorMessage: %@", errorMessage);
                } else {
                    [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
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
    [alertViewForSharing setButtonTitles: [NSMutableArray arrayWithObject: @"確     認"]];
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
    
    // 2sndUIButton View
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
    [alertViewForSharing close];
    
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString: [NSString stringWithFormat: sharingLink, _albumId, autoPlayStr]];
    [FBSDKShareDialog showFromViewController: self
                                 withContent: content
                                    delegate: self];
}

- (void)normalSharing
{
    [alertViewForSharing close];
    
    [wTools Activitymessage:[NSString stringWithFormat: sharingLink, _albumId, autoPlayStr]];
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
        
        NSString *response = [boxAPI doTask2: [wTools getUserID] token: [wTools getUserToken] task_for: albumType platform: @"apple" type: @"album" type_id: _albumId];
        
        NSLog(@"User ID: %@", [wTools getUserID]);
        NSLog(@"Token: %@", [wTools getUserToken]);
        NSLog(@"Task_For: %@", albumType);
        NSLog(@"Album ID: %@", _albumId);
        
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
                } else {
                    [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];                
                }
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
    
    // Activity Button
    UIButton *activityButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [activityButton addTarget: self action: @selector(showTheActivityPage) forControlEvents: UIControlEventTouchUpInside];
    activityButton.frame = CGRectMake(150, 220, 100, 10);
    [activityButton setTitle: @"活動連結" forState: UIControlStateNormal];
    [activityButton setTitleColor: [UIColor colorWithRed: 26.0/255.0 green: 196.0/255.0 blue: 199.0/255.0 alpha: 1.0]
                         forState: UIControlStateNormal];
    [pointView addSubview: activityButton];
    
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
    safariVC.delegate = self;
    safariVC.preferredBarTintColor = [UIColor whiteColor];
    [self presentViewController: safariVC animated: YES completion: nil];
}

#pragma mark - SFSafariViewController delegate methods
- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller
{
    // Done button pressed
    
    NSLog(@"show");
    [alertView show];
}

#pragma mark -

//檢舉
-(IBAction)insertreport:(id)sender{
    
    [wTools ShowMBProgressHUD];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString * Pointstr=[boxAPI getreportintentlist:[wTools getUserID] token:[wTools getUserToken]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[Pointstr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            
            reportintentlist=dic[@"data"];
            SelectBarViewController *mv=[[SelectBarViewController alloc]initWithNibName:@"SelectBarViewController" bundle:nil];
            
            NSMutableArray *strarr=[NSMutableArray new];
            for (int i =0; i<reportintentlist.count; i++) {
                [strarr addObject:reportintentlist[i][@"name"]];
            }
            mv.data=strarr;
            mv.delegate=self;
            mv.topViewController=self;
            [self wpresentPopupViewController:mv animated:YES completion:nil];
        });
    });
}

-(void)SaveDataRow:(NSInteger)row{
    
    NSString *rid=[reportintentlist[row][@"reportintent_id"] stringValue];
    
    [wTools ShowMBProgressHUD];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString * Pointstr=[boxAPI insertreport:[wTools getUserID] token:[wTools getUserToken] rid:rid type:@"album" typeid:[_bookdata[@"albumid"] stringValue]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[Pointstr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            
            NSString *mesg=@"";
            if ([dic[@"result"]boolValue]) {
                mesg=@"回報成功";
            }else{
                mesg=dic[@"message"];
            }
            
            Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
            [rv addtitletext:mesg];
            [rv addBackTouch];
            [rv showView:self.view];
            
        });
    });
}

#pragma mark - Custom Error Alert Method
- (void)showCustomErrorAlert: (NSString *)msg {
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
