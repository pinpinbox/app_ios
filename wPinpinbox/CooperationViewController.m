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

#import "CustomIOSAlertView.h"
#import "UIColor+Extensions.h"

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
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSMutableDictionary *data=[NSMutableDictionary new];
        [data setObject:wself.albumid forKey:@"type_id"];
        [data setObject:@"album" forKey:@"type"];
        NSString *respone = [boxAPI getcooperationlist:[wTools getUserID] token:[wTools getUserToken] data:data];
        
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
        
        NSString *responseQRCode = [boxAPI getQRCode: [wTools getUserID] token: [wTools getUserToken] type: @"album" type_id: wself.albumid effect: @"execute" is: jsonStr];
        
        dispatch_async(dispatch_get_main_queue(), ^{
          
            if (respone != nil) {
                NSLog(@"response from getCooperationList: %@", respone);
                NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                NSDictionary *dicQR = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [responseQRCode dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                NSLog(@"response from getQRCode: %@", responseQRCode);
                NSLog(@"dicQR: %@", dicQR);
                
                if ([dic[@"result"] intValue] == 1) {
                    wself->mydataarr=[NSMutableArray arrayWithArray:dic[@"data"]];
                    
                    for (NSDictionary *userdic in wself->mydataarr) {
                        NSLog(@"userdic cooperation identity: %@", userdic[@"cooperation"][@"identity"]);
                        
                        if ([userdic[@"cooperation"][@"identity"] isEqualToString:@"admin"]) {
                            wself->adminuser=userdic;
                            [wself->mydataarr removeObject:userdic];
                            break;
                        }
                    }
                    [wself.refreshControl endRefreshing];
                    [wself->mytable reloadData];
                } else if ([dic[@"result"] intValue] == 0) {
                    NSLog(@"失敗：%@",dic[@"message"]);
                    [wself showCustomErrorAlert: dic[@"message"]];
                    [wself.refreshControl endRefreshing];
                } else {
                    [wself showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    [wself.refreshControl endRefreshing];
                }

                if ([dicQR[@"result"] intValue] == 1) {
                    wself->qrImageStr = dicQR[@"data"];
                } else if ([dicQR[@"result"] intValue] == 0) {
                    NSLog(@"失敗：%@",dicQR[@"message"]);
                    [wself showCustomErrorAlert: dicQR[@"message"]];
                } else {
                    [wself showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                }
            } else {
                [wself.refreshControl endRefreshing];
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
        __block typeof(self.albumid) aid = self.albumid;
        topc.btn1select=^(BOOL bo){
            //CooperationAddViewController *cadd=[[CooperationAddViewController alloc]initWithNibName:@"CooperationAddViewController" bundle:nil];
            CooperationAddViewController *cadd = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"CooperationAddViewController"];
            
            cadd.albumid=aid;
            [self.navigationController pushViewController:cadd animated:YES];
            
            //[self performSegueWithIdentifier: @"showCooperationAddViewController" sender: self];
        };
        __block typeof(self) wself = self;
        topc.btn2select = ^(BOOL bo) {
            NSLog(@"qrCodeScan Touch");
            
            wself->dimBackgroundUIView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
            wself->dimBackgroundUIView.backgroundColor = [UIColor whiteColor];
            wself->dimBackgroundUIView.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
            
            [wself.view addSubview: wself->dimBackgroundUIView];
            
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
            
            wself->imageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 200, 200)];
            wself->imageView.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
            
            /*
            CGFloat scaleX = imageView.frame.size.width / qrcodeImage.extent.size.width;
            CGFloat scaleY = imageView.frame.size.height / qrcodeImage.extent.size.height;
            CIImage *transformedImage = [qrcodeImage imageByApplyingTransform: CGAffineTransformMakeScale(scaleX, scaleY)];
            */
            
            //imageView.image = [UIImage imageWithCIImage: transformedImage];
            
            wself->imageView.image = [self decodeBase64ToImage: wself->qrImageStr];
            
            [UIView beginAnimations: nil context: nil];
            [UIView setAnimationDuration: 1.0];
            [UIView setAnimationDelay: 1.0];
            [UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
            [wself.view addSubview: wself->imageView];
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
    __block typeof(self) wself = self;
    
    cell.btn1select=^(BOOL bo){
        NSLog(@"identity: %@", wself.identity);
        NSLog(@"mydataarr: %@", wself->mydataarr);
        NSLog(@"indexPath.row: %ld", (long)indexPath.row);
        NSLog(@"mydataarr row: %@", wself->mydataarr[indexPath.row]);
        
        if ([wself.identity isEqualToString:@"admin"] || [wself.identity isEqualToString: @"approver"]) {
            //修改權限
            wself->selectuserid=[dic[@"user"][@"user_id"] stringValue];
            SBookSelectViewController *SBSVC=[[SBookSelectViewController alloc]initWithNibName:@"SBookSelectViewController" bundle:nil];
            SBSVC.mytitletext=NSLocalizedString(@"CreateAlbumText-tipAssignRole", @"");
            SBSVC.delegate=self;
            SBSVC.data=@[NSLocalizedString(@"CreateAlbumText-admin2", @""),NSLocalizedString(@"CreateAlbumText-sharer", @""),NSLocalizedString(@"CreateAlbumText-viewer", @"")];
            SBSVC.topViewController=self;                        
            
            NSString *identityStr = wself->mydataarr[indexPath.row][@"cooperation"][@"identity"];
            NSLog(@"identityStr: %@", identityStr);
            
            // Check the array member whether is approver or not
            if ([identityStr isEqualToString: @"approver"]) {
                
                // Check the user of editing album is approver or not
                if (![wself.identity isEqualToString: @"admin"]) {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"" message: @"副管理者不能變更副管理者的權限" preferredStyle: UIAlertControllerStyleAlert];
                    UIAlertAction *okBtn = [UIAlertAction actionWithTitle: @"確認" style: UIAlertActionStyleDefault handler:nil];
                    [alert addAction: okBtn];
                    [wself presentViewController: alert animated: YES completion: nil];
                } else {
                    [wself wu2presentPopupViewController:SBSVC animated:YES completion:nil];
                }
                
            } else {
                [wself wu2presentPopupViewController:SBSVC animated:YES completion:nil];
            }
            
        } else {
            Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
            [rv addtitletext:NSLocalizedString(@"CreateAlbumText-tipPermissions", @"")];
            [rv addBackTouch];
            [rv showView:wself.view];
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
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSMutableDictionary *data=[NSMutableDictionary new];
        [data setObject:wself.albumid forKey:@"type_id"];
        [data setObject:@"album" forKey:@"type"];
        [data setObject:type forKey:@"identity"];
        [data setObject:wself->selectuserid forKey:@"user_id"];
        NSString *respone=[boxAPI updatecooperation:[wTools getUserID] token:[wTools getUserToken] data:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];

            if (respone!=nil) {
                NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                if ([dic[@"result"] intValue] == 1) {
                     [wself w2dismissPopupViewControllerAnimated:YES completion:nil];
                } else if ([dic[@"result"] intValue] == 0) {
                    NSLog(@"失敗：%@",dic[@"message"]);
                    [wself showCustomErrorAlert: dic[@"message"]];
                } else {
                    [wself showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
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

-(NSArray *)tableView:(UITableView *)tableView
editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    __block typeof(self) wself = self;
    
    UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"GeneralText-del", @"") handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
          {
            //刪除動作
           [wTools ShowMBProgressHUD];
           dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
               
               
                NSDictionary *dic=wself->mydataarr[indexPath.row];
            NSMutableDictionary *data=[NSMutableDictionary new];
                  [data setObject:wself.albumid forKey:@"type_id"];
                  [data setObject:@"album" forKey:@"type"];
                  [data setObject:[dic[@"user"][@"user_id"] stringValue] forKey:@"user_id"];
               NSString *respone=[boxAPI deletecooperation:[wTools getUserID] token:[wTools getUserToken] data:data];
               
            dispatch_async(dispatch_get_main_queue(), ^{
              [wTools HideMBProgressHUD];
                                                
                    if (respone!=nil) {
                        NSDictionary *dic = (NSDictionary *)   [NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                        if ([dic[@"result"] intValue] == 1) {
                            [wself reload];
                        } else if ([dic[@"result"] intValue] == 0) {
                            NSLog(@"失敗：%@",dic[@"message"]);
                            [wself showCustomErrorAlert: dic[@"message"]];
                        } else {
                            [wself showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
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
    [errorAlertView setUseMotionEffects: YES];
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
