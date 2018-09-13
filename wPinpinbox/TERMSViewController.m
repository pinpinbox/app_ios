//
//  TERMSViewController.m
//  wPinpinbox
//
//  Created by Angus on 2016/5/17.
//  Copyright © 2016年 Angus. All rights reserved.
//

#import "TERMSViewController.h"
#import "wTools.h"
#import "boxAPI.h"
@interface TERMSViewController ()
{
    __weak IBOutlet UIWebView *webview;
    __weak IBOutlet UILabel *lab_title;
}
@end

@implementation TERMSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    webview.backgroundColor=[UIColor clearColor];
    lab_title.text=NSLocalizedString(@"RegText_tipAgreementMemberTitle", @"");
    /*
     "關鍵字
     COPYRIGHT => 著作權聲明
     PAYMENT_TERMS => 支付條款
     PRIVACY => 隱私權聲明
     TERMS => 平台規範"
     */
    [wTools ShowMBProgressHUD];
    __block typeof(webview) wview = webview;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString * respone=[boxAPI getsettings:@"TERMS"];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSDictionary *data= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            if ([data[@"result"]boolValue]) {
                
                [wview loadHTMLString:data[@"data"] baseURL:nil];
                [wTools HideMBProgressHUD];
            }else{
                [wTools HideMBProgressHUD];
            }
        });
        
    });

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
