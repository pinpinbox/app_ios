//
//  ExchangeInfoEditViewController.m
//  wPinpinbox
//
//  Created by David on 12/03/2018.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "ExchangeInfoEditViewController.h"
//#import "ExchangeStuff.h"
#import "UIColor+Extensions.h"
#import "MyLayout.h"
#import "GlobalVars.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import "boxAPI.h"
#import "wTools.h"
#import "CustomIOSAlertView.h"

#import "UIView+Toast.h"

#import "LabelAttributeStyle.h"
#import "UIViewController+ErrorAlert.h"

@interface ExchangeInfoEditViewController () <UITextViewDelegate, UITextFieldDelegate>
{
    UITextView *selectTextView;
    UITextField *selectTextField;
    
    BOOL keyboardVisible;
    CGPoint offset;
    
    NSInteger photoUseForUserId;
}
//@property (strong, nonatomic) ExchangeStuff *exchangeStuff;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSString *jsonStr;

@property (strong, nonatomic) UITextView *nameTextView;
@property (strong, nonatomic) UITextField *telephoneField;
@property (strong, nonatomic) UITextView *addressTextView;
@end

@implementation ExchangeInfoEditViewController

#pragma mark - View Related Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"self.exchangeDic: %@", self.exchangeDic);
    NSLog(@"self.exchangeDic photousefor image: %@", self.exchangeDic[@"photousefor"][@"image"]);
    NSLog(@"self.isExisting: %d", self.isExisting);
    
    [self initialValueSetup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"ExchangeInfoEditViewController");
    NSLog(@"viewWillAppear");
    [self addKeyboardNotification];
    [[UIDevice currentDevice] setValue: [NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey: @"orientation"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"ExchangeInfoEditViewController");
    NSLog(@"viewWillDisappear");
    [self removeKeyboardNotification];
}

- (void)initialValueSetup {
    NSLog(@"initialValueSetup");
    
    // Dictionary Data Setup
    if ([self.exchangeDic.allKeys containsObject: @"photo"]) {
        NSLog(@"self.exchangeDic.allKeys contains object photo");
        NSLog(@"self.exchangeDic: %@", self.exchangeDic);
    } else {
        NSLog(@"self.exchangeDic.allKeys doesn't contain object photo");
        NSMutableDictionary *photoDic = [[NSMutableDictionary alloc] init];
        [photoDic setObject: [NSNumber numberWithBool: NO] forKey: @"has_gained"];
        [photoDic setObject: [NSNumber numberWithInteger: self.photoId] forKey: @"photo_id"];
        
        [self.exchangeDic setObject: photoDic forKey: @"photo"];
        NSLog(@"self.exchangeDic: %@", self.exchangeDic);
    }
    
    if ([self.exchangeDic.allKeys containsObject: @"photousefor_user"]) {
        NSLog(@"self.exchangeDic.allKeys contains photousefor_user");
        
        if (![self.exchangeDic[@"photousefor_user"] isEqual: [NSNull null]]) {
            if (![self.exchangeDic[@"photousefor_user"][@"photousefor_user_id"] isEqual: [NSNull null]]) {
                photoUseForUserId = [self.exchangeDic[@"photousefor_user"][@"photousefor_user_id"] integerValue];
            }
        }
    } else {
        NSLog(@"self.exchangeDic.allKeys does not contain photousefor_user");
        [self.exchangeDic setObject: [NSNull null] forKey: @"photousefor_user"];
        NSLog(@"self.exchangeDic: %@", self.exchangeDic);
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(dismissKeyboard)];
    [self.view addGestureRecognizer: tap];
    
//    UIToolbar *toolBarForDoneBtn = [[UIToolbar alloc] initWithFrame: CGRectMake(0.0, 0.0, 320, 40)];
//    toolBarForDoneBtn.barStyle = UIBarStyleDefault;
//    toolBarForDoneBtn.items = [NSArray arrayWithObjects:
//                               //[[UIBarButtonItem alloc] initWithTitle: @"取消" style: UIBarButtonItemStylePlain target: self action: @selector(cancelNumberPad)],
//                               [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil],
//                               [[UIBarButtonItem alloc] initWithTitle: @"完成" style: UIBarButtonItemStyleDone target: self action: @selector(dismissKeyboard)], nil];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    
    // ScrollView
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.myTopMargin = self.scrollView.myBottomMargin = 0;
    self.scrollView.myLeftMargin = self.scrollView.myRightMargin = 0;
    
    CGFloat bottomPadding = 0;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 1136:
                printf("iPhone 5 or 5S or 5C");
                bottomPadding = 68.0;
                break;
            case 1334:
                printf("iPhone 6/6S/7/8");
                bottomPadding = 68.0;
                break;
            case 1920:
                printf("iPhone 6+/6S+/7+/8+");
                bottomPadding = 68.0;
                break;
            case 2208:
                printf("iPhone 6+/6S+/7+/8+");
                bottomPadding = 68.0;
                break;
            case 2436:
                printf("iPhone X");
                bottomPadding = 102.0;
                break;
            default:
                printf("unknown");
                bottomPadding = 68.0;
                break;
        }
    }
    
    self.scrollView.contentInset = UIEdgeInsetsMake(64.0, 0.0, bottomPadding, 0.0);
    [self.view addSubview:_scrollView];
    
    // BgLayout
    MyLinearLayout *bgLayout = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Vert];
    bgLayout.wrapContentHeight = YES;
    bgLayout.myTopMargin = 0;
    bgLayout.myLeftMargin = bgLayout.myRightMargin = 16;
    //    bgLayout.backgroundColor = [UIColor greenColor];
    //    bgLayout.alpha = 0.5;
    [self.scrollView addSubview: bgLayout];
    
    //    self.product.imageName = @"05";
    
    // ImageView
    NSLog(@"ImageView");
    
    if (![self.exchangeDic[@"photousefor"][@"image"] isEqual: [NSNull null]]) {
        self.imageView = [[UIImageView alloc] init];
        [self.imageView sd_setImageWithURL: [NSURL URLWithString: self.exchangeDic[@"photousefor"][@"image"]]
                          placeholderImage: [UIImage imageNamed: @"bg200_no_image.jpg"]];
        self.imageView.myTopMargin = 0;
        self.imageView.myLeftMargin = self.imageView.myRightMargin = 0;
        self.imageView.layer.cornerRadius = kCornerRadius;
        self.imageView.layer.masksToBounds = YES;
        [self calculateImageViewSize];

        [bgLayout addSubview: self.imageView];
    }
    
    // Number Label
    UILabel *nameLabel = [UILabel new];
    nameLabel.wrapContentHeight = YES;
    nameLabel.myTopMargin = nameLabel.myBottomMargin = 8;
    nameLabel.myLeftMargin = nameLabel.myRightMargin = 0;
    nameLabel.numberOfLines = 0;
    nameLabel.font = [UIFont boldSystemFontOfSize: 24.0];
    
    if (![self.exchangeDic[@"photousefor"][@"name"] isEqual: [NSNull null]]) {
        nameLabel.text = self.exchangeDic[@"photousefor"][@"name"];
        [LabelAttributeStyle changeGapString: nameLabel content: nameLabel.text];
    }
    nameLabel.textColor = [UIColor firstGrey];
    [nameLabel sizeToFit];
    
    [bgLayout addSubview: nameLabel];
    
    // Topic Label
    UILabel *descriptionLabel = [UILabel new];
    descriptionLabel.myTopMargin = 8;
    descriptionLabel.myBottomMargin = 16;
    descriptionLabel.myLeftMargin = descriptionLabel.myRightMargin = 0;
    descriptionLabel.wrapContentHeight = YES;
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.font = [UIFont boldSystemFontOfSize: 18.0];
    
    if (![self.exchangeDic[@"photousefor"][@"description"] isEqual: [NSNull null]]) {
        NSLog(@"description: %@", self.exchangeDic[@"photousefor"][@"description"]);
        descriptionLabel.text = self.exchangeDic[@"photousefor"][@"description"];
        [LabelAttributeStyle changeGapString: descriptionLabel content: descriptionLabel.text];
    }
    descriptionLabel.textColor = [UIColor firstGrey];
    [descriptionLabel sizeToFit];
    
    [bgLayout addSubview: descriptionLabel];
    
    // HorzLayout1
    MyLinearLayout *horzLayout1 = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Horz];    
    horzLayout1.myTopMargin = 16.0;
    horzLayout1.myLeftMargin = horzLayout1.myRightMargin = 0;
    horzLayout1.myBottomMargin = 8.0;
    horzLayout1.wrapContentWidth = YES;
    horzLayout1.wrapContentHeight = YES;
    horzLayout1.myHeight = 28.0;
    
    // modifyContactInfoLabel
    UILabel *modifyContactInfoLabel = [UILabel new];
    modifyContactInfoLabel.wrapContentHeight = YES;
    modifyContactInfoLabel.myTopMargin = modifyContactInfoLabel.myBottomMargin = 8;
    modifyContactInfoLabel.myLeftMargin = 0;
    modifyContactInfoLabel.myRightMargin = 16;
    modifyContactInfoLabel.font = [UIFont boldSystemFontOfSize: 22.0];
    modifyContactInfoLabel.text = @"聯絡資訊";
    [LabelAttributeStyle changeGapString: modifyContactInfoLabel content: modifyContactInfoLabel.text];
    modifyContactInfoLabel.textColor = [UIColor firstGrey];
    [modifyContactInfoLabel sizeToFit];
    [horzLayout1 addSubview: modifyContactInfoLabel];
    
    // lineView
    UIView *lineView = [[UIView alloc] initWithFrame: CGRectMake(0.0, 0.0, bgLayout.bounds.size.width - modifyContactInfoLabel.frame.size.width - 16, 0.5)];
    lineView.wrapContentWidth = YES;
    lineView.myLeftMargin = 16;
    lineView.myRightMargin = 0;
    lineView.myCenterYOffset = 0;
    lineView.backgroundColor = [UIColor thirdGrey];
    [horzLayout1 addSubview: lineView];
    
    [bgLayout addSubview: horzLayout1];
    
    // userLabel
    UILabel *userLabel = [UILabel new];
    userLabel.myTopMargin = 16;
    userLabel.myBottomMargin = 4;
    userLabel.myLeftMargin = 0;
    userLabel.font = [UIFont systemFontOfSize: 18.0];
    userLabel.text = @"真實姓名";
    [LabelAttributeStyle changeGapString: userLabel content: userLabel.text];
    userLabel.textColor = [UIColor firstGrey];
    [userLabel sizeToFit];
    [bgLayout addSubview: userLabel];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // nameTextView
    self.nameTextView = [[UITextView alloc] initWithFrame: CGRectMake(0.0, 0.0, bgLayout.bounds.size.width, 36.0)];
    self.nameTextView.myTopMargin = self.nameTextView.myBottomMargin = 8;
    self.nameTextView.myLeftMargin = self.nameTextView.myRightMargin = 0;
    self.nameTextView.wrapContentHeight = YES;
    self.nameTextView.font = [UIFont systemFontOfSize: 14.0];
    
    if (![[defaults objectForKey: @"nameForExchange"] isEqual: [NSNull null]]) {
        self.nameTextView.text = [defaults objectForKey: @"nameForExchange"];
    }
    
    self.nameTextView.textColor = [UIColor firstGrey];
    self.nameTextView.textContainerInset = UIEdgeInsetsMake(10.0, 5.0, 10.0, 5.0);
    self.nameTextView.layer.cornerRadius = 6.0;
    self.nameTextView.backgroundColor = [UIColor thirdGrey];
    self.nameTextView.heightDime.max(300).min(30);
    self.nameTextView.keyboardType = UIKeyboardTypeDefault;
//    self.nameTextView.inputAccessoryView = toolBarForDoneBtn;
    self.nameTextView.delegate = self;
    [bgLayout addSubview: self.nameTextView];
    
    MyLinearLayout *horzLayout2 = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Horz];
    horzLayout2.myTopMargin = 16.0;
    horzLayout2.myLeftMargin = horzLayout2.myRightMargin = 0;
    horzLayout2.myBottomMargin = 4.0;
    horzLayout2.wrapContentWidth = YES;
    horzLayout2.wrapContentHeight = YES;
    horzLayout2.myHeight = 24.0;
    
    // telephoneLabel
    UILabel *telephoneLabel = [UILabel new];
    telephoneLabel.myTopMargin = 0;
    telephoneLabel.myBottomMargin = 0;
    telephoneLabel.myLeftMargin = 0;
    telephoneLabel.font = [UIFont systemFontOfSize: 18.0];
    telephoneLabel.text = @"電話";
    [LabelAttributeStyle changeGapString: telephoneLabel content: telephoneLabel.text];
    [telephoneLabel sizeToFit];
    [horzLayout2 addSubview: telephoneLabel];
    
    // telephoneInfoLabel
    UILabel *telephoneInfoLabel = [UILabel new];
    telephoneInfoLabel.myTopMargin = 0;
    telephoneInfoLabel.myBottomMargin = 0;
    telephoneInfoLabel.myLeftMargin = 16;
    telephoneInfoLabel.font = [UIFont systemFontOfSize: 18.0];
    telephoneInfoLabel.text = @"使用註冊時的號碼";
    [LabelAttributeStyle changeGapString: telephoneInfoLabel content: telephoneInfoLabel.text];
    telephoneInfoLabel.textColor = [UIColor firstMain];
    [telephoneInfoLabel sizeToFit];
    [horzLayout2 addSubview: telephoneInfoLabel];
    
    [bgLayout addSubview: horzLayout2];
    
    // nameTextView
    MyLinearLayout *telephoneView = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Vert];
    telephoneView.myTopMargin = 4;
    telephoneView.myLeftMargin = telephoneView.myRightMargin = 0;
    telephoneView.wrapContentWidth = YES;
    telephoneView.myHeight = 36.0;
    telephoneView.backgroundColor = [UIColor thirdGrey];
    telephoneView.layer.cornerRadius = kCornerRadius;
    telephoneView.padding = UIEdgeInsetsMake(4.0, 4.0, 4.0, 4.0);

    self.telephoneField = [UITextField new];
    self.telephoneField.wrapContentWidth = YES;
    self.telephoneField.wrapContentHeight = YES;
    self.telephoneField.myTopMargin = self.telephoneField.myBottomMargin = 4;
    self.telephoneField.myLeftMargin = self.telephoneField.myRightMargin = 4;
    self.telephoneField.font = [UIFont systemFontOfSize: 14.0];
    
    if (![[defaults objectForKey: @"telephoneForExchange"] isEqual: [NSNull null]]) {
        self.telephoneField.text = [defaults objectForKey: @"telephoneForExchange"];
    }
    
    self.telephoneField.textColor = [UIColor firstGrey];
    self.telephoneField.delegate = self;
//    self.telephoneField.inputAccessoryView = toolBarForDoneBtn;
    self.telephoneField.keyboardType = UIKeyboardTypeNumberPad;
    [telephoneView addSubview: self.telephoneField];
    
    [bgLayout addSubview: telephoneView];
    
    
    // addressLabel
    UILabel *addressLabel = [UILabel new];
    addressLabel.myTopMargin = 16;
    addressLabel.myBottomMargin = 4;
    addressLabel.myLeftMargin = 0;
    addressLabel.font = [UIFont systemFontOfSize: 18.0];
    addressLabel.text = @"地址";
    [LabelAttributeStyle changeGapString: addressLabel content: addressLabel.text];
    addressLabel.textColor = [UIColor firstGrey];
    [addressLabel sizeToFit];
    [bgLayout addSubview: addressLabel];
    
    // nameTextView
    self.addressTextView = [[UITextView alloc] initWithFrame: CGRectMake(0.0, 0.0, bgLayout.bounds.size.width, 36.0)];
    self.addressTextView.myTopMargin = self.addressTextView.myBottomMargin = 8;
    self.addressTextView.myLeftMargin = self.addressTextView.myRightMargin = 0;
    self.addressTextView.wrapContentHeight = YES;
    self.addressTextView.font = [UIFont systemFontOfSize: 14.0];
    
    if (![[defaults objectForKey: @"addressForExchange"] isEqual: [NSNull null]]) {
        self.addressTextView.text = [defaults objectForKey: @"addressForExchange"];
    }
    
    self.addressTextView.textColor = [UIColor firstGrey];
    self.addressTextView.textContainerInset = UIEdgeInsetsMake(10.0, 5.0, 10.0, 5.0);
    self.addressTextView.layer.cornerRadius = 6.0;
    self.addressTextView.backgroundColor = [UIColor thirdGrey];
    self.addressTextView.heightDime.max(300).min(30);
    self.addressTextView.keyboardType = UIKeyboardTypeDefault;
//    self.addressTextView.inputAccessoryView = toolBarForDoneBtn;
    self.addressTextView.delegate = self;
    [bgLayout addSubview: self.addressTextView];
    
    // NavBarView
    MyLinearLayout *navBarView = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Horz];
    navBarView.wrapContentWidth = YES;
    
    CGFloat navBarHeight = 0;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 1136:
                printf("iPhone 5 or 5S or 5C");
                navBarHeight = 64.0;
                break;
            case 1334:
                printf("iPhone 6/6S/7/8");
                navBarHeight = 64.0;
                break;
            case 1920:
                printf("iPhone 6+/6S+/7+/8+");
                navBarHeight = 64.0;
                break;
            case 2208:
                printf("iPhone 6+/6S+/7+/8+");
                navBarHeight = 64.0;
                break;
            case 2436:
                printf("iPhone X");
                navBarHeight = 88.0;
                break;
            default:
                printf("unknown");
                navBarHeight = 64.0;
                break;
        }
    }
    
    navBarView.myHeight = navBarHeight;
    navBarView.myTopMargin = 0;
    navBarView.myLeftMargin = navBarView.myRightMargin = 0;
    navBarView.backgroundColor = [UIColor barColor];
    
    // Dismiss Btn
    UIButton *dismissBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    [dismissBtn addTarget: self action: @selector(dismiss) forControlEvents: UIControlEventTouchUpInside];
    dismissBtn.frame = CGRectMake(0.0, 0.0, 32.0, 32.0);
    dismissBtn.imageEdgeInsets = UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0);
    dismissBtn.myLeftMargin = 13.0;
    dismissBtn.myRightMargin = 0.5;
    dismissBtn.myBottomMargin = 7.0;
    [dismissBtn setImage: [UIImage imageNamed: @"ic200_cancel_dark.png"] forState: UIControlStateNormal];
    [navBarView addSubview: dismissBtn];
    
    // Time Label
    if (!self.hasExchanged) {
        UILabel *timeLabel = [UILabel new];
        timeLabel.wrapContentWidth = YES;
        timeLabel.myRightMargin = 16;
        timeLabel.myLeftMargin = 0.5;
        timeLabel.myBottomMargin = 10.0;
        timeLabel.numberOfLines = 0;
        
        if ([self.exchangeDic[@"photousefor"][@"endtime"] isEqual: [NSNull null]]) {
            timeLabel.text = @"無期限";
            timeLabel.textColor = [UIColor secondGrey];
        } else {
            timeLabel.text = [wTools remainingTimeCalculation: self.exchangeDic[@"photousefor"][@"endtime"]];
            timeLabel.textColor = [UIColor firstPink];
        }
        [LabelAttributeStyle changeGapString: timeLabel content: timeLabel.text];
        timeLabel.font = [UIFont boldSystemFontOfSize: 20.0];
        [timeLabel sizeToFit];
        [navBarView addSubview: timeLabel];
    }
    
    [self.view addSubview: navBarView];
    
    // BottomBarView
    MyFrameLayout *bottomBarView = [MyFrameLayout new];
    bottomBarView.wrapContentWidth = YES;
    
    CGFloat bottomBarHeight = 0;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 1136:
                printf("iPhone 5 or 5S or 5C");
                bottomBarHeight = 68.0;
                break;
            case 1334:
                printf("iPhone 6/6S/7/8");
                bottomBarHeight = 68.0;
                break;
            case 1920:
                printf("iPhone 6+/6S+/7+/8+");
                bottomBarHeight = 68.0;
                break;
            case 2208:
                printf("iPhone 6+/6S+/7+/8+");
                bottomBarHeight = 68.0;
                break;
            case 2436:
                printf("iPhone X");
                bottomBarHeight = 102.0;
                break;
            default:
                printf("unknown");
                bottomBarHeight = 68.0;
                break;
        }
    }
    
    bottomBarView.myHeight = bottomBarHeight;
    bottomBarView.myBottomMargin = 0;
    bottomBarView.myLeftMargin = bottomBarView.myRightMargin = 0;
    bottomBarView.backgroundColor = [UIColor barColor];
    
    UIButton *sendBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    [sendBtn addTarget: self action: @selector(sendBtnPressed) forControlEvents: UIControlEventTouchUpInside];
    
    if (self.hasExchanged) {
        [sendBtn setTitle: @"送出" forState: UIControlStateNormal];
    } else {
        [sendBtn setTitle: @"立即兌換" forState: UIControlStateNormal];
    }    
    
    sendBtn.frame = CGRectMake(0.0, 0.0, 112.0, 48.0);
    sendBtn.backgroundColor = [UIColor firstMain];
    sendBtn.myCenterOffset = CGPointZero;
    sendBtn.layer.cornerRadius = kCornerRadius;
    
    [bottomBarView addSubview: sendBtn];
    
    [self.view addSubview: bottomBarView];
}

- (void)sendBtnPressed {
    NSLog(@"sendBtnPressed");
    [self savePersonalData];
    [self createJsonStr];
    
//    // Test
//    if ([self.delegate respondsToSelector: @selector(finishExchange:bgV:)]) {
//        [self.delegate finishExchange: self.exchangeDic bgV: self.backgroundView];
//    }
//    [self dismiss];
    
    if (self.hasExchanged) {
        NSLog(@"self.hasExchanged: %d", self.hasExchanged);
        [self updatePhotoUseForUser];
    } else {
        NSLog(@"self.hasExchanged: %d", self.hasExchanged);
        NSLog(@"self.exchangeDic: %@", self.exchangeDic);
        
        NSString *msg = @"注意獎項是否註明現場領取或寄送，如為現場領取則領取方本人須在現場執行兌換動作";
        
        [self showCustomExchangeAlert: msg];
    }
}

#pragma mark - Methods before sending out the data
- (void)savePersonalData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: self.nameTextView.text forKey: @"nameForExchange"];
    [defaults setObject: self.telephoneField.text forKey: @"telephoneForExchange"];
    [defaults setObject: self.addressTextView.text forKey: @"addressForExchange"];
    [defaults synchronize];
}

- (void)createJsonStr {
    NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
    [dataDic setObject: self.addressTextView.text forKey: @"address"];
    [dataDic setObject: self.telephoneField.text forKey: @"cellphone"];
    [dataDic setObject: self.nameTextView.text forKey: @"name"];
    
    NSLog(@"dataDic: %@", dataDic);
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: dataDic
                                                       options: 0
                                                         error: nil];
    self.jsonStr = [[NSString alloc] initWithData: jsonData
                                         encoding: NSUTF8StringEncoding];
}

#pragma mark - calculateImageViewSize
- (void)calculateImageViewSize {
    NSLog(@"calculateImageViewSize");
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    NSLog(@"screenWidth: %f", screenWidth);
    
    CGFloat imgVWidth = screenWidth - 16 * 2;
    NSLog(@"imgVWidth: %f", imgVWidth);
    
    CGFloat imgVHeight = (imgVWidth * self.imageView.image.size.height) / self.imageView.image.size.width;
    NSLog(@"imgVHeight: %f", imgVHeight);
    
    self.imageView.myWidth = imgVWidth;
    self.imageView.myHeight = imgVHeight;
}

#pragma mark - dismissKeyboard
- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

#pragma mark - Create Blur View
- (void)createBlurView {
    NSLog(@"createBlurView");
    [wTools setStatusBarBackgroundColor: [UIColor clearColor]];
    
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectViewForExchangeInfo = [[UIVisualEffectView alloc] initWithEffect:effect];
    effectViewForExchangeInfo.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    effectViewForExchangeInfo.accessibilityIdentifier = @"effectViewForExchangeInfo";
    [self.view addSubview:effectViewForExchangeInfo];
    
    MyLinearLayout *exchangedInfoLinearLayout = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Vert];
    exchangedInfoLinearLayout.mySize = CGSizeMake(self.view.bounds.size.width - 100, self.view.bounds.size.height - 120);
    exchangedInfoLinearLayout.myCenterXOffset = 0;
    exchangedInfoLinearLayout.myCenterYOffset = 0;
    exchangedInfoLinearLayout.accessibilityIdentifier = @"exchangedInfoLinearLayout";
    [self.view addSubview: exchangedInfoLinearLayout];
    [self.view bringSubviewToFront: exchangedInfoLinearLayout];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.myTopMargin = 32;
    imageView.myBottomMargin = 8;
    imageView.myCenterXOffset = 0;
    imageView.image = [UIImage imageNamed: @"pinpin_exchange_success"];
    imageView.mySize = CGSizeMake(150.0, 150.0);
    [exchangedInfoLinearLayout addSubview: imageView];
    
    UILabel *label1 = [UILabel new];
    label1.wrapContentHeight = YES;
    label1.wrapContentWidth = YES;
    label1.myTopMargin = 8;
    label1.myLeftMargin = label1.myRightMargin = 16;
    label1.myBottomMargin = 8;
    label1.numberOfLines = 1;
    label1.textAlignment = NSTextAlignmentCenter;
    label1.text = @"兌換成功";
    [LabelAttributeStyle changeGapString: label1 content: label1.text];
    label1.textColor = [UIColor whiteColor];
    [label1 sizeToFit];
    label1.font = [UIFont boldSystemFontOfSize: 24.0];
    [exchangedInfoLinearLayout addSubview: label1];
    
    UILabel *label2 = [UILabel new];
    label2.wrapContentHeight = YES;
    label2.myTopMargin = 8;
    label2.myLeftMargin = label2.myRightMargin = 16;
    label2.myBottomMargin = 16;
    label2.numberOfLines = 0;
    label2.textAlignment = NSTextAlignmentCenter;
    label2.text = @"獎項資訊已保存在個人專區 > 選單 > 兌換清單";
    [LabelAttributeStyle changeGapString: label2 content: label2.text];
    label2.textColor = [UIColor whiteColor];
    [label2 sizeToFit];
    label2.font = [UIFont boldSystemFontOfSize: 20.0];
    [exchangedInfoLinearLayout addSubview: label2];
    
    UIButton *doneBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    doneBtn.myTopMargin = 16;
    doneBtn.myCenterXOffset = 0;
    [doneBtn addTarget: self
                action: @selector(doneBtnTouchDown:)
      forControlEvents: UIControlEventTouchDown];
    [doneBtn addTarget: self
                action: @selector(doneBtnTouchUpInside:)
      forControlEvents: UIControlEventTouchUpInside];
    [doneBtn addTarget: self
                action: @selector(doneBtnTouchDragExit:)
      forControlEvents: UIControlEventTouchDragExit];
    
    doneBtn.frame = CGRectMake(0.0, 0.0, 100.0, 70.0);
    [doneBtn setTitle: @"我知道了!" forState: UIControlStateNormal];
    doneBtn.titleLabel.font = [UIFont systemFontOfSize: 18.0];
    doneBtn.backgroundColor = [UIColor clearColor];
    doneBtn.titleEdgeInsets = UIEdgeInsetsMake(4.0, 4.0, 4.0, 4.0);
    doneBtn.layer.cornerRadius = kCornerRadius;
    [exchangedInfoLinearLayout addSubview: doneBtn];
}

#pragma mark - Done Btn Selector Methods
- (void)doneBtnTouchDown:(UIButton *)btn {
    btn.backgroundColor = [UIColor secondMain];
}

- (void)doneBtnTouchUpInside:(UIButton *)btn {
    [wTools setStatusBarBackgroundColor: [UIColor whiteColor]];
    
    btn.backgroundColor = [UIColor clearColor];
    if ([self.delegate respondsToSelector: @selector(finishExchange:bgV:)]) {
        [self.delegate finishExchange: self.exchangeDic  bgV: self.backgroundView];
    }
    
    [self dismiss];
}

- (void)doneBtnTouchDragExit:(UIButton *)btn {
    btn.backgroundColor = [UIColor clearColor];
}

#pragma mark - Dismiss Method
- (void)dismiss {
    [self.navigationController popViewControllerAnimated: YES];
}

#pragma mark - gainPhotoUseForUser

// 106
- (void)gainPhotoUseForUser {
    NSLog(@"gainPhotoUseForUser");
    
    [wTools ShowMBProgressHUD];
    
    NSString *photoUseForUserIdStr = [NSString stringWithFormat: @"%ld", (long)photoUseForUserId];
    NSLog(@"photoUseForUserIdStr: %@", photoUseForUserIdStr);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *response = [boxAPI gainPhotoUseForUser: self.jsonStr
                                       photoUseForUserId: photoUseForUserIdStr
                                                   token: [wTools getUserToken]
                                                  userId: [wTools getUserID]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"response from gainPhotoUseForUser");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ExchangeInfoEditViewController");
                    NSLog(@"gainPhotoUseForUser");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"gainPhotoUseForUser"];
                } else {
                    NSLog(@"Get Real Response");
                    NSLog(@"Get response from gainPhotoUseForUser");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    NSLog(@"dic: %@", dic);
                    
                    if ([dic[@"result"] isEqualToString: @"SYSTEM_OK"]) {
                        NSLog(@"SYSTEM_OK");
                        
                        if (!self.isExisting) {
                            [self insertBookmark];
                        } else {
                            NSLog(@"self.exchangeDic.allKeys: %@", self.exchangeDic.allKeys);
                            
                            // For returning ExchangeListVC to move to other viewControllers
                            [self.exchangeDic[@"photo"] setObject: [NSNumber numberWithBool: YES] forKey: @"has_gained"];
                            NSLog(@"self.exchangeDic: %@", self.exchangeDic);
                            
//                            if ([self.delegate respondsToSelector: @selector(finishExchange:bgV:)]) {
//                                [self.delegate finishExchange: self.exchangeDic  bgV: self.backgroundView];
//                            }
                            
                            [self createBlurView];
                        }
                    } else if ([dic[@"result"] isEqualToString: @"SYSTEM_ERROR"]) {
                        NSLog(@"SYSTEM_ERROR");
                        NSLog(@"失敗：%@",dic[@"message"]);
                        NSString *msg = dic[@"message"];
                        
                        if (msg == nil) {
                            msg = NSLocalizedString(@"Host-NotAvailable", @"");
                        }
                        [self showCustomErrorAlert: dic[@"message"]];
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
                    } else if ([dic[@"result"] isEqualToString: @"USER_ERROR"]) {
                        NSLog(@"錯誤：%@",dic[@"message"]);
                        NSString *msg = dic[@"message"];
                        
                        if (msg == nil) {
                            msg = NSLocalizedString(@"Host-NotAvailable", @"");
                        }
                        [self showCustomErrorAlert: dic[@"message"]];
                    }
                }
            }
        });
    });
}

// 110
- (void)processExchangeResult:(NSDictionary *)dic {
    if ([dic[@"result"] isEqualToString: @"SYSTEM_OK"]) {
        NSLog(@"SYSTEM_OK");
        NSLog(@"dic: %@", dic);
        
        @try {
            photoUseForUserId = [dic[@"data"][@"photousefor_user"][@"photousefor_user_id"] integerValue];
            NSLog(@"photoUseForUserId: %ld", (long)photoUseForUserId);
            [self gainPhotoUseForUser];
        } @catch (NSException *exception) {
            // Print exception information
            NSLog( @"NSException caught" );
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
            return;
        }
    } else if ([dic[@"result"] isEqualToString: @"SYSTEM_ERROR"]) {
        NSLog(@"SYSTEM_ERROR");
        [self showDicMessage: dic];
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
    } else if ([dic[@"result"] isEqualToString: @"PHOTOUSEFOR_HAS_EXPIRED"]) {
        [self showDicMessage: dic];
    } else if ([dic[@"result"] isEqualToString: @"PHOTOUSEFOR_HAS_SENT_FINISHED"]) {
        [self showDicMessage: dic];
    } else if ([dic[@"result"] isEqualToString: @"PHOTOUSEFOR_NOT_YET_STARTED"]) {
        [self showDicMessage: dic];
    } else if ([dic[@"result"] isEqualToString: @"PHOTOUSEFOR_USER_HAS_EXCHANGED"]) {
        [self showDicMessage: dic];
    } else if ([dic[@"result"] isEqualToString: @"PHOTOUSEFOR_USER_HAS_GAINED"]) {
        [self showDicMessage: dic];
    } else if ([dic[@"result"] isEqualToString: @"PHOTOUSEFOR_USER_HAS_SLOTTED"]) {
        [self showDicMessage: dic];
    }
}
- (void)exchangePhotoUseFor {
    NSLog(@"exchangePhotoUseFor");
    
    [wTools ShowMBProgressHUD];
    
    UIDevice *device = [UIDevice currentDevice];
    NSString *currentDeviceId = [[device identifierForVendor] UUIDString];
    
    NSInteger photoId = [self.exchangeDic[@"photo"][@"photo_id"] integerValue];
    NSString *photoIdStr = [NSString stringWithFormat: @"%ld", (long)photoId];
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *response = [boxAPI exchangePhotoUseFor: currentDeviceId
                                                 photoId: photoIdStr
                                                   token: [wTools getUserToken]
                                                  userId: [wTools getUserID]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"response from exchangePhotoUseFor");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ExchangeInfoEditViewController");
                    NSLog(@"exchangePhotoUseFor");
                    
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"exchangePhotoUseFor"];
                } else {
                    NSLog(@"Get Real Response");
                    NSLog(@"Get response from exchangePhotoUseFor");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    NSLog(@"dic: %@", dic);
                    
                    [wself processExchangeResult:dic];
                }
            }
        });
    });
}

- (void)showDicMessage:(NSDictionary *)dic {
    NSLog(@"錯誤訊息：%@",dic[@"message"]);
    NSString *msg = dic[@"message"];
    
    if (msg == nil) {
        msg = NSLocalizedString(@"Host-NotAvailable", @"");
    }
    [self showCustomErrorAlert: dic[@"message"]];
}

// 109
- (void)insertBookmark {
    NSLog(@"insertBookmark");
    
    [wTools ShowMBProgressHUD];
    
    NSInteger photoId = [self.exchangeDic[@"photo"][@"photo_id"] integerValue];
    NSString *photoIdStr = [NSString stringWithFormat: @"%ld", (long)photoId];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *response = [boxAPI insertBookmark: photoIdStr
                                              token: [wTools getUserToken]
                                             userId: [wTools getUserID]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"response from insertBookmark");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ExchangeInfoEditViewController");
                    NSLog(@"insertBookmark");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"insertBookmark"];
                } else {
                    NSLog(@"Get Real Response");
                    NSLog(@"Get response from insertBookmark");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    NSLog(@"dic: %@", dic);
                    
                    if ([dic[@"result"] isEqualToString: @"SYSTEM_OK"]) {
                        NSLog(@"SYSTEM_OK");
                        
                        NSLog(@"self.exchangeDic.allKeys: %@", self.exchangeDic.allKeys);
                        
                        // For returning ExchangeListVC to move to other viewControllers
                        [self.exchangeDic[@"photo"] setObject: [NSNumber numberWithBool: YES] forKey: @"has_gained"];
                        NSLog(@"self.exchangeDic: %@", self.exchangeDic);
                        
//                        if ([self.delegate respondsToSelector: @selector(finishExchange:bgV:)]) {
//                            [self.delegate finishExchange: self.exchangeDic bgV: self.backgroundView];
//                        }
                        
                        [self createBlurView];
                    } else if ([dic[@"result"] isEqualToString: @"SYSTEM_ERROR"]) {
                        NSLog(@"SYSTEM_ERROR");
                        NSLog(@"錯誤：%@",dic[@"message"]);
                        NSString *msg = dic[@"message"];
                        
                        if (msg == nil) {
                            msg = NSLocalizedString(@"Host-NotAvailable", @"");
                        }
                        [self showCustomErrorAlert: dic[@"message"]];
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
                    } else if ([dic[@"result"] isEqualToString: @"USER_ERROR"]) {
                        NSLog(@"錯誤：%@",dic[@"message"]);
                        NSString *msg = dic[@"message"];
                        
                        if (msg == nil) {
                            msg = NSLocalizedString(@"Host-NotAvailable", @"");
                        }
                        [self showCustomErrorAlert: dic[@"message"]];
                    }
                }
            }
        });
    });
}

// 43
- (void)updatePhotoUseForUser {
    NSLog(@"updatePhotoUseForUser");
    
    [wTools ShowMBProgressHUD];
    
    NSString *photoUseForUserIdStr = [NSString stringWithFormat: @"%ld", (long)photoUseForUserId];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *response = [boxAPI updatePhotoUseForUser: self.jsonStr
                                         photoUseForUserId: photoUseForUserIdStr
                                                     token: [wTools getUserToken]
                                                    userId: [wTools getUserID]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"response from updatePhotoUseForUser");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ExchangeInfoEditViewController");
                    NSLog(@"updatePhotoUseForUser");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"updatePhotoUseForUser"];
                } else {
                    NSLog(@"Get Real Response");
                    NSLog(@"Get response from updatePhotoUseForUser");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    NSLog(@"dic: %@", dic);
                    NSLog(@"dic message: %@", dic[@"message"]);
                    
                    if ([dic[@"result"] isEqualToString: @"SYSTEM_OK"]) {
                        NSLog(@"SYSTEM_OK");
                        NSLog(@"dic: %@", dic);
                        
                        [self dismiss];
                        
                        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                        style.messageColor = [UIColor whiteColor];
                        style.backgroundColor = [UIColor firstMain];
                        [self.view makeToast: @"修改完成"
                                    duration: 1.0
                                    position: CSToastPositionBottom
                                       style: style];
                    } else if ([dic[@"result"] isEqualToString: @"SYSTEM_ERROR"]) {
                        NSLog(@"SYSTEM_ERROR");
                        NSLog(@"失敗：%@",dic[@"message"]);
                        NSString *msg = dic[@"message"];
                        
                        if (msg == nil) {
                            msg = NSLocalizedString(@"Host-NotAvailable", @"");
                        }
                        [self showCustomErrorAlert: dic[@"message"]];
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
                    } else if ([dic[@"result"] isEqualToString: @"USER_ERROR"]) {
                        NSLog(@"USER_ERROR");
                        NSLog(@"失敗：%@",dic[@"message"]);
                        
                        NSString *msg = dic[@"message"];
                        if (msg == nil) {
                            msg = NSLocalizedString(@"Host-NotAvailable", @"");
                        }
                        [self showCustomErrorAlert: dic[@"message"]];
                    }
                }
            }
        });
    });
}

- (void)logOut {
    [wTools logOut];
}

#pragma mark - UITextViewDelegate Methods
- (void)textViewDidBeginEditing:(UITextView *)textView {
    selectTextView = textView;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    selectTextView = nil;
}

- (void)textViewDidChange:(UITextView *)textView {
    MyBaseLayout *layout = (MyBaseLayout *)textView.superview;
    [layout setNeedsLayout];
    
    //这里设置在布局结束后将textView滚动到光标所在的位置了。在布局执行布局完毕后如果设置了endLayoutBlock的话可以在这个block里面读取布局里面子视图的真实布局位置和尺寸，也就是可以在block内部读取每个子视图的真实的frame的值。
    layout.endLayoutBlock = ^{
        NSRange rg = textView.selectedRange;
        [textView scrollRangeToVisible: rg];
    };
}

#pragma mark - UITextField Delegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"textFieldDidBeginEditing");
    selectTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"textFieldDidEndEditing");
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
    NSLog(@"");
    NSLog(@"addKeyboardNotification");
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
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
- (void)keyboardDidShow:(NSNotification*)aNotification
{
    NSLog(@"");
    NSLog(@"keyboardWasShown");
    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey: UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSLog(@"kbSize: %@", NSStringFromCGSize(kbSize));

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;

    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    NSLog(@"aRect: %@", NSStringFromCGRect(aRect));
    aRect.size.height -= kbSize.height;
    NSLog(@"aRect: %@", NSStringFromCGRect(aRect));
    
    UIView *activeField;

    if (selectTextView != nil) {
        activeField = selectTextView;
    } else if (selectTextField != nil) {
        activeField = selectTextField.superview;
    }
    
    NSLog(@"activeField.frame.origin: %@", NSStringFromCGPoint(activeField.frame.origin));
    
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        NSLog(@"!CGRectContainsPoint(aRect, activeField.frame.origin)");
        [self.scrollView scrollRectToVisible: activeField.frame animated: YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    //UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    CGFloat bottomPadding = 0;

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 1136:
                printf("iPhone 5 or 5S or 5C");
                bottomPadding = 68.0;
                break;
            case 1334:
                printf("iPhone 6/6S/7/8");
                bottomPadding = 68.0;
                break;
            case 1920:
                printf("iPhone 6+/6S+/7+/8+");
                bottomPadding = 68.0;
                break;
            case 2208:
                printf("iPhone 6+/6S+/7+/8+");
                bottomPadding = 68.0;
                break;
            case 2436:
                printf("iPhone X");
                bottomPadding = 102.0;
                break;
            default:
                printf("unknown");
                bottomPadding = 68.0;
                break;
        }
    }

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(64.0, 0.0, bottomPadding, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - Custom Alert for Checking Exchange
- (void)showCustomExchangeAlert:(NSString *)msg {
    CustomIOSAlertView *alertAudioModeView = [[CustomIOSAlertView alloc] init];
    //[alertAudioModeView setContainerView: [self createExchangeContainerView: msg]];
    [alertAudioModeView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
    alertAudioModeView.arrangeStyle = @"Horizontal";
    
    [alertAudioModeView setButtonTitles: [NSMutableArray arrayWithObjects: @"取消", @"兌換", nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertAudioModeView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor clearColor], [UIColor clearColor],nil]];
    [alertAudioModeView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstGrey], nil]];
    [alertAudioModeView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    //alertView.arrangeStyle = @"Vertical";
    
    __weak CustomIOSAlertView *weakAlertAudioModeView = alertAudioModeView;
    __weak typeof(self) weakSelf = self;
    
    [alertAudioModeView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertAudioModeView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertAudioModeView tag]);
        
        [weakAlertAudioModeView close];
        
        if (buttonIndex == 0) {
            
        } else {
            if ([self.exchangeDic[@"photousefor_user"] isEqual: [NSNull null]]) {
                NSLog(@"self.exchangeDic photousefor_user is Equal to null");
                [weakSelf exchangePhotoUseFor];
            } else {
                NSLog(@"self.exchangeDic photousefor_user is not Equal to null");
                [weakSelf gainPhotoUseForUser];
            }
        }
    }];
    [alertAudioModeView setUseMotionEffects: YES];
    [alertAudioModeView show];
}

- (UIView *)createExchangeContainerView: (NSString *)msg
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
            if ([protocolName isEqualToString: @"gainPhotoUseForUser"]) {
                [weakSelf gainPhotoUseForUser];
            } else if ([protocolName isEqualToString: @"exchangePhotoUseFor"]) {
                [weakSelf exchangePhotoUseFor];
            } else if ([protocolName isEqualToString: @"insertBookmark"]) {
                [weakSelf insertBookmark];
            } else if ([protocolName isEqualToString: @"updatePhotoUseForUser"]) {
                [weakSelf updatePhotoUseForUser];
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

- (BOOL)shouldAutorotate
{
    NSLog(@"shouldAutorotate");
    return NO;
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
//{
//    NSLog(@"shouldAutorotateToInterfaceOrientation");
//    return NO;
//}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    NSLog(@"supportedInterfaceOrientations");
    
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    NSLog(@"preferredInterfaceOrientationForPresentation");
    return UIInterfaceOrientationPortrait;
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
