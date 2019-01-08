//
//  ChangeInterestsViewController.m
//  wPinpinbox
//
//  Created by David on 05/02/2018.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "ChangeInterestsViewController.h"
#import "ChangeInterestsCollectionViewCell.h"
#import "ChangeInterestsCollectionReusableView.h"
#import "UIColor+Extensions.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "boxAPI.h"
#import "wTools.h"
#import "GlobalVars.h"
#import "CustomIOSAlertView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "LabelAttributeStyle.h"
#import "UIView+Toast.h"
#import "UIViewController+ErrorAlert.h"

@interface ChangeInterestsViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>
{
    NSMutableArray *hobbyArray;
    NSMutableArray *checkSelectedArray;
    NSMutableArray *selectArray;
    NSInteger columnCount;
    NSInteger miniInteriorSpacing;
}
@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (weak, nonatomic) IBOutlet UIButton *sendDataBtn;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation ChangeInterestsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"viewDidLoad");
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.delegate = self;
    
    [self initialValueSetup];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.enabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialValueSetup {
    columnCount = 3;
    miniInteriorSpacing = 16;
    
    self.navBarView.backgroundColor = [UIColor barColor];
    self.sendDataBtn.layer.cornerRadius = kCornerRadius;
    self.sendDataBtn.clipsToBounds = YES;
    
    self.bottomView.backgroundColor = [UIColor colorWithRed: 255.0/255.0
                                                      green: 255.0/255.0
                                                       blue: 255.0/255.0
                                                      alpha: 0.96];
    
    checkSelectedArray = [NSMutableArray new];
    selectArray = [NSMutableArray new];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"profile hobby: %@", [defaults objectForKey: @"profile"][@"hobby"]);
    
    selectArray = [[defaults objectForKey: @"profile"][@"hobby"] mutableCopy];
    NSLog(@"selectArray: %@", selectArray);
    
    //self.collectionView.contentInset = UIEdgeInsetsMake(48, 0, 0, 0);
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);    
    
    self.sendDataBtn.titleLabel.font = [UIFont systemFontOfSize: 18.0];
    [LabelAttributeStyle changeGapString: self.sendDataBtn.titleLabel content: self.sendDataBtn.titleLabel.text];
    
    [self getHobbyList];
}

- (IBAction)backBtnPressed:(id)sender {
    [selectArray removeAllObjects];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav popViewControllerAnimated: YES];
}

- (void)getHobbyList {
    @try {
        [MBProgressHUD showHUDAddedTo: self.view animated: YES];
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
                [MBProgressHUD hideHUDForView: self.view animated: YES];
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
                    
                    if ([data[@"result"] intValue] == 1) {
                        NSLog(@"getHobbyList Success");
                        if ([wTools objectExists: data]) {
                            [wself loadHobby:data];
                        }
                    } else if ([data[@"result"] intValue] == 0) {
                        NSLog(@"失敗： %@", data[@"message"]);
                        if ([wTools objectExists: data[@"message"]]) {
                            [wself showCustomErrorAlert: data[@"message"]];
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
- (void)loadHobby:(NSDictionary *)data {
    hobbyArray = data[@"data"];
    NSInteger hobbyId;
    
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

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return hobbyArray.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"viewForSupplementaryElementOfKind");
    //UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind: kind withReuseIdentifier: @"headerId" forIndexPath: indexPath];
    ChangeInterestsCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind: kind withReuseIdentifier: @"headerId" forIndexPath: indexPath];
    headerView.topicLabel.text = @"對哪種類型的資訊感興趣呢?";
    [LabelAttributeStyle changeGapString: headerView.topicLabel content: headerView.topicLabel.text];
//    [headerView.topicLabel sizeToFit];
    [LabelAttributeStyle changeGapString: headerView.infoLabel content: headerView.infoLabel.text];
//    [headerView.infoLabel sizeToFit];
    
    return headerView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForItemAtIndexPath");
    ChangeInterestsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"hobbyCell" forIndexPath: indexPath];
    NSString *imgUrlStr = hobbyArray[indexPath.row][@"hobby"][@"image_url"];
    NSInteger hobbyIdInt = [checkSelectedArray[indexPath.row][@"hobbyId"] integerValue];
    
    NSLog(@"hobby image_url: %@", hobbyArray[indexPath.row][@"hobby"][@"image_url"]);
    
    if (![imgUrlStr isEqual: [NSNull null]]) {
        //cell.hobbyImageView.imageURL = [NSURL URLWithString: imgUrlStr];
        [cell.hobbyImageView sd_setImageWithURL: [NSURL URLWithString: imgUrlStr]];
    }
    
    if (![selectArray isEqual: [NSNull null]]) {
        if (selectArray.count != 0) {
            if ([selectArray containsObject: [NSNumber numberWithInteger: hobbyIdInt]]) {
                cell.contentView.subviews[0].backgroundColor = [UIColor thirdMain];
            } else {
                cell.contentView.subviews[0].backgroundColor = [UIColor clearColor];
            }
        }
    }
    if ([wTools objectExists: hobbyArray[indexPath.row][@"hobby"][@"name"]]) {
        cell.hobbyLabel.text = hobbyArray[indexPath.row][@"hobby"][@"name"];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate Methods
- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectItemAtIndexPath");
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath: indexPath];
    NSLog(@"checkSelectedArray: %@", checkSelectedArray);
    
    if ([wTools objectExists: checkSelectedArray[indexPath.row][@"hobbyId"]]) {
        NSInteger hobbyIdInt = [checkSelectedArray[indexPath.row][@"hobbyId"] integerValue];
        NSLog(@"hobbyIdInt: %ld", (long)hobbyIdInt);
        NSLog(@"Before");
        NSLog(@"selectArray: %@", selectArray);
        
        if ([wTools objectExists: selectArray]) {
            if ([selectArray containsObject: [NSNumber numberWithInteger: hobbyIdInt]]) {
                NSLog(@"selectArray containsObject");
                NSLog(@"Before selectArray removeObject");
                [selectArray removeObject: [NSNumber numberWithInteger: hobbyIdInt]];
                NSLog(@"selectArray removeObject");
                cell.contentView.subviews[0].backgroundColor = [UIColor clearColor];
                
                if (selectArray.count == 0) {
                    self.bottomView.hidden = YES;
                } else {
                    self.bottomView.hidden = NO;
                }
            } else {
                NSLog(@"selectArray does not contain Object");
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
                NSLog(@"selectArray addObject");
                cell.contentView.subviews[0].backgroundColor = [UIColor thirdMain];
                
                if (selectArray.count == 0) {
                    self.bottomView.hidden = YES;
                } else {
                    self.bottomView.hidden = NO;
                }
            }
            NSLog(@"After");
            NSLog(@"selectArray: %@", selectArray);
        }
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"");
    NSLog(@"sizeForItemAtIndexPath");
    CGFloat itemWidth = roundf((self.view.frame.size.width - (miniInteriorSpacing * (columnCount + 1))) / columnCount);
    return CGSizeMake(itemWidth, 100);
    //return CGSizeMake(136.0, height * kCoverHeight);
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
- (IBAction)sendDataBtnPressed:(id)sender {
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
    NSLog(@"selectArray: %@", selectArray);
    
    for (id object in selectArray) {
        NSLog(@"object: %@", object);
        selectTag = [NSString stringWithFormat: @"%@,%@", selectTag, object];
    }
    NSLog(@"selectTag: %@", selectTag);
    
    @try {
        [MBProgressHUD showHUDAddedTo: self.view animated: YES];
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
        NSString *response = [boxAPI updateprofilehobby: token usid: uid hobby: selectTag];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [MBProgressHUD hideHUDForView: self.view animated: YES];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog( @"NSException caught");
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason);
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
        [MBProgressHUD showHUDAddedTo: self.view animated: YES];
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
            
            //NSLog(@"testSign: %@", testSign);
            
            if (response != nil) {
                NSLog(@"Getting response from getprofile");
                //NSLog(@"response: %@", response);
                
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
                        NSLog(@"dataIc: %@", dataIc);
                        
                        if ([wTools objectExists: [dataIc allKeys]]) {
                            for (NSString *key in [dataIc allKeys]) {
                                //NSLog(@"key: %@", key);
                                
                                id objective = [dataIc objectForKey: key];
                                //NSLog(@"objective: %@", objective);
                                
                                if ([objective isKindOfClass: [NSNull class]]) {
                                    [dataIc setObject: @"" forKey: key];
                                }
                            }
                            NSLog(@"dataIc: %@", dataIc);
                            
                            [userPrefs setValue: dataIc forKey: @"profile"];
                            [userPrefs synchronize];
                            
                            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                            [appDelegate.myNav popViewControllerAnimated: YES];
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

#pragma mark - Custom Method for TimeOut
- (void)showCustomTimeOutAlert: (NSString *)msg
                  protocolName: (NSString *)protocolName {
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
            if ([protocolName isEqualToString: @"getHobbyList"]) {
                [weakSelf getHobbyList];
            } else if ([protocolName isEqualToString: @"updateprofilehobby"]) {
                
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
