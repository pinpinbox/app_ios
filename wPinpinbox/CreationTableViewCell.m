//
//  CreationTableViewCell.m
//  wPinpinbox
//
//  Created by David on 12/15/16.
//  Copyright © 2016 Angus. All rights reserved.
//

#import "CreationTableViewCell.h"
#import "AppDelegate.h"
#import "SetupViewController.h"
#import "wTools.h"
#import "boxAPI.h"
#import "FastViewController.h"

@implementation CreationTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.bgView.backgroundColor = [UIColor whiteColor];
    self.bgView.layer.cornerRadius = 2.5;
    //  bgView.layer.masksToBounds=YES;
    self.bgView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.bgView.layer.shadowOffset = CGSizeMake(1.0, 1.0);
    self.bgView.layer.shadowOpacity = 0.5;
    self.bgView.layer.shadowRadius = 5.0;
    self.bgView.layer.cornerRadius = 5.0;
    self.bgView.layer.borderWidth = 1.0;
    self.bgView.layer.borderColor = [UIColor whiteColor].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)showTemplate:(id)sender {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    SetupViewController *sv=[[SetupViewController alloc]initWithNibName:@"SetupViewController" bundle:nil];
    [app.myNav pushViewController: sv animated: YES];
}

- (IBAction)FastBtn:(id)sender {
    
    //判斷是否有編輯中相本
    
    [wTools ShowMBProgressHUD];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *respone=[boxAPI checkalbumofdiy:[wTools getUserID] token:[wTools getUserToken]];
        [wTools HideMBProgressHUD];
        
        if (respone!=nil) {
            NSLog(@"%@",respone);
            NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            
            if ([dic[@"result"]boolValue]) {
                [boxAPI updatealbumofdiy:[wTools getUserID] token:[wTools getUserToken] album_id:[dic[@"data"][@"album"][@"album_id"] stringValue]];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            [self addNewFastMod];
        });
        
    });
}


//快速套版
-(void)addNewFastMod{
    
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
                    
                    NSString *tempalbum_id = [dic[@"data"] stringValue];
                    
                    FastViewController *fVC = [[UIStoryboard storyboardWithName: @"Fast" bundle: nil] instantiateViewControllerWithIdentifier: @"FastViewController"];
                    fVC.selectrow = [wTools userbook];
                    fVC.albumid = tempalbum_id;
                    fVC.templateid = @"0";
                    fVC.choice = @"Fast";
                    
                    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [app.myNav pushViewController: fVC animated:YES];
                    
                }else{
                    
                }
            }
        });
    });
}

@end
