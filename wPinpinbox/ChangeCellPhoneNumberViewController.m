//
//  ChangeCellPhoneNumberViewController.m
//  wPinpinbox
//
//  Created by David on 5/14/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "ChangeCellPhoneNumberViewController.h"

#import "wTools.h"
#import "boxAPI.h"
#import "UIView+Toast.h"
#import "CustomIOSAlertView.h"
#import "UIColor+Extensions.h"

#import "SelectBarViewController.h"
#import "UIViewController+CWPopup.h"

#import "CustomIOSAlertView.h"

#import "GlobalVars.h"

#import "AppDelegate.h"
#import "UIViewController+ErrorAlert.h"

@interface ChangeCellPhoneNumberViewController () <SelectBarDelegate, UIGestureRecognizerDelegate> {
    UITextField *selectTextField;
    NSDictionary *myData;
    NSArray *country;
    NSInteger timeTick;
    NSTimer *timer;
}
@property (weak, nonatomic) IBOutlet UILabel *cellPhoneNumberLabel;

@property (weak, nonatomic) IBOutlet UILabel *countryCodeLabel;
@property (weak, nonatomic) IBOutlet UIView *countryCodeView;

@property (weak, nonatomic) IBOutlet UITextField *cellPhoneTextField;
@property (weak, nonatomic) IBOutlet UIView *cellPhoneView;

@property (weak, nonatomic) IBOutlet UILabel *countDownLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;

@property (weak, nonatomic) IBOutlet UITextField *smsTextField;
@property (weak, nonatomic) IBOutlet UIView *smsView;

@property (weak, nonatomic) IBOutlet UIButton *finishRegistrationBtn;

@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarHeight;
@end

@implementation ChangeCellPhoneNumberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.delegate = self;
    [self initialValueSetup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addKeyboardNotification];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.enabled = YES;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialValueSetup {
    self.navBarView.backgroundColor = [UIColor barColor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
 
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    myData = [userPrefs objectForKey: @"profile"];
    
    self.cellPhoneNumberLabel.text = myData[@"cellphone"];
    
    self.countryCodeView.layer.cornerRadius = kCornerRadius;
    self.countryCodeView.backgroundColor = [UIColor thirdGrey];
    self.cellPhoneView.layer.cornerRadius = kCornerRadius;
    self.cellPhoneView.backgroundColor = [UIColor thirdGrey];
    self.smsView.layer.cornerRadius = kCornerRadius;
    self.smsView.backgroundColor = [UIColor thirdGrey];
    self.countDownLabel.hidden = YES;
    
    self.sendBtn.layer.cornerRadius = kCornerRadius;
    [self.sendBtn setTitle: NSLocalizedString(@"GeneralText-send", @"")
                  forState: UIControlStateNormal];
    
    self.finishRegistrationBtn.layer.cornerRadius = kCornerRadius;
    [self.finishRegistrationBtn setTitle: NSLocalizedString(@"RegText-finishedReg", @"")
                                forState: UIControlStateNormal];
        
    self.cellPhoneTextField.textColor = [UIColor firstGrey];
    self.smsTextField.textColor = [UIColor firstGrey];
    
    //取得檔案路徑
    NSString *path = [[NSBundle mainBundle] pathForResource:@"codebeautify" ofType:@"json"];
    NSString *response = [NSString stringWithContentsOfFile: path encoding: NSUTF8StringEncoding error:nil];
    country = [NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error: nil][@"item"];
    NSLog(@"%@", country);
    
    UITapGestureRecognizer *doBegan = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showbar)];
    [self.countryCodeLabel addGestureRecognizer: doBegan];
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

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - IBAction Methods
- (IBAction)backBtnPress:(id)sender {
    //[self.navigationController popViewControllerAnimated: YES];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav popViewControllerAnimated: YES];
}

#pragma mark - IBAction Methods
//發送驗證碼
-(IBAction)cellapi:(id)sender{
    if ([self.cellPhoneTextField.text isEqualToString:@""]) {
        //meeage=NSLocalizedString(@"RegText-tip", @"");
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor thirdPink];
        
        [self.view makeToast: @"行動裝置號碼不能為空"
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
        
        self.cellPhoneView.backgroundColor = [UIColor thirdPink];
        return;
    }
    
    NSString *countrstr = [self.countryCodeLabel.text componentsSeparatedByString:@"+"][1];
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    NSString *emailStr = myData[@"email"];
    NSLog(@"response: %@", emailStr);
    __block typeof(self) wself = self;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI requsetsmspwd2:[NSString stringWithFormat:@"%@,%@", countrstr, self.cellPhoneTextField.text] Account: emailStr];
        
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
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ChangeCellPhoneNumberViewController");
                    NSLog(@"cellapi");
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"requsetsmspwd2"];
                } else {
                    NSLog(@"Get Real Response");
                    NSLog(@"response: %@", response);
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    [wself processPWDRequestResult:dic];
                }
            }
        });
    });
}

- (void)processPWDRequestResult:(NSDictionary *)dic {
    if ([dic[@"result"] intValue] == 1) {
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor secondMain];
        
        [self.view makeToast: NSLocalizedString(@"RegText-successSent", @"")
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
        
        self.countDownLabel.hidden = NO;
        self.sendBtn.userInteractionEnabled = NO;
        [self.sendBtn setTitleColor: [UIColor secondGrey] forState: UIControlStateNormal];
        self.sendBtn.backgroundColor = [UIColor clearColor];
        self.sendBtn.layer.borderWidth = 1.0f;
        self.sendBtn.layer.borderColor = [UIColor secondGrey].CGColor;
        
        timeTick = 59;
        [timer invalidate];
        timer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self selector: @selector(tickForSMS) userInfo: nil repeats: YES];
    } else if ([dic[@"result"] intValue] == 0) {
        NSLog(@"失敗： %@", dic[@"message"]);
        if ([wTools objectExists: dic[@"message"]]) {
            [self showCustomErrorAlert: dic[@"message"]];
        } else {
            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
        }
    } else {
        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
    }
}

- (void)tickForSMS {
    NSLog(@"tick");
    
    if (timeTick == 0) {
        [timer invalidate];
        self.countDownLabel.hidden = YES;
        self.sendBtn.userInteractionEnabled = YES;
        [self.sendBtn setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
        self.sendBtn.backgroundColor = [UIColor firstMain];
        self.sendBtn.layer.borderWidth = 0.0f;
        self.sendBtn.layer.borderColor = [UIColor clearColor].CGColor;
    } else {
        timeTick--;
        self.countDownLabel.text = [NSString stringWithFormat: @"剩餘 %ld 秒可再發送", (long)timeTick];
        NSLog(@"self.countDownLabel.text: %@", self.countDownLabel.text);
    }
}

//註冊
- (IBAction)downbtn:(id)sender {
    [selectTextField resignFirstResponder];
    
    if ([self.cellPhoneTextField.text isEqualToString: @""]) {
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor thirdPink];
        
        [self.view makeToast: @"行動裝置號碼不能為空"
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
        
        self.cellPhoneView.backgroundColor = [UIColor thirdPink];
        return;
    }
    
    if ([self.smsTextField.text isEqualToString: @""]) {
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor thirdPink];
        
        [self.view makeToast: NSLocalizedString(@"RegText-tipSMSPwd", @"")
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
        return;
    }
    // Store Data & Create Key-Value Data
    NSString *countrStr = [self.countryCodeLabel.text componentsSeparatedByString: @"+"][1];
    
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI updatecellphone: self.cellPhoneNumberLabel.text
                                                 new: [NSString stringWithFormat:@"%@,%@", countrStr, self.cellPhoneTextField.text]
                                                pass: self.smsTextField.text];
        
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
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ChangeCellPhoneNumberViewController");
                    NSLog(@"downBtn");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"updatecellphone"];
                } else {
                    NSLog(@"Get Real Response");
                    NSLog(@"response: %@", response);
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                        style.messageColor = [UIColor whiteColor];
                        style.backgroundColor = [UIColor secondMain];
                        
                        [self.view makeToast: NSLocalizedString(@"ProfileText-changeSuccess", @"")
                                    duration: 2.0
                                    position: CSToastPositionBottom
                                       style: style];
                        
                        //[self.navigationController popViewControllerAnimated:YES];
                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        [appDelegate.myNav popViewControllerAnimated: YES];
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

#pragma mark - Show SelectBar
- (void)showbar {
    NSLog(@"showbar");
    [wTools setStatusBarBackgroundColor: [UIColor clearColor]];
    
    SelectBarViewController *mv = [[SelectBarViewController alloc]initWithNibName:@"SelectBarViewController" bundle:nil];
    mv.data = country;
    //mv.delegate = self;
    mv.topViewController = self;
    [self wpresentPopupViewController:mv animated:YES completion:nil];
}

#pragma mark - SelectBar Delegate Method
- (void)SaveDataRow:(NSInteger)row {
    [wTools setStatusBarBackgroundColor: [UIColor whiteColor]];
    NSLog(@"SaveDataRow row: %ld", (long)row);
    self.countryCodeLabel.adjustsFontSizeToFitWidth = YES;
    self.countryCodeLabel.text = country[row];
}

- (void)cancelButtonPressed {
    NSLog(@"cancelButtonPressed");
    [wTools setStatusBarBackgroundColor: [UIColor whiteColor]];
}

#pragma mark - UITextField Delegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    selectTextField = textField;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    selectTextField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"textFieldShouldReturn");
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    //NSUInteger newLength = [textField.text length] + [string length] - range.length;
    NSString *resultString = [textField.text stringByReplacingCharactersInRange: range
                                                                     withString: string];
    
    if (self.cellPhoneTextField == textField) {
        if (![resultString isEqualToString: @""]) {
            self.cellPhoneView.backgroundColor = [UIColor thirdGrey];
        } else {
            self.cellPhoneView.backgroundColor = [UIColor thirdPink];
        }
    }
    
    if (self.smsTextField == textField) {
        if (![resultString isEqualToString: @""]) {
            self.smsView.backgroundColor = [UIColor thirdGrey];
        } else {
            self.smsView.backgroundColor = [UIColor thirdPink];
        }        
    }
    return YES;
}

#pragma mark - Notifications for Keyboard
- (void)addKeyboardNotification {
    NSLog(@"");
    NSLog(@"addKeyboardNotification");
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

#pragma mark -
- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSLog(@"keyboardWasShown");
    NSDictionary* info = [aNotification userInfo];
    NSLog(@"info: %@", info);
    
    // in iOS 11, the height of size of UIKeyboardFrameBeginUserInfoKey will be zero in second time
    // when keyboardWasshown method called
    //CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSLog(@"kbSize: %@", NSStringFromCGSize(kbSize));
    
    float textfy = [selectTextField superview].frame.origin.y;
    NSLog(@"textfy: %f", textfy);
    
    float textfh = [selectTextField superview].frame.size.height;
    NSLog(@"textfh: %f", textfh);
    
    float h = self.view.frame.size.height;
    NSLog(@"h: %f", h);
    
    float kh = kbSize.height;
    NSLog(@"kh: %f", kh);
    
    float height = (textfh + textfy) - (h - kh);
    NSLog(@"height: %f", height);
    
    if (height > 0) {
        NSLog(@"height > 0");
        NSLog(@"height: %f", height);
        
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, -height, self.view.frame.size.width, self.view.frame.size.height);
            NSLog(@"self.view.frame: %@", NSStringFromCGRect(self.view.frame));
        }];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    NSLog(@"keyboardWillBeHidden");
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
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
                  protocolName: (NSString *)protocolName {
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
            if ([protocolName isEqualToString: @"requsetsmspwd2"]) {
                [weakSelf cellapi: nil];
            } else if ([protocolName isEqualToString: @"updatecellphone"]) {
                [weakSelf downbtn: nil];
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
