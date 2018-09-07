//
//  PreviewbookViewController.m
//  wPinpinbox
//
//  Created by Angus on 2015/10/28.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "PreviewbookViewController.h"
#import "WDownloadManager.h"
#import "MZUtility.h"
#import "ZipArchive.h"
#import "wTools.h"
#import "boxAPI.h"
#import "CalbumlistViewController.h"
#import "RetrievealbumpViewController.h"
#import "Remind.h"
#import "AppDelegate.h"

#define degreesToRadians(x) ((x) * (M_PI / 180.0))

#import "CustomIOSAlertView.h"
#import <SafariServices/SafariServices.h>
#import "BookViewController.h"
#import "MBProgressHUD.h"

#import "GlobalVars.h"

#import "UIColor+Extensions.h"
#import "UIViewController+ErrorAlert.h"

@interface PreviewbookViewController () <MZDownloadDataSource, MZDownloadDelegate, SFSafariViewControllerDelegate>
{
    int tmp;
    
    WDownloadManager *down;
    __weak IBOutlet UIView *precentageView;
    BOOL isPlay;
    NSString *name;
    
    __weak IBOutlet AsyncImageView *imageview;
    
    
    // For Showing Message of Getting Point
    NSString *missionTopicStr;
    NSString *rewardType;
    NSString *rewardValue;
    NSString *eventUrl;
    
    CustomIOSAlertView *alertView;
}

@property (weak, nonatomic) IBOutlet UILabel *PercentageLab;

@property (nonatomic) NSTimer *timer;
@end

@implementation PreviewbookViewController
@synthesize timer = _timer;

- (void)setTimer:(NSTimer *)timer {
    if ([_timer isValid]) {
        [_timer invalidate];
    }
    _timer = timer;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSLog(@"PreviewbookViewController");
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed: 92.0/255.0 green: 92.0/255.0 blue: 92.0/255.0 alpha: 1.0];
        
    NSMutableArray *array=[NSMutableArray new];
    
    for (int i=0; i<=8; i++) {
        [array addObject:[UIImage imageNamed:[NSString stringWithFormat:@"pinpin_%i.png",i]]];
    }
    
    animatimageview.contentMode=UIViewContentModeScaleAspectFill;
    animatimageview.animationImages=array;
    animatimageview.animationDuration=1.0;
    animatimageview.animationRepeatCount=0;
    
    [animatimageview startAnimating];
    stopbtn.selected=YES;
    // NSString *docDirectoryPath = [fileDest stringByAppendingPathComponent:fileName];
    
    //取得資料ID
    name=[NSString stringWithFormat:@"%@%@",[wTools getUserID],_albumid];
    NSString *docDirectoryPath = [filepinpinboxDest stringByAppendingPathComponent:name];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //檢查資料夾是否存在
    if ([fileManager fileExistsAtPath:docDirectoryPath]) {
        
        NSLog(@"存在 更新下載");
        NSFileManager *fm=[NSFileManager defaultManager];
        NSString *infoPath=[docDirectoryPath stringByAppendingPathComponent:@"info.txt"];
        
        if ([fm fileExistsAtPath:infoPath]) {
            NSString *str=[NSString stringWithContentsOfFile:infoPath encoding:NSUTF8StringEncoding error:nil];
            NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding]  options:NSJSONReadingMutableContainers error:nil];
            NSString *unixt= dic[@"modifytime"];
             
            //[wTools ShowMBProgressHUD];
            [MBProgressHUD showHUDAddedTo: self.view animated: YES];
            
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                
                NSString *respone=[boxAPI checkalbumzip:[wTools getUserID] token:[wTools getUserToken] album_id:_albumid];
                dispatch_async(dispatch_get_main_queue(), ^{
                    //[wTools HideMBProgressHUD];
                    [MBProgressHUD hideHUDForView: self.view animated: YES];
                    
                    if (respone!=nil) {
                        NSLog(@"%@",respone);
                        NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                         
                        if ([dic[@"result"] intValue] == 1) {
                            if ([unixt isEqualToString:[dic[@"data"][@"modifytime"] stringValue]]) {
                                //未過期
                                [self.navigationController popViewControllerAnimated:NO];
                                //[wTools ReadBookalbumid:_albumid userbook:_userbook];
                                [wTools ReadBookalbumid: _albumid userbook: _userbook eventId: nil postMode: nil fromEventPostVC: nil];
                                //[self ReadBookalbumid: _albumid userbook: _userbook eventId: nil postMode: nil];
                                 
                            } else if ([dic[@"result"] intValue] == 0) {
                                 //已過期 下載新檔案
                                 [fileManager removeItemAtPath:docDirectoryPath error:nil];
                                 [self downbook];
                            } else {
                                [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                            }
                        }
                    }
                });
            });
             
            return;
            
         } else {
              [self downbook];
         }
    
    } else {
        NSLog(@"相本不存在，開始下載流程。");
        
        [self downbook];
    }
    
    //animatimageview.hidden = YES;
    //precentageView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // NavigationBar Setup
    //self.navigationController.navigationBar.hidden = YES;
    
    //[[UIApplication sharedApplication] setStatusBarHidden: YES];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed: 92.0/255.0 green: 92.0/255.0 blue: 92.0/255.0 alpha: 1.0];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // NavigationBar Setup
    //self.navigationController.navigationBar.hidden = NO;
    
    //[[UIApplication sharedApplication] setStatusBarHidden: NO];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed: 32.0/255.0 green: 191.0/255.0 blue: 193.0/255.0 alpha: 1.0];
}

- (void)ReadBookalbumid:(NSString *)albumid userbook:(NSString *)userbook eventId: (NSString *)eventId postMode: (BOOL)postMode {
    
    //檢查本地...
    NSString *nameOfFile = [NSString stringWithFormat:@"%@%@",[wTools getUserID],albumid];
    NSString *docDirectoryPath = [filepinpinboxDest stringByAppendingPathComponent: nameOfFile];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //檢查資料夾是否存在
    if ([fileManager fileExistsAtPath:docDirectoryPath]) {
        NSLog(@"存在%@",albumid);
        
        //判斷是否需要更新
        NSFileManager *fm=[NSFileManager defaultManager];
        NSString *infoPath=[docDirectoryPath stringByAppendingPathComponent:@"info.txt"];
        
        if ([fm fileExistsAtPath:infoPath]) {
            NSString *str=[NSString stringWithContentsOfFile:infoPath encoding:NSUTF8StringEncoding error:nil];
            NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding]  options:NSJSONReadingMutableContainers error:nil];
            NSString *unixt= dic[@"modifytime"];
            
            NSLog(@"unixt:%@",unixt);
            
            //[wTools ShowMBProgressHUD];
            [MBProgressHUD showHUDAddedTo: self.view animated: YES];
            
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                
                NSString *respone=[boxAPI checkalbumzip:[wTools getUserID] token:[wTools getUserToken] album_id:albumid];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //[wTools HideMBProgressHUD];
                    [MBProgressHUD hideHUDForView: self.view animated: YES];
                    
                    if (respone!=nil) {
                        NSLog(@"%@",respone);
                        NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                        
                        if ([dic[@"result"] intValue] == 1) {
                            if (![unixt isEqualToString:[dic[@"data"][@"modifytime"] stringValue]]) {
                                //已過期 下載新檔案
                                
                                [self performSegueWithIdentifier: @"showPreviewbookViewController" sender: self];
                                return;
                            }
                            [self performSegueWithIdentifier: @"showBookViewController" sender: self];
                        }else{
                            [self performSegueWithIdentifier: @"showBookViewController" sender: self];
                        }
                    }else{
                        [self performSegueWithIdentifier: @"showBookViewController" sender: self];
                    }
                });
            });
        } else {
            NSLog(@"沒有info");
            Remind *rv=[[Remind alloc]initWithFrame: self.view.bounds];
            [rv addtitletext:[NSString stringWithFormat:@"錯誤 因為沒有檔案(%@)",albumid]];
            [rv addBackTouch];
            [rv showView: self.view];
        }
    } else {
        //檢查下載
        [self performSegueWithIdentifier: @"showPreviewbookViewController" sender: self];
    }
}

- (void)downbook {
    NSLog(@"downbook");
    
    //[wTools ShowMBProgressHUD];
    [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
    NSString *respone=[boxAPI buyalbum:[wTools getUserID] token:[wTools getUserToken] albumid:_albumid];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[wTools HideMBProgressHUD];
            [MBProgressHUD hideHUDForView: self.view animated: YES];
            
            if ([_userbook isEqualToString:@"Y"]) {
                NSLog(@"userBook is equal to string Y");
                [self playdown];
                return ;
            }
            
            if (respone!=nil) {
                NSLog(@"response from buyAlbum API");
                NSLog(@"%@",respone);
                NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                if ([dic[@"result"] intValue] == 1) {
                    NSLog(@"result: %d", [dic[@"result"] boolValue]);
                    
                    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:imageview];
                    NSString *cover=dic[@"data"][@"coverurl"];
                    
                    if (![cover isKindOfClass:[NSNull class]]) {
                        imageview.imageURL=[NSURL URLWithString:cover];
                    }
                    [self playdown];
                } else if ([dic[@"result"] intValue] == 0) {
                    NSLog(@"失敗：%@",dic[@"message"]);
                    Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
                    //[rv addtitletext:[NSString stringWithFormat:@"%@%@",dic[@"message"],_albumid]];
                    [rv addtitletext: @"連線中斷 請重新載入"];
                    [rv addBackTouch];
                    [rv showView:self.view];                                        
                } else {
                    Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
                    //[rv addtitletext:[NSString stringWithFormat:@"%@%@",dic[@"message"],_albumid]];
                    [rv addtitletext: NSLocalizedString(@"Host-NotAvailable", @"")];
                    [rv addBackTouch];
                    [rv showView:self.view];
                }
            }
        });
    });
}

//啟動下載
-(void)playdown{
    NSLog(@"play down");
    
    isPlay=YES;
    
    // Do any additional setup after loading the view from its nib.
    _loadview.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    _loadview.progress=0.0f;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(incrementProgress:) userInfo:nil repeats:YES];

    NSLog(@"WDownloadManager Setting");
    
    down=[WDownloadManager getInstance];
    down.delegate=self;
    down.dataSoure=self;
    down.downloadingArray=[NSMutableArray new];
    down.sessionManager = [down backgroundSession];
    [down populateOtherDownloadTasks];
    
    //還在下載的
    for(int i =0; i<down.downloadingArray.count;i++){
        
        NSMutableDictionary *dic=down.downloadingArray[i];
        
        NSString *filename=dic[@"fileName"];
        
        if ([filename isEqualToString:name]) {
            NSURLSessionDownloadTask *downloadTask = [dic objectForKey:kMZDownloadKeyTask];
            NSString *downloadingStatus = [dic objectForKey:kMZDownloadKeyStatus];
            
            if([downloadingStatus isEqualToString:RequestStatusPaused])
            {
                [downloadTask resume];
                [dic setObject:RequestStatusDownloading forKey:kMZDownloadKeyStatus];
                
                [down.downloadingArray replaceObjectAtIndex:i withObject:dic];
                // [self updateCell:cell forRowAtIndexPath:indexPath];
            }
            
            return;
        }
    }
    
    NSMutableDictionary *data=[NSMutableDictionary new];
    [data setObject:_albumid forKey:@"albumid"];
    [data setObject:[wTools getUserID] forKey:@"id"];
    [data setObject:[wTools getUserToken] forKey:@"token"];
    [data setObject:[boxAPI signGenerator2:data] forKey:@"sign"];
    
    // Call Protocol 14 downloadAlbumZip
    NSLog(@"down waddDownloadTask");
    [down waddDownloadTask:name fileURL:[NSString stringWithFormat:@"%@/downloadalbumzip%@",ServerURL,@"/1.1"] data:data];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)stop:(UIButton *)sender {
    sender.selected=!sender.selected;
    
    int row=0;
    BOOL isdic=YES;
    NSMutableDictionary *downloadInfo =nil;
    
    for( int i =0;i<down.downloadingArray.count ;i++){
        NSMutableDictionary *dic=down.downloadingArray[i];
        
        NSString *filename=dic[@"fileName"];
        if ([filename isEqualToString:name]) {
            downloadInfo=dic;
            isdic=NO;
            row=i;
            break;
        }
    }
    if (isdic) {
        return;
    }
    
    NSURLSessionDownloadTask *downloadTask = [downloadInfo objectForKey:kMZDownloadKeyTask];
//    NSString *downloadingStatus = [downloadInfo objectForKey:kMZDownloadKeyStatus];
    
    if (sender.selected) {
        isPlay=YES;
        animatimageview.hidden=NO;
        precentageView.hidden=YES;
        
        [downloadTask resume];
        [downloadInfo setObject:RequestStatusDownloading forKey:kMZDownloadKeyStatus];
        
        [down.downloadingArray replaceObjectAtIndex:row withObject:downloadInfo];

    }else{
       isPlay=NO;
        animatimageview.hidden=YES;
        precentageView.hidden=NO;
        [downloadTask suspend];
        [downloadInfo setObject:RequestStatusPaused forKey:kMZDownloadKeyStatus];
        [downloadInfo setObject:[NSDate date] forKey:kMZDownloadKeyStartTime];
        
        [down.downloadingArray replaceObjectAtIndex:row withObject:downloadInfo];
    }
}

#pragma mark - Timer

- (void)incrementProgress:(NSTimer *)timer {
    
    if (isPlay) {
        _loadimg.transform=CGAffineTransformMakeRotation(degreesToRadians(tmp++));
    }
}


- (IBAction)back:(id)sender {
    
    NSLog(@"PreviewbookViewController");
    
    NSLog(@"back");
    
    NSArray *vcarr=self.navigationController.viewControllers;
    
    for (int i=vcarr.count-2  ;i>0  ;i--) {
        UIViewController *vc=vcarr[i];
        
        if ([vc isKindOfClass:[CalbumlistViewController class]] ||  [vc isKindOfClass:[RetrievealbumpViewController class]]) {
            NSLog(@"vc is kind of class");
            
            [self.navigationController popToViewController:vc animated:YES];
            return;
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - MZDownloadManager Delegates

//下載開始
-(void)downloadRequestStarted:(NSURLSessionDownloadTask *)downloadTask
{
    NSLog(@"下載開始");
}

//回傳下載進度
- (void)downloadfileName:(NSString *)fileName progress:(float)progress{
    NSLog(@"downloadfileName");
    NSLog(@"%@-%f%@",fileName,progress,@"%");
    _loadview.progress = progress;
    _PercentageLab.text = [NSString stringWithFormat: @"%.0f", 100 * _loadview.progress];
    
    NSLog(@"_PercentageLab.text: %@", _PercentageLab.text);
}

-(NSString *)downloadRequestfileName {
    NSLog(@"downloadRequestfileName");
    return name;
}

//下載完成
-(void)downloadRequestFinished:(NSString *)fileName
{
    NSLog(@"downloadRequestFinished");
    
    NSString *docDirectoryPath = [filepinpinboxDest stringByAppendingPathComponent:fileName];
    
    //[wTools ShowMBProgressHUD];
    [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *respone=[boxAPI checkalbumzip:[wTools getUserID] token:[wTools getUserToken] album_id:_albumid];
        dispatch_async(dispatch_get_main_queue(), ^{
            //[wTools HideMBProgressHUD];
            [MBProgressHUD hideHUDForView: self.view animated: YES];
            
            if (respone!=nil) {
                NSLog(@"%@",respone);
                NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                if ([dic[@"result"]boolValue]) {
                    
                    NSFileManager *fm=[NSFileManager defaultManager];
                    NSString *infoPath=[docDirectoryPath stringByAppendingPathComponent:@"info.txt"];
                    
                    if ([fm fileExistsAtPath:infoPath]) {
                        NSString *str=[NSString stringWithContentsOfFile:infoPath encoding:NSUTF8StringEncoding error:nil];
                        NSMutableDictionary *info=[NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)[NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding]  options:NSJSONReadingMutableContainers error:nil]];
                        
                        NSString *modifytime=[dic[@"data"][@"modifytime"] stringValue];
                        [info setObject:modifytime forKey:@"modifytime"];
                        
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:info
                                                                           options:0 error:nil];
                        NSString *jsonstr=[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                        
                        if ([jsonstr writeToFile:infoPath atomically:YES encoding:NSUTF8StringEncoding error:nil]) {
                            NSLog(@"寫入成功");
                        }
                        
                        NSLog(@"下載完成-fileName %@",docDirectoryPath);
                        
                        [self.navigationController popViewControllerAnimated:NO];
                        
                        NSLog(@"self.fromEventPostVC: %d", self.fromEventPostVC);
                        
                        //[wTools ReadBookalbumid:_albumid userbook:_userbook];
                        [wTools ReadBookalbumid: _albumid userbook: _userbook eventId: _eventId postMode: _postMode fromEventPostVC: _fromEventPostVC];
                        //[self ReadBookalbumid: _albumid userbook: _userbook eventId: _eventId postMode: _postMode];
                    }
                }
            }
        });
    });
}

//下載取消
-(void)downloadRequestCanceled:(NSURLSessionDownloadTask *)downloadTask
{
    NSLog(@"downloadRequestCanceled");
    NSLog(@"下載取消");
}

//下載失敗
-(void)downloadfail:(NSString *)error{
    Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
    [rv addtitletext:[NSString stringWithFormat:@"%@%@",error,_albumid]];
    [rv addBackTouch];
    [rv showView:self.view];
}

#pragma mark -

/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString: @"showPreviewbookViewController"]) {
        //PreviewbookViewController *rv=[[PreviewbookViewController alloc]initWithNibName:@"PreviewbookViewController" bundle:nil];
        PreviewbookViewController *rv = segue.destinationViewController;
        rv.albumid = _albumid;
        rv.userbook = _userbook;
    }
    if ([segue.identifier isEqualToString: @"showBookViewController"]) {
        NSString *nameOfFile = [NSString stringWithFormat:@"%@%@",[wTools getUserID], _albumid];
        NSString *docDirectoryPath = [filepinpinboxDest stringByAppendingPathComponent: nameOfFile];
        
        //BookViewController *bv=[[BookViewController alloc]initWithNibName:@"BookViewController" bundle:nil];
        BookViewController *bv = segue.destinationViewController;
        bv.albumid = _albumid;
        bv.DirectoryPath = docDirectoryPath;
        bv.postMode = _postMode;
        bv.eventId = _eventId;
    }
}
*/

- (void)performSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    NSLog(@"performSegueWithIdentifier");
    
    if ([identifier isEqualToString: @"showPreviewbookViewController"]) {
        NSLog(@"showPreviewbookViewController");
        PreviewbookViewController *rv = [[PreviewbookViewController alloc] initWithNibName:@"PreviewbookViewController" bundle:nil];
        //PreviewbookViewController *rv = [[UIStoryboard storyboardWithName: @"Home" bundle:nil] instantiateViewControllerWithIdentifier: @"PreviewbookViewController"];
        rv.albumid = _albumid;
        rv.userbook = _userbook;
        
        //[self.navigationController pushViewController: rv animated: YES];
        
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app.myNav pushViewController: rv animated: YES];
        
    }
    if ([identifier isEqualToString: @"showBookViewController"]) {
        NSLog(@"showBookViewController");
        NSString *nameOfFile = [NSString stringWithFormat:@"%@%@",[wTools getUserID], _albumid];
        NSString *docDirectoryPath = [filepinpinboxDest stringByAppendingPathComponent: nameOfFile];
        
        BookViewController *bv = [[BookViewController alloc] initWithNibName: @"BookViewController" bundle: nil];
        //BookViewController *bv = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"BookViewController"];
        bv.albumid = _albumid;
        bv.DirectoryPath = docDirectoryPath;
        bv.postMode = _postMode;
        bv.eventId = _eventId;
        
        //[self.navigationController pushViewController: bv animated: YES];
        
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app.myNav pushViewController: bv animated: YES];
    }
}

#pragma mark - Custom Error Alert Method
- (void)showCustomErrorAlert: (NSString *)msg {
    
    [UIViewController showCustomErrorAlertWithMessage:msg onButtonTouchUpBlock:^(CustomIOSAlertView *customAlertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[customAlertView tag]);
        [customAlertView close];
    }];
  
}
/*
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
*/
@end
