//
//  SBookSelectViewController.m
//  wPinpinbox
//
//  Created by Angus on 2016/1/7.
//  Copyright (c) 2016年 Angus. All rights reserved.
//

#import "SBookSelectViewController.h"
#import "UIViewController+CWPopup.h"
#import "AppDelegate.h"

@interface SBookSelectViewController () <UIPickerViewDataSource,UIPickerViewDelegate>

@end

@implementation SBookSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"SBookSelectViewController");
    NSLog(@"data: %@ %@", [_data objectAtIndex: 0], [_data objectAtIndex: 1]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_mytitletext) {
        _mytitle.text=_mytitletext;
    }
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
- (NSAttributedString *)pickerView:(UIPickerView *)pickerView
             attributedTitleForRow:(NSInteger)row
                      forComponent:(NSInteger)component
{
    return [[NSAttributedString alloc] initWithString:_data[row]
                                           attributes:@
            {
            NSForegroundColorAttributeName:[UIColor whiteColor]
            }];
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectrow=row;
    [_delegate DidselectDataRow:row];
}
- (IBAction)cancel:(id)sender {
    [_topViewController w2dismissPopupViewControllerAnimated:YES completion:nil];
}
- (IBAction)Done:(id)sender {
    NSLog(@"Done");
    [_delegate SaveDataRow:selectrow];
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
