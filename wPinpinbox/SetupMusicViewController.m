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
#import "UIViewController+ErrorAlert.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "SwitchButtonView.h"
#import "AudioUploader.h"
#import "MBProgressHUD.h"
#import "LabelAttributeStyle.h"

typedef NS_ENUM(NSInteger, SetupAudioType) {
    None = 1,
    Plural = 2,
    Singular = 3,
    Singular2 = 4
};

static void *AVPlayerDemoPlaybackViewControllerRateObservationContext = &AVPlayerDemoPlaybackViewControllerRateObservationContext;
static void *AVPlayerDemoPlaybackViewControllerStatusObservationContext = &AVPlayerDemoPlaybackViewControllerStatusObservationContext;
static void *AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext = &AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext;


@interface SetupMusicViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UIDocumentPickerDelegate>
{
    NSMutableArray *musicArray;
    NSDictionary *mdata;
    
    AVPlayer *player;
    AVPlayerItem *playerItem;
    
    //NSString *oldAudioMode;
    
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


@property (weak, nonatomic) IBOutlet UIView *audioBrowserView;
@property (weak, nonatomic) IBOutlet UIView *uploadMusicSelectionView;
@property (weak, nonatomic) IBOutlet UIView *audioUploadedView;
@property (weak, nonatomic) IBOutlet UIButton *uploadBtn;
@property (weak, nonatomic) IBOutlet CustomTintButton *playerBtn;
@property (nonatomic) AudioUploader *audioUploader;
@property (weak, nonatomic) IBOutlet  UILabel *uploadAudioFileName;
@property (nonatomic) MBProgressHUD *uploadProgress;
@property (nonatomic) SetupAudioType audioType;
@property (nonatomic) SetupAudioType dataAudioType; // audiotype from getalbumsettings

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *noMusicTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *noMusicSubTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *mutipleSongTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *multipleSongSubTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *singleSongTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *singleSongSubTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *uploadTitleLabel;

@end

@implementation SetupMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"SetupMusicViewController viewDidLoad");

    // Check avPlayer is ready or not
    self.isReadyToPlay = NO;
    
    self.audioType = None;
    
    [self setupUI];
    [self getAlbumDataOptions];
    
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: self.titleLabel content: self.titleLabel.text];
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: self.noMusicTitleLabel content: self.noMusicTitleLabel.text];
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: self.noMusicSubTitleLabel content: self.noMusicSubTitleLabel.text];
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: self.mutipleSongTitleLabel content: self.mutipleSongTitleLabel.text];
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: self.multipleSongSubTitleLabel content: self.multipleSongSubTitleLabel.text];
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: self.singleSongTitleLabel content: self.singleSongTitleLabel.text];
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: self.singleSongSubTitleLabel content: self.singleSongSubTitleLabel.text];
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: self.uploadTitleLabel content: self.uploadTitleLabel.text];
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: self.uploadBtn.titleLabel content: self.uploadBtn.titleLabel.text];
    [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: self.saveBtn.titleLabel content: self.saveBtn.titleLabel.text];
}

- (void)viewWillDisappear:(BOOL)animated {
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
- (void)optionsTapped:(UITapGestureRecognizer *)tap {
    if (tap.view)
        [self setMusicReferByType:(int)tap.view.tag];
}

- (void)setupUI {
    self.saveBtn.layer.cornerRadius = 8;
    UITapGestureRecognizer *t = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(optionsTapped:)];
    [self.noMusicView addGestureRecognizer:t];
    self.noMusicSelectionView.layer.cornerRadius = 8;
    self.noMusicSelectionView.layer.borderColor = [UIColor thirdGrey].CGColor;
    self.noMusicSelectionView.layer.borderWidth = 1.0;
    
    UITapGestureRecognizer *t1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(optionsTapped:)];
    [self.eachPageMusicView addGestureRecognizer:t1];
    self.eachPageSelectionView.layer.cornerRadius = 8;
    self.eachPageSelectionView.layer.borderColor = [UIColor thirdGrey].CGColor;
    self.eachPageSelectionView.layer.borderWidth = 1.0;
    
    UITapGestureRecognizer *t2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(optionsTapped:)];
    [self.bgMusicView addGestureRecognizer:t2];
    self.bgMusicSelectionView.layer.cornerRadius = 8;
    self.bgMusicSelectionView.layer.borderColor = [UIColor thirdGrey].CGColor;
    self.bgMusicSelectionView.layer.borderWidth = 1.0;
    
    self.collectionView.showsHorizontalScrollIndicator = NO;
    
    self.uploadMusicSelectionView.layer.cornerRadius = 8;
    self.uploadMusicSelectionView.layer.borderColor = [UIColor thirdGrey].CGColor;
    self.uploadMusicSelectionView.layer.borderWidth = 1.0;
    
    [self.playerBtn setImage:[UIImage imageNamed:@"button_play"] forState:UIControlStateNormal];
    [self.playerBtn setImage:[UIImage imageNamed:@"button_stop"] forState:UIControlStateSelected];
    [self.playerBtn setTintColor:[UIColor darkGrayColor]];

    if (@available(iOS 11.0, *)) {
        UITapGestureRecognizer *t3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(optionsTapped:)];
        [self.audioBrowserView addGestureRecognizer:t3];
        
        //  File picker only works on iOS 11.0 later //
        self.uploadBtn.enabled = YES;
    } else {
        //self.audioBrowserView.hidden = ;
        self.uploadBtn.hidden = YES;
        self.uploadBtn.enabled = NO;
    }
}

- (void)processAlbumDataOptions:(NSDictionary *)dic {
    if ([dic[@"result"] intValue] == 1) {
        mdata = [dic[@"data"] mutableCopy];
        //NSLog(@"mdata: %@", mdata);
        [self getAlbumSettings];
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

- (void)getAlbumDataOptions {
    NSLog(@"getAlbumDataOptions");
    @try {
        [DGHUDView start];
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
                [DGHUDView stop];
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
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getalbumdataoptions"
                                         jsonStr: @""];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    NSLog(@"getalbumdataoptions");
                    [wself processAlbumDataOptions:dic];
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
                    NSString *res = (NSString *)dic[@"result"];
                    
                    if ([res isEqualToString:@"SYSTEM_OK"]) {
                        self.data = [[NSMutableDictionary alloc] initWithDictionary:dic[@"data"]];
                        NSLog(@"self.data: %@", self.data);
                    } else if (dic[@"message"]) {//([dic[@"result"] intValue] == 0) {
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
            [self initialValueSetup];
        });
    });
}

- (void)collectSingularAudioSetting {
    if ( [wTools objectExists:self.data[@"audio"]]){
        
        if (![self.data[@"audio"] isEqualToString: @""]) {
            int i = [self.data[@"audio_target"] intValue];
            [self.data setObject:self.data[@"audio"] forKey:@"audio_target"];
            [self.data setObject:@"system" forKey:@"audio_refer"];
            for (NSMutableDictionary *d in musicArray) {
                if ([d[@"id"] intValue] == i) {
                    [d setValue: [NSNumber numberWithBool: YES] forKey: @"selected"];
                    break;
                }
            }
        }
        
    } else {
        //  refresh selected cell
        if ( [wTools objectExists:self.data[@"audio_target"]]) {
            int i = [self.data[@"audio_target"] intValue];
            for (NSMutableDictionary *d in musicArray) {
                if ([d[@"id"] intValue] == i) {
                    [d setValue: [NSNumber numberWithBool: YES] forKey: @"selected"];
                    break;
                }
            }
        }
    }
}
- (void)setDataAudioType {
    
    self.dataAudioType = None;
    
    NSString *mode = self.data[@"audio_mode"];
    NSString *refer = self.data[@"audio_refer"];
    NSString *target = self.data[@"audio_target"];
    if (mode && [mode isKindOfClass:[NSString class]]) {
        self.audioMode = mode;
        if ([mode isEqualToString:@"plural"])
            self.dataAudioType = Plural;
        else if ([mode isEqualToString:@"none"])
            self.dataAudioType = None;
        else if ([mode isEqualToString:@"singular"]) {
            if ([refer isEqualToString:@"system"]) {
                    self.dataAudioType = Singular;
            } else if (target)
                self.dataAudioType = Singular2;
        }
    }
    self.audioType = self.dataAudioType;
    
}
- (void)initialValueSetup
{
    NSLog(@"initialValueSetup");
    
    //  check current audioType from server
    [self setDataAudioType];
    
    if (self.data[@"audio_mode"] && [self.data[@"audio_mode"] isKindOfClass:[NSString class]])
        self.audioMode = self.data[@"audio_mode"];
    else
        self.audioMode = @"none";
    
    isAudioModeChanged = NO;
    
    //oldAudioMode = self.audioMode;
    
    musicArray = [NSMutableArray new];
    for (NSMutableDictionary *d in mdata[@"audio"]) {
        [d setValue: [NSNumber numberWithBool: NO] forKey: @"selected"];
        [musicArray addObject: d];
    }
    
    if ([self.audioMode isEqualToString: @"none"]) {
        self.noMusicSelectionView.backgroundColor = [UIColor thirdMain];
    } else if ([self.audioMode isEqualToString: @"singular"]) {
        
        if (self.data[@"audio_refer"] && [self.data[@"audio_refer"] isEqualToString:@"file"]) {
            self.uploadMusicSelectionView.backgroundColor = [UIColor thirdMain];
            [self loadSingular2Settings];
        }
        else {
            self.bgMusicSelectionView.backgroundColor = [UIColor thirdMain];
            [self collectSingularAudioSetting];
        }
        
    } else if ([self.audioMode isEqualToString: @"plural"]) {
        self.eachPageSelectionView.backgroundColor = [UIColor thirdMain];
    }
    
    [self.collectionView reloadData];
}
- (void)setMusicReferByType:(int)type {
    
    self.audioType = type;
    switch (type) {
        case 1:
            //                    self.noMusicView.backgroundColor = [UIColor thirdMain];
            self.noMusicSelectionView.backgroundColor = [UIColor thirdMain];
            self.eachPageSelectionView.backgroundColor = [UIColor clearColor];
            self.bgMusicSelectionView.backgroundColor = [UIColor clearColor];
            [self switchToUploadMusic: NO];
            self.audioMode = @"none";
            if (self.avPlayer)
                [self.avPlayer pause];
            
            break;
        case 2:
            //                    self.eachPageMusicView.backgroundColor = [UIColor thirdMain];
            
            self.noMusicSelectionView.backgroundColor = [UIColor clearColor];
            self.eachPageSelectionView.backgroundColor = [UIColor thirdMain];
            self.bgMusicSelectionView.backgroundColor = [UIColor clearColor];
            [self switchToUploadMusic: NO];
            
            self.audioMode = @"plural";
            if (self.avPlayer)
                [self.avPlayer pause];
            
            break;
        case 3:
            //                    self.bgMusicView.backgroundColor = [UIColor thirdMain];
            
            self.noMusicSelectionView.backgroundColor = [UIColor clearColor];
            self.eachPageSelectionView.backgroundColor = [UIColor clearColor];
            self.bgMusicSelectionView.backgroundColor = [UIColor thirdMain];
            [self switchToUploadMusic: NO];
            
            self.audioMode = @"singular";
            
            break;
        case 4:
            [self switchToUploadMusic:YES];
            break;
        default:
            break;
    }
}
//#pragma mark - Touches Methods
//- (void)touchesBegan:(NSSet<UITouch *> *)touches
//           withEvent:(UIEvent *)event {
//    NSLog(@"touchesBegan");
//    CGPoint location = [[touches anyObject] locationInView: self.view];
//    CGRect fingerRect = CGRectMake(location.x - 5, location.y - 5, 10, 10);
//    
//    for (UIView *view in self.view.subviews) {
//        CGRect subviewFrame = view.frame;
//        
//        if (CGRectIntersectsRect(fingerRect, subviewFrame)) {
//            NSLog(@"finally touched view: %@", view);
//            NSLog(@"view.tag: %ld", (long)view.tag);
//            
//        }
//    }
//}
//
//- (void)touchesMoved:(NSSet<UITouch *> *)touches
//           withEvent:(UIEvent *)event {
//    NSLog(@"touchesMoved");
//    
//    CGPoint location = [[touches anyObject] locationInView: self.view];
//    CGRect fingerRect = CGRectMake(location.x - 5, location.y - 5, 10, 10);
//    
//    for (UIView *view in self.view.subviews) {
//        CGRect subviewFrame = view.frame;
//        
//        if (CGRectIntersectsRect(fingerRect, subviewFrame)) {
//            NSLog(@"finally touched view: %@", view);
//            NSLog(@"view.tag: %ld", (long)view.tag);
//        }
//    }
//}
//
//- (void)touchesEnded:(NSSet<UITouch *> *)touches
//           withEvent:(UIEvent *)event {
//    NSLog(@"touchesEnded");
//    
//    CGPoint location = [[touches anyObject] locationInView: self.view];
//    CGRect fingerRect = CGRectMake(location.x - 5, location.y - 5, 10, 10);
//    
//    for (UIView *view in self.view.subviews) {
//        CGRect subviewFrame = view.frame;
//        
//        if (CGRectIntersectsRect(fingerRect, subviewFrame)) {
//            NSLog(@"finally touched view: %@", view);
//            NSLog(@"view.tag: %ld", (long)view.tag);
//            //self.audioType = None;
//            switch (view.tag) {
//                case 1:
//                    self.noMusicView.backgroundColor = [UIColor clearColor];
//                    break;
//                case 2:
//                    self.eachPageMusicView.backgroundColor = [UIColor clearColor];
//                    break;
//                case 3:
//                    self.bgMusicView.backgroundColor = [UIColor clearColor];
//                    break;
//                case 4:
//                    self.audioBrowserView.backgroundColor = [UIColor clearColor];
//                default:
//                    break;
//            }
//        }
//    }
//}
//
//- (void)touchesCancelled:(NSSet<UITouch *> *)touches
//               withEvent:(UIEvent *)event {
//    NSLog(@"touchesCancelled");
//    
//    CGPoint location = [[touches anyObject] locationInView: self.view];
//    CGRect fingerRect = CGRectMake(location.x - 5, location.y - 5, 10, 10);
//    
//    for (UIView *view in self.view.subviews) {
//        CGRect subviewFrame = view.frame;
//        
//        if (CGRectIntersectsRect(fingerRect, subviewFrame)) {
//            NSLog(@"finally touched view: %@", view);
//            NSLog(@"view.tag: %ld", (long)view.tag);
//        }
//    }
//}

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    NSLog(@"musicArray.count: %lu", (unsigned long)musicArray.count);
    return musicArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"");
    NSLog(@"");
    NSLog(@"cellForItemAtIndexPath");
    
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: identifier forIndexPath: indexPath];
    cell.layer.cornerRadius = 8;
    
    UILabel *textLabel = (UILabel *)[cell viewWithTag: 100];
    
    if ([wTools objectExists: musicArray[indexPath.row][@"name"]]) {
        textLabel.text = musicArray[indexPath.row][@"name"];
        [LabelAttributeStyle changeGapStringAndLineSpacingLeftAlignment: textLabel content: textLabel.text];
    }
    
    if ([musicArray[indexPath.row][@"selected"] boolValue]) {
        cell.layer.backgroundColor = [UIColor thirdMain].CGColor;
    } else {
        cell.layer.backgroundColor = [UIColor thirdGrey].CGColor;
    }        
    return cell;
}

#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectItemAtIndexPath");
    self.audioType = Singular;
    // Switch to Singluar Mode
    self.noMusicSelectionView.backgroundColor = [UIColor clearColor];
    self.eachPageSelectionView.backgroundColor = [UIColor clearColor];
    self.bgMusicSelectionView.backgroundColor = [UIColor thirdMain];
    
    self.audioMode = @"singular";
    [self switchToUploadMusic:NO];
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath: indexPath];
    cell.layer.backgroundColor = [UIColor thirdMain].CGColor;
    //self.selectedIndexPath = indexPath;
    
    NSLog(@"mdata: %@", mdata);
    NSArray *arr = mdata[@"audio"];
    NSString *strUrl = arr[indexPath.row][@"url"];
    NSLog(@"strUrl: %@", strUrl);
    
    if (![wTools  objectExists: strUrl]) {
        return;
    }
    
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
    
    if (![wTools objectExists: musicArray]) {
        return;
    }
    
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

- (void)collectionView:(UICollectionView *)collectionView
didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didDeselectItemAtIndexPath");
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath: indexPath];
    cell.layer.cornerRadius = 8;
    cell.layer.backgroundColor = [UIColor thirdGrey].CGColor;
}

#pragma mark - AVPlayer Section
- (void)avPlayerSetUp: (NSString *)audioData {
    NSLog(@"avPlayerSetUp");
    //註冊audioInterrupted
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver: self selector: @selector(audioInterrupted:) name: AVAudioSessionInterruptionNotification object: nil];
    
    // 1. Set Up URL Audio Source
    NSURL *audioUrl = [NSURL URLWithString: audioData];
    if (audioUrl == nil)
        audioUrl = [NSURL fileURLWithPath:audioData];
    
    if (audioUrl == nil) {
        [self showCustomErrorAlert:@"檔案位置有誤，無法播放"];
        
    } else {
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
}

#pragma mark Prepare to play asset, URL
/*
 Invoked at the completion of the loading of the values for all keys on the asset that we require.
 Checks whether loading was successfull and whether the asset is playable.
 If so, sets up an AVPlayerItem and an AVPlayer to play the asset.
 */

- (void)prepareToPlayAsset:(AVURLAsset *)asset
                  withKeys:(NSArray *)requestedKeys {
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
    
//    if (self.avPlayerItem) {
//        NSLog(@"self.avPlayerItem Existed");
//        NSLog(@"self.avPlayerItem removeObserver: self forKeyPath: status");
//        @try {
//            [self.avPlayerItem removeObserver: self
//                                   forKeyPath: @"status"];
//        } @catch (NSException *exception) {
//            // Print exception information
//            NSLog( @"NSException caught" );
//            NSLog( @"Name: %@", exception.name);
//            NSLog( @"Reason: %@", exception.reason );
//            return;
//        }
//
//        /*
//        NSLog(@"NSNotificationCenter removeObserver");
//        [[NSNotificationCenter defaultCenter] removeObserver: self
//                                                        name: AVPlayerItemDidPlayToEndTimeNotification
//                                                      object: self.avPlayerItem];
//         */
//    }
    
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
        [self.avPlayer pause];
        [self.avPlayer replaceCurrentItemWithPlayerItem:self.avPlayerItem];
        
    } else {
        NSLog(@"self.avPlayer = [AVPlayer playerWithPlayerItem: self.avPlayerItem]");
        self.avPlayer = [AVPlayer playerWithPlayerItem: self.avPlayerItem];
        [self.avPlayer addObserver:self forKeyPath:@"timeControlStatus" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
    }
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
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"");
    NSLog(@"observeValueForKeyPath");
    
    NSLog(@"object: %@", object);
    if ([keyPath isEqualToString:@"timeControlStatus"]) {
        if (self.avPlayer)
            [self.playerBtn setSelected:(self.avPlayer.rate == 1.0)];
    } else if (context == AVPlayerDemoPlaybackViewControllerStatusObservationContext) {
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
                        if (self.audioType != Singular2)
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

-(void)assetFailedToPrepareForPlayback:(NSError *)error {
    NSLog(@"");
    NSLog(@"assetFailedToPrepareForPlayback");
}

#pragma mark - IBAction Methods

- (void)removeObserverForAVPlayerItem {
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
        [self.delegate dismissFromSetupMusicVC: self audioModeChanged: NO];
    }
    //[self dismissViewControllerAnimated: YES completion: nil];
    [self  removeObserverForAVPlayerItem];
    [self.avPlayer removeObserver:self forKeyPath:@"timeControlStatus"];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav dismissViewControllerAnimated: YES completion: nil];
}

- (IBAction)saveBtnPress:(id)sender {
    NSLog(@"");
    NSLog(@"");
    NSLog(@"saveBtnPress");
    
    //NSLog(@"tempAudioMode: %@", oldAudioMode);
    NSLog(@"self.audioMode: %@", self.audioMode);
    
    //if ([self.audioMode isEqualToString: oldAudioMode]) {
    if (self.dataAudioType == self.audioType) {
    if (self.audioType > Plural) {
        //if ([self.audioMode isEqualToString: @"singular"]) {
            BOOL hasBgMusic = NO;
            
            NSLog(@"musicArray: %@", musicArray);
            
            for (NSDictionary *d in musicArray) {
                if ([d[@"selected"] boolValue]) {
                    hasBgMusic = YES;
                }
            }
            
            NSLog(@"hasBgMusic: %d", hasBgMusic);
            
            if (hasBgMusic || (self.audioUploader && [self.audioUploader isReady])) {
                [self changeAudioMode];
            } else {
                //[self dismissViewControllerAnimated: YES completion: nil];
                [self  removeObserverForAVPlayerItem];
                [self.avPlayer removeObserver:self forKeyPath:@"timeControlStatus"];
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [appDelegate.myNav dismissViewControllerAnimated: YES completion: nil];
            }
        } else {
            //[self dismissViewControllerAnimated: YES completion: nil];
            [self  removeObserverForAVPlayerItem];
            [self.avPlayer removeObserver:self forKeyPath:@"timeControlStatus"];
            
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate.myNav dismissViewControllerAnimated: YES completion: nil];
        }
    } else {
        [self showCustomAlert: @"切換播放模式之後會將先前音效設定移除，確定要進行切換嗎?"];
    }
}

#pragma mark - Custom Alert Method
- (void)showCustomAlert: (NSString *)msg {
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

- (void)changeAudioMode {
    NSLog(@"");
    NSLog(@"");
    NSLog(@"changeAudioMode");
    
    NSMutableDictionary *settingsDic = [NSMutableDictionary new];
    NSLog(@"self.audioMode: %@", self.audioMode);
    
    
    switch (self.audioType) {
        case None:
            [settingsDic setObject: @"none" forKey: @"audio_mode"];
            break;
        case Plural:
            [settingsDic setObject: @"plural" forKey: @"audio_mode"];
            break;
        case Singular: {
            [settingsDic setObject: @"singular" forKey: @"audio_mode"];
            // And music has selected
            for (NSDictionary *d in musicArray) {
                if ([d[@"selected"] boolValue]) {
                    NSLog(@"%@", d[@"id"]);
                    [settingsDic setObject:@"system" forKey:@"audio_refer"];
                    [settingsDic setObject: d[@"id"] forKey: @"audio_target"];
                    break;
                }
            }
            
            if (![settingsDic objectForKey:@"audio_refer"]) {
//                [settingsDic setObject:@"none" forKey:@"audio_refer"];
//                [settingsDic setObject:@"0" forKey: @"audio_target"];
                [self showCustomErrorAlert:@"尚未選定音樂"];
                return;
            }
        }
            break;
        case Singular2: {
            [settingsDic setObject: @"singular" forKey: @"audio_mode"];
            [settingsDic setObject:@"file" forKey:@"audio_refer"];
            //[settingsDic setObject:self.audioUploader? self.audioUploader.audioName:@"" forKey:@"audio_target"];
        }
            break;
    }
    
    if (self.audioType < Singular2) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject: settingsDic
                                                           options: 0
                                                             error: nil];
        NSString *jsonStr = [[NSString alloc] initWithData: jsonData
                                                  encoding: NSUTF8StringEncoding];
        NSLog(@"jsonStr: %@", jsonStr);
        
        [self callAlbumSettings: jsonStr];
    } else {
        [self updateMusicSettingsWithAudioUploader:settingsDic];
        
    }
}

- (void)processCallAlbumSettings:(NSDictionary *)dic {
    //if ([dic[@"result"]boolValue]) {
    if ([dic[@"result"] isEqualToString: @"SYSTEM_OK"]) {
    
        if (self.audioType == self.dataAudioType) {//[self.audioMode isEqualToString: oldAudioMode]) {
            isAudioModeChanged = NO;
        } else {
            isAudioModeChanged = YES;
        }
        
        NSLog(@"isAudioModeChanged: %d", isAudioModeChanged);
        
        if ([self.delegate respondsToSelector: @selector(dismissFromSetupMusicVC:audioModeChanged:)]) {
            [self.delegate dismissFromSetupMusicVC: self audioModeChanged: isAudioModeChanged];
        }
        [self  removeObserverForAVPlayerItem];
        [self.avPlayer removeObserver:self forKeyPath:@"timeControlStatus"];
        //[self dismissViewControllerAnimated: YES completion: nil];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.myNav dismissViewControllerAnimated: YES completion: nil];
        
    } else if ([dic[@"result"] isEqualToString: @"SYSTEM_ERROR"]) {
        NSLog(@"失敗： %@", dic[@"message"]);
        if ([wTools objectExists: dic[@"message"]]) {
            [self showCustomErrorAlert: dic[@"message"]];
        } else {
            [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
        }
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

//  upload audio file and updating album settings by audioUploader
- (void)updateMusicSettingsWithAudioUploader:(NSDictionary *)settingDict {
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: settingDict
                                                       options: 0
                                                         error: nil];
    NSString *jsonStr = [[NSString alloc] initWithData: jsonData
                                              encoding: NSUTF8StringEncoding];
    
    NSMutableDictionary *param = [NSMutableDictionary new];
    [param setObject:[wTools getUserID] forKey:@"user_id"];
    [param setObject:[wTools getUserToken] forKey:@"token"];
    [param setObject:self.albumId forKey:@"album_id"];
    [param setObject:jsonStr forKey:@"settings"];
    isAudioModeChanged = YES;
    
    if ([self.audioUploader isReady]) {
        __block typeof(self) wself = self;
        self.uploadProgress =  [MBProgressHUD showHUDAddedTo: self.view animated: YES];
        self.uploadProgress.mode =  MBProgressHUDModeDeterminateHorizontalBar;
        self.uploadProgress.label.text = @"音樂上傳中";
        [self.audioUploader startUpload:param path:@"/updatealbumsettings/2.0" uploadblock:^(NSUInteger currentUploaded, NSUInteger totalSize, NSString * _Nonnull desc) {
            dispatch_async(dispatch_get_main_queue(), ^{
                wself.uploadProgress.progress = (float)currentUploaded/(float)totalSize;
            });
        } uploadResultBlock:^(NSDictionary * _Nullable result,  NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [wself.avPlayer pause];
                [wself.uploadProgress hideAnimated:YES];
                
                if ([wself.delegate respondsToSelector: @selector(dismissFromSetupMusicVC:audioModeChanged:)]) {
                    [wself.delegate dismissFromSetupMusicVC: wself audioModeChanged: wself->isAudioModeChanged];
                    
                }
                //[wself  removeObserverForAVPlayerItem];
                //[wself.avPlayer removeObserver:wself forKeyPath:@"timeControlStatus"];
                
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [appDelegate.myNav dismissViewControllerAnimated: YES completion: nil];
                //[wself dismissViewControllerAnimated: YES completion: nil];
            });
            
        }];
    }
}

- (void)callAlbumSettings: (NSString *)jsonStr {
    NSLog(@"callAlbumSettings");
    @try {
        [DGHUDView start];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI albumsettings: [wTools getUserID]
                                            token: [wTools getUserToken]
                                         album_id: wself.albumId
                                         settings: jsonStr];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [DGHUDView stop];
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
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"updatealbumsettings"
                                         jsonStr: jsonStr];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];

                    if (dic)
                        [wself processCallAlbumSettings:dic];
                    else
                        [wself showCustomErrorAlert:response?response:@"請稍後再試"];
                    
                }
            }
        });
    });
}

- (void)logOut {
    [wTools logOut];
}

#pragma mark - Custom Alert Method
- (void)showCustomErrorAlert: (NSString *)msg {
    [UIViewController showCustomErrorAlertWithMessage:msg onButtonTouchUpBlock:^(CustomIOSAlertView *customAlertView, int buttonIndex) {        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[customAlertView tag]);
        [customAlertView close];

    }];
    
}

#pragma mark - Custom Method for TimeOut
- (void)showCustomTimeOutAlert: (NSString *)msg
                  protocolName: (NSString *)protocolName
                       jsonStr: (NSString *)jsonStr {
    CustomIOSAlertView *alertTimeOutView = [[CustomIOSAlertView alloc] init];
    [alertTimeOutView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
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
            } else if ([protocolName isEqualToString: @"updatealbumsettings"]) {
                [weakSelf callAlbumSettings: jsonStr];
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
#pragma mark - Audio upload section
- (void)loadSingular2Settings {
    
    self.audioUploadedView.hidden = NO;
    if (@available(iOS 11.0, *))
        self.uploadBtn.enabled = YES;
    else
        self.uploadBtn.enabled = NO;
    
    NSString *path = self.data[@"audio_target"];
    if (path && [path isKindOfClass:[NSString class]]) {
        //self.audioUploader = [[AudioUploader alloc] initWithAudio:[NSURL URLWithString:path]  albumID:self.albumId];
        self.uploadAudioFileName.text = [NSString stringWithFormat:@"%@", [path lastPathComponent]];
        [self switchToUploadMusic:YES];
        [self avPlayerSetUp:path];
    }
}
- (BOOL)ifReadyForUpload {
    return (self.audioUploader && [self.audioUploader isReady]);
    
}
- (void)switchToUploadMusic:(BOOL)on {
    
    if (!on) {
        self.uploadMusicSelectionView.backgroundColor = [UIColor clearColor];
        self.audioUploadedView.hidden = YES;
        self.uploadAudioFileName.text = @"點擊保存後開始上傳";
        if (self.audioUploader) {
            [self.avPlayer pause];
            [self.audioUploader cacenlCurrentWork];
            self.audioUploader = nil;
        }
    } else {
        self.audioType = Singular2;
        self.noMusicSelectionView.backgroundColor = [UIColor clearColor];
        self.eachPageSelectionView.backgroundColor = [UIColor clearColor];
        self.bgMusicSelectionView.backgroundColor = [UIColor clearColor];
        self.uploadMusicSelectionView.backgroundColor = [UIColor thirdMain];
        self.audioUploadedView.hidden = NO;
        self.audioMode = @"singular";
    }
}
- (IBAction)openFileBrowser:(id)sender {
    if (@available(iOS 11.0, *)) {
        
        UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes: @[(__bridge NSString * )kUTTypeMP3,(__bridge NSString * )kUTTypeWaveformAudio,(__bridge NSString * )kUTTypeMPEG4, (__bridge NSString *)kUTTypeMPEG4Audio] inMode:UIDocumentPickerModeImport];
        
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }
}
- (IBAction)playPause:(id)sender {
    BOOL s = self.playerBtn.isSelected;
    self.playerBtn.selected = !s;
    if (self.playerBtn.selected)
        [self.avPlayer play];
    else
        [self.avPlayer pause];
        
}
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray <NSURL *>*)urls {
    
    if (self.avPlayer)
        [self.avPlayer pause];
    
    if (self.audioUploader) {
        [self.audioUploader cacenlCurrentWork];
        self.audioUploader = nil;
    }
    
    self.audioUploadedView.hidden = NO;
    self.audioUploader = [[AudioUploader alloc] initWithAudio:[urls firstObject]  albumID:self.albumId];
    NSString *path = [[urls firstObject] path];
    self.uploadAudioFileName.text = [NSString stringWithFormat:@"%@ (點擊保存後開始上傳)", [path lastPathComponent]];
    [self switchToUploadMusic:YES];
    [self avPlayerSetUp:path];
    

}
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    
}

@end

