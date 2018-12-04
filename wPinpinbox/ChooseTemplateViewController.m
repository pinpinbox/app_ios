//
//  ChooseTemplateViewController.m
//  wPinpinbox
//
//  Created by David Lee on 2017/9/27.
//  Copyright © 2017年 Angus. All rights reserved.
//

#import "ChooseTemplateViewController.h"
#import "UIColor+Extensions.h"
#import "boxAPI.h"
#import "wTools.h"
#import "AsyncImageView.h"
#import "CustomIOSAlertView.h"
#import "OldCustomAlertView.h"
#import "AlbumCreationViewController.h"
#import <SafariServices/SafariServices.h>
#import "GlobalVars.h"
#import "AppDelegate.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "LabelAttributeStyle.h"
#import "UIViewController+ErrorAlert.h"

@interface ChooseTemplateViewController () <SFSafariViewControllerDelegate>
{
    BOOL isLoading;
    NSMutableArray *pictures;
    NSInteger nextId;
    
    BOOL own;
    NSUInteger pointValue;
    NSString *templateId;
    
    // For Showing Message of Getting Point
    NSString *missionTopicStr;
    NSString *rewardType;
    NSString *rewardValue;
    NSString *eventUrl;
    NSString *restriction;
    NSString *restrictionValue;
    NSUInteger numberOfCompleted;
    
    OldCustomAlertView *alertView;
}
@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarHeight;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation ChooseTemplateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initialValueSetup];
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialValueSetup {
    NSLog(@"initialValueSetup");
    self.navBarView.backgroundColor = [UIColor barColor];
    self.titleLabel.textColor = [UIColor firstGrey];
    [LabelAttributeStyle changeGapString: self.titleLabel content: self.titleLabel.text];
    pictures = [NSMutableArray new];
    self.collectionView.contentInset = UIEdgeInsetsMake(72, 0, 0, 0);
}

- (void)viewDidLayoutSubviews {
    NSLog(@"viewDidLayoutSubviews");
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 1136:
                printf("iPhone 5 or 5S or 5C");
                break;
            case 1334:
                printf("iPhone 6/6S/7/8");
                break;
            case 1920:
                printf("iPhone 6+/6S+/7+/8+");
                break;
            case 2208:
                printf("iPhone 6+/6S+/7+/8+");
                break;
            case 2436:
                printf("iPhone X");
                self.navBarHeight.constant = navBarHeightConstant;
                break;
            default:
                printf("unknown");
                break;
        }
    }
}

- (IBAction)backBtnPress:(id)sender {
    //[self.navigationController popViewControllerAnimated: YES];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav popViewControllerAnimated: YES];
}

- (void)loadData {
    NSLog(@"loadData");
    if (!isLoading) {
        if (pictures.count == 0) {
            
        }
        isLoading = YES;
        [self getTemplateList];
    }
}

- (void)processTemplateListResult:(NSDictionary *)dic {
    if ([dic[@"result"] intValue] == 1) {
        if (![wTools objectExists: dic[@"data"]]) {
            return;
        }
        int s = 0;

        for (NSMutableDictionary *picture in [dic objectForKey: @"data"]) {
            s++;
            [pictures addObject: picture];
        }
        nextId = nextId + s;
        
        if (nextId >= 0)
            isLoading = NO;
        
        if (s == 0)
            isLoading = YES;
        
        NSLog(@"pictures: %@", pictures);
        [self.collectionView reloadData];
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

- (void)getTemplateList {
    NSLog(@"getTemplateList");
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
    NSString *limit = [NSString stringWithFormat: @"%ld, %d", (long)nextId, 10];
    [data setObject: self.rank forKey: @"rank"];
    [data setValue: limit forKey: @"limit"];
    __block typeof (self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *response = [boxAPI gettemplatelist: [wTools getUserID]
                                               token: [wTools getUserToken]
                                                data: data
                                               event: wself.event_id
                                               style: wself.style_id];
        
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
                NSLog(@"response from gettemplatelist");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ChooseTemplateViewController");
                    NSLog(@"getTemplateList");
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getTemplateList"
                                         albumId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    [wself processTemplateListResult:dic];
                }
            }
        });
    });
}

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return pictures.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForItemAtIndexPath");
    static NSString *identifier = @"Cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: identifier forIndexPath: indexPath];
    NSDictionary *data = pictures[indexPath.row];
    UIView *bgView = (UIView *)[cell viewWithTag: 50];
    bgView.layer.cornerRadius = kCornerRadius;
    
    //AsyncImageView *img = (AsyncImageView *)[cell viewWithTag: 100];
    UIImageView *img = (UIImageView *)[cell viewWithTag: 100];
    img.imageURL = nil;
    img.image = nil;
    img.contentMode = UIViewContentModeScaleAspectFit;
    
    if ([data[@"template"][@"image"] isKindOfClass: [NSNull class]]) {
        img.image = [UIImage imageNamed: @"bg200_no_image.jpg"];
    } else {
        [img sd_setImageWithURL: [NSURL URLWithString: data[@"template"][@"image"]]];
    }
    UILabel *label = (UILabel *)[cell viewWithTag: 200];
    if ([wTools objectExists: data[@"template"][@"name"]]) {
        label.text = data[@"template"][@"name"];
        [LabelAttributeStyle changeGapString: label content: data[@"template"][@"name"]];
    }
    label.textColor = [UIColor firstGrey];
    label.font = [UIFont systemFontOfSize: 12];
    label.numberOfLines = 2;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate Methods
- (BOOL)collectionView:(UICollectionView *)collectionView
shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath: indexPath];
    cell.contentView.subviews[0].backgroundColor = [UIColor thirdMain];
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView
didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath: indexPath];
    cell.contentView.subviews[0].backgroundColor = nil;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectItemAtIndexPath");
    NSDictionary *data = pictures[indexPath.row];
    NSLog(@"template own: %d", [data[@"template"][@"own"] boolValue]);
    NSLog(@"template point: %d", [data[@"template"][@"point"] intValue]);
    
    own = [data[@"template"][@"own"] boolValue];
    pointValue = [data[@"template"][@"point"] intValue];
    templateId = data[@"template"][@"template_id"];
    
    [self buy];
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods
// Horizontal Cell Spacing
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    NSLog(@"minimumInteritemSpacingForSectionAtIndex");
    return 0;
}

// Vertical Cell Spacing
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    NSLog(@"minimumLineSpacingForSectionAtIndex");
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    UIEdgeInsets itemInset = UIEdgeInsetsMake(0, 6, 0, 6);
    return itemInset;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (isLoading) {
        return;
    }
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"willDisplayCell");
    if (indexPath.item == (pictures.count - 1)) {
        [self loadData];
    }
}

#pragma mark - Buy
- (void)buy {
    NSLog(@"buy");
    if (own) {
        [self editTaoban];
    } else {
        if (pointValue == 0) {
            [self buyapi];
            return;
        }
        [self getPoint];
    }
}

- (void)getPoint {
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *response = [boxAPI geturpoints: [wTools getUserID]
                                           token: [wTools getUserToken]];
        
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
                    NSLog(@"ChooseTemplateViewController");
                    NSLog(@"getPoint");
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getPoint"
                                         albumId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if (wself->pointValue > [dic[@"data"] intValue]) {
                        NSString *errorMsg = @"P點不足，無法取得套版";
                        [wself showCustomErrorAlert: errorMsg];
                    } else {
                        [wself showCustomCheckTaobanAlert: @"確定取得套版?"];
                    }
                }
            }
        });
    });
}

-(void)buyapi {
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    __block typeof(self) wself = self;
    __block typeof(templateId) tid = templateId;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI buytemplate: [wTools getUserID]
                                           token: [wTools getUserToken]
                                      templateid: tid];
        
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
                    NSLog(@"ChooseTemplateViewController");
                    NSLog(@"buyapi");
                    
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"buytemplate"
                                         albumId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        //開始製作
                        [wself editTaoban];
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗：%@",dic[@"message"]);
                        if ([wTools objectExists: dic[@"message"]]) {
                            [wself showCustomErrorAlert: dic[@"message"]];
                        } else {
                            [wself showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                        }
                    } else {
                        [wself showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            }
        });
    });
}

//進入編輯
-(void)editTaoban {
    //判斷是否有編輯中相本
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI checkalbumofdiy: [wTools getUserID]
                                               token: [wTools getUserToken]];
        
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
                NSLog(@"response from checkalbumofdiy");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ChooseTemplateViewController");
                    NSLog(@"editTaoban");
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"checkalbumofdiy"
                                         albumId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if (dic != nil) {
                        if ([dic[@"result"] intValue] == 1) {
                            [self updateAlbumOfDiy: [dic[@"data"][@"album"][@"album_id"] stringValue]];
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
                    } else {
                        NSLog(@"dic == nil");
                        [self addNewTaobanMod];
                    }
                }
            }
        });
    });
}

- (void)updateAlbumOfDiy:(NSString *)albumId {
    NSLog(@"");
    NSLog(@"updateAlbumOfDiy: albumId: %@", albumId);
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *response = [boxAPI updatealbumofdiy: [wTools getUserID]
                                                token: [wTools getUserToken]
                                             album_id: albumId];
        
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
                NSLog(@"response from checkalbumofdiy");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ChooseTemplateViewController");
                    NSLog(@"updateAlbumOfDiy albumId");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"updatealbumofdiy"
                                         albumId: albumId];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        NSLog(@"dic result boolValue is 1");
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
            }
        });
    });
}

//套版
-(void)addNewTaobanMod {
    NSLog(@"addNewTaobanMod");
    //新增相本id
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    __block typeof(self) wself = self;
    __block typeof(templateId) tid = templateId;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI insertalbumofdiy: [wTools getUserID]
                                                token: [wTools getUserToken]
                                          template_id: tid];
        
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
                NSLog(@"response from insertalbumofdiy");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ChooseTemplateViewController");
                    NSLog(@"addNewTaobanMod");
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"insertalbumofdiy"
                                         albumId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([dic[@"result"]boolValue]) {
                        NSString *tempAlbumId = [dic[@"data"] stringValue];
                        
                        if (![wTools objectExists: tempAlbumId]) {
                            return;
                        }
                        
                        AlbumCreationViewController *albumCreationVC = [[UIStoryboard storyboardWithName: @"AlbumCreationVC" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumCreationViewController"];
                        albumCreationVC.albumid = tempAlbumId;
                        albumCreationVC.templateid = tid;
                        albumCreationVC.event_id = wself.event_id;
                        albumCreationVC.postMode = wself.postMode;
                        albumCreationVC.choice = @"Template";
                        albumCreationVC.isNew = YES;
                        //[self.navigationController pushViewController: albumCreationVC animated: YES];
                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        [appDelegate.myNav pushViewController: albumCreationVC animated: YES];
                        
                        // Check whether getting Download Template point or not
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        BOOL firsttime_download_template = [[defaults objectForKey: @"firsttime_download_template"] boolValue];
                        NSLog(@"Check whether getting Download Template point or not");
                        NSLog(@"firsttime_download_template: %d", (int)firsttime_download_template);
                        
                        if (firsttime_download_template) {
                            NSLog(@"Get the First Time Download Template Point Already");
                        } else {
                            [wself checkPoint];
                        }
                        // Save data for first edit profile
                        firsttime_download_template = YES;
                        [defaults setObject: [NSNumber numberWithBool: firsttime_download_template]
                                     forKey: @"firsttime_download_template"];
                        [defaults synchronize];
                    } else {
                        NSLog(@"失敗： %@", dic[@"message"]);
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

#pragma mark - Check Point Method
- (void)checkPoint {
    NSLog(@"checkPoint");
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    __block typeof(self) wself = self;
    __block typeof(templateId) tid = templateId;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI doTask2: [wTools getUserID] token: [wTools getUserToken] task_for: @"firsttime_download_template" platform: @"apple" type: @"template" type_id: tid];
        NSLog(@"User ID: %@", [wTools getUserID]);
        NSLog(@"Token: %@", [wTools getUserToken]);
        NSLog(@"Template ID: %@", tid);
        
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
                NSLog(@"response from doTask2");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ChooseTemplateViewController");
                    NSLog(@"checkPoint");
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"doTask2"
                                         albumId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    [wself processCheckPointResult:data];
                }
            }
        });
    });
}

- (void)processCheckPointResult:(NSDictionary *)data {
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
        [self getUrPoints];
    } else if ([data[@"result"] intValue] == 2) {
        NSLog(@"message: %@", data[@"message"]);
        // Save setting for login successfully
        BOOL firsttime_download_template = YES;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject: [NSNumber numberWithBool: firsttime_download_template] forKey: @"firsttime_download_template"];
        [defaults synchronize];
    } else if ([data[@"result"] intValue] == 0) {
        NSLog(@"失敗： %@", data[@"message"]);
    } else {
        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
    }
}

#pragma mark - Get P Point
- (void)getUrPoints {
    NSLog(@"");
    NSLog(@"getUrPoints");
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *response = [boxAPI geturpoints: [userPrefs objectForKey:@"id"]
                                           token: [userPrefs objectForKey:@"token"]];
        
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
                NSLog(@"response from geturpoints");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ChooseTemplateViewController");
                    NSLog(@"getUrPoints");
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"geturpoints"
                                         albumId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        NSLog(@"dic result boolValue is 1");
                        NSInteger point = [dic[@"data"] integerValue];
                        [userPrefs setObject: [NSNumber numberWithInteger: point] forKey: @"pPoint"];
                        [userPrefs synchronize];
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
            }
        });
    });
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Custom Alert Method
#pragma mark - Custom AlertView for Getting Point
- (void)showAlertView {
    NSLog(@"Show Alert View");
    // Custom AlertView shows up when getting the point
    alertView = [[OldCustomAlertView alloc] init];
    [alertView setContainerView: [self createPointView]];
    [alertView setButtonTitles: [NSMutableArray arrayWithObject: @"確     認"]];
    [alertView setUseMotionEffects: true];
    [alertView show];
}

- (UIView *)createPointView {
    NSLog(@"createPointView");
    UIView *pointView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 250, 250)];
    
    // Mission Topic Label
    UILabel *missionTopicLabel = [[UILabel alloc] initWithFrame: CGRectMake(10, 15, 200, 10)];
    //missionTopicLabel.text = @"收藏相本得點";
    missionTopicLabel.text = missionTopicStr;
    [LabelAttributeStyle changeGapString: missionTopicLabel content: missionTopicStr];
    
    NSLog(@"Topic Label Text: %@", missionTopicStr);
    [pointView addSubview: missionTopicLabel];
    
    if ([restriction isEqualToString: @"personal"]) {
        UILabel *restrictionLabel = [[UILabel alloc] initWithFrame: CGRectMake(10, 45, 200, 10)];
        restrictionLabel.textColor = [UIColor firstGrey];
        restrictionLabel.text = [NSString stringWithFormat: @"次數：%lu / %@", (unsigned long)numberOfCompleted, restrictionValue];
        [LabelAttributeStyle changeGapString: restrictionLabel content: [NSString stringWithFormat: @"次數：%lu / %@", (unsigned long)numberOfCompleted, restrictionValue]];
        NSLog(@"restrictionLabel.text: %@", restrictionLabel.text);
        [pointView addSubview: restrictionLabel];
    }
    
    // Gift Image
    UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(50, 90, 100, 100)];
    imageView.image = [UIImage imageNamed: @"icon_present"];
    [pointView addSubview: imageView];
    
    // Message Label
    UILabel *messageLabel = [[UILabel alloc] initWithFrame: CGRectMake(10, 200, 200, 10)];
    
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
    [LabelAttributeStyle changeGapString: messageLabel content: [NSString stringWithFormat: @"%@%@%@", congratulate, rewardValue, end]];
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

- (void)showTheActivityPage {
    NSLog(@"showTheActivityPage");
    //NSString *activityLink = @"http://www.apple.com";
    NSString *activityLink = eventUrl;
    NSURL *url = [NSURL URLWithString: activityLink];
    // Close for present safari view controller, otherwise alertView will hide the background
    [alertView close];
    
    SFSafariViewController *safariVC1 = [[SFSafariViewController alloc] initWithURL: url entersReaderIfAvailable: NO];
    safariVC1.delegate = self;
    safariVC1.preferredBarTintColor = [UIColor whiteColor];
    [self presentViewController: safariVC1 animated: YES completion: nil];
}

#pragma mark - SFSafariViewController delegate methods
- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    // Done button pressed
    NSLog(@"show");
    [alertView show];
}

- (void)showCustomCheckTaobanAlert: (NSString *)msg {
    CustomIOSAlertView *alertViewForTaoban = [[CustomIOSAlertView alloc] init];
    [alertViewForTaoban setContainerView: [self createContainerView: msg]];
    
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertViewForTaoban.arrangeStyle = @"Horizontal";
    
    [alertViewForTaoban setButtonTitles: [NSMutableArray arrayWithObjects: @"取消", @"確定", nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertViewForTaoban setButtonColors: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor firstMain],nil]];
    [alertViewForTaoban setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor whiteColor], nil]];
    [alertViewForTaoban setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    //alertView.arrangeStyle = @"Vertical";
    
    __weak CustomIOSAlertView *weakAlertViewForTaoban = alertViewForTaoban;
    [alertViewForTaoban setOnButtonTouchUpInside:^(CustomIOSAlertView *alertViewForTaoban, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertViewForTaoban tag]);
        [weakAlertViewForTaoban close];
        
        if (buttonIndex == 0) {
        } else {
            [self buyapi];
        }
    }];
    [alertViewForTaoban setUseMotionEffects: YES];
    [alertViewForTaoban show];
}

- (UIView *)createContainerView: (NSString *)msg {
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

- (void)showCustomErrorAlert: (NSString *)msg {
    NSLog(@"");
    NSLog(@"showCustomAlert msg: %@", msg);
    [UIViewController showCustomErrorAlertWithMessage:msg onButtonTouchUpBlock:^(CustomIOSAlertView *customAlertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[customAlertView tag]);
        [customAlertView close];
    }];
}

#pragma mark - Custom Method for TimeOut
- (void)showCustomTimeOutAlert: (NSString *)msg
                  protocolName: (NSString *)protocolName
                       albumId: (NSString *)albumId
{
    CustomIOSAlertView *alertTimeOutView = [[CustomIOSAlertView alloc] init];
    alertTimeOutView.parentView = self.view;
    //[alertTimeOutView setContainerView: [self createTimeOutContainerView: msg]];
    [alertTimeOutView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
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
            if ([protocolName isEqualToString: @"gettemplatelist"]) {
                [weakSelf getTemplateList];
            } else if ([protocolName isEqualToString: @"getPoint"]) {
                [weakSelf getPoint];
            } else if ([protocolName isEqualToString: @"buytemplate"]) {
                [weakSelf buyapi];
            } else if ([protocolName isEqualToString: @"updatealbumofdiy"]) {
                [weakSelf updateAlbumOfDiy: albumId];
            } else if ([protocolName isEqualToString: @"checkalbumofdiy"]) {
                [weakSelf editTaoban];
            } else if ([protocolName isEqualToString: @"insertalbumofdiy"]) {
                [weakSelf addNewTaobanMod];
            } else if ([protocolName isEqualToString: @"doTask2"]) {
                [weakSelf checkPoint];
            } else if ([protocolName isEqualToString: @"geturpoints"]) {
                [weakSelf getUrPoints];
            }
        }
    }];
    [alertTimeOutView setUseMotionEffects: YES];
    [alertTimeOutView show];
}

- (UIView *)createTimeOutContainerView: (NSString *)msg {
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
