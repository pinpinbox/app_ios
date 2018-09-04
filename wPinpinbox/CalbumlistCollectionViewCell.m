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

@implementation CalbumlistCollectionViewCell
- (void)awakeFromNib
{
    [_bgview.layer setCornerRadius:5];
    [_bgview.layer setBorderWidth:1];
    [_bgview.layer setBorderColor:[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:0.9].CGColor];
    [_bgview.layer setMasksToBounds:YES];
    
    [[_picture layer] setMasksToBounds:YES];
    [[_picture layer]setCornerRadius:_picture.bounds.size.height/2];
    
//    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] init];
//    [gr setNumberOfTapsRequired:1];
//
//    [gr addTarget:self action:@selector(addto)];
//    [_imageView addGestureRecognizer:gr];
    
    [super awakeFromNib];
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

- (void)menuSelected:(MTRadialMenu *)sender
{
    NSLog(@"menuSelected");
    NSLog(@"TAG:% ld == SELECT = %@",(long)sender.tag,sender.selectedIdentifier);
    
    if (_type==0) {
        NSLog(@"type == 0");
        
        //本人相本
        if ([sender.selectedIdentifier isEqualToString:@"A"]) {
            [self deletebook];
        }
        if ([sender.selectedIdentifier isEqualToString:@"B"]) {
            //編輯
            //[wTools editphotoinfo:_albumid templateid:_templateid];
            [wTools editphotoinfo: _albumid templateid: _templateid eventId: nil postMode: nil];
        }
        if ([sender.selectedIdentifier isEqualToString:@"C"]) {
            [wTools Activitymessage:[NSString stringWithFormat:@"%@ http://www.pinpinbox.com/index/album/content/?album_id=%@",_mytitle.text,_albumid]];
        }
        if ([sender.selectedIdentifier isEqualToString:@"D"]) {
           // [wTools messageboard:_albumid];
        }
    }
    
    if (_type==1) {
        NSLog(@"type == 1");
        
        if ([sender.selectedIdentifier isEqualToString:@"A"]) {
            [self deletebook];
        }
        if ([sender.selectedIdentifier isEqualToString:@"B"]) {
           [wTools Activitymessage:[NSString stringWithFormat:@"%@ http://www.pinpinbox.com/index/album/content/?album_id=%@",_mytitle.text,_albumid]];
        }
        if ([sender.selectedIdentifier isEqualToString:@"C"]) {
           // [wTools messageboard:_albumid];
        }

    }
    //共用
    if (_type==2) {
        NSLog(@"type == 2");
        
        if ([sender.selectedIdentifier isEqualToString:@"A"]) {
            [self deletebook];
        }
        if ([sender.selectedIdentifier isEqualToString:@"B"]) {
            //編輯
            if ([_identity isEqualToString:@"viewer"]) {
                AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
                Remind *rv=[[Remind alloc]initWithFrame:app.menu.view.bounds];
                [rv addtitletext:@"權限不足"];
                [rv addBackTouch];
                [rv showView:app.menu.view];

                return;
            }
            
            if ([_identity isEqualToString:@"admin"]) {
                NSLog(@"identity is admin");
                //[wTools editphotoinfo:_albumid templateid:_templateid];
                [wTools editphotoinfo: _albumid templateid: _templateid eventId: nil postMode: nil];
            } else {
                NSLog(@"identity is not admin");
                if ([_templateid isEqualToString: @"0"]) {
                    [wTools FastBook: _albumid choice: @"Fast"];
                } else {
                    [wTools FastBook: _albumid choice: @"Template"];
                }
                //[wTools FastBook:_albumid];
            }
        }
        if ([sender.selectedIdentifier isEqualToString:@"C"]) {
            [wTools Activitymessage:[NSString stringWithFormat:@"%@ http://www.pinpinbox.com/index/album/content/?album_id=%@",_mytitle.text,_albumid]];
        }
        if ([sender.selectedIdentifier isEqualToString:@"D"]) {
           // [wTools messageboard:_albumid];
        }
    }
    
    // [wTools Activitymessage:@"分享訊息"];
    // [wTools messageboard:_albumid];
}

//刪除事件
-(void)deletebook{
    AppDelegate *app=[[UIApplication sharedApplication]delegate];
    //取得資料ID
    NSString * name=[NSString stringWithFormat:@"%@%@",[wTools getUserID],_albumid ];
    NSString *docDirectoryPath = [filepinpinboxDest stringByAppendingPathComponent:name];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //檢查資料夾是否存在
    if ([fileManager fileExistsAtPath:docDirectoryPath]) {
        Remind *rv=[[Remind alloc]initWithFrame:app.menu.view.bounds];
        [rv addtitletext:@"確定要刪除相本?"];
        [rv addSelectBtntext:@"是" btn2:@"否"];
        [rv showView:app.menu.view];
        rv.btn1select=^(BOOL bo){
            if (bo) {
                [fileManager removeItemAtPath:docDirectoryPath error:nil];
                [self deletebook:_albumid];
            }
        };
    }else{
        Remind *rv=[[Remind alloc]initWithFrame:app.menu.view.bounds];
        [rv addtitletext:@"確定要刪除相本?"];
        [rv addSelectBtntext:@"是" btn2:@"否"];
        [rv showView:app.menu.view];
        rv.btn1select=^(BOOL bo){
            if (bo) {
                [self deletebook:_albumid];
            }
        };
    }
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
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *respone = [boxAPI delalbum:[wTools getUserID] token:[wTools getUserToken] albumid:albumid];
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
                        
            if (respone!=nil) {
                 NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                if ([dic[@"result"] intValue] == 1) {
                    [_delegate reloadData];
                } else if ([dic[@"result"] intValue] == 0) {
                    AppDelegate *app=[[UIApplication sharedApplication]delegate];
                    Remind *rv=[[Remind alloc]initWithFrame:app.menu.view.bounds];
                    [rv addtitletext:dic[@"message"]];
                     [rv addBackTouch];
                    [rv showView:app.menu.view];
                    [_delegate reloadData];
                } else {
                    AppDelegate *app=[[UIApplication sharedApplication]delegate];
                    Remind *rv=[[Remind alloc]initWithFrame:app.menu.view.bounds];
                    [rv addtitletext: NSLocalizedString(@"Host-NotAvailable", @"")];
                    [rv addBackTouch];
                    [rv showView:app.menu.view];
                    [_delegate reloadData];
                }
            }
        });
    });
}

-(void)hidealbumqueue:(NSString *)albumid{
    [wTools ShowMBProgressHUD];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *respone=@"";
        respone=[boxAPI hidealbumqueue:[wTools getUserID] token:[wTools getUserToken] albumid:albumid];

        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            if (respone!=nil) {
                NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                if ([dic[@"result"] intValue] == 1) {
                    [_delegate reloadData];
                    [self deletePlist: albumid];
                } else if ([dic[@"result"] intValue] == 0) {
                    AppDelegate *app=[[UIApplication sharedApplication]delegate];
                    Remind *rv=[[Remind alloc]initWithFrame:app.menu.view.bounds];
                    [rv addtitletext:dic[@"message"]];
                    [rv addBackTouch];
                    [rv showView:app.menu.view];
                    [_delegate reloadData];
                } else {
                    AppDelegate *app=[[UIApplication sharedApplication]delegate];
                    Remind *rv=[[Remind alloc]initWithFrame:app.menu.view.bounds];
                    [rv addtitletext:NSLocalizedString(@"Host-NotAvailable", @"")];
                    [rv addBackTouch];
                    [rv showView:app.menu.view];
                    [_delegate reloadData];
                }
            }
        });
    });
}

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


//刪除共用-共用
-(void)deletecooperation:(NSString *)albumid{
    [wTools ShowMBProgressHUD];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *respone=@"";
        NSMutableDictionary *data=[NSMutableDictionary new];
        [data setObject:[wTools getUserID] forKey:@"user_id"];
        [data setObject:@"album" forKey:@"type"];
        [data setObject:_albumid forKey:@"type_id"];
            respone=[boxAPI deletecooperation:[wTools getUserID] token:[wTools getUserToken] data:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            if (respone!=nil) {
                NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                if ([dic[@"result"]boolValue]) {
                    [_delegate reloadData];
                }else{
                    AppDelegate *app=[[UIApplication sharedApplication]delegate];
                    Remind *rv=[[Remind alloc]initWithFrame:app.menu.view.bounds];
                    [rv addtitletext:dic[@"message"]];
                    [rv addBackTouch];
                    [rv showView:app.menu.view];
                    [_delegate reloadData];
                }
            }
        });
    });
}

- (void)menuAppear:(MTRadialMenu *)sender
{
    NSLog(@"!!!");
    
    [self bringSubviewToFront:sender];
    
}
- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.imageView.image = nil;
}

- (void)reloadmenu {
    NSLog(@"reload menu");
    
    if (menu!=nil) {
        [menu removeFromSuperview];
    }
    
    menu = [MTRadialMenu new];
    
    menu.startingAngle =  305;
    
    int item = 4;
    NSArray *imgarr = nil;
    
    switch (_type) {
        case 0:
            item = 3;
            //imgarr = @[@"wbutton_delete.png",@"wbutton_photoedit.png",@"wbutton_share.png",@"wbutton_upbook"];
            imgarr = @[@"wbutton_delete.png",@"wbutton_photoedit.png",@"wbutton_share.png"];
            break;
        case 1:
            item = 2;
            imgarr = @[@"wbutton_delete.png",@"wbutton_share.png",@"wbutton_message.png"];
            break;
        case 2:
            item = 3;
            imgarr = @[@"wbutton_delete.png",@"wbutton_photoedit.png",@"wbutton_share.png",@"wbutton_message.png"];
            break;
        default:
            break;
    }
    
    
    NSArray *arr=@[@"A",@"B",@"C",@"D"];
    
    for (int i=0; i<item; i++) {
        AddNote *note = [AddNote new];
        note.identifier = arr[i];
        note.img=[UIImage imageNamed:imgarr[i]];

        [menu addMenuItem:note];
    }
    
    // Register the UIControlEvents
    [menu addTarget:self action:@selector(menuSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    // If you want to do anything when the menu appears (like bring it to the front)
    //[menu addTarget:self action:@selector(menuAppear:) forControlEvents:UIControlEventTouchDown];
    [menu addTarget:self action:@selector(menuAppear:) forControlEvents: UIControlEventTouchUpInside];
    
    menu.center = CGPointMake(_imageView.bounds.size.width / 2, _imageView.bounds.size.height / 2);
    
    menu.frame = _imageView.bounds;
    
    NSLog(@"imageView width: %f, height: %f", _imageView.bounds.size.width, _imageView.bounds.size.height);
    NSLog(@"menu width: %f, height: %f", menu.bounds.size.width, menu.bounds.size.height);
    
    NSLog(@"imageView rect: %@", _imageView);
    NSLog(@"menu rect: %@", menu);
    
    //menu.backgroundColor = [UIColor lightGrayColor];
    //menu.alpha = 0.5;
    // The add to the view
    [_imageView addSubview:menu];
}

@end
