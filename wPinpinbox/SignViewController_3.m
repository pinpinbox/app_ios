//
//  SignViewController_3.m
//  wPinpinbox
//
//  Created by Angus on 2015/8/7.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "SignViewController_3.h"
#import "wTools.h"
#import "boxAPI.h"
#import "UICustomLineLabel.h"
#import "SelectBarViewController.h"
#import "UIViewController+CWPopup.h"

#import "OpenUDID.h"
#import "UIColor+Extensions.h"
#import "UIView+Toast.h"
#import "MBProgressHUD.h"
#import "CustomIOSAlertView.h"
#import "FBFriendsFindingViewController.h"
#import "GlobalVars.h"
#import "AppDelegate.h"
#import "UIViewController+ErrorAlert.h"

@interface SignViewController_3 ()<UITextFieldDelegate, SelectBarDelegate, UIGestureRecognizerDelegate> {
    UITextField *selectText;
    __weak IBOutlet UITextField *keylab;
    __weak IBOutlet UITextField *phone;
    
    __weak IBOutlet UILabel *countryLabel;
    NSArray *country;
    
    __weak IBOutlet UIView *countryCodeView;
    __weak IBOutlet UIView *mobilePhoneView;
    __weak IBOutlet UIView *smsView;
    
    __weak IBOutlet UILabel *countDownLabel;
    
    int timeTick;
    NSTimer *timer;
    
//    BOOL wantToGetInfo;
    BOOL wantToGetNewsLetter;
}
@property (weak, nonatomic) IBOutlet UIView *newsLetterCheckView;
@property (weak, nonatomic) IBOutlet UIView *newsLetterCheckSelectionView;

//@property (weak, nonatomic) IBOutlet UIView *infoGettingCheckView;
//@property (weak, nonatomic) IBOutlet UIView *infoGettingCheckSelectionView;

@end

@implementation SignViewController_3

#pragma mark - View Related Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.delegate = self;
    
    [self viewSetup];
    [self navBarBtnSetup];
    [self inputFieldSetup];
    
    [btn_send setTitle: NSLocalizedString(@"GeneralText-send", @"") forState:UIControlStateNormal];
    [btn_send addTarget: self action: @selector(hideKeyboard:) forControlEvents: UIControlEventTouchUpInside];
    
    [btn_finishedReg setTitle: NSLocalizedString(@"RegText-finishedReg", @"") forState:UIControlStateNormal];
    
    phone.inputAccessoryView = [self setuptoolbar];
    
    //取得檔案路徑
    NSString *path = [[NSBundle mainBundle] pathForResource:@"codebeautify" ofType:@"json"];
    NSString *respone = [NSString stringWithContentsOfFile: path encoding: NSUTF8StringEncoding error:nil];
    country=[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil][@"item"];
    NSLog(@"%@",country);
    
    UITapGestureRecognizer *doBegan = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showbar)];
    [countryLabel addGestureRecognizer: doBegan];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addKeyboardNotification];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.enabled = YES;
    
    [wTools setStatusBarBackgroundColor: [UIColor clearColor]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeKeyboardNotification];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewSetup {
    countryCodeView.layer.cornerRadius = kCornerRadius;
    mobilePhoneView.layer.cornerRadius = kCornerRadius;
    smsView.layer.cornerRadius = kCornerRadius;
    countDownLabel.hidden = YES;
    
    btn_send.layer.cornerRadius = kCornerRadius;
    btn_finishedReg.layer.cornerRadius = kCornerRadius;
    
    wantToGetNewsLetter = NO;
    self.newsLetterCheckSelectionView.layer.cornerRadius = kCornerRadius;
    self.newsLetterCheckSelectionView.layer.borderColor = [UIColor thirdGrey].CGColor;
    self.newsLetterCheckSelectionView.layer.borderWidth = 1.0;
    self.newsLetterCheckSelectionView.backgroundColor = [UIColor clearColor];
}

- (void)navBarBtnSetup {
    UIImage *img = [UIImage imageNamed: @"ic200_arrow_left_light"];
    CGRect rect = CGRectMake(0, 0, 15, 15);
    UIGraphicsBeginImageContext(rect.size);
    [img drawInRect: rect];
    UIImage *navBtnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [navBackBtn setImage: navBtnImage forState: UIControlStateNormal];
    [navBackBtn setTitleEdgeInsets: UIEdgeInsetsMake(0.0, 15, 0, 0)];
}

- (void)inputFieldSetup {
    phone.textColor = [UIColor firstGrey];
    keylab.textColor = [UIColor firstGrey];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches
           withEvent:(UIEvent *)event{
    [self.view endEditing: YES];
    
    CGPoint location = [[touches anyObject] locationInView: self.view];
    CGRect fingerRect = CGRectMake(location.x - 5, location.y - 5, 10, 10);
    
    for (UIView *view in self.view.subviews) {
        CGRect subviewFrame = view.frame;
        
        if (CGRectIntersectsRect(fingerRect, subviewFrame)) {
            NSLog(@"finally touched view: %@", view);
            NSLog(@"view.tag: %ld", (long)view.tag);
            
            switch (view.tag) {
                case 100:
                    wantToGetNewsLetter = !wantToGetNewsLetter;
                    if (wantToGetNewsLetter) {
                        self.newsLetterCheckSelectionView.backgroundColor = [UIColor thirdMain];
                    } else {
                        self.newsLetterCheckSelectionView.backgroundColor = [UIColor clearColor];
                    }
                default:
                    break;
            }
        }
    }
}

- (void)hideKeyboard: (id)sender {
    [self.view endEditing: YES];
}

- (UIToolbar *)setuptoolbar {
    
    CGRect frame =CGRectMake(0, 0, 320, 44);
    NSMutableArray * Items = [NSMutableArray new];
    
    UIBarButtonItem *item0=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [Items addObject:item0];
    
    UIBarButtonItem *item1 =[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"GeneralText-ok", @"") style:UIBarButtonItemStyleDone target:self action:@selector(toolbarNext:)];
    [Items addObject:item1];
    
    
    UIToolbar *numberToolbar= [[UIToolbar alloc]initWithFrame:frame];
    //numberToolbar.barStyle=UIBarStyleBlackTranslucent;
    numberToolbar.items=Items;
    numberToolbar.tintColor=[UIColor darkGrayColor];
    numberToolbar.translucent=false;
    
    [numberToolbar sizeToFit];
    
    return numberToolbar;
}

- (void)toolbarNext:(id)sender {
    [phone resignFirstResponder];
}

#pragma mark - Show SelectBar

- (void)showbar {
    NSLog(@"showbar");
    [wTools setStatusBarBackgroundColor: [UIColor clearColor]];
    
    SelectBarViewController *mv = [[SelectBarViewController alloc]initWithNibName:@"SelectBarViewController" bundle:nil];
    mv.data = country;
    mv.delegate = self;
    mv.topViewController = self;
    [self wpresentPopupViewController:mv animated:YES completion:nil];
}

#pragma mark - SelectBar Delegate Method

- (void)SaveDataRow:(NSInteger)row {
    [wTools setStatusBarBackgroundColor: [UIColor whiteColor]];
    countryLabel.adjustsFontSizeToFitWidth=YES;
    countryLabel.text=country[row];
}

- (void)cancelButtonPressed {
    [wTools setStatusBarBackgroundColor: [UIColor whiteColor]];
}

#pragma mark -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction Methods

//發送驗證碼
-(IBAction)cellapi:(id)sender{
    
    if ([phone.text isEqualToString:@""]) {
        //meeage=NSLocalizedString(@"RegText-tip", @"");
        
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor thirdPink];
        
        [self.view makeToast: NSLocalizedString(@"RegText-tip", @"")
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
        
        mobilePhoneView.backgroundColor = [UIColor thirdPink];
        
        return;
    }
    /*
    if (![meeage isEqualToString:@""]) {
        Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
        [rv addtitletext:meeage];
        [rv addBackTouch];
        [rv showView:self.view];
        return ;
    }
    */
    NSString *countrstr=[countryLabel.text componentsSeparatedByString:@"+"][1];
    
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *tmp=[NSMutableDictionary new];
    [tmp addEntriesFromDictionary:[userPrefs objectForKey:@"tmp"]];
    
    NSString *email=@"";
    
    if (_facebookID==nil) {
        email=tmp[@"email"];
    }
    @try {
        [MBProgressHUD showHUDAddedTo: self.view animated:YES];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    NSString *pwd = [NSString stringWithFormat:@"%@,%@",countrstr,phone.text];
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSString *response = [boxAPI requsetsmspwd: pwd Account:email];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [MBProgressHUD hideHUDForView: self.view  animated:YES];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog( @"NSException caught" );
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason );
                return;
            }
            if (response != nil) {
                NSLog(@"response from requsetsmspwd");
                NSLog(@"response: %@",response);
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"SignViewController_3");
                    NSLog(@"cellapi");
                    
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"requsetsmspwd"];
                } else {
                    NSLog(@"Get Real Response");
                    
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    [wself processValidResult:dic];
                }
            }
        });
    });
}
- (void)processValidResult:(NSDictionary *)dic {
    if ([dic[@"result"] intValue] == 1) {
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor secondMain];
        
        [self.view makeToast: NSLocalizedString(@"RegText-successSent", @"")
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
        
        countDownLabel.hidden = NO;
        btn_send.userInteractionEnabled = NO;
        [btn_send setTitleColor: [UIColor secondGrey] forState: UIControlStateNormal];
        btn_send.backgroundColor = [UIColor clearColor];
        btn_send.layer.borderWidth = 1.0f;
        btn_send.layer.borderColor = [UIColor secondGrey].CGColor;
        
        timeTick = 59;
        [timer invalidate];
        timer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self selector: @selector(tickForSMS) userInfo: nil repeats: YES];
    } else if ([dic[@"result"] intValue] == 0) {
        NSLog(@"失敗： %@", dic[@"message"]);
        NSString *msg = dic[@"message"];
        [self showCustomErrorAlert: msg];
    } else {
        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
    }
}
- (void)tickForSMS
{
    NSLog(@"tick");
    
    if (timeTick == 0) {
        [timer invalidate];
        
        countDownLabel.hidden = YES;
        btn_send.userInteractionEnabled = YES;
        
        [btn_send setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
        btn_send.backgroundColor = [UIColor firstMain];
        btn_send.layer.borderWidth = 0.0f;
        btn_send.layer.borderColor = [UIColor clearColor].CGColor;
    } else {
        timeTick--;
        countDownLabel.text = [NSString stringWithFormat: @"剩餘 %d 秒可再發送", timeTick];
        NSLog(@"countDownLabel.text: %@", countDownLabel.text);
    }
}

//註冊
- (IBAction)downbtn:(id)sender {
    NSLog(@"downbtn");
    if ([keylab.text isEqualToString: @""]) {
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor thirdPink];
        
        [self.view makeToast: NSLocalizedString(@"RegText-tipSMSPwd", @"")
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
        return;
    }
    
    // Show Toast Message
    CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
    style.messageColor = [UIColor whiteColor];
    style.backgroundColor = [UIColor hintGrey];
    
    [self.view makeToast: @"正在註冊，請稍候"
                duration: 2.0
                position: CSToastPositionBottom
                   style: style];
    
    // Store Data & Create Key-Value Data
    NSString *countrStr = [countryLabel.text componentsSeparatedByString: @"+"][1];
    
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *tmp = [userPrefs objectForKey:@"tmp"];
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject:tmp[@"email"] forKey:@"account"];
    [dic setObject:@"none" forKey:@"way"];
    [dic setObject:@"null" forKey:@"way_id"];
    [dic setObject:tmp[@"pwd"] forKey:@"password"];
    [dic setObject:tmp[@"name"] forKey:@"name"];
    //[dic setObject:phone.text forKey:@"cellphone"];
    [dic setObject: [NSString stringWithFormat: @"%@,%@", countrStr, phone.text] forKey: @"cellphone"];
    [dic setObject:keylab.text forKey:@"smspassword"];
    [dic setObject: [NSNumber numberWithBool: wantToGetNewsLetter] forKey: @"newsletter"];
    
    @try {
        [MBProgressHUD showHUDAddedTo: self.view animated:YES];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){        
        NSString *respone = [boxAPI registration:dic];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [MBProgressHUD hideHUDForView: self.view  animated:YES];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog( @"NSException caught" );
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason );
                return;
            }
            
            if (respone != nil) {
                NSLog(@"response from registration");
                NSLog(@"response: %@", respone);
                
                if ([respone isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"SignViewController_3");
                    NSLog(@"downbtn");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"registration"];
                } else {
                    NSLog(@"Get Real Response");
                    
                    NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([data[@"result"] intValue] == 1) {
                        NSLog(@"result is: %d", [data[@"result"] boolValue]);
                        
                        // Show Toast Message
                        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                        style.messageColor = [UIColor whiteColor];
                        style.backgroundColor = [UIColor secondMain];
                        
                        [self.view makeToast: @"註冊成功"
                                    duration: 2.0
                                    position: CSToastPositionBottom
                                       style: style];
                        
                        NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
                        
                        [userPrefs setObject:data[@"data"][@"token"] forKey:@"token"];
                        [userPrefs setObject:[data[@"data"][@"id"] stringValue] forKey:@"id"];
                        [userPrefs synchronize];
                        
                        FBFriendsFindingViewController *fbFindingVC = [[UIStoryboard storyboardWithName:@"FBFriendsFindingVC" bundle:nil]instantiateViewControllerWithIdentifier:@"FBFriendsFindingViewController"];
                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        [appDelegate.myNav pushViewController: fbFindingVC animated: YES];
                        
                        // APNS Setting
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                            
                            NSString *awsResponse;
                            
                            if ([wTools getUUID]) {
                                
                                NSLog(@"getUserID: %@", [wTools getUserID]);
                                NSLog(@"getUserToken: %@", [wTools getUserToken]);
                                NSLog(@"getUUID: %@", [wTools getUUID]);
                                NSLog(@"identifier: %@", [OpenUDID value]);
                                
                                UIDevice *device = [UIDevice currentDevice];
                                NSString *currentDeviceId = [[device identifierForVendor] UUIDString];
                                NSLog(@"currentDeviceId: %@", currentDeviceId);
                                
                                //awsResponse = [boxAPI setawssns:[wTools getUserID] token:[wTools getUserToken] devicetoken:[wTools getUUID] identifier:[OpenUDID value]];
                                awsResponse = [boxAPI setawssns:[wTools getUserID] token:[wTools getUserToken] devicetoken:[wTools getUUID] identifier: currentDeviceId];
                            }
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                if (awsResponse != nil) {
                                    NSLog(@"awsResponse: %@", awsResponse);
                                }
                            });
                        });
                    } else if ([data[@"result"] intValue] == 0) {
                        NSLog(@"失敗： %@", data[@"message"]);
                        NSString *msg = data[@"message"];
                        NSLog(@"msg: %@", msg);                        
                        [self showCustomErrorAlert: msg];
                    } else {
                        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            }
        });
    });
}

- (IBAction)back:(id)sender {
    //[self.navigationController popViewControllerAnimated:YES];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav popViewControllerAnimated: YES];
}

#pragma mark - UITextField Delegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    selectText=textField;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    selectText=nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"textFieldShouldReturn");
    
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
//    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    NSString *resultString = [textField.text stringByReplacingCharactersInRange: range
                                                                     withString: string];
    
    if (![resultString isEqualToString: @""]) {
        mobilePhoneView.backgroundColor = [UIColor thirdGrey];
    } else {
        mobilePhoneView.backgroundColor = [UIColor thirdPink];
    }
    
    return YES;
}

#pragma mark - Keyboard Related

- (void)addKeyboardNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)removeKeyboardNotification {
    NSLog(@"");
    NSLog(@"removeKeyboardNotification");
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIKeyboardDidShowNotification
                                                  object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIKeyboardWillHideNotification
                                                  object: nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary *info = [aNotification userInfo];
    // in iOS 11, the height of size of UIKeyboardFrameBeginUserInfoKey will be zero in second time
    // when keyboardWasshown method called
    //CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    float textfy = [selectText superview].frame.origin.y;
    float textfh = selectText.frame.size.height;
    float h = self.view.frame.size.height;
    float kh = kbSize.height;
    float height = (textfh + textfy) - (h - kh);
    
    if (height > 0) {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, -height, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

#pragma mark - Custom Error Alert Method
- (void)showCustomErrorAlert: (NSString *)msg
{
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
- (void)showCustomTimeOutAlert: (NSString *)msg
                  protocolName: (NSString *)protocolName
{
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
            if ([protocolName isEqualToString: @"requsetsmspwd"]) {
                [weakSelf cellapi: nil];
            } else if ([protocolName isEqualToString: @"registration"]) {
                [weakSelf downbtn: nil];                                
            }
        }
    }];
    [alertTimeOutView setUseMotionEffects: YES];
    [alertTimeOutView show];
}

- (UIView *)createTimeOutContainerView: (NSString *)msg
{
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

@end
