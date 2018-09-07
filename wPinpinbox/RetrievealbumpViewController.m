//
//  RetrievealbumpViewController.m
//  wPinpinbox
//
//  Created by Angus on 2015/10/26.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "RetrievealbumpViewController.h"

#import "AsyncImageView.h"
#import "PreviewbookViewController.h"
#import "wTools.h"
#import "boxAPI.h"
#import "Remind.h"
#import "CurrencyViewController.h"
#import "wShowImageList.h"
#import "SelectBarViewController.h"
#import "UIViewController+CWPopup.h"

#import "CustomIOSAlertView.h"
#import <SafariServices/SafariServices.h>

#import <FBSDKShareKit/FBSDKShareLinkContent.h>
#import <FBSDKShareKit/FBSDKShareDialog.h>

#import "UIImage+AverageColor.h"

//#import "BookViewController.h"
#import "ReadBookViewController.h"

#import "AppDelegate.h"

#import "CreativeViewController.h"

#import "MBProgressHUD.h"

#import "UIColor+Extensions.h"
#import "UIViewController+ErrorAlert.h"

static NSString *sharingLink = @"http://www.pinpinbox.com/index/album/content/?album_id=%@%@";
static NSString *autoPlayStr = @"&autoplay=1";

@interface RetrievealbumpViewController () <SelectBarDelegate, SFSafariViewControllerDelegate, FBSDKSharingDelegate>
{
    NSMutableArray *imagelist;
    BOOL own;
    NSArray *reportintentlist;
    
    // For Showing Message of Getting Point
    NSString *missionTopicStr;
    NSString *rewardType;
    NSString *rewardValue;
    NSString *eventUrl;
    
    CustomIOSAlertView *alertView;
    CustomIOSAlertView *alertViewForSharing;
    
    BOOL isFree;
}
@end

@implementation RetrievealbumpViewController

#pragma mark - View Related Methods

- (void)viewDidLoad{
    [super viewDidLoad];
    
    NSLog(@"RetrievealbumpViewController");
    NSLog(@"viewDidLoad");
    
    // Do any additional setup after loading the view from its nib.
    UITapGestureRecognizer *singleTap  = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(tapDetected)];
    singleTap.numberOfTapsRequired = 1;
    
    [_coverImage setUserInteractionEnabled: YES];
    [_coverImage addGestureRecognizer: singleTap];
    
    // UI Settings
    NSString *imageUrl;
    
    NSLog(@"_data: %@", _data);
    
    if ([_data[@"photo"][0][@"image_url"] isEqual: [NSNull null]]) {
        imageUrl = @"https://ppb.sharemomo.com/static_file/pinpinbox/zh_TW/images/origin.jpg";
    } else {
        imageUrl = _data[@"photo"][0][@"image_url"];
    }
    
    NSLog(@"imageUrl :%@", imageUrl);
    
    _coverImage.image = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString: imageUrl]]];
    
    // Call this method in viewDidLoad first to avoid data flash on the screen
    [self getAlbumData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //[wTools HideMBProgressHUD];
    [MBProgressHUD hideHUDForView: self.view animated: YES];
    
    NSLog(@"RetrievealbumpViewController");
    NSLog(@"viewWillAppear");
    
    NSLog(@"status bar height: %f", [UIApplication sharedApplication].statusBarFrame.size.height);
    NSLog(@"navigationBar height: %f", self.navigationController.navigationBar.frame.size.height);
    
    NSLog(@"fromXib: %d", self.fromXib);
    
    if (self.fromXib) {
        /*
         NSLog(@"self.view.bounds: %@", NSStringFromCGRect(self.view.bounds));
         
         CGRect newBound = self.view.bounds;
         newBound.origin.y = 64;
         [self.view setBounds: newBound];
         
         NSLog(@"self.view.bounds: %@", NSStringFromCGRect(self.view.bounds));
         */
        
        /*
         NSLog(@"self.bgImgForTextView: %@", NSStringFromCGRect(self.bgImgForTextView.bounds));
         
         CGRect newImgBound = self.bgImgForTextView.bounds;
         newImgBound.size.height = 350;
         
         [self.bgImgForTextView setBounds: newImgBound];
         NSLog(@"self.bgImgForTextView: %@", NSStringFromCGRect(self.bgImgForTextView.bounds));
         */
    }
    
    //[wTools ShowMBProgressHUD];
    [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *respone=[boxAPI retrievealbump: _albumid uid:[wTools getUserID] token:[wTools getUserToken]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //[wTools HideMBProgressHUD];
            [MBProgressHUD hideHUDForView: self.view animated: YES];
            
            if (respone!=nil) {
                NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                //AppDelegate *app=[[UIApplication sharedApplication]delegate];
                
                NSLog(@"got data from protocol retrievealbump");
                
                if ([dic[@"result"] intValue] == 1) {
                    _data = [dic[@"data"] mutableCopy];
                    
                    NSLog(@"_data: %@", _data);
                    
                    //[app.myNav pushViewController:rev animated:YES];
                    [self getAlbumData];
                } else if ([dic[@"result"] intValue] == 0) {
                    NSLog(@"失敗：%@",dic[@"message"]);
                    Remind *rv=[[Remind alloc]initWithFrame: self.view.bounds];
                    [rv addtitletext:dic[@"message"]];
                    [rv addBackTouch];
                    [rv showView: self.view];
                } else {
                    Remind *rv=[[Remind alloc]initWithFrame: self.view.bounds];
                    [rv addtitletext:NSLocalizedString(@"Host-NotAvailable", @"")];
                    [rv addBackTouch];
                    [rv showView: self.view];
                }
            }
        });
    });
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed: 32.0/255.0 green: 191.0/255.0 blue: 193.0/255.0 alpha: 1.0];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // Set up for back to the previous one for disable swipe gesture
    // Because the home view controller can not swipe back to Main Screen
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)tapDetected
{
    NSLog(@"single Tap on imageView");
    //[self showimage: nil];
    
    [self readBook: nil];
}

#pragma mark -

- (void)getAlbumData
{
    NSLog(@"getAlbumData");
    NSLog(@"data: %@", _data);
    
    own = NO;
    imagelist = [NSMutableArray new];
    _userid = [_data[@"user"][@"user_id"] stringValue];
    _mytitle.text = _data[@"album"][@"name"];
    _name.text = _data[@"user"][@"name"];
    
    if (![_data[@"album"][@"location"] isEqualToString: @""]) {
        NSLog(@"data album location is not equal to string empty");
        NSLog(@"data album location: %@", _data[@"album"][@"location"]);
        
        _local.text = _data[@"album"][@"location"];
        _locationImage.hidden = NO;
    } else {
        NSLog(@"data album location is equal to string empty");
        NSLog(@"data album location: %@", _data[@"album"][@"location"]);
        
        _local.text = @"";
        _locationImage.hidden = YES;
    }
    
    // Section for Displaying UseFor Image
    NSLog(@"data album usefor: %@", _data[@"album"][@"usefor"]);
    
    BOOL gotExchange = [_data[@"album"][@"usefor"][@"exchange"] boolValue];
    NSLog(@"gotExchange: %d", gotExchange);
    
    BOOL gotSlot = [_data[@"album"][@"usefor"][@"slot"] boolValue];
    NSLog(@"gotSlot: %d", gotSlot);
    
    BOOL gotVideo = [_data[@"album"][@"usefor"][@"video"] boolValue];
    NSLog(@"gotVideo: %d", gotVideo);
    
    if (gotVideo) {
        _useForImage1.image = [UIImage imageNamed: @"icon_album_type_video"];
        
        if (gotExchange) {
            _useForImage2.image = [UIImage imageNamed: @"icon_album_type_exchange"];
            
            if (gotSlot) {
                _useForImage3.image = [UIImage imageNamed: @"icon_album_type_slot"];
            }
        } else if (gotSlot) {
            _useForImage2.image = [UIImage imageNamed: @"icon_album_type_slot"];
        }
    } else if (gotExchange) {
        _useForImage1.image = [UIImage imageNamed: @"icon_album_type_exchange"];
        
        if (gotSlot) {
            _useForImage2.image = [UIImage imageNamed: @"icon_album_type_slot"];
        }
    } else if (gotSlot) {
        _useForImage1.image = [UIImage imageNamed: @"icon_album_type_slot"];
    }
    
    // UITextView Set Up
    _descriptiontext.text = _data[@"album"][@"description"];
    
    //[_activitybtn setContentHorizontalAlignment: UIControlContentHorizontalAlignmentRight];
    [_activitybtn setContentHorizontalAlignment: UIControlContentHorizontalAlignmentLeft];
    
    if (_data[@"event"] && ![_data[@"event"] isKindOfClass:[NSNull class]]) {
        [_activitybtn setTitle:_data[@"event"][@"name"] forState:UIControlStateNormal];
    }else{
        _activitybtn.hidden = YES;
    }
    
    lab_text.text = NSLocalizedString(@"Works-desc", @"");
    [btn_report setTitle: NSLocalizedString(@"Works-report", @"") forState:UIControlStateNormal];
    //[share setTitle:NSLocalizedString(@"Works-share", @"") forState:UIControlStateNormal];
    
    
    NSLog(@"_coverImage.image: %@", [_coverImage.image averageColor]);
    
    [self updateColor: [_coverImage.image averageColor]];
    
    _navigationImageView.backgroundColor = [_coverImage.image averageColor];
    
    self.navigationController.navigationBar.barTintColor = [_coverImage.image averageColor];
    
    self.navigationItem.title = _data[@"album"][@"name"];
    /*
    UILabel *titleLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 200, 40)];
    titleLabel.text = _data[@"album"][@"name"];
    titleLabel.numberOfLines = 1;
    titleLabel.font = [UIFont systemFontOfSize: 13.5];
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.navigationItem.titleView = titleLabel;
     */
    
    _coverImage.layer.cornerRadius = 2;
    _coverImage.clipsToBounds = YES;
    _coverImage.layer.masksToBounds = NO;
    _coverImage.layer.shadowColor = [UIColor grayColor].CGColor;
    _coverImage.layer.shadowOpacity = 1;
    _coverImage.layer.shadowRadius = 2;
    _coverImage.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    _coverImage.contentMode = UIViewContentModeScaleAspectFit;
    
    _readBtn.layer.cornerRadius = 2;
    _readBtn.clipsToBounds = YES;
    _readBtn.layer.masksToBounds = NO;
    _readBtn.layer.shadowColor = [UIColor grayColor].CGColor;
    _readBtn.layer.shadowOpacity = 1;
    _readBtn.layer.shadowRadius = 2;
    _readBtn.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    
    if ([_data[@"album"][@"own"] boolValue]) {
        
        // If album is already owned
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *checkOwn = @"AlreadyOwned";
        [defaults setObject: checkOwn forKey: @"checkOwn"];
        [defaults synchronize];
        
        /*
        [_openbtn setTitle:NSLocalizedString(@"Works-viewAlbum", @"") forState:UIControlStateNormal];
        [_openbtn setImage:[UIImage imageNamed:@"button_open.png"] forState:UIControlStateNormal];
        [_openbtn setImage:[UIImage imageNamed:@"button_open_click.png"] forState:UIControlStateHighlighted];
        [_openbtn setImage:[UIImage imageNamed:@"button_open_click.png"] forState:UIControlStateSelected];
        */
        
        NSLog(@"_userid: %@", _userid);
        NSLog(@"[wTools getUserID]: %@", [wTools getUserID]);
        
        if ([_userid isEqualToString: [wTools getUserID]]) {
            [_collectAndRead setTitle: @"我 的 作 品" forState: UIControlStateNormal];
        } else {
            [_collectAndRead setTitle: @"已 收 藏" forState: UIControlStateNormal];
        }
        
        //[_collectAndRead setTitle: @"已 收 藏" forState: UIControlStateNormal];
        [_collectAndRead setTitleColor: [UIColor redColor] forState: UIControlStateNormal];
        _collectAndRead.backgroundColor = [UIColor whiteColor];
        _collectAndRead.layer.borderWidth = 0.5f;
        _collectAndRead.layer.borderColor = [UIColor redColor].CGColor;
        _collectAndRead.layer.masksToBounds = YES;
        _collectAndRead.userInteractionEnabled = NO;
        
    } else {
        
        // If album is not owned yet
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *checkOwn = @"Haven'tOwned";
        [defaults setObject: checkOwn forKey: @"checkOwn"];
        [defaults synchronize];
        
        if ([_data[@"album"][@"point"] intValue]==0) {
            //[_openbtn setTitle:NSLocalizedString(@"Works-freeGet", @"") forState:UIControlStateNormal];
            
            [_collectAndRead setTitle: @"收藏並完整閱讀" forState: UIControlStateNormal];
        } else {
            //[_openbtn setTitle:[NSString stringWithFormat:@"%@(%iP)",NSLocalizedString(@"Works-freeGet", @"Works-payForGet"),[_data[@"album"][@"point"] intValue]] forState:UIControlStateNormal];
            
            //[_openbtn setTitle:[NSString stringWithFormat:@"%@(%iP)",NSLocalizedString(@"Works-payForGet", @""),[_data[@"album"][@"point"] intValue]] forState:UIControlStateNormal];
            NSString *titleForCollect = [NSString stringWithFormat: @"%@ %iP", NSLocalizedString(@"Works-payForGet", @""), [_data[@"album"][@"point"] intValue]];
            [_collectAndRead setTitle: titleForCollect forState: UIControlStateNormal];
        }
    }
    
    
    _collectAndRead.layer.cornerRadius = 2;
    _collectAndRead.clipsToBounds = YES;
    _collectAndRead.layer.masksToBounds = NO;
    _collectAndRead.layer.shadowColor = [UIColor grayColor].CGColor;
    _collectAndRead.layer.shadowOpacity = 1;
    _collectAndRead.layer.shadowRadius = 2;
    _collectAndRead.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);

    
    _albumstatistics.text = [_data[@"albumstatistics"][@"viewed"]stringValue];
    _collectionNumber.text = [_data[@"albumstatistics"][@"count"]stringValue];
    
    own = [_data[@"album"][@"own"] boolValue];
    
    
    for (int i=0; i<[_data[@"photo"] count]; i++) {
        
        [imagelist addObject:_data[@"photo"][i][@"image_url"]];
        
        /*
        AsyncImageView *imav=[[AsyncImageView alloc]initWithFrame:CGRectMake(97*i, 0, 94, 134)];
        imav.contentMode=UIViewContentModeScaleAspectFit;
        imav.layer.shadowColor=[UIColor blackColor].CGColor;
        imav.layer.borderWidth=0.5;
        
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: imav];
        imav.imageURL=[NSURL URLWithString:_data[@"photo"][i][@"image_url_thumbnail"]];
        [_myscrollview addSubview:imav];
        
        
        UIButton *btn=[wTools W_Button:self frame:imav.frame imgname:@"" SELL:@selector(showimage:) tag:i];
        [_myscrollview addSubview:btn];
        */
    }
    //_myscrollview.contentSize=CGSizeMake(97*[_data[@"photo"] count], 0);
}

- (void)updateColor: (UIColor *)newColor
{
    const CGFloat *componentColors = CGColorGetComponents(newColor.CGColor);
    
    CGFloat colorBrightness = ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000;
    
    if (colorBrightness < 0.5) {
        NSLog(@"my color is dark");
        [_backBtn setImage: [UIImage imageNamed: @"icon_back_white_120x120"] forState: UIControlStateNormal];
        [_shareBtn setImage: [UIImage imageNamed: @"icon_share_white_120x120"] forState: UIControlStateNormal];
        _mytitle.textColor = [UIColor colorWithRed: 255/255 green: 255/255 blue: 255/255 alpha: 1.0];
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed: 255/255 green: 255/255 blue: 255/255 alpha: 1.0]};
    } else {
        NSLog(@"my color is light");
        [_backBtn setImage: [UIImage imageNamed: @"icon_back_grey800_120x120"] forState: UIControlStateNormal];
        [_shareBtn setImage: [UIImage imageNamed: @"icon_share_grey800_120x120"] forState: UIControlStateNormal];
        _mytitle.textColor = [UIColor colorWithRed: 66/255 green: 66/255 blue: 66/255 alpha: 1.0];
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed: 66/255 green: 66/255 blue: 66/255 alpha: 1.0]};
    }
}

//改變成擁有
-(void)own{
    /*
    [_openbtn setTitle:NSLocalizedString(@"Works-viewAlbum", @"") forState:UIControlStateNormal];
    [_openbtn setImage:[UIImage imageNamed:@"button_open.png"] forState:UIControlStateNormal];
    [_openbtn setImage:[UIImage imageNamed:@"button_open_click.png"] forState:UIControlStateHighlighted];
    [_openbtn setImage:[UIImage imageNamed:@"button_open_click.png"] forState:UIControlStateSelected];
    */
    
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]initWithDictionary:_data];
    NSMutableDictionary *album=[[NSMutableDictionary alloc]initWithDictionary:_data[@"album"]];
    
    [album setObject:[NSNumber numberWithBool:YES] forKey:@"own"];
    [dic setObject:album forKey:@"album"];
    
    _data=dic;
    own=YES;
}

-(void)showimage:(UIButton *)sender {
    UIView *back=[[UIView alloc]initWithFrame:self.view.bounds];
    back.backgroundColor=[UIColor clearColor];
    [self.view addSubview:back];
    
    wShowImageList *v=[[wShowImageList alloc]initWithFrame:back.frame];
    v.imagelist=imagelist;
    v.delegate=self;
    [v showView:sender.tag];
    v.alpha=0;
    
    if ([_data[@"album"][@"count_photo"] intValue]>=imagelist.count) {
        v.isShow=NO;
    }else{
        v.isShow=YES;
    }
    
    [self.view addSubview:v];
    [UIView animateWithDuration:0.3 animations:^{
        v.alpha=1;
    } completion:^(BOOL anim){
        [back removeFromSuperview];
    }];
    
}

-(void)showbook{
    [self showbook:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)Creative:(id)sender {
    //[wTools showCreativeViewController:_albumid];
    
    CreativeViewController *cVC = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"CreativeViewController"];
    cVC.userid = _userid;
    [self.navigationController pushViewController: cVC animated: NO];
}

- (IBAction)readBook:(id)sender {
    NSLog(@"readBook");
    /*
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL fromHomeVC = NO;
    [defaults setObject: [NSNumber numberWithBool: fromHomeVC]
                 forKey: @"fromHomeVC"];
    [defaults synchronize];
    */
    if (own) {
        NSLog(@"own: %d", own);
        NSLog(@"self showbook");
        [self showbook: nil];
    } else {
        NSLog(@"own: %d", own);
        NSLog(@"Push ReadBookViewController");
        
        NSLog(@"_data: %@", _data);
        
        //[self showimage: nil];
        ReadBookViewController *readBookVC = [[ReadBookViewController alloc] initWithNibName: @"ReadBookViewController" bundle: nil];
        readBookVC.dic = _data;
        
        readBookVC.isDownloaded = NO;
        readBookVC.albumid = _albumid;
        readBookVC.isFree = isFree;
        
        //[self.navigationController pushViewController: readBookVC animated: YES];
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSLog(@"before push");
        [app.myNav pushViewController: readBookVC animated: YES];
        NSLog(@"after push");
    }
}

- (IBAction)showbook:(id)sender {
    NSLog(@"showbook");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL fromHomeVC = NO;
    [defaults setObject: [NSNumber numberWithBool: fromHomeVC]
                 forKey: @"fromHomeVC"];
    [defaults synchronize];
    
    
    //取得資料ID
    NSString *name=[NSString stringWithFormat:@"%@%@", [wTools getUserID], _albumid];
    NSString *docDirectoryPath = [filepinpinboxDest stringByAppendingPathComponent:name];
    NSLog(@"filepinpinboxDest: %@", filepinpinboxDest);
    NSLog(@"docDirectoryPath: %@", docDirectoryPath);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //檢查資料夾是否存在
    if ([fileManager fileExistsAtPath:docDirectoryPath]) {
        NSLog(@"存在");
        //[wTools ReadBookalbumid:_albumid userbook:@"N"];
        [wTools ReadBookalbumid: _albumid userbook: @"N" eventId: nil postMode: nil fromEventPostVC: nil];
        return;
    }
    
    //是否已購買
    if (own) {
        
        NSLog(@"Collected Already");
        
        PreviewbookViewController *rv=[[PreviewbookViewController alloc]initWithNibName:@"PreviewbookViewController" bundle:nil];
        //PreviewbookViewController *rv = [[UIStoryboard storyboardWithName: @"Home" bundle: nil]  instantiateViewControllerWithIdentifier: @"PreviewbookViewController"];
        rv.albumid = _albumid;
        rv.userbook = @"N";
        //[self.navigationController pushViewController:rv animated:YES];
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        [app.myNav pushViewController: rv animated: YES];
        
        return;
    }
    NSLog(@"Collecting Album");
    
    //[wTools ShowMBProgressHUD];
    [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString * Pointstr=[boxAPI geturpoints:[wTools getUserID] token:[wTools getUserToken]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[wTools HideMBProgressHUD];
            [MBProgressHUD hideHUDForView: self.view animated: YES];
            
            NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[Pointstr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            
            if ([_data[@"album"][@"point"] intValue]==0) {
                NSLog(@"收藏相本");
                PreviewbookViewController *rv=[[PreviewbookViewController alloc]initWithNibName:@"PreviewbookViewController" bundle:nil];
                //PreviewbookViewController *rv = [[UIStoryboard storyboardWithName: @"Home" bundle: nil]  instantiateViewControllerWithIdentifier: @"PreviewbookViewController"];
                rv.albumid=_albumid;
                rv.userbook=@"N";
                
                [self own];
                //[self.navigationController pushViewController:rv animated:YES];
                AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
                [app.myNav pushViewController: rv animated: YES];
                
                // Check whether taskType is createAlbum or collectAlbum
                // Because, these two type will go to the same view controller - BookViewController
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSString *task_for = @"collect_free_album";
                [defaults setObject: task_for forKey: @"task_for"];
                [defaults synchronize];
            } else {
                //是否足夠
                if ([_data[@"album"][@"point"] intValue]>[dic[@"data"] intValue]) {                    
                    Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
                    [rv addtitletext:NSLocalizedString(@"Works-tipAskP", @"")];
                    [rv addSelectBtntext:NSLocalizedString(@"GeneralText-yes", @"") btn2:NSLocalizedString(@"GeneralText-no", @"") ];
                    [rv showView:self.view];
                    
                    rv.btn1select=^(BOOL bo){
                        if (bo) {
                            CurrencyViewController *cvc=[[UIStoryboard storyboardWithName:@"Home" bundle:nil]instantiateViewControllerWithIdentifier:@"CurrencyViewController"];
                            
                            [self.navigationController pushViewController:cvc animated:YES];
                        }
                    };
                    
                } else {
                    
                    //可以購買
                    Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
                    [rv addtitletext:[NSString stringWithFormat:@"%@(%d P)",NSLocalizedString(@"Works-tipConfirmGetIt", @""),[_data[@"album"][@"point"] intValue]]];
                    [rv addSelectBtntext:NSLocalizedString(@"GeneralText-yes", @"") btn2:NSLocalizedString(@"GeneralText-no", @"") ];
                    [rv showView:self.view];
                    rv.btn1select = ^(BOOL bo){
                        
                        if (bo) {
                            PreviewbookViewController *rv=[[PreviewbookViewController alloc]initWithNibName:@"PreviewbookViewController" bundle:nil];
                            //PreviewbookViewController *rv = [[UIStoryboard storyboardWithName: @"Home" bundle: nil]  instantiateViewControllerWithIdentifier: @"PreviewbookViewController"];
                            rv.albumid=_albumid;
                            rv.userbook=@"N";
                            
                            [self own];
                            //[self.navigationController pushViewController:rv animated:YES];
                            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
                            [app.myNav pushViewController: rv animated: YES];
                            
                            
                            // Check whether taskType is createAlbum or collectAlbum
                            // Because, these two type will go to the same view controller - BookViewController
                            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                            NSString *task_for = @"collect_pay_album";
                            [defaults setObject: task_for forKey: @"task_for"];
                            [defaults synchronize];
                        }
                    };
                }
            }
        });
    });
}

#pragma mark - Sharing Methods

- (IBAction)sharebtn:(id)sender {
    
    NSLog(@"Share Button in Retrive Album View Controller");
    
    //[wTools Activitymessage:[NSString stringWithFormat: sharingLink ,_mytitle.text,_albumid]];
    //[wTools Activitymessage:[NSString stringWithFormat: sharingLink ,_albumid]];
    
    /*
     FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
     content.contentURL = [NSURL URLWithString: @"http://developers.facebook.com"];
     [FBSDKShareDialog showFromViewController: self
     withContent: content
     delegate: self];
     */
    
    //[self showSharingAlertView];
    [self checkTaskComplete];
}

- (void)checkTaskComplete
{
    NSLog(@"checkTask");
    
    //[wTools ShowMBProgressHUD];
    [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *response = [boxAPI checkTaskCompleted: [wTools getUserID] token: [wTools getUserToken] task_for: @"share_to_fb" platform: @"apple"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //[wTools HideMBProgressHUD];
            [MBProgressHUD hideHUDForView: self.view animated: YES];
            
            if (response != nil) {
                NSLog(@"%@", response);
                NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                if ([data[@"result"] intValue] == 1) {
                    // Task is completed, so calling the original sharing function
                    [wTools Activitymessage:[NSString stringWithFormat: sharingLink ,_albumid, autoPlayStr]];
                    
                } else if ([data[@"result"] intValue] == 2) {
                    // Task is not completed, so pop ups alert view
                    [self showSharingAlertView];
                    
                } else if ([data[@"result"] intValue] == 0) {
                    NSString *errorMessage = data[@"message"];
                    NSLog(@"errorMessage: %@", errorMessage);
                } else {
                    [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                }
            }
        });
    });
}

- (void)showSharingAlertView
{
    NSLog(@"showSharingAlertView");
    
    alertViewForSharing = [[CustomIOSAlertView alloc] init];
    [alertViewForSharing setContainerView: [self createSharingButtonView]];
    [alertViewForSharing setButtonTitles: [NSMutableArray arrayWithObject: @"取     消"]];
    [alertViewForSharing setUseMotionEffects: true];
    
    [alertViewForSharing show];
}

- (UIView *)createSharingButtonView
{
    NSLog(@"createSharingButtonView");
    
    // Parent View
    UIView *sharingButtonView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 250, 220)];
    
    // Topic Label View
    UILabel *topicLabel = [[UILabel alloc] initWithFrame: CGRectMake(25, 25, 200, 10)];
    topicLabel.text = @"選擇分享方式";
    topicLabel.textAlignment = NSTextAlignmentCenter;
    
    // 1st UIButton View
    UIButton *buttonFB = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [buttonFB addTarget: self action: @selector(fbSharing) forControlEvents: UIControlEventTouchUpInside];
    [buttonFB setTitle: @"獎勵分享 (facebook)" forState: UIControlStateNormal];
    buttonFB.frame = CGRectMake(25, 65, 200, 50);
    [buttonFB setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    buttonFB.backgroundColor = [UIColor colorWithRed: 32.0/255.0 green: 191.0/255.0 blue: 193.0/255.0 alpha: 1.0];
    buttonFB.layer.cornerRadius = 10;
    buttonFB.clipsToBounds = YES;
    
    // 2nd UIButton View
    UIButton *buttonNormal = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [buttonNormal addTarget: self action: @selector(normalSharing) forControlEvents: UIControlEventTouchUpInside];
    [buttonNormal setTitle: @" 一 般 分 享 " forState: UIControlStateNormal];
    buttonNormal.frame = CGRectMake(25, 150, 200, 50);
    [buttonNormal setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    buttonNormal.backgroundColor = [UIColor colorWithRed: 32.0/255.0 green: 191.0/255.0 blue: 193.0/255.0 alpha: 1.0];
    buttonNormal.layer.cornerRadius = 10;
    buttonNormal.clipsToBounds = YES;
    
    [sharingButtonView addSubview: topicLabel];
    [sharingButtonView addSubview: buttonFB];
    [sharingButtonView addSubview: buttonNormal];
    
    return sharingButtonView;
}

- (void)fbSharing
{
    [alertViewForSharing close];
    
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString: [NSString stringWithFormat: sharingLink, _albumid, autoPlayStr]];
    [FBSDKShareDialog showFromViewController: self
                                 withContent: content
                                    delegate: self];
}

- (void)normalSharing
{
    [alertViewForSharing close];
    
    [wTools Activitymessage:[NSString stringWithFormat: sharingLink, _albumid, autoPlayStr]];
}

#pragma mark - FBSDKSharing Delegate Methods

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
    NSLog(@"Sharing Complete");
    
    // Check whether getting Sharing Point or not
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL share_to_fb = [defaults objectForKey: @"share_to_fb"];
    NSLog(@"Check whether getting sharing point or not");
    NSLog(@"share_to_fb: %d", (int)share_to_fb);
    
    if (share_to_fb) {
        NSLog(@"Getting Sharing Point Already");
    } else {
        NSLog(@"Haven't got the point of sharing yet");
        [self checkPoint];
    }
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    NSLog(@"Sharing didFailWithError");
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    NSLog(@"Sharing Did Cancel");
}

#pragma mark - Check Point Method

- (void)checkPoint
{
    NSLog(@"checkPoint");
    
    //[wTools ShowMBProgressHUD];
    [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *response = [boxAPI doTask2: [wTools getUserID] token: [wTools getUserToken] task_for: @"share_to_fb" platform: @"apple" type: @"album" type_id: _albumid];
        
        NSLog(@"User ID: %@", [wTools getUserID]);
        NSLog(@"Token: %@", [wTools getUserToken]);
        NSLog(@"Album ID: %@", _albumid);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //[wTools HideMBProgressHUD];
            [MBProgressHUD hideHUDForView: self.view animated: YES];
            
            if (response != nil) {
                NSLog(@"%@", response);
                NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                if ([data[@"result"] intValue] == 1) {
                    
                    missionTopicStr = data[@"data"][@"task"][@"name"];
                    NSLog(@"name: %@", missionTopicStr);
                    
                    rewardType = data[@"data"][@"task"][@"reward"];
                    NSLog(@"reward type: %@", rewardType);
                    
                    rewardValue = data[@"data"][@"task"][@"reward_value"];
                    NSLog(@"reward value: %@", rewardValue);
                    
                    eventUrl = data[@"data"][@"event"][@"url"];
                    NSLog(@"event: %@", eventUrl);
                    
                    [self showAlertView];
                    
                } else if ([data[@"result"] intValue] == 2) {
                    NSLog(@"message: %@", data[@"message"]);
                    
                    BOOL share_to_fb = YES;
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject: [NSNumber numberWithBool: share_to_fb]
                                 forKey: @"share_to_fb"];
                    [defaults synchronize];
                    
                } else if ([data[@"result"] intValue] == 0) {
                    NSString *errorMessage = data[@"message"];
                    NSLog(@"error messsage: %@", errorMessage);
                } else {
                    [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                }
            }
        });
    });
}

#pragma mark - Custom AlertView for Getting Point
- (void)showAlertView
{
    NSLog(@"Show Alert View");
    
    // Custom AlertView shows up when getting the point
    alertView = [[CustomIOSAlertView alloc] init];
    [alertView setContainerView: [self createPointView]];
    [alertView setButtonTitles: [NSMutableArray arrayWithObject: @"確     認"]];
    [alertView setUseMotionEffects: true];
    
    [alertView show];
}

- (UIView *)createPointView
{
    NSLog(@"createPointView");
    
    UIView *pointView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 250, 250)];
    
    // Mission Topic Label
    UILabel *missionTopicLabel = [[UILabel alloc] initWithFrame: CGRectMake(5, 15, 200, 10)];
    //missionTopicLabel.text = @"收藏相本得點";
    missionTopicLabel.text = missionTopicStr;
    
    NSLog(@"Topic Label Text: %@", missionTopicStr);
    [pointView addSubview: missionTopicLabel];
    
    // Gift Image
    UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(50, 40, 150, 150)];
    imageView.image = [UIImage imageNamed: @"icon_present"];
    [pointView addSubview: imageView];
    
    // Message Label
    UILabel *messageLabel = [[UILabel alloc] initWithFrame: CGRectMake(5, 200, 200, 10)];
    
    NSString *congratulate = @"恭喜您獲得 ";
    //NSString *number = @"1 ";
    
    NSLog(@"Reward Value: %@", rewardValue);
    NSString *end = @"P!";
    
    /*
     if ([rewardType isEqualToString: @"point"]) {
     congratulate = @"恭喜您獲得 ";
     number = @"5 ";
     // number = rewardValue;
     end = @"P!";
     }
     */
    
    messageLabel.text = [NSString stringWithFormat: @"%@%@%@", congratulate, rewardValue, end];
    [pointView addSubview: messageLabel];
    
    if ([eventUrl isEqual: [NSNull null]] || eventUrl == nil) {
        NSLog(@"eventUrl is equal to null or eventUrl is nil");
    } else {
        // Activity Button
        UIButton *activityButton = [UIButton buttonWithType: UIButtonTypeCustom];
        [activityButton addTarget: self action: @selector(showTheActivityPage) forControlEvents: UIControlEventTouchUpInside];
        activityButton.frame = CGRectMake(150, 220, 100, 10);
        [activityButton setTitle: @"活動連結" forState: UIControlStateNormal];
        [activityButton setTitleColor: [UIColor colorWithRed: 26.0/255.0 green: 196.0/255.0 blue: 199.0/255.0 alpha: 1.0]
                             forState: UIControlStateNormal];
        [pointView addSubview: activityButton];
    }
    
    return pointView;
}

- (void)showTheActivityPage
{
    NSLog(@"showTheActivityPage");
    
    //NSString *activityLink = @"http://www.apple.com";
    NSString *activityLink = eventUrl;
    
    NSURL *url = [NSURL URLWithString: activityLink];
    
    // Close for present safari view controller, otherwise alertView will hide the background
    [alertView close];
    
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL: url entersReaderIfAvailable: NO];
    safariVC.delegate = self;
    safariVC.preferredBarTintColor = [UIColor whiteColor];
    [self presentViewController: safariVC animated: YES completion: nil];
}

#pragma mark - SFSafariViewController delegate methods
- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller
{
    // Done button pressed
    
    NSLog(@"show");
    [alertView show];
}

#pragma mark -

-(IBAction)message:(id)seneder{
    [wTools messageboard:_albumid];
}

//檢舉
-(IBAction)insertreport:(id)sender{
    
    //[wTools ShowMBProgressHUD];
    [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString * Pointstr=[boxAPI getreportintentlist:[wTools getUserID] token:[wTools getUserToken]];
        dispatch_async(dispatch_get_main_queue(), ^{
            //[wTools HideMBProgressHUD];
            [MBProgressHUD hideHUDForView: self.view animated: YES];
            
            NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[Pointstr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            
            reportintentlist=dic[@"data"];
            SelectBarViewController *mv=[[SelectBarViewController alloc]initWithNibName:@"SelectBarViewController" bundle:nil];
            
            
            NSMutableArray *strarr=[NSMutableArray new];
            for (int i =0; i<reportintentlist.count; i++) {
                [strarr addObject:reportintentlist[i][@"name"]];
            }
            mv.data=strarr;
            mv.delegate=self;
            mv.topViewController=self;
            [self wpresentPopupViewController:mv animated:YES completion:nil];
        });
        
    });
}

-(void)SaveDataRow:(NSInteger)row{
    
    NSString *rid=[reportintentlist[row][@"reportintent_id"] stringValue];
    
    //[wTools ShowMBProgressHUD];
    [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString * Pointstr=[boxAPI insertreport:[wTools getUserID] token:[wTools getUserToken] rid:rid type:@"album" typeid:_albumid];
        dispatch_async(dispatch_get_main_queue(), ^{
            //[wTools HideMBProgressHUD];
            [MBProgressHUD hideHUDForView: self.view animated: YES];
            
            NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[Pointstr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            
            NSString *mesg=@"";
            if ([dic[@"result"]boolValue]) {
                mesg=NSLocalizedString(@"Works-tipRpSuccess", @"");
            }else{
                mesg=dic[@"message"];
            }
            
            Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
            [rv addtitletext:mesg];
            [rv addBackTouch];
            [rv showView:self.view];
            
            
        });
        
    });
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
