//
//  retrievepasswordViewController.m
//  wPinpinbox
//
//  Created by Angus on 2015/10/20.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "retrievepasswordViewController.h"
#import "SelectBarViewController.h"
#import "UIViewController+CWPopup.h"
#import "UICustomLineLabel.h"
#import "wTools.h"
#import "boxAPI.h"

#import "UIColor+Extensions.h"
#import "UIView+Toast.h"
#import "CustomIOSAlertView.h"
#import "NSString+emailValidation.h"
#import "AppDelegate.h"

#import "GlobalVars.h"
#import "UIViewController+ErrorAlert.h"

@interface retrievepasswordViewController () <UITextFieldDelegate, SelectBarDelegate, UIGestureRecognizerDelegate> {
    UITextField *selectText;
    NSArray *country;
    __weak IBOutlet UILabel *countryLabel;
    __weak IBOutlet UITextField *phone;
    __weak IBOutlet UITextField *emaillab;
    __weak IBOutlet UICustomLineLabel *titlelab;
    __weak IBOutlet UIButton *navBackBtn;
    __weak IBOutlet UIButton *sendBtn;
    __weak IBOutlet UIView *countryCodeView;
    __weak IBOutlet UIView *mobilePhoneView;
    __weak IBOutlet UIView *emailView;
}
@property (nonatomic) DGActivityIndicatorView *activityIndicatorView;
@end

@implementation retrievepasswordViewController

#pragma mark - View Related Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.delegate = self;
    
    [self initActivityIndicatorView];
    [self viewSetup];
    [self navBarBtnSetup];
    [self inputFieldSetup];
    
    titlelab.lineType=LineTypeDown;
    titlelab.text=NSLocalizedString(@"ForgetPwdText-forgetPwd", @"");
    //取得檔案路徑
    NSString *path = [[NSBundle mainBundle] pathForResource:@"codebeautify" ofType:@"json"];
    NSString *respone = [NSString stringWithContentsOfFile: path
                                                encoding: NSUTF8StringEncoding
                                                   error: nil];
    country = [NSJSONSerialization JSONObjectWithData: [respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error: nil][@"item"];
    
    //add gest.
    UITapGestureRecognizer *doBegan = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showbar)];
    [countryLabel addGestureRecognizer: doBegan];
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

- (void)initActivityIndicatorView {
    self.activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType: DGActivityIndicatorAnimationTypeDoubleBounce tintColor: [UIColor secondMain] size: kActivityIndicatorViewSize];
    self.activityIndicatorView.frame = CGRectMake(0.0f, 0.0f, 50.0f, 50.0f);
    self.activityIndicatorView.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
    [self.view addSubview: self.activityIndicatorView];
}

- (void)viewSetup {
    countryCodeView.layer.cornerRadius = kCornerRadius;
    countryCodeView.backgroundColor = [UIColor thirdGrey];
    mobilePhoneView.layer.cornerRadius = kCornerRadius;
    mobilePhoneView.backgroundColor = [UIColor thirdGrey];
    emailView.layer.cornerRadius = kCornerRadius;
    emailView.backgroundColor = [UIColor thirdGrey];
    sendBtn.layer.cornerRadius = kCornerRadius;
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
    emaillab.textColor = [UIColor firstGrey];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches
           withEvent:(UIEvent *)event {
    [self.view endEditing: YES];
}

#pragma mark - Show SelectBar
- (void)showbar {
    [wTools setStatusBarBackgroundColor: [UIColor clearColor]];
    SelectBarViewController *mv = [[SelectBarViewController alloc] initWithNibName:@"SelectBarViewController" bundle:nil];
    mv.data = country;
    mv.delegate = self;
    mv.topViewController = self;
    [self wpresentPopupViewController:mv animated:YES completion:nil];
}

#pragma mark - SelectBar Delegate Method
- (void)SaveDataRow:(NSInteger)row {
    [wTools setStatusBarBackgroundColor: [UIColor whiteColor]];
    countryLabel.adjustsFontSizeToFitWidth = YES;
    countryLabel.text = country[row];
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
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)downbtn:(id)sender {
    [self.view endEditing: YES];
    NSString *msg = @"";
    
    if ([phone.text isEqualToString:@""]) {
        NSLog(@"請填手機號碼");
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
    if ([emaillab.text isEqualToString:@""]) {
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
    }
    if (![msg isEqualToString:@""]) {
        /*
        Remind *rv = [[Remind alloc] initWithFrame: self.view.bounds];
        [rv addtitletext: msg];
        [rv addBackTouch];
        [rv showView: self.view];
        
        return;
         */
    }
    
    NSString *countrstr = [countryLabel.text componentsSeparatedByString:@"+"][1];
    
    @try {
        [self.activityIndicatorView startAnimating];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    
    NSString *phoneStr = phone.text;
    NSString *emailStr = emaillab.text;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSString *response = [boxAPI retrievepassword:[NSString stringWithFormat:@"%@,%@", countrstr, phoneStr] Account: emailStr];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [self.activityIndicatorView stopAnimating];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog( @"NSException caught" );
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason );
                return;
            }
            if (response != nil) {
                NSLog(@"%@", response);
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ViewController");
                    NSLog(@"retrievepassword");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"retrievepassword"];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                        style.messageColor = [UIColor whiteColor];
                        style.backgroundColor = [UIColor secondMain];
                        
                        [self.view makeToast: NSLocalizedString(@"ForgetPwdText-pwdSent", @"")
                                    duration: 2.0
                                    position: CSToastPositionBottom
                                       style: style];
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
            }
        });
    });
}

#pragma mark - UITextField Delegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    selectText = textField;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    selectText = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    NSString *resultString = [textField.text stringByReplacingCharactersInRange: range
                                                                     withString: string];
    
    NSLog(@"resultString: %@", resultString);
    NSLog(@"textField.text: %@", textField.text);
    
    if (phone == textField) {
        NSRange textFieldRange = NSMakeRange(0, [textField.text length]);
        
        if (NSEqualRanges(range, textFieldRange) && [string length] == 0) {
            NSLog(@"no text");
            mobilePhoneView.backgroundColor = [UIColor thirdPink];
        } else {
            NSLog(@"has text");
            mobilePhoneView.backgroundColor = [UIColor thirdGrey];
        }
        /*
        NSString *resultString = [textField.text stringByReplacingCharactersInRange: range
                                                                         withString: string];
        
        if (![resultString isEqualToString: @""]) {
            mobilePhoneView.backgroundColor = [UIColor thirdGrey];
        } else {
            mobilePhoneView.backgroundColor = [UIColor thirdPink];
        }
        */
    }
    
    if (emaillab == textField) {
        if ([resultString isEmailValid]) {
            emailView.backgroundColor = [UIColor thirdGrey];
        } else {
            emailView.backgroundColor = [UIColor thirdPink];
        }
    }
    
    /*
    if (![resultString isEqualToString: @""]) {
        mobilePhoneView.backgroundColor = [UIColor thirdGrey];
    } else {
        mobilePhoneView.backgroundColor = [UIColor thirdPink];
    }
    */
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
    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    float textfy = [selectText superview].frame.origin.y;
    float textfh = [selectText superview].frame.size.height;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
    [alertTimeOutView setContentViewWithMsg:msg contentBackgroundColor:[UIColor darkMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
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
    //[wTools setStatusBarBackgroundColor:[UIColor clearColor]];
    [alertTimeOutView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertTimeOutView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertTimeOutView tag]);
        [weakAlertTimeOutView close];
        //[wTools setStatusBarBackgroundColor:[UIColor whiteColor]];
        if (buttonIndex == 0) {            
        } else {
            if ([protocolName isEqualToString: @"retrievepassword"]) {
                [weakSelf downbtn: nil];
            }
        }
    }];
    [alertTimeOutView setUseMotionEffects: YES];
    [alertTimeOutView show];
}
@end
