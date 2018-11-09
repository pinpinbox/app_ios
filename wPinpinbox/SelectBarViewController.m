//
//  SelectBarViewController.m
//  wPinpinbox
//
//  Created by Angus on 2015/10/10.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "SelectBarViewController.h"
#import "AppDelegate.h"
#import "UIViewController+CWPopup.h"

@interface SelectBarViewController ()<UIPickerViewDataSource,UIPickerViewDelegate>

@end

@implementation SelectBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //AppDelegate *app=[[UIApplication sharedApplication]delegate];
    
    //self.view.bounds = CGRectMake(0, 0, app.menu.view.bounds.size.width, self.view.bounds.size.height);
    self.view.bounds = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.view.bounds.size.height);
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    // Picker View上有兩個滾筒，所以傳回1
    return 1;
}

// 告訴Picker View上每一個滾筒要呈現幾筆資料
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _data.count;
}

// 實際提供每一個滾筒上要呈現的資料內容
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _data[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectrow=row;
}
- (IBAction)cancel:(id)sender {    
    [_topViewController dismissPopupViewControllerAnimated:YES completion:nil];
    [_delegate cancelButtonPressed];
}

- (IBAction)Done:(id)sender {

    [_topViewController dismissPopupViewControllerAnimated:YES completion:nil];
    [_delegate SaveDataRow:selectrow];
}

@end
