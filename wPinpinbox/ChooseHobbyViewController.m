//
//  ChooseHobbyViewController.m
//  wPinpinbox
//
//  Created by David on 5/15/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "ChooseHobbyViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "boxAPI.h"
#import "wTools.h"
#import "AsyncImageView.h"
#import "UIColor+Extensions.h"

#import "UIView+Toast.h"

#import "ChooseHobbyCollectionViewCell.h"
#import "MyTabBarController.h"
#import "AppDelegate.h"

#import "CustomIOSAlertView.h"

#import "GlobalVars.h"
#import "UIViewController+ErrorAlert.h"
#import "LabelAttributeStyle.h"
#import "ChooseHobbyCollectionReusableView.h"

@interface ChooseHobbyViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
{
    NSMutableArray *hobbyArray;
    NSMutableArray *checkSelectedArray;
    NSMutableArray *selectArray;
    
    NSInteger columnCount;
    NSInteger miniInteriorSpacing;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *startUsingPinpinboxBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startUsingPinpinboxBtnHeight;
@property (weak, nonatomic) IBOutlet UIView *startUsingPinpinboxView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolBarViewHeight;
@end

@implementation ChooseHobbyViewController

#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: self.startUsingPinpinboxBtn.titleLabel content: self.startUsingPinpinboxBtn.titleLabel.text];
    columnCount = 3;
    miniInteriorSpacing = 16;
    
    checkSelectedArray = [NSMutableArray new];
    selectArray = [NSMutableArray new];
    
    self.startUsingPinpinboxBtn.layer.cornerRadius = 16;
    self.startUsingPinpinboxView.hidden = YES;
    self.startUsingPinpinboxView.backgroundColor = [UIColor colorWithRed: 255.0/255.0
                                                                   green: 255.0/255.0
                                                                    blue: 255.0/255.0
                                                                   alpha: 0.96];
    [self getHobbyList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 1136:
                printf("iPhone 5 or 5S or 5C");
                self.toolBarViewHeight.constant = kToolBarViewHeight;
                break;
            case 1334:
                printf("iPhone 6/6S/7/8");
                self.toolBarViewHeight.constant = kToolBarViewHeight;
                break;
            case 1920:
                printf("iPhone 6+/6S+/7+/8+");
                self.toolBarViewHeight.constant = kToolBarViewHeight;
                break;
            case 2208:
                printf("iPhone 6+/6S+/7+/8+");
                self.toolBarViewHeight.constant = kToolBarViewHeight;
                break;
            case 2436:
                printf("iPhone X");
                self.toolBarViewHeight.constant = kToolBarViewHeightForX;
                break;
            default:
                printf("unknown");
                self.toolBarViewHeight.constant = kToolBarViewHeight;
                break;
        }
    }
    self.startUsingPinpinboxBtnHeight.constant = kToolBarButtonHeight;
}

- (void)processHobbyListResult:(NSDictionary *)data {
    if ([data[@"result"] intValue] == 1) {
        NSLog(@"getHobbyList Success");
        hobbyArray = data[@"data"];
        NSInteger hobbyId;
        
        if ([wTools objectExists: hobbyArray]) {
            for (int i = 0; i < hobbyArray.count; i++) {
                NSMutableDictionary *dic = [NSMutableDictionary new];
                
                hobbyId = [hobbyArray[i][@"hobby"][@"hobby_id"] integerValue];
                [dic setValue: [NSNumber numberWithBool: NO] forKey: @"selected"];
                [dic setValue: [NSNumber numberWithInteger: hobbyId] forKey: @"hobbyId"];
                [checkSelectedArray addObject: dic];
            }
            NSLog(@"checkSelectedArray: %@", checkSelectedArray);
            NSLog(@"hobbyArray: %@", hobbyArray);
            
            [self.collectionView reloadData];
        }
    } else if ([data[@"result"] intValue] == 0) {
        NSLog(@"失敗： %@", data[@"message"]);
        if ([wTools objectExists: data[@"message"]]) {
            [self showCustomErrorAlert: data[@"message"]];
        } else {
            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
        }
    } else {
        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
    }
}

- (void)getHobbyList {
    @try {
        [DGHUDView start];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI getHobbyList: [wTools getUserID] token: [wTools getUserToken]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [DGHUDView stop];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog( @"NSException caught" );
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason );
                return;
            }
                        
            if (response != nil) {
                NSLog(@"get response from getHobbyList");
                NSLog(@"response: %@", response);
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ChooseHobbyViewController");
                    NSLog(@"getHobbyList");
                    
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getHobbyList"];
                } else {
                    NSLog(@"Get Real Response");
                    
                    NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableLeaves error: nil];
                    
                    [wself processHobbyListResult:data];
                    
                }
            }
        });
    });
}

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return hobbyArray.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"viewForSupplementaryElementOfKind");
    ChooseHobbyCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind: kind withReuseIdentifier: @"headerId" forIndexPath: indexPath];
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: headerView.titleLabel content: headerView.titleLabel.text];
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: headerView.subTitleLabel content: headerView.subTitleLabel.text];
    return headerView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ChooseHobbyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"hobbyCell" forIndexPath: indexPath];
    NSString *imgUrlStr = hobbyArray[indexPath.row][@"hobby"][@"image_url"];
    NSLog(@"hobby image_url: %@", hobbyArray[indexPath.row][@"hobby"][@"image_url"]);
    
    if ([wTools objectExists: imgUrlStr]) {
        cell.hobbyImageView.imageURL = [NSURL URLWithString: imgUrlStr];
    }
    if ([wTools objectExists: hobbyArray[indexPath.row][@"hobby"][@"name"]]) {
        cell.hobbyLabel.text = hobbyArray[indexPath.row][@"hobby"][@"name"];
        [LabelAttributeStyle changeGapStringAndLineSpacingCenterAlignment: cell.hobbyLabel content: cell.hobbyLabel.text];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate Methods
- (void)collectionView:(UICollectionView *)collectionView
didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath: indexPath];
    NSLog(@"cell.contentView.subviews: %@", cell.contentView.subviews);
    NSLog(@"checkSelectedArray: %@", checkSelectedArray[indexPath.row]);
    BOOL isSelected = NO;
    
    if ([wTools objectExists: checkSelectedArray[indexPath.row][@"selected"]]) {
        isSelected = [checkSelectedArray[indexPath.row][@"selected"] boolValue];
    }
    NSLog(@"isSelected: %d", isSelected);
    NSLog(@"selectArray.count: %lu", (unsigned long)selectArray.count);
    
    NSInteger hobbyIdInt = 0;
    
    if ([wTools objectExists: checkSelectedArray[indexPath.row][@"hobbyId"]]) {
        hobbyIdInt = [checkSelectedArray[indexPath.row][@"hobbyId"] integerValue];
    }
    if ([selectArray containsObject: [NSNumber numberWithInteger: hobbyIdInt]]) {
        [selectArray removeObject: [NSNumber numberWithInteger: hobbyIdInt]];
        cell.contentView.subviews[0].backgroundColor = nil;
        
        if (selectArray.count == 0) {
            self.startUsingPinpinboxView.hidden = YES;
        } else {
            self.startUsingPinpinboxView.hidden = NO;
        }
    } else {
        if (selectArray.count > 2) {
            CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
            style.messageColor = [UIColor whiteColor];
            style.backgroundColor = [UIColor thirdPink];
            
            [self.view makeToast: @"最多三項"
                        duration: 2.0
                        position: CSToastPositionBottom
                           style: style];
            return;
        }
        [selectArray addObject: [NSNumber numberWithInteger: hobbyIdInt]];
        cell.contentView.subviews[0].backgroundColor = [UIColor thirdMain];
        
        if (selectArray.count == 0) {
            self.startUsingPinpinboxView.hidden = YES;
        } else {
            self.startUsingPinpinboxView.hidden = NO;
        }
    }
    NSLog(@"");
    NSLog(@"selectArray: %@", selectArray);
    NSLog(@"selectArray.count: %lu", (unsigned long)selectArray.count);
    
    NSMutableDictionary *dic = checkSelectedArray[indexPath.row];
    [dic setValue: [NSNumber numberWithBool: isSelected] forKey: @"selected"];        
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"");
    NSLog(@"sizeForItemAtIndexPath");
    CGFloat itemWidth = roundf((self.view.frame.size.width - (miniInteriorSpacing * (columnCount + 1))) / columnCount);
    return CGSizeMake(itemWidth, 100);
}

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
    return 8;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    UIEdgeInsets itemInset = UIEdgeInsetsMake(0, 8, 0, 8);
    return itemInset;
}

#pragma mark - IBAction
- (IBAction)DownBtn:(id)sender {
    NSLog(@"DownBtn");
    NSString *selectTag = @"";
    
    if (selectArray.count == 0) {
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor thirdPink];
        
        [self.view makeToast: @"請選擇至少一項"
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
        return;
    }
    for (id object in selectArray) {
        NSLog(@"object: %@", object);
        selectTag = [NSString stringWithFormat: @"%@,%@", selectTag, object];
    }
    NSLog(@"selectTag: %@", selectTag);
    
    @try {
        [DGHUDView start];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
        NSString *token = [userPrefs objectForKey: @"token"];
        NSString *uid = [wTools getUserID];
        //BOOL respone = [boxAPI updateprofilehobby: token usid: uid hobby: selectTag];
        NSString *response = [boxAPI updateprofilehobby: token usid: uid hobby: selectTag];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [DGHUDView stop];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog( @"NSException caught" );
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason );
                return;
            }
            
            if (response != nil) {
                NSLog(@"response from updateprofilehobby");
                NSLog(@"response: %@", response);
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ChooseHobbyViewController");
                    NSLog(@"DownBtn");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"updateprofilehobby"];
                } else {
                    NSLog(@"Get Real Response");
                    
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    if ([dic[@"result"] intValue] == 1) {
                        NSLog(@"dic result boolValue is 1");
                        [self getProfile];
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗： %@", dic[@"message"]);
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

#pragma mark - Web Service - GetProfile
- (void)getProfile {
    NSLog(@"");
    NSLog(@"");
    NSLog(@"getProfile");
    
    @try {
        [DGHUDView start];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSLog(@"userPrefs id: %@", [userPrefs objectForKey: @"id"]);
        NSString *response = [boxAPI getprofile: [userPrefs objectForKey: @"id"] token: [userPrefs objectForKey: @"token"]];
        //NSString *testSign = [boxAPI testsign];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [DGHUDView stop];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog( @"NSException caught" );
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason );
                return;
            }
            
            if (response != nil) {
                NSLog(@"Getting response from getprofile");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ChooseHobbyViewController");
                    NSLog(@"getProfile");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getprofile"];
                } else {
                    NSLog(@"Get Real Response");
                    
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
                        NSMutableDictionary *dataIc = [[NSMutableDictionary alloc] initWithDictionary: dic[@"data"] copyItems: YES];
                        
                        if ([wTools objectExists: dataIc]) {
                            for (NSString *key in [dataIc allKeys]) {
                                id objective = [dataIc objectForKey: key];
                                
                                if ([objective isKindOfClass: [NSNull class]]) {
                                    [dataIc setObject: @"" forKey: key];
                                }
                            }
                            NSLog(@"dataIc: %@", dataIc);
                            
                            [userPrefs setValue: dataIc forKey: @"profile"];
                            [userPrefs synchronize];
                        }
                        [self getUrPoints];
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗： %@", dic[@"message"]);
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

#pragma mark - Get P Point
- (void)getUrPoints {
    NSLog(@"");
    NSLog(@"getUrPoints");
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    
    @try {
        [DGHUDView start];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
        
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI geturpoints: [userPrefs objectForKey:@"id"]
                                           token: [userPrefs objectForKey:@"token"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [DGHUDView stop];
            
            if (response != nil) {
                NSLog(@"response from geturpoints");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ChooseHobbyViewController");
                    NSLog(@"getUrPoints");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"geturpoints"];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];                                        
                    if ([dic[@"result"] intValue] == 1) {
                        NSLog(@"dic result boolValue is 1");
                        NSInteger point;
                        
                        if ([wTools objectExists: dic[@"data"]]) {
                            point = [dic[@"data"] integerValue];
                            [userPrefs setObject: [NSNumber numberWithInteger: point] forKey: @"pPoint"];
                            [userPrefs synchronize];
                        }
                        [self toMyTabBarController];
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗： %@", dic[@"message"]);
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

#pragma mark - To MyTabBarController
- (void)toMyTabBarController {
    MyTabBarController *myTabC = [[UIStoryboard storyboardWithName: @"Main" bundle: nil] instantiateViewControllerWithIdentifier: @"MyTabBarController"];
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.myNav pushViewController: myTabC animated: NO];
}

#pragma mark - Custom Alert Method
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
    [wTools setStatusBarBackgroundColor:[UIColor clearColor]];
    [alertTimeOutView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertTimeOutView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertTimeOutView tag]);
        
        [weakAlertTimeOutView close];
        [wTools setStatusBarBackgroundColor:[UIColor whiteColor]];
        if (buttonIndex == 0) {            
        } else {
            if ([protocolName isEqualToString: @"getHobbyList"]) {
                [weakSelf getHobbyList];
            } else if ([protocolName isEqualToString: @"updateprofilehobby"]) {
                [weakSelf DownBtn: nil];
            } else if ([protocolName isEqualToString: @"getprofile"]) {
                [weakSelf getProfile];
            } else if ([protocolName isEqualToString: @"geturpoints"]) {
                [weakSelf getUrPoints];
            }
        }
    }];
    [alertTimeOutView setUseMotionEffects: YES];
    [alertTimeOutView show];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
