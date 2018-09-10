//
//  TaobanViewController.m
//  wPinpinbox
//
//  Created by Angus on 2015/12/30.
//  Copyright © 2015年 Angus. All rights reserved.
//

#import "TaobanViewController.h"
#import "Taoban1TableViewCell.h"
#import "TaobantextTableViewCell.h"
#import "TaobannameTableViewCell.h"
#import "Taoban3TableViewCell.h"
#import "wTools.h"
#import "boxAPI.h"
#import "AsyncImageView.h"
#import "WdataButton.h"
#import "Remind.h"
#import "TemplateViewController.h"
#import "UIViewController+CWPopup.h"
#import "SelectBarViewController.h"

#import "CustomIOSAlertView.h"
#import <SafariServices/SafariServices.h>

#import "UIColor+Extensions.h"
#import "UIViewController+ErrorAlert.h"

@interface TaobanViewController () <SFSafariViewControllerDelegate, SelectBarDelegate>
{
    NSDictionary *apidata;
    __weak IBOutlet UILabel *mytitle;
    __weak IBOutlet UITableView *mytable;
    NSArray *reportintentlist;
    
    // For Showing Message of Getting Point
    NSString *missionTopicStr;
    NSString *rewardType;
    NSString *rewardValue;
    NSString *eventUrl;
    
    CustomIOSAlertView *alertView;
}
@end

@implementation TaobanViewController

-(IBAction)buy:(id)sender {
    NSLog(@"buy");
    BOOL own=[apidata[@"template"][@"own"] boolValue];
    
    if (own) {
        //已購買
        [self editTaoban];
    }else{
        //未購買
        if ([apidata[@"template"][@"point"]intValue]==0) {
            //購買流程
            [self buyapi];
            return;
        }
        [wTools ShowMBProgressHUD];
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            NSString * Pointstr=[boxAPI geturpoints:[wTools getUserID] token:[wTools getUserToken]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [wTools HideMBProgressHUD];
                
                NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[Pointstr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
               
                    //是否足夠
                    if ([apidata[@"template"][@"point"]intValue]>[dic[@"data"] intValue]) {
                        Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
                        [rv addtitletext:NSLocalizedString(@"CreateAlbumText-askP", @"")];
                        [rv addSelectBtntext:NSLocalizedString(@"GeneralText-yes", @"") btn2:NSLocalizedString(@"GeneralText-no", @"") ];
                        [rv showView:self.view];
                        
                        rv.btn1select=^(BOOL bo){
                            if (bo) {
//                                CurrencyViewController *cvc=[[UIStoryboard storyboardWithName:@"Home" bundle:nil]instantiateViewControllerWithIdentifier:@"CurrencyViewController"];
//                                
//                                [self.navigationController pushViewController:cvc animated:YES];
                            }
                        };
                        
                    }else{
                        //可以購買
                        Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
                        [rv addtitletext:[NSString stringWithFormat:@"%@(%d P)",NSLocalizedString(@"CreateAlbumText-askPay", @""),[apidata[@"template"][@"point"] intValue]]];
                        [rv addSelectBtntext:NSLocalizedString(@"GeneralText-yes", @"") btn2:NSLocalizedString(@"GeneralText-no", @"") ];
                        [rv showView:self.view];
                        
                        rv.btn1select=^(BOOL bo){
                            if (bo) {
                               //購買流程
                                [self buyapi];
                            }
                        };
                    }
            });
        });
    }
}

-(void)buyapi{
    
    [wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString * Pointstr=[boxAPI buytemplate:[wTools getUserID] token:[wTools getUserToken] templateid:_temolateid];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [wTools HideMBProgressHUD];
            
            NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[Pointstr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            
            if ([dic[@"result"] intValue] == 1) {
                //開始製作
                [self editTaoban];
            } else if ([dic[@"result"] intValue] == 0) {
                NSLog(@"失敗：%@",dic[@"message"]);
                [self showCustomErrorAlert: dic[@"message"]];
            } else {
                [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
            }
        });
    });
}


//進入編輯
-(void)editTaoban{
    //判斷是否有編輯中相本
    
    //判斷是否有編輯中相本
    
    [wTools ShowMBProgressHUD];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *respone=[boxAPI checkalbumofdiy:[wTools getUserID] token:[wTools getUserToken]];
        [wTools HideMBProgressHUD];
        
        if (respone!=nil) {
            NSLog(@"%@",respone);
            NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            
            if ([dic[@"result"] intValue] == 1) {
                [boxAPI updatealbumofdiy:[wTools getUserID] token:[wTools getUserToken] album_id:[dic[@"data"][@"album"][@"album_id"] stringValue]];
            } else if ([dic[@"result"] intValue] == 0) {
                NSLog(@"失敗：%@",dic[@"message"]);
                [self showCustomErrorAlert: dic[@"message"]];
            } else {
                [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            [self addNewTaobanMod];
        });
    });
}

//套版
-(void)addNewTaobanMod{
    
    NSLog(@"addNewTaobanMod");
    
    //新增相本id
    
    [wTools ShowMBProgressHUD];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *respone=[boxAPI insertalbumofdiy:[wTools getUserID] token:[wTools getUserToken] template_id:_temolateid];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [wTools HideMBProgressHUD];
            
            if (respone!=nil) {
                NSLog(@"%@",respone);
                NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                if ([dic[@"result"] intValue] == 1) {
                    NSString * tempalbum_id=[dic[@"data"] stringValue];
                    
                    TemplateViewController *tvc=[[UIStoryboard storyboardWithName:@"Fast" bundle:nil]instantiateViewControllerWithIdentifier:@"TemplateViewController"];
                    tvc.albumid=tempalbum_id;
                    tvc.event_id = _event_id;
                    tvc.postMode = _postMode;
                    NSLog(@"postMode: %d", _postMode);
                    
//                    FastViewController *fVC = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"FastViewController"];
//                    fVC.selectrow = [wTools userbook];
//                    fVC.albumid = tempalbum_id;
//                    fVC.event_id = _event_id;
//                    fVC.postMode = _postMode;
//                    fVC.choice = @"Template";
//                    fVC.navigationItem.title = @"版 型 建 立";
//                    fVC.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:18 weight:UIFontWeightLight], NSForegroundColorAttributeName: [UIColor whiteColor]};
//
//                    [self.navigationController pushViewController: fVC animated: YES];
                    
                    
                    // Check whether getting Download Template point or not
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    BOOL firsttime_download_template = [[defaults objectForKey: @"firsttime_download_template"] boolValue];
                    NSLog(@"Check whether getting Download Template point or not");
                    NSLog(@"firsttime_download_template: %d", (int)firsttime_download_template);
                    
                    if (firsttime_download_template) {
                        NSLog(@"Get the First Time Download Template Point Already");
                    } else {
                        [self checkPoint];
                    }
                    
                    // Save data for first edit profile
                    firsttime_download_template = YES;
                    [defaults setObject: [NSNumber numberWithBool: firsttime_download_template]
                                 forKey: @"firsttime_download_template"];
                    [defaults synchronize];
                    
                } else if ([dic[@"result"] intValue] == 0) {
                    NSLog(@"失敗：%@",dic[@"message"]);
                    [self showCustomErrorAlert: dic[@"message"]];
                } else {
                    [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                }
            }
        });
    });
}

#pragma mark - Check Point Method

- (void)checkPoint
{
    NSLog(@"checkPoint");
    
    //[wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                
        NSString *response = [boxAPI doTask2: [wTools getUserID] token: [wTools getUserToken] task_for: @"firsttime_download_template" platform: @"apple" type: @"template" type_id: _temolateid];
        
        NSLog(@"User ID: %@", [wTools getUserID]);
        NSLog(@"Token: %@", [wTools getUserToken]);
        NSLog(@"Template ID: %@", _temolateid);
        
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
                    
                    // Save setting for login successfully
                    BOOL firsttime_download_template = YES;
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject: [NSNumber numberWithBool: firsttime_download_template] forKey: @"firsttime_download_template"];
                    [defaults synchronize];
                    
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
    UIView *pointView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 250, 250)];
    
    // Mission Topic Label
    UILabel *missionTopicLabel = [[UILabel alloc] initWithFrame: CGRectMake(5, 15, 200, 10)];
    //missionTopicLabel.text = @"修改資料得點";
    missionTopicLabel.text = missionTopicStr;
    [pointView addSubview: missionTopicLabel];
    
    // Gift Image
    UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(50, 40, 150, 150)];
    imageView.image = [UIImage imageNamed: @"icon_present"];
    [pointView addSubview: imageView];
    
    // Message Label
    UILabel *messageLabel = [[UILabel alloc] initWithFrame: CGRectMake(5, 200, 200, 10)];
    
    NSString *congratulate = @"恭喜您獲得 ";
    //NSString *number = rewardValue;
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

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    
    NSLog(@"TaobanViewController");
    NSLog(@"viewDidLoad");
    
    [super viewDidLoad];        
    
    //self.navigationController.navigationBarHidden = YES;
    
    //mytitle.text=NSLocalizedString(@"CreateAlbumText-create", @"");
    //mytitle.text = @"版 型 介 紹";
    
    self.navigationItem.title = @"版 型 介 紹";
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:18 weight:UIFontWeightLight], NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    [wTools ShowMBProgressHUD];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSLog(@"calling getTemplate protocol");
        
        NSString *respone=[boxAPI gettemplate:[wTools getUserID] token:[wTools getUserToken] templateid:_temolateid];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (respone != nil) {
                
                NSLog(@"");
                NSLog(@"response from getTemplate Protocol");
                NSLog(@"%@", respone);
                NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                if ([dic[@"result"]boolValue]) {
                    apidata=[dic[@"data"] mutableCopy];
                    
                    NSLog(@"apidata: %@", apidata);
                    
                    [mytable reloadData];
                }else{
                    NSLog(@"失敗：%@",dic[@"message"]);
                    Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
                    [rv addtitletext:dic[@"message"]];
                    [rv addBackTouch];
                    [rv showView:self.view];
                }
            }
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // Set up for back to the previous one for disable swipe gesture
    // Because the home view controller can not swipe back to Main Screen
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"numberOfSectionsInTableView");
    
    //說明
    //文字
    //作者
    //作者其他版型
    //版型製作範例
    if (apidata==nil) {
        return 0;
    }
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"numberOfRowsInSection");
    // Return the number of rows in the section.
   
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.section) {
        case 0:
            return 173;
            break;
        case 1:
            
        {
            //16
            
            NSString *text=apidata[@"template"][@"description"];
            NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:13]};
            CGSize size = [text boundingRectWithSize:CGSizeMake(304, MAXFLOAT) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
            
            return size.height;
        }
            break;
        case 2:
            return 20;
            break;
        case 3:
        {
            
        }
        case 4:
            return 216;
            break;
        default:
            break;
    }
    
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForRowAtIndexPath");
    
    UITableViewCell *cell = nil;
    NSString * str=@"";
    
    switch (indexPath.section) {
        case 0:
            str=@"Taoban1TableViewCell";
            break;
        case 1:
            str=@"TaobantextTableViewCell";
            break;
        case 2:
            str=@"TaobannameTableViewCell";
            break;
        case 3:
        case 4:
            str=@"Taoban3TableViewCell";
            break;
        default:
            break;
    }
    /*
     #import "Taoban1TableViewCell.h"
     #import "TaobantextTableViewCell.h"
     #import "TaobannameTableViewCell.h"
     #import "Taoban3TableViewCell.h"
     
     */
    cell= [tableView dequeueReusableCellWithIdentifier:str];
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:str bundle:nil] forCellReuseIdentifier:str];
        cell=[tableView dequeueReusableCellWithIdentifier:str];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
   
    
    switch (indexPath.section) {
        case 0:
        {
            Taoban1TableViewCell *t1cell=(Taoban1TableViewCell *)cell;
            t1cell.name.text=apidata[@"user"][@"name"];
            t1cell.price.text=[NSString stringWithFormat:@"%@P",[apidata[@"template"][@"point"] stringValue]];
            NSArray *arr=apidata[@"frame"];
            for (int i=0;i<arr.count;i++) {
                NSDictionary *data=arr[i];
                NSString *url=data[@"url"];
                AsyncImageView *imav=[[AsyncImageView alloc]initWithFrame:CGRectMake(97*i, 0, 94, 134)];
                imav.backgroundColor=[UIColor grayColor];
                imav.layer.borderWidth=0.5;
                [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: imav];
                imav.imageURL=[NSURL URLWithString:url];
                [t1cell.showscrollview addSubview:imav];
            }
            t1cell.showscrollview.contentSize=CGSizeMake(97*arr.count, 0);
            
        }
            break;
        case 1:
        {
           TaobantextTableViewCell *ttext=(TaobantextTableViewCell *)cell;
            ttext.textlab.text=apidata[@"template"][@"description"];
        }
            break;
        case 2:
        {
            TaobannameTableViewCell *tname=(TaobannameTableViewCell *)cell;
            
            NSString *text=apidata[@"user"][@"name"];
            tname.textlab.text=text;
            UIButton *btn=(UIButton *)[cell viewWithTag:1002];
            [btn addTarget:self action:@selector(insertreport:) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
        case 3:
        {
            Taoban3TableViewCell *t3v=(Taoban3TableViewCell *)cell;
            t3v.titlename.text=NSLocalizedString(@"CreateAlbumText-authorTemps", @"");
            
            NSArray *list=apidata[@"other"];
            for (int i=0; i<list.count; i++) {
                
                NSDictionary *d=list[i];
                UIView *v=[[UIView alloc]initWithFrame:CGRectMake(100*i, 0, 95, 190)];
                v.backgroundColor=[UIColor clearColor];
                AsyncImageView *imagev=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0, 95, 140)];
                imagev.layer.borderWidth=0.5;
                [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: imagev];
                imagev.imageURL=[NSURL URLWithString:d[@"image"]];
                [v addSubview:imagev];
                
                UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(0, 143, 95, 16)];
                label.font=[UIFont systemFontOfSize:12];
                label.text=d[@"name"];
                label.textColor=[UIColor colorWithRed:(float)110/255 green:(float)110/255 blue:(float)100/255 alpha:1.0];
                [v addSubview:label];
                
                [t3v.showscrollview addSubview:v];
                
                
                WdataButton *Wbut = [WdataButton buttonWithType:UIButtonTypeCustom];
                [Wbut setFrame:CGRectMake(0, 0, v.bounds.size.width, v.bounds.size.height)];
                [Wbut addTarget:self action:@selector(selectbtn2:) forControlEvents:UIControlEventTouchUpInside];
                [Wbut setDatastr:[d[@"template_id"]stringValue]  ];
                [v addSubview:Wbut];
            }
            
            t3v.showscrollview.contentSize=CGSizeMake(100*list.count, 0);
            
        }
            break;
        case 4:
        {
            Taoban3TableViewCell *t3v=(Taoban3TableViewCell *)cell;
            t3v.titlename.text=NSLocalizedString(@"CreateAlbumText-tempSample", @"");
            
            NSArray *list=apidata[@"album"];
            
            for (int i=0; i<list.count; i++) {
                
                NSDictionary *d=list[i];
                UIView *v=[[UIView alloc]initWithFrame:CGRectMake(100*i, 0, 95, 190)];
                v.backgroundColor=[UIColor clearColor];
                AsyncImageView *imagev=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0, 95, 140)];
                [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: imagev];
                
                NSString *coverString = d[@"cover"];
                
                if (![coverString isKindOfClass: [NSNull class]]) {
                    if (![coverString isEqualToString: @""]) {
                        imagev.imageURL=[NSURL URLWithString:d[@"cover"]];
                    } else {
                        imagev.image = [UIImage imageNamed: @"origin.jpg"];
                    }
                } else {
                    imagev.image = [UIImage imageNamed: @"origin.jpg"];
                }
                
                //imagev.imageURL=[NSURL URLWithString:d[@"cover"]];
                imagev.layer.borderWidth=0.5;
                [v addSubview:imagev];
                
                UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(0, 143, 95, 16)];
                label.font=[UIFont systemFontOfSize:12];
                label.text=d[@"name"];
                label.textColor=[UIColor colorWithRed:(float)110/255 green:(float)110/255 blue:(float)100/255 alpha:1.0];
                [v addSubview:label];
                
                [t3v.showscrollview addSubview:v];
                
                
                WdataButton *Wbut = [WdataButton buttonWithType:UIButtonTypeCustom];
                [Wbut setFrame:CGRectMake(0, 0, v.bounds.size.width, v.bounds.size.height)];
                [Wbut addTarget:self action:@selector(selectbtn:) forControlEvents:UIControlEventTouchUpInside];
                [Wbut setDatastr:[d[@"album_id"]stringValue]  ];
                [v addSubview:Wbut];
            }
            
            t3v.showscrollview.contentSize=CGSizeMake(100*list.count, 0);
            
        }
            break;
        default:
            break;
    }
    
    return cell;
}
-(void)selectbtn:(WdataButton *)sender {
    NSLog(@"selectbtn");
    NSLog(@"albumid=%@",sender.datastr);
    
    [wTools ToRetrievealbumpViewControlleralbumid:sender.datastr];
}
-(void)selectbtn2:(WdataButton *)sender {
    NSLog(@"selectbtn2");
    //TaobanViewController *tv=[[TaobanViewController alloc]initWithNibName:@"TaobanViewController" bundle:nil];    
    TaobanViewController *tv = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"TaobanViewController"];
    tv.temolateid=sender.datastr;
    [self.navigationController pushViewController:tv animated:YES];
}
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
        NSString * Pointstr=[boxAPI insertreport:[wTools getUserID] token:[wTools getUserToken] rid:rid type:@"template" typeid:_temolateid];
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[Pointstr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            
            NSString *mesg=@"";
            if ([dic[@"result"]boolValue]) {
                mesg=NSLocalizedString(@"Works-tipRpSuccess", @"");
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

- (void)cancelButtonPressed {
    
}

#pragma mark - Custom Error Alert Method
- (void)showCustomErrorAlert: (NSString *)msg {
    
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
@end
