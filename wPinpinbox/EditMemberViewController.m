//
//  EditMemberViewController.m
//  wPinpinbox
//
//  Created by Angus on 2015/10/21.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "EditMemberViewController.h"
#import "AsyncImageView.h"
#import "PhotosViewController.h"
#import "EditPasswdViewController.h"
#import "SelectBarViewController.h"
#import "UIViewController+CWPopup.h"
#import "DateSelectBarViewController.h"
#import "wTools.h"
#import "boxAPI.h"
#import "EditPhoneViewController.h"

#import "NSString+emailValidation.h"
#import "MemberViewController.h"

@interface EditMemberViewController () <PhotosViewDelegate,UITextViewDelegate,SelectBarDelegate,DateSelectBarDelegate>
{
    __weak IBOutlet UIScrollView *myscrollview;
    
    __weak IBOutlet AsyncImageView *topimage;
    __weak IBOutlet UITextView *mytextview;
    
    __weak IBOutlet UITextField *nickname;
    __weak IBOutlet UITextField *email;
    
    
    __weak IBOutlet UILabel *sex;
    int sexint;
    
    
    __weak IBOutlet UILabel *birtjday;
    
    
    UITextField *selectText;
    CGPoint svos;
    
    UIButton *bgv;
    
    UIImage *selectimage;
    
    NSDictionary *mydata;
}
@end

@implementation EditMemberViewController
@synthesize cellphone;

- (IBAction)back:(id)sender {
     [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    
    NSLog(@"EditMemberViewController");
    
    [super viewDidLoad];
    myscrollview.contentSize=CGSizeMake(320, 607);
    // Do any additional setup after loading the view from its nib.
    
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    mydata=[userPrefs objectForKey:@"profile"];
    
    topimage.image = [UIImage imageNamed: @"member_back_head.png"];
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: topimage];
    topimage.imageURL=[NSURL URLWithString:mydata[@"profilepic"]];
    
    nickname.text=mydata[@"nickname"];
    email.text=mydata[@"email"];
    mytextview.text=mydata[@"selfdescription"];
    cellphone.text=mydata[@"cellphone"];
    birtjday.text=mydata[@"birthday"];
    
    sexint = [mydata[@"gender"] intValue];
    if (sexint==1) {
        sex.text=NSLocalizedString(@"ProfileText-male", @"");
    }else if(sexint==0){
        sex.text=NSLocalizedString(@"ProfileText-female", @"");
    }else{
        sex.text=NSLocalizedString(@"ProfileText-none", @"");
    }
    
    wtitle.text=NSLocalizedString(@"ProfileText-zone", @"");
    lab_about.text=NSLocalizedString(@"ProfileText-about", @"");
    lab_nickName.text=NSLocalizedString(@"GeneralText-nickName", @"");
    lab_email.text=NSLocalizedString(@"GeneralText-email", @"");
    lab_pwd.text=NSLocalizedString(@"GeneralText-pwd", @"");
    [btn_pwd setTitle:NSLocalizedString(@"ProfileText-changePwd", @"") forState:UIControlStateNormal];
    labe_phone.text=NSLocalizedString(@"GeneralText-cellphone", @"");
    [btn_phone setTitle:NSLocalizedString(@"GeneralText-modify", @"") forState:UIControlStateNormal];
    lab_sex.text=NSLocalizedString(@"ProfileText-sex", @"");
    lab_birthday.text=NSLocalizedString(@"ProfileText-birthday", @"");
    lab_ok.text=NSLocalizedString(@"GeneralText-ok", @"");
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    
    if ([userPrefs objectForKey:@"FB"]) {
        btn_pwd.hidden=YES;
    }
    
    [[topimage layer] setMasksToBounds:YES];
    [[topimage layer] setCornerRadius:topimage.bounds.size.height/2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)OKbtn:(id)sender {
    
    NSLog(@"OKbtn");
    
    NSString *msg = @"";
    
    if ([email.text isEqualToString: @""]) {
        //msg = NSLocalizedString(@"GeneralText-email", @"");
        msg = [msg stringByAppendingString: NSLocalizedString(@"GeneralText-email", @"")];
        msg = [msg stringByAppendingString: @"\n"];
    } else {
        // If Email Field is invalid then message got data
        if (![email.text isEmailValid]) {
            NSLog(@"信箱格式不對");
            //msg = NSLocalizedString(@"RegText-wrongEmail", @"");
            msg = [msg stringByAppendingString: NSLocalizedString(@"RegText-wrongEmail", @"")];
            msg = [msg stringByAppendingString: @"\n"];
        }
    }
    if ([nickname.text isEqualToString: @""]) {
        //msg = NSLocalizedString(@"GeneralText-nickName", @"");
        msg = [msg stringByAppendingString: NSLocalizedString(@"GeneralText-nickName", @"")];
        msg = [msg stringByAppendingString: @"\n"];
    }
    
    if (![msg isEqualToString: @""]) {
        Remind *rv = [[Remind alloc] initWithFrame: self.view.bounds];
        [rv addtitletext: [NSString stringWithFormat: @"資料輸入不完整：\n %@", msg]];
        [rv addBackTouch];
        [rv showView: self.view];
        return;
    }
    
    NSMutableDictionary *data=[NSMutableDictionary new];
    [data setObject:nickname.text forKey:@"nickname"];
    [data setObject:[NSString stringWithFormat:@"%d",sexint] forKey:@"gender"];
     //[data setObject:[NSNumber numberWithInt:sexint] forKey:@"gender"];
    [data setObject:birtjday.text forKey:@"birthday"];
    [data setObject:mytextview.text forKey:@"selfdescription"];
    //[data setObject:cellphone.text forKey:@"cellphone"];
    [data setObject:email.text forKey:@"email"];
    
    
    [wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *respone=[boxAPI updateprofile:[wTools getUserID] token:[wTools getUserToken] data:data];
        
        NSLog(@"user id: %@", [wTools getUserID]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [wTools HideMBProgressHUD];
            
            if (respone!=nil) {
              
                NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                if ([dic[@"result"]boolValue]) {
                    
                    // If headshot didn't change
                    if (selectimage==nil) {
                        
                        NSLog(@"update 1");
                        
                        [self.navigationController popViewControllerAnimated:YES];
                        
                        
                        // Check whether getting edit profile point or not
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        NSString *editProfile = [defaults objectForKey: @"editProfile"];
                        NSLog(@"Check whether getting first time edit point or not");
                        NSLog(@"editProfile: %@", editProfile);
                        
                        if ([editProfile isEqualToString: @"ModifiedAlready"]) {
                            NSLog(@"Get the First Time Eidt Profile Point Already");
                        } else {
                            NSLog(@"show alert point view");
                            editProfile = @"FirstTimeModified";
                            [defaults setObject: editProfile forKey: @"editProfile"];
                            [defaults synchronize];
                        }
                        
                    } else {
                    
                        // If headshot did change
                        NSLog(@"update 2");
                        
                        [wTools ShowMBProgressHUD];
                        UIImage *image=[wTools scaleImage:selectimage toScale:0.5];
                        
                        NSMutableDictionary *dc=[NSMutableDictionary new];
                        [dc setObject:[wTools getUserToken] forKey:@"token"];
                        [dc setObject:[wTools getUserID] forKey:@"id"];
                        
                        boxAPI *box=[[boxAPI alloc]init];
                        [box boxIMGAPI:dc URL:@"/updateprofilepic" image:image done:^(NSDictionary *responseData) {
                            
                            [wTools HideMBProgressHUD];

                            NSInteger status = [[responseData objectForKey:@"status"] integerValue];
                            
                            if (status < 0) {
                                NSLog(@"画像のUploadに失敗");
                                return;
                            }
                            
                            //成功
                            NSLog(@"wusuccess %@", responseData);
                            [self.navigationController popViewControllerAnimated:YES];
                            
                            
                            // Check whether getting edit profile point or not
                            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                            NSString *editProfile = [defaults objectForKey: @"editProfile"];
                            NSLog(@"Check whether getting first time edit point or not");
                            NSLog(@"editProfile: %@", editProfile);
                            
                            if ([editProfile isEqualToString: @"ModifiedAlready"]) {
                                NSLog(@"Get the First Time Eidt Profile Point Already");
                            } else {
                                NSLog(@"show alert point view");
                                editProfile = @"FirstTimeModified";
                                [defaults setObject: editProfile forKey: @"editProfile"];
                                [defaults synchronize];
                            }
                            
                        } fail:^(NSInteger status) {
                            [wTools HideMBProgressHUD];
                            NSLog(@"画像のUploadに失敗");
                        }];
                    }
                    
                } else {
                    NSLog(@"失敗：%@",dic[@"message"]);
                    Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
                    [rv addtitletext:dic[@"message"]];
                    [rv addBackTouch];
                    [rv showView:self.view];
                }
            }
        });
    });
}

- (IBAction)imagebtn:(id)sender {
    PhotosViewController *pvc=[[UIStoryboard storyboardWithName:@"PhotosVC" bundle:nil]instantiateViewControllerWithIdentifier:@"PhotosViewController"];
    pvc.selectrow=1;
    pvc.phototype=@"0";
    pvc.delegate=self;
    [self.navigationController pushViewController:pvc animated:YES];
    
}
-(void)imageCropViewController:(PhotosViewController *)controller Image:(UIImage *)Image{
    selectimage=Image;
    topimage.image=selectimage;
}
- (IBAction)pwdvtn:(id)sender {
    EditPasswdViewController *edpv=[[EditPasswdViewController alloc]initWithNibName:@"EditPasswdViewController" bundle:nil];
    [self.navigationController pushViewController:edpv animated:YES];
}

//修改電話
-(IBAction)cellphone:(id)sender{
    EditPhoneViewController *edpv=[[EditPhoneViewController alloc]initWithNibName:@"EditPhoneViewController" bundle:nil];
    edpv.editview=self;
    edpv.cellphoen=cellphone.text;
    edpv.email=email.text;
    [self.navigationController pushViewController:edpv animated:YES];
}

- (IBAction)sexbtn:(id)sender {
    SelectBarViewController *mv=[[SelectBarViewController alloc]initWithNibName:@"SelectBarViewController" bundle:nil];
    NSArray *arr=[NSArray arrayWithObjects:@"女生",@"男生", nil] ;
    mv.data=arr;
    mv.delegate=self;
    mv.topViewController=self;
    [self wpresentPopupViewController:mv animated:YES completion:nil];

}
- (IBAction)birthdaybtn:(id)sender {
    DateSelectBarViewController *dv=[[DateSelectBarViewController alloc]initWithNibName:@"DateSelectBarViewController" bundle:nil];
    dv.delegate=self;
    dv.topViewController=self;
    [self wpresentPopupViewController:dv animated:YES completion:nil];
}
-(void)SaveDataRow:(NSInteger)row{

    sexint = (int)row;
    if (sexint==1) {
        sex.text=NSLocalizedString(@"ProfileText-male", @"");
    }else if(sexint==0){
        sex.text=NSLocalizedString(@"ProfileText-female", @"");
    }else{
        sex.text=NSLocalizedString(@"ProfileText-none", @"");
    }

}
-(void)SaveDataRowData:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    
    birtjday.text=[dateFormatter stringFromDate:date];
}

//
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [myscrollview setContentOffset:svos animated:YES];
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    selectText=nil;
}
-(void)returnkey{
    [bgv removeFromSuperview];
    [myscrollview setContentOffset:svos animated:YES];
    [selectText resignFirstResponder];

}
//implementation
- (void)textFieldDidBeginEditing:(UITextField *)textField {
     selectText=textField;
    bgv=[wTools W_Button:self frame:self.view.bounds imgname:@"" SELL:@selector(returnkey) tag:1];
    [self.view addSubview:bgv];
    svos = myscrollview.contentOffset;
    CGPoint pt;
    CGRect rc = [textField bounds];
    rc = [textField convertRect:rc toView:myscrollview];
    pt = rc.origin;
    pt.x = 0;
    pt.y -= 60;
    [myscrollview setContentOffset:pt animated:YES];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (range.length == 0) {
        if ([text isEqualToString:@"\n"]) {
             [myscrollview setContentOffset:svos animated:YES];
            [textView resignFirstResponder];
            return NO;
        }
    }
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    svos = myscrollview.contentOffset;
    CGPoint pt;
    CGRect rc = [textView bounds];
    rc = [textView convertRect:rc toView:myscrollview];
    pt = rc.origin;
    pt.x = 0;
    pt.y -= 60;
    [myscrollview setContentOffset:pt animated:YES];
}

@end
