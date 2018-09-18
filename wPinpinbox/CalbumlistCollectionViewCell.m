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
#import "Remind.h"
#import "AppDelegate.h"
#import "boxAPI.h"
#import "GlobalVars.h"
#import "CustomIOSAlertView.h"
#import "UIColor+Extensions.h"

@implementation CalbumlistCollectionViewCell
- (void)awakeFromNib
{
    
    [super awakeFromNib];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapViewUserInfo:)];
    self.userInteractionEnabled = YES;
    self.userAvatar.userInteractionEnabled = YES;
    self.userAvatar.multipleTouchEnabled = YES;
    [self.userAvatar addGestureRecognizer:tap];
}
#pragma mark - arrange cell sub views by collectionViewType
- (void)selfAlbumMode {
    _userAvatar.hidden = YES;
    _opMenuDelete.enabled = YES;
    _opMenuInvite.enabled = YES;
    _coopConstraint.constant = 8;
    
}
- (void)coopAlbumMode {
    
    _userAvatar.hidden = NO;
    _userAvatar.userInteractionEnabled = YES;
    _userAvatar.multipleTouchEnabled = YES;
    _opMenuDelete.enabled = YES;
    _opMenuInvite.enabled = YES;
    _coopConstraint.constant = 40;
}
- (void)favAlbumMode {
    _userAvatar.hidden = NO;
    _userAvatar.userInteractionEnabled = YES;
    _userAvatar.multipleTouchEnabled = YES;
    _opMenuInvite.enabled = NO;
    _opMenuEdit.enabled = NO;
    _coopConstraint.constant = 40;
}

-(void)addto{
    NSLog(@"CalbumlistCollectionViewCell");
    NSLog(@"addTo");
    
    // Data Storing for FastViewController popToHomeViewController Directly
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL fromHomeVC = NO;
    [defaults setObject: [NSNumber numberWithBool: fromHomeVC]
                 forKey: @"fromHomeVC"];
    [defaults synchronize];
    
    NSLog(@"_zipped: %d", _zipped);
    
    if (_zipped) {
        NSLog(@"if zipped is YES");
        
        if (_type==2) {
             //[wTools ReadBookalbumid:_albumid userbook:@"Y"];
            //[wTools ReadBookalbumid: _albumid userbook: @"Y" eventId: nil postMode: nil fromEventPostVC: nil];
            [wTools ReadTestBookalbumid: _albumid userbook: @"Y" eventId: nil postMode: nil fromEventPostVC: nil];
            return;
        }
        
        if ([[(id)_userid stringValue] isEqualToString:[wTools getUserID]]) {
            //[wTools ReadBookalbumid:_albumid userbook:@"Y"];
            //[wTools ReadBookalbumid: _albumid userbook: @"Y" eventId: nil postMode: nil fromEventPostVC: nil];
            [wTools ReadTestBookalbumid: _albumid userbook: @"Y" eventId: nil postMode: nil fromEventPostVC: nil];
        }else{
            //[wTools ReadBookalbumid:_albumid userbook:@"N"];
            //[wTools ReadBookalbumid: _albumid userbook: @"N" eventId: nil postMode: nil fromEventPostVC: nil];
            [wTools ReadTestBookalbumid: _albumid userbook: @"Y" eventId: nil postMode: nil fromEventPostVC: nil];
        }
    }
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
    [alertTimeOutView setContentViewWithMsg:@"確定要刪除作品?" contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
    alertTimeOutView.arrangeStyle = @"Horizontal";
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    alertTimeOutView.parentView = appDelegate.window;
    [alertTimeOutView setButtonTitles: [NSMutableArray arrayWithObjects: @"是",@"否", nil]];

    [alertTimeOutView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor whiteColor],nil]];
    [alertTimeOutView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstGrey], nil]];
    [alertTimeOutView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];

    __weak CustomIOSAlertView *weakAlertTimeOutView = alertTimeOutView;
    [alertTimeOutView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertTimeOutView, int buttonIndex) {
        //NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertTimeOutView tag]);
        
        if (buttonIndex == 1) {
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
    __block typeof(self.delegate) wdelegate = self.delegate;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *respone = [boxAPI delalbum:[wTools getUserID] token:[wTools getUserToken] albumid:albumid];
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
                        
            if (respone!=nil) {
                 NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                if ([dic[@"result"] intValue] == 1) {
                    [wdelegate reloadData];
                } else if ([dic[@"result"] intValue] == 0) {
                    AppDelegate *app= (AppDelegate *)[[UIApplication sharedApplication]delegate];
                    Remind *rv=[[Remind alloc]initWithFrame:app.window.bounds];
                    [rv addtitletext:dic[@"message"]];
                     [rv addBackTouch];
                    [rv showView:app.window];
                    [wdelegate reloadData];
                } else {
                    AppDelegate *app= (AppDelegate *)[[UIApplication sharedApplication]delegate];
                    Remind *rv=[[Remind alloc]initWithFrame:app.window.bounds];
                    [rv addtitletext: NSLocalizedString(@"Host-NotAvailable", @"")];
                    [rv addBackTouch];
                    [rv showView:app.window];
                    [wdelegate reloadData];
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
                    AppDelegate *app= (AppDelegate *)[[UIApplication sharedApplication]delegate];
                    Remind *rv=[[Remind alloc]initWithFrame:app.window.bounds];
                    [rv addtitletext:dic[@"message"]];
                    [rv addBackTouch];
                    [rv showView:app.window];
                    [wdelegate reloadData];
                } else {
                    AppDelegate *app= (AppDelegate *)[[UIApplication sharedApplication]delegate];
                    Remind *rv=[[Remind alloc]initWithFrame:app.window.bounds];
                    [rv addtitletext:NSLocalizedString(@"Host-NotAvailable", @"")];
                    [rv addBackTouch];
                    [rv showView:app.window];
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
        
        NSString *respone=@"";
        NSMutableDictionary *data=[NSMutableDictionary new];
        [data setObject:[wTools getUserID] forKey:@"user_id"];
        [data setObject:@"album" forKey:@"type"];
        [data setObject:walbumid forKey:@"type_id"];
            respone=[boxAPI deletecooperation:[wTools getUserID] token:[wTools getUserToken] data:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            if (respone!=nil) {
                NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                if ([dic[@"result"]boolValue]) {
                    [wdelegate reloadData];
                }else{
                    AppDelegate *app= (AppDelegate *)[[UIApplication sharedApplication]delegate];
                    Remind *rv=[[Remind alloc]initWithFrame:app.window.bounds];
                    [rv addtitletext:dic[@"message"]];
                    [rv addBackTouch];
                    [rv showView:app.window];
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

- (void)reloadmenu {
//    NSLog(@"reload menu");
//
//    if (menu!=nil) {
//        [menu removeFromSuperview];
//    }
//
//    menu = [MTRadialMenu new];
//
//    menu.startingAngle =  305;
//
//    int item = 4;
//    NSArray *imgarr = nil;
//
//    switch (_type) {
//        case 0:
//            item = 3;
//            //imgarr = @[@"wbutton_delete.png",@"wbutton_photoedit.png",@"wbutton_share.png",@"wbutton_upbook"];
//            imgarr = @[@"wbutton_delete.png",@"wbutton_photoedit.png",@"wbutton_share.png"];
//            break;
//        case 1:
//            item = 2;
//            imgarr = @[@"wbutton_delete.png",@"wbutton_share.png",@"wbutton_message.png"];
//            break;
//        case 2:
//            item = 3;
//            imgarr = @[@"wbutton_delete.png",@"wbutton_photoedit.png",@"wbutton_share.png",@"wbutton_message.png"];
//            break;
//        default:
//            break;
//    }
//
//
//    NSArray *arr=@[@"A",@"B",@"C",@"D"];
//
//    for (int i=0; i<item; i++) {
//        AddNote *note = [AddNote new];
//        note.identifier = arr[i];
//        note.img=[UIImage imageNamed:imgarr[i]];
//
//        [menu addMenuItem:note];
//    }
//
//    // Register the UIControlEvents
//    [menu addTarget:self action:@selector(menuSelected:) forControlEvents:UIControlEventTouchUpInside];
//
//    // If you want to do anything when the menu appears (like bring it to the front)
//    //[menu addTarget:self action:@selector(menuAppear:) forControlEvents:UIControlEventTouchDown];
//    [menu addTarget:self action:@selector(menuAppear:) forControlEvents: UIControlEventTouchUpInside];
//
//    menu.center = CGPointMake(_imageView.bounds.size.width / 2, _imageView.bounds.size.height / 2);
//
//    menu.frame = _imageView.bounds;
//
//    NSLog(@"imageView width: %f, height: %f", _imageView.bounds.size.width, _imageView.bounds.size.height);
//    NSLog(@"menu width: %f, height: %f", menu.bounds.size.width, menu.bounds.size.height);
//
//    NSLog(@"imageView rect: %@", _imageView);
//    NSLog(@"menu rect: %@", menu);
//
//    //menu.backgroundColor = [UIColor lightGrayColor];
//    //menu.alpha = 0.5;
//    // The add to the view
//    [_imageView addSubview:menu];
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
        self.opMenuLeading.constant = 0;
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self layoutIfNeeded];
            
        } completion:nil];
    }
}
@end
