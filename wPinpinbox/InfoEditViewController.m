 //
//  InfoEditViewController.m
//  wPinpinbox
//
//  Created by David on 4/23/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "InfoEditViewController.h"

//#import <objc/runtime.h>
//#import <objc/message.h>

#import "AsyncImageView.h"
#import "MyLinearLayout.h"
#import "UIColor+Extensions.h"
#import "ChangePwdViewController.h"
#import "ChangeCellPhoneNumberViewController.h"
#import "NSString+emailValidation.h"
#import "UIView+Toast.h"
#import "boxAPI.h"
#import "wTools.h"
#import "CustomIOSAlertView.h"
#import "PhotosViewController.h"
#import "UIImage+Extras.h"
#import "GlobalVars.h"

#import "AppDelegate.h"
#import "LabelAttributeStyle.h"
#import "ChangeInterestsViewController.h"
#import "UIViewController+ErrorAlert.h"


#define kWidthForUpload 720
#define kHeightForUpload 960

@interface InfoEditViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PhotosViewDelegate, UIGestureRecognizerDelegate>
{
    NSDictionary *myData;
    
    UILabel *placeHolderNameLabel;
    UILabel *placeHolderDescriptionLabel;
    
    UITextView *selectTextView;
    UITextField *selectTextField;
    
    NSInteger sextInteger;
    
    UIDatePicker *datePicker;
    NSLocale *datelocale;
    
    UIVisualEffectView *blurEffectView;
    
    UIImage *selectImage;
    
//    BOOL wantToGetInfo;
    BOOL wantToGetNewsLetter;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *topicLabel;
@property (weak, nonatomic) IBOutlet AsyncImageView *headshotImageView;
@property (weak, nonatomic) IBOutlet UIButton *headshotImgBtn;

@property (weak, nonatomic) IBOutlet UITextView *nameTextView;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *creatorNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *CreatorNameTextView;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
//@property (weak, nonatomic) IBOutlet UIView *emailView;
@property (weak, nonatomic) IBOutlet MyLinearLayout *emailView;

@property (weak, nonatomic) IBOutlet UILabel *pwdLabel;
@property (weak, nonatomic) IBOutlet UIButton *pwdChangeBtn;
@property (weak, nonatomic) IBOutlet UILabel *mobileLabel;
@property (weak, nonatomic) IBOutlet UIButton *mobileChangeBtn;

@property (weak, nonatomic) IBOutlet UILabel *interestLabel;
@property (weak, nonatomic) IBOutlet UIButton *interestChangeBtn;

@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UIButton *maleBtn;
@property (weak, nonatomic) IBOutlet UIButton *femaleBtn;
@property (weak, nonatomic) IBOutlet UIButton *privateBtn;

@property (weak, nonatomic) IBOutlet UILabel *birthdayLabel;
@property (weak, nonatomic) IBOutlet UIView *birthdayView;
@property (weak, nonatomic) IBOutlet UITextField *birthdayTextField;

@property (weak, nonatomic) IBOutlet UILabel *communityLabel;
@property (weak, nonatomic) IBOutlet MyLinearLayout *facebookBgView;
@property (weak, nonatomic) IBOutlet MyLinearLayout *facebookView;
@property (weak, nonatomic) IBOutlet UITextField *facebookTextField;

@property (weak, nonatomic) IBOutlet MyLinearLayout *googleBgView;
@property (weak, nonatomic) IBOutlet MyLinearLayout *googleView;
@property (weak, nonatomic) IBOutlet UITextField *googleTextField;

@property (weak, nonatomic) IBOutlet MyLinearLayout *instagramBgView;
@property (weak, nonatomic) IBOutlet MyLinearLayout *instagramView;
@property (weak, nonatomic) IBOutlet UITextField *instagramTextField;

@property (weak, nonatomic) IBOutlet MyLinearLayout *linkedInBgView;
@property (weak, nonatomic) IBOutlet MyLinearLayout *linkedInView;
@property (weak, nonatomic) IBOutlet UITextField *linkedInTextField;

@property (weak, nonatomic) IBOutlet MyLinearLayout *pinterestBgView;
@property (weak, nonatomic) IBOutlet MyLinearLayout *pinterestView;
@property (weak, nonatomic) IBOutlet UITextField *pinterestTextField;

@property (weak, nonatomic) IBOutlet MyLinearLayout *twitterBgView;
@property (weak, nonatomic) IBOutlet MyLinearLayout *twitterView;
@property (weak, nonatomic) IBOutlet UITextField *twitterTextField;

@property (weak, nonatomic) IBOutlet MyLinearLayout *youtubeBgView;
@property (weak, nonatomic) IBOutlet MyLinearLayout *youtubeView;
@property (weak, nonatomic) IBOutlet UITextField *youtubeTextField;

@property (weak, nonatomic) IBOutlet MyLinearLayout *homeBgView;
@property (weak, nonatomic) IBOutlet MyLinearLayout *homeView;
@property (weak, nonatomic) IBOutlet UITextField *homeTextField;

@property (weak, nonatomic) IBOutlet MyLinearLayout *newsLetterCheckView;
@property (weak, nonatomic) IBOutlet UIView *newsLetterCheckSelectionView;
//@property (weak, nonatomic) IBOutlet MyLinearLayout *infoGettingCheckView;
//@property (weak, nonatomic) IBOutlet UIView *infoGettingCheckSelectionView;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;

@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarHeight;

@end

@implementation InfoEditViewController

#pragma mark - View Related Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"InfoEditViewController viewDidLoad");
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.delegate = self;
    
    [self initialValueSetup];
    [self userInterfaceSetup];
    
    [self getProfile];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    for (UIView *view in self.tabBarController.view.subviews) {
        UIButton *btn = (UIButton *)[view viewWithTag: 104];
        btn.hidden = YES;
    }
    [self addKeyboardNotification];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removeKeyboardNotification];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.enabled = NO;
}

- (void)getProfile {
    NSLog(@"getProfile");
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    [wTools ShowMBProgressHUD];
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI getprofile: [userPrefs objectForKey: @"id"] token: [userPrefs objectForKey: @"token"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"MeTabViewController");
                    NSLog(@"getProfile");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getprofile"];                                        
                    //                    [self.refreshControl endRefreshing];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    NSLog(@"responseFromGetProfile != nil");
                    NSLog(@"dic: %@", dic);
                    
                    [wself processProfileResult:dic];
                }
            }
        });
    });
}
- (void)refreshUserInterface {
    self.nameTextView.text = myData[@"nickname"];
    
    if ([self.nameTextView.text isEqualToString: @""]) {
        placeHolderNameLabel.alpha = 1;
    } else {
        placeHolderNameLabel.alpha = 0;
    }
    self.descriptionTextView.text = myData[@"selfdescription"];
    if ([self.descriptionTextView.text isEqualToString: @""]) {
        placeHolderDescriptionLabel.alpha = 1;
    } else {
        placeHolderDescriptionLabel.alpha = 0;
    }
    
    self.CreatorNameTextView.text = myData[@"creative_name"];
    self.emailTextField.text = myData[@"email"];
    sextInteger = [myData[@"gender"] integerValue];
    NSLog(@"sextInteger: %ld", (long)sextInteger);
    
    if (sextInteger == 1) {
        [self.maleBtn setTitleColor: [UIColor blackColor]
                           forState: UIControlStateNormal];
        self.maleBtn.backgroundColor = [UIColor secondMain];
        self.maleBtn.layer.borderWidth = 0;
        
        [self.femaleBtn setTitleColor: [UIColor thirdGrey]
                             forState: UIControlStateNormal];
        self.femaleBtn.backgroundColor = [UIColor clearColor];
        self.femaleBtn.layer.borderColor = [UIColor thirdGrey].CGColor;
        self.femaleBtn.layer.borderWidth = 1.0;
        
        [self.privateBtn setTitleColor: [UIColor thirdGrey]
                              forState: UIControlStateNormal];
        self.privateBtn.backgroundColor = [UIColor clearColor];
        self.privateBtn.layer.borderColor = [UIColor thirdGrey].CGColor;
        self.privateBtn.layer.borderWidth = 1.0;
    } else if (sextInteger == 0) {
        [self.maleBtn setTitleColor: [UIColor thirdGrey]
                           forState: UIControlStateNormal];
        self.maleBtn.backgroundColor = [UIColor clearColor];
        self.maleBtn.layer.borderColor = [UIColor thirdGrey].CGColor;
        self.maleBtn.layer.borderWidth = 1.0;
        
        [self.femaleBtn setTitleColor: [UIColor blackColor]
                             forState: UIControlStateNormal];
        self.femaleBtn.backgroundColor = [UIColor secondMain];
        self.femaleBtn.layer.borderWidth = 0;
        
        [self.privateBtn setTitleColor: [UIColor thirdGrey]
                              forState: UIControlStateNormal];
        self.privateBtn.backgroundColor = [UIColor clearColor];
        self.privateBtn.layer.borderColor = [UIColor thirdGrey].CGColor;
        self.privateBtn.layer.borderWidth = 1.0;
    } else if (sextInteger == 2) {
        [self.maleBtn setTitleColor: [UIColor thirdGrey]
                           forState: UIControlStateNormal];
        self.maleBtn.backgroundColor = [UIColor clearColor];
        self.maleBtn.layer.borderColor = [UIColor thirdGrey].CGColor;
        self.maleBtn.layer.borderWidth = 1.0;
        
        [self.femaleBtn setTitleColor: [UIColor thirdGrey]
                             forState: UIControlStateNormal];
        self.femaleBtn.backgroundColor = [UIColor clearColor];
        self.femaleBtn.layer.borderColor = [UIColor thirdGrey].CGColor;
        self.femaleBtn.layer.borderWidth = 1.0;
        
        [self.privateBtn setTitleColor: [UIColor blackColor]
                              forState: UIControlStateNormal];
        self.privateBtn.backgroundColor = [UIColor secondMain];
        self.privateBtn.layer.borderWidth = 0;
    }
    self.birthdayTextField.text = myData[@"birthday"];
    
    // wantToGetNewsLetter data should get from server    
    wantToGetNewsLetter = [myData[@"newsletter"] boolValue];
    NSLog(@"wantToGetNewsLetter: %d", wantToGetNewsLetter);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkNewsLetterGetting)];
    [self.newsLetterCheckView addGestureRecognizer:tap];
    self.newsLetterCheckSelectionView.layer.cornerRadius = kCornerRadius;
    self.newsLetterCheckSelectionView.layer.borderColor = [UIColor thirdGrey].CGColor;
    self.newsLetterCheckSelectionView.layer.borderWidth = 1.0;
    
    if (wantToGetNewsLetter) {
        self.newsLetterCheckSelectionView.backgroundColor = [UIColor thirdMain];
    } else {
        self.newsLetterCheckSelectionView.backgroundColor = [UIColor clearColor];
    }
}

- (void)checkNewsLetterGetting {
    NSLog(@"checkNewsLetterGetting");
    wantToGetNewsLetter = !wantToGetNewsLetter;
    
    if (wantToGetNewsLetter) {
        self.newsLetterCheckSelectionView.backgroundColor = [UIColor thirdMain];
    } else {
        self.newsLetterCheckSelectionView.backgroundColor = [UIColor clearColor];
    }
}

- (void)processProfileResult:(NSDictionary *)dic {
    if ([dic[@"result"] intValue] == 1) {
        NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *dataIc = [[NSMutableDictionary alloc] initWithDictionary: dic[@"data"] copyItems: YES];
        
        for (NSString *key in [dataIc allKeys]) {
            id objective = [dataIc objectForKey: key];
            
            if ([objective isKindOfClass: [NSNull class]]) {
                [dataIc setObject: @"" forKey: key];
            }
        }
        [userPrefs setValue: dataIc forKey: @"profile"];
        [userPrefs synchronize];
        
        myData = [dataIc mutableCopy];
        
        [self checkSocialData];
        [self refreshUserInterface];
    } else if ([dic[@"result"] intValue] == 0) {
        NSLog(@"失敗：%@",dic[@"message"]);
        [self showCustomErrorAlert: dic[@"message"]];
    } else {
        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
    }
}
#pragma mark - UI Setup Section
- (void)initialValueSetup {
    // Get the profile data
    
    self.navBarView.backgroundColor = [UIColor barColor];
    
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    myData = [userPrefs objectForKey: @"profile"];
    
    NSLog(@"myData: %@", myData);
    
    [LabelAttributeStyle changeGapString: self.topicLabel content: self.topicLabel.text];
    [self.topicLabel sizeToFit];
    self.topicLabel.textColor = [UIColor firstGrey];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    // HeadshotImageView & HeadShotImageButton Setting
    self.headshotImageView.layer.cornerRadius = self.headshotImageView.bounds.size.width / 2;
    self.headshotImageView.clipsToBounds = YES;
    self.headshotImageView.alpha = 0.1;
    
    NSLog(@"mydata profilePic: %@", myData[@"profilepic"]);
    
    if (![myData[@"profilepic"] isKindOfClass: [NSNull class]]) {
        self.headshotImageView.imageURL = [NSURL URLWithString: myData[@"profilepic"]];
    }
    
    [LabelAttributeStyle changeGapString: self.creatorNameLabel content: self.creatorNameLabel.text];
    [self.creatorNameLabel sizeToFit];
    
    [LabelAttributeStyle changeGapString: self.emailLabel content: self.emailLabel.text];
    [self.emailLabel sizeToFit];
    
    [LabelAttributeStyle changeGapString: self.pwdLabel content: self.pwdLabel.text];
    [self.pwdLabel sizeToFit];
    
    [LabelAttributeStyle changeGapString: self.mobileLabel content: self.mobileLabel.text];
    [self.mobileLabel sizeToFit];
    
    [LabelAttributeStyle changeGapString: self.genderLabel content: self.genderLabel.text];
    [self.genderLabel sizeToFit];
    
    [LabelAttributeStyle changeGapString: self.birthdayLabel content: self.birthdayLabel.text];
    [self.birthdayLabel sizeToFit];
    
    [LabelAttributeStyle changeGapString: self.interestLabel content: self.interestLabel.text];
    [self.interestLabel sizeToFit];
    
    [LabelAttributeStyle changeGapString: self.communityLabel content: self.communityLabel.text];
    [self.communityLabel sizeToFit];
    
    self.scrollView.showsVerticalScrollIndicator = NO;    
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

- (void)dismissKeyboard {
    NSLog(@"dismissKeyboard");
    [self.view endEditing:YES];
    
    [blurEffectView removeFromSuperview];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)userInterfaceSetup {
    UIToolbar *toolBarForDoneBtn = [[UIToolbar alloc] initWithFrame: CGRectMake(0, 0, 320, 40)];
    toolBarForDoneBtn.barStyle = UIBarStyleDefault;
    toolBarForDoneBtn.items = [NSArray arrayWithObjects:
                               //[[UIBarButtonItem alloc] initWithTitle: @"取消" style: UIBarButtonItemStylePlain target: self action: @selector(cancelNumberPad)],
                               [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil],
                               [[UIBarButtonItem alloc] initWithTitle: @"完成" style: UIBarButtonItemStyleDone target: self action: @selector(dismissKeyboard)], nil];
    
    self.nameTextView.tag = 100;
    self.nameTextView.myLeftMargin = 0;
    self.nameTextView.myRightMargin = 13;
    self.nameTextView.myTopMargin = 5;
    self.nameTextView.myBottomMargin = 0;
    self.nameTextView.myCenterYOffset = 0;
    self.nameTextView.wrapContentHeight = YES;
    self.nameTextView.heightDime.max(300).min(30);
    
    self.nameTextView.textColor = [UIColor firstGrey];
    self.nameTextView.backgroundColor = [UIColor thirdGrey];
    self.nameTextView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self.nameTextView.layer.cornerRadius = kCornerRadius;
    
    self.nameTextView.inputAccessoryView = toolBarForDoneBtn;
    
    placeHolderNameLabel = [[UILabel alloc] initWithFrame: CGRectMake(13, 10, 0, 0)];
    placeHolderNameLabel.text = @"您的名稱是？";
    placeHolderNameLabel.numberOfLines = 0;
    placeHolderNameLabel.textColor = [UIColor hintGrey];
    [placeHolderNameLabel sizeToFit];
    [self.nameTextView addSubview:placeHolderNameLabel];
    
    self.nameTextView.font = [UIFont systemFontOfSize: 14.f];
    placeHolderNameLabel.font = [UIFont systemFontOfSize: 14.f];
    
    self.nameTextView.text = myData[@"nickname"];
    
    if ([self.nameTextView.text isEqualToString: @""]) {
        placeHolderNameLabel.alpha = 1;
    } else {
        placeHolderNameLabel.alpha = 0;
    }
    
    // descriptionTextView Setting
    self.descriptionTextView.hidden = YES;
    self.descriptionTextView.textColor = [UIColor firstGrey];
    self.descriptionTextView.backgroundColor = [UIColor thirdGrey];
    self.descriptionTextView.wrapContentHeight = YES;
    self.descriptionTextView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self.descriptionTextView.layer.cornerRadius = kCornerRadius;
    
    self.descriptionTextView.myTopMargin = 5;
    self.descriptionTextView.myLeftMargin = 16;
    self.descriptionTextView.myRightMargin = 16;
    
    self.descriptionTextView.inputAccessoryView = toolBarForDoneBtn;
    
    placeHolderDescriptionLabel = [[UILabel alloc] initWithFrame: CGRectMake(13, 10, 0, 0)];
    placeHolderDescriptionLabel.text = @"簡單介紹一下自己吧！";
    placeHolderDescriptionLabel.numberOfLines = 0;
    placeHolderDescriptionLabel.textColor = [UIColor hintGrey];
    [placeHolderDescriptionLabel sizeToFit];
    [self.descriptionTextView addSubview: placeHolderDescriptionLabel];
    
    self.descriptionTextView.font = [UIFont systemFontOfSize: 14.f];
    placeHolderDescriptionLabel.font = [UIFont systemFontOfSize: 14.f];
    
    self.descriptionTextView.text = myData[@"selfdescription"];
    
    if ([self.descriptionTextView.text isEqualToString: @""]) {
        placeHolderDescriptionLabel.alpha = 1;
    } else {
        placeHolderDescriptionLabel.alpha = 0;
    }
    
    // Pwd Setting
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"userDefaults FB: %@", [userDefaults objectForKey: @"FB"]);
    
    if ([userDefaults objectForKey: @"FB"] != nil) {
        NSLog(@"FB data is not nil");
        
        self.pwdLabel.hidden = YES;
        self.pwdChangeBtn.hidden = YES;
    } else {
        NSLog(@"FB data is nil");
        
        self.pwdLabel.hidden = NO;
        self.pwdChangeBtn.hidden = NO;
    }
    
    // CreatorNameTextView Setting
    self.CreatorNameTextView.text = myData[@"creative_name"];
    self.CreatorNameTextView.textColor = [UIColor firstGrey];
    self.CreatorNameTextView.backgroundColor = [UIColor thirdGrey];
    self.CreatorNameTextView.wrapContentHeight = YES;
    self.CreatorNameTextView.textContainerInset = UIEdgeInsetsMake(10, 5, 10, 5);
    self.CreatorNameTextView.layer.cornerRadius = kCornerRadius;
    self.CreatorNameTextView.myTopMargin = 5;
    self.CreatorNameTextView.myLeftMargin = 16;
    self.CreatorNameTextView.myRightMargin = 16;
    
    self.CreatorNameTextView.inputAccessoryView = toolBarForDoneBtn;
    
    // Email Setting
    self.emailTextField.text = myData[@"email"];
    self.emailTextField.textColor = [UIColor firstGrey];
    self.emailTextField.inputAccessoryView = toolBarForDoneBtn;
    self.emailView.layer.cornerRadius = kCornerRadius;
    self.emailView.clipsToBounds = YES;
    self.emailView.backgroundColor = [UIColor thirdGrey];
    
    // PWD Change Button Setting
    self.pwdChangeBtn.backgroundColor = [UIColor thirdGrey];
    self.pwdChangeBtn.layer.cornerRadius = kCornerRadius;
    self.pwdChangeBtn.clipsToBounds = YES;
    
    // Mobile Change Button Setting
    self.mobileChangeBtn.backgroundColor = [UIColor thirdGrey];
    self.mobileChangeBtn.layer.cornerRadius = kCornerRadius;
    self.mobileChangeBtn.clipsToBounds = YES;
    
    // Interest Change Button Setting
    self.interestChangeBtn.backgroundColor = [UIColor thirdGrey];
    self.interestChangeBtn.layer.cornerRadius = kCornerRadius;
    self.interestChangeBtn.clipsToBounds = YES;
    
    // Sex Gender Button Setting
    self.maleBtn.backgroundColor = [UIColor thirdGrey];
    self.maleBtn.layer.cornerRadius = kCornerRadius;
    self.maleBtn.clipsToBounds = YES;
    
    self.femaleBtn.backgroundColor = [UIColor thirdGrey];
    self.femaleBtn.layer.cornerRadius = kCornerRadius;
    self.femaleBtn.clipsToBounds = YES;
    
    self.privateBtn.backgroundColor = [UIColor thirdGrey];
    self.privateBtn.layer.cornerRadius = kCornerRadius;
    self.privateBtn.clipsToBounds = YES;
    
    sextInteger = [myData[@"gender"] integerValue];
    NSLog(@"sextInteger: %ld", (long)sextInteger);
    
    if (sextInteger == 1) {
        [self.maleBtn setTitleColor: [UIColor blackColor]
                           forState: UIControlStateNormal];
        self.maleBtn.backgroundColor = [UIColor secondMain];
        self.maleBtn.layer.borderWidth = 0;
        
        [self.femaleBtn setTitleColor: [UIColor thirdGrey]
                             forState: UIControlStateNormal];
        self.femaleBtn.backgroundColor = [UIColor clearColor];
        self.femaleBtn.layer.borderColor = [UIColor thirdGrey].CGColor;
        self.femaleBtn.layer.borderWidth = 1.0;
        
        [self.privateBtn setTitleColor: [UIColor thirdGrey]
                              forState: UIControlStateNormal];
        self.privateBtn.backgroundColor = [UIColor clearColor];
        self.privateBtn.layer.borderColor = [UIColor thirdGrey].CGColor;
        self.privateBtn.layer.borderWidth = 1.0;
    } else if (sextInteger == 0) {
        [self.maleBtn setTitleColor: [UIColor thirdGrey]
                           forState: UIControlStateNormal];
        self.maleBtn.backgroundColor = [UIColor clearColor];
        self.maleBtn.layer.borderColor = [UIColor thirdGrey].CGColor;
        self.maleBtn.layer.borderWidth = 1.0;
        
        [self.femaleBtn setTitleColor: [UIColor blackColor]
                             forState: UIControlStateNormal];
        self.femaleBtn.backgroundColor = [UIColor secondMain];
        self.femaleBtn.layer.borderWidth = 0;
        
        [self.privateBtn setTitleColor: [UIColor thirdGrey]
                              forState: UIControlStateNormal];
        self.privateBtn.backgroundColor = [UIColor clearColor];
        self.privateBtn.layer.borderColor = [UIColor thirdGrey].CGColor;
        self.privateBtn.layer.borderWidth = 1.0;
    } else if (sextInteger == 2) {
        [self.maleBtn setTitleColor: [UIColor thirdGrey]
                           forState: UIControlStateNormal];
        self.maleBtn.backgroundColor = [UIColor clearColor];
        self.maleBtn.layer.borderColor = [UIColor thirdGrey].CGColor;
        self.maleBtn.layer.borderWidth = 1.0;
        
        [self.femaleBtn setTitleColor: [UIColor thirdGrey]
                             forState: UIControlStateNormal];
        self.femaleBtn.backgroundColor = [UIColor clearColor];
        self.femaleBtn.layer.borderColor = [UIColor thirdGrey].CGColor;
        self.femaleBtn.layer.borderWidth = 1.0;
        
        [self.privateBtn setTitleColor: [UIColor blackColor]
                              forState: UIControlStateNormal];
        self.privateBtn.backgroundColor = [UIColor secondMain];
        self.privateBtn.layer.borderWidth = 0;
    }
    
    // Birthday Setting
    self.birthdayView.layer.cornerRadius = kCornerRadius;
    self.birthdayView.backgroundColor = [UIColor thirdGrey];
    
    self.birthdayTextField.text = myData[@"birthday"];
    self.birthdayTextField.tintColor = [UIColor clearColor];
    self.birthdayTextField.backgroundColor = [UIColor clearColor];
    
    datePicker = [[UIDatePicker alloc] init];
    datelocale = [[NSLocale alloc] initWithLocaleIdentifier: @"zh_TW"];
    datePicker.locale = datelocale;
    datePicker.timeZone = [NSTimeZone timeZoneWithName: @"GMT"];
    datePicker.datePickerMode = UIDatePickerModeDate;
    
    self.birthdayTextField.inputView = datePicker;
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, 0, 320, 44)];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle: @"確定" style: UIBarButtonItemStylePlain target: self action: @selector(donePicker)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil];
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle: @"取消" style: UIBarButtonItemStylePlain target: self action: @selector(cancelPicker)];
    toolBar.items = [NSArray arrayWithObjects: left, flexibleSpace, right, nil];
    
    self.birthdayTextField.inputAccessoryView = toolBar;
    
    // SaveBtn Setting
    self.saveBtn.layer.cornerRadius = kCornerRadius;    
}

- (void)checkSocialData {
    if ([myData[@"sociallink"] isEqual: [NSNull null]]) {
        [self hideSocialData];
    } else if ([myData[@"sociallink"] isKindOfClass: [NSString class]]) {
        if ([myData[@"sociallink"] isEqualToString: @""]) {
            [self hideSocialData];
        } else {
            [self showSocialData];
        }
    } else {
        [self showSocialData];
    }
}

- (void)hideSocialData {
    self.communityLabel.hidden = YES;
    self.facebookBgView.hidden = YES;
    self.googleBgView.hidden = YES;
    self.instagramBgView.hidden = YES;
    self.linkedInBgView.hidden = YES;
    self.pinterestBgView.hidden = YES;
    self.twitterBgView.hidden = YES;
    self.youtubeBgView.hidden = YES;
    self.homeBgView.hidden = YES;
}

- (void)showSocialData {
    self.communityLabel.hidden = NO;
    
    self.facebookBgView.hidden = NO;
    self.facebookView.layer.cornerRadius = kCornerRadius;
    self.facebookView.clipsToBounds = YES;
    self.facebookView.backgroundColor = [UIColor thirdGrey];
    self.facebookTextField.textColor = [UIColor firstGrey];
    self.facebookTextField.text = self.userDic[@"sociallink"][@"facebook"];
    
    self.googleBgView.hidden = NO;
    self.googleView.layer.cornerRadius = kCornerRadius;
    self.googleView.clipsToBounds = YES;
    self.googleView.backgroundColor = [UIColor thirdGrey];
    self.googleTextField.textColor = [UIColor firstGrey];
    self.googleTextField.text = self.userDic[@"sociallink"][@"google"];
    
    self.instagramBgView.hidden = NO;
    self.instagramView.layer.cornerRadius = kCornerRadius;
    self.instagramView.clipsToBounds = YES;
    self.instagramView.backgroundColor = [UIColor thirdGrey];
    self.instagramTextField.textColor = [UIColor firstGrey];
    self.instagramTextField.text = self.userDic[@"sociallink"][@"instagram"];
    
    self.linkedInBgView.hidden = NO;
    self.linkedInView.layer.cornerRadius = kCornerRadius;
    self.linkedInView.clipsToBounds = YES;
    self.linkedInView.backgroundColor = [UIColor thirdGrey];
    self.linkedInTextField.textColor = [UIColor firstGrey];
    self.linkedInTextField.text = self.userDic[@"sociallink"][@"linkedin"];
    
    self.pinterestBgView.hidden = NO;
    self.pinterestView.layer.cornerRadius = kCornerRadius;
    self.pinterestView.clipsToBounds = YES;
    self.pinterestView.backgroundColor = [UIColor thirdGrey];
    self.pinterestTextField.textColor = [UIColor firstGrey];
    self.pinterestTextField.text = self.userDic[@"sociallink"][@"pinterest"];
    
    self.twitterBgView.hidden = NO;
    self.twitterView.layer.cornerRadius = kCornerRadius;
    self.twitterView.clipsToBounds = YES;
    self.twitterView.backgroundColor = [UIColor thirdGrey];
    self.twitterTextField.textColor = [UIColor firstGrey];
    self.twitterTextField.text = self.userDic[@"sociallink"][@"twitter"];
    
    self.youtubeBgView.hidden = NO;
    self.youtubeView.layer.cornerRadius = kCornerRadius;
    self.youtubeView.clipsToBounds = YES;
    self.youtubeView.backgroundColor = [UIColor thirdGrey];
    self.youtubeTextField.textColor = [UIColor firstGrey];
    self.youtubeTextField.text = self.userDic[@"sociallink"][@"youtube"];
    
    self.homeBgView.hidden = NO;
    self.homeView.layer.cornerRadius = kCornerRadius;
    self.homeView.clipsToBounds = YES;
    self.homeView.backgroundColor = [UIColor thirdGrey];
    self.homeTextField.textColor = [UIColor firstGrey];
    self.homeTextField.text = self.userDic[@"sociallink"][@"web"];
}

- (void)donePicker
{
    if ([self.view endEditing: NO]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate: @"yyyy-MM-dd" options: 0 locale: datelocale];
        [formatter setDateFormat: dateFormat];
        [formatter setLocale: datelocale];
        
        self.birthdayTextField.text = [NSString stringWithFormat: @"%@", [formatter stringFromDate: datePicker.date]];
    }
    
    [blurEffectView removeFromSuperview];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)cancelPicker
{
    [self.view endEditing: YES];
    
    [blurEffectView removeFromSuperview];
    self.view.backgroundColor = [UIColor whiteColor];
}

#pragma mark - IBAction Methods
- (IBAction)pwdChangeBtnPress:(id)sender {
    //ChangePwdViewController *changePwdVC = [[UIStoryboard storyboardWithName: @"Main" bundle: nil] instantiateViewControllerWithIdentifier: @"ChangePwdViewController"];
    ChangePwdViewController *changePwdVC = [[UIStoryboard storyboardWithName: @"ChangePwdVC" bundle: nil] instantiateViewControllerWithIdentifier: @"ChangePwdViewController"];
    //[self.navigationController pushViewController: changePwdVC animated: YES];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav pushViewController: changePwdVC animated: YES];
}

- (IBAction)mobileChangeBtnPress:(id)sender {
    //ChangeCellPhoneNumberViewController *changeCellPhoneNumberVC = [[UIStoryboard storyboardWithName: @"Main" bundle: nil] instantiateViewControllerWithIdentifier: @"ChangeCellPhoneNumberViewController"];
    ChangeCellPhoneNumberViewController *changeCellPhoneNumberVC = [[UIStoryboard storyboardWithName: @"ChangeCellPhoneNumberVC" bundle: nil] instantiateViewControllerWithIdentifier: @"ChangeCellPhoneNumberViewController"];
    //[self.navigationController pushViewController: changeCellPhoneNumberVC animated: YES];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav pushViewController: changeCellPhoneNumberVC animated: YES];
}

- (IBAction)interestChangeBtnPressed:(id)sender {
    NSLog(@"interestChangeBtnPressed");
    ChangeInterestsViewController *changeInterestsVC = [[UIStoryboard storyboardWithName: @"ChangeInterestsVC" bundle: nil] instantiateViewControllerWithIdentifier: @"ChangeInterestsViewController"];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav pushViewController: changeInterestsVC animated: YES];
}

- (IBAction)maleBtnPress:(id)sender {
    [self.maleBtn setTitleColor: [UIColor blackColor]
                       forState: UIControlStateNormal];
    self.maleBtn.backgroundColor = [UIColor secondMain];
    self.maleBtn.layer.borderWidth = 0;
    
    [self.femaleBtn setTitleColor: [UIColor thirdGrey]
                         forState: UIControlStateNormal];
    self.femaleBtn.backgroundColor = [UIColor clearColor];
    self.femaleBtn.layer.borderColor = [UIColor thirdGrey].CGColor;
    self.femaleBtn.layer.borderWidth = 1.0;
    
    [self.privateBtn setTitleColor: [UIColor thirdGrey]
                          forState: UIControlStateNormal];
    self.privateBtn.backgroundColor = [UIColor clearColor];
    self.privateBtn.layer.borderColor = [UIColor thirdGrey].CGColor;
    self.privateBtn.layer.borderWidth = 1.0;
    
    sextInteger = 1;
}

- (IBAction)femaleBtnPress:(id)sender {
    [self.maleBtn setTitleColor: [UIColor thirdGrey]
                       forState: UIControlStateNormal];
    self.maleBtn.backgroundColor = [UIColor clearColor];
    self.maleBtn.layer.borderColor = [UIColor thirdGrey].CGColor;
    self.maleBtn.layer.borderWidth = 1.0;
    
    [self.femaleBtn setTitleColor: [UIColor blackColor]
                         forState: UIControlStateNormal];
    self.femaleBtn.backgroundColor = [UIColor secondMain];
    self.femaleBtn.layer.borderWidth = 0;
    
    [self.privateBtn setTitleColor: [UIColor thirdGrey]
                          forState: UIControlStateNormal];
    self.privateBtn.backgroundColor = [UIColor clearColor];
    self.privateBtn.layer.borderColor = [UIColor thirdGrey].CGColor;
    self.privateBtn.layer.borderWidth = 1.0;
    
    sextInteger = 0;
}

- (IBAction)privateBtnPress:(id)sender {
    [self.maleBtn setTitleColor: [UIColor thirdGrey]
                       forState: UIControlStateNormal];
    self.maleBtn.backgroundColor = [UIColor clearColor];
    self.maleBtn.layer.borderColor = [UIColor thirdGrey].CGColor;
    self.maleBtn.layer.borderWidth = 1.0;
    
    [self.femaleBtn setTitleColor: [UIColor thirdGrey]
                         forState: UIControlStateNormal];
    self.femaleBtn.backgroundColor = [UIColor clearColor];
    self.femaleBtn.layer.borderColor = [UIColor thirdGrey].CGColor;
    self.femaleBtn.layer.borderWidth = 1.0;
    
    [self.privateBtn setTitleColor: [UIColor blackColor]
                          forState: UIControlStateNormal];
    self.privateBtn.backgroundColor = [UIColor secondMain];
    self.privateBtn.layer.borderWidth = 0;
    
    sextInteger = 2;
}

- (IBAction)saveBtnPress:(id)sender {
    NSLog(@"saveBtnPress");
    
    NSMutableDictionary *dataDic = [NSMutableDictionary new];
    [dataDic setObject: self.nameTextView.text forKey: @"name"];
    [dataDic setObject: [NSString stringWithFormat: @"%ld", (long)sextInteger] forKey: @"gender"];
    [dataDic setObject: self.birthdayTextField.text forKey: @"birthday"];
    //[data setObject: self.descriptionTextView.text forKey: @"selfdescription"];
    [dataDic setObject: self.CreatorNameTextView.text forKey: @"creative_name"];
    [dataDic setObject: self.emailTextField.text forKey: @"email"];
    [dataDic setObject: [NSNumber numberWithBool: wantToGetNewsLetter] forKey: @"newsletter"];
    
    NSMutableDictionary *socialDic = [NSMutableDictionary new];
    [socialDic setObject: self.facebookTextField.text forKey: @"facebook"];
    [socialDic setObject: self.googleTextField.text forKey: @"google"];
    [socialDic setObject: self.instagramTextField.text forKey: @"instagram"];
    [socialDic setObject: self.linkedInTextField.text forKey: @"linkedin"];
    [socialDic setObject: self.pinterestTextField.text forKey: @"pinterest"];
    [socialDic setObject: self.twitterTextField.text forKey: @"twitter"];
    [socialDic setObject: self.youtubeTextField.text forKey: @"youtube"];
    [socialDic setObject: self.homeTextField.text forKey: @"web"];
    
    [dataDic setObject: socialDic forKey: @"sociallink"];
    
    NSLog(@"dataDic: %@", dataDic);
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: dataDic options: 0 error: nil];
    NSString *jsonStr = [[NSString alloc] initWithData: jsonData encoding: NSUTF8StringEncoding];
    
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
        //NSString *response = [boxAPI updateprofile: [wTools getUserID] token: [wTools getUserToken] data: data];
        NSString *response = [boxAPI updateUser: [wTools getUserID]
                                          token: [wTools getUserToken]
                                          param: jsonStr];
        
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
                    NSLog(@"InfoEditViewController");
                    NSLog(@"saveBtnPress");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"updateUser"];
                } else {
                    NSLog(@"Get Real Response");
                    
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    //if ([dic[@"result"] boolValue]) {
                    if ([dic[@"result"] isEqualToString: @"SYSTEM_OK"]) {
                        NSLog(@"dic: %@", dic);
                        
                        if (wself->selectImage == nil) {
                            NSLog(@"update 1");
                            
                            [self checkPointTask];
                        } else {
                            
                            // If headshot did change
                            NSLog(@"update 2");
                            [self updateProfilePic];
                            //[self callboxIMGAPI];
                        }
                        
                        // Callback for MeTabVC to update the edit data
                        if ([self.delegate respondsToSelector: @selector(infoEditViewControllerSaveBtnPressed:)]) {
                            NSLog(@"self.delegate respondsToSelector: @selector(infoEditViewControllerSaveBtnPressed:");
                            [self.delegate infoEditViewControllerSaveBtnPressed: self];
                        }
                    } else if ([dic[@"result"] isEqualToString: @"SYSTEM_ERROR"]) {
                        NSLog(@"失敗： %@", dic[@"message"]);
                        NSString *msg = dic[@"message"];
                        
                        if (msg == nil) {
                            msg = NSLocalizedString(@"Host-NotAvailable", @"");
                        }
                        [self showCustomErrorAlert: msg];
                    } else if ([dic[@"result"] isEqualToString: @"TOKEN_ERROR"]) {
                        NSLog(@"TOKEN_ERROR");
                        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                        style.messageColor = [UIColor whiteColor];
                        style.backgroundColor = [UIColor thirdPink];
                        
                        [self.view makeToast: @"用戶驗證異常請重新登入"
                                    duration: 2.0
                                    position: CSToastPositionBottom
                                       style: style];
                        
                        [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                         target: self
                                                       selector: @selector(logOut)
                                                       userInfo: nil
                                                        repeats: NO];
                    }
                }
            }
        });
    });
}

- (void)logOut {
    [wTools logOut];
}

- (void)updateProfilePic {
    NSLog(@"updateProfilePic");
    
    UIImage *image = [wTools scaleImage: selectImage
                                toScale: 0.5];
    
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
        NSString *response = [boxAPI updateProfilePic: [wTools getUserID]
                                                token: [wTools getUserToken]
                                                image: image];
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
                NSLog(@"response from updateProfilePic");
                
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                NSLog(@"dic: %@", dic);
                
                if ([dic[@"result"] intValue] == 1) {
                    NSLog(@"dic result boolValue is 1");
                    
                    if ([self.delegate respondsToSelector: @selector(profilePictureUpdate:)]) {
                        [self.delegate profilePictureUpdate: dic[@"data"]];
                    }                    
                    [self checkPointTask];
                } else if ([dic[@"result"] intValue] == 0) {
                    NSLog(@"失敗： %@", dic[@"message"]);
                    NSString *msg = dic[@"message"];
                    [self showCustomErrorAlert: msg];
                } else {
                    [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                }
            }
        });
    });
}

- (IBAction)backBtnPress:(id)sender {
    //[self.navigationController popViewControllerAnimated: YES];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav popViewControllerAnimated: YES];
}

- (IBAction)changeHeadshotImage:(id)sender {
    NSLog(@"changeHeadshotImage");
    PhotosViewController *pVC = [[UIStoryboard storyboardWithName: @"PhotosVC" bundle: nil] instantiateViewControllerWithIdentifier: @"PhotosViewController"];
    pVC.selectrow = 1;
    pVC.phototype = @"0";
    pVC.delegate = self;
    pVC.fromVC = @"InfoEditViewController";
    //[self.navigationController pushViewController: pVC animated: YES];
    //[self presentViewController: pVC animated: YES completion: nil];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav presentViewController: pVC animated: YES completion: nil];
    NSLog(@"presentViewController");
}

#pragma mark - PhotoViewsController Delegate Method
- (void)imageCropViewController:(PhotosViewController *)controller Image:(UIImage *)Image
{
    selectImage = Image;
    self.headshotImageView.image = selectImage;
}

#pragma mark - checkPointTask
- (void)checkPointTask
{
    // Check Point Task
    [self checkFirstTimeEditing];
    //[self.navigationController popViewControllerAnimated: YES];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav popViewControllerAnimated: YES];
}

#pragma mark - checkFirstTimeEditing
- (void)checkFirstTimeEditing
{
    NSLog(@"checkFirstTimeEditing");
    
    // Check whether getting edit profile point or not
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *editProfile = [defaults objectForKey: @"editProfile"];
    NSLog(@"editProfile: %@", editProfile);
    
    if ([editProfile isEqualToString: @"ModifiedAlready"]) {
        NSLog(@"Get the First Time Eidt Profile Point Already");
    } else {
        NSLog(@"show alert point view");
        editProfile = @"FirstTimeModified";
        [defaults setObject: editProfile forKey: @"editProfile"];
        [defaults synchronize];
    }
}

#pragma mark -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    NSLog(@"textViewDidBeginEditing");
    
    selectTextView = textView;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    NSLog(@"textViewDidEndEditing");
    selectTextView = nil;
}

- (void)textViewDidChange:(UITextView *)textView {
    NSLog(@"textViewDidChange");
    
    //每次输入变更都让布局重新布局。
    MyBaseLayout *layout = (MyBaseLayout*)textView.superview;
    [layout setNeedsLayout];
    
    //这里设置在布局结束后将textView滚动到光标所在的位置了。在布局执行布局完毕后如果设置了endLayoutBlock的话可以在这个block里面读取布局里面子视图的真实布局位置和尺寸，也就是可以在block内部读取每个子视图的真实的frame的值。
    layout.endLayoutBlock = ^{
        NSRange rg = textView.selectedRange;
        [textView scrollRangeToVisible:rg];
    };
    
    if ([self.nameTextView.text isEqualToString: @""]) {
        placeHolderNameLabel.alpha = 1;
    } else {
        placeHolderNameLabel.alpha = 0;
    }
    
    if ([self.descriptionTextView.text isEqualToString: @""]) {
        placeHolderDescriptionLabel.alpha = 1;
    } else {
        placeHolderDescriptionLabel.alpha = 0;
    }
}

- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text {
    if (textView.tag == 100) {
        NSLog(@"textView.tag == 100");
        
        if ([text isEqualToString: @"\n"]) {
            [textView resignFirstResponder];
            return NO;
        }
    }
    return YES;
}

#pragma mark - UITextField Delegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"textFieldDidBeginEditing");
    [wTools setStatusBarBackgroundColor: [UIColor clearColor]];
    
    selectTextField = textField;
    
    if (textField.inputView == datePicker) {
        NSLog(@"datePicker View Shows up");
        
        [self createBlurView];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"textFieldDidEndEditing");
    [wTools setStatusBarBackgroundColor: [UIColor whiteColor]];
    selectTextField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"textFieldShouldReturn");
    
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Notifications for Keyboard
// Call this method somewhere in your view controller setup code.
- (void)addKeyboardNotification {
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

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSLog(@"");
    NSLog(@"keyboardWasShown");
    NSDictionary* info = [aNotification userInfo];
    NSLog(@"info: %@", info);
    
    //CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGSize kbSize = [[info objectForKey: UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    NSLog(@"aRect: %@", NSStringFromCGRect(aRect));
    
    aRect.size.height -= kbSize.height;
    NSLog(@"aRect.size.height: %f", aRect.size.height);
    
    UIView *activeField;
    
    if (selectTextView != nil) {
        activeField = selectTextView;
    } else if (selectTextField != nil) {
        activeField = selectTextField;
    }
    
    NSLog(@"aRect: %@", NSStringFromCGRect(aRect));
    NSLog(@"activeField.frame.origin: %@", NSStringFromCGPoint(activeField.frame.origin));
    
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        CGPoint scrollPoint;
        
        if (kbSize.height > 264) {
            // for iOS 11
            scrollPoint = CGPointMake(0.0, activeField.frame.origin.y - kbSize.height + 50);
        } else {
            // Under iOS 11 the kb height will be 264
            scrollPoint = CGPointMake(0.0, activeField.frame.origin.y - kbSize.height);
        }
        NSLog(@"scrollPoint: %@", NSStringFromCGPoint(scrollPoint));
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - Blurring Overlay View
- (void)createBlurView
{
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        self.view.backgroundColor = [UIColor clearColor];
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle: UIBlurEffectStyleDark];
        blurEffectView = [[UIVisualEffectView alloc] initWithEffect: blurEffect];
        blurEffectView.frame = self.view.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.view addSubview: blurEffectView];
    }
}

#pragma mark - Custom Error Alert Method
- (void)showCustomErrorAlert: (NSString *)msg
{
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
#pragma mark - Custom Method for TimeOut
- (void)showCustomTimeOutAlert: (NSString *)msg
                  protocolName: (NSString *)protocolName
{
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
            if ([protocolName isEqualToString: @"updateUser"]) {
                [weakSelf saveBtnPress: nil];
            }
        }
    }];
    [alertTimeOutView setUseMotionEffects: YES];
    [alertTimeOutView show];
}

- (UIView *)createTimeOutContainerView: (NSString *)msg
{
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches
           withEvent:(UIEvent *)event {
    CGPoint location = [[touches anyObject] locationInView: self.view];
    CGRect fingerRect = CGRectMake(location.x - 5, location.y - 5, 10, 10);
    
    for (UIView *view in self.view.subviews) {
        CGRect subviewFrame = view.frame;
        
        if (CGRectIntersectsRect(fingerRect, subviewFrame)) {
            NSLog(@"finally touched view: %@", view);
            NSLog(@"view.tag: %ld", (long)view.tag);
            
            switch (view.tag) {
                case 100:
                    wantToGetNewsLetter = !wantToGetNewsLetter;
                    if (wantToGetNewsLetter) {
                        self.newsLetterCheckSelectionView.backgroundColor = [UIColor thirdMain];
                    } else {
                        self.newsLetterCheckSelectionView.backgroundColor = [UIColor clearColor];
                    }
                default:
                    break;
            }
        }
    }
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
