//
//  ChangePwdViewController.m
//  wPinpinbox
//
//  Created by David on 5/14/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "ChangePwdViewController.h"
#import "wTools.h"
#import "boxAPI.h"
#import "NSString+passwordValidation.h"
#import "UIColor+Extensions.h"
#import "UIView+Toast.h"
#import "CustomIOSAlertView.h"
#import "GlobalVars.h"

#import "AppDelegate.h"
#import "UIViewController+ErrorAlert.h"
#import "UserInfo.h"

@interface ChangePwdViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate> {
    UITextField *selectText;
}

@property (weak, nonatomic) IBOutlet UITextField *currentPwdTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField1;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField2;
@property (weak, nonatomic) IBOutlet UILabel *pwdCheckLabel1;
@property (weak, nonatomic) IBOutlet UILabel *pwdCheckLabel2;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;

@property (weak, nonatomic) IBOutlet UIView *currentPwdView;
@property (weak, nonatomic) IBOutlet UIView *pwdView1;
@property (weak, nonatomic) IBOutlet UIView *pwdView2;

@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarHeight;

@end

@implementation ChangePwdViewController

#pragma mark - View Related Methods
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

- (void)initialValueSetup {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    self.navBarView.backgroundColor = [UIColor barColor];
    
    self.currentPwdTextField.textColor = [UIColor firstGrey];
    self.pwdTextField1.textColor = [UIColor firstGrey];
    self.pwdTextField2.textColor = [UIColor firstGrey];
    
    self.currentPwdView.layer.cornerRadius = kCornerRadius;
    self.currentPwdView.backgroundColor = [UIColor thirdGrey];
    self.pwdView1.layer.cornerRadius = kCornerRadius;
    self.pwdView1.backgroundColor = [UIColor thirdGrey];
    self.pwdView2.layer.cornerRadius = kCornerRadius;
    self.pwdView2.backgroundColor = [UIColor thirdGrey];
    
    self.pwdCheckLabel1.hidden = YES;
    self.pwdCheckLabel2.hidden = YES;
    
    self.sendBtn.layer.cornerRadius = kCornerRadius;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"textFieldDidBeginEditing");
    selectText = textField;
    
    if (selectText.tag == 1) {
        selectText.returnKeyType = UIReturnKeyNext;
    }
    if (selectText.tag == 2) {
        selectText.returnKeyType = UIReturnKeyNext;
    }
    if (selectText.tag == 3) {
        selectText.returnKeyType = UIReturnKeyDone;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"textFieldDidEndEditing");
    selectText = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"textFieldShouldReturn");
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder *nextResponder = [textField.superview.superview viewWithTag: nextTag];
    
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard
        [textField resignFirstResponder];
    }
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    NSLog(@"shouldChangeCharactersInRange");
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    NSString *resultString = [textField.text stringByReplacingCharactersInRange: range
                                                                     withString: string];
    //NSString *regExPattern = @"[a-zA-Z0-8]*";
    NSString *regExPattern = @"^[a-zA-Z0-9]{8,24}$";
    BOOL bIsInputValid = [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", regExPattern]
                          evaluateWithObject: resultString];
    
    NSLog(@"resultString: %@", resultString);

    if (self.currentPwdTextField == textField) {
        NSLog(@"self.currentPwdTextField.text: %@", self.currentPwdTextField.text);
        NSRange textFieldRange = NSMakeRange(0, [textField.text length]);
        
        if (NSEqualRanges(range, textFieldRange) && [string length] == 0) {
            NSLog(@"no text");
            self.currentPwdView.backgroundColor = [UIColor thirdPink];
        } else {
            NSLog(@"has text");
            self.currentPwdView.backgroundColor = [UIColor thirdGrey];
        }
    }
    if (self.pwdTextField1 == textField) {
        NSLog(@"self.pwdTextField1.text: %@", self.pwdTextField1);
        
        if (newLength >= 8) {
            NSLog(@"newLength: %lu", (unsigned long)newLength);
            
            if (bIsInputValid) {
                NSLog(@"bIsInputValid: %d", bIsInputValid);
                self.pwdView1.backgroundColor = [UIColor thirdGrey];
                self.pwdCheckLabel1.hidden = NO;
            } else {
                NSLog(@"bIsInputValid: %d", bIsInputValid);
                self.pwdView1.backgroundColor = [UIColor thirdPink];
                self.pwdCheckLabel1.hidden = YES;
            }
        } else {
            NSLog(@"newLength: %lu", (unsigned long)newLength);
            self.pwdView1.backgroundColor = [UIColor thirdPink];
            self.pwdCheckLabel1.hidden = YES;
        }
    }
    
    if (self.pwdTextField2 == textField) {
        NSLog(@"self.pwdTextField1.text: %@", self.pwdTextField1.text);
        NSLog(@"self.pwdTextField2.text: %@", self.pwdTextField2.text);
        
        if ([resultString isEqualToString: self.pwdTextField1.text]) {
            self.pwdView2.backgroundColor = [UIColor thirdGrey];
            self.pwdCheckLabel2.hidden = NO;
        } else {
            self.pwdView2.backgroundColor = [UIColor thirdPink];
            self.pwdCheckLabel2.hidden = YES;
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
    
    float textfy = [selectText superview].frame.origin.y;
    NSLog(@"textfy: %f", textfy);
    
    float textfh = [selectText superview].frame.size.height;
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

#pragma mark - IBAction Method

- (IBAction)backbtnPress:(id)sender {
    //[self.navigationController popViewControllerAnimated:YES];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav popViewControllerAnimated: YES];
}

- (IBAction)sendBtnPress:(id)sender {
    NSLog(@"sendBtnPress");
    NSLog(@"");
    NSLog(@"self.currentPwdTextField.text: %@", self.currentPwdTextField.text);
    NSLog(@"self.pwdTextField1.text: %@", self.pwdTextField1.text);
    NSLog(@"self.pwdTextField2.text: %@", self.pwdTextField2.text);
    
    if ([self.currentPwdTextField.text isEqualToString: @""]) {
        NSLog(@"");
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor thirdPink];
        
        [self.view makeToast: @"請輸入密碼"
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
        self.currentPwdView.backgroundColor = [UIColor thirdPink];
        
        return;
    }
    
    if ([self.pwdTextField1.text isEqualToString: @""]) {
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor thirdPink];
        
        [self.view makeToast: @"還沒設定密碼"
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
        self.pwdView1.backgroundColor = [UIColor thirdPink];
        
        return;
    } else {
        if (![self.pwdTextField1.text isPasswordValid]) {
            CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
            style.messageColor = [UIColor whiteColor];
            style.backgroundColor = [UIColor thirdPink];
            
            [self.view makeToast: @"密碼至少8個字元唷"
                        duration: 2.0
                        position: CSToastPositionBottom
                           style: style];
            self.pwdView1.backgroundColor = [UIColor thirdPink];
            
            return;
        }
    }
    
    if ([self.pwdTextField2.text isEqualToString: @""]) {
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor thirdPink];
        
        [self.view makeToast: @"密碼至少8個字元唷"
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
        self.pwdView2.backgroundColor = [UIColor thirdPink];
        
        return;
    } else if (![self.pwdTextField2.text isEqualToString: self.pwdTextField1.text]) {
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor thirdPink];
        
        [self.view makeToast: @"兩次密碼輸入不符"
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
        
        self.pwdView2.backgroundColor = [UIColor thirdPink];
        
        return;
    }
    
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    
    NSString *userPwd = [userPrefs objectForKey: @"pwd"];
    NSLog(@"pwd: %@", [userPrefs objectForKey: @"pwd"]);
    
    if (![self.currentPwdTextField.text isEqualToString: userPwd]) {
        NSLog(@"用戶的密碼錯誤");
        [self showCustomErrorAlert: @"用戶的密碼錯誤"];
        return;
    }
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *response = [boxAPI updatepwd: [wTools getUserID]
                                         token: [wTools getUserToken]
                                        oldpwd: self.currentPwdTextField.text
                                        newpwd: self.pwdTextField2.text];
                
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
                NSLog(@"response from updatepwd: %@", response);
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ChangePwdViewController");
                    NSLog(@"sendBtnPress");
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"updatepwd"];
                } else {
                    NSLog(@"Get Real Response");
                }
                NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                
                if ([dic[@"result"] intValue] == 1) {
                    NSLog(@"更新成功");
                    if ([wTools objectExists: self.pwdTextField2.text]) {
                        NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
                        [userPrefs setObject: self.pwdTextField2.text forKey: @"pwd"];
                        [userPrefs synchronize];
                        
                        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                        style.messageColor = [UIColor whiteColor];
                        style.backgroundColor = [UIColor secondMain];
                        
                        [self.view makeToast: @"密碼更新成功"
                                    duration: 2.0
                                    position: CSToastPositionBottom
                                       style: style];
                        
                        //[self.navigationController popViewControllerAnimated:YES];
                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        [appDelegate.myNav popViewControllerAnimated: YES];
                    }
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
        });
    });
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
            if ([protocolName isEqualToString: @"updatepwd"]) {
                [weakSelf sendBtnPress: nil];
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
