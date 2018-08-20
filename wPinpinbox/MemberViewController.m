//
//  MemberViewController.m
//  wPinpinbox
//
//  Created by Angus on 2015/8/7.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "MemberViewController.h"
#import "MemberTopimageTableViewCell.h"
#import "MemberTextViewTableViewCell.h"
#import "MemberTextTableViewCell.h"
#import "MemberBtnTableViewCell.h"
#import "boxAPI.h"
#import "AppDelegate.h"
#import "MemberPointTableViewCell.h"
#import "CurrencyViewController.h"
#import "EditPasswdViewController.h"
#import "EditMemberViewController.h"
#import "Remind.h"
#import "wTools.h"

#import "CustomIOSAlertView.h"
#import <SafariServices/SafariServices.h>

#import "UIColor+Extensions.h"

@interface MemberViewController () <SFSafariViewControllerDelegate>
{
    __weak IBOutlet UIButton *mbtn;
    
    __weak IBOutlet UIButton *pbtn;
    NSArray *titlearr;
    NSDictionary *mydata;
    NSString *Pointstr;
    int typeno;
    
    int type;
    
    BOOL FBlogin;
    
    // For Showing Message of Getting Point
    NSString *missionTopicStr;
    NSString *rewardType;
    NSString *rewardValue;
    NSString *eventUrl;
    
    CustomIOSAlertView *alertView;
}

@property (weak, nonatomic) IBOutlet UITableView *mytableview;

@end

@implementation MemberViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    
    if ([userPrefs objectForKey:@"FB"])
    {
        FBlogin=YES;
    }
    else
    {
        FBlogin=NO;
    }
    
    
    titlearr=@[@"",NSLocalizedString(@"ProfileText-about", @""),NSLocalizedString(@"GeneralText-nickName", @""),NSLocalizedString(@"GeneralText-email", @""),NSLocalizedString(@"GeneralText-pwd", @""),NSLocalizedString(@"GeneralText-cellphone", @""),NSLocalizedString(@"ProfileText-sex", @""),NSLocalizedString(@"ProfileText-birthday", @"")];
    
    typeno=0;
    type=0;
    
    
    wtitle.text=NSLocalizedString(@"ProfileText-zone", @"");
    [mbtn setTitle:NSLocalizedString(@"ProfileText-zone", @"") forState:UIControlStateNormal];
    [pbtn setTitle:NSLocalizedString(@"ProfileText-reqP", @"") forState:UIControlStateNormal];
}

#pragma mark -

-(void)reloadmydata {
    [wTools ShowMBProgressHUD];
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *respone=[boxAPI getprofile:[userPrefs objectForKey:@"id"] token:[userPrefs objectForKey:@"token"]];
        
        Pointstr=[boxAPI geturpoints:[userPrefs objectForKey:@"id"] token:[userPrefs objectForKey:@"token"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (respone!=nil) {
                NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                NSDictionary *pointdic=(NSDictionary *)[NSJSONSerialization JSONObjectWithData:[Pointstr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                NSInteger point=[pointdic[@"data"] integerValue];
                Pointstr=[NSString stringWithFormat:@"%ldP",(long)point];
                
                if ([dic[@"result"] intValue] == 1) {
                    //儲存會員資料
                    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
                    NSMutableDictionary *dataic=[[NSMutableDictionary alloc]initWithDictionary:dic[@"data"] copyItems:YES];
                    
                    for (NSString *kye in [dataic allKeys] ) {
                        id objective =[dataic objectForKey:kye];
                        if ([objective isKindOfClass:[NSNull class]]) {
                            [dataic setObject:@"" forKey:kye];
                        }
                    }
                    
                    [userPrefs setValue:dataic forKey:@"profile"];
                    [userPrefs synchronize];
                    AppDelegate *app=[[UIApplication sharedApplication]delegate];
                    [app.menu reloadpic:dic[@"data"][@"profilepic"]];
                    
                    mydata=[dataic mutableCopy];
                    typeno=8;
                    [self btn:mbtn];
                    [_mytableview reloadData];
                } else if ([dic[@"result"] intValue] == 0) {
                    Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
                    [rv addtitletext:dic[@"message"]];
                    [rv addBackTouch];
                    [rv showView:self.view];
                    NSLog(@"失敗：%@",dic[@"message"]);
                } else {
                    Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
                    [rv addtitletext: NSLocalizedString(@"Host-NotAvailable", @"")];
                    [rv addBackTouch];
                    [rv showView:self.view];
                }
            }
        });
    });
}

-(void)viewWillAppear:(BOOL)animated {
    NSLog(@"MemberViewController");
    NSLog(@"viewWillAppear");
    
    [super viewWillAppear:animated];
    typeno=0;
    type=0;
    //最先載入個人資料
    [self reloadmydata];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *editProfile = [defaults objectForKey: @"editProfile"];
    NSLog(@"editProfile: %@", editProfile);
    
    if ([editProfile isEqualToString: @"FirstTimeModified"]) {
        
        NSLog(@"Get the First Time Eidt Profile Point Already");
        NSLog(@"show alert point view");
        [self checkPoint];
        
        // Save data for first edit profile
        editProfile = @"ModifiedAlready";
        
        [defaults setObject: editProfile
                     forKey: @"editProfile"];
        [defaults synchronize];
    }
}

#pragma mark - Check Point Method

- (void)checkPoint
{
    NSLog(@"checkPoint");
    
    //[wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *response = [boxAPI doTask1: [wTools getUserID] token: [wTools getUserToken] task_for: @"firsttime_edit_profile" platform: @"apple"];
        
        NSLog(@"User ID: %@", [wTools getUserID]);
        NSLog(@"Token: %@", [wTools getUserToken]);
        
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
                    
                    // Save data for first edit profile
                    BOOL firsttime_edit_profile = YES;
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject: [NSNumber numberWithBool: firsttime_edit_profile]
                                 forKey: @"firsttime_edit_profile"];
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

#pragma mark - Custom AlertView for Getting Point
- (void)showAlertView
{
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
    //missionTopicLabel.text = @"登入得點";
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)editbtn:(id)sender {
    EditMemberViewController *emv=[[EditMemberViewController alloc]initWithNibName:@"EditMemberViewController" bundle:nil];
    [self.navigationController pushViewController:emv animated:YES];
}

- (IBAction)menu:(id)sender {
    [wTools myMenu];
}

- (IBAction)btn:(id)sender {
    if (mbtn==sender) {
        mbtn.selected=YES;
        pbtn.selected=NO;
        type=0;
        typeno=8;
    }else{
        mbtn.selected=NO;
        pbtn.selected=YES;
        type=1;
        typeno=2;
    }
    [_mytableview reloadData];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return typeno;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.section) {
        case 0:
            return 100;
            break;
        case 1:
            if (type==1) {
                return 67;
            }
            return 120;
            break;
        case 4:
            if (FBlogin) {
                return 0;
            }
            return 67;
            break;
        default:
            return 67;
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier=@"";
    NSString *str=@"";
    switch (indexPath.section) {
        case 0:
            CellIdentifier=@"CellIdentifier1";
            str=@"MemberTopimageTableViewCell";
            break;
        case 1:
            
            CellIdentifier=@"CellIdentifier2";
            str=@"MemberTextViewTableViewCell";
            if (type==1) {
                CellIdentifier=@"CellIdentifier5";
                str=@"MemberPointTableViewCell";
            }
            break;
        case 4:
            CellIdentifier=@"CellIdentifier4";
            str=@"MemberBtnTableViewCell";
            break;
        default:
            CellIdentifier=@"CellIdentifier3";
            str=@"MemberTextTableViewCell";
            break;
    }
    UITableViewCell *cell=nil;
    cell= [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:str bundle:nil] forCellReuseIdentifier:CellIdentifier];
        cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    switch (indexPath.section) {
        case 0:
        {
            MemberTopimageTableViewCell *imgecell=(MemberTopimageTableViewCell *)cell;
            //imgecell.myimage.image=[UIImage imageNamed:@"2-01aaphoto.png"];
            imgecell.myimage.image = [UIImage imageNamed: @"member_back_head.png"];
            [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: imgecell.myimage];
            imgecell.myimage.imageURL=[NSURL URLWithString:mydata[@"profilepic"]];
            
            [[imgecell.myimage layer] setMasksToBounds:YES];
            [[imgecell.myimage layer]setCornerRadius:imgecell.myimage.bounds.size.height/2];
        }
            break;
        case 1:
        {
            if (type==1) {
                MemberPointTableViewCell *pcell=(MemberPointTableViewCell *)cell;
                pcell.mytext.text=Pointstr;
                pcell.customBlock=^(void){
                    NSLog(@"購買P點");
                    /*
                     Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
                     [rv addtitletext:@"暫時無法購買, 請待開放後使用!!"];
                     [rv addBackTouch];
                     [rv showView:self.view];
                     */
                    CurrencyViewController *cvc=[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"CurrencyViewController"];
                    
                    [self.navigationController pushViewController:cvc animated:YES];
                    
                    
                };
            }else{
                MemberTextViewTableViewCell *tvcell=(MemberTextViewTableViewCell *)cell;
                tvcell.mytextview.text=mydata[@"selfdescription"];
                tvcell.mytextview.textColor=[UIColor whiteColor];
            }
            
        }
            break;
        case 2://暱稱
        {
            MemberTextTableViewCell *textcell=(MemberTextTableViewCell *)cell;
            textcell.title.text=titlearr[indexPath.section];
            textcell.mytext.text=mydata[@"nickname"];
        }
            break;
        case 3://email.
        {
            MemberTextTableViewCell *textcell=(MemberTextTableViewCell *)cell;
            textcell.title.text=titlearr[indexPath.section];
            textcell.mytext.text=mydata[@"email"];
        }
            break;
        case 4://密碼
        {
            MemberBtnTableViewCell *btncell=(MemberBtnTableViewCell *)cell;
            
            
            for (UIView *v in [btncell subviews]) {
                v.hidden=YES;
            }
            btncell.title.text=titlearr[indexPath.section];
            btncell.customBlock=^(void){
                
                EditPasswdViewController *edpv=[[EditPasswdViewController alloc]initWithNibName:@"EditPasswdViewController" bundle:nil];
                [self.navigationController pushViewController:edpv animated:YES];
                
                NSLog(@"變更密碼");
            };
        }
            break;
        case 5://手機
        {
            MemberTextTableViewCell *textcell=(MemberTextTableViewCell *)cell;
            textcell.title.text=titlearr[indexPath.section];
            textcell.mytext.text=mydata[@"cellphone"];
        }
            break;
        case 6:
        {
            MemberTextTableViewCell *textcell=(MemberTextTableViewCell *)cell;
            textcell.title.text=titlearr[indexPath.section];
            
            if ([mydata[@"gender"] isEqualToNumber:[NSNumber numberWithInt:1]]) {
                textcell.mytext.text=NSLocalizedString(@"ProfileText-male", @"");
            }else if ([mydata[@"gender"] isEqualToNumber:[NSNumber numberWithInt:0]]){
                textcell.mytext.text=NSLocalizedString(@"ProfileText-female", @"");
            }else{
                textcell.mytext.text=NSLocalizedString(@"ProfileText-none", @"");
            }
        }
            break;
        case 7:
        {
            MemberTextTableViewCell *textcell=(MemberTextTableViewCell *)cell;
            textcell.title.text=titlearr[indexPath.section];
            textcell.mytext.text=mydata[@"birthday"];
        }
            break;
        default:
        {
            MemberTextTableViewCell *textcell=(MemberTextTableViewCell *)cell;
            textcell.title.text=titlearr[indexPath.section];
        }
            break;
    }
    
    // Configure the cell...
    
    return cell;
}

-(IBAction)logout:(id)sender{
    // if ([userPrefs objectForKey:@"id"] &&[userPrefs objectForKey:@"token"]) {
    
    Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
    [rv addtitletext:@"確定要登出，並且刪除紀錄資料？"];
    [rv addSelectBtntext:@"是" btn2:@"否"];
    [rv showView:self.view];
    rv.btn1select=^(BOOL bo){
        NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
        [userPrefs removeObjectForKey:@"id"];
        [userPrefs removeObjectForKey:@"token"];
        [userPrefs synchronize];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"data"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *  newFolderPath = [path stringByAppendingPathComponent:@"pinpinbox"];
        //建立新資料夾
        fileManager = [NSFileManager defaultManager];
        
        BOOL isFileAlreadyExists = [fileManager fileExistsAtPath:newFolderPath];
        if (!isFileAlreadyExists) {
            [fileManager createDirectoryAtPath:newFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
        }else{
            if ([fileManager removeItemAtPath:newFolderPath error:nil])
                [fileManager createDirectoryAtPath:newFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
            
        }
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    };
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
    [errorAlertView setUseMotionEffects: YES];
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

@end
