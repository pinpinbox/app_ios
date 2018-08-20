//
//  AlbumCollectionViewController.m
//  wPinpinbox
//
//  Created by David on 4/23/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "AlbumCollectionViewController.h"
#import "AppDelegate.h"
#import "MyTabBarController.h"

#import "MyLayout.h"
#import "UIColor+Extensions.h"
#import "CAPSPageMenu.h"
#import "MeTabViewController.h"

//#import "GetAlbumListViewController.h"
#import "MyAlbumCollectionViewController.h"
#import "OtherCollectionViewController.h"
//#import "TestReadBookViewController.h"
#import "MBProgressHUD.h"
#import "CustomIOSAlertView.h"
#import "wTools.h"
#import "boxAPI.h"
#import "CalbumlistViewController.h"
#import "AlbumCreationViewController.h"
#import "AlbumSettingViewController.h"
#import "NewEventPostViewController.h"

#import "GlobalVars.h"

#import "DDAUIActionSheetViewController.h"

#import "ContentCheckingViewController.h"

@interface AlbumCollectionViewController () <CAPSPageMenuDelegate, MyAlbumCollectionViewControllerDelegate, OtherCollectionViewControllerDelegate, CalbumlistViewControllerDelegate, DDAUIActionSheetViewControllerDelegate, UIGestureRecognizerDelegate>
@property (nonatomic) CAPSPageMenu *pageMenu;
//@property (nonatomic) UIView *navBarView;
@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarHeight;

@property (nonatomic, strong) UIView *underLineView;
@property (nonatomic, copy) void(^action)(NSInteger index);

@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UILabel *centerLabel;
@property (nonatomic, strong) UILabel *rightLabel;

@property (nonatomic) UIVisualEffectView *effectView;
@property (nonatomic) DDAUIActionSheetViewController *customEditActionSheet;
@end

@implementation AlbumCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.        
    NSLog(@"");
    NSLog(@"AlbumCollectionViewController");
    NSLog(@"viewDidLoad");
    
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    appDelegate.myNav.interactivePopGestureRecognizer.delegate = self;
    
    // CustomActionSheet
    self.customEditActionSheet = [[DDAUIActionSheetViewController alloc] init];
    self.customEditActionSheet.delegate = self;
    self.customEditActionSheet.topicStr = @"你 想 做 什 麼?";
    
    NSLog(@"");
    NSLog(@"app.myNav");
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    for (id controller in app.myNav.viewControllers) {
        NSLog(@"controller: %@", controller);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"");
    NSLog(@"AlbumCollectionViewController");
    NSLog(@"viewWillAppear");
    
    [self initialValueSetup];
    
    for (UIView *view in self.tabBarController.view.subviews) {
        UIButton *btn = (UIButton *)[view viewWithTag: 104];
        btn.hidden = YES;
    }        
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    appDelegate.myNav.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    appDelegate.myNav.interactivePopGestureRecognizer.enabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                break;
            default:
                printf("unknown");
                break;
        }
    }
}

#pragma mark -
- (void)initialValueSetup {
    NSLog(@"");
    NSLog(@"initialValueSetup");
    self.navBarView.backgroundColor = [UIColor barColor];
    [self createPageMenu];
    [self createAnimateSegmentView];
}

- (void)createPageMenu {
    NSLog(@"");
    NSLog(@"createPageMenu");
    // ViewController Array Setup
    CalbumlistViewController *myVC = [[UIStoryboard storyboardWithName: @"Calbumlist" bundle: nil] instantiateViewControllerWithIdentifier: @"CalbumlistViewController"];
    myVC.title = @"";
    myVC.collectionType = 0;
    myVC.delegate = self;
    
    CalbumlistViewController *otherVC = [[UIStoryboard storyboardWithName: @"Calbumlist" bundle: nil] instantiateViewControllerWithIdentifier: @"CalbumlistViewController"];
    otherVC.title = @"";
    otherVC.collectionType = 1;
    otherVC.delegate = self;
    
    CalbumlistViewController *collaborateVC = [[UIStoryboard storyboardWithName: @"Calbumlist" bundle: nil] instantiateViewControllerWithIdentifier: @"CalbumlistViewController"];
    collaborateVC.title = @"";
    collaborateVC.collectionType = 2;
    collaborateVC.delegate = self;
    
    // CAPSPageMenuOptionViewBackgroundColor is backgroundColor setting    
    
    NSArray *controllerArray = @[myVC, otherVC, collaborateVC];
    NSDictionary *parameters = @{
                                 CAPSPageMenuOptionScrollMenuBackgroundColor: [UIColor clearColor],
                                 CAPSPageMenuOptionViewBackgroundColor: [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],
                                 CAPSPageMenuOptionSelectionIndicatorColor: [UIColor clearColor],
                                 CAPSPageMenuOptionBottomMenuHairlineColor: [UIColor clearColor],
                                 CAPSPageMenuOptionMenuItemFont: [UIFont fontWithName:@"HelveticaNeue" size:13.0],
                                 CAPSPageMenuOptionMenuHeight: @(64.0),
                                 CAPSPageMenuOptionMenuItemWidth: @(90.0),
                                 CAPSPageMenuOptionCenterMenuItems: @(YES)
                                 };
    
    CGFloat y = 0;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 1136:
                printf("iPhone 5 or 5S or 5C");
                y = 4;
                break;
            case 1334:
                printf("iPhone 6/6S/7/8");
                y = 4;
                break;
            case 1920:
                printf("iPhone 6+/6S+/7+/8+");
                y = 4;
                break;
            case 2208:
                printf("iPhone 6+/6S+c/7+/8+");
                y = 4;
                break;
            case 2436:
                printf("iPhone X");
                self.navBarHeight.constant = navBarHeightConstant;
                y = 22.0;
                break;
            default:
                printf("unknown");
                y = 4;
                break;
        }
    }
    
    self.pageMenu = [[CAPSPageMenu alloc] initWithViewControllers:controllerArray frame:CGRectMake(0.0, y, self.view.frame.size.width, self.view.frame.size.height) options:parameters];
    self.pageMenu.delegate = self;
    self.pageMenu.view.myTopMargin = 0;
    
    [self.view addSubview: self.pageMenu.view];
    [self.view bringSubviewToFront: self.navBarView];
    
//    self.navBarView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.view.bounds.size.width, 64)];
//    [self.view addSubview: self.navBarView];
    
//    UIButton *backBtn = [UIButton buttonWithType: UIButtonTypeCustom];
//    [backBtn addTarget: self action: @selector(backBtnPress:) forControlEvents: UIControlEventTouchUpInside];
//    [backBtn setImage: [UIImage imageNamed: @"ic200_arrow_left_dark.png"] forState: UIControlStateNormal];
//    backBtn.frame = CGRectMake(5, 20, 40, 40);
//    backBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
//    [self.navBarView addSubview: backBtn];
}

- (void)createAnimateSegmentView {
    NSLog(@"");
    NSLog(@"createAnimateSegmentView");
    [self setItemChangedAction:^(NSInteger index) {
        NSLog(@"index: %ld", (long)index);
    }];
    
    MyFrameLayout *rootLayout = [MyFrameLayout new];
    rootLayout.widthDime.equalTo(self.navBarView.widthDime).multiply(2/3.0);
    rootLayout.heightDime.equalTo(@48);
    rootLayout.myRightMargin = 0;
    rootLayout.myBottomMargin = 0;
    [self.navBarView addSubview: rootLayout];
    
    // Left Label
    self.leftLabel = [UILabel new];
    self.leftLabel.text = @"我的作品";
    self.leftLabel.font = [UIFont systemFontOfSize:15];
    [self.leftLabel sizeToFit];
    self.leftLabel.centerXPos.equalTo(@0);
    self.leftLabel.centerYPos.equalTo(@0); //标题尺寸由内容包裹，位置在布局视图中居中。
    
    // Left Item Layout
    //MyFrameLayout *leftItemLayout = [self createItemLayout: @"我的作品" withTag:0];
    MyFrameLayout *leftItemLayout = [MyFrameLayout new];
    leftItemLayout.tag = 0;
    [leftItemLayout setTarget:self action:@selector(handleTap:)];
    leftItemLayout.widthDime.equalTo(rootLayout.widthDime).multiply(1/3.0);
    leftItemLayout.heightDime.equalTo(rootLayout.heightDime);
    leftItemLayout.highlightedOpacity = 0.5;
    
    [leftItemLayout addSubview: self.leftLabel];
    [rootLayout addSubview:leftItemLayout];
    
    // Center Label
    self.centerLabel = [UILabel new];
    self.centerLabel.text = @"其他收藏";
    self.centerLabel.font = [UIFont systemFontOfSize:15];
    [self.centerLabel sizeToFit];
    self.centerLabel.centerXPos.equalTo(@0);
    self.centerLabel.centerYPos.equalTo(@0); //标题尺寸由内容包裹，位置在布局视图中居中。
    self.centerLabel.textColor = [UIColor thirdGrey];
    
    //MyFrameLayout *centerItemLayout = [self createItemLayout: @"其他收藏" withTag:1];
    
    // Center Item Layout
    MyFrameLayout *centerItemLayout = [MyFrameLayout new];
    centerItemLayout.tag = 1;
    [centerItemLayout setTarget:self action:@selector(handleTap:)];
    centerItemLayout.widthDime.equalTo(rootLayout.widthDime).multiply(1/3.0);
    centerItemLayout.heightDime.equalTo(rootLayout.heightDime);
    centerItemLayout.centerXPos.equalTo(@0);
    centerItemLayout.highlightedOpacity = 0.5;
    
    [centerItemLayout addSubview: self.centerLabel];
    [rootLayout addSubview:centerItemLayout];
    
    // Right Label
    self.rightLabel = [UILabel new];
    self.rightLabel.text = @"共用協作";
    self.rightLabel.font = [UIFont systemFontOfSize:15];
    [self.rightLabel sizeToFit];
    self.rightLabel.centerXPos.equalTo(@0);
    self.rightLabel.centerYPos.equalTo(@0); //标题尺寸由内容包裹，位置在布局视图中居中。
    self.rightLabel.textColor = [UIColor thirdGrey];
    
    // Right Item Layout
    //MyFrameLayout *rightItemLayout = [self createItemLayout: @"共用條件" withTag:2];
    MyFrameLayout *rightItemLayout = [MyFrameLayout new];
    rightItemLayout.tag = 2;
    [rightItemLayout setTarget:self action:@selector(handleTap:)];
    rightItemLayout.widthDime.equalTo(rootLayout.widthDime).multiply(1/3.0);
    rightItemLayout.heightDime.equalTo(rootLayout.heightDime);
    rightItemLayout.rightPos.equalTo(@0);
    rightItemLayout.highlightedOpacity = 0.5;
    
    [rightItemLayout addSubview: self.rightLabel];
    [rootLayout addSubview:rightItemLayout];
    
    //底部的横线
    _underLineView = [UIView new];
    _underLineView.backgroundColor = [UIColor darkMain];
    _underLineView.widthDime.equalTo(rootLayout.widthDime).multiply(1/3.0);
    _underLineView.heightDime.equalTo(@2);
    _underLineView.bottomPos.equalTo(@0);
    _underLineView.leftPos.equalTo(@0).active = YES;   //设置左边位置有效
    _underLineView.centerXPos.equalTo(@0).active = NO;  //设置水平中间位置无效
    _underLineView.rightPos.equalTo(@0).active = NO;    //设置右边位置无效
    [rootLayout addSubview:_underLineView];
}

- (void)setItemChangedAction:(void(^)(NSInteger index))action {
    self.action = [action copy];
}

#pragma mark -- Layout Construction
-(MyFrameLayout*)createItemLayout:(NSString*)title withTag:(NSInteger)tag
{
    //创建一个框架条目布局，并设置触摸处理事件
    MyFrameLayout *itemLayout = [MyFrameLayout new];
    itemLayout.tag = tag;
    [itemLayout setTarget:self action:@selector(handleTap:)];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:15];
    [titleLabel sizeToFit];
    titleLabel.centerXPos.equalTo(@0);
    titleLabel.centerYPos.equalTo(@0); //标题尺寸由内容包裹，位置在布局视图中居中。
    [itemLayout addSubview:titleLabel];
    
    return itemLayout;
}

-(void)handleTap:(MyBaseLayout*)sender
{
    switch (sender.tag) {
        case 0:
            self.underLineView.leftPos.active = YES;
            self.underLineView.centerXPos.active = NO;
            self.underLineView.rightPos.active = NO;
            
            self.leftLabel.textColor = [UIColor blackColor];
            self.centerLabel.textColor = [UIColor thirdGrey];
            self.rightLabel.textColor = [UIColor thirdGrey];
            
            [self.pageMenu moveToPage: 0];
            break;
        case 1:
            self.underLineView.leftPos.active = NO;
            self.underLineView.centerXPos.active = YES;
            self.underLineView.rightPos.active = NO;
            
            self.leftLabel.textColor = [UIColor thirdGrey];
            self.centerLabel.textColor = [UIColor blackColor];
            self.rightLabel.textColor = [UIColor thirdGrey];
            
            [self.pageMenu moveToPage: 1];
            break;
        case 2:
            
            self.underLineView.leftPos.active = NO;
            self.underLineView.centerXPos.active = NO;
            self.underLineView.rightPos.active = YES;
            
            self.leftLabel.textColor = [UIColor thirdGrey];
            self.centerLabel.textColor = [UIColor thirdGrey];
            self.rightLabel.textColor = [UIColor blackColor];
            
            [self.pageMenu moveToPage: 2];
             
            /*
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"" message: @"即將推出，敬請期待" preferredStyle: UIAlertControllerStyleAlert];
            UIAlertAction *okBtn = [UIAlertAction actionWithTitle: @"確定" style: UIAlertActionStyleDefault handler: nil];
            [alert addAction: okBtn];
            [self presentViewController: alert animated: YES completion: nil];
        }
            */
            break;
        default:
            NSAssert(0, @"oops!");
            break;
    }
    
    MyBaseLayout *layout = (MyBaseLayout*)sender.superview;
    [layout layoutAnimationWithDuration:0.2];
    
    if (self.action != nil)
        self.action(sender.tag);
}

- (void)didMoveToPage:(UIViewController *)controller index:(NSInteger)index
{
    NSLog(@"didMoveToPage index: %ld", (long)index);
    [self changeViewAndLabel: index];
    
    [wTools setStatusBarBackgroundColor: [UIColor colorWithRed: 255.0 green: 255.0 blue: 255.0 alpha: 1.0]];
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
}

- (void)willMoveToPage:(UIViewController *)controller index:(NSInteger)index
{
    NSLog(@"willMoveToPage index: %ld", (long)index);
    [self changeViewAndLabel: index];
}

- (void)setStatusBarBackgroundColor:(UIColor *)color {
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey: @"statusBarWindow"] valueForKey: @"statusBar"];
    
    if ([statusBar respondsToSelector: @selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}

- (void)changeViewAndLabel: (NSInteger)index
{
    switch (index) {
        case 0:
            self.underLineView.leftPos.active = YES;
            self.underLineView.centerXPos.active = NO;
            self.underLineView.rightPos.active = NO;
            
            self.leftLabel.textColor = [UIColor blackColor];
            self.centerLabel.textColor = [UIColor thirdGrey];
            self.rightLabel.textColor = [UIColor thirdGrey];
            break;
        case 1:
            self.underLineView.leftPos.active = NO;
            self.underLineView.centerXPos.active = YES;
            self.underLineView.rightPos.active = NO;
            
            self.leftLabel.textColor = [UIColor thirdGrey];
            self.centerLabel.textColor = [UIColor blackColor];
            self.rightLabel.textColor = [UIColor thirdGrey];
            break;
        case 2:
            self.underLineView.leftPos.active = NO;
            self.underLineView.centerXPos.active = NO;
            self.underLineView.rightPos.active = YES;
            
            self.leftLabel.textColor = [UIColor thirdGrey];
            self.centerLabel.textColor = [UIColor thirdGrey];
            self.rightLabel.textColor = [UIColor blackColor];
            break;
        default:
            break;
    }
}

- (IBAction)backBtnPress:(id)sender {
    NSLog(@"backBtnPress");
    NSLog(@"self.navigationController");
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (self.postMode) {
        for (UIViewController *vc in app.myNav.viewControllers) {
            NSLog(@"vc: %@", vc);
            
            if ([vc isKindOfClass: [NewEventPostViewController class]]) {
                [app.myNav popToViewController: vc animated: YES];
                return;
            }
        }
    }
    
    for (id controller in app.myNav.viewControllers) {
        NSLog(@"controller: %@", controller);
        
        if ([controller isKindOfClass: [MeTabViewController class]]) {
            [self.navigationController popToViewController: controller animated: YES];
            return;
        }
    }
    
    for (id controller in app.myNav.viewControllers) {
        NSLog(@"controller: %@", controller);
        
        if ([controller isKindOfClass: [MyTabBarController class]]) {
            [app.myNav popToViewController: controller animated: YES];
            return;
        }
    }
}

#pragma mark - CustomActionSheet
- (void)showCustomEditActionSheet: (NSString *)albumId
                       templateId: (NSString *)templateId
                  shareCollection: (BOOL)shareCollection
                         hasImage: (BOOL)hasImage
{
    NSLog(@"showCustomEditActionSheet");
    [wTools setStatusBarBackgroundColor: [UIColor clearColor]];
    
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle: UIBlurEffectStyleDark];
    [UIView animateWithDuration: kAnimateActionSheet animations:^{
        self.effectView = [[UIVisualEffectView alloc] initWithEffect: blurEffect];
    }];
    self.effectView.frame = self.view.frame;
    self.effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.effectView.myLeftMargin = self.effectView.myRightMargin = 0;
    self.effectView.myTopMargin = self.effectView.myBottomMargin = 0;
    self.effectView.alpha = 0.8;
    
    [self.view addSubview: self.effectView];
    
    // Custom ActionSheet Setting
    [self.view addSubview: self.customEditActionSheet.view];
    [self.customEditActionSheet viewWillAppear: NO];
    
    [self.customEditActionSheet addSelectItem: @""
                                        title: @"作品編輯"
                                       btnStr: @""
                                       tagInt: 1
                                identifierStr: @"toAlbumCreationVC"];
    
    [self.customEditActionSheet addSelectItem: @""
                                        title: @"修改資訊"
                                       btnStr: @""
                                       tagInt: 2
                                identifierStr: @"toAlbumSettingVC"];
    
    __weak typeof(self) weakSelf = self;
    
    self.customEditActionSheet.customViewBlock = ^(NSInteger tagId, BOOL isTouchDown, NSString *identifierStr) {
        NSLog(@"");
        NSLog(@"self.customEditActionSheet.customViewBlock");
        NSLog(@"tagId: %ld", (long)tagId);
        NSLog(@"isTouchDown: %d", isTouchDown);
        NSLog(@"identifierStr: %@", identifierStr);
        
        if ([identifierStr isEqualToString: @"toAlbumCreationVC"]) {
            [weakSelf toAlbumCreationViewController: albumId
                                         templateId: templateId
                                    shareCollection: shareCollection];
        } else if ([identifierStr isEqualToString: @"toAlbumSettingVC"]) {
            [weakSelf toAlbumSettingViewController: albumId
                                        templateId: templateId
                                   shareCollection: shareCollection
                                          hasImage: hasImage];
        }
    };
}

#pragma mark - DDAUIActionSheetViewControllerDelegate Method
- (void)actionSheetViewDidSlideOut:(DDAUIActionSheetViewController *)controller
{
    NSLog(@"actionSheetViewDidSlideOut");
    //[self.fxBlurView removeFromSuperview];
    
    [wTools setStatusBarBackgroundColor: [UIColor whiteColor]];
    
    [self.effectView removeFromSuperview];
    self.effectView = nil;
}

#pragma mark - Methods for choosing viewControllers
- (void)toAlbumCreationViewController: (NSString *)albumId
                           templateId: (NSString *)templateId
                      shareCollection: (BOOL)shareCollection
{
    NSLog(@"toAlbumCreationViewController");
    
    AlbumCreationViewController *acVC = [[UIStoryboard storyboardWithName: @"AlbumCreationVC" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumCreationViewController"];
    //acVC.selectrow = [wTools userbook];
    acVC.albumid = albumId;
    acVC.templateid = [NSString stringWithFormat:@"%@", templateId];
    acVC.shareCollection = shareCollection;
    acVC.postMode = NO;
    acVC.fromVC = @"AlbumCollectionVC";
    
    if ([templateId isEqualToString:@"0"]) {
        acVC.booktype = 0;
        acVC.choice = @"Fast";
    } else {
        acVC.booktype = 1000;
        acVC.choice = @"Template";
    }
    
    //[self.navigationController pushViewController: acVC animated: YES];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav pushViewController: acVC animated: YES];
}

- (void)toAlbumSettingViewController: (NSString *)albumId
                          templateId: (NSString *)templateId
                     shareCollection: (BOOL)shareCollection
                            hasImage: (BOOL)hasImage
{
    NSLog(@"toAlbumSettingViewController");
    
    AlbumSettingViewController *aSVC = [[UIStoryboard storyboardWithName: @"Main" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumSettingViewController"];
    aSVC.albumId = albumId;
    aSVC.postMode = NO;
    aSVC.templateId = [NSString stringWithFormat:@"%@", templateId];
    aSVC.shareCollection = shareCollection;
    aSVC.hasImage = hasImage;
    aSVC.fromVC = @"AlbumCollectionVC";
    //[self.navigationController pushViewController: aSVC animated: YES];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav pushViewController: aSVC animated: YES];
}

#pragma mark - CalbumlistViewControllerDelegate
- (void)editPhoto:(NSString *)albumId
       templateId:(NSString *)templateId
  shareCollection:(BOOL)shareCollection
         hasImage:(BOOL)hasImage
{
    NSLog(@"editPhoto Delegate Method");
    NSLog(@"albumId: %@", albumId);
    NSLog(@"templateId: %@", templateId);
    
    [self showCustomEditActionSheet: albumId
                         templateId: templateId
                    shareCollection: shareCollection
                           hasImage: hasImage];
}

- (void)shareLink:(NSString *)sharingStr albumId:(NSString *)albumId
{
    NSLog(@"sharingStr: %@", sharingStr);
    NSLog(@"albumId: %@", albumId);
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems: [NSArray arrayWithObjects: sharingStr, nil] applicationActivities: nil];
    [self presentViewController: activityVC animated: YES completion: nil];
}

#pragma mark - Delegate Methods
- (void)toReadBookController:(NSString *)albumId
{
    NSLog(@"toReadBookController albumId: %@", albumId);
    [self retrieveAlbum: albumId];
}

- (void)retrieveAlbum: (NSString *)albumId {
    NSLog(@"retrieveAlbum");
    @try {
        [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI retrievealbump: albumId
                                                uid: [wTools getUserID]
                                              token: [wTools getUserToken]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [MBProgressHUD hideHUDForView: self.view animated: YES];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog( @"NSException caught" );
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason );
                return;
            }
            
            if (response != nil) {
                NSLog(@"response: %@", response);
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"AlbumCollectionViewController");
                    NSLog(@"retrieveAlbum");
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"retrievealbump"
                                         albumId: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        NSLog(@"result bool value is YES");
                        NSLog(@"dic: %@", dic);
                        
                        NSLog(@"dic data photo: %@", dic[@"data"][@"photo"]);
                        NSLog(@"dic data user name: %@", dic[@"data"][@"user"][@"name"]);
                        
                        ContentCheckingViewController *contentCheckingVC = [[UIStoryboard storyboardWithName: @"ContentCheckingVC" bundle: nil] instantiateViewControllerWithIdentifier: @"ContentCheckingViewController"];
                        contentCheckingVC.albumId = albumId;
                        
                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        [appDelegate.myNav pushViewController: contentCheckingVC animated: YES];
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

#pragma mark - Custom Alert Method
- (void)showCustomErrorAlert: (NSString *)msg
{
    CustomIOSAlertView *errorAlertView = [[CustomIOSAlertView alloc] init];
    [errorAlertView setContainerView: [self createErrorContainerView: msg]];
    
    [errorAlertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    [errorAlertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    [errorAlertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    errorAlertView.arrangeStyle = @"Horizontal";
    
    /*
     [alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
     [alertView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor firstMain], [UIColor firstPink], [UIColor secondGrey], nil]];
     [alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor darkMain], [UIColor darkPink], [UIColor firstGrey], nil]];
     alertView.arrangeStyle = @"Vertical";
     */
    
    __weak CustomIOSAlertView *weakErrorAlertView = errorAlertView;
    [errorAlertView setOnButtonTouchUpInside:^(CustomIOSAlertView *customAlertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[customAlertView tag]);
        [weakErrorAlertView close];
    }];
    [errorAlertView setUseMotionEffects: YES];
    [errorAlertView show];
}

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

#pragma mark - Custom Method for TimeOut
- (void)showCustomTimeOutAlert: (NSString *)msg
                  protocolName: (NSString *)protocolName
                       albumId: (NSString *)albumId
{
    CustomIOSAlertView *alertTimeOutView = [[CustomIOSAlertView alloc] init];
    [alertTimeOutView setContainerView: [self createTimeOutContainerView: msg]];
    
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertTimeOutView.arrangeStyle = @"Horizontal";
    
    alertTimeOutView.parentView = self.view;
    [alertTimeOutView setButtonTitles: [NSMutableArray arrayWithObjects: NSLocalizedString(@"TimeOut-CancelBtnTitle", @""), NSLocalizedString(@"TimeOut-OKBtnTitle", @""), nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertTimeOutView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstMain],nil]];
    [alertTimeOutView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor whiteColor], nil]];
    [alertTimeOutView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    //alertView.arrangeStyle = @"Vertical";
    
    __weak typeof(self) weakSelf = self;
    __weak CustomIOSAlertView *weakAlertTimeOutView = alertTimeOutView;
    [alertTimeOutView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertTimeOutView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertTimeOutView tag]);
        
        [weakAlertTimeOutView close];
        
        if (buttonIndex == 0) {
            
        } else {
            if ([protocolName isEqualToString: @"retrievealbump"]) {
                [weakSelf retrieveAlbum: albumId];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
