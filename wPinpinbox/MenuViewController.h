//
//  MenuViewController.h
//  wPinpinbox
//
//  Created by Angus on 2015/8/7.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UIViewController
{
    __weak IBOutlet UILabel *homepage;
    __weak IBOutlet UILabel *search;
    __weak IBOutlet UILabel *createalbum;
    __weak IBOutlet UILabel *fav;
    __weak IBOutlet UILabel *rank;
    __weak IBOutlet UILabel *profile;
}

//開啟視窗
-(void)showMenu;
//更新大頭貼
-(void)reloadpic:(NSString *)urlstr;

//首頁
-(IBAction)homebtn:(id)sender;
-(IBAction)showJCC:(id)sender;

-(IBAction)memberbtn:(id)sender;
-(IBAction)showSetupview:(id)sender;

- (void)FastBtn;

- (void)checkLocation;

@end
