//
//  CalbumlistCollectionViewCell.m
//  wPinpinbox
//
//  Created by Angus on 2015/10/27.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "CalbumlistCollectionViewCell.h"
#import "MTRadialMenu.h"
#import "AddNote.h"
#import "wTools.h"
#import "UserInfo.h"
//
#import "AppDelegate.h"
#import "boxAPI.h"
#import "GlobalVars.h"
#import "CustomIOSAlertView.h"
#import "UIColor+Extensions.h"
#import "UIViewController+ErrorAlert.h"
#import "CustomIOSAlertView.h"

@interface CalbumlistCollectionViewCell ()
@property (nonatomic) UIImageView *caution;
@end
@implementation CalbumlistCollectionViewCell
- (void)awakeFromNib {    
    [super awakeFromNib];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapViewUserInfo:)];
    self.userInteractionEnabled = YES;
    self.userAvatar.userInteractionEnabled = YES;
    self.userAvatar.multipleTouchEnabled = YES;
    [self.userAvatar addGestureRecognizer:tap];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 95, [UIScreen mainScreen].bounds.size.width, 1)];
    line.backgroundColor = [UIColor thirdGrey];
    [self addSubview: line];
    
    _caution = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic200_warn_pink"]];
    _caution.frame = CGRectMake(0, 0,32, 32);
    [self.bgview insertSubview:_caution belowSubview:self.opMenu]; //aboveSubview:self.imageView];
    //[self bringSubviewToFront:_caution];
    _caution.hidden = YES;

}
- (void)switchOpMenuButtonTint:(UIButton *)button {
    
    UIImage *op = [button.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    button.imageView.image = op;
    button.imageView.tintColor = [UIColor whiteColor];
}
#pragma mark - arrange cell sub views by collectionViewType
//  mode for displaying user's album list
- (void)selfAlbumMode {
    _userAvatar.hidden = YES;
    _opMenuDelete.hidden = NO;
    _opMenuInvite.hidden = NO;
    _coopConstraint.constant = 8;
    _opMenuInvite.alpha = 1;
    _opMenuEdit.alpha = 1;
    _opShareLeading.constant = 158;
}
//  mode for displaying user's cooperator album list
- (void)coopAlbumMode {
    
    _userAvatar.hidden = NO;
    _userAvatar.userInteractionEnabled = YES;
    _userAvatar.multipleTouchEnabled = YES;
    _opMenuDelete.hidden = NO;
    _opMenuInvite.hidden = NO;
    _coopConstraint.constant = 40;
    _opMenuInvite.alpha = 1;
    _opMenuEdit.alpha = 1;
    _opShareLeading.constant = 158;
}
//  mode for displaying user's favorite album list
- (void)favAlbumMode {
    _userAvatar.hidden = NO;
    _userAvatar.userInteractionEnabled = YES;
    _userAvatar.multipleTouchEnabled = YES;
    _opMenuInvite.hidden = YES;
    _opMenuEdit.hidden = YES;
    _opMenuInvite.alpha = 0.3;
    _opMenuEdit.alpha = 0.3;
    
    _coopConstraint.constant = 40;
    _opShareLeading.constant = 30;
}
- (void)setAlbumDesc:(NSString *)desc {
    _descLabel.numberOfLines = 0;
    _descLabel.text = desc;
    CGSize s = [_descLabel sizeThatFits:CGSizeMake(225, 58)];
    CGPoint t = _descLabel.frame.origin;
    if (s.height > 58) {
        _descLabel.bounds = CGRectMake(t.x, t.y, s.width, 58);
        _descLabel.numberOfLines = 3;
    } else {
        _descLabel.frame = CGRectMake(t.x, t.y, s.width, s.height);
    }
}
- (void)setCoopNumber:(int)number{
    self.coopLabel.text = [NSString stringWithFormat:@"%00d", number];
    _coopIcon.hidden = number <= 1;
    _coopLabel.hidden = number <= 1;
}
- (void)displayZippedStatus:(BOOL)z {
    self.zipped = z;
    if (z) {
        self.imageView.alpha = 1;
        self.caution.hidden = YES;
    } else {
        self.imageView.alpha = 0.3;
        self.caution.center = self.imageView.center;
        _caution.hidden = NO;
    }
}
-(void)addto{
    // NSLog(@"CalbumlistCollectionViewCell");
    //     NSLog(@"addTo");
    //
    //     // Data Storing for FastViewController popToHomeViewController Directly
    //     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //     BOOL fromHomeVC = NO;
    //     [defaults setObject: [NSNumber numberWithBool: fromHomeVC]
    //                  forKey: @"fromHomeVC"];
    //     [defaults synchronize];
    //
    //     NSLog(@"_zipped: %d", _zipped);
    //
    //     if (_zipped) {
    //         NSLog(@"if zipped is YES");
    //
    //         if (_type==2) {
    //              //[wTools ReadBookalbumid:_albumid userbook:@"Y"];
    //             //[wTools ReadBookalbumid: _albumid userbook: @"Y" eventId: nil postMode: nil fromEventPostVC: nil];
    //             [wTools ReadTestBookalbumid: _albumid userbook: @"Y" eventId: nil postMode: NO fromEventPostVC: NO];
    //             return;
    //         }
    //
    //         if ([[(id)_userid stringValue] isEqualToString:[wTools getUserID]]) {
    //             //[wTools ReadBookalbumid:_albumid userbook:@"Y"];
    //             //[wTools ReadBookalbumid: _albumid userbook: @"Y" eventId: nil postMode: nil fromEventPostVC: nil];
    //             [wTools ReadTestBookalbumid: _albumid userbook: @"Y" eventId: nil postMode: NO fromEventPostVC: nil];
    //         }else{
    //             //[wTools ReadBookalbumid:_albumid userbook:@"N"];
    //             //[wTools ReadBookalbumid: _albumid userbook: @"N" eventId: nil postMode: nil fromEventPostVC: nil];
    //             [wTools ReadTestBookalbumid: _albumid userbook: @"Y" eventId: nil postMode: nil fromEventPostVC: nil];
    //         }
    //     }
}
//  Tap userAvatar to show user info page
- (void)tapViewUserInfo:(UITapGestureRecognizer *)gesture {
    // delegate push userinfo
    if (_delegate && self.userid && self.userid.length) {
        [self.delegate showCreatorPageWithUserid:self.userid];
    }
}
//  change album act
- (IBAction)changeAlbumActStatus:(id)sender {
    NSLog(@"%@",self.albumid);
    if (self.delegate)
        [self.delegate changeAlbumAct:self.albumid index:self.dataIndex];
}
#pragma mark - opMenu Actions
- (BOOL)isOpMode {
    return (self.opMenuLeading.constant == 0);
}
// edit
- (IBAction)opMenuEditTap:(id)sender {
    if (self.delegate)
        [self.delegate opMenuAction:OPEdit index:self.dataIndex];
    
    [self opMenuSwitch:nil];
}
// delete
- (IBAction)opMenuDeleteTap:(id)sender {
    [self deletebook];
    
    [self opMenuSwitch:nil];
}
// share
- (IBAction)opMenuShareTap:(id)sender{
    if (self.delegate)
        [self.delegate opMenuAction:OPShare index:self.dataIndex];
    
    [self opMenuSwitch:nil];
}
// invite
- (IBAction)opMenuInviteTap:(id)sender{
    switch (_type) {
        case 0:
        case 2:{
            if (self.delegate)
                [self.delegate opMenuAction:OPInvite index:self.dataIndex];
        } break;
        case 1:{
            
        } break;
            
    }
    [self opMenuSwitch:nil];
}

//刪除事件
-(void)deletebook  {
    //AppDelegate *app= (AppDelegate *)[[UIApplication sharedApplication]delegate];
    //取得資料ID
    NSString * name=[NSString stringWithFormat:@"%@%@",[wTools getUserID],_albumid ];
    NSString *docDirectoryPath = [filepinpinboxDest stringByAppendingPathComponent:name];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //檢查資料夾是否存在
    
    BOOL localcopy = [fileManager fileExistsAtPath:docDirectoryPath];
    
    __block typeof(self) wself = self;
    CustomIOSAlertView *alertTimeOutView = [[CustomIOSAlertView alloc] init];
    NSString *msg = @"確定要刪除作品？";
    if (_type == 2)
        msg = @"確定解除協作狀態？";
    [alertTimeOutView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
    alertTimeOutView.arrangeStyle = @"Horizontal";
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    alertTimeOutView.parentView = appDelegate.window;
    [alertTimeOutView setButtonTitles: [NSMutableArray arrayWithObjects: @"取消",@"刪除", nil]];
    
    [alertTimeOutView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor whiteColor],nil]];
    [alertTimeOutView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstGrey], nil]];
    [alertTimeOutView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    
    __weak CustomIOSAlertView *weakAlertTimeOutView = alertTimeOutView;
    [alertTimeOutView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertTimeOutView, int buttonIndex) {
        //NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertTimeOutView tag]);
        
        if (buttonIndex == 0) {
            [weakAlertTimeOutView close];
        } else {
            [weakAlertTimeOutView close];
            if (localcopy)
                [fileManager removeItemAtPath:docDirectoryPath error:nil];
            [wself deletebook:wself.albumid];
        }
    }];
    [alertTimeOutView setUseMotionEffects: YES];
    [alertTimeOutView show];
    
    
}

//刪除相本
-(void)deletebook:(NSString *)albumid{
    if (_type==1) {
        [self hidealbumqueue:albumid];
        
        return;
    }
    if (_type==2) {
        [self deletecooperation:albumid];
        return;
    }
    
    [wTools ShowMBProgressHUD];
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *respone = [boxAPI delalbum:[wTools getUserID] token:[wTools getUserToken] albumid:albumid];
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (respone!=nil) {
                NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                if ([dic[@"result"] intValue] == 1) {
                    [wself.delegate reloadData];
                } else if ([dic[@"result"] intValue] == 0) {
                    //                    AppDelegate *app= (AppDelegate *)[[UIApplication sharedApplication]delegate];
                    //                    Remind *rv=[[Remind alloc]initWithFrame:app.window.bounds];
                    //                    [rv addtitletext:dic[@"message"]];
                    //                     [rv addBackTouch];
                    //                    [rv showView:app.window];
                    NSString *msg = dic[@"message"];
                    [UIViewController showCustomErrorAlertWithMessage:msg onButtonTouchUpBlock:^(CustomIOSAlertView * _Nonnull customAlertView, int buttonIndex) {
                        
                        [customAlertView close];
                    }];
                    [wself.delegate reloadData];
                } else {
                    
                    //                    AppDelegate *app= (AppDelegate *)[[UIApplication sharedApplication]delegate];
                    //                    Remind *rv=[[Remind alloc]initWithFrame:app.window.bounds];
                    //                    [rv addtitletext: NSLocalizedString(@"Host-NotAvailable", @"")];
                    //                    [rv addBackTouch];
                    //                    [rv showView:app.window];
                    [UIViewController showCustomErrorAlertWithMessage:NSLocalizedString(@"Host-NotAvailable", @"") onButtonTouchUpBlock:^(CustomIOSAlertView * _Nonnull customAlertView, int buttonIndex) {
                        
                        [customAlertView close];
                    }];
                    [wself.delegate reloadData];
                }
            }
        });
    });
}
//  remove fav album
-(void)hidealbumqueue:(NSString *)albumid{
    [wTools ShowMBProgressHUD];
    __block typeof(self.delegate) wdelegate = self.delegate;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *respone=@"";
        respone=[boxAPI hidealbumqueue:[wTools getUserID] token:[wTools getUserToken] albumid:albumid];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            if (respone!=nil) {
                NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                if ([dic[@"result"] intValue] == 1) {
                    [wdelegate reloadData];
                    [self deletePlist: albumid];
                } else if ([dic[@"result"] intValue] == 0) {
                    //                    AppDelegate *app= (AppDelegate *)[[UIApplication sharedApplication]delegate];
                    //                    Remind *rv=[[Remind alloc]initWithFrame:app.window.bounds];
                    //                    [rv addtitletext:dic[@"message"]];
                    //                    [rv addBackTouch];
                    //                    [rv showView:app.window];
                    NSString *msg = dic[@"message"];
                    [UIViewController showCustomErrorAlertWithMessage:msg onButtonTouchUpBlock:^(CustomIOSAlertView * _Nonnull customAlertView, int buttonIndex) {
                        
                        [customAlertView close];
                    }];
                    [wdelegate reloadData];
                } else {
                    //                    AppDelegate *app= (AppDelegate *)[[UIApplication sharedApplication]delegate];
                    //                    Remind *rv=[[Remind alloc]initWithFrame:app.window.bounds];
                    //                    [rv addtitletext:NSLocalizedString(@"Host-NotAvailable", @"")];
                    //                    [rv addBackTouch];
                    //                    [rv showView:app.window];
                    NSString *msg = NSLocalizedString(@"Host-NotAvailable", @"");
                    [UIViewController showCustomErrorAlertWithMessage:msg onButtonTouchUpBlock:^(CustomIOSAlertView * _Nonnull customAlertView, int buttonIndex) {
                        
                        [customAlertView close];
                    }];
                    [wdelegate reloadData];
                }
            }
        });
    });
}
//  delete local entry
- (void)deletePlist: (NSString *)albumId
{
    NSLog(@"deletePlist");
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex: 0];
    NSString *filePath = [documentsDirectory stringByAppendingString: @"/GiftData.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableDictionary *data;
    
    if ([fileManager fileExistsAtPath: filePath]) {
        NSLog(@"file exists");
        
        data = [[NSMutableDictionary alloc] initWithContentsOfFile: filePath];
        NSLog(@"data: %@", data);
        
        [data removeObjectForKey: albumId];
        NSLog(@"data: %@", data);
    }
    
    if ([data writeToFile: filePath atomically: YES]) {
        NSLog(@"Data saving is successful");
    } else {
        NSLog(@"Data saving is failed");
    }
}

// remove coop
//刪除共用-共用
-(void)deletecooperation:(NSString *)albumid{
    [wTools ShowMBProgressHUD];
    __block typeof(self.delegate) wdelegate = self.delegate;
    __block typeof(self.albumid) walbumid = self.albumid;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *response=@"";
        NSMutableDictionary *data=[NSMutableDictionary new];
        [data setObject:[wTools getUserID] forKey:@"user_id"];
        [data setObject:@"album" forKey:@"type"];
        [data setObject:walbumid forKey:@"type_id"];
        response=[boxAPI deletecooperation:[wTools getUserID] token:[wTools getUserToken] data:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            if (response!=nil) {
                NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                if ([dic[@"result"]boolValue]) {
                    [wdelegate reloadData];
                }else{
                    //                    AppDelegate *app= (AppDelegate *)[[UIApplication sharedApplication]delegate];
                    //                    Remind *rv=[[Remind alloc]initWithFrame:app.window.bounds];
                    //                    [rv addtitletext:dic[@"message"]];
                    //                    [rv addBackTouch];
                    //                    [rv showView:app.window];
                    NSString *msg = dic[@"message"];
                    [UIViewController showCustomErrorAlertWithMessage:msg onButtonTouchUpBlock:^(CustomIOSAlertView * _Nonnull customAlertView, int buttonIndex) {
                        
                        [customAlertView close];
                    }];
                    [wdelegate reloadData];
                    
                }
            }
        });
    });
}
- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.imageView.image = nil;
}

// show or hide opMenu with animation
- (IBAction)opMenuSwitch:(id)sender {
    CGFloat c = self.opMenuLeading.constant;
    
    if (c == 0) {
        CGFloat w = self.bounds.size.width;
        self.opMenuLeading.constant = w;
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            [self layoutIfNeeded];
        } completion:nil];
    } else {
        [self switchOpMenuButtonTint:self.opMenuEdit];
        [self switchOpMenuButtonTint:self.opMenuShare];
        [self switchOpMenuButtonTint:self.opMenuDelete];
        [self switchOpMenuButtonTint:self.opMenuInvite];
        self.opMenuLeading.constant = 0;
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self layoutIfNeeded];
            
        } completion:nil];
    }
}
@end
