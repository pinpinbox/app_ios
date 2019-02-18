//
//  TemplateViewController.m
//  wPinpinbox
//
//  Created by Angus on 2016/2/1.
//  Copyright (c) 2016年 Angus. All rights reserved.
//

#import "TemplateViewController.h"
#import "O_drag.h"
#import "PhotosViewController.h"
#import "wTools.h"
#import "boxAPI.h"
#import "AsyncImageView.h"
#import "CooperationViewController.h"

#import "UIColor+Extensions.h"
#import "CustomIOSAlertView.h"
#import "AlbumCreationViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "UIView+Toast.h"

#import "MyLayout.h"

#import "GlobalVars.h"

#import "AppDelegate.h"


#import "UIViewController+ErrorAlert.h"
#import "CustomIOSAlertView.h"

@interface TemplateViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,PhotosViewDelegate, UIGestureRecognizerDelegate> {
    __weak IBOutlet UICollectionView *mycollection;
    __weak IBOutlet UIButton *conbtn;
    
    NSInteger selectItem;
    NSMutableArray *imagearr;    //版型資料
    
    NSInteger editimage;
    
    BOOL templatePhotoExist;
    BOOL isSwap;
    
    NSInteger selectImgCount;
        
    UIImage *img1;
    UIImage *img2;
    
    UIImage *imgForCancel;
}
@property (weak, nonatomic) IBOutlet UIView *ShowView;
@property (weak, nonatomic) IBOutlet UICollectionView *dataCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *swapBtn;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@end

@implementation TemplateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"TemplateViewController");    
    NSLog(@"self.choice: %@", self.choice);
    NSLog(@"self.templateid: %@", self.templateid);
    
    // Set the titleView text color for white
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:18 weight:UIFontWeightLight], NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    isSwap = NO;
    self.saveBtn.layer.cornerRadius = 8;
    
    wtitle.text=NSLocalizedString(@"CreateAlbumText-createAlbum", @"");
    imagearr=[NSMutableArray new];
    [[_ShowView layer]setMasksToBounds:YES];
    
//    NSString* const CreativeSDKClientId = @"9acbf5b342a8419584a67069e305fa39";
//    NSString* const CreativeSDKClientSecret = @"b4d92522-49ac-4a69-9ffe-eac1f494c6fc";
    
    [self getAlbumOfDiy];
}

- (void)processAlbumDiyResult:(NSDictionary *)dic {
    if ([dic[@"result"] intValue] == 1) {
        _templatelist = [dic[@"data"][@"frame"]mutableCopy];
        // ImageDataArr=[NSMutableArray arrayWithArray:dic[@"data"][@"photo"]];
        selectItem = 0;
        NSDictionary *data = _templatelist[selectItem];
        //NSLog(@"data: %@", data);
        NSArray *frame = data[@"blank"];
        
        if (![wTools objectExists: frame]) {
            return;
        }
        
        for (int i = 0; i < frame.count; i++) {
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject: frame[i] forKey: @"frame"];
            [imagearr addObject: dic];
        }
        
        [self showimageview];
        [mycollection reloadData];
        
        @try {
            [wTools HideMBProgressHUD];
        } @catch (NSException *exception) {
            // Print exception information
            NSLog( @"NSException caught" );
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
            return;
        }
        [self getCooperation];
    } else if ([dic[@"result"] intValue] == 0) {
        NSLog(@"失敗：%@",dic[@"message"]);
        if ([wTools objectExists: dic[@"message"]]) {
            [self showCustomErrorAlert: dic[@"message"]];
        } else {
            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
        }
        [wTools HideMBProgressHUD];
    } else {
        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
        [wTools HideMBProgressHUD];
    }
}

- (void)getAlbumOfDiy {
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    __block typeof(_albumid) aid = _albumid;
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI getalbumofdiy: [wTools getUserID]
                                             token: [wTools getUserToken]
                                          album_id: aid];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [wTools HideMBProgressHUD];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog( @"NSException caught" );
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason );
                return;
            }
            if (response != nil) {
                NSLog(@"response from getalbumofdiy: %@", response);
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"TemplateViewController");
                    NSLog(@"getAlbumOfDiy");
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getalbumofdiy"];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    [wself processAlbumDiyResult:dic];
                }
            }
        });
    });
}

- (void)getCooperation {
    NSLog(@"getCooperation");
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    NSMutableDictionary *data = [NSMutableDictionary new];
    [data setObject: _albumid forKey: @"type_id"];
    [data setObject: [wTools getUserID] forKey: @"user_id"];
    [data setObject: @"album" forKey: @"type"];
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *response = [boxAPI getcooperation: [wTools getUserID]
                                              token: [wTools getUserToken]
                                               data: data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [wTools HideMBProgressHUD];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog( @"NSException caught" );
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason );
                return;
            }
            if (response != nil) {
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"TemplateViewController");
                    NSLog(@"getCooperation");
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getcooperation"];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    if ([dic[@"result"] boolValue]) {
                        wself.identity = dic[@"data"];
                    } else {
                        NSLog(@"失敗：%@", dic[@"message"]);
                        if ([wTools objectExists: dic[@"message"]]) {
                            [wself showCustomErrorAlert: dic[@"message"]];
                        } else {
                            [wself showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                        }
                    }
                }
            }
        });
    });
}

-(void)viewWillAppear:(BOOL)animated{
    CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
    //判斷3.5吋或4吋螢幕以載入不同storyboard
    if (iOSDeviceScreenSize.height == 480) {
        CGPoint con=_ShowView.center;
        float s=0.8f;
        _ShowView.frame=CGRectMake(_ShowView.frame.origin.x, _ShowView.frame.origin.y, 258*s, 387*s);
        _ShowView.center=CGPointMake(con.x, _ShowView.center.y-5);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav popViewControllerAnimated: YES];
}

- (IBAction)swapImgBtnPress:(id)sender {
    NSLog(@"");
    NSLog(@"swapImage");
    
    NSUInteger imageCount = 0;
    
    if (![wTools objectExists: _ShowView.subviews]) {
        return;
    }
    
    for (UIView *v in _ShowView.subviews) {
        NSLog(@"v: %@", v);
        
        if ([v isKindOfClass: [O_drag class]]) {
            imageCount++;
        }
    }
    NSLog(@"imageCount: %lu", (unsigned long)imageCount);
    
    if (imageCount < 2) {
        NSLog(@"imageCount < 2");
        isSwap = NO;
        
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor firstGrey];
        
        [self.view makeToast: @"至少添加兩張相片"
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
    } else if (imageCount >= 2) {
        NSLog(@"imageCount >= 2");
        isSwap = !isSwap;
    }
    
    NSLog(@"isSwap: %d", isSwap);
    
    if (isSwap) {
        self.backBtn.hidden = YES;
        self.saveBtn.hidden = YES;
        [self.swapBtn setImage: [UIImage imageNamed: @"ic200_template_photo_change_dark"] forState: UIControlStateNormal];
        
        UIView *msgView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.dataCollectionView.bounds.size.width, self.dataCollectionView.bounds.size.height)];
        msgView.backgroundColor = [UIColor whiteColor];
        msgView.myLeftMargin = msgView.myRightMargin = 0;
        msgView.myTopMargin = msgView.myBottomMargin = 0;
        msgView.accessibilityIdentifier = @"msgView";
        [self.dataCollectionView addSubview: msgView];
        
        UILabel *msgLabel = [UILabel new];
        msgLabel.myLeftMargin = msgLabel.myRightMargin = 0;
        msgLabel.myTopMargin = msgLabel.myBottomMargin = 10;
        msgLabel.text = @"點選兩張相片可交換位置";
        msgLabel.textColor = [UIColor firstGrey];
        msgLabel.font = [UIFont systemFontOfSize: 18];
        msgLabel.textAlignment = NSTextAlignmentCenter;
        msgLabel.numberOfLines = 0;
        [msgLabel sizeToFit];
        msgLabel.center = CGPointMake(msgView.bounds.size.width / 2, msgView.bounds.size.height / 2);
        [msgView addSubview: msgLabel];
        
        selectImgCount = 0;
        
        for (UIView *v in _ShowView.subviews) {
            NSLog(@"\n v: %@", v);
            if ([v isKindOfClass: [O_drag class]]) {
                v.userInteractionEnabled = NO;
            }
        }
    } else {
        self.backBtn.hidden = NO;
        self.saveBtn.hidden = NO;
        [self.swapBtn setImage: [UIImage imageNamed: @"ic200_template_photo_change_light"] forState: UIControlStateNormal];
        
        if (![wTools objectExists: self.dataCollectionView.subviews]) {
            return;
        }
        
        for (UIView *v in self.dataCollectionView.subviews) {
            if ([v.accessibilityIdentifier isEqualToString: @"msgView"]) {
                [v removeFromSuperview];
            }
        }
        selectImgCount = 0;
        
        if (![wTools objectExists: _ShowView.subviews]) {
            return;
        }
        
        for (UIView *v in _ShowView.subviews) {
            NSLog(@"");
            NSLog(@"v: %@", v);
            
            if ([v isKindOfClass: [O_drag class]]) {
                v.userInteractionEnabled = YES;
                v.accessibilityIdentifier = @"";
                v.layer.borderWidth = 0.0;
                v.layer.borderColor = [UIColor clearColor].CGColor;
            }
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches
           withEvent:(UIEvent *)event {
    NSLog(@"\ntouchesBegan");
    UITouch *touch = [touches anyObject];
    NSLog(@"touch.view: %@", touch.view);
    NSLog(@"touch.view.tag: %ld",(long)touch.view.tag);
    
    if (isSwap) {
        for (UIView *v in _ShowView.subviews) {
            if ([v isKindOfClass: [O_drag class]]) {
                NSLog(@"");
                NSLog(@"v isKindOfClass O_drag class");
                NSLog(@"v: %@", v);
                
                CGPoint location = [touch locationInView: v];
                BOOL withinBounds = CGRectContainsPoint(v.bounds, location);
                
                if (withinBounds) {
                    NSLog(@"withinBounds");
                    NSLog(@"v.subviews: %@", v.subviews);
                    NSLog(@"v.accessibilityIdentifier: %@", v.accessibilityIdentifier);
                    
                    if ([v.accessibilityIdentifier isEqualToString: @"selected"]) {
                        v.layer.borderColor = [UIColor clearColor].CGColor;
                        v.layer.borderWidth = 0.0;
                    } else {
                        v.layer.borderColor = [UIColor firstPink].CGColor;
                        v.layer.borderWidth = 5.0;
                    }
                }
            }
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches
           withEvent:(UIEvent *)event {
    NSLog(@"\ntouchesEnded");
    UITouch *touch = [touches anyObject];
    NSLog(@"touch.view: %@", touch.view);
    NSLog(@"touch.view.tag: %ld",(long)touch.view.tag);
    
    if (isSwap) {
        for (UIView *v in _ShowView.subviews) {
            NSLog(@"v: %@", v);
            
            if ([v isKindOfClass: [O_drag class]]) {
                NSLog(@"");
                NSLog(@"v isKindOfClass O_drag class");
                NSLog(@"v: %@", v);
                
                CGPoint location = [touch locationInView: v];
                BOOL withinBounds = CGRectContainsPoint(v.bounds, location);
                
                if (withinBounds) {
                    NSLog(@"withinBounds");
                    NSLog(@"v.subviews: %@", v.subviews);
                    NSLog(@"v.accessibilityIdentifier: %@", v.accessibilityIdentifier);
                    
                    if ([v.accessibilityIdentifier isEqualToString: @"selected"]) {
                        selectImgCount--;
                        v.accessibilityIdentifier = @"";
                        v.layer.borderColor = [UIColor clearColor].CGColor;
                        v.layer.borderWidth = 0.0;
                        //v.tag = 0;
                        
                        for (UIView *subView in v.subviews) {
                            if ([subView isKindOfClass: [UIImageView class]]) {
//                                UIImageView *imgV = (UIImageView *)subView;
                                
                                /*
                                if (imgV.tag == 1) {
                                    img1 = nil;
                                } else if (imgV.tag == 2) {
                                    img2 = nil;
                                }
                                
                                imgV.tag = 0;
                                 */
                            }
                        }
                    } else {
                        selectImgCount++;
                        v.accessibilityIdentifier = @"selected";
                        v.layer.borderColor = [UIColor firstPink].CGColor;
                        v.layer.borderWidth = 5.0;
                        //v.tag = selectImgCount;
                        
                        for (UIView *subView in v.subviews) {
                            if ([subView isKindOfClass: [UIImageView class]]) {
                                UIImageView *imgV = (UIImageView *)subView;
                                imgV.tag = selectImgCount;
                                NSLog(@"imgV.tag: %ld", (long)imgV.tag);
                                
                                if (imgV.tag == 1) {
                                    img1 = imgV.image;
                                } else if (imgV.tag == 2) {
                                    img2 = imgV.image;
                                }
                            }
                        }
                    }
                }
            }
        }
        
        NSLog(@"");
        NSLog(@"");
        NSLog(@"img1: %@", img1);
        NSLog(@"img2: %@", img2);
        NSLog(@"");
        NSLog(@"");
        
        NSLog(@"selectImgCount: %ld", (long)selectImgCount);
        
        if (selectImgCount == 2) {
            selectImgCount = 0;
            
            for (UIView *v in _ShowView.subviews) {
                NSLog(@"v: %@", v);
                
                if ([v isKindOfClass: [O_drag class]]) {
                    NSLog(@"");
                    NSLog(@"v isKindOfClass O_drag class");
                    NSLog(@"v: %@", v);
                    
                    if ([v.accessibilityIdentifier isEqualToString: @"selected"]) {
                        for (UIView *subView in v.subviews) {
                            NSLog(@"subView: %@", subView);
                            
                            if ([subView isKindOfClass: [UIImageView class]]) {
                                UIImageView *imgV = (UIImageView *)subView;
                                NSLog(@"img1: %@", img1);
                                NSLog(@"img2: %@", img2);
                                
                                if (imgV.tag == 1) {
                                    imgV.image = img2;
                                } else if (imgV.tag == 2) {
                                    imgV.image = img1;
                                }
                            }
                        }
                        v.accessibilityIdentifier = @"";
                        v.layer.borderColor = [UIColor clearColor].CGColor;
                        v.layer.borderWidth = 0.0f;
                    }
                    for (UIView *subView in v.subviews) {
                        if ([subView isKindOfClass: [UIImageView class]]) {
                            UIImageView *imgV = (UIImageView *)subView;
                            imgV.tag = 0;
                        }
                    }
                }
            }
        }
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches
               withEvent:(UIEvent *)event {
    NSLog(@"");
    NSLog(@"touchesCancelled");
    UITouch *touch = [touches anyObject];
    NSLog(@"touch.view: %@", touch.view);
    NSLog(@"touch.view.tag: %d", (int)touch.view.tag);
}

//共用
-(IBAction)coppertation:(id)sender {
    if ([_identity isEqualToString:@"editor"]) {
//        Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
//        [rv addtitletext:NSLocalizedString(@"CreateAlbumText-tipPermissions", @"")];
//        [rv addBackTouch];
//        [rv showView:self.view];
        [UIViewController showCustomErrorAlertWithMessage:NSLocalizedString(@"CreateAlbumText-tipPermissions", @"") onButtonTouchUpBlock:^(CustomIOSAlertView * _Nonnull customAlertView, int buttonIndex) {
            [customAlertView close];
        }];
        return;
    }
    CooperationViewController *copv = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"CooperationViewController"];
    copv.albumid=_albumid;
    copv.identity=_identity;
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav pushViewController: copv animated: YES];
}

- (void)checkTemplatePhoto {
    templatePhotoExist = YES;
    
    for (int i = 0; i < imagearr.count; i++) {
        NSMutableDictionary *data = imagearr[i];
        NSLog(@"imagearr count: %lu", (unsigned long)imagearr.count);
        
        if (data[@"image"]) {
            NSLog(@"image exists");
        } else {
            NSLog(@"image does not exist");
            templatePhotoExist = NO;
        }
    }
}

//上傳圖片
-(IBAction)upphotobtn:(id)sender {
    NSLog(@"upphotobtn");
    NSUInteger templatePhotoNumber = 0;
    
    for (UIView *v in [_ShowView subviews]) {
        NSLog(@"v: %@", v);
        
        if ([v isKindOfClass: [O_drag class]]) {
            NSLog(@"O_drag class exists");
            templatePhotoNumber++;
        }
    }
    NSLog(@"templatePhotoNumber: %lu", (unsigned long)templatePhotoNumber);
    NSLog(@"imagearr count: %lu", (unsigned long)imagearr.count);
    
    //[self checkTemplatePhoto];
    //NSLog(@"templatePhotoExist: %d", templatePhotoExist);
    
    if (templatePhotoNumber == imagearr.count) {
        NSLog(@"All the fields are full with photo");
        [self upphoto];
    } else {
        NSLog(@"There is at least one empty photo field");
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"" message: @"還有欄位沒放相片" preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction *okBtn = [UIAlertAction actionWithTitle: @"確定" style: UIAlertActionStyleDefault handler: nil];
        [alert addAction: okBtn];
        [self presentViewController: alert animated: YES completion: nil];
    }
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section {
    return _templatelist.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableview = nil;
    
    //photocell
    UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"photocell" forIndexPath:indexPath];
    reusableview=footerview;
    //        return myCell;
    return reusableview;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *myCell = [collectionView
                                    dequeueReusableCellWithReuseIdentifier:@"FastV"
                                    forIndexPath:indexPath];
    AsyncImageView *imagev=(AsyncImageView *)[myCell viewWithTag:2222];
    imagev.showActivityIndicator = NO;
    imagev.image = nil;
    imagev.contentMode = UIViewContentModeScaleAspectFill;
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: imagev];
    
    if ([self.templatelist[indexPath.row][@"image_url_thumbnail"] isKindOfClass: [NSNull class]]) {
        imagev.image = [UIImage imageNamed: @"bg200_no_image.jpg"];
    } else {
        imagev.imageURL=[NSURL URLWithString:_templatelist[indexPath.row][@"image_url_thumbnail"]];
    }
    [[imagev layer]setMasksToBounds:YES];
    
    UILabel *lab = (UILabel *)[myCell viewWithTag:1111];
    lab.text = @"";
    
    // Set up the Selected Cell
    if (indexPath.item == selectItem) {
        myCell.layer.borderWidth = 3;
        myCell.layer.borderColor = [[UIColor colorWithRed: 233.0/255.0 green: 30.0/255.0 blue: 99.0/255.0 alpha: 1.0] CGColor];
    } else {
        myCell.layer.borderWidth = 0;
        myCell.layer.borderColor = [UIColor clearColor].CGColor;
    }
    return myCell;
}

#pragma mark - UICollectionViewDelegate Methods
- (void)collectionView:(UICollectionView *)collectionView
didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    //選擇
    BOOL hasImage = NO;
    
    for (UIView *v in _ShowView.subviews) {
        NSLog(@"v: %@", v);
        
        if ([v isKindOfClass: [O_drag class]]) {
            hasImage = YES;
        }
    }
    
    if (hasImage) {
        [self showCustomForChangeTemplate: @"更換版型樣式?" indexPathRow: indexPath.row];
    } else {
        selectItem = indexPath.row;
        imagearr = [NSMutableArray new];
        
        NSDictionary *data = _templatelist[selectItem];
        NSArray *frame = data[@"blank"];
        
        for (int i = 0; i < frame.count; i++) {
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject:frame[i] forKey:@"frame"];
            [imagearr addObject:dic];
        }
        [self showimageview];
        [self.dataCollectionView reloadData];
    }
}

#pragma mark - UICollectionViewFlowLayoutDelegate Methods
-(CGSize)collectionView:(UICollectionView *)collectionView
                 layout:(UICollectionViewLayout *)collectionViewLayout
 sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(54, 94);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

//顯示畫面
-(void)showimageview{
    _ShowView.backgroundColor=[UIColor whiteColor];
    
    for (UIView *v in [_ShowView subviews]) {
        [v removeFromSuperview];
    }
    //1336/2004
    
    float mag =_ShowView.bounds.size.width/1336;
    int i = 0;
    
    if (![wTools objectExists: imagearr]) {
        return;
    }
    
    for (NSDictionary *dic in imagearr) {
        NSDictionary *f=dic[@"frame"];
        float x=[f[@"L"] floatValue]*mag;
        float y=[f[@"T"] floatValue]*mag;
        float w=[f[@"W"] floatValue]*mag;
        float h=[f[@"H"] floatValue]*mag;
        
        //判斷有沒有圖片
        if (dic[@"image"]) {
            //有圖片壓圖
            O_drag *v=[[O_drag alloc]initWithFrame:CGRectMake(x, y, w, h)];
            v.tag=210+i;
            [v setImage:dic[@"image"]];
            [_ShowView addSubview:v];
        } else {
            UIView *v=[[UIView alloc]initWithFrame:CGRectMake(x, y, w, h)];
            v.backgroundColor=[UIColor firstGrey];
            v.tag=210+i;
            [_ShowView addSubview:v];
            
            //沒圖片用按鈕
            //icon_creatnewframe_plus.png
            
            UIImageView *addimage=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
            //addimage.image=[UIImage imageNamed:@"icon_creatnewframe_plus.png"];
            addimage.image = [UIImage imageNamed: @"camera.png"];
            addimage.center=CGPointMake(v.frame.size.width/2, v.frame.size.height/2);
            [v addSubview:addimage];
            
            //按鈕
            UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame=CGRectMake(0, 0, w, h);
            btn.tag=i;
            [btn addTarget:self action:@selector(addimage:) forControlEvents:UIControlEventTouchUpInside];
            [v addSubview:btn];
        }
        i++;
    }
    AsyncImageView *imagev=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0, _ShowView.frame.size.width, _ShowView.frame.size.height)];
    imagev.showActivityIndicator = NO;
    [_ShowView addSubview:imagev];
    imagev.tag=200;
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: imagev];
    imagev.imageURL=[NSURL URLWithString:_templatelist[selectItem][@"image_url"]];
    [[imagev layer]setMasksToBounds:YES];
    
}

//新增圖片
-(void)addimage:(UIButton *)sender{
    NSLog(@"11");
    editimage=sender.tag;
    NSLog(@"editimage: %ld", (long)editimage);
    
    PhotosViewController *pvc=[[UIStoryboard storyboardWithName:@"PhotosVC" bundle:nil]instantiateViewControllerWithIdentifier:@"PhotosViewController2"];
    pvc.selectrow=1;
    pvc.phototype=@"1";
    pvc.delegate=self;
    pvc.choice = _choice;
    pvc.fromVC = @"TemplateViewController";
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav pushViewController: pvc animated: YES];
}

#pragma mark - PhotoViewControllerDelegate Methods
//delegate
//-(void)imageCropViewController:(PhotosViewController *)controller ImageArr:(NSArray *)Images{
- (void)imageCropViewController:(PhotosViewController *)controller
                       ImageArr:(NSArray *)Images
                    compression:(CGFloat)compressionQuality {
    
    imgForCancel = Images[0];
    [self showCustomAlertForEffect: @"要使用特效編輯嗎?" ImageArr: Images];
    
    /*
    Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
    [rv addtitletext:NSLocalizedString(@"CreateAlbumText-tipGoEditor", @"")];
    [rv addSelectBtntext:NSLocalizedString(@"GeneralText-yes", @"") btn2:NSLocalizedString(@"GeneralText-no", @"") ];
    rv.btn1select=^(BOOL select){
        if (select) {
            [self displayEditorForImahe:Images[0]];
        }else{
            [self addimagetoitem:Images[0]];
        }
    };
    [rv showView:self.view];
     */
}

#pragma mark -

//新增相片
-(void)addimagetoitem:(UIImage *)image{
    NSLog(@"addimagetoitem");
    
    NSMutableDictionary *dic = imagearr[editimage];
    [dic setObject:image forKey:@"image"];
    
    UIView *v = [_ShowView viewWithTag: 210 + editimage];
    
    CGRect frame = v.frame;
    [v removeFromSuperview];
    
    O_drag *imgv = [[O_drag alloc]initWithFrame:frame];
    imgv.tag = 210 + editimage;
    [imgv setImage:image];
    
    [_ShowView addSubview:imgv];
    
    UIView *asyncv=[_ShowView viewWithTag:200];
    [_ShowView bringSubviewToFront:asyncv];
    
    
    //4_8button_changphoto.png
    //刪除按鈕
    UIButton *deletebtn=[UIButton buttonWithType:UIButtonTypeCustom];
    //[deletebtn setImage:[UIImage imageNamed:@"4_8button_changphoto.png"] forState:UIControlStateNormal];
    [deletebtn setImage: [UIImage imageNamed: @"4-08button_delete.png"] forState: UIControlStateNormal];
    [deletebtn addTarget:self action:@selector(deleteimage:) forControlEvents:UIControlEventTouchUpInside];
    deletebtn.tag=editimage+310;
    deletebtn.frame = CGRectMake(imgv.frame.origin.x + imgv.frame.size.width - 28, imgv.frame.origin.y + imgv.frame.size.height - 28, 28, 28);
    [_ShowView addSubview:deletebtn];
    
    //[_ShowView bringSubviewToFront:asyncv];
    
    for (UIView *v in [_ShowView subviews]) {
        NSLog(@"v: %@", v);
    }
}

//刪除照片
-(void)deleteimage:(UIButton *)sender{
    [self showCustomForDeletingImage: NSLocalizedString(@"CreateAlbumText-tipConfirmDel", @"") btn:sender];
   
    /*
    Remind *rv = [[Remind alloc]initWithFrame:self.view.bounds];
    
    [rv addtitletext:NSLocalizedString(@"CreateAlbumText-tipConfirmDel", @"")];
    [rv addSelectBtntext:NSLocalizedString(@"GeneralText-yes", @"") btn2:NSLocalizedString(@"GeneralText-no", @"") ];
    
    rv.btn1select=^(BOOL select){
        if (select) {
            UIView *v=[_ShowView viewWithTag: sender.tag-100];
            CGRect frame = v.frame;
            int tag = sender.tag;
            [v removeFromSuperview];
            [sender removeFromSuperview];
            
            v = [[UIView alloc] initWithFrame: frame];
            v.backgroundColor = [UIColor firstGrey];
            v.tag = sender.tag - 100;
            [_ShowView addSubview:v];
            
            //沒圖片用按鈕
            //icon_creatnewframe_plus.png
            
            UIImageView *addimage = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 30, 30)];
            //addimage.image = [UIImage imageNamed: @"icon_creatnewframe_plus.png"];
            addimage.image = [UIImage imageNamed: @"camera.png"];
            addimage.center = CGPointMake(v.frame.size.width / 2, v.frame.size.height / 2);
            [v addSubview: addimage];
            
            //按鈕
            UIButton *btn = [UIButton buttonWithType: UIButtonTypeCustom];
            btn.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
            btn.tag = tag - 310;
            [btn addTarget: self action: @selector(addimage:) forControlEvents: UIControlEventTouchUpInside];
            [v addSubview: btn];
            
            UIView *asyncv = [_ShowView viewWithTag: 200];
            [_ShowView bringSubviewToFront: asyncv];
            
        } else {
            
        }
    };
    [rv showView:self.view];
    
    for (UIView *v in [_ShowView subviews]) {
        NSLog(@"v: %@", v);
    }
     */
}

-(void)displayEditorForImahe:(UIImage *)imageToEdit {
    
    
}


//上傳相片
- (void)processUploadPhotoResult:(NSDictionary *)dic{
    if ([dic[@"result"] intValue] == 1) {
        NSLog(@"dic result boolValue: %d", [dic[@"result"] boolValue]);
        NSLog(@"self.navigationController.viewControllers: %@", self.navigationController.viewControllers);
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
        for (UIViewController *vc in [appDelegate.myNav viewControllers] ) {
            if ([vc isKindOfClass:[AlbumCreationViewController class]]) {
                NSLog(@"_templateid: %@", _templateid);
                
                if ([self.delegate respondsToSelector: @selector(uploadPhotoDidComplete:)]) {
                    [self.delegate uploadPhotoDidComplete: self];
                }
                AlbumCreationViewController *albumCreationVC = (AlbumCreationViewController *)vc;
                [albumCreationVC reloaddatat: [NSMutableArray arrayWithArray: dic[@"data"][@"photo"]]];
                [albumCreationVC reloadItem: [dic[@"data"][@"photo"] count] - 1];
                albumCreationVC.albumid = _albumid;
                albumCreationVC.templateid = _templateid;
                albumCreationVC.event_id = _event_id;
                albumCreationVC.postMode = _postMode;
                albumCreationVC.choice = @"Template";
                albumCreationVC.isNew = NO;
                
                [appDelegate.myNav popToViewController: vc animated: YES];
                return;
            }
        }
    } else if ([dic[@"result"] intValue] == 0) {
        NSLog(@"失敗：%@",dic[@"message"]);
        if ([wTools objectExists: dic[@"message"]]) {
            [self showCustomErrorAlert: dic[@"message"]];
        } else {
            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
        }
    } else {
        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
    }
}

-(void)upphoto {
    NSLog(@"upPhoto");
    NSLog(@"imagearr: %@", imagearr);
    
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    
    if (![wTools objectExists: imagearr]) {
        return;
    }
    
    for (int i = 0; i < imagearr.count; i++) {
        NSMutableDictionary *data = imagearr[i];
        NSLog(@"imagearr count: %lu", (unsigned long)imagearr.count);
        
        if (data[@"image"]) {
            NSLog(@"image exists");
            
            O_drag *oview = (O_drag *)[_ShowView viewWithTag: 210 + i];
            NSDictionary *fd = data[@"frame"];
            float ww = [fd[@"W"] floatValue];
            float hh = [fd[@"H"] floatValue];
            
            UIImage *bimag = [oview finishCropping];
            // NSLog(@"00:%ld",(long)bimag.imageOrientation);
            UIGraphicsBeginImageContext(CGSizeMake(ww, hh));
            [[UIColor clearColor] setFill];
            [[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, ww, hh)] fill];
            CGRect frame = oview.imageView.frame;
            
            float x = frame.origin.x;
            float y = frame.origin.y;
            float w = frame.size.width;
            float h = frame.size.height;
            float s = hh / oview.bounds.size.height;
            
            if (x > 0) {
                if (x + w > oview.bounds.size.width) {
                    w = oview.bounds.size.width - x;
                }
            }
            
            if(y > 0){
                
            } if (y + h > oview.bounds.size.height) {
                h = oview.bounds.size.height - y;
            }
            
            if (x < 0) {
                w = w + x;
                x = 0;
            }
            if (y < 0) {
                h = h + y;
                y = 0;
            }
            
            if (w > oview.bounds.size.width) {
                w = oview.bounds.size.width;
            }
            if (h > oview.bounds.size.height) {
                h = oview.bounds.size.height;
            }
            
            [bimag drawInRect:CGRectMake(x*s,y*s, w*s, h*s)];
            // 現在のグラフィックスコンテキストの画像を取得する
            bimag = UIGraphicsGetImageFromCurrentImageContext();
            
            // 現在のグラフィックスコンテキストへの編集を終了
            // (スタックの先頭から削除する)
            UIGraphicsEndImageContext();
            
            // NSLog(@"11:%ld",(long)bimag.imageOrientation);
            
            [data setObject:bimag forKey:@"image"];
            
            //NSLog(@"data: %@", data);
        } else {
            NSLog(@"image does not exist");
        }
    }
    //合成影像
    NSURL *url = [NSURL URLWithString:_templatelist[selectItem][@"image_url"]];
    
    NSLog(@"url: %@", url);
    //使用NSData的方法將影像指定給UIImage
    //基底
    UIImage *bgimag = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:url]];
    
    //UIGraphicsBeginImageContext(bgimag.size);
    UIGraphicsBeginImageContext(_ShowView.frame.size);
    
    NSLog(@"imagearr: %@", imagearr);
    
    for (int i = 0; i < imagearr.count; i++) {
        NSDictionary *data = imagearr[i];
        if (data[@"image"]) {
            NSDictionary *fd = data[@"frame"];
            
            float x = [fd[@"L"] floatValue];
            float y = [fd[@"T"] floatValue];
            float w = [fd[@"W"] floatValue];
            float h = [fd[@"H"] floatValue];
            
            UIImage *image = data[@"image"];
            CGRect f = CGRectMake(x, y, w, h);
            [image drawInRect:f];
        }
    }
    
    //[bgimag drawInRect:CGRectMake(0, 0, bgimag.size.width, bgimag.size.height)];
    [bgimag drawInRect:CGRectMake(0, 0, _ShowView.frame.size.width, _ShowView.frame.size.height)];
    
    NSLog(@"bgimag: %@", bgimag);
    
    // 現在のグラフィックスコンテキストの画像を取得する
//    UIImage *newbgimag = UIGraphicsGetImageFromCurrentImageContext();
    
    // 現在のグラフィックスコンテキストへの編集を終了
    // (スタックの先頭から削除する)
    UIGraphicsEndImageContext();
    
    
    if (![wTools objectExists: _ShowView.subviews]) {
        return;
    }
    
    for (UIButton *btn in _ShowView.subviews) {
        if ([btn isKindOfClass: [UIButton class]]) {
            btn.hidden = YES;
        }
    }
    
    // Convert UIView to UIImage
    UIGraphicsBeginImageContextWithOptions(_ShowView.bounds.size, _ShowView.opaque, 0.0);
    [_ShowView.layer renderInContext: UIGraphicsGetCurrentContext()];
    
    UIImage *newImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    __block typeof(self) wself = self;
    __block typeof(_albumid) aid = _albumid;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = @"";
        response = [boxAPI insertphotoofdiy: [wTools getUserID]
                                      token: [wTools getUserToken]
                                   album_id: aid
                                      image: newImg
                                compression: 0.0];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [wTools HideMBProgressHUD];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog( @"NSException caught" );
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason );
                return;
            }
            if (response != nil) {
                NSLog(@"response from insertphotoofdiy: %@", response);
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"TemplateViewController");
                    NSLog(@"upphoto");
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"insertphotoofdiy"];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    [wself processUploadPhotoResult:dic];
                }
            }
        });
    });
}

-(IBAction)nextbtn:(id)sender{
//    for (UIViewController *vc in [self.navigationController viewControllers] ) {
//        if ([vc isKindOfClass:[FastViewController class]]) {
//            [self.navigationController popToViewController:vc animated:YES];
//            return;
//        }
//    }
//    
//    FastViewController *fvc=[[UIStoryboard storyboardWithName:@"Fast" bundle:nil]instantiateViewControllerWithIdentifier:@"FastViewController"];
//    fvc.selectrow=[wTools userbook];
//    fvc.albumid=_albumid;
//    fvc.booktype=1000;
//    [self.navigationController pushViewController:fvc animated:YES];
}

#pragma mark - Custom AlertView
- (void)showCustomForDeletingImage:(NSString *)msg
                               btn:(UIButton *)sender {
    CustomIOSAlertView *alertViewForDeletingImage = [[CustomIOSAlertView alloc] init];
    //[alertViewForDeletingImage setContainerView: [self createDeletingImageContainerView: msg]];
    [alertViewForDeletingImage setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin"];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertViewForDeletingImage.arrangeStyle = @"Horizontal";
    
    [alertViewForDeletingImage setButtonTitles: [NSMutableArray arrayWithObjects: NSLocalizedString(@"GeneralText-no", @""), NSLocalizedString(@"GeneralText-yes", @""), nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertViewForDeletingImage setButtonColors: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor whiteColor],nil]];
    [alertViewForDeletingImage setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstGrey], nil]];
    [alertViewForDeletingImage setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    //alertView.arrangeStyle = @"Vertical";
    
    __block typeof(_ShowView) sv = _ShowView;
    [alertViewForDeletingImage setOnButtonTouchUpInside:^(CustomIOSAlertView *alertViewForDeletingImage, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertViewForDeletingImage tag]);
        
        [alertViewForDeletingImage close];
        
        if (buttonIndex == 0) {
            
        } else {
            UIView *v=[sv viewWithTag: sender.tag-100];
            CGRect frame = v.frame;
            int tag = (int)sender.tag;
            [v removeFromSuperview];
            [sender removeFromSuperview];
            
            v = [[UIView alloc] initWithFrame: frame];
            v.backgroundColor = [UIColor firstGrey];
            v.tag = sender.tag - 100;
            [sv addSubview:v];
            
            //沒圖片用按鈕
            //icon_creatnewframe_plus.png
            
            UIImageView *addimage = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 30, 30)];
            //addimage.image = [UIImage imageNamed: @"icon_creatnewframe_plus.png"];
            addimage.image = [UIImage imageNamed: @"camera.png"];
            addimage.center = CGPointMake(v.frame.size.width / 2, v.frame.size.height / 2);
            [v addSubview: addimage];
            
            //按鈕
            UIButton *btn = [UIButton buttonWithType: UIButtonTypeCustom];
            btn.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
            btn.tag = tag - 310;
            [btn addTarget: self action: @selector(addimage:) forControlEvents: UIControlEventTouchUpInside];
            [v addSubview: btn];
            
            UIView *asyncv = [sv viewWithTag: 200];
            [sv bringSubviewToFront: asyncv];
        }
    }];
    [alertViewForDeletingImage setUseMotionEffects: YES];
    [alertViewForDeletingImage show];
}

- (UIView *)createDeletingImageContainerView:(NSString *)msg {
    // TextView Setting
    UITextView *textView = [[UITextView alloc] initWithFrame: CGRectMake(10, 30, 280, 20)];
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
    [imageView setImage:[UIImage imageNamed:@"icon_2_0_0_dialog_pinpin.png"]];
    
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
    //contentView.backgroundColor = [UIColor firstPink];
    contentView.backgroundColor = [UIColor firstMain];
    
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

- (void)showCustomForChangeTemplate:(NSString *)msg
                       indexPathRow:(NSInteger)indexPathRow {
    CustomIOSAlertView *alertViewForTemplate = [[CustomIOSAlertView alloc] init];
    //[alertViewForTemplate setContainerView: [self createTemplateContainerView: msg]];
    [alertViewForTemplate setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin"];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertViewForTemplate.arrangeStyle = @"Horizontal";
    
    [alertViewForTemplate setButtonTitles: [NSMutableArray arrayWithObjects: @"取消", @"確定", nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertViewForTemplate setButtonColors: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor whiteColor],nil]];
    [alertViewForTemplate setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstGrey], nil]];
    [alertViewForTemplate setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    //alertView.arrangeStyle = @"Vertical";
    __block typeof(self) wself = self;
    [alertViewForTemplate setOnButtonTouchUpInside:^(CustomIOSAlertView *alertViewForTemplate, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertViewForTemplate tag]);
        
        [alertViewForTemplate close];
        
        if (buttonIndex == 0) {
            
        } else {
            [wself processChangeTemplate:indexPathRow];
        }
    }];
    [alertViewForTemplate setUseMotionEffects: YES];
    [alertViewForTemplate show];
}

- (void)processChangeTemplate:(NSInteger)indexPathRow {
    selectItem = indexPathRow;
    imagearr = [NSMutableArray new];
    
    NSDictionary *data = _templatelist[selectItem];
    NSArray *frame = data[@"blank"];
    
    if (![wTools objectExists: frame]) {
        return;
    }
    
    for (int i = 0; i < frame.count; i++) {
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject: frame[i] forKey: @"frame"];
        [imagearr addObject: dic];
    }
    [self showimageview];
    [self.dataCollectionView reloadData];
    
}

- (UIView *)createTemplateContainerView: (NSString *)msg {
    // TextView Setting
    UITextView *textView = [[UITextView alloc] initWithFrame: CGRectMake(10, 30, 280, 20)];
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
    [imageView setImage:[UIImage imageNamed:@"icon_2_0_0_dialog_pinpin.png"]];
    
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
    //contentView.backgroundColor = [UIColor firstPink];
    contentView.backgroundColor = [UIColor firstMain];
    
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

- (void)showCustomAlertForEffect:(NSString *)msg
                        ImageArr:(NSArray *)Images {
    CustomIOSAlertView *alertViewForEffect = [[CustomIOSAlertView alloc] init];
    [alertViewForEffect setContainerView: [self createEffectContainerView: msg]];
    
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertViewForEffect.arrangeStyle = @"Horizontal";
    
    [alertViewForEffect setButtonTitles: [NSMutableArray arrayWithObjects: @"不需要", @"特效", nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertViewForEffect setButtonColors: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor firstMain],nil]];
    [alertViewForEffect setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor whiteColor], nil]];
    [alertViewForEffect setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    //alertView.arrangeStyle = @"Vertical";
    
    [alertViewForEffect setOnButtonTouchUpInside:^(CustomIOSAlertView *alertViewForEffect, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertViewForEffect tag]);
        
        [alertViewForEffect close];
        
        if (buttonIndex == 0) {
            [self addimagetoitem:Images[0]];
        } else {
            [self displayEditorForImahe:Images[0]];
        }
    }];
    [alertViewForEffect setUseMotionEffects: YES];
    [alertViewForEffect show];
}

- (UIView *)createEffectContainerView: (NSString *)msg {
    // TextView Setting
    UITextView *textView = [[UITextView alloc] initWithFrame: CGRectMake(10, 30, 280, 20)];
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
    [imageView setImage:[UIImage imageNamed:@"icon_2_0_0_dialog_pinpin.png"]];
    
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
    //contentView.backgroundColor = [UIColor firstPink];
    contentView.backgroundColor = [UIColor firstMain];
    
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

#pragma mark - Custom Error Alert Method
- (void)showCustomErrorAlert: (NSString *)msg {
    [UIViewController showCustomErrorAlertWithMessage:msg onButtonTouchUpBlock:^(CustomIOSAlertView *customAlertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[customAlertView tag]);
        [customAlertView close];
    }];
}

#pragma mark - Custom Method for TimeOut
- (void)showCustomTimeOutAlert: (NSString *)msg
                  protocolName: (NSString *)protocolName {
    CustomIOSAlertView *alertTimeOutView = [[CustomIOSAlertView alloc] init];
    //[alertTimeOutView setContainerView: [self createTimeOutContainerView: msg]];
    [alertTimeOutView setContentViewWithMsg:msg contentBackgroundColor:[UIColor darkMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertTimeOutView.arrangeStyle = @"Horizontal";
    
    alertTimeOutView.parentView = self.view;
    [alertTimeOutView setButtonTitles: [NSMutableArray arrayWithObjects: NSLocalizedString(@"TimeOut-CancelBtnTitle", @""), NSLocalizedString(@"TimeOut-OKBtnTitle", @""), nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertTimeOutView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor clearColor], [UIColor clearColor],nil]];
    [alertTimeOutView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstGrey], nil]];
    [alertTimeOutView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    //alertView.arrangeStyle = @"Vertical";
    
    __weak typeof(self) weakSelf = self;
    __weak CustomIOSAlertView *weakAlertTimeOutView = alertTimeOutView;
    [alertTimeOutView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertTimeOutView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertTimeOutView tag]);
        [weakAlertTimeOutView close];
        
        if (buttonIndex == 0) {
            
        } else {
            if ([protocolName isEqualToString: @"getalbumofdiy"]) {
                [weakSelf getAlbumOfDiy];
            } else if ([protocolName isEqualToString: @"getcooperation"]) {
                [weakSelf getCooperation];
            } else if ([protocolName isEqualToString: @"insertphotoofdiy"]) {
                [weakSelf upphoto];
            }
        }
    }];
    [alertTimeOutView setUseMotionEffects: YES];
    [alertTimeOutView show];
}

- (UIView *)createTimeOutContainerView:(NSString *)msg {
    // TextView Setting
    UITextView *textView = [[UITextView alloc] initWithFrame: CGRectMake(10, 30, 280, 20)];
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
    [imageView setImage:[UIImage imageNamed:@"icon_2_0_0_dialog_pinpin.png"]];
    
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
    //contentView.backgroundColor = [UIColor firstPink];
    contentView.backgroundColor = [UIColor firstMain];
    
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
