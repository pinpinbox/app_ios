//
//  SignViewController_2.m
//  wPinpinbox
//
//  Created by Angus on 2015/8/7.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "SignViewController_2.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CoreLocation.h>
#import "PhotosViewController.h"
#import "RSKImageCropViewController.h"
#import "boxAPI.h"
#import "wTools.h"
#import "SignViewController_3.h"
#import "SelectBarViewController.h"
#import "UIViewController+CWPopup.h"
#import "UICustomLineLabel.h"
//
#import "ChooseHobbyViewController.h"
#import "AsyncImageView.h"

#import "UIViewController+ErrorAlert.h"
#import "CustomIOSAlertView.h"

#import "UserInfo.h"
@interface SignViewController_2 ()<UITextFieldDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,PhotosViewDelegate,SelectBarDelegate>
{
    UITextField *selectText;
    __weak IBOutlet AsyncImageView *myphoto;
    __weak IBOutlet UIButton *ageree;
    __weak IBOutlet UITextField *name;
    __weak IBOutlet UITextField *phone;
    __weak IBOutlet UITextField *url;
    
    IBOutletCollection(UITextField) NSArray *textlields;
    
    __weak IBOutlet UIView *imageview;
    
    UIImage *selectimage;
    __weak IBOutlet UILabel *countryLabel;
    NSArray *country;
    __weak IBOutlet UICustomLineLabel *titlelab;
    __weak IBOutlet UIWebView *webview;
}
@end

@implementation SignViewController_2

- (void)viewDidLoad {
    [super viewDidLoad];
    titlelab.lineType=LineTypeDown;
    [self registerForKeyboardNOtifications];
    // Do any additional setup after loading the view.
    
    for (UITextField *tf in textlields) {
        if ([tf respondsToSelector:@selector(setAttributedPlaceholder:)])
        {
            tf.attributedPlaceholder = [[NSAttributedString alloc] initWithString:tf.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
        }
    }
    
    
    
    //取得檔案路徑
    NSString *path = [[NSBundle mainBundle] pathForResource:@"codebeautify" ofType:@"json"];
    NSString *respone=[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    country=[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil][@"item"];

    UITapGestureRecognizer *doBegan=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showbar)];
    [countryLabel addGestureRecognizer:doBegan];
    
    
    if (_facebookID)
    {
       // https://graph.facebook.com/me/picture?height=200&width=200
        NSString *fburl=[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?height=200&width=200",_facebookID];
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:myphoto];
        myphoto.imageURL=[NSURL URLWithString:fburl];
        name.text=_facebookname;
    }
    
    
    
    
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    webview.backgroundColor=[UIColor clearColor];
    /*
     "關鍵字
     COPYRIGHT => 著作權聲明
     PAYMENT_TERMS => 支付條款
     PRIVACY => 隱私權聲明
     TERMS => 平台規範"
     */
      [wTools ShowMBProgressHUD];
    __block typeof(webview) wwebview = webview;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString * respone=[boxAPI getsettings:@"TERMS"];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSDictionary *data= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            if ([data[@"result"]boolValue]) {                
                [wwebview loadHTMLString:data[@"data"] baseURL:nil];
                 [wTools HideMBProgressHUD];
            }else{
                 [wTools HideMBProgressHUD];
            }
        });
        
    });
    
    [[imageview layer] setMasksToBounds:YES];
    [[imageview layer]setCornerRadius:imageview.bounds.size.height/2];
    
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
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

///
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
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



-(void)textFieldDidBeginEditing:(UITextField *)textField{
    selectText=textField;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    selectText=nil;
}
- (IBAction)Agree:(id)sender {
    ageree.selected=!ageree.selected;
}
//照騙啊
- (IBAction)photo:(UIButton *)sender {
    
    
    PhotosViewController *pvc=[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"PhotosViewController"];
    pvc.selectrow=1;
    pvc.phototype=@"0";
    pvc.delegate=self;
    [self.navigationController pushViewController:pvc animated:YES];
    
    
    return;
}
-(void)imageCropViewController:(PhotosViewController *)controller Image:(UIImage *)Image{
    selectimage=[Image copy];
    myphoto.imageURL=nil;
    myphoto.image=Image;
}
- (IBAction)downbtn:(id)sender {
    NSString *meeage=@"";
    if (!ageree.selected) {
        meeage=@"請同意會員條款";
        return;
    }
    if ([name.text isEqualToString:@""]) {
        meeage=@"請填寫暱稱";
        return ;
    }
    if (!_facebookID) {
        if ([phone.text isEqualToString:@""]) {
            meeage=@"請填寫電話";
            return ;
        }
    }
    if ([url.text isEqualToString:@""]) {
        meeage=@"請填寫URL";
        return ;
    }
    if (![meeage isEqualToString:@""]) {
//        Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
//        [rv addtitletext:meeage];
//        [rv addBackTouch];
//        [rv showView:self.view];
        [UIViewController showCustomErrorAlertWithMessage:meeage onButtonTouchUpBlock:^(CustomIOSAlertView * _Nonnull customAlertView, int buttonIndex) {
            [customAlertView close];
        }];
        return ;
        
    }
    NSString *countrstr=[countryLabel.text componentsSeparatedByString:@"+"][1];
    
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *tmp=[NSMutableDictionary new];
    [tmp addEntriesFromDictionary:[userPrefs objectForKey:@"tmp"]];
    [tmp setObject:name.text forKey:@"name"];
    if (!_facebookID) {
        [tmp setObject:[NSString stringWithFormat:@"%@,%@",countrstr,phone.text] forKey:@"phone"];
    }
      [tmp setObject:url.text forKey:@"url"];
    if (selectimage!=nil) {
        [tmp setObject:UIImageJPEGRepresentation(selectimage, 1.0) forKey:@"image"];
    }
    if (_facebookID) {
         [tmp setObject:UIImageJPEGRepresentation(myphoto.image, 1.0) forKey:@"image"];
    }

    [userPrefs setObject:tmp forKey:@"tmp"];
 //   [userPrefs synchronize];
    
    if (_facebookID) {
        [self FBSign];
        return;
    }
    [wTools ShowMBProgressHUD];
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *email = @"";
        if (wself->_facebookID == nil) {
            email=tmp[@"email"];
        }else{
            email= wself->_facebookID;
        }
        NSString *respone=[boxAPI requsetsmspwd:tmp[@"phone"] Account:email];
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            if (respone != nil) {
                NSLog(@"%@",respone);
                 NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                if ([dic[@"result"] intValue] == 1) {
                   SignViewController_3 *sv3= [[UIStoryboard storyboardWithName:@"SignVC_3" bundle:nil]instantiateViewControllerWithIdentifier:@"SignViewController_3"];
                    if (wself->_facebookID!=nil) {
                        sv3.facebookID=wself->_facebookID;
                    }
                    [self.navigationController pushViewController:sv3 animated:YES];
                } else if ([dic[@"result"] intValue] == 0) {
//                    Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
//                    [rv addtitletext:dic[@"message"]];
//                    [rv addBackTouch];
//                    [rv showView:self.view];
                    [UIViewController showCustomErrorAlertWithMessage:dic[@"message"] onButtonTouchUpBlock:^(CustomIOSAlertView * _Nonnull customAlertView, int buttonIndex) {
                        [customAlertView close];
                    }];
                    NSLog(@"失敗：%@",dic[@"message"]);
                    
                } else {
//                    Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
//                    [rv addtitletext: NSLocalizedString(@"Host-NotAvailable", @"")];
//                    [rv addBackTouch];
//                    [rv showView:self.view];
                    [UIViewController showCustomErrorAlertWithMessage:NSLocalizedString(@"Host-NotAvailable", @"") onButtonTouchUpBlock:^(CustomIOSAlertView * _Nonnull customAlertView, int buttonIndex) {
                        [customAlertView close];
                    }];
                }
            }
        });
    });
}

-(void)FBSign{
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *tmp=[userPrefs objectForKey:@"tmp"];
    NSMutableDictionary *dic=[NSMutableDictionary new];
 
        [dic setObject:@""forKey:@"account"];
        [dic setObject:@"facebook" forKey:@"way"];
        [dic setObject:_facebookID forKey:@"wayid"];
        [dic setObject:@"" forKey:@"pwd"];
    
    
    
    [dic setObject:tmp[@"name"] forKey:@"nickname"];
    [dic setObject:@"" forKey:@"smspassword"];
    [dic setObject:tmp[@"url"] forKey:@"surl"];
    [dic setObject:@"" forKey:@"cellphone"];
    
    [wTools ShowMBProgressHUD];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *respone=[boxAPI registration:dic];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (respone!=nil) {
                NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                NSLog(@"%@",respone);
                if ([dic[@"result"] intValue] == 1) {
                    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
                    [userPrefs setObject:dic[@"data"][@"token"] forKey:@"token"];
                    [userPrefs setObject:[dic[@"data"][@"id"] stringValue] forKey:@"id"];
                    [userPrefs synchronize];
                    // for share extension //
                    [UserInfo setUserInfo:[dic[@"data"][@"id"] stringValue] token:dic[@"data"][@"token"]];                    
                    if (tmp[@"image"]) {
                        NSLog(@"UPDATA IMAGE");
                        NSMutableDictionary *dic=[NSMutableDictionary new];
                        [dic setObject:[UserInfo getUserToken] forKey:@"token"];
                        [dic setObject:[UserInfo getUserID]  forKey:@"id"];
                        
                        UIImage *image=[UIImage imageWithData:tmp[@"image"]];
                        
                        boxAPI *box=[[boxAPI alloc]init];
                        [box boxIMGAPI:dic URL:@"/updateprofilepic" image:image done:^(NSDictionary *responseData) {
                            NSInteger status = [[responseData objectForKey:@"status"] integerValue];
                            if (status < 0) {
                                [wTools HideMBProgressHUD];
                                NSLog(@"画像のUploadに失敗");
                                ChooseHobbyViewController *chooseHobbyVC = [[UIStoryboard storyboardWithName: @"ChooseHobbyVC" bundle: nil] instantiateViewControllerWithIdentifier: @"ChooseHobbyViewController"];
                                [self.navigationController pushViewController: chooseHobbyVC animated: YES];
                                return;
                            }
                            //成功
                            NSLog(@"wusuccess %@", responseData);
                            
                            ChooseHobbyViewController *chooseHobbyVC = [[UIStoryboard storyboardWithName: @"ChooseHobbyVC" bundle: nil] instantiateViewControllerWithIdentifier: @"ChooseHobbyViewController"];
                            [self.navigationController pushViewController: chooseHobbyVC animated: YES];
                            [wTools HideMBProgressHUD];
                        } fail:^(NSInteger status) {
                            [wTools HideMBProgressHUD];
                            NSLog(@"画像のUploadに失敗");
                            ChooseHobbyViewController *chooseHobbyVC = [[UIStoryboard storyboardWithName: @"ChooseHobbyVC" bundle: nil] instantiateViewControllerWithIdentifier: @"ChooseHobbyViewController"];
                            [self.navigationController pushViewController: chooseHobbyVC animated: YES];
                        }];
                    }else{
                         [wTools HideMBProgressHUD];
                        ChooseHobbyViewController *chooseHobbyVC = [[UIStoryboard storyboardWithName: @"ChooseHobbyVC" bundle: nil] instantiateViewControllerWithIdentifier: @"ChooseHobbyViewController"];
                        [self.navigationController pushViewController: chooseHobbyVC animated: YES];
                    }
                    
                } else if ([dic[@"result"] intValue] == 0) {
                    [wTools HideMBProgressHUD];
//                    Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
//                    [rv addtitletext:dic[@"message"]];
//                    [rv addBackTouch];
//                    [rv showView:self.view];
//                    NSLog(@"失敗：%@",dic[@"message"]);
                    [UIViewController showCustomErrorAlertWithMessage:dic[@"message"] onButtonTouchUpBlock:^(CustomIOSAlertView * _Nonnull customAlertView, int buttonIndex) {
                        [customAlertView close];
                    }];
                } else {
//                    [wTools HideMBProgressHUD];
//                    Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
//                    [rv addtitletext: NSLocalizedString(@"Host-NotAvailable", @"")];
//                    [rv addBackTouch];
//                    [rv showView:self.view];
                    [UIViewController showCustomErrorAlertWithMessage:NSLocalizedString(@"Host-NotAvailable", @"") onButtonTouchUpBlock:^(CustomIOSAlertView * _Nonnull customAlertView, int buttonIndex) {
                        [customAlertView close];
                    }];
                }
            }
        });
    });
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
