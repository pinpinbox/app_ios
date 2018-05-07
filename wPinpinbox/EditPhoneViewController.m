//
//  EditPhoneViewController.m
//  wPinpinbox
//
//  Created by Angus on 2015/12/21.
//  Copyright © 2015年 Angus. All rights reserved.
//

#import "EditPhoneViewController.h"
#import "UIViewController+CWPopup.h"
#import "Remind.h"
#import "boxAPI.h"
#import "AppDelegate.h"

@interface EditPhoneViewController ()
{
    UITextField *selectText;
    NSArray *country;
    
    BOOL keyboardIsShown;
}
@end

@implementation EditPhoneViewController

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing: YES];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //[self registerForKeyboardNOtifications];
    // Do any additional setup after loading the view.
    
    lab_ok.text=NSLocalizedString(@"GeneralText-ok", @"");
    wtitle.text=NSLocalizedString(@"GeneralText-profile", @"");
    lab_text.text=NSLocalizedString(@"ProfileText-SMSvaild", @"");
    lab_text2.text=NSLocalizedString(@"ProfileText-tipNewCellPhone", @"");
    [btn_getvai setTitle:NSLocalizedString(@"ProfileText-getVaildCode", @"") forState:UIControlStateNormal];
    phonetv.placeholder=NSLocalizedString(@"GeneralText-cellphone", @"");
    //mstv.placeholder=NSLocalizedString(@"RegText-tipPwd", @"");
    mstv.placeholder = @"請 輸 入 驗 證 碼";
    
    mstv.layer.cornerRadius = mstv.layer.bounds.size.height / 2;
    mstv.layer.borderWidth = 1.0;
    
    for (UITextField *tf in textlields) {
        if ([tf respondsToSelector:@selector(setAttributedPlaceholder:)])
        {
            tf.attributedPlaceholder = [[NSAttributedString alloc] initWithString:tf.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
        }
    }
    
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *  mydata=[userPrefs objectForKey:@"profile"];
    
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: myphoto];
    myphoto.imageURL=[NSURL URLWithString:mydata[@"profilepic"]];
    
    //取得檔案路徑
    NSString *path = [[NSBundle mainBundle] pathForResource:@"codebeautify" ofType:@"json"];
    NSString *respone=[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    country=[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil][@"item"];
    UITapGestureRecognizer *doBegan=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showbar)];
    [countryLabel addGestureRecognizer:doBegan];
    
    // okBtn Setting
    self.okBtn.layer.cornerRadius = self.okBtn.bounds.size.height / 2;
    self.okBtn.clipsToBounds = YES;
    self.okBtn.layer.masksToBounds = NO;

}

-(void)showbar{
    SelectBarViewController *mv=[[SelectBarViewController alloc]initWithNibName:@"SelectBarViewController" bundle:nil];
    mv.data=country;
    mv.delegate=self;
    mv.topViewController=self;
    [self wpresentPopupViewController:mv animated:YES completion:nil];
}

-(void)SaveDataRow:(NSInteger)row{
    countryLabel.adjustsFontSizeToFitWidth=YES;
    countryLabel.text=country[row];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"_cellphoen: %@", _cellphoen);
    phonelab.text=_cellphoen;
    [[myphoto layer] setMasksToBounds:YES];
    [[myphoto layer]setCornerRadius:myphoto.bounds.size.height/2];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    selectText=textField;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    selectText=nil;
}


/*
-(void)registerForKeyboardNOtifications{
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    float textfy=[selectText superview].frame.origin.y;
    float textfh=[selectText superview].frame.size.height;
    float h=self.view.frame.size.height;
    float kh=kbSize.height;
    float height=(textfh+textfy)-(h-kh);
    
    if (height>0) {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame=CGRectMake(0, -height, self.view.frame.size.width, self.view.frame.size.height);
            
        }];
    }
    
    
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
}
*/

//發送驗證碼
-(IBAction)cellapi:(id)sender {
    NSString *meeage=@"";
    [selectText resignFirstResponder];
    
    NSString *str = phonelab.text;
    NSRange equalRange = [str rangeOfString: @"," options: NSBackwardsSearch];
    
    NSString *phoneStr;
    
    if (equalRange.location != NSNotFound) {
        phoneStr = [str substringFromIndex: equalRange.location + equalRange.length];
        NSLog(@"The result = %@", phoneStr);
    } else {
        NSLog(@"There is no = in the string");
    }
    
    if ([phonetv.text isEqualToString:@""]) {
        //meeage=NSLocalizedString(@"ProfileText-empData", @"");
        meeage = @"行動裝置號碼不能為空";
    } else if ([phoneStr isEqualToString: phonetv.text]) {
        NSLog(@"phonelab.text isEqualToString phonetv.text");
        meeage = @"新的電話號碼跟舊的電話號碼不能一樣";
    }
    
    if (![meeage isEqualToString:@""]) {
        Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
        [rv addtitletext:meeage];
        [rv addBackTouch];
        [rv showView:self.view];
        return ;
    }

    NSString *countrstr=[countryLabel.text componentsSeparatedByString:@"+"][1];
    
    [wTools ShowMBProgressHUD];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString * respone=[boxAPI requsetsmspwd2:[NSString stringWithFormat:@"%@,%@",countrstr,phonetv.text] Account:_email];
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];

            NSLog(@"%@",respone);
            NSDictionary *data= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            
            if ([data[@"result"]boolValue]) {
                Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
                [rv addtitletext:NSLocalizedString(@"ProfileText-successSent", @"")];
                [rv addBackTouch];
                [rv showView:self.view];
                
            }else{
                NSLog(@"Response from requsetsmspwd2");
                Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
                [rv addtitletext:data[@"message"]];
                [rv addBackTouch];
                [rv showView:self.view];
                NSLog(@"失敗：%@",data[@"message"]);
            }
        });
    });
}

- (IBAction)downbtn:(id)sender {
    NSLog(@"downbtn");
    
    [selectText resignFirstResponder];
    NSString *meeage=@"";
    
    NSLog(@"phonelab.text: %@", phonelab.text);
    
    NSString *str = phonelab.text;
    NSRange equalRange = [str rangeOfString: @"," options: NSBackwardsSearch];
    
    NSString *phoneStr;
    
    if (equalRange.location != NSNotFound) {
        phoneStr = [str substringFromIndex: equalRange.location + equalRange.length];
        NSLog(@"The result = %@", phoneStr);
    } else {
        NSLog(@"There is no = in the string");
    }
    
    if ([phonetv.text isEqualToString:@""]) {
        NSLog(@"phonetv.text is equal to empty");
        //meeage=NSLocalizedString(@"ProfileText-empData", @"");
        meeage = @"行動裝置號碼不能為空";
    } else if ([phoneStr isEqualToString: phonetv.text]) {
        NSLog(@"phonelab.text isEqualToString phonetv.text");
        meeage = @"新的電話號碼跟舊的電話號碼不能一樣";
    } else if ([mstv.text isEqualToString:@""]) {
        NSLog(@"phonetv.text is equal to empty");
        //meeage=NSLocalizedString(@"ProfileText-empData", @"");
        meeage = @"驗證碼不能是空的";
    }
    
    if (![meeage isEqualToString:@""]) {
        Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
        [rv addtitletext:meeage];
        [rv addBackTouch];
        [rv showView:self.view];
        return ;
    }

    NSString *countrstr=[countryLabel.text componentsSeparatedByString:@"+"][1];

    [wTools ShowMBProgressHUD];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString * respone=[boxAPI updatecellphone:phonelab.text new: [NSString stringWithFormat:@"%@,%@",countrstr,phonetv.text] pass:mstv.text];        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];

            NSLog(@"%@",respone);
            NSDictionary *data= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            
            if ([data[@"result"]boolValue]) {
                //_editview.cellphone.text=[NSString stringWithFormat:@"%@,%@",countrstr,phonetv.text];
                _editview.phoneNumberTextField.text = [NSString stringWithFormat:@"%@,%@",countrstr,phonetv.text];
                Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
                [rv addtitletext:NSLocalizedString(@"ProfileText-changeSuccess", @"")];
                [rv addBackTouch];
                 AppDelegate *app=[[UIApplication sharedApplication]delegate];
                [rv showView:app.menu.view];
                [self.navigationController popViewControllerAnimated:YES];
                
            }else{
                Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
                [rv addtitletext:data[@"message"]];
                [rv addBackTouch];
                [rv showView:self.view];
                NSLog(@"失敗：%@",data[@"message"]);
            }
        });
    });
}

@end
