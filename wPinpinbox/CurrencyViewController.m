//
//  CurrencyViewController.m
//  wPinpinbox
//
//  Created by Angus on 2015/8/10.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "CurrencyViewController.h"
#import "boxAPI.h"
#import "wTools.h"
#import "InAppPurchaseManager.h"
#import "Remind.h"
#import "MKDropdownMenu.h"

#import "CustomIOSAlertView.h"
#import <SafariServices/SafariServices.h>
#import "UIColor+Extensions.h"

@interface CurrencyViewController () <UITextFieldDelegate, SFSafariViewControllerDelegate, MKDropdownMenuDelegate, MKDropdownMenuDataSource>
{
    NSString *pointstr;
    NSDictionary *pointlist;
    NSArray *listdata;
    __weak IBOutlet UIButton *showbtn;
    NSString *selectproductid;
    
    NSArray *datakey;
    
    //價格表
    NSDictionary *pointdata;
    
    NSString *orderid;
    
    // For Showing Message of Getting Point
    NSString *missionTopicStr;
    NSString *rewardType;
    NSString *rewardValue;
    NSString *eventUrl;
    
    CustomIOSAlertView *alertView;
}

@property (weak, nonatomic) IBOutlet UILabel *mypoint;
@property (weak, nonatomic) IBOutlet UILabel *selectpointText;
@property (weak, nonatomic) IBOutlet UILabel *selectpriceText;

@property (strong, nonatomic) NSArray <NSString *> *types;
@property (weak, nonatomic) IBOutlet MKDropdownMenu *priceMenu;
@property (strong, nonatomic) NSString *priceTitle;

@end

@implementation CurrencyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    pickview.alpha=0;
    
    [self dropdownMenuSetUp];
    
    ptitle.text=NSLocalizedString(@"StoreText-buyP", @"");
    ptext.text=NSLocalizedString(@"StoreText-currentP", @"");
    
    //[btn_buy setImage:[UIImage imageNamed:[NSString stringWithFormat:@"button_buy_%@.png",[wTools localstring]]] forState:UIControlStateNormal];
    btn_buy.layer.cornerRadius = btn_buy.bounds.size.height / 2;
    btn_buy.clipsToBounds = YES;
    btn_buy.layer.masksToBounds = NO;
    
    [wTools ShowMBProgressHUD];
    
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *respone=[boxAPI getpointstore:[userPrefs objectForKey:@"id"] token:[userPrefs objectForKey:@"token"]];
        
        pointstr=[boxAPI geturpoints:[userPrefs objectForKey:@"id"] token:[userPrefs objectForKey:@"token"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            NSLog(@"%@",respone);
            
            if (respone!=nil) {
                NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                NSDictionary *pointdic=(NSDictionary *)[NSJSONSerialization JSONObjectWithData:[pointstr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                NSInteger point=[pointdic[@"data"] integerValue];
                pointstr=[NSString stringWithFormat:@"%ld",(long)point];
                
                if ([dic[@"result"] intValue] == 1) {
                    pointlist=[dic[@"data"] mutableCopy];
                    
                    NSMutableArray *testarr=[NSMutableArray new];
                    NSMutableArray *testarr2=[NSMutableArray new];
                    
                    for (NSDictionary *pointdic in pointlist) {
                        NSString *platform_flag =pointdic[@"platform_flag"];
                        NSString *obtain=[pointdic[@"obtain"] stringValue];
                        [testarr addObject:platform_flag];
                        [testarr2 addObject:obtain];
                    }
                    datakey=[NSArray arrayWithArray:testarr];
                    NSLog(@"datakey: %@", datakey);
                    
                    listdata=[NSArray arrayWithArray:testarr2];
                    NSLog(@"listdata: %@", listdata);
                    
                    _mypoint.text=pointstr;
                    
                    NSLog(@"myPoint: %@", _mypoint);
                    
                    _selectpointText.text=[NSString stringWithFormat:@"%@ P",listdata[0]];
                    _selectpriceText.text=@"";
                    selectproductid=datakey[0];
                } else if ([dic[@"result"] intValue] == 0) {
                    NSLog(@"失敗：%@",dic[@"message"]);
                    [self showCustomErrorAlert: dic[@"message"]];
                } else {
                    [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                }
            }
            [InAppPurchaseManager getInstance].delegate = self;
            [InAppPurchaseManager getInstance].priceid=datakey;
            [[InAppPurchaseManager getInstance] loadStore]; //讀取商店資訊
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dropdownMenuSetUp
{
    self.priceTitle = @"42 P";
    datakey=@[@"point_42",@"point_126",@"point_294",@"point_756",@"point_2016"];
    listdata=@[@"42",@"126",@"294",@"756",@"2016"];
    
    self.priceMenu.dataSource = self;
    self.priceMenu.delegate = self;
    
    // Make background light instead of dark when presenting the dropdown
    self.priceMenu.backgroundDimmingOpacity = 0;
    
    // Set custom disclosure indicator image
    UIImage *indicator = [UIImage imageNamed:@"indicator"];
    self.priceMenu.disclosureIndicatorImage = indicator;
    
    // Add an arrow between the menu header and the dropdown
    UIImageView *spacer = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"triangle"]];
    
    // Prevent the arrow image from stretching
    spacer.contentMode = UIViewContentModeCenter;
    
    self.priceMenu.spacerView = spacer;
    
    // Offset the arrow to align with the disclosure indicator
    self.priceMenu.spacerViewOffset = UIOffsetMake(self.priceMenu.bounds.size.width/2 - indicator.size.width/2 - 8, 1);
    
    // Hide top row separator to blend with the arrow
    self.priceMenu.dropdownShowsTopRowSeparator = NO;
    
    self.priceMenu.backgroundDimmingOpacity = 0.05;
    
    self.priceMenu.dropdownBouncesScroll = NO;
    
    self.priceMenu.rowSeparatorColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    self.priceMenu.rowTextAlignment = NSTextAlignmentCenter;
    
    // Round all corners (by default only bottom corners are rounded)
    self.priceMenu.dropdownRoundedCorners = UIRectCornerAllCorners;
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)buybtn:(id)sender {
    
    NSLog(@"%@",selectproductid);
    
    if(![[InAppPurchaseManager getInstance] canMakePurchases])
    {
        NSLog(@"無法使用購買服務。");
        return;
    }
    
    [wTools ShowMBProgressHUD];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *respone=[boxAPI getpayload:[wTools getUserID] token:[wTools getUserToken] productid:selectproductid];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            NSLog(@"%@",respone);
            
            if (respone!=nil) {
                NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                if ([dic[@"result"] intValue] == 1) {
                    orderid=dic[@"data"];
                    [[InAppPurchaseManager getInstance] purchaseProUpgrade2:selectproductid];
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
        
        //NSString *response = [boxAPI doTask2: [wTools getUserID] token: [wTools getUserToken] task_for: @"firsttime_buy_point" platform: @"apple" type: @"album" type_id: _albumid];
        NSString *response = [boxAPI doTask1: [wTools getUserID] token: [wTools getUserToken] task_for: @"firsttime_buy_point" platform: @"apple"];
        
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
                    
                    [self pointsUPdate];
                    
                } else if ([data[@"result"] intValue] == 2) {
                    NSLog(@"message: %@", data[@"message"]);
                    
                    // Save data for first collect album
                    BOOL firsttime_buy_point = YES;
                    
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject: [NSNumber numberWithBool: firsttime_buy_point]
                                 forKey: @"firsttime_buy_point"];
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
#pragma mark Points Update
- (void)pointsUPdate
{
    // Call geturpoints for right value
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        pointstr = [boxAPI geturpoints: [userPrefs objectForKey: @"id"] token: [userPrefs objectForKey: @"token"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"pointstr: %@", pointstr);
            
            if (pointstr != nil) {
                NSDictionary *pointDic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [pointstr dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                NSInteger point = [pointDic[@"data"] integerValue];
                pointstr = [NSString stringWithFormat: @"%ld", (long)point];
                NSLog(@"new pointstr: %@", pointstr);
                
                _mypoint.text=pointstr;
            }
        });
    });
}

#pragma mark -

- (IBAction)menulist:(UIButton *)sender {
    sender.enabled=NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        if (sender.selected) {
            pickview.alpha=0;
            showbtn.frame=CGRectMake(31, self.view.bounds.size.height-68, showbtn.bounds.size.width, showbtn.bounds.size.height) ;
        }else{
            pickview.alpha=1;
            showbtn.frame=CGRectMake(31, self.view.bounds.size.height-68-163, showbtn.bounds.size.width, showbtn.bounds.size.height) ;
        }
        sender.selected=!sender.selected;
        
    } completion:^(BOOL anim){
        
        sender.enabled=YES;
        
    }];
}

//內建函式印出圖片在Picker上
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    //設定符合PickerView的邊界
    CGRect theRect = CGRectMake(0.0, 0.0, [pickerView rowSizeForComponent:component].width, [pickerView rowSizeForComponent:component].height*2);
    //取得目前的選項項目
    UILabel *theLabel = (id)view;
    if (!theLabel) {
        theLabel = [[UILabel alloc] initWithFrame:theRect];
    }
    
    //設定文字大小
    [theLabel setFont:[UIFont boldSystemFontOfSize:18.0]];
    
    //置中
    [theLabel setTextAlignment:NSTextAlignmentCenter];
    
    //顏色
    [theLabel setTextColor:[UIColor whiteColor]];
    
    //背景顏色
    [theLabel setBackgroundColor:[UIColor clearColor]];
    
    //文字內容
    theLabel.text =[NSString stringWithFormat:@"%@ P",listdata[row]];
    
    return theLabel;
}


//內建的函式回傳UIPicker共有幾組選項
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
//內建的函式回傳UIPicker每組選項的項目數目
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    //第一組選項由0開始
    switch (component) {
        case 0:
            return [listdata count];
            break;
            
            //如果有一組以上的選項就在這裡以component的值來區分（以本程式碼為例default:永遠不可能被執行
        default:
            return 0;
            break;
    }
}


//選擇UIPickView中的項目時會出發的內建函式
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    _selectpointText.text=[NSString stringWithFormat:@"%@ P",listdata[row]];
    _selectpriceText.text=[NSString stringWithFormat:@"%@",pointdata[datakey[row]]];
    NSLog(@"%@",listdata[row]);
    selectproductid=datakey[row];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    
    return 40;
}

#pragma mark -
#pragma mark In-App Purchase

//內購相關
-(void)purchaseComplete:(NSString*)PID withDic:(NSDictionary*)dict appendString:(NSString*)str flag:(int)status{
    NSLog(@"購買行為");
    //NSError *error;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *respone=[boxAPI finishpurchased:[wTools getUserID] token:[wTools getUserToken] orderid:orderid dataSignature:str];
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (respone!=nil) {
                NSLog(@"%@",respone);
                
                NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                if ([dic[@"result"] intValue] == 1) {
                    pointstr=[dic[@"data"] stringValue];
                    NSLog(@"old pointstr: %@", pointstr);
                    
                    //_mypoint.text=pointstr;
                    
                    NSLog(@"Purchase is Successful");
                    // Check whether getting P-Point-Buying point or not
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    BOOL firsttime_buy_point = [[defaults objectForKey: @"firsttime_buy_point"] boolValue];
                    NSLog(@"firsttime_buy_point: %d", (int)firsttime_buy_point);
                    
                    if (firsttime_buy_point) {
                        NSLog(@"Get the First Time Buying P Point Task Already");
                    } else {
                        [self checkPoint];
                    }
                    [self pointsUPdate];
                    
                } else if ([dic[@"result"] intValue] == 0) {
                    NSLog(@"失敗：%@",dic[@"message"]);
                    Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
                    [rv addtitletext:dic[@"message"]];
                    [rv addBackTouch];
                    [rv showView:self.view];
                } else {
                    Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
                    [rv addtitletext:NSLocalizedString(@"Host-NotAvailable", @"")];
                    [rv addBackTouch];
                    [rv showView:self.view];
                }
            }
        });
    });
    
    //[wTools HideMBProgressHUD];
}

-(void)purchaseFailed:(NSString*)info{
    NSLog(@"Failed:%@",info);
}

-(void)StoreInfoError:(NSString*)info{
    NSLog(@"Error:%@",info);
}

//-(void)giveMeStoreList:(NSArray*)products; //商品列表 from apple
//商品資訊
-(void)giveMeItemInfo:(NSMutableDictionary*)products{
    NSLog(@"商品詳細Info:%@", products);
    pointdata = [NSDictionary dictionaryWithDictionary:products];
    
    _selectpointText.text = [NSString stringWithFormat:@"%@ P",listdata[0]];
    self.priceTitle = [NSString stringWithFormat:@"%@ P",listdata[0]];
    
    _selectpriceText.text = [NSString stringWithFormat:@"%@",pointdata[datakey[0]]];
    selectproductid = datakey[0];
}

#pragma mark - MKDropdownMenuDataSource
- (NSInteger)numberOfComponentsInDropdownMenu:(MKDropdownMenu *)dropdownMenu {
    return 1;
}

- (NSInteger)dropdownMenu:(MKDropdownMenu *)dropdownMenu numberOfRowsInComponent:(NSInteger)component {
    return listdata.count;
}

#pragma mark - MKDropdownMenuDelegate
- (CGFloat)dropdownMenu:(MKDropdownMenu *)dropdownMenu rowHeightForComponent:(NSInteger)component {
    return 30;
}

- (CGFloat)dropdownMenu:(MKDropdownMenu *)dropdownMenu widthForComponent:(NSInteger)component {
    return 0;
}

- (BOOL)dropdownMenu:(MKDropdownMenu *)dropdownMenu shouldUseFullRowWidthForComponent:(NSInteger)component {
    return NO;
}

- (NSAttributedString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu attributedTitleForComponent:(NSInteger)component {
    return [[NSAttributedString alloc] initWithString: self.priceTitle
                                           attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:24 weight:UIFontWeightLight],
                                                        NSForegroundColorAttributeName: [UIColor blackColor]}];
}

- (NSAttributedString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSMutableAttributedString *string =
    [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat: @"%@ P", listdata[row]]
                                           attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14 weight:UIFontWeightLight],
                                                        NSForegroundColorAttributeName: [UIColor blackColor]}];
    return string;
}

- (UIColor *)dropdownMenu:(MKDropdownMenu *)dropdownMenu backgroundColorForRow:(NSInteger)row forComponent:(NSInteger)component {
    //return [UIColor colorWithRed: 32.0/255.0 green: 191.0/255.0 blue: 193.0/255.0 alpha: 1.0];;
    return [UIColor whiteColor];
}

- (void)dropdownMenu:(MKDropdownMenu *)dropdownMenu didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"dropdownMenu didSelectRow");
    
    _selectpointText.text = [NSString stringWithFormat:@"%@ P", listdata[row]];
    self.priceTitle = [NSString stringWithFormat:@"%@ P", listdata[row]];
    
    _selectpriceText.text = [NSString stringWithFormat:@"%@", pointdata[datakey[row]]];
    NSLog(@"%@",listdata[row]);
    selectproductid = datakey[row];
    
    [dropdownMenu closeAllComponentsAnimated:YES];
    [dropdownMenu reloadAllComponents];
    
    /*
    self.navTitle = self.types[row];
    //[self.navItem setTitle: self.types[row]];
    self.navigationItem.title = self.types[row];
    
    self.typeData = self.types[row];
    
    //@"最  新" ,@"熱  門", @"贊  助", @"關  注"
    if ([self.typeData isEqualToString: @"最  新"]) {
        self.typeData = @"latest";
    } else if ([self.typeData isEqualToString: @"熱  門"]) {
        self.typeData = @"hot";
    } else if ([self.typeData isEqualToString: @"贊  助"]) {
        self.typeData = @"sponsored";
    } else if ([self.typeData isEqualToString: @"關  注"]) {
        self.typeData = @"follow";
    }
    
    NSLog(@"self.typeData: %@", self.typeData);
     
    delay(0.1, ^{
        [dropdownMenu closeAllComponentsAnimated:YES];
        [dropdownMenu reloadAllComponents];
    });
    
    [self refresh];
      */
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
