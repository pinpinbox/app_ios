//
//  SetupMusicViewController.m
//  wPinpinbox
//
//  Created by David on 6/20/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "SetupMusicViewController.h"
#import "UIColor+Extensions.h"
#import "boxAPI.h"
#import "wTools.h"
#import <AVFoundation/AVFoundation.h>
#import "CustomIOSAlertView.h"
#import "UIView+Toast.h"
#import "GlobalVars.h"

#import "AppDelegate.h"

static void *AVPlayerDemoPlaybackViewControllerRateObservationContext = &AVPlayerDemoPlaybackViewControllerRateObservationContext;
static void *AVPlayerDemoPlaybackViewControllerStatusObservationContext = &AVPlayerDemoPlaybackViewControllerStatusObservationContext;
static void *AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext = &AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext;

@interface SetupMusicViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
{
    NSMutableArray *musicArray;
    NSDictionary *mdata;
    
    AVPlayer *player;
    AVPlayerItem *playerItem;
    
    NSString *oldAudioMode;
    
    BOOL isAudioModeChanged;
}

@property (strong, nonatomic) AVPlayer *avPlayer;
@property (strong, nonatomic) AVPlayerItem *avPlayerItem;
@property (assign, nonatomic) BOOL isReadyToPlay;

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@property (weak, nonatomic) IBOutlet UIView *noMusicSelectionView;
@property (weak, nonatomic) IBOutlet UIView *noMusicView;

@property (weak, nonatomic) IBOutlet UIView *eachPageSelectionView;
@property (weak, nonatomic) IBOutlet UIView *eachPageMusicView;

@property (weak, nonatomic) IBOutlet UIView *bgMusicSelectionView;
@property (weak, nonatomic) IBOutlet UIView *bgMusicView;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation SetupMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"SetupMusicViewController viewDidLoad");
    
    // Check avPlayer is ready or not
    self.isReadyToPlay = NO;
    
    [self setupUI];
    [self getAlbumDataOptions];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    @try {
        [self removeObserverForAVPlayerItem];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupUI
{
    self.saveBtn.layer.cornerRadius = 8;
    
    self.noMusicSelectionView.layer.cornerRadius = 8;
    self.noMusicSelectionView.layer.borderColor = [UIColor thirdGrey].CGColor;
    self.noMusicSelectionView.layer.borderWidth = 1.0;
    
    self.eachPageSelectionView.layer.cornerRadius = 8;
    self.eachPageSelectionView.layer.borderColor = [UIColor thirdGrey].CGColor;
    self.eachPageSelectionView.layer.borderWidth = 1.0;
    
    self.bgMusicSelectionView.layer.cornerRadius = 8;
    self.bgMusicSelectionView.layer.borderColor = [UIColor thirdGrey].CGColor;
    self.bgMusicSelectionView.layer.borderWidth = 1.0;
    
    self.collectionView.showsHorizontalScrollIndicator = NO;
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
                    NSLog(@"SetupMusicViewController");
                    NSLog(@"getAlbumDataOptions");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getalbumdataoptions"
                                         jsonStr: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    NSLog(@"getalbumdataoptions");
                    
                    if ([dic[@"result"] intValue] == 1) {
                        mdata = [dic[@"data"] mutableCopy];
                        //NSLog(@"mdata: %@", mdata);                        
                        [self getAlbumSettings];
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

- (void)getAlbumSettings {
    NSLog(@"getAlbumSettings");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *response = [boxAPI getalbumsettings: [wTools getUserID]
                                                token: [wTools getUserToken]
                                             album_id: self.albumId];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (response != nil) {
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"SetupMusicViewController");
                    NSLog(@"getAlbumSettings");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getalbumsettings"
                                         jsonStr: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        self.data = [dic[@"data"] mutableCopy];
                        NSLog(@"self.data: %@", self.data);
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗：%@",dic[@"message"]);
                        [self showCustomErrorAlert: dic[@"message"]];
                    } else {
                        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            }            
            [self initialValueSetup];
        });
    });
}

- (void)initialValueSetup
{
    NSLog(@"initialValueSetup");
    
    NSLog(@"self.audioMode: %@", self.audioMode);
    
    isAudioModeChanged = NO;
    
    oldAudioMode = self.audioMode;
    
    if ([self.audioMode isEqualToString: @"none"]) {
        self.noMusicSelectionView.backgroundColor = [UIColor thirdMain];
    } else if ([self.audioMode isEqualToString: @"singular"]) {
        self.bgMusicSelectionView.backgroundColor = [UIColor thirdMain];
    } else if ([self.audioMode isEqualToString: @"plural"]) {
        self.eachPageSelectionView.backgroundColor = [UIColor thirdMain];
    }
    
    musicArray = [NSMutableArray new];
    
    if (![self.data[@"audio"] isKindOfClass: [NSNull class]]) {
        NSLog(@"self.data audio is not kind of null calss");
        if (![self.data[@"audio"] isEqualToString: @""]) {
            NSLog(@"self.data audio is not equal to string empty");
            
            for (NSMutableDictionary *d in mdata[@"audio"]) {
                NSLog(@"self.data audio: %@", self.data[@"audio"]);
                NSLog(@"d id: %@", d[@"id"]);
                
                if ([self.data[@"audio"] isEqualToString: [d[@"id"] stringValue]]) {
                    [d setValue: [NSNumber numberWithBool: YES] forKey: @"selected"];
                } else {
                    [d setValue: [NSNumber numberWithBool: NO] forKey: @"selected"];
                }
                [musicArray addObject: d];
            }
        } else {
            NSLog(@"self.data audio is equal to string empty");
            
            for (NSMutableDictionary *d in mdata[@"audio"]) {
                [d setValue: [NSNumber numberWithBool: NO] forKey: @"selected"];
                [musicArray addObject: d];
            }
        }
    } else {
        NSLog(@"self.data audio is kind of null calss");
        
        for (NSMutableDictionary *d in mdata[@"audio"]) {
            [d setValue: [NSNumber numberWithBool: NO] forKey: @"selected"];
            [musicArray addObject: d];
        }
    }

    
    NSLog(@"");
    NSLog(@"");
    //NSLog(@"musicArray: %@", musicArray);
    
    [self.collectionView reloadData];
}

#pragma mark - Touches Methods
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesBegan");
    
    CGPoint location = [[touches anyObject] locationInView: self.view];
    CGRect fingerRect = CGRectMake(location.x - 5, location.y - 5, 10, 10);
    
    for (UIView *view in self.view.subviews) {
        CGRect subviewFrame = view.frame;
        
        if (CGRectIntersectsRect(fingerRect, subviewFrame)) {
            NSLog(@"finally touched view: %@", view);
            NSLog(@"view.tag: %ld", (long)view.tag);
            
            switch (view.tag) {
                case 1:
//                    self.noMusicView.backgroundColor = [UIColor thirdMain];
                    
                    self.noMusicSelectionView.backgroundColor = [UIColor thirdMain];
                    self.eachPageSelectionView.backgroundColor = [UIColor clearColor];
                    self.bgMusicSelectionView.backgroundColor = [UIColor clearColor];
                    
                    self.audioMode = @"none";
                    break;
                case 2:
//                    self.eachPageMusicView.backgroundColor = [UIColor thirdMain];
                    
                    self.noMusicSelectionView.backgroundColor = [UIColor clearColor];
                    self.eachPageSelectionView.backgroundColor = [UIColor thirdMain];
                    self.bgMusicSelectionView.backgroundColor = [UIColor clearColor];
                    
                    self.audioMode = @"plural";
                    break;
                case 3:
//                    self.bgMusicView.backgroundColor = [UIColor thirdMain];
                    
                    self.noMusicSelectionView.backgroundColor = [UIColor clearColor];
                    self.eachPageSelectionView.backgroundColor = [UIColor clearColor];
                    self.bgMusicSelectionView.backgroundColor = [UIColor thirdMain];
                    
                    self.audioMode = @"singular";
                    
                    break;
                default:
                    break;
            }
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesMoved");
    
    CGPoint location = [[touches anyObject] locationInView: self.view];
    CGRect fingerRect = CGRectMake(location.x - 5, location.y - 5, 10, 10);
    
    for (UIView *view in self.view.subviews) {
        CGRect subviewFrame = view.frame;
        
        if (CGRectIntersectsRect(fingerRect, subviewFrame)) {
            NSLog(@"finally touched view: %@", view);
            NSLog(@"view.tag: %ld", (long)view.tag);
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesEnded");
    
    CGPoint location = [[touches anyObject] locationInView: self.view];
    CGRect fingerRect = CGRectMake(location.x - 5, location.y - 5, 10, 10);
    
    for (UIView *view in self.view.subviews) {
        CGRect subviewFrame = view.frame;
        
        if (CGRectIntersectsRect(fingerRect, subviewFrame)) {
            NSLog(@"finally touched view: %@", view);
            NSLog(@"view.tag: %ld", (long)view.tag);
            
            switch (view.tag) {
                case 1:
                    self.noMusicView.backgroundColor = [UIColor clearColor];
                    break;
                case 2:
                    self.eachPageMusicView.backgroundColor = [UIColor clearColor];
                    break;
                case 3:
                    self.bgMusicView.backgroundColor = [UIColor clearColor];
                default:
                    break;
            }
        }
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesCancelled");
    
    CGPoint location = [[touches anyObject] locationInView: self.view];
    CGRect fingerRect = CGRectMake(location.x - 5, location.y - 5, 10, 10);
    
    for (UIView *view in self.view.subviews) {
        CGRect subviewFrame = view.frame;
        
        if (CGRectIntersectsRect(fingerRect, subviewFrame)) {
            NSLog(@"finally touched view: %@", view);
            NSLog(@"view.tag: %ld", (long)view.tag);
        }
    }
}

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"musicArray.count: %lu", (unsigned long)musicArray.count);
    return musicArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"");
    NSLog(@"");
    NSLog(@"cellForItemAtIndexPath");
    
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: identifier forIndexPath: indexPath];
    cell.layer.cornerRadius = 8;
    
    UILabel *textLabel = (UILabel *)[cell viewWithTag: 100];
    textLabel.text = musicArray[indexPath.row][@"name"];
    
    if ([musicArray[indexPath.row][@"selected"] boolValue]) {
        cell.layer.backgroundColor = [UIColor thirdMain].CGColor;
    } else {
        cell.layer.backgroundColor = [UIColor thirdGrey].CGColor;
    }        
    return cell;
}

#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectItemAtIndexPath");
    
    // Switch to Singluar Mode
    self.noMusicSelectionView.backgroundColor = [UIColor clearColor];
    self.eachPageSelectionView.backgroundColor = [UIColor clearColor];
    self.bgMusicSelectionView.backgroundColor = [UIColor thirdMain];
    
    self.audioMode = @"singular";
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath: indexPath];
    cell.layer.backgroundColor = [UIColor thirdMain].CGColor;
    //self.selectedIndexPath = indexPath;
    
    NSLog(@"mdata: %@", mdata);
    NSArray *arr = mdata[@"audio"];
    NSString *strUrl = arr[indexPath.row][@"url"];
    NSLog(@"strUrl: %@", strUrl);
    
    [self avPlayerSetUp: strUrl];
    
    /*
    NSURL *url = [NSURL URLWithString: strUrl];
    
    if (player!=nil) {
        [player pause];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        playerItem = [AVPlayerItem playerItemWithURL:url];
        player = [AVPlayer playerWithPlayerItem:playerItem];
        player.volume = 1.0;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [player play];
        });
    });
    */
    for (NSMutableDictionary *d in musicArray) {
        if ([d[@"selected"] boolValue]) {
            [d setObject: [NSNumber numberWithBool: NO] forKey: @"selected"];
        }
    }
    musicArray[indexPath.row][@"selected"] = [NSNumber numberWithBool: YES];

    NSLog(@"musicArray: %@", musicArray);
    
    for (NSDictionary *d in musicArray) {
        NSLog(@"selected: %@", d[@"selected"]);
    }
    
    [self.collectionView reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didDeselectItemAtIndexPath");
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath: indexPath];
    cell.layer.cornerRadius = 8;
    cell.layer.backgroundColor = [UIColor thirdGrey].CGColor;
    
    //self.selectedIndexPath = nil;
}

#pragma mark - AVPlayer Section
- (void)avPlayerSetUp: (NSString *)audioData
{
    NSLog(@"avPlayerSetUp");
    
    //註冊audioInterrupted
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver: self selector: @selector(audioInterrupted:) name: AVAudioSessionInterruptionNotification object: nil];
    
    // 1. Set Up URL Audio Source
    NSURL *audioUrl = [NSURL URLWithString: audioData];
    
    // 2. PlayerItem Setup
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL: audioUrl options: nil];
    NSArray *requestedKeys = @[@"playable"];
    
    // Tells the asset to load the values of any of the specified keys that are not already loaded.
    [asset loadValuesAsynchronouslyForKeys: requestedKeys completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self prepareToPlayAsset: asset withKeys: requestedKeys];
        });
    }];
}

#pragma mark Prepare to play asset, URL
/*
 Invoked at the completion of the loading of the values for all keys on the asset that we require.
 Checks whether loading was successfull and whether the asset is playable.
 If so, sets up an AVPlayerItem and an AVPlayer to play the asset.
 */

- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys
{
    NSLog(@"");
    NSLog(@"prepareToPlayAsset");
    
    /* Make sure that the value of each key has loaded successfully. */
    for (NSString *thisKey in requestedKeys) {
        NSLog(@"");
        NSLog(@"thisKey: %@", thisKey);
        
        NSError *error = nil;
        AVKeyValueStatus keyStatus = [asset statusOfValueForKey: thisKey error: &error];
        NSLog(@"keyStatus: %ld", (long)keyStatus);
        
        if (keyStatus == AVKeyValueStatusFailed) {
            NSLog(@"keyStatus == AVKeyValueStatusFailed");
            return;
        }
        /* If you are also implementing -[AVAsset cancelLoading], add your code here to bail out properly in the case of cancellation. */
    }
    
    // Use the AVAsset playable property to detect whether the asset can be played.
    if (!asset.playable) {
        NSLog(@"");
        NSLog(@"asset.playable: %d", asset.playable);
        
        /* Generate an error describing the failure. */
        NSString *localizedDescription = NSLocalizedString(@"Item cannot be played", @"Item cannot be played description");
        NSString *localizedFailureReason = NSLocalizedString(@"The assets tracks were loaded, but could not be made playable.", @"Item cannot be played failure reason");
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   localizedDescription, NSLocalizedDescriptionKey,
                                   localizedFailureReason, NSLocalizedFailureReasonErrorKey,
                                   nil];
        NSError *assetCannotBePlayedError = [NSError errorWithDomain:@"StitchedStreamPlayer" code:0 userInfo:errorDict];
        
        // Display the error to the user.
        [self assetFailedToPrepareForPlayback: assetCannotBePlayedError];
        
        return;
    }
    
    if (self.avPlayerItem) {
        NSLog(@"self.avPlayerItem Existed");
        NSLog(@"self.avPlayerItem removeObserver: self forKeyPath: status");
        @try {
            [self.avPlayerItem removeObserver: self
                                   forKeyPath: @"status"];
        } @catch (NSException *exception) {
            // Print exception information
            NSLog( @"NSException caught" );
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
            return;
        }
        
        /*
        NSLog(@"NSNotificationCenter removeObserver");
        [[NSNotificationCenter defaultCenter] removeObserver: self
                                                        name: AVPlayerItemDidPlayToEndTimeNotification
                                                      object: self.avPlayerItem];
         */
    }
    
    NSLog(@"self.avPlayerItem = [AVPlayerItem playerItemWithAsset: asset]");
    self.avPlayerItem = [AVPlayerItem playerItemWithAsset: asset];
    
    NSLog(@"self.avPlayerItem addObserver: self forKeyPath: status");
    [self.avPlayerItem addObserver: self
                        forKeyPath: @"status"
                           options: NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                           context: AVPlayerDemoPlaybackViewControllerStatusObservationContext];
    
    if (self.avPlayer != nil) {
        NSLog(@"self.avPlayer != nil");
        NSLog(@"self.avPlayer removeObserver: self forKeyPath: rate");
    }
    
    [self.avPlayer pause];
    NSLog(@"self.avPlayer = [AVPlayer playerWithPlayerItem: self.avPlayerItem]");
    self.avPlayer = [AVPlayer playerWithPlayerItem: self.avPlayerItem];
    // This loading audio faster feature is available iOS 10.0 not lower version
    self.avPlayer.automaticallyWaitsToMinimizeStalling = NO;
}

#pragma mark - Audio Interrupted
-(void)audioInterrupted:(NSNotification *)notification{
    NSLog(@"");
    NSLog(@"audioInterrupted");
    NSUInteger type=[notification.userInfo[AVAudioSessionInterruptionTypeKey] intValue];
    NSUInteger option=[notification.userInfo[AVAudioSessionInterruptionOptionKey]intValue];
    
    if (type == AVAudioSessionInterruptionTypeBegan) {
        NSLog(@"中斷音樂");
    }else if (type==AVAudioSessionInterruptionTypeBegan){
        if (option == AVAudioSessionInterruptionTypeEnded) {
            NSLog(@"中斷恢復");
            
            if (self.isReadyToPlay) {
                [NSThread sleepForTimeInterval: 0.1];
                [self.avPlayer play];
            }
        }
    }
}

// From Apple API Reference
// Informs the observing object when the value at the specified key path
// relative to the observed object has changed
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    NSLog(@"");
    NSLog(@"observeValueForKeyPath");
    
    NSLog(@"object: %@", object);
    
    if (context == AVPlayerDemoPlaybackViewControllerStatusObservationContext) {
        NSLog(@"context == AVPlayerDemoPlaybackViewControllerStatusObservationContext");
        
        switch (self.avPlayer.status) {
            case AVPlayerStatusUnknown:
            {
                NSLog(@"AVPlayerStatusUnknown");
                self.isReadyToPlay = NO;
            }
                break;
                
            case AVPlayerStatusReadyToPlay:
            {
                NSLog(@"AVPlayerStatusReadyToPlay");
                self.isReadyToPlay = YES;
                
                if (self.avPlayer != nil) {
                    NSLog(@"avPlayer is initialized");
                    
                    if (self.isReadyToPlay) {
                        NSLog(@"self.isReadyToPlay is set to YES");
                        
                        [self.avPlayer play];
                        NSLog(@"self.avPlayer play");
                        // Only for iOS 10
                        //[self.avPlayer playImmediatelyAtRate: 1.0];
                    } else {
                        NSLog(@"self.isReadyToPlay is set to NO");
                    }
                }
            }
                break;
                
            case AVPlayerStatusFailed:
            {
                NSLog(@"AVPlayerStatusFailed");
                self.isReadyToPlay = NO;
                AVPlayerItem *playerItem1 = (AVPlayerItem *)object;
                [self assetFailedToPrepareForPlayback: playerItem1.error];
            }
                break;
            default:
                break;
        }
    } else if (context == AVPlayerDemoPlaybackViewControllerRateObservationContext) {
        NSLog(@"context == AVPlayerDemoPlaybackViewControllerRateObservationContext");
    }
    
    else {
        NSLog(@"else");
        [super observeValueForKeyPath: keyPath ofObject: object change: change context: context];
    }
}

#pragma mark -
#pragma mark Error Handling - Preparing Assets for Playback Failed

/* --------------------------------------------------------------
 **  Called when an asset fails to prepare for playback for any of
 **  the following reasons:
 **
 **  1) values of asset keys did not load successfully,
 **  2) the asset keys did load successfully, but the asset is not
 **     playable
 **  3) the item did not become ready to play.
 ** ----------------------------------------------------------- */

-(void)assetFailedToPrepareForPlayback:(NSError *)error
{
    NSLog(@"");
    NSLog(@"assetFailedToPrepareForPlayback");
}

#pragma mark - IBAction Methods

- (void)removeObserverForAVPlayerItem
{
    if (self.avPlayerItem) {
        NSLog(@"self.avPlayerItem Existed");
        NSLog(@"self.avPlayerItem removeObserver: self forKeyPath: status");
        
        @try {
            [self.avPlayerItem removeObserver: self
                                   forKeyPath: @"status"];
        } @catch (NSException *exception) {
            // Print exception information
            NSLog( @"NSException caught" );
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
            return;
        }
        
    }
    
    @try {
        NSLog(@"NSNotificationCenter removeObserver");
        [[NSNotificationCenter defaultCenter] removeObserver: self
                                                        name: AVPlayerItemDidPlayToEndTimeNotification
                                                      object: self.avPlayerItem];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    
}

- (IBAction)exitBtnPress:(id)sender {
    NSLog(@"exitBtnPress");
    
    if ([self.delegate respondsToSelector: @selector(dismissFromSetupMusicVC:audioModeChanged:)]) {
        [self.delegate dismissFromSetupMusicVC: self audioModeChanged: nil];
    }
    //[self dismissViewControllerAnimated: YES completion: nil];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav dismissViewControllerAnimated: YES completion: nil];
}

- (IBAction)saveBtnPress:(id)sender {
    NSLog(@"");
    NSLog(@"");
    NSLog(@"saveBtnPress");
    
    NSLog(@"tempAudioMode: %@", oldAudioMode);
    NSLog(@"self.audioMode: %@", self.audioMode);
    
    if ([self.audioMode isEqualToString: oldAudioMode]) {
        if ([self.audioMode isEqualToString: @"singular"]) {
            BOOL hasBgMusic = NO;
            
            NSLog(@"musicArray: %@", musicArray);
            
            for (NSDictionary *d in musicArray) {
                if ([d[@"selected"] boolValue]) {
                    hasBgMusic = YES;
                }
            }
            
            NSLog(@"hasBgMusic: %d", hasBgMusic);
            
            if (hasBgMusic) {
                [self changeAudioMode];
            } else {
                //[self dismissViewControllerAnimated: YES completion: nil];
                
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [appDelegate.myNav dismissViewControllerAnimated: YES completion: nil];
            }
        } else {
            //[self dismissViewControllerAnimated: YES completion: nil];
            
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate.myNav dismissViewControllerAnimated: YES completion: nil];
        }
    } else {
        [self showCustomAlert: @"切換播放模式之後會將先前音效設定移除，確定要進行切換嗎?"];
    }
}

#pragma mark - Custom Alert Method
- (void)showCustomAlert: (NSString *)msg
{
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    //[alertView setContainerView: [self createContainerView: msg]];
    [alertView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertView.arrangeStyle = @"Horizontal";
    
    [alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"稍後再說", @"確定切換", nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor clearColor], [UIColor clearColor],nil]];
    [alertView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstGrey], nil]];
    [alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    //alertView.arrangeStyle = @"Vertical";
    
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
        
        [alertView close];
        
        if (buttonIndex == 0) {
            
        } else {
            [self changeAudioMode];
        }
    }];
    [alertView setUseMotionEffects: YES];
    [alertView show];
}

- (UIView *)createContainerView: (NSString *)msg
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

#pragma mark -

- (void)changeAudioMode
{
    NSLog(@"");
    NSLog(@"");
    NSLog(@"changeAudioMode");
    
    NSMutableDictionary *settingsDic = [NSMutableDictionary new];
    NSLog(@"self.audioMode: %@", self.audioMode);
    
    [settingsDic setObject: self.audioMode forKey: @"audio_mode"];
    
    // If Audio Mode is singular
    if ([self.audioMode isEqualToString: @"singular"]) {
        NSString *musicStr;
        
        NSLog(@"musicArray: %@", musicArray);
        
        // And music has selected
        for (NSDictionary *d in musicArray) {
            if ([d[@"selected"] boolValue]) {
                NSLog(@"%@", d[@"id"]);
                
                musicStr = d[@"id"];
                NSLog(@"musicStr: %d", [musicStr intValue]);
            }
        }
        NSLog(@"settingsDic setObject");
        
        if (musicStr == nil) {
            NSLog(@"musicStr is kind of null class");
        } else {
            NSLog(@"musicStr is not kind of null class");
            [settingsDic setObject: musicStr forKey: @"audio"];
        }
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: settingsDic
                                                       options: 0
                                                         error: nil];
    NSString *jsonStr = [[NSString alloc] initWithData: jsonData
                                              encoding: NSUTF8StringEncoding];
    NSLog(@"jsonStr: %@", jsonStr);
    
    [self callAlbumSettings: jsonStr];
}

- (void)callAlbumSettings: (NSString *)jsonStr
{
    NSLog(@"callAlbumSettings");
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
                NSLog(@"respone from albumsettings: %@", response);
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"SetupMusicViewController");
                    NSLog(@"callAlbumSettings");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"albumsettings"
                                         jsonStr: jsonStr];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    //if ([dic[@"result"]boolValue]) {
                    if ([dic[@"result"] isEqualToString: @"SYSTEM_OK"]) {
                        NSLog(@"dic: %@", dic);
                        
                        if ([self.audioMode isEqualToString: oldAudioMode]) {
                            isAudioModeChanged = NO;
                        } else {
                            isAudioModeChanged = YES;
                        }
                        
                        NSLog(@"isAudioModeChanged: %d", isAudioModeChanged);
                        
                        if ([self.delegate respondsToSelector: @selector(dismissFromSetupMusicVC:audioModeChanged:)]) {
                            [self.delegate dismissFromSetupMusicVC: self audioModeChanged: isAudioModeChanged];
                        }
                        
                        [self dismissViewControllerAnimated: YES completion: nil];
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

#pragma mark - Custom Alert Method
- (void)showCustomErrorAlert: (NSString *)msg
{
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    //[alertView setContainerView: [self createErrorContainerView: msg]];
    [alertView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstPink] badgeName:nil];
    [alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    [alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    [alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondPink]]];
    alertView.arrangeStyle = @"Horizontal";
    
    /*
     [alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
     [alertView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor firstMain], [UIColor firstPink], [UIColor secondGrey], nil]];
     [alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor darkMain], [UIColor darkPink], [UIColor firstGrey], nil]];
     alertView.arrangeStyle = @"Vertical";
     */
    
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
        [alertView close];
    }];
    [alertView setUseMotionEffects: YES];
    [alertView show];
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
                       jsonStr: (NSString *)jsonStr
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
            if ([protocolName isEqualToString: @"getalbumdataoptions"]) {
                [weakSelf getAlbumDataOptions];
            } else if ([protocolName isEqualToString: @"getalbumsettings"]) {
                [weakSelf getAlbumSettings];
            } else if ([protocolName isEqualToString: @"albumsettings"]) {
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
