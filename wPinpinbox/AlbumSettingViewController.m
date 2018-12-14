//
//  AlbumSettingViewController.m
//  wPinpinbox
//
//  Created by David on 6/21/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "AlbumSettingViewController.h"
#import "UIColor+Extensions.h"
#import "boxAPI.h"
#import "wTools.h"
#import "MyLinearLayout.h"
#import "UIView+Toast.h"
#import "CustomIOSAlertView.h"
#import "OldCustomAlertView.h"
#import "TouchDetectedScrollView.h"
#import "AlbumCollectionViewController.h"
#import <SafariServices/SafariServices.h>
#import "ContentCheckingViewController.h"
#import "AlbumCreationViewController.h"
#import "GlobalVars.h"
#import "AppDelegate.h"
#import "ScanCodeForAdvancedSettingViewController.h"
#import "AlbumDetailViewController.h"
#import "UIViewController+ErrorAlert.h"

#import "UIImage+Resize.h"

#import "InfoTextView.h"

#define SponsorRemindMsg @"啟用需遵守個人資料保護法之相關規定，盡善良管理人之注意義務，不得外流或作為本次回饋使用者以外目的之使用，並須遵守本平台含隱私權政策在內之相關規定，如有違反，需自負一切責任。"

@interface CheckBox : UIButton
@end

@implementation  CheckBox
- (void)awakeFromNib {
    [super awakeFromNib];
    UIImage *i = [UIImage imageNamed:@"navigationbarshadow"];
    UIImage *ni = [i resizedImage:CGSizeMake(24, 24) interpolationQuality:kCGInterpolationNone];
    [self setImage:ni forState:UIControlStateNormal];
    
    self.imageView.contentMode = UIViewContentModeScaleToFill;
    self.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 2);
    self.imageView.layer.borderColor = [UIColor thirdGrey].CGColor;
    self.imageView.layer.borderWidth = 1;
    self.imageView.layer.cornerRadius = 6;
    //self.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 0, 0);
}
- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (!selected) {
        self.imageView.backgroundColor = [UIColor clearColor];
    } else {
        self.imageView.backgroundColor = [UIColor thirdMain];
    }
}
@end

@interface DelTextField : UITextField<UITextFieldDelegate>
@property (nonatomic) int listIndex;
@property (nonatomic) NSString *delActionFUNCName;
@property (nonatomic) id delSource;
@property (nonatomic) UIButton *delBtn;
- (id)initWithFrame:(CGRect)frame listindex:(int)listindex text:(NSString *)text source:(id)source delaction:(SEL)delaction;
@end
@implementation DelTextField
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return NO;
}
- (id)initWithFrame:(CGRect)frame listindex:(int)listindex text:(NSString *)text source:(id)source delaction:(SEL)delaction {
    self = [super initWithFrame:frame];
    if (self) {
        self.listIndex = listindex;
        self.text = text;
        self.delegate = self;
        self.delSource = source;
        self.delActionFUNCName = NSStringFromSelector(delaction);
        
        self.delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.delBtn setBackgroundColor:[UIColor thirdGrey]];
        [self.delBtn setImage:[UIImage imageNamed:@"ic200_cancel_light"] forState:UIControlStateNormal];
        [self.delBtn setImageEdgeInsets:UIEdgeInsetsMake(6, 6, 6, 6)];
        UIView *base = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        self.delBtn.frame = CGRectMake(4,4,32,32);
        [base setBackgroundColor:[UIColor clearColor]];
        [base addSubview:self.delBtn];
        self.delBtn.layer.cornerRadius = 6;
        self.rightView = base;
        self.rightViewMode = UITextFieldViewModeAlways;
        [self.delBtn addTarget:self action:@selector(delThisItem:) forControlEvents:UIControlEventTouchUpInside];
        self.layer.cornerRadius = 6;
        self.backgroundColor = [UIColor thirdGrey];
        
        
        self.leftViewMode = UITextFieldViewModeAlways;
        UIView *left = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, self.frame.size.height)];
        left.backgroundColor = UIColor.clearColor;
        self.leftView = left;
    }
    
    return self;
}
- (void)delThisItem:(id)sender {
    SEL action = NSSelectorFromString(self.delActionFUNCName);
    if (action && self.delSource) {
        if ([self.delSource respondsToSelector:action]) {                        
            [self.delSource performSelectorOnMainThread:action withObject:self waitUntilDone:NO];
        }
    }
}
@end


@interface AlbumSettingViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate, UITextFieldDelegate, UITextViewDelegate, SFSafariViewControllerDelegate>
{
    NSString *sfir;
    NSString *ssec;
    NSString *sact;
    NSString *saudio;
    NSString *swea;
    NSString *smood;
    
    NSString *firstPaging;
    NSString *secondPaging;
    NSString *weatherStr;
    NSString *moodStr;
    
    // Menu Data
    NSDictionary *mdata;
 
    UITextView *selectTextView;
    UITextField *selectTextField;
    
    BOOL isPrivate;
    BOOL isModified;
    
    NSMutableArray *firstCategoryArray;
    NSMutableArray *secondCategoryArray;
    NSMutableArray *weatherArray;
    NSMutableArray *moodArray;        
    
    NSString *oldName;
    NSString *oldDescription;
    NSString *oldLocation;
    NSString *oldPoint;
    NSString *oldAdvancedStr;
    
    BOOL albumEditBtnPress;
    
    
    // For Showing Message of Getting Point
    NSString *missionTopicStr;
    NSString *rewardType;
    NSString *rewardValue;
    NSString *eventUrl;
    
    NSString *restriction;
    NSString *restrictionValue;
    NSUInteger numberOfCompleted;
    
    OldCustomAlertView *alertTaskView;
}

// User Setting Data
@property (strong,nonatomic) NSDictionary *data;

@property (nonatomic, strong) NSIndexPath *firstCategoryIndexPath;
@property (nonatomic, strong) NSIndexPath *secondCategoryIndexPath;
//@property (nonatomic, strong) NSIndexPath *weatherIndexPath;
//@property (nonatomic, strong) NSIndexPath *moodIndexPath;

//@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet TouchDetectedScrollView *scrollView;
@property (weak, nonatomic) IBOutlet MyLinearLayout *backgroundLayout;
@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarHeight;
@property (weak, nonatomic) IBOutlet UILabel *privacyLabel;
@property (weak, nonatomic) IBOutlet UIButton *privacyBtn;

@property (weak, nonatomic) IBOutlet UITextView *nameTextView;

//@property (weak, nonatomic) IBOutlet UIView *nameBgView;
@property (weak, nonatomic) IBOutlet MyLinearLayout *nameBgView;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UITextView *locationTextView;

@property (weak, nonatomic) IBOutlet UIButton *toAlbumCreationBtn;
@property (weak, nonatomic) IBOutlet UIButton *saveAndExitBtn;

@property (weak, nonatomic) IBOutlet UICollectionView *firstCategoryCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *secondCategoryCollectionView;

//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secondCategoryHeight;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *plusMemberHeight;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *professionMemberHeight;
//@property (weak, nonatomic) IBOutlet UICollectionView *weatherCollectionView;
//@property (weak, nonatomic) IBOutlet UICollectionView *moodCollectionView;

@property (weak, nonatomic) IBOutlet UIButton *pQuestionBtn;
@property (weak, nonatomic) IBOutlet UIView *pPointView;
@property (weak, nonatomic) IBOutlet UITextField *pPointTextField;

//@property (weak, nonatomic) IBOutlet MyLinearLayout *advanceLayout;
//@property (weak, nonatomic) IBOutlet UIView *advancedLineView;
//@property (weak, nonatomic) IBOutlet UIView *advanceSettingView;
//@property (weak, nonatomic) IBOutlet UITextField *advancedTextField;

@property (weak, nonatomic) IBOutlet UILabel *nameRequiredLabel;
@property (weak, nonatomic) IBOutlet UILabel *decriptionRequiredLabel;
@property (weak, nonatomic) IBOutlet UILabel *mainCategoryRequiredLabel;
@property (weak, nonatomic) IBOutlet UILabel *subCategoryRequiredLabel;

@property (weak, nonatomic) IBOutlet UIView *bottomBtnView;

@property (weak, nonatomic) IBOutlet MyLinearLayout *plusView;
@property (weak, nonatomic) IBOutlet UIButton *sponsorDescON;
@property (weak, nonatomic) IBOutlet UIButton *sponsorDescOFF;
@property (weak, nonatomic) IBOutlet UIButton *sponsorCountON;
@property (weak, nonatomic) IBOutlet UIButton *sponsorCountOFF;
@property (weak, nonatomic) IBOutlet InfoTextView *sponsorDesc;

@property (weak, nonatomic) IBOutlet MyLinearLayout *professionView;
@property (weak, nonatomic) IBOutlet UITextField *advTextField;
@property (weak, nonatomic) IBOutlet MyLinearLayout *albslistView;
@property (nonatomic) UIButton *submitBtn;

@property (nonatomic) NSMutableArray *albumIndexArray;
@end

@implementation AlbumSettingViewController
#pragma mark - View Related Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"AlbumSettingViewController viewDidLoad");
    NSLog(@"self.prefixText: %@", self.prefixText);    
    NSLog(@"self.postMode: %d", self.postMode);
    NSLog(@"self.fromVC: %@", self.fromVC);
    NSLog(@"self.userIdentity: %@", self.userIdentity);
    [self setupUI1];
    [self getAlbumDataOptions];
    //[self checkCreatePointTask];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addKeyboardNotification];
    
    [UIView animateWithDuration: 0.5 animations:^{
        self.view.alpha = 0;
        self.view.alpha = 1;
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeKeyboardNotification];
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
            default://case 2436:
                printf("iPhone X");
                self.navBarHeight.constant = navBarHeightConstant;
                break;
//            default:
//                printf("unknown");
//                break;
        }
    }
}

- (void)getAlbumDataOptions {
    NSLog(@"getAlbumDataOptions");
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
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI getalbumdataoptions: [wTools getUserID]
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
                    NSLog(@"AlbumSettingViewController");
                    NSLog(@"getAlbumDataOptions");
                    
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getalbumdataoptions"
                                         jsonStr: @""
                                         albumId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        [wself setMData:dic];
                        [wself getAlbumSettings];
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

- (void)setMData:(NSDictionary *)dic {
    mdata = [[dic objectForKey: @"data"] mutableCopy];
    NSLog(@"mdata: %@", mdata);
}

- (void)getAlbumSettings {
    NSLog(@"getAlbumSettings");
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
        NSString *response = [boxAPI getalbumsettings: [wTools getUserID]
                                                token: [wTools getUserToken]
                                             album_id: self.albumId];
        
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
                    NSLog(@"AlbumSettingViewController");
                    NSLog(@"getAlbumSettings");
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getalbumsettings"
                                         jsonStr: @""
                                         albumId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    //if ([dic[@"result"] intValue] == 1) {
                    NSString *res = (NSString *)dic[@"result"];
                    
                    if ([res isEqualToString:@"SYSTEM_OK"]) {
                        self.data = [dic[@"data"] mutableCopy];
                        [self initialValueSetup];
                        [self.firstCategoryCollectionView reloadData];
                        [self.secondCategoryCollectionView reloadData];
//                        [self.weatherCollectionView reloadData];
//                        [self.moodCollectionView reloadData];
                        [self retrieveAlbumIndex];
                        [self checkCreatePointTask];
                    } else if (dic[@"message"] != nil) {
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

- (void)checkCreatePointTask {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL create_free_album = [[defaults objectForKey: @"create_free_album"] boolValue];
    NSLog(@"Check whether getting Download Template point or not");
    NSLog(@"create_free_album: %d", (int)create_free_album);
    
    if (create_free_album) {
        NSLog(@"Get the First Time Creating Album Point Already");
    } else {
        NSLog(@"Haven't got the point of creating album for first time");
        [self checkPoint];
    }
}

- (void)checkPoint {
    NSLog(@"checkPoint");
    //[wTools ShowMBProgressHUD];
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI doTask2: [wTools getUserID]
                                       token: [wTools getUserToken]
                                    task_for: @"create_free_album"
                                    platform: @"apple"
                                        type: @"album"
                                     type_id: self.albumId];
        
        NSLog(@"User ID: %@", [wTools getUserID]);
        NSLog(@"Token: %@", [wTools getUserToken]);
        NSLog(@"Task_For: %@", @"collect_free_album");
        NSLog(@"Album ID: %@", self.albumId);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[wTools HideMBProgressHUD];
            if (response != nil) {
                NSLog(@"response from doTask2: %@", response);
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"AlbumSettingViewController");
                    NSLog(@"checkPoint");
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"doTask2"
                                         jsonStr: @""
                                         albumId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    NSLog(@"data: %@", data);
                    [wself processCheckPoint:data];
                }
            }
        });
    });
}

- (void)processCheckPoint:(NSDictionary *)data {
    if ([data[@"result"] intValue] == 1) {
        missionTopicStr = data[@"data"][@"task"][@"name"];
        NSLog(@"name: %@", missionTopicStr);
        
        rewardType = data[@"data"][@"task"][@"reward"];
        NSLog(@"reward type: %@", rewardType);
        
        rewardValue = data[@"data"][@"task"][@"reward_value"];
        NSLog(@"reward value: %@", rewardValue);
        
        eventUrl = data[@"data"][@"event"][@"url"];
        NSLog(@"event: %@", eventUrl);
        
        restriction = data[@"data"][@"task"][@"restriction"];
        NSLog(@"restriction: %@", restriction);
        
        restrictionValue = data[@"data"][@"task"][@"restriction_value"];
        NSLog(@"restrictionValue: %@", restrictionValue);
        
        numberOfCompleted = [data[@"data"][@"task"][@"numberofcompleted"] unsignedIntegerValue];
        NSLog(@"numberOfCompleted: %lu", (unsigned long)numberOfCompleted);
        
        [self showTaskAlertView];
        [self getUrPoints];
        //[self getPointStore];
    } else if ([data[@"result"] intValue] == 2) {
        NSLog(@"message: %@", data[@"message"]);
        // Save data for creating album first time
        BOOL create_free_album = YES;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject: [NSNumber numberWithBool: create_free_album]  forKey: @"create_free_album"];
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
                    NSLog(@"AlbumSettingViewController");
                    NSLog(@"getUrPoints");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"geturpoints"
                                         jsonStr: @""
                                         albumId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    if ([dic[@"result"] intValue] == 1) {
                        NSLog(@"dic result boolValue is 1");
                        if ([wTools objectExists: dic[@"data"]]) {
                            NSInteger point = [dic[@"data"] integerValue];
                            //NSLog(@"point: %ld", (long)point);
                            [userPrefs setObject: [NSNumber numberWithInteger: point] forKey: @"pPoint"];
                            [userPrefs synchronize];
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
            }
        });
    });
}

#pragma mark - Custom AlertView for Getting Point
- (void)showTaskAlertView {
    NSLog(@"Show Alert View");
    // Custom AlertView shows up when getting the point
    alertTaskView = [[OldCustomAlertView alloc] init];
    [alertTaskView setContainerView: [self createPointView]];
    [alertTaskView setButtonTitles: [NSMutableArray arrayWithObject: @"確     認"]];
    [alertTaskView setUseMotionEffects: true];
    [alertTaskView show];
}

- (UIView *)createPointView {
    NSLog(@"createPointView");
    UIView *pointView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 250, 250)];
    
    // Mission Topic Label
    UILabel *missionTopicLabel = [[UILabel alloc] initWithFrame: CGRectMake(10, 15, 200, 10)];
    //missionTopicLabel.text = @"收藏相本得點";
    
    if ([wTools objectExists: missionTopicStr]) {
        missionTopicLabel.text = missionTopicStr;
    }
    
    NSLog(@"Topic Label Text: %@", missionTopicStr);
    [pointView addSubview: missionTopicLabel];
    
    if ([restriction isEqualToString: @"personal"]) {
        UILabel *restrictionLabel = [[UILabel alloc] initWithFrame: CGRectMake(10, 45, 200, 10)];
        restrictionLabel.textColor = [UIColor firstGrey];
        restrictionLabel.text = [NSString stringWithFormat: @"次數：%lu / %@", (unsigned long)numberOfCompleted, restrictionValue];
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
    
    if ([wTools objectExists: rewardValue]) {
        messageLabel.text = [NSString stringWithFormat: @"%@%@%@", congratulate, rewardValue, end];
    }
    
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
    if (![wTools objectExists: eventUrl]) {
        return;
    }
    //NSString *activityLink = @"http://www.apple.com";
    NSString *activityLink = eventUrl;
    
    NSURL *url = [NSURL URLWithString: activityLink];
    
    // Close for present safari view controller, otherwise alertView will hide the background
    [alertTaskView close];
    
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL: url entersReaderIfAvailable: NO];
    safariVC.delegate = self;
    safariVC.preferredBarTintColor = [UIColor whiteColor];
    [self presentViewController: safariVC animated: YES completion: nil];
}

#pragma mark - SFSafariViewController delegate methods
- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    // Done button pressed
    NSLog(@"show");
    [alertTaskView show];
}

#pragma mark -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup Initial Value
- (void)initialValueSetup {
    firstCategoryArray = [NSMutableArray new];
    secondCategoryArray = [NSMutableArray new];
    weatherArray = [NSMutableArray new];
    moodArray = [NSMutableArray new];
    
    self.firstCategoryCollectionView.showsHorizontalScrollIndicator = NO;
    self.firstCategoryCollectionView.myLeftMargin = 16;
    self.firstCategoryCollectionView.myRightMargin = 16;
    
    self.secondCategoryCollectionView.showsHorizontalScrollIndicator = NO;
    self.secondCategoryCollectionView.myLeftMargin = 16;
    self.secondCategoryCollectionView.myRightMargin = 16;
    
//    self.weatherCollectionView.showsHorizontalScrollIndicator = NO;
//    self.weatherCollectionView.myLeftMargin = 16;
//    self.weatherCollectionView.myRightMargin = 16;
//
//    self.moodCollectionView.showsHorizontalScrollIndicator = NO;
//    self.moodCollectionView.myLeftMargin = 16;
//    self.moodCollectionView.myRightMargin = 16;
    
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    [self loadUserSettingData];
    [self setupUI2];
    //  for profession member only
    [self processAlbumIndexList];
    isModified = NO;
    albumEditBtnPress = NO;
}

- (void)loadUserSettingData {
    NSLog(@"loadUserSettingData");
    // First Category
    //if ([self.data[@"firstpaging"] isKindOfClass: [NSNull class]]) {
    if ([self.data[@"categoryarea_id"] isKindOfClass: [NSNull class]]) {
        NSLog(@"firstpaging is kinf of null class");
        
        for (NSMutableDictionary *d in mdata[@"firstpaging"]) {
            [d setValue: [NSNumber numberWithBool: NO] forKey: @"selected"];
            [firstCategoryArray addObject: d];
        }
        self.secondCategoryCollectionView.hidden = YES;
    } else {
        NSLog(@"firstpaging is not kind of null class");
        NSArray *arr = mdata[@"firstpaging"];
        
        // List setting data
        //int x = [self.data[@"firstpaging"] intValue];
        int x = [self.data[@"categoryarea_id"] intValue];
        NSLog(@"x: %d", x);
        
        // Data for SecondCategory
        sfir = [NSString stringWithFormat: @"%i", x];
        NSLog(@"sfir: %@", sfir);
        NSDictionary *firdata = nil;
        
        if ([wTools objectExists: arr]) {
            for (NSMutableDictionary *dic in arr) {
                NSLog(@"d[id]: %d", [dic[@"id"] intValue]);
                
                int y = [dic[@"id"] intValue];
                NSLog(@"y: %d", y);
                
                if (x == y) {
                    [dic setValue: [NSNumber numberWithBool: YES] forKey: @"selected"];
                    
                    // if setting data is matching with First Category id value
                    // then set dictionary for certain second paging
                    firdata = dic;
                    
                    NSLog(@"firdata: %@", firdata);
                } else {
                    [dic setValue: [NSNumber numberWithBool: NO] forKey: @"selected"];
                }
                [firstCategoryArray addObject: dic];
            }
        }
        // Second Category
        //if (![self.data[@"secondpaging"] isKindOfClass: [NSNull class]]) {
        if (![self.data[@"category_id"] isKindOfClass:[NSNull class]]) {
            //_secondCategoryHeight.constant = 53;
            self.secondCategoryCollectionView.hidden = NO;
            
            NSLog(@"secondpaging is not kind of null class");
            arr = firdata[@"secondpaging"];
            
            //x = [self.data[@"secondpaging"] intValue];
            x = [self.data[@"category_id"] intValue];
            ssec = [NSString stringWithFormat: @"%i", x];
            NSLog(@"ssec: %@", ssec);
            
            if ([wTools objectExists: arr]) {
                for (NSMutableDictionary *dic in arr) {
                    int y = [dic[@"id"] intValue];
                    
                    if (x == y) {
                        [dic setValue: [NSNumber numberWithBool: YES] forKey: @"selected"];
                    } else {
                        [dic setValue: [NSNumber numberWithBool: NO] forKey: @"selected"];
                    }
                    [secondCategoryArray addObject: dic];
                }
            }
            
            [firstCategoryArray removeAllObjects];
            BOOL checkFirst = NO;
            
            if ([wTools objectExists: mdata[@"firstpaging"]]) {
                for (NSMutableDictionary *d in mdata[@"firstpaging"]) {
                    arr = d[@"secondpaging"];
                    checkFirst = NO;
                    
                    if ([wTools objectExists: arr]) {
                        for (NSDictionary *d1 in arr) {
                            int y = [d1[@"id"] intValue];
                            if (x == y) {
                                checkFirst = YES;
                                break;
                            }
                        }
                    }
                    [d setValue: [NSNumber numberWithBool: checkFirst] forKey: @"selected"];
                    
                    if ([wTools objectExists: secondCategoryArray]) {
                        if (checkFirst && secondCategoryArray.count < 1) {
                            if ([wTools objectExists: arr]) {
                                for (NSMutableDictionary *d1 in arr) {
                                    int y = [d1[@"id"] intValue];
                                    [d1 setValue: [NSNumber numberWithBool: x==y] forKey: @"selected"];
                                    [secondCategoryArray addObject:d1];
                                }
                            }
                        }
                        [firstCategoryArray addObject: d];
                    }
                }
            }
        }
    }
    
    if ([wTools objectExists: mdata[@"weather"]]) {
        for (NSMutableDictionary *dic in mdata[@"weather"]) {
            if ([self.data[@"weather"] isEqualToString: dic[@"id"]]) {
                [dic setValue: [NSNumber numberWithBool: YES] forKey: @"selected"];
            } else{
                [dic setValue: [NSNumber numberWithBool: NO] forKey: @"selected"];
            }
            [weatherArray addObject: dic];
        }
    }
    if ([wTools objectExists: mdata[@"mood"]]) {
        for (NSMutableDictionary *dic in mdata[@"mood"]) {
            if ([self.data[@"mood"] isEqualToString: dic[@"id"]]) {
                [dic setValue: [NSNumber numberWithBool: YES] forKey: @"selected"];
            } else{
                [dic setValue: [NSNumber numberWithBool: NO] forKey: @"selected"];
            }
            [moodArray addObject: dic];
        }
    }
}

- (void)setupUI1 {
    // Default set to YES
    self.decriptionRequiredLabel.hidden = YES;
    
    self.navBarView.backgroundColor = [UIColor barColor];
    self.bottomBtnView.backgroundColor = [UIColor colorWithRed: 255.0/255.0
                                                         green: 255.0/255.0
                                                          blue: 255.0/255.0
                                                         alpha: 0.96];
    
    self.privacyBtn.layer.cornerRadius = kCornerRadius;
    
    self.nameBgView.layer.cornerRadius = kCornerRadius;
    self.nameBgView.backgroundColor = [UIColor thirdGrey];
    self.nameBgView.padding = UIEdgeInsetsMake(4, 4, 4, 4);
    self.nameTextField.textColor = [UIColor firstGrey];
    
    if (![self.prefixText isEqual: [NSNull null]]) {
        self.nameTextField.placeholder = self.prefixText;
    }
    self.nameTextField.delegate = self;
    
    self.descriptionTextView.layer.cornerRadius = kCornerRadius;
    self.descriptionTextView.textColor = [UIColor firstGrey];
    self.descriptionTextView.backgroundColor = [UIColor thirdGrey];
    self.descriptionTextView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.locationTextView.layer.cornerRadius = kCornerRadius;
    self.locationTextView.textColor = [UIColor firstGrey];
    self.locationTextView.backgroundColor = [UIColor thirdGrey];
    self.locationTextView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.toAlbumCreationBtn.layer.cornerRadius = kCornerRadius;
    self.toAlbumCreationBtn.layer.borderColor = [UIColor thirdMain].CGColor;
    self.toAlbumCreationBtn.layer.borderWidth = 1.0;
    
    self.pQuestionBtn.hidden = YES;
    self.pPointView.layer.cornerRadius = kCornerRadius;
    
//    self.advanceSettingView.layer.cornerRadius = kCornerRadius;
    self.saveAndExitBtn.layer.cornerRadius = kCornerRadius;
    
    self.plusView.hidden = YES;
    self.professionView.hidden = YES;
    
    self.pPointTextField.leftViewMode = UITextFieldViewModeAlways;
    UILabel *left = [[UILabel alloc] init];
    left.text = @"贊助所需P點:";
    left.font = [UIFont systemFontOfSize:17];
    CGSize s = [left.text sizeWithAttributes:@{NSFontAttributeName:left.font}];
    left.textAlignment = NSTextAlignmentCenter;
    left.frame = CGRectMake(0, 0, s.width+16, s.height);
    left.textColor = [UIColor hintGrey];
    left.backgroundColor = UIColor.clearColor;
    self.pPointTextField.leftView = left;
    
    [self addProfessionSubmitBtn];
    
}
- (void)setupUI2 {
    NSLog(@"act: %@", self.data[@"act"]);
    NSString *act = self.data[@"act"];
    
    if (self.isNew) {
        act = @"open";
    }
    
    if ([wTools objectExists: act]) {
        if ([act isEqualToString: @"close"]) {
            isPrivate = YES;
        } else if ([act isEqualToString: @"open"]) {
            isPrivate = NO;
        }
    }
    NSLog(@"isPrivate: %d", isPrivate);
    
    if (isPrivate) {
        [self.privacyBtn setImage: [UIImage imageNamed: @"ic200_act_close_pink"] forState: UIControlStateNormal];
        self.privacyLabel.textColor = [UIColor secondGrey];
        self.privacyLabel.text = @"當前隱私權為關閉";
        
        self.nameRequiredLabel.hidden = YES;
        self.decriptionRequiredLabel.hidden = YES;
        self.mainCategoryRequiredLabel.hidden = YES;
        self.subCategoryRequiredLabel.hidden = YES;
    } else {
        [self.privacyBtn setImage: [UIImage imageNamed: @"ic200_act_open_white"] forState: UIControlStateNormal];
        self.privacyLabel.textColor = [UIColor firstMain];
        self.privacyLabel.text = @"當前隱私權為開啟";
        
        self.nameRequiredLabel.hidden = NO;
        //self.decriptionRequiredLabel.hidden = NO;
        self.decriptionRequiredLabel.hidden = YES;
        self.mainCategoryRequiredLabel.hidden = NO;
        self.subCategoryRequiredLabel.hidden = NO;
    }
    NSLog(@"self.data: %@", self.data);
    
//    if ([self.data[@"title"] isEqual: [NSNull null]]) {
//        self.nameTextField.text = @"";
//    } else {
//        self.nameTextField.text = self.data[@"title"];
//    }
    
    if ([self.data[@"name"] isEqual: [NSNull null]]) {
        self.nameTextField.text = @"";
    } else {
        self.nameTextField.text = self.data[@"name"];
    }
    oldName = self.nameTextField.text;        
    
    if ([self.data[@"description"] isEqual: [NSNull null]]) {
        self.descriptionTextView.text = @"";
    } else {
        self.descriptionTextView.text = self.data[@"description"];
    }
    oldDescription = self.descriptionTextView.text;
    
    if ([self.data[@"location"] isEqual: [NSNull null]]) {
        self.locationTextView.text = @"";
    } else {
        self.locationTextView.text = self.data[@"location"];
    }
    oldLocation = self.locationTextView.text;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSLog(@"");
    NSLog(@"profile: %@", [defaults objectForKey: @"profile"]);
    NSLog(@"profile creative: %d", [[defaults objectForKey: @"profile"][@"creative"] boolValue]);
    NSLog(@"");
    
    // Change Setup to Default Hidden NO
    /*
    //BOOL isCreator = [[defaults objectForKey: @"creator"] boolValue];
    BOOL isCreator = [[defaults objectForKey: @"profile"][@"creative"] boolValue];
    
    NSLog(@"isCreator: %d", isCreator);
    
    if (isCreator) {
        self.pPointView.hidden = NO;
    } else {
        self.pPointView.hidden = YES;
    }
    */
    
    // Default Setup is NO
    self.pPointView.hidden = NO;
    
    if ([self.data[@"point"] isEqual: [NSNull null]]) {
        self.pPointTextField.text = [NSString stringWithFormat: @"0"];
    } else {
        self.pPointTextField.text = [NSString stringWithFormat: @"%d", [self.data[@"point"] intValue]];
    }
    oldPoint = self.pPointTextField.text;
    
    /*
    UIToolbar *numberToolBar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, 0, 320, 40)];
    numberToolBar.barStyle = UIBarStyleDefault;
    numberToolBar.items = [NSArray arrayWithObjects:
                           //[[UIBarButtonItem alloc] initWithTitle: @"取消" style: UIBarButtonItemStylePlain target: self action: @selector(cancelNumberPad)],
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil],
                           [[UIBarButtonItem alloc] initWithTitle: @"完成" style: UIBarButtonItemStyleDone target: self action: @selector(doneNumberPad)] ,nil];
    
    //[self.pPointTextField sizeToFit];
    self.pPointTextField.inputAccessoryView = numberToolBar;
    */
    
    NSLog(@"usergrade: %@", mdata[@"usergrade"]);
    
//    if ([mdata[@"usergrade"] isEqualToString: @"profession"]) {
//        self.advanceLayout.hidden = NO;
//        self.advancedLineView.hidden = NO;
//    } else {
//        self.advanceLayout.hidden = YES;
//        self.advancedLineView.hidden = YES;
//    }
    
//    oldAdvancedStr = self.advancedTextField.text;
    //self.plusMemberHeight.constant = 0;
    //self.professionMemberHeight.constant = 0;
    
    if (mdata[@"usergrade"]) {
        NSString *user = mdata[@"usergrade"];
        if (![user isEqualToString:@"free"]) {
            BOOL n = [self isDisplayCollectNum];
            self.sponsorCountON.selected = n;
            self.sponsorCountOFF.selected = !n;
            BOOL c = [self isDisplayCollectReward];
            self.sponsorDescON.selected = c;
            self.sponsorDescOFF.selected = !c;
            self.sponsorDesc.text = [self getRewardDesc];
            self.sponsorDesc.hidden = !c ;//&& (_sponsorDesc.text.length < 1);
            self.plusView.hidden = NO;
            //self.plusMemberHeight.constant = c? 280: 208;
                
            if ([user isEqualToString:@"profession"]) {
                self.plusView.hidden = NO;
                self.professionView.hidden = NO;
                //self.professionMemberHeight.constant = 200;
            }
            [self.plusView setNeedsLayout];
            [self.backgroundLayout setNeedsLayout];
        }
        
    }
    NSLog(@"");
}

- (void)processAlbumIndexList {
    
}

- (void)doneNumberPad {
    NSLog(@"doneNumberPad");
    [self.pPointTextField resignFirstResponder];
}

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    NSLog(@"numberOfItemsInSection");
    NSInteger numberOfItems = 0;
    
    if (collectionView == self.firstCategoryCollectionView) {
        NSLog(@"collectionView == self.firstCategoryCollectionView");
        numberOfItems = firstCategoryArray.count;
        NSLog(@"numberOfItems: %ld", (long)numberOfItems);
    } else if (collectionView == self.secondCategoryCollectionView) {
        NSLog(@"collectionView == secondCategoryCollectionView");
        numberOfItems = secondCategoryArray.count;
        NSLog(@"numberOfItems: %ld", (long)numberOfItems);
    }
//    else if (collectionView == self.weatherCollectionView) {
//        NSLog(@"collectionView == self.weatherCollectionView");
//        numberOfItems = weatherArray.count;
//    } else if (collectionView == self.moodCollectionView) {
//        NSLog(@"collectionView == self.moodCollectionView");
//        numberOfItems = moodArray.count;
//    }
    
    NSLog(@"numberOfItems: %ld", (long)numberOfItems);
    
    return numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForItemAtIndexPath");
    UICollectionViewCell *cell;
    
    if (collectionView == self.firstCategoryCollectionView) {
        NSLog(@"");
        NSLog(@"collectionView == self.firstCategoryCollectionView");
        
        cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"FirstCategoryCell" forIndexPath: indexPath];
        cell.layer.cornerRadius = kCornerRadius;
        
        UILabel *textLabel = (UILabel *)[cell viewWithTag: 100];
        if ([wTools objectExists: firstCategoryArray[indexPath.row][@"name"]]) {
            textLabel.text = firstCategoryArray[indexPath.row][@"name"];
        }
        NSIndexPath *selectedIndexPath;
        
        if ([wTools objectExists: firstCategoryArray[indexPath.row][@"selected"]]) {
            if ([firstCategoryArray[indexPath.row][@"selected"] boolValue]) {
                selectedIndexPath = indexPath;
                cell.layer.backgroundColor = [UIColor thirdMain].CGColor;
            } else {
                cell.layer.backgroundColor = [UIColor thirdGrey].CGColor;
            }
        }
        //[collectionView scrollToItemAtIndexPath: indexPath atScrollPosition: UICollectionViewScrollPositionNone animated: NO];
    } else if (collectionView == self.secondCategoryCollectionView) {
        NSLog(@"");
        NSLog(@"collectionView == self.secondCategoryCollectionView");
        
        cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SecondCategoryCell" forIndexPath: indexPath];
        cell.layer.cornerRadius = kCornerRadius;
        
        UILabel *textLabel = (UILabel *)[cell viewWithTag: 100];
        if ([wTools objectExists: secondCategoryArray[indexPath.row][@"name"]]) {
            textLabel.text = secondCategoryArray[indexPath.row][@"name"];
        }
        NSIndexPath *selectedIndexPath;
        
        if ([wTools objectExists: secondCategoryArray[indexPath.row][@"selected"]]) {
            if ([secondCategoryArray[indexPath.row][@"selected"] boolValue]) {
                selectedIndexPath = indexPath;
                cell.layer.backgroundColor = [UIColor thirdMain].CGColor;
            } else {
                cell.layer.backgroundColor = [UIColor thirdGrey].CGColor;
            }
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectItemAtIndexPath");
    isModified = YES;
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath: indexPath];
    
    if (collectionView == self.firstCategoryCollectionView) {
        NSLog(@"collectionView == self.firstCategoryCollectionView");
        cell.layer.backgroundColor = [UIColor thirdMain].CGColor;
        
        if ([wTools objectExists: firstCategoryArray]) {
            for (NSMutableDictionary *d in firstCategoryArray) {
                if ([d[@"selected"] boolValue]) {
                    [d setObject: [NSNumber numberWithBool: NO] forKey: @"selected"];
                }
            }
            firstCategoryArray[indexPath.row][@"selected"] = [NSNumber numberWithBool: YES];
            
            for (NSDictionary *d in firstCategoryArray) {
                NSLog(@"selected: %@", d[@"selected"]);
            }
            [self.firstCategoryCollectionView reloadData];
            //self.secondCategoryHeight.constant = 53;
            self.secondCategoryCollectionView.hidden = NO;
            
            [secondCategoryArray removeAllObjects];
            
            for (NSMutableDictionary *d in firstCategoryArray[indexPath.row][@"secondpaging"]) {
                [d setValue: [NSNumber numberWithBool: NO] forKey: @"selected"];
                [secondCategoryArray addObject: d];
            }
            NSLog(@"secondCategoryArray: %@", secondCategoryArray);
            [self.secondCategoryCollectionView reloadData];
        }
    } else if (collectionView == self.secondCategoryCollectionView) {
        NSLog(@"collectionView == self.secondCategoryCollectionView");
        cell.layer.backgroundColor = [UIColor thirdMain].CGColor;
        
        if ([wTools objectExists: secondCategoryArray]) {
            for (NSMutableDictionary *d in secondCategoryArray) {
                if ([d[@"selected"] boolValue]) {
                    [d setObject: [NSNumber numberWithBool: NO] forKey: @"selected"];
                }
            }
            secondCategoryArray[indexPath.row][@"selected"] = [NSNumber numberWithBool: YES];
            
            for (NSDictionary *d in secondCategoryArray) {
                NSLog(@"selected: %@", d[@"selected"]);
            }
            [self.secondCategoryCollectionView reloadData];
        }
    }
}

#pragma mark - Touches Detection
- (void)touchesBegan:(NSSet<UITouch *> *)touches
           withEvent:(UIEvent *)event {
    NSLog(@"");
    NSLog(@"touchesBegan");
    [self.view endEditing: YES];
    
    CGPoint location = [[touches anyObject] locationInView: self.view];
    CGRect fingerRect = CGRectMake(location.x - 5, location.y - 5, 10, 10);
    
    for (UIView *view in self.view.subviews) {
        CGRect subviewFrame = view.frame;
        
        if (CGRectIntersectsRect(fingerRect, subviewFrame)) {
            NSLog(@"finally touched view: %@", view);
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches
           withEvent:(UIEvent *)event {
    NSLog(@"");
    NSLog(@"touchesEnded");
}

#pragma mark - IBAction Methods
- (IBAction)submitInsertAlbum:(id)sender {
    NSString *nid = self.advTextField.text;
    
    if (nid && nid.length > 0) {
        [self addAlbumIndexWithAid:nid];
    }
    [self.advTextField resignFirstResponder];
}

- (IBAction)scanCodeForAdvanceSetting:(id)sender {
    NSLog(@"scanCodeForAdvanceSetting");
    
    ScanCodeForAdvancedSettingViewController *scanCodeFASVC = [[UIStoryboard storyboardWithName: @"Main" bundle: nil] instantiateViewControllerWithIdentifier: @"ScanCodeForAdvancedSettingViewController"];
    
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [appDelegate.myNav popViewControllerAnimated: YES];
//    [appDelegate.myNav pushViewController: scanCodeFASVC animated: YES];
    
    [self presentViewController:scanCodeFASVC animated:YES completion:nil];
    __weak typeof(self) wself = self;
    
    scanCodeFASVC.finishedBlock = ^(NSArray *anyids) {
        [wself processScanResult: anyids];
    };
}

- (IBAction)privacyBtnPress:(id)sender {
    isModified = YES;
    isPrivate = !isPrivate;
    
    NSLog(@"isPrivate: %d", isPrivate);
    
    if (self.hasImage) {
        if (isPrivate) {
            [self.privacyBtn setImage: [UIImage imageNamed: @"ic200_act_close_pink"] forState: UIControlStateNormal];
            self.privacyLabel.textColor = [UIColor secondGrey];
            self.privacyLabel.text = @"當前隱私權為關閉";
            
            self.nameRequiredLabel.hidden = YES;
            self.decriptionRequiredLabel.hidden = YES;
            self.mainCategoryRequiredLabel.hidden = YES;
            self.subCategoryRequiredLabel.hidden = YES;
        } else {
            [self.privacyBtn setImage: [UIImage imageNamed: @"ic200_act_open_white"] forState: UIControlStateNormal];
            self.privacyLabel.textColor = [UIColor firstMain];
            self.privacyLabel.text = @"當前隱私權為開啟";
            
            self.nameRequiredLabel.hidden = NO;
            //self.decriptionRequiredLabel.hidden = NO;
            self.decriptionRequiredLabel.hidden = YES;
            self.mainCategoryRequiredLabel.hidden = NO;
            self.subCategoryRequiredLabel.hidden = NO;
        }
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject: [NSNumber numberWithBool: YES] forKey: @"privacyStatusChange"];
        [defaults synchronize];
    } else {
        [self warnToastWithMessage:@"你的作品沒有內容"];
    }
}

- (IBAction)pQuestionBtnPress:(id)sender {
    NSString *msg = @"設 定 p 點 可 以 跟 喜 歡 你 的 粉 絲 索 取 贊 助 ， 須 完 成 專 案 註 冊 申 請 並 信 件 認 證 後 ， 即 可 開 啟 此 功 能 ( 開 通 後 A P P 要 重 新 開 啟 )";
    [self showCustomAlert: msg];
}

- (IBAction)backBtnPress:(id)sender {
    [self checkModified];
    
    if (isModified) {
        [self showModifiedCustomAlert: @"資 訊 有 變 動 ， 要 直 接 離 開 嗎 ?"];
    } else {
        //[self.navigationController popViewControllerAnimated: YES];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.myNav popViewControllerAnimated: YES];
    }
}

- (IBAction)toAlbumCreationVC:(id)sender {
    NSLog(@"");
    NSLog(@"toAlbumCreationVC");
    albumEditBtnPress = YES;
    
    [self checkModified];
    
    if (isModified) {
        NSLog(@"isModified is YES");
        NSLog(@"isModified: %d", isModified);
        [self showCustomAlertForEditing: @"資 訊 有 變 動 ， 要 先 保 存 嗎 ?"];
    } else {
        NSLog(@"isModified is NO");
        NSLog(@"isModified: %d", isModified);
        NSLog(@"self.fromVC: %@", self.fromVC);
        [self checkBeforeGoingToAlbumCreationVC];
    }
}

- (void)checkBeforeGoingToAlbumCreationVC {
    NSLog(@"checkBeforeGoingToAlbumCreationVC");
    NSLog(@"self.fromVC: %@", self.fromVC);
    
    if ([self.fromVC isEqualToString: @"AlbumCollectionVC"] || [self.fromVC isEqualToString: @"AlbumDetailVC"]) {
        NSLog(@"self.fromVC is AlbumColletionVC");
        AlbumCreationViewController *acVC = [[UIStoryboard storyboardWithName: @"AlbumCreationVC" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumCreationViewController"];
        //acVC.selectrow = [wTools userbook];
        acVC.albumid = self.albumId;
        acVC.templateid = [NSString stringWithFormat:@"%@", self.templateId];
        acVC.shareCollection = self.shareCollection;
        acVC.postMode = NO;
        acVC.fromVC = self.fromVC;
        acVC.isNew = NO;
        acVC.userIdentity = self.userIdentity;
        
        NSLog(@"self.fromVC: %@", self.fromVC);
        
        if ([self.templateId isEqualToString:@"0"]) {
            acVC.booktype = 0;
            acVC.choice = @"Fast";
        } else {
            acVC.booktype = 1000;
            acVC.choice = @"Template";
        }
        
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.myNav pushViewController: acVC animated: YES];
    } else if ([self.fromVC isEqualToString: @"AlbumCreationVC"]) {
        NSLog(@"self.fromVC is AlbumCreationVC");
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.myNav popViewControllerAnimated: YES];
    }
}

- (IBAction)saveAndExit:(id)sender {
    [self saveData];
}

- (IBAction)sponsingSettingSwitch:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (!btn.selected) {
        if (btn == self.sponsorCountON) {
            self.sponsorCountON.selected = YES;
            self.sponsorCountOFF.selected = NO;
        } else {
            self.sponsorCountON.selected = NO;
            self.sponsorCountOFF.selected = YES;
        }
    }
}

- (IBAction)sponsingResponseSettingSwitch:(id)sender{
    NSLog(@"%@", sender);
    UIButton *btn = (UIButton *)sender;
    
    if (!btn.selected) {
        if (btn == self.sponsorDescON) {
            if ([self getCurrentSetPPoint] < 3) {
                [self warnToastWithMessage:@"贊助條件至少3P才能開啟"];
                self.sponsorDescON.selected = NO;
                self.sponsorDescOFF.selected = YES;
                return;
            } else {
                self.sponsorDescON.selected = YES;
                self.sponsorDescOFF.selected = NO;
                //self.plusMemberHeight.constant = 280;
                self.sponsorDesc.hidden = NO;
                
                [self showCustomAlert:SponsorRemindMsg];
            }
        } else {
            self.sponsorDescON.selected = NO;
            self.sponsorDescOFF.selected = YES;
            //self.plusMemberHeight.constant = 208;
            self.sponsorDesc.hidden = YES;
            [self.sponsorDesc resignFirstResponder];
        }
        [self.plusView setNeedsLayout];
        //btn.selected = !btn.selected;
    }
}

- (void)postAlbum {
    NSLog(@"postAlbum");
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason);
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI switchstatusofcontribution: [wTools getUserID]
                                                          token: [wTools getUserToken]
                                                       event_id: self.eventId
                                                       album_id: self.albumId];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[wTools HideMBProgressHUD];
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
                //NSLog(@"%@", response);
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"TestReadBookViewController");
                    NSLog(@"postAlbum");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"switchstatusofcontribution"
                                         jsonStr: @""
                                         albumId: self.albumId];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        NSLog(@"post album success");
                        if ([wTools objectExists: dic[@"data"][@"event"][@"contributionstatus"]]) {
                            int contributionCheck = [dic[@"data"][@"event"][@"contributionstatus"] boolValue];
                            NSLog(@"contributionCheck: %d", contributionCheck);
                            [self remindToastWithMessage:@"投稿成功"];
                        }
                        if ([wTools objectExists: self.albumId]) {
                            [self ToRetrievealbumpViewControlleralbumid: self.albumId];
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
            }
        });
    });
}

- (void)checkModified {
    if ([wTools objectExists: oldName]) {
        if (![oldName isEqualToString: self.nameTextField.text]) {
            isModified = YES;
        }
    }
    if ([wTools objectExists: oldDescription]) {
        if (![oldDescription isEqualToString: self.descriptionTextView.text]) {
            isModified = YES;
        }
    }
    if ([wTools objectExists: oldLocation]) {
        if (![oldLocation isEqualToString: self.locationTextView.text]) {
            isModified = YES;
        }
    }
    if ([wTools objectExists: oldPoint]) {
        if (![oldPoint isEqualToString: self.pPointTextField.text]) {
            isModified = YES;
        }
    }
}

- (void)processScanResult:(NSArray *)anyIds {
    NSLog(@"%@",anyIds);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (anyIds == nil || anyIds.count < 1) {
            [self remindToastWithMessage:@"掃描QR code未取得結果"];
            return;
        }
        NSString *nid = (NSString *)[anyIds lastObject];
        if ([wTools objectExists: nid]) {
            self.advTextField.text = nid;
        }
    });
    
}

#pragma mark -
- (BOOL)isDisplayCollectNum {
    id d = self.data[@"display_num_of_collect"];
    if (d && [d isKindOfClass:[NSNumber class]]) {
        return [d boolValue];
    }
    return NO;
}

- (BOOL)isDisplayCollectReward{
    id d = self.data[@"reward_after_collect"];
    if (d && [d isKindOfClass:[NSNumber class]]) {
        return [d boolValue];
    }
    return NO;
}

- (NSString *)getRewardDesc {
    id desc = self.data[@"reward_description"];
    if (desc && [desc isKindOfClass:[NSString class]])
        return self.data[@"reward_description"];
    
    return @"";
}

- (int)getCurrentSetPPoint {
    NSString *pStr = self.pPointTextField.text;
    return [pStr intValue];
}

#pragma mark - Get Server Data
- (void)saveData {
    NSLog(@"");
    NSLog(@"saveData");
    
    if (firstCategoryArray != nil) {
        NSLog(@"firstCategoryArray != nil");
        
        for (NSDictionary *d in firstCategoryArray) {
            if ([d[@"selected"] boolValue]) {
                NSLog(@"d id: %@", d[@"id"]);
                firstPaging = d[@"id"];
                NSLog(@"firstPaging: %@", firstPaging);
            }
        }
    }
    NSLog(@"");
    
    if (secondCategoryArray != nil) {
        NSLog(@"secondCategoryArray != nil");
        
        for (NSDictionary *d in secondCategoryArray) {
            if ([d[@"selected"] boolValue]) {
                NSLog(@"d id: %@", d[@"id"]);
                secondPaging = d[@"id"];
                NSLog(@"secondPaging: %@", secondPaging);
            }
        }
    }
    NSLog(@"");
    
    if (weatherArray != nil) {
        NSLog(@"weatherArray != nil");
        
        for (NSDictionary *d in weatherArray) {
            if ([d[@"selected"] intValue] == 1) {
                NSLog(@"weatherArray");
                NSLog(@"d id: %@", d[@"id"]);
                weatherStr = d[@"id"];
            }
        }
    }
    NSLog(@"");
    
    if (moodArray != nil) {
        NSLog(@"moodArray != nil");
        
        for (NSDictionary *d in moodArray) {
            if ([d[@"selected"] intValue] == 1) {
                NSLog(@"moodArray");
                NSLog(@"d id: %@", d[@"id"]);
                moodStr = d[@"id"];
            }
        }
    }
    NSLog(@"");
    
    //NSLog(@"self.nameTextView.text: %@", self.nameTextView.text);
    NSLog(@"self.nameTextField.text: %@", self.nameTextField.text);
    NSLog(@"self.descriptionTextView.text: %@", self.descriptionTextView.text);
    NSLog(@"self.locationTextView.text: %@", self.locationTextView.text);
    
    NSString *pStr = self.pPointTextField.text;
    
    NSLog(@"p point: %d", [pStr intValue]);
    
    if (isPrivate) {
        sact = @"close";
    } else {
        sact = @"open";
    }
    NSLog(@"sact: %@", sact);
    //NSLog(@"self.nameTextView.text: %@", self.nameTextView.text);
    NSLog(@"self.nameTextField.text: %@", self.nameTextField.text);
    NSLog(@"self.descriptionTextView.text: %@", self.descriptionTextView.text);
    NSLog(@"firstPaging: %@", firstPaging);
    NSLog(@"secondPaging: %@", secondPaging);
    
    if ([sact isEqualToString: @"open"]) {
        if ([self.nameTextField.text isEqualToString: @""]) {
            [self warnToastWithMessage:@"名稱要記得填寫"];
            return;
        }
        if (firstPaging == nil) {
            [self warnToastWithMessage:@"主類別還沒選"];
            return;
        }
        if (secondPaging == nil) {
            [self warnToastWithMessage:@"子類別還沒選"];
            return;
        }
    }
    NSLog(@"");
    NSLog(@"pStr.length: %lu", (unsigned long)pStr.length);
    
    if (pStr.length > 1) {
        NSLog(@"pStr: %@", pStr);
        
        if ([pStr hasPrefix: @"0"]) {
            NSLog(@"pStr as prefix 0");
            [self warnToastWithMessage:@"第一位數不能為0"];
            return;
        }
    }
    
    if ([pStr intValue] > 0 && [pStr intValue] < 3) {
        [self warnToastWithMessage:@"至少3P點"];
        return;
    }
    
    if (self.postMode) {
        if ([sact isEqualToString: @"close"]) {
            [self warnToastWithMessage:@"隱私打開才能投稿作品"];
            return;
        }
    }
    // Sending Data Section
    NSMutableDictionary *settingsDic = [NSMutableDictionary new];
    [settingsDic setObject: sact forKey: @"act"];
    //[settingsDic setObject: self.nameTextView.text forKey: @"title"];
    //[settingsDic setObject: self.nameTextField.text forKey: @"title"];
    [settingsDic setObject: self.nameTextField.text forKey: @"name"];
    [settingsDic setObject: self.descriptionTextView.text forKey: @"description"];
    [settingsDic setObject: self.locationTextView.text forKey:@"location"];
    
    NSLog(@"check firstPaging");
    
    if (![firstPaging isKindOfClass: [NSNull class]]) {
        //[settingsDic setObject: [NSNumber numberWithInt: [firstPaging intValue]] forKey: @"firstpaging"];
        [settingsDic setObject: [NSNumber numberWithInt: [firstPaging intValue]] forKey: @"categoryarea_id"];
    }
    
    NSLog(@"check secondPaging");
    
    if (![secondPaging isKindOfClass: [NSNull class]]) {
        //[settingsDic setObject: [NSNumber numberWithInt: [secondPaging intValue]] forKey: @"secondpaging"];
        [settingsDic setObject: [NSNumber numberWithInt: [secondPaging intValue]] forKey: @"category_id"];
    }
    [settingsDic setObject: weatherStr forKey:@"weather"];
    [settingsDic setObject: moodStr forKey:@"mood"];
    [settingsDic setObject: [NSNumber numberWithInt: [pStr intValue]] forKey: @"point"];

    if (![self collectNonfreeMemberOption:settingsDic]) {
        return ;
    }
    NSLog(@"settingsDic: %@", settingsDic);
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: settingsDic options: 0 error: nil];
    NSString *jsonStr = [[NSString alloc] initWithData: jsonData encoding: NSUTF8StringEncoding];
    
    [self callAlbumSettings: jsonStr];
}

//  save settings of plus/profession member
- (BOOL)collectNonfreeMemberOption:(NSMutableDictionary *)settings {
    // check member grade //
    if (mdata[@"usergrade"]) {
        NSString *user = mdata[@"usergrade"];
        if (![user isEqualToString:@"free"]) {
            if (self.sponsorDescON.selected) {
                NSString *desc = self.sponsorDesc.text;
                if (!desc || desc.length < 1) {
                    [self warnToastWithMessage:@"尚未填寫回饋說明"];
                    return NO;
                }
                [settings setObject:desc forKey:@"reward_description"];
                [settings setObject:[NSNumber numberWithBool:YES] forKey:@"reward_after_collect"];
            } else {
                [settings setObject:[NSNumber numberWithBool:NO] forKey:@"reward_after_collect"];
                [settings setObject:@"" forKey:@"reward_description"];
            }
            [settings setObject:[NSNumber numberWithBool:self.sponsorCountON.selected] forKey:@"display_num_of_collect"];
            
            if (self.advTextField.text.length != 0 && ![self.advTextField.text isEqualToString:@" "]){
                [self warnToastWithMessage:@"還有作品編號未加入"];
                return NO;
            }
        }
    }
    return YES;
}

- (void)callAlbumSettings: (NSString *)jsonStr {
    NSLog(@"callAlbumSettings");
    NSLog(@"jsonStr: %@", jsonStr);
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
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){        
        NSLog(@"self.albumId: %@", self.albumId);
        
        NSString *response = [boxAPI albumsettings: [wTools getUserID]
                                             token: [wTools getUserToken]
                                          album_id: wself.albumId
                                          settings: jsonStr];
        
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
                NSLog(@"response from albumsettings: %@", response);
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"AlbumSettingViewController");
                    NSLog(@"callAlbumSettings");
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"albumsettings"
                                         jsonStr: jsonStr
                                         albumId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    [wself processCallAlbumSetting:dic];
                }
            }
        });
    });
}

- (void)processCallAlbumSetting:(NSDictionary *)dic {    
    if ([dic[@"result"] isEqualToString: @"SYSTEM_OK"]) {
        NSLog(@"self.postMode: %d", self.postMode);
        
        if (albumEditBtnPress) {
            NSLog(@"albumEditBtnPress: %d", albumEditBtnPress);
            [self checkBeforeGoingToAlbumCreationVC];
        } else {
            if (self.postMode) {
                [self postAlbum];
            } else {
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                NSLog(@"");
                NSLog(@"appDelegate.myNav.viewControllers: %@", appDelegate.myNav.viewControllers);
                
                for (UIViewController *vc in appDelegate.myNav.viewControllers) {
                    if ([vc isKindOfClass: [AlbumDetailViewController class]]) {
                        NSLog(@"vc is AlbumDetailVC");
                        
                        if ([self.delegate respondsToSelector: @selector(albumSettingViewControllerUpdate:)]) {
                            [self.delegate albumSettingViewControllerUpdate: self];
                        }
                        [appDelegate.myNav popToViewController: vc animated: YES];
                        
                        return;
                    } else if ([vc isKindOfClass: [AlbumCollectionViewController class]]) {
                        NSLog(@"vc is AlbumCollectionVC");
                        if ([self.delegate respondsToSelector: @selector(albumSettingViewControllerUpdate:)]) {
                            [self.delegate albumSettingViewControllerUpdate: self];
                        }
                        [appDelegate.myNav popToViewController: vc animated: YES];
                        
                        return;
                    }
                }
                //AlbumCollectionViewController *albumCollectionVC = [[UIStoryboard storyboardWithName: @"Main" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumCollectionViewController"];
                
                AlbumCollectionViewController *albumCollectionVC = [[UIStoryboard storyboardWithName: @"AlbumCollectionVC" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumCollectionViewController"];
                [appDelegate.myNav pushViewController: albumCollectionVC animated: YES];
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject: [NSNumber numberWithBool: YES] forKey: @"modifyAlbum"];
                [defaults synchronize];
            }
        }
    } else if ([dic[@"result"] isEqualToString: @"SYSTEM_ERROR"]) {
        NSLog(@"失敗： %@", dic[@"message"]);
        if ([wTools objectExists: dic[@"message"]]) {
            [self showCustomErrorAlert: dic[@"message"]];
        } else {
            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
        }
    } else if ([dic[@"result"] isEqualToString: @"USER_ERROR"]) {
        NSLog(@"失敗： %@", dic[@"message"]);
        if ([wTools objectExists: dic[@"message"]]) {
            [self showCustomErrorAlert: dic[@"message"]];
        } else {
            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
        }
    } else if ([dic[@"result"] isEqualToString: @"TOKEN_ERROR"]) {
        [self warnToastWithMessage:@"用戶驗證異常請重新登入"];
        [NSTimer scheduledTimerWithTimeInterval: 1.0
                                         target: self
                                       selector: @selector(logOut)
                                       userInfo: nil
                                        repeats: NO];
    }
}

- (void)logOut {
    [wTools logOut];
}

#pragma mark - Call Protocol
- (void)ToRetrievealbumpViewControlleralbumid:(NSString *)albumid {
    NSLog(@"ToRetrievealbumpViewControlleralbumid");
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
        NSString *response = [boxAPI retrievealbump: albumid
                                                uid: [wTools getUserID]
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
                NSLog(@"response from retrievealbump: %@", response);
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"AlbumSettingViewController");
                    NSLog(@"ToRetrievealbumpViewControlleralbumid");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"retrievealbump"
                                         jsonStr: @""
                                         albumId: albumid];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        NSLog(@"result bool value is YES");
                        if ([wTools objectExists: self.albumId]) {
                            ContentCheckingViewController *contentCheckingVC = [[UIStoryboard storyboardWithName: @"ContentCheckingVC" bundle: nil] instantiateViewControllerWithIdentifier: @"ContentCheckingViewController"];
                            contentCheckingVC.albumId = self.albumId;
                            contentCheckingVC.postMode = self.postMode;
                            contentCheckingVC.specialUrl = self.specialUrl;
                            
                            [self.navigationController pushViewController: contentCheckingVC animated: YES];
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
            }
        });
    });
}

#pragma mark - Custom Alert Method
- (void)showCustomErrorAlert: (NSString *)msg {
    [UIViewController showCustomErrorAlertWithMessage:msg onButtonTouchUpBlock:^(CustomIOSAlertView *customAlertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[customAlertView tag]);
        [customAlertView close];
    }];
}

- (void)showCustomAlertForEditing: (NSString *)msg {
    [self.view endEditing: YES];
    
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    //[alertView setContainerView: [self createContainerViewForEditing: msg]];
    [alertView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"我 知 道 了"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertView.arrangeStyle = @"Horizontal";
    
    [alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"稍後再說", @"好的", nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor whiteColor],nil]];
    [alertView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstGrey], nil]];
    [alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    //alertView.arrangeStyle = @"Vertical";
    
    __weak CustomIOSAlertView *weakAlertView = alertView;
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
        
        [weakAlertView close];
        
        if (buttonIndex == 0) {
            
        } else {
            [self saveData];
        }
    }];
    [alertView setUseMotionEffects: YES];
    [alertView show];
}

- (UIView *)createContainerViewForEditing: (NSString *)msg {
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

- (void)showModifiedCustomAlert: (NSString *)msg {
    [self.view endEditing: YES];
    
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    //[alertView setContainerView: [self createModifiedContainerView: msg]];
    [alertView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"我 知 道 了"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertView.arrangeStyle = @"Horizontal";
    
    [alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"繼續編輯", @"直接離開", nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor whiteColor],nil]];
    [alertView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstGrey], nil]];
    [alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    //alertView.arrangeStyle = @"Vertical";
    
    __weak CustomIOSAlertView *weakAlertView = alertView;
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
        
        [weakAlertView close];
        
        if (buttonIndex == 0) {
            
        } else {
            //[self.navigationController popViewControllerAnimated: YES];
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate.myNav popViewControllerAnimated: YES];
        }
    }];
    [alertView setUseMotionEffects: YES];
    [alertView show];
}

- (UIView *)createModifiedContainerView: (NSString *)msg {
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

- (void)showCustomAlert: (NSString *)msg {
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    //[alertView setContainerView: [self createContainerView: msg]];
    [alertView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
    [alertView setButtonTitles: [NSMutableArray arrayWithObject: @"我 知 道 了"]];
    [alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    [alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondPink]]];
    alertView.arrangeStyle = @"Horizontal";
    
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"稍後再說", @"確定切換", nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    //[alertView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor firstMain],nil]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor whiteColor], nil]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    //alertView.arrangeStyle = @"Vertical";
    
    __weak CustomIOSAlertView *weakAlertView = alertView;
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
        
        [weakAlertView close];
        
        if (buttonIndex == 0) {
            
        } else {
            
        }
    }];
    [alertView setUseMotionEffects: YES];
    [alertView show];
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
    imageView.alpha = 0.4;
    
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

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    selectTextView = textView;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    selectTextView = nil;
}

- (void)textViewDidChange:(UITextView *)textView {
    //NSLog(@"textViewDidChange");
    isModified = YES;
    if ([textView isKindOfClass: [InfoTextView class]]) {
        NSLog(@"InfoTextView");
        
    }
    UITextRange *tp = textView.selectedTextRange;
    CGRect caret = [textView firstRectForRange:tp];
    if (caret.size.width < 1) {
        caret = [textView caretRectForPosition:[textView endOfDocument]];
    }
    
    CGRect r2 = [self.scrollView convertRect:caret fromView:textView];
    
    [self.scrollView scrollRectToVisible:CGRectMake(0, r2.origin.y, self.scrollView.bounds.size.width, r2.size.height) animated:YES];
    
    MyBaseLayout *layout = (MyBaseLayout*)textView.superview;
    [layout setNeedsLayout];
    layout.endLayoutBlock = ^{
        NSRange rg = textView.selectedRange;
        [textView scrollRangeToVisible:rg];
    };
    [self.backgroundLayout setNeedsLayout];
}

#pragma mark - UITextField Delegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"textFieldDidBeginEditing");
    NSLog(@"textField.text: %@", textField.text);
    selectTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"textFieldDidEndEditing");
    NSLog(@"textField.text: %@", textField.text);
    selectTextField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"textFieldShouldReturn");
    NSLog(@"textField.text: %@", textField.text);
    
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
        //[self.descriptionTextView becomeFirstResponder];
        [self.descriptionTextView performSelector: @selector(becomeFirstResponder) withObject: nil afterDelay: 0.0];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    NSLog(@"shouldChangeCharactersInRange");
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    NSString *resultString = [textField.text stringByReplacingCharactersInRange: range
                                                                     withString: string];
    NSLog(@"newLength: %lu", (unsigned long)newLength);
    NSLog(@"resultString: %@", resultString);
    
    if (self.pPointTextField == textField) {
        NSLog(@"self.pPointTextField.text: %@", self.pPointTextField.text);
        
        if ([resultString isEqualToString: @"1"]) {
            self.pPointView.backgroundColor = [UIColor thirdPink];
        } else if ([resultString isEqualToString: @"2"]) {
            self.pPointView.backgroundColor = [UIColor thirdPink];
        } else {
            self.pPointView.backgroundColor = [UIColor thirdGrey];
        }
        
        if (resultString.length > 1) {
            if ([resultString hasPrefix: @"0"]) {
                self.pPointView.backgroundColor = [UIColor thirdPink];
            } else {
                self.pPointView.backgroundColor = [UIColor thirdGrey];
            }
        }
        
        int val = [resultString intValue];
        if (val > 50000){//newLength > 4) {
            //[self warnToastWithMessage:@"贊助P點上限為50,000"];//最多四位數"];
            CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
            style.messageColor = [UIColor whiteColor];
            style.backgroundColor = [UIColor thirdPink];
            
            [self.view makeToast: @"贊助P點上限為50,000"
                        duration: 2.0
                        position: CSToastPositionCenter
                           style: style];
            textField.text = @"50000";
            //[textField resignFirstResponder];
            return NO;
        }
    }
    return YES;
}

// Call this method somewhere in your view controller setup code.
#pragma mark - Notifications for Keyboard
- (void)addKeyboardNotification {
    NSLog(@"");
    NSLog(@"addKeyboardNotification");
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)removeKeyboardNotification {
    NSLog(@"");
    NSLog(@"removeKeyboardNotification");
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIKeyboardDidShowNotification
                                                  object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIKeyboardWillHideNotification
                                                  object: nil];
}

#pragma mark -
// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey: UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    
    UIView *activeField;
    
    if (selectTextView != nil) {
        activeField = selectTextView;
    } else if (selectTextField != nil) {
        activeField = selectTextField;
    }
    NSLog(@"aRect: %@", NSStringFromCGRect(aRect));
    NSLog(@"activeField.frame.origin: %@", NSStringFromCGPoint(activeField.frame.origin));
    
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        NSLog(@"!CGRectContainsPoint aRect activeField.frame.origin");
        CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y - kbSize.height);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    } else {
        CGRect r2 = [self.scrollView convertRect:CGRectMake(0, 0, 16, activeField.frame.size.height) fromView:activeField];
        [self.scrollView scrollRectToVisible:CGRectMake(0, r2.origin.y, self.scrollView.bounds.size.width, r2.size.height) animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - profession user related functions
- (void) addAlbumIndexWithAid:(NSString *)aid {
    NSInteger i = self.albumIndexArray.count;
    if (i >= 20) {
        [self warnToastWithMessage:@"已達上限"];
        return;
    }
    __block typeof(self) wself = self;
    self.advTextField.text = @"";
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSString *response = [boxAPI insertalbumindex:[wTools getUserID]
                                                token:[wTools getUserToken]
                                             album_id:self.albumId
                                                index:aid];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (response != nil) {
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"AlbumSettingViewController");
                    NSLog(@"getAlbumDataOptions");
                    
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                     protocolName: @"insertalbumindex"
                                          jsonStr: @""
                                          albumId: aid];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    NSString *res = (NSString *)dic[@"result"];
                    
                    if ([res isEqualToString:@"SYSTEM_OK"]) {
                        [wself.albumIndexArray addObject:aid];//addObject:@{@"album_id":aid, @"index":[NSNumber numberWithInteger:i+1]}];
                        [wself reloadAlbumIndexList];
                    } else if (dic[@"message"] != nil) {
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

-(void)addProfessionSubmitBtn {
    self.submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.submitBtn.backgroundColor = [UIColor firstMain];
    [self.submitBtn setImage:[UIImage imageNamed:@"icon_creatnewframe_plus"] forState:UIControlStateNormal];
    //UIView *sv = self.advTextField.superview;
    UIView *base = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    self.submitBtn.frame = CGRectMake(4,4,32,32);
    [base setBackgroundColor:[UIColor clearColor]];
    [base addSubview:self.submitBtn];
    self.submitBtn.layer.cornerRadius = 6;
    self.advTextField.rightView = base;
    self.advTextField.rightViewMode = UITextFieldViewModeAlways;
    [self.submitBtn addTarget:self action:@selector(submitInsertAlbum:) forControlEvents:UIControlEventTouchUpInside];
    
    self.advTextField.leftViewMode = UITextFieldViewModeAlways;
    UIView *tleft = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, self.advTextField.frame.size.height)];
    tleft.backgroundColor = UIColor.clearColor;
    self.advTextField.leftView = tleft;
    self.albumIndexArray = [NSMutableArray array];
}

- (void)retrieveAlbumIndex {
    NSArray *alb = self.data[@"albumindex"];
    [self.albumIndexArray removeAllObjects];
    [self.albumIndexArray setArray:alb];
    [self reloadAlbumIndexList];
}

- (void)reloadAlbumIndexList {
    if (self.albslistView.hidden)
        self.albslistView.hidden = NO;
    
    for ( UIView *v in self.albslistView.subviews) {
        [v removeFromSuperview];
    }
    int i = 0;
    for (NSString *t in self.albumIndexArray) {
        //int i1 = [[t objectForKey:@"index"] intValue];
        //NSString *al = [t objectForKey:@"album_id"];
        DelTextField *d = [[DelTextField alloc] initWithFrame:CGRectMake(0, i*40, self.albslistView.frame.size.width, 40) listindex:i text:t source:self delaction:@selector(delAlbumIndexWithInfo:)];
        d.myBottomMargin = 8;
        d.myLeftMargin = 50;
        d.myRightMargin = 0;
        [self.albslistView addSubview:d];
        i++;
    }
    [self.albslistView setNeedsLayout];
    [self.professionView setNeedsLayout];
    [self.backgroundLayout setNeedsLayout];
//    self.backgroundLayout.endLayoutBlock = ^{
//        NSLog(@"backgroundLayout height %f",self.backgroundLayout.frame.size.height);
//    };
}

- (void)deleteAlbumIndexWithfield:(NSString  *)aid {
    if ([wTools objectExists: self.albumIndexArray]) {
        for (NSString *a in self.albumIndexArray) {
            if ([a isEqualToString:aid]){
                [self.albumIndexArray removeObject:a];
                break;
            }
        }
    }
    //int index = field.listIndex; //
    __block typeof(self) wself = self;
    //__block DelTextField *wfield = field;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSString *response = [boxAPI deletealbumindex:[wTools getUserID]
                                                token:[wTools getUserToken]
                                             album_id:self.albumId
                                                index:aid];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (response != nil) {
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"AlbumSettingViewController");
                    NSLog(@"getAlbumDataOptions");
                    
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                     protocolName: @"deletealbumindex"
                                          jsonStr: @""
                                          albumId: aid];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    NSString *res = (NSString *)dic[@"result"];
                    
                    if ([res isEqualToString:@"SYSTEM_OK"]) {
                        //[wfield removeFromSuperview];
                        if ([wTools objectExists: wself.albumIndexArray]) {
                            for (NSString *t in wself.albumIndexArray) {
                                if ([t isEqualToString:aid]) {
                                    [wself.albumIndexArray removeObject:t];
                                    break;
                                }
                            }
                        }
                        [wself reloadAlbumIndexList];
                    } else if (dic[@"message"] != nil) {
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

- (void)delAlbumIndexWithInfo:(DelTextField *)field {
    NSString *q = [NSString stringWithFormat:@"確定刪除 %@？",field.text];
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    [alertView setContentViewWithMsg:q contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
    alertView.arrangeStyle = @"Horizontal";
    [alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"取消", @"刪除", nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor whiteColor],nil]];
    [alertView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstGrey], nil]];
    [alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    
    __weak CustomIOSAlertView *weakAlertView = alertView;
    __block typeof(self) wself = self;
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
        [weakAlertView close];
        
        if (buttonIndex == 1) {
            [wself deleteAlbumIndexWithfield:field.text];
        }
    }];
    [alertView setUseMotionEffects: YES];
    [alertView show];
}

#pragma mark - toast message
- (void)remindToastWithMessage:(NSString *)message {
    CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
    style.messageColor = [UIColor whiteColor];
    style.backgroundColor = [UIColor firstMain];
    
    [self.view makeToast: message
                duration: 2.0
                position: CSToastPositionBottom
                   style: style];
}

- (void)warnToastWithMessage:(NSString *)message {
    CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
    style.messageColor = [UIColor whiteColor];
    style.backgroundColor = [UIColor thirdPink];
    
    [self.view makeToast: message
                duration: 2.0
                position: CSToastPositionBottom
                   style: style];
}

#pragma mark - Custom Method for TimeOut
- (void)showCustomTimeOutAlert: (NSString *)msg
                  protocolName: (NSString *)protocolName
                       jsonStr: (NSString *)jsonStr
                       albumId: (NSString *)albumId {
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
    [alertTimeOutView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor whiteColor],nil]];
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
            if ([protocolName isEqualToString: @"getalbumdataoptions"]) {
                [weakSelf getAlbumDataOptions];
            } else if ([protocolName isEqualToString: @"getalbumsettings"]) {
                [weakSelf getAlbumSettings];
            } else if ([protocolName isEqualToString: @"doTask2"]) {
                [weakSelf checkPoint];
            } else if ([protocolName isEqualToString: @"geturpoints"]) {
                [weakSelf getUrPoints];
            } else if ([protocolName isEqualToString: @"albumsettings"]) {
                [weakSelf callAlbumSettings: jsonStr];
            } else if ([protocolName isEqualToString: @"retrievealbump"]) {
                [weakSelf ToRetrievealbumpViewControlleralbumid: albumId];
            } else if ([protocolName isEqualToString:@"insertalbumindex"]) {
                [weakSelf addAlbumIndexWithAid:albumId];
            } else if ([protocolName isEqualToString:@"deletealbumindex"]) {
                [weakSelf deleteAlbumIndexWithfield:albumId];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
/*
 
 項目內容顯示變化:
 
 
 依接口getalbumdataoptions(32) respond param
 
 
 usergrade=plus(profession)該區域顯示，否則隱藏不佔位
 
 項目內容顯示變化:
 
 
 贊助條件需>=3才能選擇開啟
 
 
 否則顯示toast"贊助條件至少3P" (一般樣式)
 
 項目內容顯示變化:
 
 
 選擇開啟時顯示，否則隱藏不佔位
 
 項目內容顯示變化:
 
 
 依接口getalbumdataoptions(32) respond param
 
 
 usergrade=profession參數顯示或隱藏不佔位
 
profession
 1. get: getalbumsettings. albumindex
 2. add: insertalbumindex
 3. delete: deletealbumindex
增刪都先call API
 https://free.modao.cc/app/rsPJEqdqNcSYkdLfx7w0jFRFxlrKlaA#screen=s05CF9E106B1520519294799
 */
