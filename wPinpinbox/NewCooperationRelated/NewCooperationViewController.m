//
//  NewCooperationViewController.m
//  wPinpinbox
//
//  Created by David on 2018/9/25.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "NewCooperationViewController.h"
#import "AppDelegate.h"
#import "GlobalVars.h"
#import "UIColor+Extensions.h"
#import "UIColor+HexString.h"
#import "wTools.h"
#import "boxAPI.h"
#import "CustomIOSAlertView.h"
#import "UIViewController+ErrorAlert.h"
#import "MyLinearLayout.h"
#import "LabelAttributeStyle.h"
#import "IdentityCollectionViewCell.h"
#import "CreatorListCollectionViewCell.h"
#import "CreatorListCollectionReusableView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIView+Toast.h"
//#import "DDAUIActionSheetViewController.h"
#import "CooperationInfoViewController.h"

@interface NewCooperationViewController () <UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CooperationInfoViewControllerDelegate>
@property (strong, nonatomic) NSString *qrImageStr;
@property (strong, nonatomic) NSMutableArray *cooperationData;
@property (strong, nonatomic) NSMutableArray *creatorListData;
@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarHeight;
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIButton *cancelTextBtn;
@property (weak, nonatomic) IBOutlet UIButton *qrCodeBtn;

@property (weak, nonatomic) IBOutlet MyLinearLayout *infoView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@property (weak, nonatomic) IBOutlet UIView *qrCodeBgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qrCodeBgViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImageView;
@property (weak, nonatomic) IBOutlet UILabel *qrCodeInfoLabel;

@property (weak, nonatomic) IBOutlet UICollectionView *identityCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *creatorListCollectionView;

@property (nonatomic) UIVisualEffectView *effectView;
@property (nonatomic) CooperationInfoViewController *customActionSheet;

@property (nonatomic) BOOL firstTimeLoadingData;
@property (strong, nonatomic) NSString *option;
@property (strong, nonatomic) NSMutableArray *indexPathArray;
@property (strong, nonatomic) NSMutableArray *creatorIndexPathArray;

@end

@implementation NewCooperationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initialValueSetup];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [wTools setStatusBarBackgroundColor: [UIColor whiteColor]];
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
                self.qrCodeBgViewBottomConstraint.constant = 35;
                break;
            default:
                printf("unknown");
                break;
        }
    }
}

- (void)initialValueSetup {
    self.option = @"FirstTimeLoading";
    self.firstTimeLoadingData = YES;
    [wTools setStatusBarBackgroundColor: [UIColor clearColor]];
    self.cooperationData = [NSMutableArray new];
    self.creatorListData = [NSMutableArray new];
    self.indexPathArray = [NSMutableArray new];
    self.creatorIndexPathArray = [NSMutableArray new];
    [self setupCollectionViewRelated];
    [self setupNavBarViewRelated];
    [self setupQRCodeRelatedView];
    [self setupInfoViewAndInfoLabel];
    [self getCooperationList];
}

- (void)setupCollectionViewRelated {
    self.creatorListCollectionView.hidden = YES;
    self.creatorListCollectionView.backgroundColor = [UIColor whiteColor];
    self.creatorListCollectionView.contentInset = UIEdgeInsetsMake(0, 0, self.identityCollectionView.frame.size.height, 0);
//    self.homeCollectionView.contentInset = UIEdgeInsetsMake(topContentOffset, 0, 0, 0);
    self.identityCollectionView.backgroundColor = [UIColor barColor];
}

- (void)setupNavBarViewRelated {
    self.navBarView.backgroundColor = [UIColor barColor];
    self.searchView.layer.cornerRadius = kCornerRadius;
    
    UIToolbar *numberToolBar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, 0, 320, 40)];
    numberToolBar.barStyle = UIBarStyleDefault;
    numberToolBar.items = [NSArray arrayWithObjects:
                           //[[UIBarButtonItem alloc] initWithTitle: @"取消" style: UIBarButtonItemStylePlain target: self action: @selector(cancelNumberPad)],
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil],
                           [[UIBarButtonItem alloc] initWithTitle: @"完成" style: UIBarButtonItemStyleDone target: self action: @selector(dismissKeyboard)], nil];
    self.searchTextField.inputAccessoryView = numberToolBar;
    self.searchTextField.textColor = [UIColor blackColor];
    
    self.cancelTextBtn.layer.cornerRadius = 8;
    [self.cancelTextBtn addTarget: self
                           action: @selector(cancelButtonHighlight:)
                 forControlEvents: UIControlEventTouchDown];
    [self.cancelTextBtn addTarget: self
                           action: @selector(cancelButtonNormal:)
                 forControlEvents: UIControlEventTouchUpInside];
    self.cancelTextBtn.hidden = YES;
    
    self.qrCodeBtn.layer.cornerRadius = kCornerRadius;
    self.qrCodeBtn.backgroundColor = [UIColor clearColor];
}

- (void)setupQRCodeRelatedView {
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(singleTap)];
    [self.qrCodeBgView addGestureRecognizer: singleTap];
    self.qrCodeBgView.backgroundColor = [UIColor blackColor];
    self.qrCodeBgView.alpha = 0.7;
    self.qrCodeImageView.backgroundColor = [UIColor whiteColor];
    [self hideQRCodeRelatedView];
}

#pragma mark -
- (void)hideQRCodeRelatedView {    
    self.qrCodeBgView.hidden = YES;
    self.qrCodeImageView.hidden = YES;
    self.qrCodeInfoLabel.hidden = YES;
}

- (void)showQRCodeRelatedView {
    self.qrCodeBgView.hidden = NO;
    self.qrCodeImageView.hidden = NO;
    self.qrCodeInfoLabel.hidden = NO;
}

- (void)singleTap {
    [UIView animateWithDuration: 0.5 animations:^{
        [self hideQRCodeRelatedView];
    }];
}

- (void)setupInfoViewAndInfoLabel {
    self.infoView.backgroundColor = [UIColor thirdGrey];
    self.infoView.layer.cornerRadius = 16;
    self.infoLabel.text = NSLocalizedString(@"GeneralText-DefaultInfo", @"");
    [LabelAttributeStyle changeGapString: self.infoLabel content: self.infoLabel.text];
    self.infoLabel.textColor = [UIColor firstGrey];
    self.infoLabel.font = [UIFont systemFontOfSize: 20.0];
    self.infoLabel.numberOfLines = 0;
    [self.infoLabel sizeToFit];
}

#pragma mark - UIButton Selector Methods
- (void)cancelButtonHighlight: (UIButton *)sender {
    NSLog(@"cancelButtonHighlight");
    sender.backgroundColor = [UIColor thirdMain];
    self.cancelTextBtn.hidden = YES;
    self.searchTextField.text = @"";
}

- (void)cancelButtonNormal: (UIButton *)sender {
    NSLog(@"cancelButtonNormal");
    sender.backgroundColor = [UIColor clearColor];
}

#pragma mark - UITextField Delegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    NSLog(@"shouldChangeCharactersInRange");
    NSString *resultString = [textField.text stringByReplacingCharactersInRange: range withString: string];
    NSLog(@"resultString: %@", resultString);
    
    if ([resultString isEqualToString: @""]) {
        NSLog(@"no text");
        self.cancelTextBtn.hidden = YES;
    } else {
        NSLog(@"has text");
        self.cancelTextBtn.hidden = NO;
        [self searchCreator: resultString];
    }
    return YES;
}

#pragma mark - Web Service
- (void)getCooperationList {
    [wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableDictionary *data = [NSMutableDictionary new];
        [data setObject: self.albumId forKey: @"type_id"];
        [data setObject: @"album" forKey: @"type"];
        NSString *response = [boxAPI getcooperationlist: [wTools getUserID]
                                                  token: [wTools getUserToken]
                                                   data: data];
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"getCooperationList response");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"NewCooperationViewController");
                    NSLog(@"getCooperationList");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getCooperationList"
                                            text: @""
                                          userId: @""
                                        identity: @""
                                         albumId: @""
                                      creatorDic: nil];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    NSLog(@"dic: %@", dic);
                    
                    if ([dic[@"result"] intValue] == 1) {
                        NSLog(@"Before");
                        NSLog(@"self.option: %@", self.option);
                        self.cooperationData = [NSMutableArray arrayWithArray: dic[@"data"]];
                        [self.identityCollectionView reloadData];
                        
                        NSLog(@"Before Swap");
                        NSLog(@"self.cooperationData: %@", self.cooperationData);
                        // Swap Array data for change admin order to 1st one
                        if (self.cooperationData.count > 0) {
                            NSString *identityStr = self.cooperationData[0][@"cooperation"][@"identity"];
                            NSLog(@"identityStr: %@", identityStr);
                            
                            if (![identityStr isEqualToString: @"admin"]) {
                                NSInteger adminIndexInteger = 0;
                                
                                for (NSInteger i = 0; i < self.cooperationData.count; i++) {
                                    NSString *identityStr = self.cooperationData[i][@"cooperation"][@"identity"];
                                    NSLog(@"identityStr: %@", identityStr);
                                    
                                    if ([identityStr isEqualToString: @"admin"]) {
                                        adminIndexInteger = i;
                                        NSLog(@"adminIndexInteger: %ld", (long)adminIndexInteger);
                                    }
                                }
                                [self.cooperationData exchangeObjectAtIndex: adminIndexInteger withObjectAtIndex: 0];
                                NSLog(@"After Swap");
                                NSLog(@"self.cooperationData: %@", self.cooperationData);
                            }
                        }
                        
                        // Get User Identity
                        for (NSDictionary *d in self.cooperationData) {
                            NSInteger userIdInteger = [d[@"user"][@"user_id"] integerValue];
                            
                            if ([[wTools getUserID] integerValue] == userIdInteger) {
                                self.userIdentity = d[@"cooperation"][@"identity"];
                            }
                        }
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗：%@",dic[@"message"]);
                        [self showCustomErrorAlert: dic[@"message"]];
                    } else {
                        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            }
        });
    });
}

- (void)getQRCode {
    [wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableDictionary *qrDic = [NSMutableDictionary new];
        [qrDic setObject: [NSNumber numberWithBool: YES] forKey: @"is_cooperation"];
        [qrDic setObject: [NSNumber numberWithBool: NO] forKey: @"is_follow"];
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject: qrDic
                                                           options: 0
                                                             error: nil];
        NSString *jsonStr = [[NSString alloc] initWithData: jsonData
                                                  encoding:  NSUTF8StringEncoding];
        NSString *responseQRCode = [boxAPI getQRCode: [wTools getUserID] token: [wTools getUserToken] type: @"album" type_id: self.albumId effect: @"execute" is: jsonStr];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (responseQRCode != nil) {
                NSLog(@"getQRCode response");
                
                if ([responseQRCode isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"NewCooperationViewController");
                    NSLog(@"getQRCode");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getQRCode"
                                            text: @""
                                          userId: @""
                                        identity: @""
                                         albumId: @""
                                      creatorDic: nil];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dicQR = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [responseQRCode dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    if ([dicQR[@"result"] intValue] == 1) {
                        self.qrImageStr = dicQR[@"data"];
                        self.qrCodeImageView.image = [self decodeBase64ToImage: self.qrImageStr];
                        
                        [UIView animateWithDuration: 0.5 animations:^{
                            [self showQRCodeRelatedView];
                        }];
                    } else if ([dicQR[@"result"] intValue] == 0) {
                        NSLog(@"失敗：%@",dicQR[@"message"]);
                        [self showCustomErrorAlert: dicQR[@"message"]];
                    } else {
                        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            }
        });
    });
}

- (void)searchCreator:(NSString *)text {
    NSLog(@"searchCreator");
    [wTools ShowMBProgressHUD];
    
    NSString *string = text;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableDictionary *data = [NSMutableDictionary new];
        [data setObject: @"user" forKey: @"searchtype"];
        [data setObject: string forKey: @"searchkey"];
        [data setObject: @"0,32" forKey: @"limit"];
        
        NSString *response = [boxAPI search: [wTools getUserID]
                                      token: [wTools getUserToken]
                                       data: data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"searchCreator");
                NSLog(@"response from search");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"NewCooperationViewController");
                    NSLog(@"searchCreator");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"searchCreator"
                                            text: text
                                          userId: @""
                                        identity: @""
                                         albumId: @""
                                      creatorDic: nil];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if (![dic[@"result"] boolValue]) {
                        return ;
                    }
                    //判斷回傳是否一樣
                    if (![text isEqualToString:string]) {
                        return;
                    }
                    //判斷目前table和 搜尋結果是否相同
                    if (![data[@"searchtype"] isEqualToString: @"user"]) {
                        return;
                    }
                    
                    if ([dic[@"result"] intValue] == 1) {
                        NSLog(@"dic result boolValue is 1");
                        NSLog(@"dic: %@", dic);
                        self.creatorListData = [NSMutableArray arrayWithArray: dic[@"data"]];
                        NSLog(@"self.creatorListData: %@", self.creatorListData);
                        NSLog(@"self.cooperationData: %@", self.cooperationData);
                        
                        // Method below will cause crash
                        /*
                        NSMutableArray *discardedItemsArray = [NSMutableArray array];
                        
                        // Remove those creators are already in the cooperation list
                        for (NSInteger i = 0; i < self.creatorListData.count; i++) {
                            NSLog(@"i: %ld", (long)i);
                            NSDictionary *dic1 = self.creatorListData[i];
                            NSLog(@"dic1: %@", dic1);
                            
                            for (NSInteger j = 0; j < self.cooperationData.count; j++) {
                                NSDictionary *dic2 = self.cooperationData[j];
                                NSInteger userId1 = [dic1[@"user"][@"user_id"] integerValue];
                                NSLog(@"userId1: %ld", (long)userId1);
                                NSInteger userId2 = [dic2[@"user"][@"user_id"] integerValue];
                                NSLog(@"userId2: %ld", (long)userId2);

                                if (userId1 == userId2) {
                                    NSLog(@"userId1 == userId2");
                                    [discardedItemsArray addObject: [NSNumber numberWithInteger: i]];
                                    NSLog(@"discardedItemsArray: %@", discardedItemsArray);
                                }
                            }
                        }
                        NSLog(@"discardedItemsArray: %@", discardedItemsArray);
                        
                        for (NSInteger i = 0; i < discardedItemsArray.count; i++) {
                            NSInteger index = [discardedItemsArray[i] integerValue];
                            [self.creatorListData removeObjectAtIndex: index];
                        }
                        */
                        
                        NSLog(@"self.creatorListData: %@", self.creatorListData);
                        [self.creatorListCollectionView reloadData];
                        
                        if (self.creatorListData.count == 0) {
                            self.infoLabel.text = NSLocalizedString(@"GeneralText-NoMatchCreator", @"");
                            self.infoLabel.textAlignment = NSTextAlignmentCenter;
                            [LabelAttributeStyle changeGapString: self.infoLabel content: self.infoLabel.text];
                            
                            self.creatorListCollectionView.hidden = YES;;
                            self.infoView.hidden = NO;
                        } else if (self.creatorListData.count > 0) {
                            self.creatorListCollectionView.hidden = NO;
                            self.infoView.hidden = YES;
                        }
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗：%@",dic[@"message"]);
                        self.creatorListCollectionView.hidden = YES;;
                        self.infoView.hidden = NO;
                        [self showCustomErrorAlert: dic[@"message"]];
                    } else {
                        self.creatorListCollectionView.hidden = YES;;
                        self.infoView.hidden = NO;
                        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            }
        });
    });
}

- (void)updateCooperation:(NSString *)userId
                 identity:(NSString *)identity
                  albumId:(NSString *)albumId {
    [wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *data = [NSMutableDictionary new];
        [data setObject: albumId forKey: @"type_id"];
        [data setObject: @"album" forKey: @"type"];
        [data setObject: identity forKey: @"identity"];
        [data setObject: userId forKey: @"user_id"];
        
        NSLog(@"data: %@", data);
        
        NSString *response = [boxAPI updatecooperation: [wTools getUserID]
                                                 token: [wTools getUserToken]
                                                  data: data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"response from updateCooperation");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"updateCooperation"
                                            text: @""
                                          userId: userId
                                        identity: identity
                                         albumId: albumId
                                      creatorDic: nil];
                } else {
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    NSLog(@"dic: %@", dic);
                    
                    if ([dic[@"result"] intValue] == 1) {
                        self.option = @"Updating";
                        
                        NSLog(@"Before Updating");
                        NSLog(@"self.cooperationData: %@", self.cooperationData);
                        for (NSInteger i = 0; i < self.cooperationData.count; i++) {
                            NSMutableDictionary *d = self.cooperationData[i];
                            NSMutableDictionary *cooperationDic = d[@"cooperation"];
                            [cooperationDic setValue: identity forKey: @"identity"];
                        }
                        NSLog(@"After Updating");
                        NSLog(@"self.cooperationData: %@", self.cooperationData);
                        
                        [UIView performWithoutAnimation:^{
                            [self.identityCollectionView reloadItemsAtIndexPaths: self.indexPathArray];
                        }];                        
//                        [self.cooperationData removeAllObjects];
//                        [self getCooperationList];
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗：%@",dic[@"message"]);
                        [self showCustomErrorAlert: dic[@"message"]];
                    } else {
                        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            } else {
                [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
            }
        });
    });
}

- (void)deleteCooperation:(NSString *)userId
                  albumId:(NSString *)albumId
               creatorDic:(NSMutableDictionary *)creatorDic {
    [wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableDictionary *data = [NSMutableDictionary new];
        [data setObject: userId forKey: @"user_id"];
        [data setObject: albumId forKey: @"type_id"];
        [data setObject: @"album" forKey: @"type"];
        
        NSString *response = [boxAPI deletecooperation: [wTools getUserID]
                                                 token: [wTools getUserToken]
                                                  data: data];
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"response from deleteCooperation");
                if (response != nil) {
                    if ([response isEqualToString: timeOutErrorCode]) {
                        [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                        protocolName: @"deleteCooperation"
                                                text: @""
                                              userId: userId
                                            identity: @""
                                             albumId: albumId
                                          creatorDic: creatorDic];
                    } else {
                        NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                        
                        NSLog(@"dic: %@", dic);
                        
                        if ([dic[@"result"] intValue] == 1) {
                            self.option = @"Deleting";
                            
                            NSInteger indexInt = 0;
                            NSArray *array;

                            NSLog(@"self.cooperationData: %@", self.cooperationData);
                            
                            for (NSInteger i = 0; i < self.cooperationData.count; i++) {
                                NSLog(@"i: %ld", i);
                                
                                NSMutableDictionary *dicData = self.cooperationData[i];
                                NSLog(@"dicData: %@", dicData);
                                
                                if ([dicData[@"user"][@"user_id"] intValue] == [creatorDic[@"user"][@"user_id"] intValue]) {
                                    NSLog(@"userId Match");
                                    array = [NSArray arrayWithObject: creatorDic];
                                    NSLog(@"array: %@", array);
                                    indexInt = i;
                                }
                            }
//                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow: indexInt inSection: 0];
//                            NSArray *indexPathArray = [NSArray arrayWithObject: indexPath];
//                            [self.indexPathArray removeAllObjects];
//                            [self.indexPathArray addObject: indexPathArray];
//
                            NSLog(@"self.cooperationData removeObjectsInArray");
                            
                            [self.cooperationData removeObjectAtIndex: indexInt];
                            NSLog(@"self.cooperationData: %@", self.cooperationData);
                            
                            NSLog(@"self.identityCollectionView deleteItemsAtIndexPaths");
//                            NSLog(@"indexPath.row: %ld", (long)indexPath.row);
                            
                            [self.identityCollectionView deleteItemsAtIndexPaths: self.indexPathArray];
                            
                            if (self.creatorListData.count > 0) {
                                NSLog(@"self.creatorListCollectionView reloadItemsAtIndexPaths");
                                [self.creatorListCollectionView reloadItemsAtIndexPaths: self.creatorIndexPathArray];
                            }
//                            [self getCooperationList];
                        } else if ([dic[@"result"] intValue] == 0) {
                            NSLog(@"失敗：%@",dic[@"message"]);
                            [self showCustomErrorAlert: dic[@"message"]];
                        } else {
                            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                        }
                    }
                } else {
                    [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                }
            }
        });
    });
}

- (void)addCoperation:(NSString *)userId
              albumId:(NSString *)albumId
           creatorDic:(NSMutableDictionary *)creatorDic {
    [wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *data = [NSMutableDictionary new];
        [data setObject: userId forKey: @"user_id"];
        [data setObject: @"album" forKey: @"type"];
        [data setObject: albumId forKey: @"type_id"];
        NSString *response = [boxAPI addcooperation: [wTools getUserID]
                                              token: [wTools getUserToken]
                                               data: data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"response from addCoperation");
                if (response != nil) {
                    if ([response isEqualToString: timeOutErrorCode]) {
                        [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                        protocolName: @"addCoperation"
                                                text: @""
                                              userId: userId
                                            identity: @""
                                             albumId: albumId
                                          creatorDic: creatorDic];
                    } else {
                        NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                        
                        NSLog(@"dic: %@", dic);
                        
                        if ([dic[@"result"] intValue] == 1) {
                            self.option = @"Adding";
                            [self.indexPathArray removeAllObjects];
                            self.indexPathArray = [NSMutableArray arrayWithObject: [NSIndexPath indexPathForRow: 1 inSection: 0]];
                            [self.cooperationData insertObject: creatorDic atIndex: 1];
                            [self.identityCollectionView insertItemsAtIndexPaths: self.indexPathArray];
                            if (self.creatorListData.count > 0) {
                                [self.creatorListCollectionView reloadItemsAtIndexPaths: self.creatorIndexPathArray];
                            }
//                            if (self.creatorListData.count > 0) {
//                                [self.creatorListCollectionView reloadData];
//                            }
//                            [self.cooperationData removeAllObjects];
//                            [self getCooperationList];
                        } else if ([dic[@"result"] intValue] == 0) {
                            NSLog(@"失敗：%@",dic[@"message"]);
                            [self showCustomErrorAlert: dic[@"message"]];
                        } else {
                            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                        }
                    }
                } else {
                    [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                }
            }
        });
    });
}

#pragma mark - decodeBase64ToImage Method
- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData{
    NSData *data = [[NSData alloc] initWithBase64EncodedString: strEncodeData options: NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData: data];
}

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    NSLog(@"numberOfItemsInSection");
    if (collectionView == self.identityCollectionView) {
        return self.cooperationData.count;
    } else {
        return self.creatorListData.count;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"viewForSupplementaryElementOfKind");
    CreatorListCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind: kind withReuseIdentifier: @"HeaderCell" forIndexPath: indexPath];
    [LabelAttributeStyle changeGapString: headerView.topicLabel content: headerView.topicLabel.text];
    return headerView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForItemAtIndexPath");
    
    if (collectionView == self.identityCollectionView) {
        IdentityCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"IdentityCell" forIndexPath: indexPath];
        
        if (indexPath.row == 0) {
            cell.deleteIdentityBtn.hidden = YES;
        } else {
            cell.deleteIdentityBtn.hidden = NO;
        }
        
        NSDictionary *userDic = self.cooperationData[indexPath.row][@"user"];
        
        if ([userDic[@"picture"] isEqual: [NSNull null]]) {
            cell.userPictureImageView.image = [UIImage imageNamed: @"member_back_head.png"];
        } else {
            [cell.userPictureImageView sd_setImageWithURL: [NSURL URLWithString: userDic[@"picture"]] placeholderImage: [UIImage imageNamed: @"member_back_head.png"]];
        }
        cell.userNameLabel.text = userDic[@"name"];
        
        NSDictionary *cooperationDic = self.cooperationData[indexPath.row][@"cooperation"];
        
        if (![cooperationDic[@"identity"] isEqual: [NSNull null]]) {
            [self changeUserIdentityChangeBtn: cell.userIdentityChangeBtn identity: cooperationDic[@"identity"]];
        }
        
        return cell;
    } else {
        NSDictionary *userDic = self.creatorListData[indexPath.row][@"user"];
        
        CreatorListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"CreatorListCell" forIndexPath: indexPath];
        if ([userDic[@"picture"] isEqual: [NSNull null]]) {
            cell.userPictureImageView.image = [UIImage imageNamed: @"member_back_head.png"];
        } else {
            [cell.userPictureImageView sd_setImageWithURL: [NSURL URLWithString: userDic[@"picture"]] placeholderImage: [UIImage imageNamed: @"member_back_head.png"]];
        }
        cell.userNameLabel.text = userDic[@"name"];
        [LabelAttributeStyle changeGapString: cell.userNameLabel content: cell.userNameLabel.text];
        
        if ([self checkUsersInCooperationDataOrNot: [userDic[@"user_id"] intValue]]) {
            [cell setInviteBtnEnabled: NO];
        } else {
            [cell setInviteBtnEnabled: YES];
        }
        return cell;
    }
}

- (BOOL)checkUsersInCooperationDataOrNot:(NSInteger)userId {
    __block int r = -1;
    
    [self.cooperationData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *d = (NSDictionary *)obj;
        NSDictionary *user = d[@"user"];
        int u = [user[@"user_id"] intValue];
        
        if (u == userId) {
            r = (int)idx;
            *stop = YES;
        }
    }];
    return (r >= 0);
}

- (UIButton *)changeUserIdentityChangeBtn:(UIButton *)btn
                                 identity:(NSString *)identity {
    if ([identity isEqualToString: @"admin"]) {
        [btn setTitle: @"管理" forState: UIControlStateNormal];
        [self changeBtnStyle: btn identity: identity];
    } else if ([identity isEqualToString: @"approver"]) {
        [btn setTitle: @"副管理" forState: UIControlStateNormal];
        [self changeBtnStyle: btn identity: identity];
    } else if ([identity isEqualToString: @"editor"]) {
        [btn setTitle: @"共用" forState: UIControlStateNormal];
        [self changeBtnStyle: btn identity: identity];
    } else if ([identity isEqualToString: @"viewer"]) {
        [btn setTitle: @"瀏覽" forState: UIControlStateNormal];
        [self changeBtnStyle: btn identity: identity];
    }
    return btn;
}

- (UIButton *)changeBtnStyle:(UIButton *)btn
                    identity:(NSString *)identity {
    if ([identity isEqualToString: @"admin"]) {
        [btn setTitleColor: [UIColor secondGrey] forState: UIControlStateNormal];
        btn.backgroundColor = [UIColor clearColor];
        btn.layer.borderColor = [UIColor secondGrey].CGColor;
        btn.layer.borderWidth = 1.0;
    } else {
        [btn setTitleColor: [UIColor firstGrey] forState: UIControlStateNormal];
        btn.backgroundColor = [UIColor thirdGrey];
        btn.layer.borderColor = [UIColor clearColor].CGColor;
        btn.layer.borderWidth = 0;
    }
    return btn;
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (collectionView == self.identityCollectionView) {
        return 16.0f;
    } else {
        return 1.0f;
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {    
    UIEdgeInsets itemInset = UIEdgeInsetsMake(0, 16, 0, 16);
    return itemInset;
}

#pragma mark - IBAction Methods
- (IBAction)qrcodeBtnPressed:(id)sender {
    NSLog(@"qrcodeBtnPressed");
    [self getQRCode];
}

- (IBAction)backBtnPressed:(id)sender {
    //  notify CalbumCollectionVC
    if (self.vDelegate && [self.vDelegate respondsToSelector:@selector(newCoopeartionVCFinished:)]) {
        [self.vDelegate newCoopeartionVCFinished:self.albumId];
    }
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav popViewControllerAnimated: YES];
}

- (IBAction)inviteBtnPressed:(id)sender {
    NSLog(@"inviteBtnPressed");
    CreatorListCollectionViewCell *cell = (CreatorListCollectionViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.creatorListCollectionView indexPathForCell: cell];
    NSDictionary *userDic = self.creatorListData[indexPath.row][@"user"];
    NSString *userId = [userDic[@"user_id"] stringValue];
    
    if (indexPath == nil) {
        assert(false);
        return;
    }
    NSLog(@"indexPath.row: %ld", (long)indexPath.row);
    
//    NSArray *creatorIndexPathArray;
//    creatorIndexPathArray = [NSArray arrayWithObject: indexPath];
    
    [self.creatorIndexPathArray removeAllObjects];
    [self.creatorIndexPathArray addObject: indexPath];
    
    [self addCoperation: userId
                albumId: self.albumId
             creatorDic: [self createCreatorDic: userDic]];
}

- (IBAction)identityBtnPressed:(id)sender {
    NSLog(@"identityBtnPressed");
    IdentityCollectionViewCell *cell = (IdentityCollectionViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.identityCollectionView indexPathForCell: cell];
    NSDictionary *userDic = self.cooperationData[indexPath.row][@"user"];
    NSDictionary *cooperationDic = self.cooperationData[indexPath.row][@"cooperation"];
    NSString *userId = [userDic[@"user_id"] stringValue];
    
    NSLog(@"userDic: %@", userDic);
    
    if (indexPath == nil) {
        assert(false);
        return;
    }
    
    NSLog(@"indexPath.row: %ld", (long)indexPath.row);
    [self.indexPathArray removeAllObjects];
    [self.indexPathArray addObject: indexPath];
    
    if (indexPath.row != 0) {
        if ([self.userIdentity isEqualToString: @"admin"]) {
            [self showManagementActionSheet: userId];
//            [self showActionSheet: userId];
        } else if ([self.userIdentity isEqualToString: @"approver"]) {
            if (![cooperationDic[@"identity"] isEqual: [NSNull null]]) {
                if ([cooperationDic[@"identity"] isEqualToString: @"approver"]) {
                    CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                    style.messageColor = [UIColor whiteColor];
                    style.backgroundColor = [UIColor colorFromHexString: @"9e9e9e"];
                    [self.view makeToast: @"副管理者之間不能互相變更權限"
                                duration: 1.0
                                position: CSToastPositionBottom
                                   style: style];
                    return;
                } else {
                    [self showManagementActionSheet: userId];
//                    [self showActionSheet: userId];
                }
            }
        }
    }
}

- (IBAction)deleteIdentityBtnPressed:(id)sender {
    NSLog(@"deleteIdentityBtnPressed");
    IdentityCollectionViewCell *cell = (IdentityCollectionViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.identityCollectionView indexPathForCell: cell];
    NSDictionary *userDic = self.cooperationData[indexPath.row][@"user"];
    NSDictionary *cooperationDic = self.cooperationData[indexPath.row][@"cooperation"];
    NSString *userId = [userDic[@"user_id"] stringValue];
    
    if (indexPath == nil) {
        assert(false);
        return;
    }
    NSLog(@"indexPath.row: %ld", (long)indexPath.row);
    
    [self.creatorIndexPathArray removeAllObjects];
    
//    NSArray *creatorIndexPathArray;
    
    if (self.creatorListData.count > 0) {
        for (NSInteger i = 0; i < self.creatorListData.count; i++) {
            NSDictionary *dic = self.creatorListData[i];
            NSLog(@"dic: %@", dic);
            
            if ([dic[@"user"][@"user_id"] intValue] == [userId intValue]) {
                NSLog(@"found userId in self.creatorListData");
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow: i inSection: 0];
                [self.creatorIndexPathArray addObject: indexPath];
//                creatorIndexPathArray = [NSArray arrayWithObject: indexPath];
            }
        }
    }
    
//    NSArray *cooperationIndexPathArray;
//    cooperationIndexPathArray = [NSArray arrayWithObject: indexPath];
    
    [self.indexPathArray removeAllObjects];
    [self.indexPathArray addObject: indexPath];
    
    if (indexPath.row != 0) {
        if ([self.userIdentity isEqualToString: @"admin"]) {
            [self deleteCooperation: userId
                            albumId: self.albumId
                         creatorDic: [self createCreatorDic: userDic]];
        } else if ([self.userIdentity isEqualToString: @"approver"]) {
            if ([cooperationDic[@"identity"] isEqualToString: @"approver"]) {
                CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                style.messageColor = [UIColor whiteColor];
                style.backgroundColor = [UIColor colorFromHexString: @"9e9e9e"];
                [self.view makeToast: @"副管理者之間不能互相移除"
                            duration: 1.0
                            position: CSToastPositionBottom
                               style: style];
                return;
            } else {
                [self deleteCooperation: userId
                                albumId: self.albumId
                             creatorDic: [self createCreatorDic: userDic]];
            }
        }
    }
}

#pragma mark -
- (NSMutableDictionary *)createCreatorDic:(NSDictionary *)userDic {
    NSMutableDictionary *identityDic = [NSMutableDictionary new];
    [identityDic setObject: @"viewer" forKey: @"identity"];
    
    NSMutableDictionary *userDicData = [NSMutableDictionary new];
    [userDicData setObject: userDic[@"name"] forKey: @"name"];
    [userDicData setObject: userDic[@"picture"] forKey: @"picture"];
    [userDicData setObject: userDic[@"user_id"] forKey: @"user_id"];
    
    NSMutableDictionary *creatorDic = [NSMutableDictionary new];
    [creatorDic setObject: identityDic forKey: @"cooperation"];
    [creatorDic setObject: userDicData forKey: @"user"];
    
    return creatorDic;
}

#pragma mark - Show actionsheet
- (void)showManagementActionSheet:(NSString *)userId {
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle: UIBlurEffectStyleDark];
    self.effectView = [[UIVisualEffectView alloc] initWithEffect: blurEffect];
    
    self.effectView.frame = CGRectMake(0, 0, self.view.frame.size.width, [UIApplication sharedApplication].keyWindow.bounds.size.height);//self.view.frame;
    self.effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.effectView.alpha = 0.8;
    
    self.customActionSheet = [[CooperationInfoViewController alloc] init];
//    self.customActionSheet.infoStr = NSLocalizedString(@"GeneralText-IdentityInfo", @"");
    self.customActionSheet.topicStr = @"變更權限";
    self.customActionSheet.hideQuestionBtn = NO;
    self.customActionSheet.delegate = self;
    [[UIApplication sharedApplication].keyWindow addSubview: self.effectView];
    [[UIApplication sharedApplication].keyWindow addSubview: self.customActionSheet.view];
    [self.customActionSheet viewWillAppear: NO];
    
    if ([self.userIdentity isEqualToString: @"admin"]) {
        [self.customActionSheet addSelectButtons: @[@"副管理", @"共用", @"瀏覽"]
                                  identifierStrs: @[@"approver", @"editor", @"viewer"]];
        __block typeof(self) weakSelf = self;
        __block typeof(self.albumId) albumId = self.albumId;
        
        self.customActionSheet.customButtonTapBlock = ^(NSInteger tag, NSString *identifierStr) {
            switch (tag) {
                case 1:
                case 2:
                case 3:
                    [weakSelf updateCooperation: userId
                                       identity: identifierStr
                                        albumId: albumId];
                    break;
                default:
                    break;
            }
        };
    } else if ([self.userIdentity isEqualToString: @"approver"]) {
        [self.customActionSheet addSelectButtons:@[@"共用",@"瀏覽"]
                                  identifierStrs:@[@"editor",@"viewer"]];
        __block typeof(self) weakSelf = self;
        __block typeof(self.albumId) albumId = self.albumId;
        
        self.customActionSheet.customButtonTapBlock = ^(NSInteger tag, NSString *identifierStr) {
            switch (tag) {
                case 1:
                case 2:
                    [weakSelf updateCooperation: userId
                                       identity: identifierStr
                                        albumId: albumId];
                    break;
                default:
                    break;
            }
        };
    }
}

- (void)actionSheetViewDidSlideOut:(CooperationInfoViewController *)controller {
    [self.effectView removeFromSuperview];
    self.effectView = nil;
}

#pragma mark - Touches Detection
- (void)touchesBegan:(NSSet<UITouch *> *)touches
           withEvent:(UIEvent *)event {
    NSLog(@"");
    NSLog(@"touchesBegan");
    [self dismissKeyboard];
}

- (void)dismissKeyboard {
    [self.view endEditing: YES];
}

#pragma mark - Custom Error Alert Method
- (void)showCustomErrorAlert: (NSString *)msg {
    [UIViewController showCustomErrorAlertWithMessage:msg onButtonTouchUpBlock:^(CustomIOSAlertView * _Nullable customAlertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[customAlertView tag]);
        [customAlertView close];
    }];
}

#pragma mark - Custom Method for TimeOut
- (void)showCustomTimeOutAlert:(NSString *)msg
                  protocolName:(NSString *)protocolName
                          text:(NSString *)text
                        userId:(NSString *)userId
                      identity:(NSString *)identity
                       albumId:(NSString *)albumId
                    creatorDic:(NSMutableDictionary *)creatorDic {
    CustomIOSAlertView *alertTimeOutView = [[CustomIOSAlertView alloc] init];
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
            if ([protocolName isEqualToString: @"getCooperationList"]) {
                [weakSelf getCooperationList];
            } else if ([protocolName isEqualToString: @"getQRCode"]) {
                [weakSelf getQRCode];
            } else if ([protocolName isEqualToString: @"searchCreator"]) {
                [weakSelf searchCreator: text];
            } else if ([protocolName isEqualToString: @"updateCooperation"]) {
                [weakSelf updateCooperation: userId
                                   identity: identity
                                    albumId: albumId];
            } else if ([protocolName isEqualToString: @"deleteCooperation"]) {
                [weakSelf deleteCooperation: userId
                                    albumId: albumId
                                 creatorDic: creatorDic];
            } else if ([protocolName isEqualToString: @"addCoperation"]) {
                [weakSelf addCoperation: userId
                                albumId: albumId
                             creatorDic: creatorDic];
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



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
