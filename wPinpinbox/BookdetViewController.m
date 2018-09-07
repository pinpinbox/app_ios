//
//  BookdetViewController.m
//  wPinpinbox
//
//  Created by Angus on 2016/1/5.
//  Copyright (c) 2016年 Angus. All rights reserved.
//

#import "BookdetViewController.h"
#import "wTools.h"
#import "UIViewController+CWPopup.h"
#import "boxAPI.h"
#import "Remind.h"
#import "AppDelegate.h"
#import "PreviewbookViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "FastViewController.h"
#import "BookedtQRViewController.h"

#import "NSMutableArray+Reverse.h"

#import "CustomIOSAlertView.h"
#import "UIColor+Extensions.h"

#import "UIViewController+ErrorAlert.h"

@interface BookdetViewController () <UITextViewDelegate,BookdetDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    UIButton *selectbtn;
    
    NSString * sfir;
    NSString * ssec;
    NSString * sact;
    NSString * saudio;
    NSString * swea;
    NSString * smood;
    NSDictionary *mdata;
    
    AVPlayer *player;
    AVPlayerItem *playerItem;
    NSString *qrcode;
    
    __weak IBOutlet UIButton *btn_return;
    __weak IBOutlet UIView *indexview;
    
    __weak IBOutlet UIButton *finishBtn;
    
    BOOL statusValue;
    
    NSArray *arrayForPicker;
    UIActionSheet *actionSheet;
    NSInteger selectRow;
    
    NSInteger selectFirstRow;
    NSInteger selectSecondRow;
}
@end

@implementation BookdetViewController
- (IBAction)QRcode:(id)sender {
    
    BookedtQRViewController *bdqr=[[BookedtQRViewController alloc]initWithNibName:@"BookedtQRViewController" bundle:nil];
    bdqr.delegate=self;
    [self.navigationController pushViewController:bdqr animated:YES];
}

-(void)SaveDataString:(NSString *)str{
    qrcode=str;
}

#pragma mark - View Related Methods

- (void)handleSingleTap: (UITapGestureRecognizer *)sender
{
    [self.view endEditing: YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"viewDidLoad");
    /*
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar setBackgroundImage: [UIImage new] forBarMetrics: UIBarMetricsDefault];
     */
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed: 66.0/255.0 green: 68.0/255.0 blue: 86.0/255.0 alpha: 1.0];
    
    
    
    // Setup the tap for dismissing keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleSingleTap:)];
    [self.view addGestureRecognizer: tap];
    
    // Listen for keyboard appearances and disappearnces
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object: nil];
    
    //[self getSettingData];
}

- (void)keyboardWillShow: (NSNotification *)notif
{
    [self dismissPickerView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed: 32.0/255.0 green: 191.0/255.0 blue: 193.0/255.0 alpha: 1.0];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    NSLog(@"viewWillAppear");
    NSLog(@"BookdetViewController");
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed: 66.0/255.0 green: 68.0/255.0 blue: 86.0/255.0 alpha: 1.0];
    
    [self.view endEditing:YES];
    
    [self dismissPickerView];
    
    if (player!=nil) {
        [player pause];
    }
    
    if (qrcode) {
        [wqtbtn setTitle:qrcode forState:UIControlStateNormal];
    }
    
    if (_isRecorded) {
        NSLog(@"isRecorded is: %d", _isRecorded);
        [waudio setImage: [UIImage imageNamed: @"frame_blue_red"] forState: UIControlStateNormal];
    }
    
    [self getSettingData];
}

#pragma mark -
- (void)getSettingData {
    NSLog(@"getSettingData");
    
    statusValue = NO;
    
    lab_title.text=NSLocalizedString(@"CreateAlbumText-productInfo", @"");
    notext.text=NSLocalizedString(@"CreateAlbumText-pDesc", @"");
    
    [wfirstpag setTitle:NSLocalizedString(@"CreateAlbumText-pCate", @"") forState:UIControlStateNormal];
    [wsecondpag setTitle:NSLocalizedString(@"CreateAlbumText-pCate2", @"") forState:UIControlStateNormal];
    [waudio setTitle:NSLocalizedString(@"CreateAlbumText-pMusic", @"") forState:UIControlStateNormal];
    [wqtbtn setTitle:NSLocalizedString(@"CreateAlbumText-pIndex", @"") forState:UIControlStateNormal];
    
    [wweather setTitle:NSLocalizedString(@"CreateAlbumText-weather", @"") forState:UIControlStateNormal];
    [wmood setTitle:NSLocalizedString(@"CreateAlbumText-mood", @"") forState:UIControlStateNormal];
    
    [btn_return setTitle:NSLocalizedString(@"CreateAlbumText-backToEditor", @"") forState:UIControlStateNormal];
    
    [[finishBtn layer] setMasksToBounds: YES];
    [[finishBtn layer] setCornerRadius: finishBtn.bounds.size.height / 2];
    
    // Set target action methods for detecting textfield change
    [wtitle addTarget: self action: @selector(textFieldDidChange:) forControlEvents: UIControlEventEditingChanged];
    
    if ([wtitle respondsToSelector:@selector(setAttributedPlaceholder:)])
    {
        wtitle.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"CreateAlbumText-pName", @"") attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    }
    if ([wlocation respondsToSelector:@selector(setAttributedPlaceholder:)])
    {
        wlocation.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"CreateAlbumText-pLoc", @"") attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    }
    
    // 下載資料
    [wTools ShowMBProgressHUD];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *respone = [boxAPI getalbumdataoptions:[wTools getUserID] token:[wTools getUserToken]];
        NSString *getAlbumSettingsResponse = [boxAPI getalbumsettings: [wTools getUserID] token: [wTools getUserToken] album_id: _album_id];        
        NSLog(@"getAlbumSettingsResponse: %@", getAlbumSettingsResponse);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (respone!=nil) {
                //NSLog(@"%@",respone);
                NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                NSLog(@"getalbumdataoptions");
                //NSLog(@"dic: %@", dic);
                
                if ([dic[@"result"] intValue] == 1) {
                    mdata=[[dic objectForKey:@"data"] mutableCopy];
                    //NSLog(@"mdata: %@", mdata);
                    
                    if (getAlbumSettingsResponse != nil) {
                        NSDictionary *dicForSettings = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [getAlbumSettingsResponse dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                        NSLog(@"getAlbumSettingsResponse");
                        NSLog(@"dicForSettings: %@", dicForSettings);
                        
                        if ([dicForSettings[@"result"] boolValue]) {
                            _data = [dicForSettings[@"data"] mutableCopy];
                            NSLog(@"_data: %@", _data);
                        }
                    }
                    
                    NSLog(@"data act: %@", _data[@"open"]);
                    
                    //載入資料
                    wtitle.text = _data[@"title"];
                    
                    wdescription.text = _data[@"description"];
                    
                    if (![wdescription.text isEqualToString:@""]) {
                        notext.hidden = YES;
                    }
                    
                    wlocation.text = _data[@"location"];
                    
                    //主分類
                    if (![_data[@"firstpaging"] isKindOfClass:[NSNull class]]) {
                        NSArray *arr = mdata[@"firstpaging"];
                        NSLog(@"mdata firstpaging: %@", arr);
                        
                        int x = [_data[@"firstpaging"] intValue];
                        
                        NSLog(@"x: %d", x);
                        
                        sfir = [NSString stringWithFormat:@"%i",x];
                        NSDictionary *firdata = nil;
                        
                        for(NSDictionary *dic in arr) {
                            int y = [dic[@"id"] intValue];
                            
                            NSLog(@"y: %d", y);
                            
                            if (x == y) {
                                firdata = dic;
                                break;
                            }
                        }
                        [wfirstpag setTitle:firdata[@"name"] forState:UIControlStateNormal];
                        
                        //次分頁
                        if (![_data[@"secondpaging"] isKindOfClass:[NSNull class]]) {
                            arr = firdata[@"secondpaging"];
                            //NSLog(@"secondPaging: %@", arr);
                            
                            x = [_data[@"secondpaging"] intValue];
                            ssec = [NSString stringWithFormat:@"%i",x];
                            NSDictionary *data=nil;
                            
                            for (NSDictionary *dic in arr) {
                                int y = [dic[@"id"] intValue];
                                if (x == y) {
                                    data = dic;
                                }
                            }
                            [wsecondpag setTitle:data[@"name"] forState:UIControlStateNormal];
                        }
                    }
                    //音樂
                    if (![_data[@"audio"] isKindOfClass:[NSNull class]]) {
                        NSLog(@"data audio: %@", _data[@"audio"]);
                        
                        if (![_data[@"audio"] isEqualToString:@"0"]) {
                            NSArray *arr = mdata[@"audio"];
                            int x = [_data[@"audio"] intValue];
                            saudio = [NSString stringWithFormat:@"%i",x];
                            
                            NSLog(@"saudio intValue: %d", [saudio intValue]);
                            
                            NSDictionary *data = nil;
                            
                            for (NSDictionary *dic in arr) {
                                int y =[dic[@"id"] intValue];
                                
                                if (x == y) {
                                    data = dic;
                                    break;
                                }
                            }
                            [waudio setTitle:data[@"name"] forState:UIControlStateNormal];
                        }
                    }
                    NSLog(@"audio");
                    NSLog(@"saudio intValue: %d", [saudio intValue]);
                    
                    //天氣
                    swea = [NSString stringWithFormat:@"%@",_data[@"weather"]];
                    [wweather setTitle:_data[@"weather"] forState:UIControlStateNormal];
                    
                    //心情
                    smood = [NSString stringWithFormat:@"%@",_data[@"mood"]];
                    [wmood setTitle:_data[@"mood"] forState:UIControlStateNormal];
                    
                    //開關
                    sact = [NSString stringWithFormat:@"%@",_data[@"act"]];
                    [wact setTitle:_data[@"act"] forState:UIControlStateNormal];
                    
                    NSLog(@"sact: %@", sact);
                    NSLog(@"wact: %@", wact.titleLabel.text);
                    
                    if ([_data[@"act"] isEqualToString: @"open"]) {
                        NSLog(@"data act is open");
                        sact = @"公開";
                        [wact setTitle: @"公開" forState: UIControlStateNormal];
                        switchImageView.image = [UIImage imageNamed: @"frame_blue"];
                    } else if ([_data[@"act"] isEqualToString: @"close"]) {
                        NSLog(@"data act is close");
                        [wact setTitle: @"隱私" forState: UIControlStateNormal];
                        sact = @"隱私";
                        
                        switchImageView.image = [UIImage imageNamed: @"frame_blue_red"];
                    }
                    if ([wTools userbook]==100) {
                        indexview.hidden=NO;
                    }
                } else if ([dic[@"result"] intValue] == 0) {
                    NSLog(@"失敗：%@",dic[@"message"]);
                    [self showCustomErrorAlert: dic[@"message"]];
                } else {
                    [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                }
            }
            [wTools HideMBProgressHUD];
        });
    });
}

- (IBAction)firstpaging:(id)sender {
    selectbtn=sender;
    
    NSMutableArray *arr=[NSMutableArray new];
    
    for (NSDictionary *d in mdata[@"firstpaging"]) {
        [arr addObject:d[@"name"]];
    }
    [self showSVSVC:arr];
}

- (IBAction)secondpaging:(id)sender {
    if (sfir==nil) {
        
        Remind *rv = [[Remind alloc] initWithFrame: self.view.bounds];
        [rv addtitletext: @"請先選擇主類別"];
        [rv addBackTouch];
        [rv showView: self.view];
        
        return;
    }
    if ([sfir isEqualToString:@""]) {
        
        Remind *rv = [[Remind alloc] initWithFrame: self.view.bounds];
        [rv addtitletext: @"請先選擇主類別"];
        [rv addBackTouch];
        [rv showView: self.view];
        
        return;
    }
    
    
    selectbtn=sender;
    
    int x=[sfir intValue];
    NSMutableArray *arr=[NSMutableArray new];
    
    NSLog(@"x: %d", x);
    
    for (NSDictionary *d in mdata[@"firstpaging"][x][@"secondpaging"]) {
        NSLog(@"d name: %@", d[@"name"]);
        [arr addObject:d[@"name"]];
    }
    [self showSVSVC:arr];
}

- (IBAction)act:(id)sender {
    
    NSLog(@"act");
    
    [self.view endEditing:YES];
    
    selectbtn=sender;
    
    NSMutableArray *arr=[NSMutableArray new];
    
    for (NSDictionary *d in mdata[@"act"]) {
        
        NSString *s = d[@"name"];
        NSLog(@"s: %@", s);
        
        NSString *str;
        
        if ([d[@"name"] isEqualToString: @"Close"]) {
            NSLog(@"隱私");
            str = @"隱私";
        } else if ([d[@"name"] isEqualToString: @"Open"]) {
            NSLog(@"公開");
            str = @"公開";
        }
        
        //[arr addObject:d[@"name"]];
        
        [arr addObject: str];
    }
    
    NSLog(@"act arr: %@", arr);
    
    [arr reverse];
    
    [self showSVSVC:arr];
}

- (IBAction)weather:(id)sender {
    selectbtn=sender;
    NSMutableArray *arr=[NSMutableArray new];
    for (NSDictionary *d in mdata[@"weather"]) {
        [arr addObject:d[@"name"]];
    }
    
    [self showSVSVC:arr];
}
- (IBAction)mood:(id)sender {
    selectbtn=sender;
    NSMutableArray *arr=[NSMutableArray new];
    for (NSDictionary *d in mdata[@"mood"]) {
        [arr addObject:d[@"name"]];
    }
    
    [self showSVSVC:arr];
}
- (IBAction)audio:(id)sender {
    selectbtn=sender;
    NSMutableArray *arr=[NSMutableArray new];
    
    NSLog(@"mdata audio: %@", mdata[@"audio"]);
    
    for (NSDictionary *d in mdata[@"audio"]) {
        [arr addObject:d[@"name"]];
    }
    
    [self showSVSVC:arr];
}

#pragma mark - Pop Up & Dimiss PickerView
- (void)popupPickerView
{
    [UIView beginAnimations: nil context: NULL];
    [pickerUIView setFrame: CGRectMake(0.0f, self.view.bounds.size.height - 294.0, self.view.bounds.size.width, 294.0f)];
    [UIView commitAnimations];
    
    finishBtn.userInteractionEnabled = NO;
    finishBtn.hidden = YES;
}

- (void)dismissPickerView
{
    [UIView beginAnimations: nil context: NULL];
    [pickerUIView setFrame: CGRectMake(0.0f, self.view.bounds.size.height, self.view.bounds.size.width, 294.0f)];
    [UIView commitAnimations];
    
    finishBtn.userInteractionEnabled = YES;
    finishBtn.hidden = NO;
}

#pragma mark - Show PickerView
-(void)showSVSVC:(NSArray *)arr{
    [self.view endEditing:YES];
    
    arrayForPicker = arr;
    
    NSLog(@"arrayForPicker: %@", arrayForPicker);
    
    selectedPicker.delegate = self;
    selectedPicker.dataSource = self;
    
    
    // Set the selected row
    if (selectbtn.tag == 1) {
        NSLog(@"selectbtn.tag: %ld", (long)selectbtn.tag);
        //selectFirstRow = row;
        [selectedPicker selectRow: selectFirstRow inComponent: 0 animated: NO];
        //NSLog(@"selectFirstRow: %ld", (long)selectFirstRow);
    } else if (selectbtn.tag == 2) {
        NSLog(@"selectbtn.tag: %ld", (long)selectbtn.tag);
        //selectSecondRow = row;
        [selectedPicker selectRow: selectSecondRow inComponent: 0 animated: NO];
        //NSLog(@"selectSecondRow: %ld", (long)selectSecondRow);
    } else {
        NSLog(@"selectbtn.tag: %ld", (long)selectbtn.tag);
        //selectRow = row;
        [selectedPicker selectRow: selectRow inComponent: 0 animated: NO];
    }
    
    [self popupPickerView];
    
    //[self createActionSheet];
    
    /*
    SBookSelectViewController *SBSVC=[[SBookSelectViewController alloc]initWithNibName:@"SBookSelectViewController" bundle:nil];
    SBSVC.delegate=self;
    SBSVC.data=arr;
    SBSVC.topViewController=self;
    
    [self wu2presentPopupViewController:SBSVC animated:YES completion:nil];
     */
}

- (IBAction)cancelSelection:(id)sender {
    //[self w2dismissPopupViewControllerAnimated: YES completion: nil];
    [self dismissPickerView];
}

- (IBAction)doneSelection:(id)sender {
    NSLog(@"doneSelection");
    
    NSLog(@"selectRow: %ld", (long)selectRow);
    
    [self saveRowData: selectRow];
    [self dismissPickerView];
}

- (void)saveRowData: (NSInteger)row
{
    NSLog(@"saveRowData");
    
    NSDictionary *data=nil;
    
    if (player!=nil) {
        [player pause];
    }
    
    NSLog(@"before switch");
    
    switch (selectbtn.tag) {
        case 1://主分類
        {
            NSLog(@"case 1");
            
            //sfir=[NSString stringWithFormat:@"%li",(long)row];
            
            NSLog(@"selectFirstRow: %ld", (long)selectFirstRow);
            NSLog(@"selectSecondRow: %ld", (long)selectSecondRow);
            
            sfir=[NSString stringWithFormat:@"%li",(long)selectFirstRow];
            NSLog(@"sfir: %@", sfir);
            
            //data= mdata[@"firstpaging"][row];
            data= mdata[@"firstpaging"][selectFirstRow];
            NSLog(@"data: %@", data);
            
            ssec=@"";
            
            NSLog(@"data name: %@", data[@"name"]);
            
            if (data[@"name"]) {
                pImageView.image = [UIImage imageNamed: @"frame_blue"];
            } else {
                pImageView.image = [UIImage imageNamed: @"frame_blue_red"];
            }
            
            [wsecondpag setTitle:NSLocalizedString(@"CreateAlbumText-pCate2", @"") forState:UIControlStateNormal];
        }
            break;
        case 2://次分頁
        {
            NSLog(@"case 2");
            
            int x= [sfir intValue];
            //data=mdata[@"firstpaging"][x][@"secondpaging"][row];
            
            NSLog(@"selectFirstRow: %ld", (long)selectFirstRow);
            NSLog(@"selectSecondRow: %ld", (long)selectSecondRow);
            
            data=mdata[@"firstpaging"][x][@"secondpaging"][selectSecondRow];
            ssec=[NSString stringWithFormat:@"%@",data[@"id"]];
            
            NSLog(@"data name: %@", data[@"name"]);
            NSLog(@"ssec: %@", ssec);
            
            if (data[@"name"]) {
                sImageView.image = [UIImage imageNamed: @"frame_blue"];
            } else {
                sImageView.image = [UIImage imageNamed: @"frame_blue_red"];
            }
            
            NSLog(@"ssec: %@", ssec);
        }
            break;
        case 3://開放
        {
            NSLog(@"mdata act: %@", mdata[@"act"]);
            NSLog(@"row: %ld", (long)row);
            NSLog(@"mdata act row: %@", mdata[@"act"][row]);
            
            //data = mdata[@"act"][row];
            
            NSMutableArray *arrayForPost = mdata[@"act"];
            [arrayForPost reverse];
            
            NSLog(@"arrayForPost: %@", arrayForPost);
            NSLog(@"arrayForPost row: %@", arrayForPost[row]);
            
            data = arrayForPost[row];
            
            NSLog(@"data name: %@", data[@"name"]);
            
            
            //sact=[NSString stringWithFormat:@"%@",data[@"name"]];
            
            if ([data[@"name"] isEqualToString: @"Close"]) {
                sact = @"隱私";
                NSLog(@"select sact: %@", sact);
                
                statusValue = NO;
                
                // Default Setting
                anImageView.image = [UIImage imageNamed: @"frame_text1"];
                adImageView.image = [UIImage imageNamed: @"frame_text2"];
                pImageView.image = [UIImage imageNamed: @"frame_blue"];
                sImageView.image = [UIImage imageNamed: @"frame_blue"];
                
            } else if ([data[@"name"] isEqualToString: @"Open"]) {
                sact = @"公開";
                NSLog(@"select sact: %@", sact);
                
                statusValue = YES;
                
                // Change image when item content is empty
                if ([wtitle.text isEqualToString: @""]) {
                    NSLog(@"album name is empty");
                    anImageView.image = [UIImage imageNamed: @"frame_text1_red"];
                }
                
                if ([wdescription.text isEqualToString: @""]) {
                    NSLog(@"album description is empty");
                    adImageView.image = [UIImage imageNamed: @"frame_text2_red"];
                }
                
                if ([wfirstpag.titleLabel.text isEqualToString: @"主類別"]) {
                    NSLog(@"1st category is empty");
                    pImageView.image = [UIImage imageNamed: @"frame_blue_red"];
                }
                
                if ([wsecondpag.titleLabel.text isEqualToString: @"子類別"]) {
                    NSLog(@"2nd category is empty");
                    sImageView.image = [UIImage imageNamed: @"frame_blue_red"];
                }
            }
        }
            break;
        case 4://天氣
        {
            data=mdata[@"weather"][row];
            swea=[NSString stringWithFormat:@"%@",data[@"name"]];
        }
            break;
        case 5://心情
        {
            data=mdata[@"mood"][row];
            smood=[NSString stringWithFormat:@"%@",data[@"name"]];
        }
            break;
        case 6://音樂
        {
            data=mdata[@"audio"][row];
            NSLog(@"mdata audio row: %@", mdata[@"audio"][row]);
            
            saudio = [NSString stringWithFormat: @"%@", data[@"id"]];
            NSLog(@"data id: %@", data[@"id"]);
        }
            break;
            
        default:
            break;
    }
    
    NSLog(@"after switch");
    
    if (data!= nil) {
        // Tranlate response string message into Mandarin
        if ([data[@"name"] isEqualToString: @"Close"]) {
            [selectbtn setTitle: sact forState:UIControlStateNormal];
            switchImageView.image = [UIImage imageNamed: @"frame_blue_red"];
        } else if ([data[@"name"] isEqualToString: @"Open"]) {
            [selectbtn setTitle: sact forState:UIControlStateNormal];
            switchImageView.image = [UIImage imageNamed: @"frame_blue"];
        } else {
            // For general setting
            NSLog(@"selectbtn setTitle forState");
            NSLog(@"data name: %@", data[@"name"]);
            [selectbtn setTitle:data[@"name"] forState:UIControlStateNormal];
        }
    }
}

#pragma mark -

//btn
- (IBAction)backbookedit:(id)sender {
    
    for (UIViewController *vc in [self.navigationController viewControllers] ) {
        if ([vc isKindOfClass:[FastViewController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
            return;
        }
    }
    
    FastViewController *fvc=[[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"FastViewController"];
    fvc.selectrow=[wTools userbook];
    fvc.albumid=_album_id;
    fvc.templateid=[NSString stringWithFormat:@"%@",_templateid];
        
    if ([_templateid isEqualToString:@"0"]) {
        fvc.booktype=0;
        fvc.choice = @"Fast";
    } else {
        fvc.booktype=1000;
        fvc.choice = @"Template";
    }
    
    [self.navigationController pushViewController:fvc animated:YES];
}

- (IBAction)save:(id)sender {
    
    NSLog(@"save button pressed");
    
    [self.view endEditing:YES];
    
    NSString *msg=@"";
    
    NSLog(@"sact: %@", sact);
    
    // Translation for communicating with server, because the parameter from server is English
    if ([sact isEqualToString: @"隱私"]) {
        sact = @"close";
    } else if ([sact isEqualToString: @"公開"]) {
        sact = @"open";
    }
    
    if (![sact isEqualToString:@"close"]) {
        if ([wtitle.text isEqualToString:@""]) {
            msg = [msg stringByAppendingString: NSLocalizedString(@"CreateAlbumText-tipAlbumName", @"")];
            msg = [msg stringByAppendingString: @"\n"];
            
            NSLog(@"wtitle.text msg: %@", msg);
        }
        
        if ([wdescription.text isEqualToString:@"" ]) {
            msg = [msg stringByAppendingString: NSLocalizedString(@"CreateAlbumText-tipAlbumDesc", @"")];
            msg = [msg stringByAppendingString: @"\n"];
            
            NSLog(@"wdescription.text msg: %@", msg);
        }
        
        if ([wfirstpag.titleLabel.text isEqualToString: @"主類別"]) {
            msg = [msg stringByAppendingString: NSLocalizedString(@"CreateAlbumText-tipAlbumCate", @"")];
            msg = [msg stringByAppendingString: @"\n"];
            
            NSLog(@"sfir msg: %@", msg);
        }
        if ([wsecondpag.titleLabel.text isEqualToString: @"子類別"]) {
            msg = [msg stringByAppendingString: NSLocalizedString(@"CreateAlbumText-tipAlbumCate2", @"")];
            msg = [msg stringByAppendingString: @"\n"];
            
            NSLog(@"ssec msg: %@", msg);
        }
    }
    
    NSLog(@"msg: %@", msg);
    
    if (![msg isEqualToString:@""]) {
        Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
        //[rv addtitletext:msg];
        [rv addMoreTitleText: msg];
        [rv addBackTouch];
        [rv showView:self.view];
        
        return;
    }
    
    NSMutableDictionary *settingsdic=[NSMutableDictionary new];
    [settingsdic setObject:sact forKey:@"act"];
    
    NSLog(@"saudio intValue: %d", [saudio intValue]);
    
    [settingsdic setObject:[NSNumber numberWithInt:[saudio intValue]] forKey:@"audio"];
    [settingsdic setObject:wdescription.text forKey:@"description"];
    [settingsdic setObject:wlocation.text forKey:@"location"];
    [settingsdic setObject:smood forKey:@"mood"];
    [settingsdic setObject:[NSNumber numberWithInt:[ssec intValue]] forKey:@"secondpaging"];
    [settingsdic setObject:wtitle.text forKey:@"title"];
    [settingsdic setObject:swea forKey:@"weather"];
    
    NSLog(@"settingsdic: %@", settingsdic);
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:settingsdic
                                                       options:0 error:nil];
    NSString *jsonstr=[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSLog(@"jsonStr: %@", jsonstr);
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"" message: @"確認本次編輯並送出?" preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction *okBtn = [UIAlertAction actionWithTitle: @"確定" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *actValue = [settingsdic valueForKey: @"act"];
        NSLog(@"act value: %@", actValue);
        
        if (_postMode) {
            if ([actValue isEqualToString: @"close"]) {
                UIAlertController *alertForPost = [UIAlertController alertControllerWithTitle: @"" message: @"隱私打開才能投稿作品唷!" preferredStyle: UIAlertControllerStyleAlert];
                UIAlertAction *ok = [UIAlertAction actionWithTitle: @"確定" style: UIAlertActionStyleDefault handler: nil];
                [alertForPost addAction: ok];
                [self presentViewController: alertForPost animated: YES completion: nil];
            } else {
                [self callAlbumSettings: jsonstr];
            }
        } else {
            [self callAlbumSettings: jsonstr];
        }
    }];
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleDefault handler: nil];
    [alert addAction: cancelBtn];
    [alert addAction: okBtn];
    [self presentViewController: alert animated: YES completion: nil];
}

- (void)callAlbumSettings: (NSString *)jsonStr {
    [wTools ShowMBProgressHUD];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *respone=[boxAPI albumsettings:[wTools getUserID] token:[wTools getUserToken] album_id:_album_id settings: jsonStr];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (respone!=nil) {
                NSLog(@"%@",respone);
                NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                if ([dic[@"result"] intValue] == 1) {
                    PreviewbookViewController *rv = [[UIStoryboard storyboardWithName: @"Home" bundle: nil]  instantiateViewControllerWithIdentifier: @"PreviewbookViewController"];
                    rv.albumid=_album_id;
                    rv.userbook=@"Y";
                    rv.postMode = _postMode;
                    rv.eventId = _eventId;
                    rv.fromEventPostVC = self.fromEventPostVC;
                    [self.navigationController pushViewController:rv animated:YES];
                    
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    NSString *task_for = @"create_free_album";
                    [defaults setObject: task_for forKey: @"task_for"];
                    [defaults synchronize];
                } else if ([dic[@"result"] intValue] == 0) {
                    NSLog(@"失敗：%@",dic[@"message"]);
                    [self showCustomErrorAlert: dic[@"message"]];
                } else {
                    [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                }
            }
        });
    });
}

//選擇器回傳
-(void)SaveDataRow:(NSInteger)row{
    
    NSLog(@"SaveDataRow");
    
    [self w2dismissPopupViewControllerAnimated:YES completion:nil];
    
    NSDictionary *data=nil;
    
    if (player!=nil) {
        [player pause];
    }
    
    switch (selectbtn.tag) {
        case 1://主分類
        {
            sfir=[NSString stringWithFormat:@"%li",(long)row];
            data= mdata[@"firstpaging"][row];
            ssec=@"";
            
            NSLog(@"data: %@", data[@"name"]);
            
            if (data[@"name"]) {
                pImageView.image = [UIImage imageNamed: @"frame_blue"];
            } else {
                pImageView.image = [UIImage imageNamed: @"frame_blue_red"];
            }
            
            [wsecondpag setTitle:NSLocalizedString(@"CreateAlbumText-pCate2", @"") forState:UIControlStateNormal];
        }
            break;
        case 2://次分頁
        {
            int x= [sfir intValue];
            data=mdata[@"firstpaging"][x][@"secondpaging"][row];
            ssec=[NSString stringWithFormat:@"%@",data[@"id"]];
            
            NSLog(@"data: %@", data[@"name"]);
            NSLog(@"ssec: %@", ssec);
            
            if (data[@"name"]) {
                sImageView.image = [UIImage imageNamed: @"frame_blue"];
            } else {
                sImageView.image = [UIImage imageNamed: @"frame_blue_red"];
            }
            
            NSLog(@"ssec: %@", ssec);
        }
            break;
        case 3://開放
        {
            data=mdata[@"act"][row];
            //sact=[NSString stringWithFormat:@"%@",data[@"name"]];
            
            if ([data[@"name"] isEqualToString: @"Close"]) {
                sact = @"隱私";
                NSLog(@"select sact: %@", sact);
                
                statusValue = NO;
                
                // Default Setting
                anImageView.image = [UIImage imageNamed: @"frame_text1"];
                adImageView.image = [UIImage imageNamed: @"frame_text2"];
                pImageView.image = [UIImage imageNamed: @"frame_blue"];
                sImageView.image = [UIImage imageNamed: @"frame_blue"];
                
            } else if ([data[@"name"] isEqualToString: @"Open"]) {
                sact = @"公開";
                NSLog(@"select sact: %@", sact);
                
                statusValue = YES;
                
                // Change image when item content is empty
                if ([wtitle.text isEqualToString: @""]) {
                    NSLog(@"album name is empty");
                    anImageView.image = [UIImage imageNamed: @"frame_text1_red"];
                }
                
                if ([wdescription.text isEqualToString: @""]) {
                    NSLog(@"album description is empty");
                    adImageView.image = [UIImage imageNamed: @"frame_text2_red"];
                }
                
                if ([wfirstpag.titleLabel.text isEqualToString: @"主類別"]) {
                    NSLog(@"1st category is empty");
                    pImageView.image = [UIImage imageNamed: @"frame_blue_red"];
                }
                
                if ([wsecondpag.titleLabel.text isEqualToString: @"子類別"]) {
                    NSLog(@"2nd category is empty");
                    sImageView.image = [UIImage imageNamed: @"frame_blue_red"];
                }
            }
        }
            break;
        case 4://天氣
        {
            data=mdata[@"weather"][row];
            swea=[NSString stringWithFormat:@"%@",data[@"name"]];            
        }
            break;
        case 5://心情
        {
            data=mdata[@"mood"][row];
            smood=[NSString stringWithFormat:@"%@",data[@"name"]];
        }
            break;
        case 6://音樂
        {
            data=mdata[@"audio"][row];
            NSLog(@"mdata audio row: %@", mdata[@"audio"][row]);
            
            saudio = [NSString stringWithFormat: @"%@", data[@"id"]];
            NSLog(@"data id: %@", data[@"id"]);
        }
            break;
            
        default:
            break;
    }
    if (data != nil) {
        // Tranlate response string message into Mandarin
        if ([data[@"name"] isEqualToString: @"Close"]) {
            [selectbtn setTitle: sact forState:UIControlStateNormal];
            switchImageView.image = [UIImage imageNamed: @"frame_blue_red"];
        } else if ([data[@"name"] isEqualToString: @"Open"]) {
            [selectbtn setTitle: sact forState:UIControlStateNormal];
            switchImageView.image = [UIImage imageNamed: @"frame_blue"];
        } else {
            // For general setting
            [selectbtn setTitle:data[@"name"] forState:UIControlStateNormal];
        }
    }
}

//選擇中
-(void)DidselectDataRow:(NSInteger)row{
    NSLog(@"DidselectDataRow: %ld", (long)row);
    
    if (selectbtn==waudio) {
        NSArray *arr=mdata[@"audio"];
        
        NSString *strurl=arr[row][@"url"];
        NSLog(@"%@",strurl);
        
        
        NSURL *url=[NSURL URLWithString:strurl];
        if (player!=nil) {
            [player pause];
        }
        
        playerItem=[AVPlayerItem playerItemWithURL:url];
        player=[AVPlayer playerWithPlayerItem:playerItem];
        // player=[AVPlayer playerWithURL:url];
        [player play];
    }
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (statusValue) {
        if ([textField.text isEqualToString: @""]) {
            NSLog(@"empty");
            anImageView.image = [UIImage imageNamed: @"frame_text1_red"];
        } else if (![textField.text isEqualToString: @""]) {
            NSLog(@"not empty");
            anImageView.image = [UIImage imageNamed: @"frame_text1"];
        }
    }
    
    [textField resignFirstResponder];
    [self.view endEditing: YES];
    
    return YES;
}

- (void)textFieldDidChange: (UITextField *)textField {
    NSLog(@"text changed");
    
    if (statusValue) {
        if ([textField.text isEqualToString: @""]) {
            anImageView.image = [UIImage imageNamed: @"frame_text1_red"];
        } else {
            anImageView.image = [UIImage imageNamed: @"frame_text1"];
        }
    }
}

#pragma mark - UITextView Delegate Methods

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (range.length == 0) {
        if ([text isEqualToString:@"\n"]) {
            [textView resignFirstResponder];
            return NO;
        }
    }
    
    NSString *resultString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    BOOL isPressedBackspaceAfterSingleSpaceSymbol = [text isEqualToString:@""] && [resultString isEqualToString:@""] && range.location == 0 && range.length == 1;
    if (isPressedBackspaceAfterSingleSpaceSymbol) {
        //  your actions for deleteBackward actions
        notext.hidden=NO;
    }else{
        
        if ([resultString isEqualToString:@""]) {
            notext.hidden=NO;
        }else{
            notext.hidden=YES;
        }
    }
    
    if (statusValue) {
        if ([[textView.text stringByAppendingString: text] isEqualToString: @""]) {
            adImageView.image = [UIImage imageNamed: @"frame_text2_red"];
        } else {
            adImageView.image = [UIImage imageNamed: @"frame_text2"];
        }
    }
    
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    notext.hidden=YES;
    if (textView.text.length==0) {
        notext.hidden=NO;
    }
    
    return YES;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - UIPickerView Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    //NSLog(@"arrayForPicker.count: %lu", (unsigned long)arrayForPicker.count);
    return arrayForPicker.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSLog(@"pickerView titleForRow forComponent");
    NSLog(@"arrayForPicker[row]: %@", arrayForPicker[row]);
    return arrayForPicker[row];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView
             attributedTitleForRow:(NSInteger)row
                      forComponent:(NSInteger)component
{
    NSLog(@"pickerView attributedTitleForRow forComponent");
    NSLog(@"row: %ld", (long)row);
    NSLog(@"arrayForPicker[row]: %@", arrayForPicker[row]);
    
    return [[NSAttributedString alloc] initWithString:arrayForPicker[row]
                                           attributes:@
            {
            NSForegroundColorAttributeName:[UIColor whiteColor]
            }];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"pickerView didSelectRow: %ld inComponent: %ld", (long)row, (long)component);
    
    if (selectbtn.tag == 1) {
        NSLog(@"selectbtn.tag: %ld", (long)selectbtn.tag);
        selectFirstRow = row;
        NSLog(@"selectFirstRow: %ld", (long)selectFirstRow);
    } else if (selectbtn.tag == 2) {
        NSLog(@"selectbtn.tag: %ld", (long)selectbtn.tag);
        selectSecondRow = row;
        NSLog(@"selectSecondRow: %ld", (long)selectSecondRow);
    } else {
        NSLog(@"selectbtn.tag: %ld", (long)selectbtn.tag);
        selectRow = row;
    }
    
    if (selectbtn==waudio) {
        NSArray *arr=mdata[@"audio"];
        
        NSString *strurl=arr[row][@"url"];
        NSLog(@"%@",strurl);
        
        NSURL *url=[NSURL URLWithString:strurl];
        if (player!=nil) {
            [player pause];
        }
        
        playerItem=[AVPlayerItem playerItemWithURL:url];
        player=[AVPlayer playerWithPlayerItem:playerItem];
        // player=[AVPlayer playerWithURL:url];
        [player play];
    }
}

- (void)performSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString: @"showPreviewbookViewController"]) {
        PreviewbookViewController *rv=[[PreviewbookViewController alloc]initWithNibName:@"PreviewbookViewController" bundle:nil];
        //PreviewbookViewController *rv = [[UIStoryboard storyboardWithName: @"Home" bundle: nil]  instantiateViewControllerWithIdentifier: @"PreviewbookViewController"];        
        rv.albumid=_album_id;
        rv.userbook=@"Y";
        rv.postMode = _postMode;
        rv.eventId = _eventId;
        
        [self.navigationController pushViewController: rv animated: YES];
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
