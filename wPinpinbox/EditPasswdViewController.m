//
//  EditPasswdViewController.m
//  wPinpinbox
//
//  Created by Angus on 2015/10/21.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "EditPasswdViewController.h"
#import "AsyncImageView.h"
#import "boxAPI.h"
#import "wTools.h"
#import "Remind.h"

#import "NSString+passwordValidation.h"

#define kOFFSET_FOR_KEYBOARD 80.0

@interface EditPasswdViewController () <UITextFieldDelegate>
{
    __weak IBOutlet AsyncImageView *topimage;
    
    __weak IBOutlet UITextField *t1;
    __weak IBOutlet UITextField *t2;
    __weak IBOutlet UITextField *t3;
    
    UITextField *selectText;
    NSDictionary *mydata;

    BOOL keyboardIsShown;
}
@property (weak, nonatomic) IBOutlet UIButton *okBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation EditPasswdViewController

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing: YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    mydata=[userPrefs objectForKey:@"profile"];
    
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: topimage];
    topimage.imageURL=[NSURL URLWithString:mydata[@"profilepic"]];
  
    if ([t1 respondsToSelector:@selector(setAttributedPlaceholder:)])
    {
        t1.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"ProfileText-currentPwd", @"") attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    }

    if ([t2 respondsToSelector:@selector(setAttributedPlaceholder:)])
    {
        t2.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"ProfileText-changePwd", @"") attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    }

    if ([t3 respondsToSelector:@selector(setAttributedPlaceholder:)])
    {
        t3.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"ProfileText-confirmPwd", @"") attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    }

    wtitle.text=NSLocalizedString(@"GeneralText-profile", @"");
    lab_text.text=NSLocalizedString(@"ProfileText-changePwd", @"");
    lab_ok.text=NSLocalizedString(@"GeneralText-pwd", @"");
    
    
    // Do any additional setup after loading the view from its nib.
    self.okBtn.layer.cornerRadius = self.okBtn.bounds.size.height / 2;
    self.okBtn.clipsToBounds = YES;
    self.okBtn.layer.masksToBounds = NO;
}

-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"viewWillAppear");
    
    [super viewWillAppear:animated];
    //[self registerForKeyboardNOtifications];
    [[topimage layer] setMasksToBounds:YES];
    [[topimage layer] setCornerRadius:topimage.bounds.size.height/2];
    
    NSLog(@"Registering for keyboard events");
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillShow:)
                                                 name: UIKeyboardWillShowNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillHide:)
                                                 name: UIKeyboardWillHideNotification
                                               object: nil];
    
    keyboardIsShown = NO;
    
    // make contentSize bigger than your scrollSize (you will need to figure out for your own use case)
    CGSize scrollContentsize = CGSizeMake(320, 345);
    self.scrollView.contentSize = scrollContentsize;
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"viewWillDisappear");
    [super viewWillDisappear:animated];
    
    NSLog(@"Unregistering for keyboard events");
    // unregister for keyboard notifications while not visible
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIKeyboardWillShowNotification
                                                  object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIKeyboardWillHideNotification
                                                  object: nil];
}

- (void)keyboardWillHide: (NSNotification *)n
{
    NSLog(@"keyboardWillHide");
    
    NSDictionary *userInfo = [n userInfo];
    
    // get the size of the keyboard
    CGSize keyboardSize = [[userInfo objectForKey: UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // resize the scrollView
    CGRect viewFrame = self.scrollView.frame;
    viewFrame.size.height += keyboardSize.height;
    
    [UIView beginAnimations: nil context: NULL];
    [UIView setAnimationBeginsFromCurrentState: YES];
    self.scrollView.frame = viewFrame;
    [UIView commitAnimations];
    
    keyboardIsShown = NO;
}

- (void)keyboardWillShow: (NSNotification *)n
{
    NSLog(@"keyboardWillShow");
    
    if (keyboardIsShown) {
        return;
    }
    
    NSDictionary *userInfo = [n userInfo];
    
    // get the size of the keyboard
    CGSize keyboardSize = [[userInfo objectForKey: UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // resize the scrollView
    CGRect viewFrame = self.scrollView.frame;
    viewFrame.size.height -= keyboardSize.height;
    
    [UIView beginAnimations: nil context: NULL];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [self.scrollView setFrame: viewFrame];
    [UIView commitAnimations];
    
    keyboardIsShown = YES;
}

//
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldDidBeginEditing");
    selectText = textField;
    
    textField.keyboardType = UIKeyboardTypeDefault;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    selectText = nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)OKbtn:(id)sender {
    
    NSString *msg = @"";
    
    if ([t1.text isEqualToString: @""]) {
        msg = NSLocalizedString(@"ProfileText-tipCurrentPwd", @"");
    } else if ([t2.text isEqualToString: @""]) {
        msg = NSLocalizedString(@"ProfileText-tipNewPwd", @"");
    } else if (![t2.text isPasswordValid]) {
        NSLog(@"密碼未滿8個或超過18個字元");
        msg = NSLocalizedString(@"RegText-wrongPwd", @"");
    } else if ([t1.text isEqualToString: t2.text]) {
        msg = NSLocalizedString(@"ProfileText-samePwd", @"");
    } else if ([t3.text isEqualToString: @""]) {
        msg = NSLocalizedString(@"ProfileText-tipNewPwd2", @"");
    } else if (![t2.text isEqualToString: t3.text]) {
        msg = NSLocalizedString(@"ProfileText-diffPwd", @"");
    }
            
    if (![msg isEqualToString:@""]) {
        Remind *rv = [[Remind alloc] initWithFrame: self.view.bounds];
        [rv addtitletext: msg];
        [rv addBackTouch];
        [rv showView: self.view];
        return;
    }
    
    
    [wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        BOOL respone=[boxAPI updatepwd:[wTools getUserID] token:[wTools getUserToken] oldpwd:t1.text newpwd:t2.text];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [wTools HideMBProgressHUD];
            
            if (respone) {
                NSLog(@"更新成功");
                [self.navigationController popViewControllerAnimated:YES];
//                Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
//                [rv editiamgetick];
//                [rv addtitletext:@"更新成功"];
//                [rv addBackTouch];
//                [rv showView:self.view];
                
            }else{
                NSLog(@"更新失敗");
                Remind *rv = [[Remind alloc] initWithFrame: self.view.bounds];
                [rv addtitletext: NSLocalizedString(@"ProfileText-changeFail", @"")];
                [rv addBackTouch];
                [rv showView: self.view];
            }
        });
    });
}

/*
-(void)registerForKeyboardNOtifications{
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSLog(@"keyboardWasShown");
    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    NSLog(@"kbSize: %@", NSStringFromCGSize(kbSize));
    
    float textfy = selectText.frame.origin.y;
    NSLog(@"textfy: %f", textfy);
    
    float textfh = selectText.frame.size.height;
    NSLog(@"textfh: %f", textfh);
    
    float h = self.view.frame.size.height;
    NSLog(@"h: %f", h);
    
    float kh = kbSize.height;
    NSLog(@"kh: %f", kh);
    
    float height = (textfh + textfy) - (h - kh);
    NSLog(@"height: %f", height);
    
    if (height > 0) {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, -height, self.view.frame.size.width, self.view.frame.size.height);
            NSLog(@"self.view.frame: %@", NSStringFromCGRect(self.view.frame));
        }];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSLog(@"keyboardWillBeHidden");
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        NSLog(@"self.view.frame: %@", NSStringFromCGRect(self.view.frame));
    }];
}
*/
@end
