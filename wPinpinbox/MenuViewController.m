//
//  MenuViewController.m
//  wPinpinbox
//
//  Created by Angus on 2015/8/7.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "MenuViewController.h"
#import "AppDelegate.h"
#import "MemberViewController.h"
#import "homeViewController.h"
#import "StartImage.h"
#import "boxAPI.h"
#import "AsyncImageView.h"
#import "SearchViewController.h"
#import "RetrievehotrankViewController.h"
#import "CalbumlistViewController.h"
#import "SetupViewController.h"
#import "wTools.h"
#import "RecommendViewController.h"
#import "OpenUDID.h"

//#import "AlbumCreateViewController.h"
#import "FastViewController.h"

#import "CustomIOSAlertView.h"
#import <CoreLocation/CoreLocation.h>

#import "MyTabBarController.h"

#import "UIColor+Extensions.h"

@interface MenuViewController ()
{
    
    __weak IBOutlet UIView *bgview;
    __weak IBOutlet UIView *menuView;
    BOOL isAnimated;
    __weak IBOutlet AsyncImageView *picimageview;
    BOOL Enter;
    
    UIView* animatview;
    UIImageView *animatimageview;
    
    
    StartImage*StartView;
}

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"MenuViewController");
    
    homepage.text=NSLocalizedString(@"GeneralText-homePage", @"");
    search.text=NSLocalizedString(@"GeneralText-search", @"");
    createalbum.text=NSLocalizedString(@"GeneralText-createAlbum", @"");
    fav.text=NSLocalizedString(@"GeneralText-fav", @"");
    rank.text=NSLocalizedString(@"GeneralText-rank", @"");
    profile.text=NSLocalizedString(@"GeneralText-profile", @"");
    
    //新增下載相關資料夾
    [self checkDir];
    isAnimated = NO;
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    app.menu=self;        
    
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] init];
    [gr setNumberOfTapsRequired:1];
    
    [gr addTarget:self action:@selector(packup:)];
    [bgview addGestureRecognizer:gr];
    
    //[boxAPI testAPIcode];
    //     boxAPI *box=[[boxAPI alloc]init];
    //    NSMutableDictionary *dic=[NSMutableDictionary new];
    //    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    //    [dic setValue:[userPrefs objectForKey:@"id"] forKey:@"id"];
    //    [dic setValue:[userPrefs objectForKey:@"token"] forKey:@"token"];
    //    [box boxIMGAPI:dic URL:@"/updateprofilepic" image:[UIImage imageNamed:@"me.jpg"] done:nil fail:nil];
    
}

//新增資料夾
-(BOOL)checkDir
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"data"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]){
        if (![fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil]) {
            NSLog(@"Create Fail..");
            return NO;
        }
    }
    [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:path]];
    
    
    //製作新資料夾的路徑
    NSString *newFolderPath = [path stringByAppendingPathComponent:@"Download"];
    
    
    
    //建立新資料夾
    fileManager = [NSFileManager defaultManager];
    
    BOOL isFileAlreadyExists = [fileManager fileExistsAtPath:newFolderPath];
    if (!isFileAlreadyExists) {
        if ([fileManager createDirectoryAtPath:newFolderPath withIntermediateDirectories:YES attributes:nil error:nil])
            NSLog(@"新資料夾建立成功");
    }else{
        NSLog(@"Download資料夾已存在");
    }
    
    
    newFolderPath = [path stringByAppendingPathComponent:@"pinpinbox"];
    
    
    
    //建立新資料夾
    fileManager = [NSFileManager defaultManager];
    
    isFileAlreadyExists = [fileManager fileExistsAtPath:newFolderPath];
    if (!isFileAlreadyExists) {
        if ([fileManager createDirectoryAtPath:newFolderPath withIntermediateDirectories:YES attributes:nil error:nil])
            NSLog(@"新資料夾建立成功");
    }else{
        NSLog(@"pinpinbox資料夾已存在");
    }
    
    
    return NO;
}
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    menuView.frame=CGRectMake(0, -menuView.frame.size.height, menuView.frame.size.width, menuView.frame.size.height);
    menuView.alpha=0;
    bgview.alpha=0;
    isAnimated=YES;
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    // [userPrefs synchronize];
    //Enter=YES;
    if (!Enter) {
        
        
        if (![userPrefs objectForKey:@"start"]) {
            [userPrefs setObject:@"1" forKey:@"start"];
            [userPrefs synchronize];
            StartView=[[StartImage alloc]initWithFrame:self.view.bounds];
            [StartView show];
            [self.view addSubview:StartView];
        }
        
        
        
        //        animatview=[[UIView alloc]initWithFrame:self.view.bounds];
        //        animatview.backgroundColor=[UIColor whiteColor];
        //        NSMutableArray *array=[NSMutableArray new];
        //        for (int i=0; i<=27; i++) {
        //            [array addObject:[UIImage imageNamed:[NSString stringWithFormat:@"render_3_%i.png",i]]];
        //        }
        //        animatimageview=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 179, 165)];
        //        animatimageview.contentMode=UIViewContentModeScaleAspectFill;
        //        animatimageview.animationImages=array;
        //        animatimageview.animationDuration=2.0;
        //        animatimageview.animationRepeatCount=1;
        //
        //        [animatview addSubview:animatimageview];
        //        [self.view addSubview:animatview];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [[picimageview layer] setMasksToBounds:YES];
    [[picimageview layer] setCornerRadius:picimageview.bounds.size.height/2];
    menuView.frame=CGRectMake(0, -menuView.frame.size.height, menuView.frame.size.width, menuView.frame.size.height);
    
    if (!Enter) {
        if (animatimageview.isAnimating) {
            return;
        }
        
        animatimageview.center=CGPointMake(animatview.bounds.size.width/2,animatview.bounds.size.height/2);
        [animatimageview startAnimating];
        [NSTimer scheduledTimerWithTimeInterval:2.0
                                         target:self
                                       selector:@selector(animationstop)
                                       userInfo:nil
                                        repeats:NO];
    }
}

-(void)animationstop{
    UIImageView *image=[[UIImageView alloc]initWithFrame:animatimageview.frame];
    image.contentMode=UIViewContentModeScaleAspectFill;
    image.image=[UIImage imageNamed:@"render_3_27.png"];
    [animatview addSubview:image];
    
    [UIView animateWithDuration:2.0 animations:^{
        animatview.alpha=0;
    } completion:^(BOOL anim){
        [animatview removeFromSuperview];
        
        Enter=YES;
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//結束視窗
- (IBAction)packup:(id)sender {
    NSLog(@"pack");
    
    if (isAnimated) {
        return;
    }
    isAnimated = YES;
    [self packupMenu];
}

-(void)packupMenu{
    [UIView animateWithDuration:0.3 animations:^{
        menuView.frame=CGRectMake(0, -menuView.frame.size.height, menuView.frame.size.width, menuView.frame.size.height);
        menuView.alpha=0;
        bgview.alpha=0;
        
    } completion:^(BOOL anim){
    }];
}

//開啟視窗
-(void)showMenu{
    if (isAnimated) {
        isAnimated=NO;
        [UIView animateWithDuration:0.3 animations:^{
            menuView.frame=CGRectMake(0, 0, menuView.frame.size.width, menuView.frame.size.height);
            menuView.alpha=1;
            bgview.alpha=0.1;
        } completion:^(BOOL anim){
            isAnimated = NO;
            
        }];
    }
}

//個人資料
-(IBAction)memberbtn:(id)sender{
    AppDelegate *app=[[UIApplication sharedApplication]delegate];
    if ([app.myNav.topViewController isKindOfClass:[ MemberViewController class]]) {
        [self packup:nil];
        return;
    }
    for (UIViewController *temp in app.myNav.viewControllers) {
        if ([temp isKindOfClass:[ MemberViewController class]]) {
            [app.myNav popToViewController:temp animated:NO];
            [self packup:nil];
            return;
        }
    }
    // MemberViewController *mvc=[[UIStoryboard storyboardWithName:@"Member" bundle:nil]instantiateViewControllerWithIdentifier:@"MemberViewController"];
    MemberViewController *mvc=[[MemberViewController alloc]initWithNibName:@"MemberViewController" bundle:nil];
    [app.myNav pushViewController:mvc animated:NO];
    [self packup:nil];
}

//首頁
-(IBAction)homebtn:(id)sender {
    NSLog(@"Press homeBtn");
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    for (id controller in self.navigationController.viewControllers)
        NSLog(@"controller: %@", controller);
    
    if ([app.myNav.topViewController isKindOfClass:[homeViewController class]]) {
        NSLog(@"app.myNav.topViewController is kind of homeViewController class");
        [self packup:nil];
        return;
    }
    
    NSMutableDictionary *data=[NSMutableDictionary new];
    [data setValue:@"0,10" forKey:@"limit"];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *respone=[boxAPI updatelist:[wTools getUserID] token:[wTools getUserToken] data:data rank: @"latest"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            if (respone!=nil) {
                NSLog(@"%@",respone);
                NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                if ([dic[@"result"]boolValue]) {
                    
                    if ([[dic objectForKey:@"data"] count]>0) {
                        //有資料轉跳首頁
                        NSLog(@"Call updateList got data is bigger than 0");
                        
                        for (UIViewController *temp in app.myNav.viewControllers) {
                            if ([temp isKindOfClass:[homeViewController class]]) {
                                NSLog(@"temp is kind of homeViewController class");
                                
                                [app.myNav popToViewController:temp animated:NO];
                                [self packup:nil];
                                return;
                            }
                        }
                        
                        NSLog(@"temp is not kind of homeViewController class");
                        
                        //homeViewController *mvc=[[UIStoryboard storyboardWithName:@"Home" bundle:nil]instantiateViewControllerWithIdentifier:@"homeViewController"];
                        MyTabBarController *myTabC = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"MyTabBarController"];
                        
                        [app.myNav pushViewController: myTabC animated:NO];
                        [self packup:nil];
                    }else{
                        //無資料轉跳推薦好友
                        for (UIViewController *temp in app.myNav.viewControllers) {
                            if ([temp isKindOfClass:[RecommendViewController class]]) {
                                [app.myNav popToViewController:temp animated:NO];
                                [self packup:nil];
                                return;
                            }
                        }
                        RecommendViewController *rv=[[RecommendViewController alloc]initWithNibName:@"RecommendViewController" bundle:nil];
                        rv.working=NO;
                        [app.myNav pushViewController:rv animated:YES];
                        [self packup:nil];
                    }
                    
                }else{
                    NSLog(@"失敗：%@",dic[@"message"]);
                }
                
            }
        });
        
    });
    
    return;
    
    
    if ([app.myNav.topViewController isKindOfClass:[ homeViewController class]]) {
        NSLog(@"app.myNav.topViewController is kind of homeViewController class");
        
        [self packup:nil];
        return;
    }
    for (UIViewController *temp in app.myNav.viewControllers) {
        if ([temp isKindOfClass:[homeViewController class]]) {
            NSLog(@"temp is homeViewController class");
            
            [app.myNav popToViewController:temp animated:NO];
            [self packup:nil];
            return;
        }
    }
    
    NSLog(@"app.myNav.topViewController is not kind of homeViewController class");
    NSLog(@"temp is not homeViewController class");        
    
    [app.myNav popViewControllerAnimated: NO];
    
    //homeViewController *mvc=[[UIStoryboard storyboardWithName:@"Home" bundle:nil]instantiateViewControllerWithIdentifier:@"homeViewController"];
    MyTabBarController *myTabC = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"MyTabBarController"];
    
    [app.myNav pushViewController: myTabC animated:NO];
    [self packup:nil];
}

//更新大頭貼
-(void)reloadpic:(NSString *)urlstr{
    if ([urlstr isEqual:[NSNull null]]) {
        picimageview.image = [UIImage imageNamed: @"member_back_head.png"];
        return;
    }
    
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: picimageview];
    picimageview.imageURL=[NSURL URLWithString:urlstr];
}

//搜尋
-(IBAction)Search:(id)sender{
    AppDelegate *app=[[UIApplication sharedApplication]delegate];
    if ([app.myNav.topViewController isKindOfClass:[ SearchViewController class]]) {
        [self packup:nil];
        return;
    }
    for (UIViewController *temp in app.myNav.viewControllers) {
        if ([temp isKindOfClass:[SearchViewController class]]) {
            [app.myNav popToViewController:temp animated:NO];
            [self packup:nil];
            return;
        }
    }
    SearchViewController*mvc=[[SearchViewController alloc]initWithNibName:@"SearchViewController" bundle:nil];
    
    [app.myNav pushViewController:mvc animated:NO];
    [self packup:nil];
}

//排行榜
-(IBAction)Recommend:(id)sender{
    AppDelegate *app=[[UIApplication sharedApplication]delegate];
    if ([app.myNav.topViewController isKindOfClass:[RetrievehotrankViewController class]]) {
        [self packup:nil];
        return;
    }
    for (UIViewController *temp in app.myNav.viewControllers) {
        if ([temp isKindOfClass:[RetrievehotrankViewController class]]) {
            [app.myNav popToViewController:temp animated:NO];
            [self packup:nil];
            return;
        }
    }
    RetrievehotrankViewController*mvc=[[RetrievehotrankViewController alloc]initWithNibName:@"RetrievehotrankViewController" bundle:nil];
    [app.myNav pushViewController:mvc animated:NO];
    [self packup:nil];
}

//我收藏
-(IBAction)showJCC:(id)sender{
    AppDelegate *app=[[UIApplication sharedApplication]delegate];
    
    if ([app.myNav.topViewController isKindOfClass:[ CalbumlistViewController class]]) {
        [self packup:nil];
        return;
    }
    for (UIViewController *temp in app.myNav.viewControllers) {
        if ([temp isKindOfClass:[ CalbumlistViewController class]]) {
            [app.myNav popToViewController:temp animated:NO];
            [self packup:nil];
            return;
        }
    }
    
    CalbumlistViewController *jv=[[UIStoryboard storyboardWithName:@"Calbumlist" bundle:nil]instantiateViewControllerWithIdentifier:@"CalbumlistViewController"];
    [app.myNav pushViewController:jv animated:NO];
    [self packup:nil];
}

//建立相本
-(IBAction)showSetupview:(id)sender{
    AppDelegate *app=[[UIApplication sharedApplication]delegate];
    
    if ([app.myNav.topViewController isKindOfClass:[SetupViewController class]]) {
        [self packup:nil];
        return;
    }
    for (UIViewController *temp in app.myNav.viewControllers) {
        if ([temp isKindOfClass:[SetupViewController class]]) {
            [app.myNav popToViewController:temp animated:NO];
            [self packup:nil];
            return;
        }
    }
    SetupViewController *sv=[[SetupViewController alloc]initWithNibName:@"SetupViewController" bundle:nil];
    [app.myNav pushViewController:sv animated:NO];
    [self packup:nil];
}

- (void)FastBtn {
    NSLog(@"FastBtn");
    
    //判斷是否有編輯中相本
    
    [wTools ShowMBProgressHUD];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *respone=[boxAPI checkalbumofdiy:[wTools getUserID] token:[wTools getUserToken]];
        [wTools HideMBProgressHUD];
        
        if (respone!=nil) {
            NSLog(@"%@",respone);
            NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            
            if ([dic[@"result"] intValue] == 1) {
                [boxAPI updatealbumofdiy:[wTools getUserID] token:[wTools getUserToken] album_id:[dic[@"data"][@"album"][@"album_id"] stringValue]];
            } else if ([dic[@"result"] intValue] == 0) {
                NSLog(@"失敗：%@",dic[@"message"]);
                [self showCustomErrorAlert: dic[@"message"]];
            } else {
                [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            [self addNewFastMod];
        });
    });
}

//快速套版
- (void)addNewFastMod {
    
    NSLog(@"addNewFastMod");
    
    //新增相本id
    [wTools ShowMBProgressHUD];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *respone=[boxAPI insertalbumofdiy:[wTools getUserID] token:[wTools getUserToken] template_id:@"0"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [wTools HideMBProgressHUD];
            
            if (respone!=nil) {
                NSLog(@"%@",respone);
                NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                if ([dic[@"result"]boolValue]) {
                    
                    NSLog(@"insertalbumofdiy success");
                    
                    NSString *tempalbum_id=[dic[@"data"] stringValue];
                    
                    /*
                    AlbumCreateViewController *acVC = [[UIStoryboard storyboardWithName: @"Fast" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumCreateViewController"];
                    acVC.albumid = tempalbum_id;
                    //acVC.event_id = _event_id;
                    //acVC.postMode = _postMode;
                    acVC.choice = @"Fast";
                    */
                    
                    FastViewController *fVC=[[UIStoryboard storyboardWithName:@"Fast" bundle:nil] instantiateViewControllerWithIdentifier:@"FastViewController"];
                    //FastViewController *fVC = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"FastViewController"];
                    fVC.selectrow = [wTools userbook];
                    fVC.albumid = tempalbum_id;
                    fVC.choice = @"Fast";
                    
                    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
                    [app.myNav pushViewController: fVC animated:NO];
                    
                    //[self.navigationController pushViewController: fVC animated:YES];
                    
                    
                }else{
                    
                }
            }
        });
    });
}

#pragma mark - Custom Error Alert Method
- (void)showCustomErrorAlert: (NSString *)msg {
    CustomIOSAlertView *errorAlertView = [[CustomIOSAlertView alloc] init];
    [errorAlertView setContainerView: [self createErrorContainerView: msg]];
    
    [errorAlertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    [errorAlertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    [errorAlertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    errorAlertView.arrangeStyle = @"Horizontal";
    
    /*
     [alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
     [alertView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor firstMain], [UIColor firstPink], [UIColor secondGrey], nil]];
     [alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor darkMain], [UIColor darkPink], [UIColor firstGrey], nil]];
     alertView.arrangeStyle = @"Vertical";
     */
    
    __weak CustomIOSAlertView *weakErrorAlertView = errorAlertView;
    [errorAlertView setOnButtonTouchUpInside:^(CustomIOSAlertView *customAlertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[customAlertView tag]);
        [weakErrorAlertView close];
    }];
    
    [errorAlertView show];
}

- (UIView *)createErrorContainerView: (NSString *)msg
{
    // TextView Setting
    UITextView *textView = [[UITextView alloc] initWithFrame: CGRectMake(10, 30, 280, 20)];
    //textView.text = @"帳號已經存在，請使用另一個";
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
    [imageView setImage:[UIImage imageNamed:@"icon_2_0_0_dialog_error"]];
    
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
    contentView.backgroundColor = [UIColor firstPink];
    
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
