//
//  PreviewPageSetupViewController.m
//  wPinpinbox
//
//  Created by David on 3/21/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "PreviewPageSetupViewController.h"
#import "UIView+Toast.h"
#import "wTools.h"
#import "boxAPI.h"
#import "GlobalVars.h"
#import "UIColor+Extensions.h"
#import "CustomIOSAlertView.h"
#import "MyLinearLayout.h"
#import "UIViewController+ErrorAlert.h"

#define kCellHeightForPreview 170
#define kViewHeightForPreview 568

@interface PreviewPageSetupViewController ()
@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarHeight;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) NSMutableArray *labelArray;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@end

@implementation PreviewPageSetupViewController

- (void)viewDidLoad {
    NSLog(@"PreviewPageSetupViewController");
    NSLog(@"viewDidLoad");
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.backButton.layer.cornerRadius = 8;
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleTapGesture:)];
    [self.collectionView addGestureRecognizer: tapGR];
    
    // Check the cover preview value can not be 0
    BOOL isPreview = [self.imageArray[0][@"is_preview"] boolValue];
    
    if (!isPreview) {
        NSLog(@"The cover preview page can not be cancelled");
        isPreview = !isPreview;
        
        self.imageArray[0][@"is_preview"] = [NSNumber numberWithBool: isPreview];
    }
    
    self.collectionView.delegate = self;
    self.collectionView.showsVerticalScrollIndicator = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)callBackButtonFunction
{
    [self back: nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.labelArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.imageArray.count; i++) {
        if (i == 0) {
            [self.labelArray addObject: [NSString stringWithFormat: NSLocalizedString(@"GeneralText-homePage", @"")]];
        } else if (i > 0) {
            [self.labelArray addObject: [NSString stringWithFormat: @"%d", i]];
        }
    }
    [self.collectionView reloadData];
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
                self.navBarHeight.constant = 80;
                break;
            default:
                printf("unknown");
                break;
        }
    }
}

- (void)handleTapGesture: (UITapGestureRecognizer *)gestureRecognizer
{
    /*
    for (UICollectionViewCell *cell in [self.collectionView visibleCells]) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell: cell];
        NSLog(@"indexPath: %@", indexPath);
    }
    */
    
    NSLog(@"handleTapGesture");
        
    CGPoint location = [gestureRecognizer locationInView: self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint: location];
    NSLog(@"indexPath: %@", indexPath);
    NSLog(@"indexPath.row: %ld", (long)indexPath.row);
    
    NSLog(@"indexPath.item: %ld", (long)indexPath.item);
    
    if (indexPath != nil) {
        NSLog(@"indexPath is nil");
        
        if (indexPath.row == 0) {
            NSLog(@"indexPath.row: %ld", (long)indexPath.row);
            
            CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
            style.messageColor = [UIColor whiteColor];
            style.backgroundColor = [UIColor thirdPink];
            //style.backgroundColor = [UIColor colorWithRed: 233.0/255.0 green: 30.0/255.0 blue: 99.0/255.0 alpha: 1.0];
            [[self.view superview] makeToast: @"封面不能取消"
                                    duration: 2.0
                                    position: CSToastPositionBottom
                                       style: style];
        } else {
            NSLog(@"indexPath.row: %ld", (long)indexPath.row);
            
            NSLog(@"photo_id: %@", self.imageArray[indexPath.row][@"photo_id"]);
            NSLog(@"isPreview: %d", [self.imageArray[indexPath.row][@"is_preview"] boolValue]);
            
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath: indexPath];
            UIImageView *previewImageView = (UIImageView *)[cell viewWithTag: 300];
            
            BOOL isPreview = [self.imageArray[indexPath.row][@"is_preview"] boolValue];
            NSLog(@"isPreview: %d", isPreview);
            
            isPreview = !isPreview;
            
            if (isPreview) {
                previewImageView.image = [UIImage imageNamed: @"icon_select_pink500_120x120"];
            } else {
                previewImageView.image = [UIImage imageNamed: @"icon_unselect_teal500_120x120"];
            }
            
            self.imageArray[indexPath.row][@"is_preview"] = [NSNumber numberWithBool: isPreview];
            //NSLog(@"self.imageArray: %@", self.imageArray);
        }
    } else {
        NSLog(@"indexPath is nil");
    }
}

- (IBAction)back:(id)sender
{
    // For Presenting as ChildViewController
//    [UIView animateWithDuration: 0.2 animations:^{
//        self.view.frame = CGRectMake(0, kViewHeightForPreview, 320, kCellHeightForPreview);
//    } completion:^(BOOL finished) {
//        [self.view removeFromSuperview];
//        [self removeFromParentViewController];
//    }];
    
    double delayInSeconds = 0.6;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector: @selector(previewPageSetupViewControllerDisappear:)]) {
            [self.delegate previewPageSetupViewControllerDisappear: self];
        }
    });
    
    [self createDataForCallingServer];
    
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (void)createDataForCallingServer
{
    NSLog(@"createArrayForCallingServer");
    
    NSMutableArray *arrayForSending = [[NSMutableArray alloc] init];
    
    NSLog(@"self.imageArray: %@", self.imageArray);
    
    for (int i = 0; i < self.imageArray.count; i++) {
        BOOL isPreview = [self.imageArray[i][@"is_preview"] boolValue];
        NSLog(@"isPreview: %d", isPreview);
        
        if (isPreview) {
            [arrayForSending addObject: self.imageArray[i][@"photo_id"]];
        }
    }
    NSLog(@"arrayForSending: %@", arrayForSending);
    
    NSMutableString *photoIdStr = [NSMutableString string];
    
    for (int i = 0; i < arrayForSending.count; i++) {
        if (i + 1 != arrayForSending.count) {
            [photoIdStr appendString: [NSString stringWithFormat: @"%@%@", arrayForSending[i], @","]];
        } else {
            [photoIdStr appendString: [NSString stringWithFormat: @"%@", arrayForSending[i]]];
        }
    }
    
    NSLog(@"photoIdStr: %@", photoIdStr);
    
    NSMutableDictionary *settingsDic = [NSMutableDictionary new];
    [settingsDic setObject: photoIdStr forKey: @"preview"];
    
    NSLog(@"settingsDic: %@", settingsDic);
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: settingsDic
                                                       options: 0
                                                         error: nil];
    NSString *jsonStr = [[NSString alloc] initWithData: jsonData
                                              encoding: NSUTF8StringEncoding];
    [self callAlbumSettings: jsonStr];
}

- (void)callAlbumSettings: (NSString *)jsonStr
{
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI albumsettings: [wTools getUserID]
                                             token: [wTools getUserToken]
                                          album_id: self.albumId
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
                NSLog(@"response from albumsettings");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"PreviewPageSetupViewController");
                    NSLog(@"callAlbumSettings jsonStr");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"albumsettings"
                                         jsonStr: jsonStr];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([dic[@"result"] isEqualToString: @"SYSTEM_OK"]) {
                        NSLog(@"dic: %@", dic);
                        
                        if ([self.delegate respondsToSelector: @selector(previewPageSetupViewControllerDisappearAfterCalling:modifySuccess:imageArray:)]) {
                            [self.delegate previewPageSetupViewControllerDisappearAfterCalling: self modifySuccess: [dic[@"result"] boolValue] imageArray: self.imageArray];
                        }
                    } else if ([dic[@"result"] isEqualToString: @"SYSTEM_ERROR"]) {
                        NSLog(@"失敗： %@", dic[@"message"]);
                        NSString *msg = dic[@"message"];
                        
                        if (msg == nil) {
                            msg = NSLocalizedString(@"Host-NotAvailable", @"");
                        }
                        [self showCustomErrorAlert: msg];
                    }
                }
            }
        });
    });
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"self.imageArray.count: %ld", self.imageArray.count);
    return self.imageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cellForItemAtIndexPath");
    
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: identifier forIndexPath: indexPath];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag: 100];
    NSString *thumbStr = _imageArray[indexPath.row][@"image_url_thumbnail"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(queue, ^{
        NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:thumbStr ]];
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = [UIImage imageWithData: data];
        });
    });
    
    // Set up the label text
    UILabel *lab = (UILabel *)[cell viewWithTag: 200];
    lab.text = self.labelArray[indexPath.row];
    NSLog(@"lab.text: %@", lab.text);
    
    // Set up the previewImage
    UIImageView *previewImageView = (UIImageView *)[cell viewWithTag: 300];
    
    //NSLog(@"photo_id: %@", self.imageArray[indexPath.row][@"photo_id"]);
    //NSLog(@"isPreview: %d", [self.imageArray[indexPath.row][@"is_preview"] boolValue]);
    
    if ([self.imageArray[indexPath.row][@"is_preview"] boolValue]) {
        previewImageView.image = [UIImage imageNamed: @"icon_select_pink500_120x120"];
    } else {
        previewImageView.image = [UIImage imageNamed: @"icon_unselect_teal500_120x120"];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectItemAtIndexPath");
    
    NSLog(@"indexPath.item: %ld", (long)indexPath.item);
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didHighlightItemAtIndexPath");
    NSLog(@"indexPath.item: %ld", (long)indexPath.item);
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
                       jsonStr: (NSString *)jsonStr
{
    CustomIOSAlertView *alertTimeOutView = [[CustomIOSAlertView alloc] init];
    //[alertTimeOutView setContainerView: [self createTimeOutContainerView: msg]];
    [alertTimeOutView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertTimeOutView.arrangeStyle = @"Horizontal";
    
    [alertTimeOutView setButtonTitles: [NSMutableArray arrayWithObjects: @"關閉", @"再試一次", nil]];
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
            if ([protocolName isEqualToString: @"albumsettings"]) {
                [weakSelf callAlbumSettings: jsonStr];
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
