//
//  NewExistingAlbumViewController.m
//  wPinpinbox
//
//  Created by David Lee on 2017/9/26.
//  Copyright © 2017年 Angus. All rights reserved.
//

#import "NewExistingAlbumViewController.h"
#import "NewExistingAlbumCollectionViewCell.h"
#import "boxAPI.h"
#import "wTools.h"
#import "UIColor+Extensions.h"
#import "AsyncImageView.h"
#import "MyLayout.h"
#import "CustomIOSAlertView.h"
#import "OldCustomAlertView.h"
#import "UIView+Toast.h"
#import "GlobalVars.h"
#import "AppDelegate.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "LabelAttributeStyle.h"

#import "AlbumCreationViewController.h"
#import "ChooseTemplateViewController.h"
#import "UIViewController+ErrorAlert.h"

@interface NewExistingAlbumViewController () {
    NSMutableArray *existedAlbumArray;
    NSString *albumId;
    NSString *coverImage;
    NSString *descriptionText;
    NSString *nameForAlbum;
    
    NSMutableArray *checkPostArray;
    NSString *postDescription;
    
    UICollectionViewCell *cellForPost;
    //UIImageView *imgForPost;
    UIImageView *tickImageView;
    
    NSInteger columnCount;
    NSInteger miniInteriorSpacing;
    BOOL checkPost;
    
    //NSMutableDictionary *dict1;
    
    NSInteger currentContributionNumber;
    
    ChooseTemplateViewController *chooseTemplateVC;
}
@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarHeight;
@property (weak, nonatomic) IBOutlet UILabel *currentAlbumLabel;
@property (weak, nonatomic) IBOutlet UILabel *onlyForPublicLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *createNewAlbumBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *createNewAlbumBtnHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolBarViewHeight;
@end

@implementation NewExistingAlbumViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"NewExistingAlbumViewController viewDidLoad");
    NSLog(@"self.prefixText: %@", self.prefixText);
    NSLog(@"self.eventId: %@", self.eventId);
    NSLog(@"self.contributionNumber: %ld", (long)self.contributionNumber);
    NSLog(@"self.specialUrl: %@", self.specialUrl);
    [self initialValueSetup];
    [self getExistedAlbum];
}

- (void)initialValueSetup {
    NSLog(@"initialValueSetup");
    self.navBarView.backgroundColor = [UIColor barColor];
    
    self.currentAlbumLabel.textColor = [UIColor firstGrey];
    [LabelAttributeStyle changeGapString: self.currentAlbumLabel content: self.currentAlbumLabel.text];
    self.onlyForPublicLabel.textColor = [UIColor secondGrey];
    [LabelAttributeStyle changeGapString: self.onlyForPublicLabel content: self.onlyForPublicLabel.text];
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    checkPostArray = [[NSMutableArray alloc] init];
    
    self.collectionView.contentInset = UIEdgeInsetsMake(72, 0, 0, 0);
    
    columnCount = 3;
    miniInteriorSpacing = 16;
    
    self.createNewAlbumBtn.layer.masksToBounds = YES;
    self.createNewAlbumBtn.layer.cornerRadius = kCornerRadius;
    self.createNewAlbumBtnHeight.constant = kToolBarButtonHeight;
    [LabelAttributeStyle changeGapString: self.createNewAlbumBtn.titleLabel content: self.createNewAlbumBtn.titleLabel.text];
    
    [LabelAttributeStyle changeGapString: self.currentAlbumLabel content: self.currentAlbumLabel.text];
    [LabelAttributeStyle changeGapString: self.onlyForPublicLabel content: self.onlyForPublicLabel.text];
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
                self.navBarHeight.constant = navBarHeightConstant;
                self.toolBarViewHeight.constant = kToolBarViewHeightForX;
                break;
            default:
                printf("unknown");
                self.toolBarViewHeight.constant = kToolBarViewHeight;
                break;
        }
    }
}

#pragma mark - Protocol Methods
- (void)getExistedAlbum {
    NSLog(@"getExistedAlbum");    
    existedAlbumArray = [[NSMutableArray alloc] init];
    
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    NSString *limit = [NSString stringWithFormat: @"%d, %d", 0, 10000];
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *response = [boxAPI getcalbumlist: [wTools getUserID]
                                             token: [wTools getUserToken]
                                              rank: @"mine"
                                             limit: limit];
        
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
                NSLog(@"response from getcalbumlist");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"NewExistingAlbumViewController");
                    NSLog(@"getExistedAlbum");
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getcalbumlist"
                                            cell: nil];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    [wself processExistedAlbumResult:dic];
                }
            }
        });
    });
}

- (void)processExistedAlbumResult:(NSDictionary *)dic {
    if ([dic[@"result"] intValue] == 1) {
        NSArray *array = dic[@"data"];
        NSLog(@"array: %@", array);
        NSLog(@"array.count: %lu", (unsigned long)array.count);
        
        if (![wTools objectExists: array]) {
            return;
        }
        
        for (int i = 0; i < array.count; i++) {
            NSLog(@"array template: %@", array[i][@"template"][@"template_id"]);
            
            NSString *act = array[i][@"album"][@"act"];
            NSLog(@"act: %@", act);
            
            if (![wTools objectExists: act]) {
                return;
            }
            
            if ([act isEqualToString: @"open"]) {
                if (![wTools objectExists: self.templateArray]) {
                    return;
                }
                
                for (int j = 0; j < self.templateArray.count; j++) {
                    NSLog(@"templateArray: %@", [self.templateArray[j] stringValue]);
                    NSLog(@"array[i] template template_id: %@", array[i][@"template"][@"template_id"]);
                    
                    NSString *currentTemplateId = [array[i][@"template"][@"template_id"] stringValue];
                    
                    if (![wTools objectExists: currentTemplateId]) {
                        return;
                    }
                    
                    if ([currentTemplateId isEqualToString: [self.templateArray[j] stringValue]]) {
                        NSLog(@"same template");
                        NSLog(@"array[i]: %@", array[i]);
                        
                        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                        [dict setValue: array[i][@"album"][@"album_id"] forKey: @"albumId"];
                        [dict setValue: array[i][@"album"][@"cover"] forKey: @"cover"];
                        [dict setValue: array[i][@"album"][@"description"] forKey: @"description"];
                        [dict setValue: array[i][@"album"][@"name"] forKey: @"name"];
                        
                        NSArray *eventArray = [[NSArray alloc] init];
                        eventArray = array[i][@"event"];
                        
                        NSMutableArray *eventArrayData = [[NSMutableArray alloc] init];
                        
                        if (![wTools objectExists: eventArray]) {
                            return;
                        }
                        
                        for (int k = 0; k < eventArray.count; k++) {
                            [eventArrayData addObject: array[i][@"event"][k]];
                            NSLog(@"eventArrayData: %@", eventArrayData);
                        }
                        [dict setValue: eventArrayData forKey: @"eventArrayData"];
                        [existedAlbumArray addObject: dict];
                    }
                }
            }
        }
        NSLog(@"existedAlbumArray: %@", existedAlbumArray);
        NSLog(@"existedAlbumArray.count: %lu", (unsigned long)existedAlbumArray.count);
        
        currentContributionNumber = 0;
        NSLog(@"check contribution");
        
        NSMutableArray *arrayForRemove = [[NSMutableArray alloc] init];
        
        if (![wTools objectExists: existedAlbumArray]) {
            return;
        }
        
        for (int i = 0; i < existedAlbumArray.count; i++) {
            NSDictionary *d1 = existedAlbumArray[i];
            NSLog(@"name: %@", d1[@"name"]);
            NSArray *array = d1[@"eventArrayData"];
            NSLog(@"array: %@", array);
            
            NSDictionary *d2;
            
            if (![wTools objectExists: array]) {
                return;
            }
            
            for (int j = 0; j < array.count; j++) {
                d2 = array[j];
                NSLog(@"d2: %@", d2);
                
                if ([d2[@"contributionstatus"] integerValue] == 1) {
                    if ([self.eventId integerValue] == [d2[@"event_id"] integerValue]) {
                        NSLog(@"Event ID is the same");
                        ++currentContributionNumber;
                        NSLog(@"currentContributionNumber: %ld", (long)currentContributionNumber);
                    } else {
                        NSLog(@"Event ID is not the same");
                        NSLog(@"Album Event ID is not the same: %@", existedAlbumArray[i]);
                        [arrayForRemove addObject: existedAlbumArray[i]];
                    }
                }
            }
        }
        NSLog(@"currentContributionNumber: %ld", (long)currentContributionNumber);
        [existedAlbumArray removeObjectsInArray: arrayForRemove];
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

- (void)postAlbum:(UICollectionViewCell *)cell {
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI switchstatusofcontribution: [wTools getUserID]
                                                          token: [wTools getUserToken]
                                                       event_id: wself->_eventId
                                                       album_id: wself->albumId];
        
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
                NSLog(@"respons from switchstatusofcontribution");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"NewExistingAlbumViewController");
                    NSLog(@"postAlbum cell");
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"switchstatusofcontribution"
                                            cell: cell];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        NSLog(@"post album success");
                        
                        if (![wTools objectExists: dic[@"data"][@"event"][@"contributionstatus"]]) {
                            return;
                        }
                        int contributionCheck = [dic[@"data"][@"event"][@"contributionstatus"] boolValue];
                        NSLog(@"contributionCheck: %d", contributionCheck);
                        
                        NSString *checkPost;
                        NSIndexPath *indexPath = [wself.collectionView indexPathForCell: cell];
                        
                        if (contributionCheck) {
                            checkPost = @"1";
                            //[self showImageOnCell: cellForPost];
                            
                            CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                            style.messageColor = [UIColor whiteColor];
                            style.backgroundColor = [UIColor secondMain];
                            
                            [wself.view makeToast: @"投稿成功"
                                        duration: 2.0
                                        position: CSToastPositionBottom
                                           style: style];
                        } else {
                            checkPost = @"0";
                            //[self hideImageOnCell: cellForPost];
                            
                            CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                            style.messageColor = [UIColor whiteColor];
                            style.backgroundColor = [UIColor hintGrey];
                            
                            [self.view makeToast: @"取消投稿"
                                        duration: 2.0
                                        position: CSToastPositionBottom
                                           style: style];
                        }
                        wself->checkPostArray[indexPath.row] = checkPost;
                        [wself getExistedAlbum];
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

- (void)showImageOnCell:(UICollectionViewCell *)cell {
    NSLog(@"showImageOnCell");
    UIView *maskView = (UIView *)[cell viewWithTag: 300];
    maskView.alpha = 0.7;
    maskView.layer.masksToBounds = YES;
    maskView.layer.cornerRadius = kCornerRadius;

    UILabel *label = (UILabel *)[cell viewWithTag: 123];
    label.hidden = NO;
}

- (void)hideImageOnCell: (UICollectionViewCell *)cell {
    NSLog(@"hideImageOnCell");
    UIView *maskView = (UIView *)[cell viewWithTag: 300];
    maskView.alpha = 0;
    maskView.layer.masksToBounds = YES;
    maskView.layer.cornerRadius = kCornerRadius;
    
    UILabel *label = (UILabel *)[cell viewWithTag: 123];
    label.hidden = YES;
}

#pragma mark - IBAction Methods
- (IBAction)backBtnPress:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav popViewControllerAnimated: YES];
}

- (IBAction)createNewAlbum:(id)sender {
    NSLog(@"createNewAlbum");
    NSLog(@"currentContributionNumber: %ld", (long)currentContributionNumber);
    NSLog(@"self.contributionNumber: %ld", (long)self.contributionNumber);
    
    if (currentContributionNumber == self.contributionNumber) {
        NSLog(@"currentContributionNumber == self.contributionNumber");
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor hintGrey];
        
        [self.view makeToast: @"投稿數量已達上限"
                    duration: 2.0
                    position: CSToastPositionBottom
                       style: style];
        
    } else if (currentContributionNumber < self.contributionNumber) {
        NSLog(@"currentContributionNumber < self.contributionNumber");
        [self checkPostedAlbum];
    }
}

#pragma mark - Calling API Methods
- (void)checkPostedAlbum {
    NSLog(@"checkPostedAlbum");
    
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    NSString *limit = [NSString stringWithFormat: @"%d, %d", 0, 10000];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *response = [boxAPI getcalbumlist: [wTools getUserID]
                                             token: [wTools getUserToken]
                                              rank: @"mine"
                                             limit: limit];
        
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
                NSLog(@"response from getcalbumlist");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"NewEventPostViewController");
                    NSLog(@"checkPostedAlbum");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"checkPostedAlbum"
                                            cell: nil];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        NSArray *array = dic[@"data"];
                        NSLog(@"array.count: %lu", (unsigned long)array.count);
                        
                        if (![wTools objectExists: array]) {
                            return;
                        }
                        
                        for (int i = 0; i < array.count; i++) {
                            NSString *act = array[i][@"album"][@"act"];
                            
                            if (![wTools objectExists: act]) {
                                return;
                            }
                            
                            if ([act isEqualToString: @"open"]) {
                                NSLog(@"array: %@", array[i]);
                                
                                NSArray *eventArray = [[NSArray alloc] init];
                                eventArray = array[i][@"event"];
                                
                                if (![wTools objectExists: eventArray]) {
                                    return;
                                }
                                
                                for (int k = 0; k < eventArray.count; k++) {
                                    BOOL contributionStatus = [array[i][@"event"][k][@"contributionstatus"] boolValue];
                                    NSString *eventIdCheck = array[i][@"event"][k][@"event_id"];
                                    NSLog(@"contributionStatus: %d", contributionStatus);
                                    
                                    if (![wTools objectExists: eventIdCheck]) {
                                        return;
                                    }
                                    
                                    if ([eventIdCheck intValue] == [self.eventId intValue]) {
                                        NSLog(@"match eventId");
                                        
                                        if (contributionStatus) {
                                            NSLog(@"joined post activity already");
                                            NSLog(@"contributionStatus: %d", contributionStatus);
                                            
                                            //checkPost = YES;
                                            
//                                            dict1 = [[NSMutableDictionary alloc] init];
//                                            [dict1 setValue: array[i][@"album"][@"album_id"] forKey: @"albumId"];
//                                            [dict1 setValue: array[i][@"album"][@"cover"] forKey: @"cover"];
//                                            [dict1 setValue: array[i][@"album"][@"description"] forKey: @"description"];
//                                            [dict1 setValue: array[i][@"album"][@"name"] forKey: @"name"];
//
//                                            NSLog(@"match eventId, posted already, dict1:%@", dict1);
                                        }
                                    }
                                }
                            }
                        }
                        NSNumber *eventTemplateId = [self.templateArray objectAtIndex: 0];
                        NSLog(@"eventTemplateId: %@", eventTemplateId);

                        // Because the return value of element of Array is int
                        if ([eventTemplateId intValue] == 0) {
                            [self addNewFastMod];
                        } else {
                            [self toChooseTempalteVC];
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

- (void)addNewFastMod {
    NSLog(@"addNewFastMod");
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
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI insertalbumofdiy: [wTools getUserID]
                                                token: [wTools getUserToken]
                                          template_id: @"0"];
        
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
                    NSLog(@"NewEventPostViewController");
                    NSLog(@"addNewFastMod");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"insertalbumofdiy"
                                            cell: nil];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([dic[@"result"]boolValue]) {
                        NSLog(@"get result value from insertalbumofdiy");
                        NSString *tempAlbumId = [dic[@"data"] stringValue];
                        
                        if (![wTools objectExists: tempAlbumId]) {
                            return;
                        }
                        AlbumCreationViewController *albumCreationVC = [[UIStoryboard storyboardWithName: @"AlbumCreationVC" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumCreationViewController"];
                                                
                        // Data from wTools userbook is not right
                        //albumCreationVC.selectrow = [wTools userbook];
                        
                        albumCreationVC.albumid = tempAlbumId;
                        albumCreationVC.templateid = @"0";
                        albumCreationVC.choice = @"Fast";
                        albumCreationVC.event_id = self.eventId;
                        albumCreationVC.postMode = YES;
                        albumCreationVC.isNew = YES;
                        albumCreationVC.prefixText = self.prefixText;
                        albumCreationVC.specialUrl = self.specialUrl;
                        NSLog(@"self.specialUrl: %@", self.specialUrl);
                        
                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        [appDelegate.myNav pushViewController: albumCreationVC animated: YES];
                        
                    } else {
                        NSLog(@"失敗： %@", dic[@"message"]);
                        if ([wTools objectExists: dic[@"message"]]) {
                            [self showCustomErrorAlert: dic[@"message"]];
                        } else {
                            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                        }
                    }
                }
            }
        });
    });
}

- (void)toChooseTempalteVC {
    if (![wTools objectExists: self.eventId]) {
        return;
    }
    chooseTemplateVC = [[UIStoryboard storyboardWithName: @"ChooseTemplateVC" bundle: nil] instantiateViewControllerWithIdentifier: @"ChooseTemplateViewController"];
    chooseTemplateVC.rank = @"hot";
    chooseTemplateVC.event_id = self.eventId;
    chooseTemplateVC.postMode = YES;
    checkPost = NO;
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav pushViewController: chooseTemplateVC animated: YES];
}

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    NSLog(@"existedAlbumArray.count: %lu", (unsigned long)existedAlbumArray.count);
    return existedAlbumArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForItemAtIndexPath");
    NewExistingAlbumCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"Cell" forIndexPath: indexPath];

    NSDictionary *data = existedAlbumArray[indexPath.row];
    NSLog(@"data: %@", data);
    
    cellForPost = cell;
    
    if ([data[@"cover"] isKindOfClass: [NSNull class]]) {
        cell.imageView.image = [UIImage imageNamed: @"bg200_no_image.jpg"];
    } else {
        [cell.imageView sd_setImageWithURL: [NSURL URLWithString: data[@"cover"]]];
    }
    
    if ([wTools objectExists: existedAlbumArray[indexPath.row][@"name"]]) {
        cell.textLabel.text = existedAlbumArray[indexPath.row][@"name"];
        [LabelAttributeStyle changeGapString: cell.textLabel content: cell.textLabel.text];
    }
    NSArray *eventArrayData = data[@"eventArrayData"];
    NSString *checkPost;
    
    NSLog(@"eventArrayData: %@", eventArrayData);
    
    if ([wTools objectExists: eventArrayData]) {
        for (int i = 0; i < eventArrayData.count; i++) {
            NSString *albumEventId = eventArrayData[i][@"event_id"];
            NSString *contribution = eventArrayData[i][@"contributionstatus"];
            NSLog(@"contribution: %@", contribution);
            NSLog(@"albumEventId: %@", albumEventId);
            NSLog(@"eventId: %@", self.eventId);
            
            if ([albumEventId intValue] == [self.eventId intValue]) {
                NSLog(@"eventId is the same");
                
                if ([contribution intValue] == 1) {
                    NSLog(@"contribution is 1");
                    checkPost = @"1";
                    NSLog(@"checkPost: %@", checkPost);
                } else {
                    NSLog(@"contribution is 0");
                    checkPost = @"0";
                    NSLog(@"checkPost: %@", checkPost);
                }
            }
        }
        NSLog(@"checkPost: %@", checkPost);
        checkPostArray[indexPath.row] = checkPost;
        
        if ([checkPost intValue] == 1) {
            [self showImageOnCell: cell];
        } else {
            [self hideImageOnCell: cell];
        }
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate Methods
- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectItemAtIndexPath");
    NSDictionary *data = existedAlbumArray[indexPath.row];
    NSLog(@"data: %@", data);
    
    albumId = data[@"albumId"];
    coverImage = data[@"cover"];
    descriptionText = data[@"description"];
    nameForAlbum = data[@"name"];
    
    NSLog(@"checkPostArray: %@", checkPostArray);
    
    NSString *checkPost = checkPostArray[indexPath.row];
    cellForPost = [collectionView cellForItemAtIndexPath: indexPath];
    
    [self showAlertView: checkPost cell: cellForPost];
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"");
    NSLog(@"sizeForItemAtIndexPath");
    
    CGFloat itemWidth = roundf((self.view.frame.size.width - (miniInteriorSpacing * (columnCount + 1))) / columnCount);
    NSLog(@"itemWidth: %f", itemWidth);
    
    CGFloat itemHeight = (3 * itemWidth) / 2;
    NSLog(@"itemHeight: %f", itemHeight);
    
    NSInteger labelHeight = 0;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 1136:
                printf("iPhone 5 or 5S or 5C");
                labelHeight = 60;
                break;
            case 1334:
                printf("iPhone 6/6S/7/8");
                labelHeight = 40;
                break;
            case 1920:
                printf("iPhone 6+/6S+/7+/8+");
                labelHeight = 40;
                break;
            case 2208:
                printf("iPhone 6+/6S+/7+/8+");
                labelHeight = 40;
                break;
            case 2436:
                printf("iPhone X");
                labelHeight = 40;
                break;
            default:
                printf("unknown");
                labelHeight = 40;
                break;
        }
    }
    return CGSizeMake(itemWidth, itemHeight + labelHeight);
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
    return 32;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    UIEdgeInsets itemInset = UIEdgeInsetsMake(0, 16, 0, 16);
    return itemInset;
}

#pragma mark - Custom Alert Method
- (void)showCustomErrorAlert: (NSString *)msg {
    NSLog(@"");
    NSLog(@"showCustomAlert msg: %@", msg);
    [UIViewController showCustomErrorAlertWithMessage:msg onButtonTouchUpBlock:^(CustomIOSAlertView *customAlertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[customAlertView tag]);
        [customAlertView close];
    }];
}

- (void)showAlertView: (NSString *)checkPost
                 cell: (UICollectionViewCell *)cell {
    OldCustomAlertView *alertView = [[OldCustomAlertView alloc] init];
    [alertView setContainerView: [self createView: checkPost]];
    [alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"取消", @"確定", nil]];
    
    __weak OldCustomAlertView *weakAlertView = alertView;
    [alertView setOnButtonTouchUpInside:^(OldCustomAlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
        [weakAlertView close];
        
        if (buttonIndex == 0) {
            
        } else if (buttonIndex == 1) {
            NSLog(@"Yes");
            [self postAlbum: cell];
        }
    }];
    [alertView setUseMotionEffects: true];
    [alertView show];
}

- (UIView *)createView: (NSString *)checkPost {
    UIView *view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 280, 220)];
    UIView *bgView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 280, 200)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(30, 30, 100, 100)];
    imageView.image = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString: coverImage]]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    NSString *albumName = @"作品名稱";
    NSString *albumDescription = @"作品介紹";
    
    UITextView *textView = [[UITextView alloc] init];
    textView.font = [UIFont fontWithName: @"TrebuchetMS-Bold" size: 15.0f];
    textView.textColor = [UIColor firstGrey];
    textView.backgroundColor = [UIColor clearColor];
    textView.frame = CGRectMake(145, 10, bgView.bounds.size.width / 2, bgView.bounds.size.height - 50);
    textView.text = [NSString stringWithFormat: @"%@:\n%@\n\n\n%@:\n%@", albumName, nameForAlbum, albumDescription, descriptionText];
    textView.userInteractionEnabled = NO;
    
    [bgView addSubview: imageView];
    [bgView addSubview: textView];
    
    UILabel *postLabel = [[UILabel alloc] initWithFrame: CGRectMake(8, view.bounds.size.height / 2 + 50,  view.bounds.size.width - 16, 50)];
    
    NSLog(@"[checkPost intValue]: %d", [checkPost intValue]);
    
    if ([checkPost intValue] == 1) {
        postLabel.textColor = [UIColor firstPink];
        postDescription = @"此作品已投稿，是否重新選擇? (若確定，則該作品的投票數將會歸零)";
    } else {
        postLabel.textColor = [UIColor blackColor];
        postDescription = @"確定投稿此作品?";
    }
    
    postLabel.text = postDescription;
    [LabelAttributeStyle changeGapString: postLabel content: postDescription];
    postLabel.textAlignment = NSTextAlignmentCenter;
    postLabel.font = [UIFont systemFontOfSize: 14.0];
    postLabel.numberOfLines = 0;
    //postLabel.adjustsFontSizeToFitWidth = YES;
    
    [view addSubview: postLabel];
    [view addSubview: bgView];
    
    return view;
}

#pragma mark - Custom Method for TimeOut
- (void)showCustomTimeOutAlert: (NSString *)msg
                  protocolName: (NSString *)protocolName
                          cell: (UICollectionViewCell *)cell {
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
            if ([protocolName isEqualToString: @"getcalbumlist"]) {
                [weakSelf getExistedAlbum];
            } else if ([protocolName isEqualToString: @"switchstatusofcontribution"]) {
                [weakSelf postAlbum: cell];
            } else if ([protocolName isEqualToString: @"checkPostedAlbum"]) {
                [weakSelf checkPostedAlbum];
            } else if ([protocolName isEqualToString: @"insertalbumofdiy"]) {
                [weakSelf addNewFastMod];
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
