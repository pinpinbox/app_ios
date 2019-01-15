//
//  VotingViewController.m
//  wPinpinbox
//
//  Created by David on 2017/10/31.
//  Copyright © 2017年 Angus. All rights reserved.
//

#import "VotingViewController.h"
#import "VotingCollectionViewCell.h"
#import "VotingCollectionReusableView.h"
#import "AppDelegate.h"
#import "boxAPI.h"
#import "wTools.h"
#import "UIColor+Extensions.h"
#import "MyLayout.h"
#import "GlobalVars.h"
#import "CustomIOSAlertView.h"
#import "JCCollectionViewWaterfallLayout.h"
#import "AsyncImageView.h"
#import "GlobalVars.h"
#import "AlbumDetailViewController.h"
#import "CreaterViewController.h"
#import "UIColor+HexString.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIView+Toast.h"
#import "LabelAttributeStyle.h"
#import "UIViewController+ErrorAlert.h"
#import "UserInfo.h"

#import "YAlbumDetailContainerViewController.h"

@interface VotingViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, JCCollectionViewWaterfallLayoutDelegate, UIGestureRecognizerDelegate> {
    BOOL isLoading;
    BOOL isReloading;
    NSInteger nextId;
    NSMutableArray *voteArray;
    NSInteger voteLeft;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarHeight;
@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (weak, nonatomic) IBOutlet MyLinearLayout *remainingVoteView;
@property (weak, nonatomic) IBOutlet UILabel *remainingVoteLabel;

@property (nonatomic, strong) JCCollectionViewWaterfallLayout *jccLayout;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation VotingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initialValueSetup];
    [self loadData];
    //[self.collectionView reloadData];
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
    self.navBarView.myTopMargin = 32;
    self.navBarView.backgroundColor = [UIColor barColor];
    
    //self.remainingVoteView.wrapContentWidth = YES;
    self.remainingVoteView.myCenterYOffset = 0;
    self.remainingVoteView.myTopMargin = 8;
    self.remainingVoteView.myRightMargin = 32;
    self.remainingVoteView.myLeftMargin = 20;
    //self.remainingVoteView.widthDime.max(240);
    //self.remainingVoteView.backgroundColor = [UIColor thirdPink];
    //self.remainingVoteView.orientation = MyMarginGravity_Horz_Right;
    self.remainingVoteView.gravity = MyMarginGravity_Horz_Right;
    
    self.remainingVoteLabel.wrapContentWidth = YES;
    self.remainingVoteLabel.myTopMargin = 32;
    self.remainingVoteLabel.myRightMargin = 16;
    
    self.remainingVoteLabel.textColor = [UIColor firstGrey];
    self.remainingVoteLabel.font = [UIFont systemFontOfSize: 16];
    self.remainingVoteLabel.textAlignment = NSTextAlignmentRight;
    //self.remainingVoteLabel.backgroundColor = [UIColor thirdMain];
    
    nextId = 0;
    isLoading = NO;
    isReloading = NO;
    
    voteArray = [NSMutableArray new];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget: self
                            action: @selector(refresh)
                  forControlEvents: UIControlEventValueChanged];
    [self.collectionView addSubview: self.refreshControl];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
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
                self.navBarHeight.constant = 0;
                //self.collectionView.contentInset = UIEdgeInsetsMake(32, 0, 0, 0);
                break;
            default:
                printf("unknown");
                break;
        }
    }
}

- (void)updateRemainingVoteLabel {
    NSLog(@"");
    NSLog(@"updateRemainingVoteLabel");
    NSLog(@"voteLeft: %ld", (long)voteLeft);
    if (voteLeft >= 10000000) {
        NSLog(@"voteLeft >= 10000000");
        voteLeft = voteLeft / 1000000;
        self.remainingVoteLabel.text = [NSString stringWithFormat: @"今日剩餘票數: %ldM", (long)voteLeft];
        [LabelAttributeStyle changeGapString: self.remainingVoteLabel content: [NSString stringWithFormat: @"今日剩餘票數: %ldM", (long)voteLeft]];
    } else if (voteLeft >= 10000) {
        NSLog(@"voteLeft >= 10000");
        voteLeft = voteLeft/ 1000;
        self.remainingVoteLabel.text = [NSString stringWithFormat: @"今日剩餘票數: %ldK", (long)voteLeft];
        [LabelAttributeStyle changeGapString: self.remainingVoteLabel content: [NSString stringWithFormat: @"今日剩餘票數: %ldK", (long)voteLeft]];
    } else {
        NSLog(@"else");
        self.remainingVoteLabel.text = [NSString stringWithFormat: @"今日剩餘票數: %ld", (long)voteLeft];
        [LabelAttributeStyle changeGapString: self.remainingVoteLabel content: [NSString stringWithFormat: @"今日剩餘票數: %ld", (long)voteLeft]];
        NSLog(@"self.remainingVoteLabel.text: %@", self.remainingVoteLabel.text);
    }
    [self.remainingVoteLabel sizeToFit];
}

- (IBAction)backBtnPress:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.myNav popViewControllerAnimated: YES];
}

- (void)refresh {
    NSLog(@"");
    NSLog(@"refresh");
    NSLog(@"isReloading: %d", isReloading);
    if (!isReloading) {
        isReloading = YES;
        nextId = 0;
        isLoading = NO;
        // Reset data before loading new data
        //voteArray = nil;
        [self loadData];
    }
}

- (void)loadData {
    NSLog(@"");
    NSLog(@"loadData");
    // If isLoading is NO then run the following code
    if (!isLoading) {
        if (nextId == 0) {
            NSLog(@"nextId: %ld", (long)nextId);
        }
        isLoading = YES;
        [self getEventVoteList];
    }
}

- (void)processEventVoteList:(NSDictionary *)dic {
    NSString *resultStr = dic[@"result"];
    
    if ([resultStr isEqualToString: @"SYSTEM_OK"]) {
        NSLog(@"resultStr isEqualToString SYSTEM_OK");
        
        if (nextId == 0) {
            voteArray = [NSMutableArray new];
        }
        
        // s for counting how much data is loaded
        int s = 0;
        
        if (![wTools objectExists: dic[@"data"][@"eventjoin"]]) {
            return;
        }
        for (NSMutableDictionary *vote in [dic objectForKey: @"data"][@"eventjoin"]) {
            s++;
            [voteArray addObject: vote];
        }
        NSLog(@"voteArray.count: %lu", (unsigned long)voteArray.count);
        // If data keeps loading then the nextId is accumulating
        nextId = nextId + s;
        
        // If nextId is bigger than 0, that means there are some data loaded already.
        if (nextId >= 0) {
            isLoading = NO;
        }
        // If s is 0, that means dic data is empty
        if (s == 0) {
            isLoading = YES;
        }
        [self.collectionView reloadData];
        [self.refreshControl endRefreshing];
        isReloading = NO;
        
        voteLeft = [dic[@"data"][@"event"][@"vote_left"] intValue];
        [self updateRemainingVoteLabel];
        
    } else if ([resultStr isEqualToString: @"SYSTEM_ERROR"]) {
        NSLog(@"resultStr isEqualToString SYSTEM_ERROR");
        [self showCustomErrorAlert: @"不明錯誤"];
        
        [self.refreshControl endRefreshing];
        isReloading = NO;
    } else if ([resultStr isEqualToString: @"USER_ERROR"]) {
        NSLog(@"resultStr isEqualToString USER_ERROR");
        NSLog(@"失敗： %@", dic[@"message"]);
        if ([wTools objectExists: dic[@"message"]]) {
            [self showCustomErrorAlert: dic[@"message"]];
        } else {
            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
        }
        [self.refreshControl endRefreshing];
        isReloading = NO;
    } else if ([dic[@"result"] isEqualToString: @"TOKEN_ERROR"]) {
        NSLog(@"resultStr isEqualToString TOKEN_ERROR");
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

- (void)getEventVoteList {
    NSLog(@"");
    NSLog(@"getEventVoteList");
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught");
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    NSString *limit = [NSString stringWithFormat: @"%ld,%d", (long)nextId, 16];
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI getEventVoteList: self.eventId
                                                limit: limit
                                                token: [wTools getUserToken]
                                               userId: [wTools getUserID]];
        
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
                NSLog(@"response from getEventVoteList");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"VotingViewController");
                    NSLog(@"getEventVoteList");
                    
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getEventVoteList"
                                         albumId: @""
                                       indexPath: nil];
                    [wself.refreshControl endRefreshing];
                    wself->isReloading = NO;
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    [wself processEventVoteList:dic];
                }
            } else {
                [wself.refreshControl endRefreshing];
                wself->isReloading = NO;
            }
        });
    });
}

- (void)logOut {
    [wTools logOut];
}

- (void)vote:(NSString *)albumId
   indexPath:(NSIndexPath *)indexPath {
    NSLog(@"\nvote");
    NSLog(@"indexPath.row: %ld", (long)indexPath.row);
    
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = [boxAPI vote: albumId
                                  eventId: self.eventId
                                    token: [wTools getUserToken]
                                   userId: [wTools getUserID]];
        
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
                NSLog(@"response from vote");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"VotingViewController");
                    NSLog(@"Vote");
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"vote"
                                         albumId: albumId
                                       indexPath: indexPath];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    [wself processVoteResult:dic indexPath:indexPath];
                }
            }
        });
    });
}

- (void)processVoteResult:(NSDictionary *)dic
                indexPath:(NSIndexPath *)indexPath{
    NSString *resultStr = dic[@"result"];
    
    if ([resultStr isEqualToString: @"SYSTEM_OK"]) {
        NSLog(@"resultStr isEqualToString SYSTEM_OK");
        voteLeft = [dic[@"data"][@"event"][@"vote_left"] intValue];
        [self updateRemainingVoteLabel];
        
        VotingCollectionViewCell *cell = (VotingCollectionViewCell *)[self.collectionView cellForItemAtIndexPath: indexPath];
        cell.votedLabel.hidden = NO;
        cell.voteBtn.hidden = YES;
        
        [self refresh];
    } else if ([resultStr isEqualToString: @"SYSTEM_ERROR"]) {
        NSLog(@"resultStr isEqualToString SYSTEM_ERROR");
        [self showCustomErrorAlert: @"不明錯誤"];
    } else if ([resultStr isEqualToString: @"USER_ERROR"]) {
        NSLog(@"resultStr isEqualToString USER_ERROR");
        NSLog(@"失敗： %@", dic[@"message"]);
        if ([wTools objectExists: dic[@"message"]]) {
            [self showCustomErrorAlert: dic[@"message"]];
        } else {
            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
        }
    } else if ([dic[@"result"] isEqualToString: @"TOKEN_ERROR"]) {
        NSLog(@"resultStr isEqualToString TOKEN_ERROR");
        
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
#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return voteArray.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"viewForSupplementaryElementOfKind");
    VotingCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind: kind withReuseIdentifier: @"headerId" forIndexPath: indexPath];
    //headerView.topicLabel.text = @"Test";
    return headerView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForItemAtIndexPath");
    VotingCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"Voting" forIndexPath: indexPath];
    cell.contentView.subviews[0].backgroundColor = nil;
    NSDictionary *data = voteArray[indexPath.row];
    NSLog(@"voteArray: %@", voteArray);
    
    if ([data[@"album"][@"cover"] isEqual: [NSNull null]]) {
        cell.coverImageView.image = [UIImage imageNamed: @"bg200_no_image.jpg"];
    } else {
        [cell.coverImageView sd_setImageWithURL: [NSURL URLWithString: data[@"album"][@"cover"]]];
        cell.coverImageView.backgroundColor = [UIColor colorFromHexString: data[@"album"][@"cover_hex"]];
    }
    
    // UserForView Info Setting
    BOOL gotAudio = [data[@"album"][@"usefor"][@"audio"] boolValue];
    NSLog(@"gotAudio: %d", gotAudio);
    
    BOOL gotVideo = [data[@"album"][@"usefor"][@"video"] boolValue];
    NSLog(@"gotVideo: %d", gotVideo);
    
    BOOL gotExchange = [data[@"album"][@"usefor"][@"exchange"] boolValue];
    NSLog(@"gotExchange: %d", gotExchange);
    
    BOOL gotSlot = [data[@"album"][@"usefor"][@"slot"] boolValue];
    NSLog(@"gotSlot: %d", gotSlot);
    
    [cell.btn1 setImage: nil forState: UIControlStateNormal];
    [cell.btn2 setImage: nil forState: UIControlStateNormal];
    [cell.btn3 setImage: nil forState: UIControlStateNormal];
    
    cell.userInfoView.hidden = YES;
    
    if (gotAudio) {
        NSLog(@"gotAudio");
        cell.userInfoView.hidden = NO;
        [cell.btn3 setImage: [UIImage imageNamed: @"ic200_audio_play_dark"] forState: UIControlStateNormal];
        
        CGRect rect = cell.userInfoView.frame;
        rect.size.width = 28 * 1;
        cell.userInfoView.frame = rect;
        
        if (gotVideo) {
            NSLog(@"gotAudio");
            NSLog(@"gotVideo");
            [cell.btn3 setImage: [UIImage imageNamed: @"ic200_video_dark"] forState: UIControlStateNormal];
            [cell.btn2 setImage: [UIImage imageNamed: @"ic200_audio_play_dark"] forState: UIControlStateNormal];
            
            CGRect rect = cell.userInfoView.frame;
            rect.size.width = 28 * 2;
            cell.userInfoView.frame = rect;
            
            if (gotExchange || gotSlot) {
                NSLog(@"gotAudio");
                NSLog(@"gotVideo");
                NSLog(@"gotExchange or gotSlot");
                
                [cell.btn1 setImage: [UIImage imageNamed: @"ic200_audio_play_dark"] forState: UIControlStateNormal];
                [cell.btn2 setImage: [UIImage imageNamed: @"ic200_video_dark"] forState: UIControlStateNormal];
                [cell.btn3 setImage: [UIImage imageNamed: @"ic200_gift_dark"] forState: UIControlStateNormal];
                
                CGRect rect = cell.userInfoView.frame;
                rect.size.width = 28 * 3;
                cell.userInfoView.frame = rect;
            }
        }
    } else if (gotVideo) {
        NSLog(@"gotVideo");
        cell.userInfoView.hidden = NO;
        [cell.btn3 setImage: [UIImage imageNamed: @"ic200_video_dark"] forState: UIControlStateNormal];
        
        CGRect rect = cell.userInfoView.frame;
        rect.size.width = 28 * 1;
        cell.userInfoView.frame = rect;
        
        if (gotExchange || gotSlot) {
            NSLog(@"gotVideo");
            NSLog(@"gotExchange or gotSlot");
            [cell.btn3 setImage: [UIImage imageNamed: @"ic200_gift_dark"] forState: UIControlStateNormal];
            [cell.btn2 setImage: [UIImage imageNamed: @"ic200_video_dark"] forState: UIControlStateNormal];
            
            CGRect rect = cell.userInfoView.frame;
            rect.size.width = 28 * 2;
            cell.userInfoView.frame = rect;
        }
    } else if (gotExchange || gotSlot) {
        NSLog(@"gotExchange or gotSlot");
        cell.userInfoView.hidden = NO;
        [cell.btn3 setImage: [UIImage imageNamed: @"ic200_gift_dark"] forState: UIControlStateNormal];
        
        CGRect rect = cell.userInfoView.frame;
        rect.size.width = 28 * 1;
        cell.userInfoView.frame = rect;
    }
    
    // AlbumNameLabel Setting
    if (![data[@"album"][@"name"] isEqual: [NSNull null]]) {
        cell.albumNameLabel.text = data[@"album"][@"name"];
        [LabelAttributeStyle changeGapString: cell.albumNameLabel content: data[@"album"][@"name"]];
    }
    if (![data[@"album"][@"album_id"] isEqual:[NSNull null]]) {
        NSString *albumIdStr = [data[@"album"][@"album_id"] stringValue];
        cell.albumIdLabel.text = [NSString stringWithFormat: @"編號:%@", albumIdStr];
        [LabelAttributeStyle changeGapString: cell.albumIdLabel content: [NSString stringWithFormat: @"編號:%@", albumIdStr]];
    }
    if (![data[@"eventjoin"][@"count"] isEqual:[NSNull null]]) {
        NSInteger eventJoinInt = [data[@"eventjoin"][@"count"] integerValue];
        
        if (eventJoinInt >= 10000000) {
            NSLog(@"voteLeft >= 10000000");
            eventJoinInt = eventJoinInt / 1000000;
            cell.eventJoinLabel.text = [NSString stringWithFormat: @"票數:%ld", (long)eventJoinInt];
            [LabelAttributeStyle changeGapString: cell.eventJoinLabel content: [NSString stringWithFormat: @"票數:%ld", (long)eventJoinInt]];
        } else if (eventJoinInt >= 10000) {
            NSLog(@"voteLeft >= 10000");
            eventJoinInt = eventJoinInt/ 1000;
            cell.eventJoinLabel.text = [NSString stringWithFormat: @"票數:%ld", (long)eventJoinInt];
            [LabelAttributeStyle changeGapString: cell.eventJoinLabel content: [NSString stringWithFormat: @"票數:%ld", (long)eventJoinInt]];
        } else {
            NSLog(@"else");
            cell.eventJoinLabel.text = [NSString stringWithFormat: @"票數:%ld", (long)eventJoinInt];
            [LabelAttributeStyle changeGapString: cell.eventJoinLabel content: [NSString stringWithFormat: @"票數:%ld", (long)eventJoinInt]];
        }
    }
    
    // Check rank label
    NSLog(@"indexPath.row: %ld", (long)indexPath.row);
    
    if (indexPath.row <= 59) {
        NSLog(@"indexPath.row <= 59");
        cell.rankLabel.text = [NSString stringWithFormat: @"%ld", (long)(indexPath.row + 1)];
        [LabelAttributeStyle changeGapString: cell.rankLabel content: [NSString stringWithFormat: @"%ld", (long)(indexPath.row + 1)]];
        cell.rankLabel.hidden = NO;
    } else {
        cell.rankLabel.hidden = YES;
    }
    
    if ([data[@"user"][@"picture"] isEqual: [NSNull null]]) {
        cell.userPictureImageView.image = [UIImage imageNamed: @"member_back_head.png"];
    } else {
        [cell.userPictureImageView sd_setImageWithURL: [NSURL URLWithString: data[@"user"][@"picture"]]];
    }
    
    // UserNameLabel Setting
    if (![data[@"user"][@"name"] isEqual: [NSNull null]]) {
        cell.userNameLabel.text = data[@"user"][@"name"];
        [LabelAttributeStyle changeGapString: cell.userNameLabel content: data[@"user"][@"name"]];
    }
    
    if (![data[@"album"][@"has_voted"] isEqual: [NSNull null]]) {
        BOOL isVoted = [data[@"album"][@"has_voted"] boolValue];
        NSLog(@"isVoted: %d", isVoted);
        
        if (isVoted) {
            NSLog(@"isVoted");
            cell.votedLabel.hidden = NO;
            cell.voteBtn.hidden = YES;
        } else {
            NSLog(@"isNotVoted");
            cell.votedLabel.hidden = YES;
            cell.voteBtn.hidden = NO;
        }
    }
    [LabelAttributeStyle changeGapString: cell.votedLabel content: cell.votedLabel.text];
    cell.userId = data[@"user"][@"user_id"];
    cell.albumId = data[@"album"][@"album_id"];
    
    cell.userBtnBlock = ^(BOOL selected, NSString *userId, NSString *albumId) {
        if (![wTools objectExists: userId]) {
            return;
        }
        CreaterViewController *cVC = [[UIStoryboard storyboardWithName: @"CreaterVC" bundle: nil] instantiateViewControllerWithIdentifier: @"CreaterViewController"];
        cVC.userId = userId;
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.myNav pushViewController: cVC animated: YES];
    };
    
    cell.voteBtnBlock = ^(BOOL selected, NSString *userId, NSString *albumId) {
        NSLog(@"albumId: %@", albumId);
        NSString *msg = [NSString stringWithFormat: @"投票給[%@]?", data[@"album"][@"name"]];
        [self showCustomAlertForVote: msg
                             albumId: albumId
                           indexPath: indexPath];
    };
    return cell;
}

#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"");
    NSLog(@"willDisplayCell");
    NSLog(@"indexPath.item: %ld", (long)indexPath.item);
    NSLog(@"voteArray.count: %lu", (unsigned long)voteArray.count);
    
    if (indexPath.item == (voteArray.count - 1)) {
        [self loadData];
    }
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath: indexPath];
    VotingCollectionViewCell *cell = (VotingCollectionViewCell *)[collectionView cellForItemAtIndexPath: indexPath];
    //cell.contentView.subviews[0].backgroundColor = [UIColor thirdMain];
    NSString *albumId = [voteArray[indexPath.row][@"album"][@"album_id"] stringValue];
    
    if (![wTools objectExists: albumId]) {
        return;
    }
    
    CGRect source = [self.view convertRect:cell.frame fromView:collectionView];
    
    @try {
        YAlbumDetailContainerViewController *aDVC = [YAlbumDetailContainerViewController albumDetailVCWithAlbumID:albumId sourceRect:source sourceImageView:cell.coverImageView noParam:YES];
        
        aDVC.fromVC = @"VotingVC";
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.myNav pushViewController: aDVC animated: YES];
        
    } @catch (NSException *exception) {
        [self showCustomErrorAlert:@"Album id is empty"];
    } @finally {        
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView
didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
//    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath: indexPath];
    //cell.contentView.subviews[0].backgroundColor = nil;
}

#pragma mark - UICollectionViewDelegateFlowLayout Methods
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"");
    NSLog(@"sizeForItemAtIndexPath");
    
    NSDictionary *data = voteArray[indexPath.row];
    
    // Check Width & Height return value is nil or not
    NSNumber *coverWidth = data[@"album"][@"cover_width"];
    NSNumber *coverHeight = data[@"album"][@"cover_height"];
    
    NSInteger resultWidth;
    NSInteger resultHeight;
    
    if ([coverWidth isEqual: [NSNull null]]) {
        resultWidth = (self.view.bounds.size.width - 48) / 2;
    } else {
        resultWidth = [coverWidth integerValue];
    }
    
    if ([coverHeight isEqual: [NSNull null]]) {
        resultHeight = resultWidth;
    } else {
        resultHeight = [coverHeight integerValue];
    }
    
    CGFloat scale = [UIScreen mainScreen].scale;
    
    CGFloat widthForCoverImg = (self.view.bounds.size.width - 48) / 2;
    CGFloat heightForCoverImg = (resultHeight * widthForCoverImg) / resultWidth;
    
    NSLog(@"widthForCoverImg: %f", widthForCoverImg);
    NSLog(@"heightForCoverImg: %f", heightForCoverImg);
    
    if (heightForCoverImg < (36 * scale)) {
        heightForCoverImg = 36 * scale;
    }
    
    NSLog(@"heightForCoverImg: %f", heightForCoverImg);
    
    CGFloat width = ([UIScreen mainScreen].bounds.size.width - 16) / 2;
    return CGSizeMake(width, heightForCoverImg + 17 + 42 + 28);
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
    return 24;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    UIEdgeInsets itemInset = UIEdgeInsetsMake(8, 8, 8, 8);
    return itemInset;
}

#pragma mark - JCCollectionViewWaterfallLayoutDelegate
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
 heightForHeaderInSection:(NSInteger)section {
    NSLog(@"heightForHeaderInSection");
    return 78;
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (isLoading) {
        NSLog(@"isLoading: %d", isLoading);
        return;
    }
}

#pragma mark - Custom AlertView for Yes and No
- (void)showCustomAlertForVote: (NSString *)msg
                       albumId: (NSString *)albumId
                     indexPath: (NSIndexPath *)indexPath {
    NSLog(@"showCustomAlertForYesAndNo: Msg: %@", msg);
    CustomIOSAlertView *alertViewForVote = [[CustomIOSAlertView alloc] init];
    //[alertViewForVote setContainerView: [self createContainerViewForVote: msg]];
    [alertViewForVote setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertViewForVote.arrangeStyle = @"Horizontal";
    
    [alertViewForVote setButtonTitles: [NSMutableArray arrayWithObjects: @"取消", @"確定", nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertViewForVote setButtonColors: [NSMutableArray arrayWithObjects: [UIColor clearColor], [UIColor clearColor],nil]];
    [alertViewForVote setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstGrey], nil]];
    [alertViewForVote setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    //alertView.arrangeStyle = @"Vertical";
    
    __weak CustomIOSAlertView *weakAlertViewForVote = alertViewForVote;
    __weak typeof(self) weakSelf = self;
    [alertViewForVote setOnButtonTouchUpInside:^(CustomIOSAlertView *alertViewForVote, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertViewForVote tag]);
        [weakAlertViewForVote close];
        
        if (buttonIndex == 0) {
            
        } else {
            [weakSelf vote: albumId indexPath: indexPath];
        }
    }];
    [alertViewForVote setUseMotionEffects: YES];
    [alertViewForVote show];
}

- (UIView *)createContainerViewForVote: (NSString *)msg {
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
- (void)showCustomErrorAlert: (NSString *)msg {
    [UIViewController showCustomErrorAlertWithMessage:msg onButtonTouchUpBlock:^(CustomIOSAlertView *customAlertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[customAlertView tag]);
        [customAlertView close];
    }];
}

#pragma mark - Custom Method for TimeOut
- (void)showCustomTimeOutAlert: (NSString *)msg
                  protocolName: (NSString *)protocolName
                       albumId: (NSString *)albumId
                     indexPath: (NSIndexPath *)indexPath {
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
            if ([protocolName isEqualToString: @"getEventVoteList"]) {
                [weakSelf getEventVoteList];
            } else if ([protocolName isEqualToString: @"vote"]) {
                [weakSelf vote: albumId indexPath: indexPath];
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
