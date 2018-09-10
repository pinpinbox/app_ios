//
//  SignViewController_4.m
//  wPinpinbox
//
//  Created by Angus on 2015/8/7.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "SignViewController_4.h"
#import "wTools.h"
#import "UICustomLineLabel.h"
#import "wTools.h"
#import "boxAPI.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "UIView+Toast.h"
#import "UIColor+Extensions.h"

#import "MyTabBarController.h"

#define kFontSize 16

@interface SignViewController_4 ()
{
    __weak IBOutlet UICustomLineLabel *titleLab;
    __weak IBOutlet UIScrollView *myscrollview;
    
    __weak IBOutlet UICustomLineLabel *titlelab;
    __weak IBOutlet UILabel *lab_text;
    __weak IBOutlet UIButton *startUsingPinpinboxBtn;
    __weak IBOutlet UIView *startUsingPinpinboxView;
    
    __weak IBOutlet UIView *viewForImage;
    NSMutableArray *selectArr;
    NSArray *imagearr;
    NSArray *textarr;
}
@end

@implementation SignViewController_4

- (void)viewDidLoad {
    NSLog(@"viewDidLoad");
    
    [super viewDidLoad];
    
    startUsingPinpinboxBtn.layer.cornerRadius = 16;
    startUsingPinpinboxView.hidden = YES;
    
    titleLab.lineType = LineTypeDown;
    selectArr = [NSMutableArray new];
    imagearr = @[@"travel",@"photography",@"food",@"sing",@"nature",@"pet",@"moviestar",@"fashion",@"makeup",@"cooking",@"toy",@"gardening",@"3c",@"art",@"movie",@"exercise"];
    
    //取得檔案路徑
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Hobby_lang" ofType: @"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    NSLog(@"data: %@", data);
    
    NSString *language = [NSString stringWithFormat: @"%@", [[[NSUserDefaults standardUserDefaults]objectForKey: @"AppleLanguages"] objectAtIndex: 0]];
    NSLog(@"language: %@", language);
    
    textarr = data[language];
    
    if (textarr == nil) {
        textarr = @[@"四處旅遊",@"就愛攝影",@"美食享受",@"唱歌跳舞",@"崇尚自然",@"喜愛寵物",@"就愛追星",@"時尚潮流",@"美妝造型",@"料理烘焙",@"模型改造",@"花草園藝",@"熱愛3C",@"藝術創作",@"影音欣賞",@"運動休閒"];
    }
    
    CGSize scsize = myscrollview.bounds.size;
    NSLog(@"scsize: %@", NSStringFromCGSize(scsize));
    
    float space = scsize.width / 32;
    NSLog(@"space: %f", space);
    
    float imagewidth = space * 10;
    NSLog(@"imagewidth: %f", imagewidth);
    
    for (int i = 0; i < 5; i++) {
        for (int j = 0; j < 3; j++) {
            UIView *v = [[UIView alloc] initWithFrame: CGRectMake(j * (imagewidth + space), i * (imagewidth + space), imagewidth, imagewidth)];
            NSLog(@"v frame: %@", NSStringFromCGRect(v.frame));
            
            v.backgroundColor = [UIColor clearColor];
            v.tag = (i * 3) + j;
            
            UIImageView *imagev = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, imagewidth, imagewidth)];
            imagev.image = [UIImage imageNamed: [NSString stringWithFormat: @"icon_%@.png", imagearr[v.tag]]];
            imagev.tag = 100;
            [v addSubview: imagev];
            
            float fontsize = kFontSize;
            
            UILabel *text = [[UILabel alloc]initWithFrame: CGRectMake(0, 0, fontsize * 4, fontsize + 1)];
            text.font = [UIFont systemFontOfSize: fontsize];
            text.textColor = [UIColor whiteColor];
            text.textAlignment = NSTextAlignmentCenter;
            text.text = textarr[v.tag];
            text.center = imagev.center;
            text.adjustsFontSizeToFitWidth = YES;
            [v addSubview: text];
            
            //[myscrollview addSubview: v];
            [viewForImage addSubview: v];
            
            UITapGestureRecognizer *doBegan = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(selectbtn:)];
            [v addGestureRecognizer: doBegan];
//            UIButton *btn=[wTools W_Button:self frame:CGRectMake(j*(imagewidth),i*(imagewidth) , imagewidth, imagewidth) imgname:@"icon_cooking.png" SELL:@selector(selectbtn:) tag:i*3+j];
//            [myscrollview addSubview:btn];
        }
    }
    
    myscrollview.contentSize = CGSizeMake(0, 5 * (imagewidth + space));
    NSLog(@"myscrollview.contentSize: %@", NSStringFromCGSize(myscrollview.contentSize));
    /*
    UIImageView *image = [[UIImageView alloc] initWithFrame: self.view.bounds];
    image.image = [UIImage imageNamed: @"mask-cover.png"];
    [self.view addSubview: image];
     */
}

- (IBAction)selectbtn:(UITapGestureRecognizer *)gesture {
    NSLog(@"selectbtn");
    
    UIImageView *imagev = (UIImageView *)[gesture.view viewWithTag: 100];
    
    NSLog(@"selectArr: %@", selectArr);
    NSLog(@"gesture.view: %@", gesture.view);
    
    if ([selectArr containsObject: gesture.view]) {
        NSLog(@"selectArr exists the object same as gesture.view");
        
        for (UIView *v in [gesture.view subviews]) {
            NSLog(@"UIView *v in [gesture.view subviews]");
            NSLog(@"v.tag = %ld", (long)v.tag);
            
            if (v.tag == 100) {
                imagev.image = [UIImage imageNamed: [NSString stringWithFormat: @"icon_%@.png", imagearr[gesture.view.tag]]];
                
                float fontsize = kFontSize;
                
                UILabel *text = [[UILabel alloc]initWithFrame: CGRectMake(0, 0, fontsize * 4, fontsize + 1)];
                text.font = [UIFont systemFontOfSize: fontsize];
                text.textColor = [UIColor whiteColor];
                text.textAlignment = NSTextAlignmentCenter;
                text.text = textarr[gesture.view.tag];
                text.center = imagev.center;
                text.adjustsFontSizeToFitWidth = YES;
                
                NSLog(@"gesture.view addSubview: text");
                [gesture.view addSubview: text];
            } else {
                NSLog(@"v removeFromSuperview");
                [v removeFromSuperview];
            }
        }
        NSLog(@"selectArr removeObject: gesture.view");
        [selectArr removeObject: gesture.view];
        
        NSLog(@"selectArr.count: %lu", (unsigned long)selectArr.count);
        
        if (selectArr.count == 0) {
            startUsingPinpinboxView.hidden = YES;
        } else {
            startUsingPinpinboxView.hidden = NO;
        }
        
        return;
    }
    
    // Check selectArr whether is reached its maximum value or not
    if ([selectArr count] > 2) {
        NSLog(@"已選三個");
        
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor thirdPink];
        
        [self.view makeToast: @"最多三項"
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
        return;
    }
    
    // Add Plus Png File
    for (UIView *v in [gesture.view subviews]) {
        NSLog(@"UIView *v in [gesture.view subviews]");
        NSLog(@"v.tag = %ld", (long)v.tag);
        
        if (v.tag == 100) {
            NSLog(@"imagearr[gesture.view.tag]: %@", imagearr[gesture.view.tag]);
            imagev.image = [UIImage imageNamed: [NSString stringWithFormat: @"icon_%@_click.png", imagearr[gesture.view.tag]]];
            [selectArr addObject: gesture.view];
            
            UIImageView *plus = [[UIImageView alloc] initWithFrame: imagev.frame];
            plus.image = [UIImage imageNamed: @"icon_plus.png"];
            
            NSLog(@"gesture.view addSubview: plus");
            [gesture.view addSubview: plus];
        } else {
            NSLog(@"v removeFromSuperview");
            [v removeFromSuperview];
        }
    }
    
    NSLog(@"selectArr.count: %lu", (unsigned long)selectArr.count);
    
    if (selectArr.count == 0) {
        startUsingPinpinboxView.hidden = YES;
    } else {
        startUsingPinpinboxView.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)DownBtn:(id)sender {
    NSLog(@"DownBtn");
    
    NSString *selecttag = @"";
    
    if (selectArr.count == 0) {
        /*
        Remind *rv = [[Remind alloc]initWithFrame: self.view.bounds];
        [rv addtitletext: @"請選擇至少一項"];
        [rv addBackTouch];
        [rv showView: self.view];
        NSLog(@"請選擇至少一項");
        
        return;
         */
    }
    for (UIView *v in selectArr) {
        selecttag = [NSString stringWithFormat: @"%@,%i", selecttag, (int)v.tag];
    }
    
    //[wTools ShowMBProgressHUD];
    [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
        NSString *token = [userPrefs objectForKey:@"token"];
        NSString *uid = [wTools getUserID];
        BOOL respone = [boxAPI updateprofilehobby:token usid:uid hobby:selecttag];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[wTools HideMBProgressHUD];
            [MBProgressHUD hideHUDForView: self.view animated: YES];
            
            NSLog(@"response: %d", respone);
            
            if (respone) {
                NSLog(@"if response is TRUE");
                
                MyTabBarController *myTabC = [[UIStoryboard storyboardWithName: @"Main" bundle: nil] instantiateViewControllerWithIdentifier: @"MyTabBarController"];
                
                AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [app.myNav pushViewController: myTabC animated: NO];
                
                //AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
                //[app.menu homebtn:nil];
//                homeViewController *hv= [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"homeViewController"];
//                
//                [self.navigationController pushViewController:hv animated:YES];
            }
        });
    });
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
