//
//  DateSelectBarViewController.m
//  wPinpinbox
//
//  Created by Angus on 2015/10/12.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "DateSelectBarViewController.h"
#import "UIViewController+CWPopup.h"
#import "AppDelegate.h"
@interface DateSelectBarViewController ()

@end

@implementation DateSelectBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *app=[[UIApplication sharedApplication]delegate];
    // Do any additional setup after loading the view from its nib.
     self.view.bounds=CGRectMake(0, 0, app.menu.view.bounds.size.width, self.view.bounds.size.height);
    datepicker.maximumDate=[NSDate date];
    if (_selectdate) {
        datepicker.date=_selectdate;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)cancel:(id)sender {
    [_topViewController dismissPopupViewControllerAnimated:YES completion:nil];
}
- (IBAction)Done:(id)sender {
    
    [_topViewController dismissPopupViewControllerAnimated:YES completion:nil];
    [_delegate SaveDataRowData:datepicker.date];
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
