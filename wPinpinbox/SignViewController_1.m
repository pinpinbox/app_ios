//
//  SignViewController_1.m
//  wPinpinbox
//
//  Created by Angus on 2015/8/7.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "SignViewController_1.h"
#import "UICustomLineLabel.h"

#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "wTools.h"
#import "boxAPI.h"
#import "SignViewController_3.h"
#import "UIViewController+CWPopup.h"

#import "NSString+emailValidation.h"
#import "NSString+passwordValidation.h"
#import "OpenUDID.h"

#import "VersionUpdate.h"

#import <SafariServices/SafariServices.h>

#import "UIColor+Extensions.h"
#import "UIView+Toast.h"
#import "MBProgressHUD.h"
#import "CustomIOSAlertView.h"

#import "GlobalVars.h"

#import "AppDelegate.h"

#import "UIViewController+ErrorAlert.h"

typedef void (^FBBlock)(void);

//static NSString *pinpinbox = @"https://www.pinpinbox.com/";

@interface SignViewController_1 () <UITextFieldDelegate, UIGestureRecognizerDelegate>
{
//    __weak IBOutlet UICustomLineLabel *titlelab;
    
    UITextField *selectText;
    
    __weak IBOutlet UIView *nickNameView;
    __weak IBOutlet UIView *emailView;
    __weak IBOutlet UIView *pwdView1;
    __weak IBOutlet UIView *pwdView2;
    
    __weak IBOutlet UITextField *name;
    __weak IBOutlet UITextField *email;
    __weak IBOutlet UITextField *pwd1;
    __weak IBOutlet UITextField *pwd2;
    
    BOOL NextView;
    FBBlock _alertOkHandler;
    NSString *main;    
    
    __weak IBOutlet UIButton *emailBtn;        
    __weak IBOutlet UILabel *pwd1CheckLabel;
    __weak IBOutlet UILabel *pwd2CheckLabel;
}
@end

@implementation SignViewController_1

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing: YES];
}

//規範
/*
- (IBAction)TERMSbtn:(id)sender
{
    NSString *termStr = @"https://www.pinpinbox.com/index/index/terms";
    NSURL *url = [NSURL URLWithString: termStr];
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL: url entersReaderIfAvailable: NO];
    safariVC.preferredBarTintColor = [UIColor whiteColor];
    [self presentViewController: safariVC animated: YES completion: nil];
}
 */

#pragma mark - View Related Method

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"SignViewController_1");
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.delegate = self;
    
    [self navBarBtnSetup];
    [self nextBtnSetup];
    [self inputFieldSetup];
    
    main = @"Main";
    CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
    
    //判斷3.5吋或4吋螢幕以載入不同storyboard
    if (iOSDeviceScreenSize.height == 480)
    {
        main = @"Main35";
    }
    
//    titlelab.lineType = LineTypeDown;
//    titlelab.text = NSLocalizedString(@"RegText-applyAccount", @"");
    
    
    
//    labtip.text = NSLocalizedString(@"RegText-tipAgreement", @"");
//    [btn_btntip setTitle: NSLocalizedString(@"RegText-tipAgreementTitle", @"")
//                forState: UIControlStateNormal];
    
    
    // Do any additional setup after loading the view.
    
    [pwd1 addTarget: self action: @selector(checkPwd1:) forControlEvents: UIControlEventEditingChanged];
    [pwd2 addTarget: self action: @selector(checkPwd2:) forControlEvents: UIControlEventEditingChanged];
    
    // Email Check Button Configuration
    emailBtn.layer.cornerRadius = 10;
    emailBtn.clipsToBounds = YES;
    [emailBtn addTarget: self action: @selector(checkValidity:) forControlEvents: UIControlEventTouchUpInside];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self addKeyboardNotification];
    
    NextView = NO;
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

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Setup
- (void)nextBtnSetup {
    nextBtn.layer.cornerRadius = 8;
    nextBtn.backgroundColor = [UIColor firstMain];
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
    name.textColor = [UIColor firstGrey];
    email.textColor = [UIColor firstGrey];
    pwd1.textColor = [UIColor firstGrey];
    pwd2.textColor = [UIColor firstGrey];
    
    nickNameView.layer.cornerRadius = kCornerRadius;
    emailView.layer.cornerRadius = kCornerRadius;
    pwdView1.layer.cornerRadius = kCornerRadius;
    pwdView2.layer.cornerRadius = kCornerRadius;
    
    pwd1CheckLabel.hidden = YES;
    pwd2CheckLabel.hidden = YES;
}

#pragma mark - Selector Methods

// Check the value of password field 1 is valid
- (void)checkPwd1: (id)sender
{
    UITextField *textField = (UITextField *)sender;
    
    if ([textField.text length] >= 8 && [textField.text length] <= 18) {
        //pwdbtn1.imageView.image = [UIImage imageNamed: @"icon_v_click.png"];
    } else {
        //pwdbtn1.imageView.image = [UIImage imageNamed: @"icon_v.png"];
    }
}

// Check the value of password field 2 is valid
- (void)checkPwd2: (id)sender
{
    UITextField *textField = (UITextField *)sender;
    
    if ([textField.text length] >= 8 && [textField.text length] <= 18) {
        //pwdbtn2.imageView.image = [UIImage imageNamed: @"icon_v_click.png"];
    } else {
        //pwdbtn2.imageView.image = [UIImage imageNamed: @"icon_v.png"];
    }
}

// Check Email is valid or not
- (void)checkValidity: (id)sender
{
    // Hide keyboard
    [self.view endEditing: YES];
    
    if (![boxAPI hostAvailable: pinpinbox]) {
        [self showCustomErrorAlert: @"沒有網路 請重新檢查連線"];
        
        /*
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        Remind *rv = [[Remind alloc] initWithFrame: app.menu.view.bounds];
        [rv addtitletext: @"沒有網路 請重新檢查連線"];
        [rv addBackTouch];
        [rv showView: app.menu.view];
        */
        return;
    }
    
    // If Email Field is invalid then message got data
    if ([email.text isEqualToString: @""]) {
        NSLog(@"信箱好像還沒填");
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor thirdPink];
        
        [self.view makeToast: NSLocalizedString(@"RegText-empEmail", @"")
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
        
        emailView.backgroundColor = [UIColor thirdPink];
        
        return;
    } else if (![email.text isEmailValid]) {
        // If Email Field is invalid then message got data
        NSLog(@"信箱格式出了點問題");
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor thirdPink];
        
        [self.view makeToast: NSLocalizedString(@"RegText-wrongEmail", @"")
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
        
        emailView.backgroundColor = [UIColor thirdPink];
        
        return;
    } else {
        NSLog(@"Check with Server");
        @try {
            [MBProgressHUD showHUDAddedTo: self.view animated:YES];
        } @catch (NSException *exception) {
            // Print exception information
            NSLog( @"NSException caught" );
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
            return;
        }
        
        NSString *emailStr = email.text;
        __block typeof(emailBtn) btn = emailBtn;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
            //BOOL response = [boxAPI check: @"account" checkValue: email.text];
            NSString *response = [boxAPI check: @"account" checkValue: emailStr];
            
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
                    NSLog(@"response from check checkValue");
                    NSLog(@"response: %@", response);
                    
                    if ([response isEqualToString: timeOutErrorCode]) {
                        NSLog(@"Time Out Message Return");
                        NSLog(@"SignViewController_1");
                        NSLog(@"checkValidity");
                        
                        [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                        protocolName: @"checkValue"];
                    } else {
                        NSLog(@"Get Real Response");
                        
                        NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                        
                        if ([dic[@"result"] boolValue]) {
                            NSLog(@"dic result boolValue is 1");
                            NSLog(@"check成功");
                            
                            // Change Button
                            btn.backgroundColor = [UIColor clearColor];
                            [btn setTitle: @"OK" forState: UIControlStateNormal];
                            [btn setTitleColor: [UIColor firstMain] forState: UIControlStateNormal];
                            btn.userInteractionEnabled = NO;
                        } else {                                                        
                            NSLog(@"失敗： %@", dic[@"message"]);
                            if ([wTools objectExists: dic[@"message"]]) {
                                [self showCustomErrorAlert: dic[@"message"]];
                            } else {
                                [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                            }
                        }
                    }
                } else {
                    NSLog(@"check失敗");
                    [self showCustomErrorAlert: @"帳號已經存在，請使用另一個"];
                }
            });
        });
    }
}

#pragma mark - Custom Error Alert Method
- (void)showCustomErrorAlert: (NSString *)msg {
    [UIViewController showCustomErrorAlertWithMessage:msg onButtonTouchUpBlock:^(CustomIOSAlertView *customAlertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[customAlertView tag]);
        [customAlertView close];
    }];
}

#pragma mark - IBAction Methods
- (IBAction)back:(id)sender {
    //[self.navigationController popViewControllerAnimated:YES];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav popViewControllerAnimated: YES];
}

- (IBAction)signbtn:(id)sender {
    NSLog(@"signbtn");
    NSString *msg = @"";
    NSLog(@"name");
    
    // If Name Field is empty then message got data
    if ([name.text isEqualToString: @""]) {
        NSLog(@"暱稱好像還沒填");
        
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor thirdPink];
        
        [self.view makeToast: NSLocalizedString(@"RegText-empNickname", @"")
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
        
        nickNameView.backgroundColor = [UIColor thirdPink];
        
        return;
    }
    
    NSLog(@"email");
    
    // If Email Field is empty then message got data
    if ([email.text isEqualToString: @""]) {
        NSLog(@"信箱好像還沒填");
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor thirdPink];
        
        [self.view makeToast: NSLocalizedString(@"RegText-empEmail", @"")
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
        
        emailView.backgroundColor = [UIColor thirdPink];
        
        return;
    } else if (![email.text isEmailValid]) {
        NSLog(@"信箱格式出了點問題");
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor thirdPink];
        
        [self.view makeToast: NSLocalizedString(@"RegText-wrongEmail", @"")
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
        
        emailView.backgroundColor = [UIColor thirdPink];
        
        return;
    }
    
    NSLog(@"password");
    
    NSLog(@"pwd1.text: %@", pwd1.text);
    NSLog(@"pwd2.text: %@", pwd2.text);
    
    // If Password Field is empty then message got data
    if ([pwd1.text isEqualToString: @""]) {
        NSLog(@"還沒設定密碼");
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor thirdPink];
        
        [self.view makeToast: NSLocalizedString(@"RegText-empPwd", @"")
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
        
        pwdView1.backgroundColor = [UIColor thirdPink];
        
        return;
    } else if (![pwd1.text isPasswordValid]) {
        NSLog(@"pw1.text 密碼至少8個字元唷");
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor thirdPink];
        
        [self.view makeToast: NSLocalizedString(@"RegText-wrongPwd", @"")
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
        
        pwdView1.backgroundColor = [UIColor thirdPink];
        
        return;
    } else if (![pwd2.text isPasswordValid]) {
        NSLog(@"pwd2.text 密碼至少8個字元唷");
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor thirdPink];
        
        [self.view makeToast: NSLocalizedString(@"RegText-wrongPwd", @"")
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
        pwdView2.backgroundColor = [UIColor thirdPink];
        
        return;
    } else if (![pwd2.text isEqualToString: pwd1.text]) {
        NSLog(@"兩次密碼輸入不符");
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor thirdPink];
        
        [self.view makeToast: NSLocalizedString(@"RegText-diffPwd", @"")
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
        
        pwdView2.backgroundColor = [UIColor thirdPink];
        
        return;
    }
    // If message is not empty, that means there are some error messages in message
    if (![msg isEqualToString: @""]) {
        
        NSLog(@"message: %@", msg);
        
        /*
        // Remind: Alert Message Function
        Remind *rv = [[Remind alloc] initWithFrame: self.view.bounds];
        [rv addtitletext: msg];
        [rv addBackTouch];
        [rv showView: self.view];
         */
        return;
    }
    
    // Store the User Preferences
    NSMutableDictionary *tmp = [NSMutableDictionary new];
    [tmp setObject: name.text forKey: @"name"];
    [tmp setObject: email.text forKey: @"email"];
    [tmp setObject: pwd1.text forKey: @"pwd"];
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    
    if ([userPrefs objectForKey: @"tmp"] ) {
        [userPrefs removeObjectForKey: @"tmp"];
    }
    [userPrefs setObject: tmp forKey: @"tmp"];
    
    
    //註冊去
    SignViewController_3 *sv3 = [[UIStoryboard storyboardWithName: @"SignVC_3"
                                                           bundle: nil]
                                 instantiateViewControllerWithIdentifier: @"SignViewController_3"];
    
    //[self.navigationController pushViewController: sv3 animated: YES];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav pushViewController: sv3 animated: YES];
}

#pragma mark - UITextFieldDelegate Methods

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"textFieldDidBeginEditing");
    
    selectText = textField;
    
    if (selectText.tag == 1) {
        selectText.returnKeyType = UIReturnKeyNext;
    }
    if (selectText.tag == 2) {
        selectText.returnKeyType = UIReturnKeyNext;
    }
    if (selectText.tag == 3) {
        selectText.returnKeyType = UIReturnKeyNext;
    }
    if (selectText.tag == 4) {
        selectText.returnKeyType = UIReturnKeyDone;
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"textFieldDidEndEditing");

    selectText = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"textFieldShouldReturn");

    NSLog(@"pwd1.text: %@", pwd1.text);
    
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
replacementString:(NSString *)string
{
    NSLog(@"shouldChangeCharactersInRange");
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    NSString *resultString = [textField.text stringByReplacingCharactersInRange: range
                                                                     withString: string];
    
    NSString *regExPattern = @"[a-zA-Z0-8]*";
    BOOL bIsInputValid = [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", regExPattern]
                          evaluateWithObject: resultString];
    
    NSLog(@"resultString: %@", resultString);
    
    if (name == textField) {
        NSLog(@"name.text: %@", name.text);
        
        NSRange textFieldRange = NSMakeRange(0, [textField.text length]);
        
        if (NSEqualRanges(range, textFieldRange) && [string length] == 0) {
            NSLog(@"no text");
            
            nickNameView.backgroundColor = [UIColor thirdPink];
        } else {
            NSLog(@"has text");
            
            nickNameView.backgroundColor = [UIColor thirdGrey];
        }
    }
    
    if (email == textField) {
        NSLog(@"email.text: %@", email.text);
        NSLog(@"resultString: %@", resultString);
        
        if ([resultString isEmailValid]) {
            NSLog(@"email.text Email is Valid");
            emailView.backgroundColor = [UIColor thirdGrey];
        } else {
            NSLog(@"email.text Email is not Valid");
            emailView.backgroundColor = [UIColor thirdPink];
        }
        
        // emailBtn Setting
        emailBtn.backgroundColor = [UIColor firstMain];
        [emailBtn setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
        [emailBtn setTitle: @"檢 查" forState: UIControlStateNormal];
        emailBtn.layer.cornerRadius = 10;
        emailBtn.clipsToBounds = YES;
        [emailBtn addTarget: self action: @selector(checkValidity:) forControlEvents: UIControlEventTouchUpInside];
        emailBtn.userInteractionEnabled = YES;
    }
    
    if (pwd1 == textField) {
        NSLog(@"pwd1.text: %@", pwd1.text);
        
        if (newLength >= 8) {
            if (bIsInputValid) {
                pwdView1.backgroundColor = [UIColor thirdGrey];
                pwd1CheckLabel.hidden = NO;
            } else {
                pwdView1.backgroundColor = [UIColor thirdPink];
                pwd1CheckLabel.hidden = YES;
            }
        } else {
            pwdView1.backgroundColor = [UIColor thirdPink];
            pwd1CheckLabel.hidden = YES;
        }
    }
    
    if (pwd2 == textField) {
        NSLog(@"pwd1.text: %@", pwd1.text);
        NSLog(@"pwd2.text: %@", pwd2.text);
        
        if (newLength >= 8) {
            if (bIsInputValid) {
                if ([resultString isEqualToString: pwd1.text]) {
                    pwdView2.backgroundColor = [UIColor thirdGrey];
                    pwd2CheckLabel.hidden = NO;
                } else {
                    pwdView2.backgroundColor = [UIColor thirdPink];
                    pwd2CheckLabel.hidden = YES;
                }
            } else {
                pwdView2.backgroundColor = [UIColor thirdPink];
                pwd2CheckLabel.hidden = YES;
            }
        } else {
            pwdView2.backgroundColor = [UIColor thirdPink];
            pwd2CheckLabel.hidden = YES;
        }
        
        /*
        if (![wTools pwd:resultString]) {
            pwdbtn2.selected = NO;
            return YES;
        }
        
        if (newLength >= 8) {
            if ([resultString isEqualToString:pwd1.text]) {
                pwdbtn2.selected = YES;
            }else{
                pwdbtn2.selected = NO;
            }
            
        }else{
            pwdbtn2.selected = NO;
        }
         */
    }
    
    return YES;
}

#pragma mark - Keyboard Notification
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
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIKeyboardDidShowNotification
                                                  object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIKeyboardWillHideNotification
                                                  object: nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
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

#pragma mark -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    
    
    NextView=YES;
    
    return NextView;
}

#pragma mark -
#pragma mark FaceBook SDK Delegate Methods

- (void)loginAndRequestPermissionsWithSuccessHandler:(FBBlock) successHandler
                           declinedOrCanceledHandler:(FBBlock) declinedOrCanceledHandler
                                        errorHandler:(void (^)(NSError *)) errorHandler{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    //public_profile
    //publish_actions
    [login
     logInWithReadPermissions: @[@"public_profile"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         
         if (error) {
             if (errorHandler) {
                 errorHandler(error);
             }
             return;
         }
         
         if ([FBSDKAccessToken currentAccessToken] &&
             [[FBSDKAccessToken currentAccessToken].permissions containsObject:@"public_profile"]) {
             
             if (successHandler) {
                 successHandler();
             }
             return;
         }
         
         if (declinedOrCanceledHandler) {
             declinedOrCanceledHandler();
         }
     }];
}

- (void)alertDeclinedPublishActionsWithCompletion:(FBBlock)completion {
    /*
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Publish Permissions"
                                                        message:@"Publish permissions are needed to share game content automatically. Do you want to enable publish permissions?"
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Ok", nil];
    _alertOkHandler = [completion copy];
    [alertView show];
     */
}

#pragma mark - Custom Method for TimeOut
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
            if ([protocolName isEqualToString: @"checkValue"]) {
                [weakSelf checkValidity: nil];
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
