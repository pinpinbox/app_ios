//
//  CooperationViewController.m
//  wPinpinbox
//
//  Created by Angus on 2016/1/12.
//  Copyright (c) 2016年 Angus. All rights reserved.
//

#import "CooperationViewController.h"
#import "CoopTopTableViewCell.h"
#import "CopperatiocTableViewCell.h"
#import "wTools.h"
#import "boxAPI.h"
#import "AsyncImageView.h"
#import "Remind.h"
#import "CooperationAddViewController.h"
#import "SBookSelectViewController.h"
#import "UIViewController+CWPopup.h"

@interface CooperationViewController () <UITableViewDataSource,UITableViewDelegate,SBookSelectViewController>
{
    NSMutableArray *mydataarr;
    NSDictionary *adminuser;
    NSString *selectuserid;
    
    NSString *qrImageStr;
    
    UIView *dimBackgroundUIView;
    UIView *containerView;
    UIImageView *imageView;
}

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation CooperationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   // mytable.editing=YES;
    mydataarr=[NSMutableArray new];
    wtitle.text=NSLocalizedString(@"CreateAlbumText-createGroup", @"");
    
    // Do any additional setup after loading the view from its nib.
    
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleGesture:)];
    [self.view addGestureRecognizer: gr];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget: self
                            action: @selector(refresh)
                  forControlEvents: UIControlEventValueChanged];
    [mytable addSubview: self.refreshControl];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // Set up for back to the previous one for disable swipe gesture
    // Because the home view controller can not swipe back to Main Screen
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)handleGesture: (UIGestureRecognizer *)gestureRecognizer
{
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationDuration: 1.0];
    [UIView setAnimationDelay: 1.0];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
    
    if (imageView) {
        [imageView removeFromSuperview];
    }
    if (containerView) {
        [containerView removeFromSuperview];
    }
    if (dimBackgroundUIView) {
        [dimBackgroundUIView removeFromSuperview];
    }
    
    [UIView commitAnimations];        
}

- (void)refresh
{
    [self reload];
}

-(void)reload {
    [wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSMutableDictionary *data=[NSMutableDictionary new];
        [data setObject:_albumid forKey:@"type_id"];
        [data setObject:@"album" forKey:@"type"];
        NSString *respone=[boxAPI getcooperationlist:[wTools getUserID] token:[wTools getUserToken] data:data];
        
        NSMutableDictionary *qrDic = [NSMutableDictionary new];
        [qrDic setObject: [NSNumber numberWithBool: YES] forKey: @"is_cooperation"];
        [qrDic setObject: [NSNumber numberWithBool: NO] forKey: @"is_follow"];
        
        NSLog(@"generate jSON data for getQRCode");
        NSLog(@"qrDic: %@", qrDic);
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject: qrDic
                                                           options: 0
                                                             error: nil];
        NSString *jsonStr = [[NSString alloc] initWithData: jsonData
                                                  encoding: NSUTF8StringEncoding];
        
        NSString *responseQRCode = [boxAPI getQRCode: [wTools getUserID] token: [wTools getUserToken] type: @"album" type_id: _albumid effect: @"execute" is: jsonStr];
        
        dispatch_async(dispatch_get_main_queue(), ^{
          
            if (respone != nil) {
                NSLog(@"response from getCooperationList: %@", respone);
                NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                NSDictionary *dicQR = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [responseQRCode dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                NSLog(@"response from getQRCode: %@", responseQRCode);
                NSLog(@"dicQR: %@", dicQR);
                
                if ([dic[@"result"] boolValue]) {
                    mydataarr=[NSMutableArray arrayWithArray:dic[@"data"]];
                    
                    for (NSDictionary *userdic in mydataarr) {
                        NSLog(@"userdic cooperation identity: %@", userdic[@"cooperation"][@"identity"]);
                        
                        if ([userdic[@"cooperation"][@"identity"] isEqualToString:@"admin"]) {
                            adminuser=userdic;
                            [mydataarr removeObject:userdic];
                            break;
                        }
                    }
                    
                    [self.refreshControl endRefreshing];
                    [mytable reloadData];
                } else{
                    [self.refreshControl endRefreshing];
                    
                    NSLog(@"失敗: %@", dic[@"message"]);
                }
                
                if ([dicQR[@"result"] boolValue]) {
                    qrImageStr = dicQR[@"data"];
                } else {
                    
                }
            } else {
                [self.refreshControl endRefreshing];
            }
            
            [wTools HideMBProgressHUD];
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CIImage *)createQRForString: (NSString *)qrString
{
    //NSData *stringData = [qrString dataUsingEncoding: NSISOLatin1StringEncoding allowLossyConversion: false];
    
    NSData *stringData = [[NSData alloc] initWithBase64EncodedString: qrString options: NSDataBase64DecodingIgnoreUnknownCharacters];
    
    CIFilter *qrFilter = [CIFilter filterWithName: @"CIQRCodeGenerator"];
    [qrFilter setValue: stringData forKey: @"inputMessage"];
    [qrFilter setValue: @"Q" forKey: @"inputCorrectionLevel"];
    
    return qrFilter.outputImage;
}

- (UIImage *)decodeBase64ToImage: (NSString *)strEncodeData
{
    NSData *data = [[NSData alloc] initWithBase64EncodedString: strEncodeData options: NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData: data];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (adminuser.allKeys.count==0) {
        return 0;
    }
    if (section==0) {
        return 1;
    }
    // Return the number of rows in the section.
    
    return mydataarr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section==0) {
        return 120;
    }
    return 56;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // NSString *identifier = [NSString stringWithFormat:@"HomeTableViewCell_%@", [[[pictures objectAtIndex:indexPath.row] objectForKey:@"album"]objectForKey:@"album_id" ]];
    
    NSString *CellIdentifier=@"CopperatiocTableViewCell";
    
    if (indexPath.section==0) {
        CellIdentifier=@"CoopTopTableViewCell";
        CoopTopTableViewCell *topc=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (topc == nil) {
            [tableView registerNib:[UINib nibWithNibName:@"CoopTopTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
            topc=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        }
        topc.selectionStyle=UITableViewCellSelectionStyleNone;

        NSDictionary *dic=adminuser;
        topc.name.text=dic[@"user"][@"name"];
        topc.photo.image=[UIImage imageNamed:@"1-02a1track_photo.png"];
        
        if (![dic[@"user"][@"picture"] isKindOfClass:[NSNull class]]) {
            [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: topc.photo];
            topc.photo.imageURL=[NSURL URLWithString:dic[@"user"][@"picture"]];
            [[topc.photo layer]setMasksToBounds:YES];
        }
        
        topc.btn1select=^(BOOL bo){
            //CooperationAddViewController *cadd=[[CooperationAddViewController alloc]initWithNibName:@"CooperationAddViewController" bundle:nil];
            CooperationAddViewController *cadd = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"CooperationAddViewController"];
            
            cadd.albumid=_albumid;
            [self.navigationController pushViewController:cadd animated:YES];
            
            //[self performSegueWithIdentifier: @"showCooperationAddViewController" sender: self];
        };

        topc.btn2select = ^(BOOL bo) {
            NSLog(@"qrCodeScan Touch");
            
            dimBackgroundUIView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
            dimBackgroundUIView.backgroundColor = [UIColor whiteColor];
            dimBackgroundUIView.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
            
            [self.view addSubview: dimBackgroundUIView];
            
            /*
            if (!UIAccessibilityIsReduceTransparencyEnabled()) {
                dimBackgroundUIView.backgroundColor = [UIColor clearColor];
                
                UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle: UIBlurEffectStyleLight];
                UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect: blurEffect];
                blurEffectView.frame = self.view.bounds;
                blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                
                [dimBackgroundUIView addSubview: blurEffectView];
            } else {
                dimBackgroundUIView.backgroundColor = [UIColor blackColor];
            }
            */
            //CIImage *qrcodeImage = [self createQRForString: qrImageStr];
            //CIImage *qrcodeImage = [self createQRForString: @"http://www.appcoda.com"];
            
            //UIImage *image = [UIImage imageWithCIImage: qrcodeImage scale: [UIScreen mainScreen].scale orientation: UIImageOrientationUp];
            
            imageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 200, 200)];
            imageView.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
            
            /*
            CGFloat scaleX = imageView.frame.size.width / qrcodeImage.extent.size.width;
            CGFloat scaleY = imageView.frame.size.height / qrcodeImage.extent.size.height;
            CIImage *transformedImage = [qrcodeImage imageByApplyingTransform: CGAffineTransformMakeScale(scaleX, scaleY)];
            */
            
            //imageView.image = [UIImage imageWithCIImage: transformedImage];
            
            imageView.image = [self decodeBase64ToImage: qrImageStr];
            
            [UIView beginAnimations: nil context: nil];
            [UIView setAnimationDuration: 1.0];
            [UIView setAnimationDelay: 1.0];
            [UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
            [self.view addSubview: imageView];
            [UIView commitAnimations];
            
            //containerView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 220, 220)];
            //containerView.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
            
            //[dimBackgroundUIView addSubview: imageView];
            //[containerView addSubview: imageView];
            
        };
        
        return topc;
    }
    
    CopperatiocTableViewCell *cell=nil;
    cell= [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"CopperatiocTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
        cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    NSDictionary *dic=mydataarr[indexPath.row];
    cell.name.text=dic[@"user"][@"name"];
    cell.photo.image=[UIImage imageNamed:@"1-02a1track_photo.png"];
    
    if (![dic[@"user"][@"picture"] isKindOfClass:[NSNull class]]) {
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: cell.photo];
        cell.photo.imageURL=[NSURL URLWithString:dic[@"user"][@"picture"]];
        [[cell.photo layer]setMasksToBounds:YES];
    }
    
    cell.type=[NSString stringWithFormat:@"%@",dic[@"cooperation"][@"identity"]];
    
    if ([cell.type isEqualToString:@"admin"]) {
        cell.typetitle.text=NSLocalizedString(@"CreateAlbumText-admin", @"");
    }else if ([cell.type isEqualToString:@"approver"]){
        cell.typetitle.text=NSLocalizedString(@"CreateAlbumText-admin2", @"");
    }else if ([cell.type isEqualToString:@"editor"]){
        cell.typetitle.text=NSLocalizedString(@"CreateAlbumText-sharer", @"");
    }else{
        cell.typetitle.text=NSLocalizedString(@"CreateAlbumText-viewer", @"");
    }
    
    cell.btn1select=^(BOOL bo){
        NSLog(@"identity: %@", _identity);
        NSLog(@"mydataarr: %@", mydataarr);
        NSLog(@"indexPath.row: %ld", (long)indexPath.row);
        NSLog(@"mydataarr row: %@", mydataarr[indexPath.row]);
        
        if ([_identity isEqualToString:@"admin"] || [_identity isEqualToString: @"approver"]) {
            //修改權限
            selectuserid=[dic[@"user"][@"user_id"] stringValue];
            SBookSelectViewController *SBSVC=[[SBookSelectViewController alloc]initWithNibName:@"SBookSelectViewController" bundle:nil];
            SBSVC.mytitletext=NSLocalizedString(@"CreateAlbumText-tipAssignRole", @"");
            SBSVC.delegate=self;
            SBSVC.data=@[NSLocalizedString(@"CreateAlbumText-admin2", @""),NSLocalizedString(@"CreateAlbumText-sharer", @""),NSLocalizedString(@"CreateAlbumText-viewer", @"")];
            SBSVC.topViewController=self;                        
            
            NSString *identityStr = mydataarr[indexPath.row][@"cooperation"][@"identity"];
            NSLog(@"identityStr: %@", identityStr);
            
            // Check the array member whether is approver or not
            if ([identityStr isEqualToString: @"approver"]) {
                
                // Check the user of editing album is approver or not
                if (![_identity isEqualToString: @"admin"]) {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"" message: @"副管理者不能變更副管理者的權限" preferredStyle: UIAlertControllerStyleAlert];
                    UIAlertAction *okBtn = [UIAlertAction actionWithTitle: @"確認" style: UIAlertActionStyleDefault handler:nil];
                    [alert addAction: okBtn];
                    [self presentViewController: alert animated: YES completion: nil];
                } else {
                    [self wu2presentPopupViewController:SBSVC animated:YES completion:nil];
                }
                
            } else {
                [self wu2presentPopupViewController:SBSVC animated:YES completion:nil];
            }
            
        } else {
            Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
            [rv addtitletext:NSLocalizedString(@"CreateAlbumText-tipPermissions", @"")];
            [rv addBackTouch];
            [rv showView:self.view];
            return;
        }
    };
    
    return cell;
}

//選擇器回傳
-(void)SaveDataRow:(NSInteger)row{
    NSArray *arr = @[@"approver",@"editor",@"viewer"];
    NSString *type = [NSString stringWithFormat:@"%@", arr[row]];
    
    [wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSMutableDictionary *data=[NSMutableDictionary new];
        [data setObject:_albumid forKey:@"type_id"];
        [data setObject:@"album" forKey:@"type"];
        [data setObject:type forKey:@"identity"];
        [data setObject:selectuserid forKey:@"user_id"];
        NSString *respone=[boxAPI updatecooperation:[wTools getUserID] token:[wTools getUserToken] data:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];

            if (respone!=nil) {
                NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                if ([dic[@"result"]boolValue]) {
                     [self w2dismissPopupViewControllerAnimated:YES completion:nil];
                }
            }
            
        });
        
    });
}


//選擇中
-(void)DidselectDataRow:(NSInteger)row{
    
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==0) {
        return NO;
    }
    return YES;
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"GeneralText-del", @"") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
          {
            //刪除動作
           [wTools ShowMBProgressHUD];
           dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
               
               
                NSDictionary *dic=mydataarr[indexPath.row];
            NSMutableDictionary *data=[NSMutableDictionary new];
                  [data setObject:_albumid forKey:@"type_id"];
                  [data setObject:@"album" forKey:@"type"];
                  [data setObject:[dic[@"user"][@"user_id"] stringValue] forKey:@"user_id"];
               NSString *respone=[boxAPI deletecooperation:[wTools getUserID] token:[wTools getUserToken] data:data];
               
            dispatch_async(dispatch_get_main_queue(), ^{
              [wTools HideMBProgressHUD];
                                                
                    if (respone!=nil) { NSDictionary *dic= (NSDictionary *)   [NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    if ([dic[@"result"]boolValue]) {
                        [self reload];
                        }
                       }
                                                
                     });
                                            
           });

                                        
                                        
                                        
                                    }];
    button.backgroundColor = [wTools colorFromHexString:@"#12b0b3"]; //arbitrary color

    return @[button];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // No statement or algorithm is needed in here. Just the implementation
}
//-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    if (indexPath.section==0) {
//        return UITableViewCellEditingStyleNone;
//    }
//    
//    return UITableViewCellEditingStyleDelete;
//}

/*
- (void)performSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString: @"showCooperationAddViewController"]) {
        CooperationAddViewController *cadd = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"CooperationAddViewController"];
        cadd.albumid=_albumid;
        [self.navigationController pushViewController:cadd animated:YES];
    }
}
*/

@end
