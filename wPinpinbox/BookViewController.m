//
//  BookViewController.m
//  wPinpinbox
//
//  Created by Angus on 2015/11/6.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "BookViewController.h"
#import "UICustomLineLabel.h"
#import "MyScrollView.h"
#import "wTools.h"
#import "YoutubeViewController.h"
#import "VideoViewController.h"
#import "PagetextViewController.h"
#import "PageNavigationController.h"
#import "CalbumlistViewController.h"
#import "RetrievealbumpViewController.h"
#import "AppDelegate.h"
#import "OfflineViewController.h"
#import "boxAPI.h"
#import "OpenUDID.h"

#import "Remind.h"

#import "CustomIOSAlertView.h"
#import <SafariServices/SafariServices.h>
#import "MZUtility.h"
#import "EventPostViewController.h"

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

#import "PreviewbookViewController.h"
#import "CurrencyViewController.h"

#import "PageCollectionViewController.h"

#import "MyTabBarController.h"

#import <CoreData/CoreData.h>

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import "YTVimeoExtractor.h"
#import "MBProgressHUD.h"
#import "UIColor+Extensions.h"

typedef void (^FBBlock)(void);typedef void (^FBBlock)(void);

@interface BookViewController () <MyScrollViewDataSource1, UIScrollViewDelegate, SFSafariViewControllerDelegate, UITextViewDelegate>
{
    __weak IBOutlet UICustomLineLabel *mytitle;
    __weak IBOutlet UIView *showview;
    
    MyScrollView *mySV;
    NSArray *datalist;
    NSString *file;
    
    AVAudioPlayer *audioPlayer;
    AVAudioPlayer *PageaudioPlayer;
    NSDictionary *bookdata;
    BOOL isfile;
    
    NSMutableArray *audiobool;
    
    BOOL isplayaudio;
    BOOL playWholeAlbum;
    NSString *audioMode;
    
    UIButton *tmpbtn;
    UIView *tmpview;
    
    NSDictionary *locdata;
    
    // For Slot
    //NSString *giftImage;
    //NSString *giftName;
    //NSString *photoUseForUserId;
    
    UIView *giftView;
    UIButton *exchangeButton;
    UILabel *exchangeLabel;
    UIImageView *exchangeGiftImageView;
    UILabel *giftLabel;
    UILabel *noticeLabel;
    UIButton *yesButton;
    UIButton *noButton;
    UIButton *exchangeCheckButton;
    
    NSTimer *timer;
    int timeTick;
    UILabel *timeLabel;
    
    // For Exchange
    NSString *giftImage1;
    NSString *giftName1;
    NSString *photoUseForUserId1;
    
    UIView *giftView1;
    UIButton *exchangeButton1;
    UILabel *exchangeLabel1;
    UIImageView *exchangeGiftImageView1;
    UILabel *giftLabel1;
    UILabel *noticeLabel1;
    UIButton *yesButton1;
    UIButton *noButton1;
    UIButton *exchangeCheckButton1;
    
    NSTimer *timer1;
    int timeTick1;
    UILabel *timeLabel1;
    
    
    // For Showing Message of Getting Point
    NSString *missionTopicStr;
    NSString *rewardType;
    NSString *rewardValue;
    NSString *eventUrl;
    
    CustomIOSAlertView *alertView;
    CustomIOSAlertView *alertViewForExchange;
    
    NSString *task_for;
    
    // For Photo Caption
    UITextView *myText;
    
    NSString *fileNameForDeletion;
    
    // For checking scrolling right or left
    CGFloat lastContentOffset;
}
@property (strong) NSMutableArray *browseArray;
@property (strong, nonatomic) AVPlayer *avPlayer;
@property (assign, nonatomic) BOOL isReadyToPlay;

@end

@implementation BookViewController

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    
    if ([delegate performSelector: @selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)checkBrowseDataReachMax
{
    // Fetch the data from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName: @"Browse"];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey: @"browseDate" ascending: NO];
    [fetchRequest setSortDescriptors: @[sortDescriptor]];
    
    self.browseArray = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    if (self.browseArray.count >= 20) {
        NSLog(@"browseArray.count is more than 20, so need to be removed the last object");
        [managedObjectContext deleteObject: [self.browseArray lastObject]];
    }
}

- (void)saveBrowseData: (NSDictionary *)bookData
{
    NSLog(@"albumId: %@", self.albumid);
    NSLog(@"author: %@", bookdata[@"author"]);
    NSLog(@"description: %@", bookdata[@"description"]);
    NSLog(@"title: %@", bookdata[@"title"]);
    
    NSString *imageFolderName = [NSString stringWithFormat: @"%@%@", [wTools getUserID], self.albumid];
    NSLog(@"imageFolderName: %@", imageFolderName);
    
    // Save data to Core Data
    NSManagedObjectContext *context = [self managedObjectContext];
    NSManagedObject *newData = [NSEntityDescription insertNewObjectForEntityForName: @"Browse" inManagedObjectContext: context];
    [newData setValue: self.albumid forKey: @"albumId"];
    [newData setValue: bookdata[@"author"] forKey: @"author"];
    [newData setValue: bookdata[@"description"] forKey: @"descriptionInfo"];
    [newData setValue: bookdata[@"title"] forKey: @"title"];
    [newData setValue: imageFolderName forKey: @"imageFolderName"];
    [newData setValue: [NSDate date] forKey: @"browseDate"];
    
    NSError *error = nil;
    
    // Save the object to persistent store
    if (![context save: &error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    } else {
        NSLog(@"Saving Data Success");
    }
}

- (void)setupForDicFile: (NSDictionary *)dic
{
    NSLog(@"setupForDicFile");
    
    bookdata = dic;
    //NSLog(@"dic: %@", dic);
    NSLog(@"bookdata: %@", bookdata);
    
    [self checkBrowseDataReachMax];
    [self saveBrowseData: bookdata];
    
    datalist = dic[@"photo"];
    NSLog(@"datalist: %@", datalist);
    
    audioMode = dic[@"audio_mode"];
    NSLog(@"audioMode: %@", audioMode);
    
    mytitle.text = dic[@"title"];
    
    
    // NavigationBar Text Setup
    self.title = dic[@"title"];
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:18 weight:UIFontWeightLight], NSForegroundColorAttributeName: [UIColor whiteColor]};
    //self.navigationController.navigationBar.barTintColor = [UIColor clearColor];    
    //self.navigationController.navigationBar.translucent = YES;    
    
    CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
    
    //判斷3.5吋或4吋螢幕以載入不同storyboard
    if (iOSDeviceScreenSize.height == 480)
    {
        showview.frame=CGRectMake(showview.frame.origin.x, showview.frame.origin.y, showview.frame.size.width, 392);
    }
    
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(viewSignleTapped:)];
    [showview addGestureRecognizer: singleTapGesture];
    
    
    myText = [[UITextView alloc] init];
    myText.font = [UIFont fontWithName: @"TrebuchetMS-Bold" size: 15.0f];
    myText.textColor = [UIColor whiteColor];
    myText.backgroundColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.5];
    
    myText.frame = CGRectMake(0, 300, showview.bounds.size.width, showview.bounds.size.height);
    //[myText.text drawInRect: myText.frame withFont: myText.font];
    [myText.text drawInRect:myText.frame withAttributes:@{}];
    myText.editable = NO;
    myText.textAlignment = NSTextAlignmentCenter;
    
    
    mySV=[[MyScrollView alloc]initWithFrame:CGRectMake(0, 0, showview.bounds.size.width, showview.bounds.size.height)];
    mySV.dataSourceDelegate=self;
    mySV.pagingEnabled=YES;
    [mySV initWithDelegate:self atPage:0];
    mySV.alwaysBounceHorizontal = YES;
    
    [showview addSubview: mySV];
    // myText is on top of mySV, so need to add later
    [showview addSubview: myText];
    
    if (datalist.count!=0) {
        NSString *usefor=datalist[0][@"usefor"];
        typelabel.text=usefor;
        NSLog(@"typelabel.text: %@", typelabel.text);
    } else {
        typelabel.text=@"";
    }
    
    //設定音樂開關
    for (int i=0; i<bookdata.count; i++) {
        [audiobool addObject:@"1"];
    }
    NSString *location=bookdata[@"location"];
    
    if (![location isEqualToString:@""]) {
        //[wTools ShowMBProgressHUD];
        [MBProgressHUD showHUDAddedTo: self.view animated: YES];
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            
            NSString *respone=[boxAPI api_GET:[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=false",location ] ];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //[wTools HideMBProgressHUD];
                [MBProgressHUD hideHUDForView: self.view animated: YES];
                
                if (respone!=nil) {
                    //NSLog(@"%@",respone);
                    NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    locdata=[dic mutableCopy];
                }
            });
        });
    }
}

#pragma mark -
#pragma mark View Related Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"BookViewController");
    NSLog(@"albumId: %@", _albumid);
    NSLog(@"viewDidLoad");
    
    NSLog(@"fromEventPostVC: %d", self.fromEventPostVC);
    
    // Resize UIImage for LeftBarButtonItem
    UIImage *originalImage = [UIImage imageNamed: @"icon_back_white_120x120.png"];
    CGSize destinationSize = CGSizeMake(60, 60);
    UIGraphicsBeginImageContext(destinationSize);
    [originalImage drawInRect: CGRectMake(0, 0, destinationSize.width, destinationSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
        
    // LeftBarButtonItem Setup
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage: newImage style: UIBarButtonItemStylePlain target: self action: @selector(back:)];
    backButton.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = backButton;
    
    
    //[wTools HideMBProgressHUD];
    [MBProgressHUD hideHUDForView: self.view animated: YES];
    
    locdata = nil;
    
    // Default Setting for Audio
    // Audio Switch should be set to Off
    _audioSwitch = YES;
    isplayaudio = NO;
    _fromPageText = NO;
    
    
    isfile = NO;

    file = [NSString stringWithFormat:@"%@",_DirectoryPath];
    
    NSLog(@"file: %@", file);
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *infoPath = [file stringByAppendingPathComponent:@"info.txt"];
    
    if ([fm fileExistsAtPath: infoPath]) {
        NSLog(@"fileExistsAtPath");
        
        isfile = YES;
        
        NSString *str = [NSString stringWithContentsOfFile:infoPath encoding:NSUTF8StringEncoding error:nil];
        NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        
        [self setupForDicFile: dic];
    } else if (![_dic isKindOfClass: [NSNull class]]) {
        NSLog(@"file does not exist at path");
        [self setupForDicFile: _dic];
    } else {
        NSLog(@"沒有檔案");
    }
    
    // Do any additional setup after loading the view from its nib.
    
    [self checkPointForActivity];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"");
    NSLog(@"viewWillAppear");
    
    [super viewWillAppear:animated];
    
    for (id controller in self.navigationController.viewControllers) {
        NSLog(@"controller: %@", controller);
    }
    
    // NavigationBar Setup
    //self.navigationController.navigationBar.hidden = YES;
    
    //[[UIApplication sharedApplication] setStatusBarHidden: YES];
    
    // Back to BookViewController, so that means videoPlay is finished
    
    if (_videoPlay) {
        _videoPlay = NO;
    }
    
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
    //[[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
    
    [self changeAudioButtonImage];
    
    NSLog(@"");
    NSLog(@"audioMode: %@", audioMode);
    
    // For playing audio File
    NSString *audioPath;
    
    // For checking audio file whether exists or not
    NSString *audioStr;
    
    NSURL *audioURL;
    
    NSLog(@"");
    NSLog(@"Check File Exists or not");
    NSLog(@"");
    
    if (isfile) {
        NSLog(@"isfile: %d", isfile);
        if (![audioMode isEqualToString: @"none"]) {
            if ([audioMode isEqualToString: @"singular"]) {
                NSLog(@"audioMode isEqualToString singular");
                
                audioStr = bookdata[@"audio_target"];
                NSLog(@"audioStr: %@", audioStr);
                
                NSString *httpStr = @"http";
                
                if (![audioStr isKindOfClass: [NSNull class]]) {
                    if (![audioStr isEqualToString: @""]) {
                        if ([audioStr rangeOfString: httpStr].location == NSNotFound) {
                            NSLog(@"audioStr does not contain http");
                            audioPath = [file stringByAppendingPathComponent: @"bgm.mp3"];
                            audioURL = [NSURL fileURLWithPath: audioPath];
                        } else {
                            NSLog(@"audioStr contains http");
                            audioURL = [NSURL URLWithString: audioStr];
                        }
                        
                        playWholeAlbum = YES;
                    }
                } else {
                    NSLog(@"audioStr is null");
                }
            } else if ([audioMode isEqualToString: @"plural"]) {
                NSLog(@"audioMode isEqualToString plural");
                
                // Get the page value for playing the audio accordingly
                int page = mySV.contentOffset.x / mySV.frame.size.width;
                NSLog(@"page: %d", page);
                
                audioStr = datalist[page][@"audio_target"];
                NSLog(@"audioStr: %@", audioStr);
                
                NSString *httpStr = @"http";
                
                if (![audioStr isKindOfClass: [NSNull class]]) {
                    if (![audioStr isEqualToString: @""]) {
                        if ([audioStr rangeOfString: httpStr].location == NSNotFound) {
                            NSLog(@"audioStr does not contain http");
                            audioPath = [file stringByAppendingPathComponent: [NSString stringWithFormat: @"%d.mp3", page]];
                            audioURL = [NSURL fileURLWithPath: audioPath];
                        } else {
                            NSLog(@"audioStr contains http");
                            audioURL = [NSURL URLWithString: audioStr];
                        }
                        
                        playWholeAlbum = NO;
                    }
                } else {
                    NSLog(@"audioStr is null");
                }
            }
            
            NSLog(@"audioStr: %@", audioStr);
            NSLog(@"audioPath: %@", audioPath);
            NSLog(@"audioURL: %@", audioURL);
            
            if (![audioStr isKindOfClass: [NSNull class]]) {
                if (![audioStr isEqualToString: @""]) {
                    if (self.avPlayer == nil) {
                        NSLog(@"self.avPlayer is nil, needs to be initialized");
                        
                        NSFileManager *fm = [NSFileManager defaultManager];
                        
                        if ([fm fileExistsAtPath: audioPath]) {
                            NSLog(@"FileManager file exists at path audioPath: %@", audioPath);
                            [self avPlayerSetUp: audioURL];
                            
                            if (self.avPlayer != nil) {
                                NSLog(@"self.avPlayer was initialized already");
                                
                                if (self.isReadyToPlay) {
                                    NSLog(@"avPlayer isReadyToPlay");
                                    
                                    if (isplayaudio) {
                                        NSLog(@"isPlayAudio is switched On");
                                        [self.avPlayer play];
                                    }
                                }
                            }
                            
                            /*
                            NSData *fileData = [NSData dataWithContentsOfFile: audioPath];
                            [self avAudioPlayerSetUp: fileData];
                            
                            if (audioPlayer != nil) {
                                NSLog(@"audioPlayer was initialized already");
                                if ([audioPlayer prepareToPlay]) {
                                    NSLog(@"audioPlayer prepareToPlay");
                                    if (isplayaudio) {
                                        NSLog(@"isPlayAudio is switched On");
                                        [audioPlayer play];
                                    }
                                }
                            }
                             */
                        } else {
                            NSLog(@"FileManager file does not exist");
                            [self avPlayerSetUp: audioURL];
                            
                            if (self.avPlayer != nil) {
                                NSLog(@"self.avPlayer was initialized already");
                                
                                if (self.isReadyToPlay) {
                                    NSLog(@"avPlayer isReadyToPlay");
                                    
                                    if (isplayaudio) {
                                        NSLog(@"isPlayAudio is switched On");
                                        [self.avPlayer play];
                                    }
                                }
                            }
                        }
                    } else {
                        NSLog(@"avPlayer is initialized");
                        
                        if (self.isReadyToPlay) {
                            if (isplayaudio) {
                                [self.avPlayer play];
                            }
                        }
                        /*
                        if ([audioPlayer prepareToPlay]) {
                            if (isplayaudio) {
                                [audioPlayer play];
                            }
                        }
                         */
                    }
                }
            }
        }
    }
    
    /*
    if (isfile) {
        NSLog(@"file exists");
        
        NSLog(@"Check audioMode");
        
        if ([audioMode isEqualToString: @"singular"]) {
            audioStr = bookdata[@"album"][@"audio_target"];
            audioPath = [file stringByAppendingPathComponent: @"bgm.mp3"];
            playWholeAlbum = YES;
            
        } else if ([audioMode isEqualToString: @"plural"]) {
            int page = mySV.contentOffset.x / mySV.frame.size.width;
            NSLog(@"page: %d", page);
            
            audioStr = datalist[page][@"audio_target"];
            
            audioPath = [file stringByAppendingPathComponent: [NSString stringWithFormat: @"%d.mp3", page]];
            playWholeAlbum = NO;
        }
        
        NSLog(@"audioPath: %@", audioPath);
        NSLog(@"audioStr: %@", audioStr);
        
        if (![audioStr isKindOfClass: [NSNull class]]) {
            if (![audioStr isEqualToString: @""]) {
                if (audioPlayer == nil) {
                    NSLog(@"audioPlayer is nil, needs to be initialized");
                    
                    NSFileManager *fm = [NSFileManager defaultManager];
                    
                    if ([fm fileExistsAtPath: audioPath]) {
                        
                        NSLog(@"bgm.mp3 file exsits");
                        
                        NSData *fileData = [NSData dataWithContentsOfFile: audioPath];
                        
                        [self avAudioPlayerSetUp: fileData];
                        
                        if (audioPlayer != nil) {
                            NSLog(@"audioPlayer was initialized already");
                            if ([audioPlayer prepareToPlay]) {
                                NSLog(@"audioPlayer prepareToPlay");
                                if (isplayaudio) {
                                    NSLog(@"isPlayAudio is switched On");
                                    [audioPlayer play];
                                }
                            }
                        }
                    }
                } else {
                    NSLog(@"audioPlayer is initialized");
                    if ([audioPlayer prepareToPlay]) {
                        if (isplayaudio) {
                            [audioPlayer play];
                        }
                    }
                }
            }
        }                
    }
     */
    
    [self playCheck: audioStr];
}

#pragma mark - AVPlayer Section
- (void)avPlayerSetUp: (NSURL *)audioUrl
{
    NSLog(@"avPlayerSetUp");
    
    //註冊audioInterrupted
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver: self selector: @selector(audioInterrupted:) name: AVAudioSessionInterruptionNotification object: nil];
    
    //self.avPlayer = [[AVPlayer alloc] initWithURL: audioUrl];
    //avPlayer = player;
    
    // 1. Set Up URL Audio Source
    //NSURL *audioUrl = [NSURL URLWithString: audioStr];
    
    // 2. PlayItem Setup
    //self.playerItem = [AVPlayerItem playerItemWithURL: audioUrl];
    // Setting AVAsset & AVPlayerItem this way can avoid crash
    AVAsset *asset = [AVURLAsset URLAssetWithURL: audioUrl options: nil];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset: asset];
    
    if (self.avPlayer != nil) {
        [self.avPlayer removeObserver: self forKeyPath: @"status"];
    }
    
    // 3. AVPlayer Setup
    self.avPlayer = [AVPlayer playerWithPlayerItem: playerItem];
    
    [self.avPlayer addObserver: self
                    forKeyPath: @"status"
                       options: 0
                       context: nil];
    
    BOOL isLoop;
    NSLog(@"audioMode: %@", audioMode);
    
    if ([audioMode isEqualToString: @"singular"]) {
        
        isLoop = [bookdata[@"audio_loop"] boolValue];
        NSLog(@"audioLoop: %d", isLoop);
        
        if (isLoop) {
            NSLog(@"Loop Audio");
            
            // The setting below is to loop audio
            self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
            [self addNotification];
        } else {
            NSLog(@"Don't Loop Audio");
            self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndPause;
        }
    } else if ([audioMode isEqualToString: @"plural"]) {
        int page = mySV.contentOffset.x / mySV.frame.size.width;
        NSLog(@"page: %d", page);
        
        isLoop = [datalist[page][@"audio_loop"] boolValue];
        NSLog(@"audioLoop: %d", isLoop);
        
        if (isLoop) {
            NSLog(@"Loop Audio");
            // The setting below is to loop audio
            self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
            [self addNotification];
        } else {
            NSLog(@"Don't Loop Audio");
            self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndPause;
        }
    }
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
                if (isplayaudio) {
                    [NSThread sleepForTimeInterval: 0.1];
                    [self.avPlayer play];
                }
            }
        }
    }
}

#pragma mark - NSNotification
- (void)addNotification
{
    NSLog(@"");
    NSLog(@"addNotification");
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(playerItemDidReachEnd:)
                                                 name: AVPlayerItemDidPlayToEndTimeNotification
                                               object: [self.avPlayer currentItem]];
}

- (void)removeNotification
{
    NSLog(@"");
    NSLog(@"removeNotification");
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

#pragma mark -

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    
    //  code here to play next audio file
    NSLog(@"");
    NSLog(@"playerItemDidReachEnd");
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        // The setting below is to loop audio
        NSLog(@"Seek To Time kCMTimeZero");
        AVPlayerItem *p = [notification object];
        [p seekToTime: kCMTimeZero];
    });
}

// From Apple API Reference
// Informs the observing object when the value at the specified key path
// relative to the observed object has changed
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    NSLog(@"");
    NSLog(@"observeValueForKeyPath");
    
    if (object == self.avPlayer && [keyPath isEqualToString: @"status"]) {
        // Get status value
        switch (self.avPlayer.status) {
            case AVPlayerStatusFailed:
                NSLog(@"AVPlayerItem got problem");
                self.isReadyToPlay = NO;
                break;
            case AVPlayerStatusReadyToPlay:
                NSLog(@"Ready to Play");
                self.isReadyToPlay = YES;
                break;
            case AVPlayerStatusUnknown:
                self.isReadyToPlay = NO;
                break;
            default:
                break;
        }
    }
}

#pragma mark -

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear");
    
    // NavigationBar Setup
    self.navigationController.navigationBar.hidden = NO;
    
    //[[UIApplication sharedApplication] setStatusBarHidden: NO];
    
    [timer invalidate];
    
    if (self.avPlayer != nil) {
        [self.avPlayer pause];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"dealloc");
    
    if (self.avPlayer != nil) {
        NSLog(@"self.avPlayer != nil");
        NSLog(@"remove observer");
        [self.avPlayer removeObserver: self forKeyPath: @"status"];
    }
}

- (void)playCheck: (NSString *)audioStr
{
    NSLog(@"playCheck");
    
    // audioSwitch is ON, after pressed button will be set to NO
    // That means audioSwitch is ON at the beginning
    if (!_audioSwitch) {
        NSLog(@"audioSwitch is ON");
        if (!_fromPageText) {
            NSLog(@"if the previous viewController is not PageTextViewController");
            
            if (!_videoPlay) {
                NSLog(@"videoPlay is finished");
                if (![audioStr isKindOfClass: [NSNull class]]) {
                    if (![audioStr isEqualToString: @""]) {
                        if (self.avPlayer != nil) {
                            NSLog(@"avPlayer is not nil");
                            if (self.isReadyToPlay) {
                                NSLog(@"self.isReadyToPlay is set to: %d", self.isReadyToPlay);
                                if (isplayaudio) {
                                    NSLog(@"isplayaudio is set to: %d", isplayaudio);
                                    [self.avPlayer play];
                                }
                            }
                        }
                    }
                }
            } else if (_videoPlay) {
                NSLog(@"Video is playing");
                [self.avPlayer pause];
                NSLog(@"avPlayer pause");
            }
        } else if (_fromPageText) {
            _fromPageText = NO;
        }
    }
}

#pragma mark -
#pragma mark Audio Related Methods

- (void)playbool: (id)sender {
    NSLog(@"playbool");
    
    //[self removeNotification];
    
    if (_audioSwitch) {
        NSLog(@"audioSwitch is set to YES");
        NSLog(@"_audioSwitch: %d", _audioSwitch);
        isplayaudio = YES;
        
        if (_videoPlay) {
            NSLog(@"videoPlay is set to YES");
            isplayaudio = NO;
        } else {
            NSLog(@"videoPlay is set to NO");
            isplayaudio = YES;
        }
        
        _audioSwitch = NO;
    } else {
        NSLog(@"audioSwitch is set to NO");
        NSLog(@"_audioSwitch: %d", _audioSwitch);
        isplayaudio = NO;
        
        _audioSwitch = YES;
    }
    
    //isplayaudio = !isplayaudio;
    
    NSLog(@"isplayaudio: %d", isplayaudio);
    
    if (self.avPlayer != nil) {
        NSLog(@"avPlayer is not nil");
        NSLog(@"avPlayer: %@", self.avPlayer);
        
        if (isplayaudio) {
            [self.avPlayer play];
            NSLog(@"avPlayer play");
            
            [self changeAudioButtonImage];
            
        } else {
            [self.avPlayer pause];
            NSLog(@"avPlayer pause");
            
            [self changeAudioButtonImage];
        }
    } else {
        NSLog(@"avPlayer is nil");
        NSLog(@"avPlayer: %@", self.avPlayer);
    }
}

/*
- (void)avAudioPlayerSetUp: (NSData *)fileData
{
    NSLog(@"");
    NSLog(@"avAudioPlayerSetUp");
 
    //註冊audioInterrupted
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver: self selector: @selector(audionInterrupted:) name: AVAudioSessionInterruptionNotification object: nil];
    
    //初始化
    audioPlayer = [[AVAudioPlayer alloc] initWithData: fileData error: nil];
    
    BOOL isLoop;
    
    NSLog(@"audioMode: %@", audioMode);
    
    if ([audioMode isEqualToString: @"singular"]) {
        isLoop = [bookdata[@"audio_loop"] boolValue];
        NSLog(@"audioLoop: %d", isLoop);
        
        if (isLoop) {
            NSLog(@"Loop Audio");
            [audioPlayer setNumberOfLoops: -1];
        } else {
            NSLog(@"Don't Loop Audio");
            [audioPlayer setNumberOfLoops: 0];
        }
    } else if ([audioMode isEqualToString: @"plural"]) {
        int page = mySV.contentOffset.x / mySV.frame.size.width;
        NSLog(@"page: %d", page);
        
        isLoop = [datalist[page][@"audio_loop"] boolValue];
        NSLog(@"audioLoop: %d", isLoop);
        
        if (isLoop) {
            NSLog(@"Loop Audio");
            [audioPlayer setNumberOfLoops: -1];
        } else {
            NSLog(@"Don't Loop Audio");
            [audioPlayer setNumberOfLoops: 0];
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    // NavigationBar Setup
    //self.navigationController.navigationBar.hidden = NO;
    
    [[UIApplication sharedApplication] setStatusBarHidden: NO];    
    
    [timer invalidate];
    
    if (audioPlayer != nil) {
        [audioPlayer pause];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)audionInterrupted:(NSNotification *)notification{
    NSUInteger type=[notification.userInfo[AVAudioSessionInterruptionTypeKey] intValue];
    NSUInteger option=[notification.userInfo[AVAudioSessionInterruptionOptionKey]intValue];
    
    if (type == AVAudioSessionInterruptionTypeBegan) {
        NSLog(@"中斷音樂");
    }else if (type==AVAudioSessionInterruptionTypeBegan){
        if (option == AVAudioSessionInterruptionTypeEnded) {
            NSLog(@"中斷恢復");
            if ([audioPlayer prepareToPlay]) {
                [NSThread sleepForTimeInterval:0.1];
                [audioPlayer play];
            }
        }
    }
}

- (void)playCheck: (NSString *)audioStr
{
    NSLog(@"");
    NSLog(@"playCheck");
    
    // audioSwitch is ON, after pressed button will be set to NO
    // That means audioSwitch is ON at the beginning
    if (!_audioSwitch) {
        NSLog(@"audioSwitch is ON");
        if (!_fromPageText) {
            NSLog(@"if the previous viewController is not PageTextViewController");
            if (!_videoPlay) {
                NSLog(@"videoPlay is finished");
                if (![audioStr isKindOfClass: [NSNull class]]) {
                    if (![audioStr isEqualToString: @""]) {
                        if (audioPlayer != nil) {
                            NSLog(@"audioPlayer is not nil");
                            if ([audioPlayer prepareToPlay]) {
                                NSLog(@"audioPlayer prepareToPlay");
                                if (isplayaudio) {
                                    NSLog(@"audioPlayer play");
                                    [audioPlayer play];
                                }
                            }
                        }
                    }
                }
                                
            } else if (_videoPlay) {
                NSLog(@"Video is playing");
                [audioPlayer pause];
                NSLog(@"audioPlayer pause");
            }
        } else if (_fromPageText) {
            _fromPageText = NO;
        }
    }
}

#pragma mark -
#pragma mark Audio Related Methods

- (void)playbool: (id)sender {
    NSLog(@"");
    NSLog(@"playbool");
    
    if (_audioSwitch) {
        NSLog(@"audioSwitch is set to YES");
        NSLog(@"_audioSwitch: %d", _audioSwitch);
        isplayaudio = YES;
        
        if (_videoPlay) {
            NSLog(@"videoPlay is set to YES");
            isplayaudio = NO;
        } else {
            NSLog(@"videoPlay is set to NO");
            isplayaudio = YES;
        }
        
        _audioSwitch = NO;
    } else {
        NSLog(@"audioSwitch is set to NO");
        NSLog(@"_audioSwitch: %d", _audioSwitch);
        isplayaudio = NO;
        
        _audioSwitch = YES;
    }
    
    //isplayaudio = !isplayaudio;
    
    NSLog(@"isplayaudio: %d", isplayaudio);
    
    if (audioPlayer != nil) {
        NSLog(@"audioPlayer is not nil");
        NSLog(@"audioPlayer: %@", audioPlayer);
        
        if (isplayaudio) {
            [audioPlayer play];
            NSLog(@"audioPlayer play");
            
            [self changeAudioButtonImage];
            
        } else {
            [audioPlayer pause];
            NSLog(@"audioPlayer pause");
            
            [self changeAudioButtonImage];
        }
    } else {
        NSLog(@"audioPlayer is nil");
        NSLog(@"audioPlayer: %@", audioPlayer);
    }
}
*/

- (void)changeAudioButtonImage
{
    NSLog(@"changeAudioButtonImage");

    for (UIView *addedView in mySV.subviews) {
        for (UIView *sub in [addedView subviews]) {
            if ([sub isKindOfClass: [UIButton class]]) {
                UIButton *btn = (UIButton *)sub;
                
                NSLog(@"btn.tag: %ld", (long)btn.tag);
                NSLog(@"isplayaudio: %d", isplayaudio);
                
                if (btn.tag == 55) {
                    if (isplayaudio) {
                        [btn setImage: [UIImage imageNamed: @"icon_audioswitch_open_white_75x75"] forState: UIControlStateNormal];
                    } else {
                        [btn setImage: [UIImage imageNamed: @"icon_audioswitch_close_white_75x75"] forState: UIControlStateNormal];
                    }
                }
            }
        }
    }
}

- (void)addingAudioButton: (UIView *)v target: (NSString *)audioTarget page: (int)pageId
{
    NSLog(@"addingAudioButton");

    NSLog(@"pageId: %d", pageId);
    NSLog(@"audioTarget: %@", audioTarget);
    
    NSLog(@"isplayaudio: %d", isplayaudio);
    NSLog(@"audioMode: %@", audioMode);
    
    if ([audioMode isEqualToString: @"singular"]) {
        NSLog(@"audioMode is signular");
        UIButton *btn;
                
        if (isplayaudio) {
            btn = [wTools W_Button: self frame: CGRectMake(0, 0, 50, 50) imgname: @"icon_audioswitch_open_white_75x75" SELL: @selector(playbool:) tag: pageId];
        } else {
            btn = [wTools W_Button: self frame: CGRectMake(0, 0, 50, 50) imgname: @"icon_audioswitch_close_white_75x75" SELL: @selector(playbool:) tag: pageId];
        }
        
        //btn.center = CGPointMake(v.frame.size.width / 2, v.frame.size.height / 2);
        btn.center = CGPointMake(v.frame.size.width - 25, 25);
        btn.tag = 55;
        
        UIView *btnBgView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 50, 50)];
        btnBgView.center = CGPointMake(v.frame.size.width - 25, 25);
        btnBgView.backgroundColor = [UIColor blackColor];
        btnBgView.alpha = 0.5;
        btnBgView.layer.cornerRadius = 25;
        btnBgView.clipsToBounds = YES;
        
        [v addSubview: btnBgView];
        NSLog(@"v addSubview btbBgView");
        
        [v addSubview: btn];
        NSLog(@"v addSubview btn");
    }
    
    if ([audioMode isEqualToString: @"plural"]) {
        NSLog(@"audioMode is plural");
        
        if (![audioTarget isKindOfClass: [NSNull class]]) {
            
            NSLog(@"audioTarget is not null class");
            NSLog(@"audioTarget: %@", audioTarget);
            
            UIButton *btn;
            
            if (isplayaudio) {
                btn = [wTools W_Button: self frame: CGRectMake(0, 0, 50, 50) imgname: @"icon_audioswitch_open_white_75x75" SELL: @selector(playbool:) tag: pageId];
            } else {
                btn = [wTools W_Button: self frame: CGRectMake(0, 0, 50, 50) imgname: @"icon_audioswitch_close_white_75x75" SELL: @selector(playbool:) tag: pageId];
            }
            
            //btn.center = CGPointMake(v.frame.size.width / 2, v.frame.size.height / 2);
            btn.center = CGPointMake(v.frame.size.width - 25, 25);
            btn.tag = 55;
            
            UIView *btnBgView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 50, 50)];
            btnBgView.center = CGPointMake(v.frame.size.width - 25, 25);
            btnBgView.backgroundColor = [UIColor blackColor];
            btnBgView.alpha = 0.5;
            btnBgView.layer.cornerRadius = 25;
            btnBgView.clipsToBounds = YES;
            
            [v addSubview: btnBgView];
            NSLog(@"v addSubview btbBgView");
            
            [v addSubview: btn];
            NSLog(@"v addSubview btn");
        }
    }
}

#pragma mark -
#pragma mark Activity Related

- (void)checkPointForActivity
{
    // Check album is owned or not
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *checkOwn = [defaults objectForKey: @"checkOwn"];
    NSLog(@"checkOwn: %@", checkOwn);
    
    // Check task_for value
    task_for = [defaults objectForKey: @"task_for"];
    NSLog(@"task_for: %@", task_for);
    
    if ([task_for isEqualToString: @"create_free_album"]) {
        // Check whether getting creating album point or not
        BOOL create_free_album = [[defaults objectForKey: @"create_free_album"] boolValue];
        NSLog(@"Check whether getting Download Template point or not");
        NSLog(@"create_free_album: %d", (int)create_free_album);
        
        if (create_free_album) {
            NSLog(@"Get the First Time Creating Album Point Already");
        } else {
            NSLog(@"Haven't got the point of creating album for first time");
            [self checkPoint];
        }
    } else if ([checkOwn isEqualToString: @"Haven'tOwned"]) {
        
        if ([task_for isEqualToString: @"collect_free_album"]) {
            // Check whether getting Free Album point or not
            BOOL collect_free_album = [[defaults objectForKey: @"collect_free_album"] boolValue];
            NSLog(@"Check whether getting Album Saving point or not");
            NSLog(@"collect_free_album: %d", (int)collect_free_album);
            
            if (collect_free_album) {
                NSLog(@"Get the First Time Album Saving Point Already");
            } else {
                NSLog(@"Haven't got the point of saving album for first time");
                [self checkPoint];
            }
        } else if ([task_for isEqualToString: @"collect_pay_album"]) {
            // Check whether getting Pay Album Point or not
            BOOL collect_pay_album = [[defaults objectForKey: @"collect_pay_album"] boolValue];
            NSLog(@"Check whether getting paid album point or not");
            NSLog(@"collect_pay_album: %d", (int)collect_pay_album);
            
            if (collect_pay_album) {
                NSLog(@"Getting Paid Album Point Already");
            } else {
                NSLog(@"Haven't got the point of saving paid album for first time");
                [self checkPoint];
            }
        }
    }
}

#pragma mark -
#pragma mark Text Description Related Methods

- (void)viewSignleTapped: (UIGestureRecognizer *)recognizer
{
    if (myText.hidden == YES) {
        myText.hidden = NO;
    } else if (myText.hidden == NO) {
        myText.hidden = YES;
    }
}

#pragma mark - Check Point Method

- (void)checkPoint
{
    NSLog(@"checkPoint");
    
    //[wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *response = [boxAPI doTask2: [wTools getUserID] token: [wTools getUserToken] task_for: task_for platform: @"apple" type: @"album" type_id: _albumid];
        
        NSLog(@"User ID: %@", [wTools getUserID]);
        NSLog(@"Token: %@", [wTools getUserToken]);
        NSLog(@"Task_For: %@", task_for);
        NSLog(@"Album ID: %@", _albumid);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //[wTools HideMBProgressHUD];
            [MBProgressHUD hideHUDForView: self.view animated: YES];
            
            if (response != nil) {
                NSLog(@"%@", response);
                NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                if ([data[@"result"] intValue] == 1) {
                    missionTopicStr = data[@"data"][@"task"][@"name"];
                    NSLog(@"name: %@", missionTopicStr);
                    
                    rewardType = data[@"data"][@"task"][@"reward"];
                    NSLog(@"reward type: %@", rewardType);
                    
                    rewardValue = data[@"data"][@"task"][@"reward_value"];
                    NSLog(@"reward value: %@", rewardValue);
                    
                    eventUrl = data[@"data"][@"event"][@"url"];
                    NSLog(@"event: %@", eventUrl);
                    
                    [self showAlertView];
                    
                } else if ([data[@"result"] intValue] == 2) {
                    NSLog(@"message: %@", data[@"message"]);
                    
                    if ([task_for isEqualToString: @"create_free_album"]) {
                        
                        // Save data for creating album first time
                        BOOL create_free_album = YES;
                        
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        [defaults setObject: [NSNumber numberWithBool: create_free_album]  forKey: @"create_free_album"];
                        [defaults synchronize];
                        
                    } else if ([task_for isEqualToString: @"collect_free_album"]) {
                        
                        // Save data for first collect album
                        BOOL collect_free_album = YES;
                        
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        [defaults setObject: [NSNumber numberWithBool: collect_free_album]
                                     forKey: @"collect_free_album"];
                        [defaults synchronize];
                        
                    } else if ([task_for isEqualToString: @"collect_pay_album"]) {
                        
                        // Save data for first collect paid album
                        BOOL collect_pay_album = YES;
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        [defaults setObject: [NSNumber numberWithBool: collect_pay_album]
                                     forKey: @"collect_pay_album"];
                        [defaults synchronize];
                    }
                    
                } else if ([data[@"result"] intValue] == 0) {
                    NSString *errorMessage = data[@"message"];
                    NSLog(@"error messsage: %@", errorMessage);
                } else {
                    [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];                
                }
            }
        });
    });
}

#pragma mark - Custom AlertView for Getting Point
- (void)showAlertView
{
    NSLog(@"Show Alert View");
    
    // Custom AlertView shows up when getting the point
    alertView = [[CustomIOSAlertView alloc] init];
    [alertView setContainerView: [self createPointView]];
    [alertView setButtonTitles: [NSMutableArray arrayWithObject: @"確     認"]];
    [alertView setUseMotionEffects: true];
    
    [alertView show];
}

- (UIView *)createPointView
{
    NSLog(@"createPointView");
    
    UIView *pointView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 250, 250)];
    
    // Mission Topic Label
    UILabel *missionTopicLabel = [[UILabel alloc] initWithFrame: CGRectMake(5, 15, 200, 10)];
    //missionTopicLabel.text = @"收藏相本得點";
    missionTopicLabel.text = missionTopicStr;
    
    NSLog(@"Topic Label Text: %@", missionTopicStr);
    [pointView addSubview: missionTopicLabel];
    
    // Gift Image
    UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(50, 40, 150, 150)];
    imageView.image = [UIImage imageNamed: @"icon_present"];
    [pointView addSubview: imageView];
    
    // Message Label
    UILabel *messageLabel = [[UILabel alloc] initWithFrame: CGRectMake(5, 200, 200, 10)];
    
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
    
    messageLabel.text = [NSString stringWithFormat: @"%@%@%@", congratulate, rewardValue, end];
    [pointView addSubview: messageLabel];
    
    // Activity Button
    UIButton *activityButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [activityButton addTarget: self action: @selector(showTheActivityPage) forControlEvents: UIControlEventTouchUpInside];
    activityButton.frame = CGRectMake(150, 220, 100, 10);
    [activityButton setTitle: @"活動連結" forState: UIControlStateNormal];
    [activityButton setTitleColor: [UIColor colorWithRed: 26.0/255.0 green: 196.0/255.0 blue: 199.0/255.0 alpha: 1.0]
                         forState: UIControlStateNormal];
    [pointView addSubview: activityButton];
    
    return pointView;
}

- (void)showTheActivityPage
{
    NSLog(@"showTheActivityPage");
    
    //NSString *activityLink = @"http://www.apple.com";
    NSString *activityLink = eventUrl;
    
    NSURL *url = [NSURL URLWithString: activityLink];
    
    // Close for present safari view controller, otherwise alertView will hide the background
    [alertView close];
    
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL: url entersReaderIfAvailable: NO];
    safariVC.delegate = self;
    safariVC.preferredBarTintColor = [UIColor whiteColor];
    [self presentViewController: safariVC animated: YES completion: nil];
}

#pragma mark - SFSafariViewController delegate methods
- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller
{
    // Done button pressed
    
    NSLog(@"show");
    [alertView show];
}

#pragma mark -

- (IBAction)back:(id)sender {
    NSLog(@"BookViewController");
    NSLog(@"back");
    
    NSArray *vcarr = self.navigationController.viewControllers;
    
    for (id controller in self.navigationController.viewControllers) {
        NSLog(@"controller: %@", controller);
        
        if ([controller isKindOfClass: [homeViewController class]]) {
            [self.navigationController popToViewController: controller animated: YES];
            break;
        } else if ([controller isKindOfClass: [PageCollectionViewController class]]) {
            [self.navigationController popToViewController: controller animated: YES];
            break;
        }
    }
    
    for (int i = vcarr.count - 2  ;i > 0  ;i--) {
        UIViewController *vc = vcarr[i];
        
        NSLog(@"i: %d", i);
        NSLog(@"vc: %@", vc);
        
        NSLog(@"postMode: %d", _postMode);
        
        if (_postMode) {
            /*
            if ([vc isKindOfClass: [EventPostViewController class]]) {
                NSString *alertMessage = @"確定投稿此作品? (點 取消 則退出作品瀏覽，如需再投稿此作品請至活動頁面 - 點擊投稿 - 選擇現有作品)";
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"" message: alertMessage preferredStyle: UIAlertControllerStyleAlert];
                //UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleDefault handler: nil];
                UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self.navigationController popToViewController: vc animated: YES];
                }];
                UIAlertAction *okBtn = [UIAlertAction actionWithTitle: @"確定" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self postAlbum];
                    [self.navigationController popToViewController: vc animated: YES];
                }];
                
                [alert addAction: cancelBtn];
                [alert addAction: okBtn];
                [self presentViewController: alert animated: YES completion: nil];
            }
             */
            
            NSLog(@"self.fromEventPostVC: %d", self.fromEventPostVC);
            
            if (self.fromEventPostVC) {
                NSString *alertMessage = @"確定投稿此作品? (點 取消 則退出作品瀏覽，如需再投稿此作品請至活動頁面 - 點擊投稿 - 選擇現有作品)";
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"" message: alertMessage preferredStyle: UIAlertControllerStyleAlert];
                //UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleDefault handler: nil];
                UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self.navigationController popToViewController: vc animated: YES];
                }];
                UIAlertAction *okBtn = [UIAlertAction actionWithTitle: @"確定" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self postAlbum];
                    //[self.navigationController popToViewController: vc animated: YES];
                    
                    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
                    //[app.menu showJCC:nil];
                    
                    // Check from which viewController pushes
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    BOOL fromHomeVC = [[defaults objectForKey: @"fromHomeVC"] boolValue];
                    NSLog(@"fromHomeVC: %d", fromHomeVC);
                    
                    if (fromHomeVC) {
                        NSLog(@"fromHomeVC: %d", fromHomeVC);
                        [app.menu homebtn: nil];
                        //[self.navigationController popViewControllerAnimated: NO];
                        return;
                    } else {
                        NSLog(@"fromHomeVC: %d", fromHomeVC);
                        [self.navigationController popViewControllerAnimated: YES];
                        return;
                    }
                }];
                
                [alert addAction: cancelBtn];
                [alert addAction: okBtn];
                [self presentViewController: alert animated: YES completion: nil];
                
                return;
            }
        } else if ([vc isKindOfClass:[CalbumlistViewController class]] ||  [vc isKindOfClass:[RetrievealbumpViewController class]] || [vc isKindOfClass:[OfflineViewController class]] || [vc isKindOfClass:[PageCollectionViewController class]]) {
            
            [self.navigationController popToViewController:vc animated:YES];
            return;
        }
    }
    
    NSLog(@"if above conditions aren't matched");
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    //[app.menu showJCC:nil];
    
    // Check from which viewController pushes
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL fromHomeVC = [[defaults objectForKey: @"fromHomeVC"] boolValue];
    NSLog(@"fromHomeVC: %d", fromHomeVC);
    
    if (fromHomeVC) {
        NSLog(@"fromHomeVC");
        [app.menu homebtn: nil];
        //[self.navigationController popViewControllerAnimated: NO];
    } else {
        NSLog(@"Not fromHomeVC");
        [self.navigationController popViewControllerAnimated: YES];
    }
}

- (void)postAlbum
{
    //[wTools ShowMBProgressHUD];
    [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI switchstatusofcontribution: [wTools getUserID] token: [wTools getUserToken] event_id: _eventId album_id: _albumid];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[wTools HideMBProgressHUD];
            [MBProgressHUD hideHUDForView: self.view animated: YES];
            
            if (response != nil) {
                NSLog(@"%@", response);
                
                NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                if ([dic[@"result"] intValue] == 1) {
                    NSLog(@"post album success");
                    int contributionCheck = [dic[@"data"][@"event"][@"contributionstatus"] boolValue];
                    NSLog(@"contributionCheck: %d", contributionCheck);
                } else if ([dic[@"result"] intValue] == 0) {
                    NSLog(@"message: %@", dic[@"message"]);
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"" message: dic[@"message"] preferredStyle: UIAlertControllerStyleAlert];
                    UIAlertAction *okBtn = [UIAlertAction actionWithTitle: @"OK" style: UIAlertActionStyleDefault handler: nil];
                    [alert addAction: okBtn];
                    [self presentViewController: alert animated: YES completion: nil];
                } else {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"" message: NSLocalizedString(@"Host-NotAvailable", @"") preferredStyle: UIAlertControllerStyleAlert];
                    UIAlertAction *okBtn = [UIAlertAction actionWithTitle: @"OK" style: UIAlertActionStyleDefault handler: nil];
                    [alert addAction: okBtn];
                    [self presentViewController: alert animated: YES completion: nil];
                }
            }
        });
    });
}

#pragma mark - MyScrollViewDataScource
-(UIView *)ScrollView:(MyScrollView *)scrollView atPage:(int)pageId
{
    // Activate when flip page
    // Preloading Content Methods
    // So, pageId is ahead of current page in order to prepare the content for display
    NSLog(@"");
    NSLog(@"MyScrollView DataSource");
    
    UIView *v = [[UIView alloc] initWithFrame: CGRectMake(scrollView.bounds.size.width * pageId, 0, scrollView.bounds.size.width, scrollView.bounds.size.height)];
    
    NSLog(@"pageId: %d", pageId);
    NSLog(@"x coordinate: %f", scrollView.bounds.size.width * pageId);
    
    //NSLog(@"datalist: %@", datalist);
    
    //相片用途
    NSString *usefor = datalist[pageId][@"usefor"];
    //NSLog(@"usefor: %@", usefor);
    
    NSString *pid = [datalist[pageId][@"photo_id"] stringValue];
    NSLog(@"pid: %@", pid);

    NSLog(@"pageId: %d", pageId);
    
    
    int page = mySV.contentOffset.x / mySV.frame.size.width;
    NSLog(@"page: %d", page);
    
    myText.text = datalist[page][@"description"];
    NSLog(@"description: %@", datalist[page][@"description"]);
    NSLog(@"myText.text: %@", myText);
    
    // Adjust TextView based on Content
    NSLog(@"myText.contentSize.height: %f", myText.contentSize.height);
    CGRect frame = myText.frame;
    
    if ([myText.text isEqualToString: @""]) {
        frame.size.height = 0;
        myText.frame = CGRectMake(0, scrollView.bounds.size.height - frame.size.height, frame.size.width, frame.size.height);
    } else {
        if (myText.contentSize.height > v.bounds.size.height * 1/3 ) {
            frame.size.height = v.bounds.size.height * 1/3;
            myText.frame = CGRectMake(0, scrollView.bounds.size.height - frame.size.height, frame.size.width, frame.size.height);
        } else if (myText.contentSize.height < 168) {
            frame.size.height = 168;
            myText.frame = CGRectMake(0, scrollView.bounds.size.height - frame.size.height, frame.size.width, frame.size.height);
        } else {
            frame.size.height = myText.contentSize.height;
            myText.frame = CGRectMake(0, scrollView.bounds.size.height - frame.size.height, frame.size.width, frame.size.height);
        }
    }
    
    // Audio Section
    NSString *audioTarget = datalist[pageId][@"audio_target"];
    NSLog(@"audioTarget: %@", audioTarget);
    NSLog(@"audioMode: %@", audioMode);

    
    //相片
    if ([usefor isEqualToString:@"image"]) {
        
        NSLog(@"usefor is image");
        
        UIScrollView *sc = [[UIScrollView alloc] initWithFrame: v.bounds];
        sc.maximumZoomScale = 2.0;
        sc.minimumZoomScale = 1;
        sc.delegate = self;
        
        NSString *filename = [NSString stringWithFormat: @"%d.jpg", pageId];
        NSString *imagePath = [file stringByAppendingPathComponent: filename];
        
        UIImageView *imagev = [[UIImageView alloc] initWithFrame: v.bounds];
        
        NSLog(@"image w: %f h: %f", imagev.bounds.size.width, imagev.bounds.size.height);
        
        NSLog(@"dic: %@", _dic);
        
        
        if (_dic) {
            NSLog(@"dic is not null");
            
            NSURL *url = [NSURL URLWithString: datalist[pageId][@"image_url"]];
            NSData *data = [NSData dataWithContentsOfURL: url];
            imagev.image = [UIImage imageWithData: data];
        } else {
            NSLog(@"dic is null");
            NSLog(@"imagePath: %@", imagePath);
            imagev.image = [UIImage imageWithContentsOfFile: imagePath];
        }
                        
        imagev.contentMode = UIViewContentModeScaleAspectFit;        
        [sc addSubview: imagev];
        [v addSubview: sc];
        
        int page = mySV.contentOffset.x / mySV.frame.size.width;
        NSLog(@"page: %d", page);
        
        [self addingAudioButton: v target: audioTarget page: pageId];
        
    } else {
        NSLog(@"usefor is not image");
        
        NSString *filename = [NSString stringWithFormat: @"%d.jpg", pageId];
        NSString *imagePath = [file stringByAppendingPathComponent: filename];
                
        UIImageView *imagev = [[UIImageView alloc]initWithFrame: v.bounds];
        imagev.accessibilityIdentifier = imagePath;
        imagev.image = [UIImage imageWithContentsOfFile: imagePath];
        imagev.contentMode = UIViewContentModeScaleAspectFit;
        [v addSubview: imagev];
                
        int page = mySV.contentOffset.x / mySV.frame.size.width;
        NSLog(@"page: %d", page);
    }
    
    //影片
    if([usefor isEqualToString: @"video"]){
        
        NSLog(@"usefor is video");
        
        UIView *bv = [[UIView alloc] initWithFrame: v.bounds];
        bv.backgroundColor = [UIColor blackColor];
        bv.alpha = 0.5;
        [v addSubview: bv];
        
        NSString *refer = datalist[pageId][@"video_refer"];
        NSLog(@"refer: %@", refer);
        
        if ([refer isEqualToString: @"embed"]) {
            UIButton *btn = [wTools W_Button: self frame: CGRectMake(0, 0, 100, 100) imgname: @"wbutton_play.png" SELL: @selector(videoembed:) tag: pageId];
            btn.center = CGPointMake(v.frame.size.width / 2, v.frame.size.height / 2);
            [v addSubview: btn];
        }
        if ([refer isEqualToString: @"file"]) {
            UIButton *btn = [wTools W_Button: self frame: CGRectMake(0, 0, 100, 100) imgname: @"wbutton_play.png" SELL: @selector(videofile:) tag: pageId];
            btn.center = CGPointMake(v.frame.size.width / 2, v.frame.size.height / 2);
            [v addSubview: btn];
        }
        if ([refer isEqualToString: @"system"]) {
            UIButton *btn = [wTools W_Button: self frame: CGRectMake(0, 0, 100, 100) imgname: @"wbutton_play.png" SELL: @selector(videofile:) tag: pageId];
            btn.center = CGPointMake(v.frame.size.width / 2, v.frame.size.height / 2);
            [v addSubview: btn];
        }
        
        [self addingAudioButton: v target: audioTarget page: pageId];
    }
    
    NSArray *slotArray = [self readPlist: @"slot"];
    //NSLog(@"slotArray: %@", slotArray);
    NSArray *giftArray = [self readPlist: @"gift"];
    //NSLog(@"giftArray: %@", giftArray);
    
    BOOL slotPressed = NO;
    BOOL slotGiftExchanged = NO;
    
    NSLog(@"initial value");
    NSLog(@"slotPressed %d", (int)slotPressed);
    NSLog(@"slotGiftExchanged %d", (int)slotGiftExchanged);
    
    
    for (NSDictionary *dict in slotArray) {
        for (NSString *str in [dict allKeys]) {
            if ([str isEqualToString: pid]) {
                slotPressed = YES;
            }
        }
    }
    
    for (NSString *str in giftArray) {
        if ([str isEqualToString: pid]) {
            //NSLog(@"pidArray for gift: %@", str);
            //NSLog(@"pid: %@", pid);
            slotGiftExchanged = YES;
        }
    }
    
    NSLog(@"after setting value");
    NSLog(@"slotPressed is :%d", (int)slotPressed);
    NSLog(@"slotGiftExchanged is :%d", (int)slotGiftExchanged);
    
    //拉霸
    if ([usefor isEqualToString: @"slot"]) {
        
        [self addingAudioButton: v target: audioTarget page: pageId];
        
        NSLog(@"usefor is slot");
        
        // If slot gift is already exchanged
        if (slotGiftExchanged) {
            NSLog(@"slotGiftExchanged");
            
            UIView *bv = [[UIView alloc] initWithFrame: v.bounds];
            bv.backgroundColor = [UIColor blackColor];
            bv.alpha = 0.5;
            [v addSubview: bv];
            
            // Show Image
            UIImageView *exchangedImage = [[UIImageView alloc] initWithFrame: CGRectMake(v.bounds.size.width - 100 * 1.0, v.bounds.size.height - 100 * 1.0, 100 * 1.0, 100 * 1.0)];
            exchangedImage.image = [UIImage imageNamed: @"icon_exchanged.png"];
            [v addSubview: exchangedImage];
            
            // Show exchange label
            exchangeLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 100, 26)];
            exchangeLabel.center = CGPointMake(exchangedImage.center.x + 15, exchangedImage.center.y + 26);
            exchangeLabel.textAlignment = 1;
            exchangeLabel.text = @"已兌換";
            exchangeLabel.font = [UIFont systemFontOfSize: 22];
            exchangeLabel.textColor = [UIColor whiteColor];
            [v addSubview: exchangeLabel];
            
        } else {
            
            // If slot button is pressed
            if (slotPressed) {
                NSLog(@"slotPressed");
                
                // Shows the exchange image 截角圖
                UIView *bv = [[UIView alloc] initWithFrame: v.bounds];
                bv.backgroundColor = [UIColor blackColor];
                bv.alpha = 0.5;
                [v addSubview: bv];
                
                exchangeButton = [wTools W_Button: self frame: CGRectMake(v.bounds.size.width - 100 * 1.0, v.bounds.size.height - 100 * 1.0, 100 * 1.0, 100 * 1.0) imgname: @"icon_exchange.png" SELL: @selector(showGift) tag: pageId];
                [exchangeButton setImage: [UIImage imageNamed: @"icon_exchange_click.png"] forState:UIControlStateHighlighted];
                [v addSubview: exchangeButton];
                
                exchangeLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 100, 26)];
                exchangeLabel.center = CGPointMake(exchangeButton.center.x + 15, exchangeButton.center.y + 26);
                exchangeLabel.textAlignment = 1;
                exchangeLabel.text = @"兌 換";
                exchangeLabel.font = [UIFont systemFontOfSize: 22];
                exchangeLabel.textColor = [UIColor whiteColor];
                [v addSubview: exchangeLabel];
                
            } else {
                NSLog(@"slot is not pressed");
                
                // If slot button is not pressed
                // Shows the Gift Slot Image
                UIView *bv = [[UIView alloc] initWithFrame: v.bounds];
                bv.backgroundColor = [UIColor blackColor];
                bv.alpha = 0.5;
                [v addSubview: bv];
                
                UIButton *btn = [wTools W_Button: self frame: CGRectMake(v.bounds.size.width - 100, v.bounds.size.height - 100, 180, 200) imgname: @"gift_slot.png" SELL: @selector(showSlot:) tag: pageId];
                btn.center = CGPointMake(v.frame.size.width / 2, v.frame.size.height / 2);
                [v addSubview: btn];
            }
        }
        
        // Reset to NO
        slotPressed = NO;
        slotGiftExchanged = NO;
    }
    
    //兌換
    if ([usefor isEqualToString: @"exchange"]) {
        
        NSLog(@"usefor is exchange");
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey: @"giftExchanged"]) {
            NSLog(@"giftExchanged");
            
            UIView *bv = [[UIView alloc] initWithFrame: v.bounds];
            bv.backgroundColor = [UIColor blackColor];
            bv.alpha = 0.5;
            [v addSubview: bv];
            
            // Show Image
            UIImageView *exchangedImage = [[UIImageView alloc] initWithFrame: CGRectMake(v.bounds.size.width - 100 * 1.0, v.bounds.size.height - 100 * 1.0, 100 * 1.0, 100 * 1.0)];
            exchangedImage.image = [UIImage imageNamed: @"icon_exchanged.png"];
            [v addSubview: exchangedImage];
            
            exchangeLabel1 = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 100, 26)];
            exchangeLabel1.center = CGPointMake(exchangedImage.center.x + 15, exchangedImage.center.y + 26);
            exchangeLabel1.textAlignment = 1;
            exchangeLabel1.text = @"已兌換";
            exchangeLabel1.font = [UIFont systemFontOfSize: 22];
            exchangeLabel1.textColor = [UIColor whiteColor];
            [v addSubview: exchangeLabel1];
            
        } else {
            UIView *bv = [[UIView alloc] initWithFrame: v.bounds];
            bv.backgroundColor = [UIColor blackColor];
            bv.alpha = 0.5;
            [v addSubview: bv];
            
            exchangeButton1 = [wTools W_Button: self frame: CGRectMake(v.bounds.size.width - 100 * 1.0, v.bounds.size.height - 100 * 1.0, 100 * 1.0, 100 * 1.0) imgname: @"icon_exchange.png" SELL: @selector(showexchange:) tag: pageId];
            [exchangeButton1 setImage: [UIImage imageNamed: @"icon_exchange_click.png"] forState:UIControlStateHighlighted];
            
            [v addSubview: exchangeButton1];
            
            exchangeLabel1 = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 100, 26)];
            exchangeLabel1.center = CGPointMake(exchangeButton1.center.x + 15, exchangeButton1.center.y + 26);
            exchangeLabel1.textAlignment = 1;
            exchangeLabel1.text = @"兌 換";
            exchangeLabel1.font = [UIFont systemFontOfSize: 22];
            exchangeLabel1.textColor = [UIColor whiteColor];
            [v addSubview: exchangeLabel1];
        }
        
        /*
         UIView *bv = [[UIView alloc] initWithFrame: v.bounds];
         bv.backgroundColor = [UIColor blackColor];
         bv.alpha = 0.5;
         [v addSubview: bv];
         
         exchangeButton1 = [wTools W_Button: self frame: CGRectMake(v.bounds.size.width - 100 * 1.0, v.bounds.size.height - 100 * 1.0, 100 * 1.0, 100 * 1.0) imgname: @"icon_exchange.png" SELL: @selector(showexchange:) tag: pageId];
         [exchangeButton1 setImage: [UIImage imageNamed: @"icon_exchange_click.png"] forState:UIControlStateHighlighted];
         
         [v addSubview: exchangeButton1];
         
         exchangeLabel1 = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 100, 26)];
         exchangeLabel1.center = CGPointMake(exchangeButton1.center.x + 15, exchangeButton1.center.y + 26);
         exchangeLabel1.textAlignment = 1;
         exchangeLabel1.text = @"兌 換";
         exchangeLabel1.font = [UIFont systemFontOfSize: 22];
         exchangeLabel1.textColor = [UIColor whiteColor];
         [v addSubview: exchangeLabel1];
         */
    }
    
    return v;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView  {
    return [[scrollView subviews]objectAtIndex:0];
}

-(CGSize)ContentSizeInScrollView:(MyScrollView *)scrollView
{
    return CGSizeMake(scrollView.bounds.size.width * datalist.count, scrollView.bounds.size.height);
}

-(int)TotalPageInScrollView:(MyScrollView *)scrollView
{
    return datalist.count;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"");
    NSLog(@"scrollViewDidEndDecelerating");
    
    //目前頁數
    int wNowPage = [mySV getNowPage: 2];
    NSLog(@"current page: %i", wNowPage);
    
    NSLog(@"dic album count_photo: %d", [_dic[@"album"][@"count_photo"] intValue]);
    
    NSString *usefor = datalist[wNowPage][@"usefor"];
    typelabel.text = usefor;
    
    // Text Description
    // For 1st and Last Page
    myText.text = datalist[wNowPage][@"description"];
    NSLog(@"description: %@", datalist[wNowPage][@"description"]);
    NSLog(@"myText.text: %@", myText);

    NSLog(@"myText.contentSize.height: %f", myText.contentSize.height);
    CGRect frame = myText.frame;
    
    if ([myText.text isEqualToString: @""]) {
        frame.size.height = 0;
        myText.frame = CGRectMake(0, scrollView.bounds.size.height - frame.size.height, frame.size.width, frame.size.height);
    } else {
        if (myText.contentSize.height > mySV.bounds.size.height * 1/3 ) {
            frame.size.height = mySV.bounds.size.height * 1/3;
            myText.frame = CGRectMake(0, scrollView.bounds.size.height - frame.size.height, frame.size.width, frame.size.height);
        } else if (myText.contentSize.height < 168) {
            frame.size.height = 168;
            myText.frame = CGRectMake(0, scrollView.bounds.size.height - frame.size.height, frame.size.width, frame.size.height);
        } else {
            frame.size.height = myText.contentSize.height;
            myText.frame = CGRectMake(0, scrollView.bounds.size.height - frame.size.height, frame.size.width, frame.size.height);
        }
    }
    
    NSLog(@"");
    //判斷播放音樂
    NSString *audiorefer = datalist[wNowPage][@"audio_refer"];
    NSLog(@"audiorefer: %@", audiorefer);
    
    NSString *photoAudioTarget = datalist[wNowPage][@"audio_target"];
    NSLog(@"photoAudioTarget: %@", photoAudioTarget);
    
    BOOL isplay = NO;
        
    if (playWholeAlbum) {
        NSLog(@"playWholeAlbum is set to YES");
        
        if (self.avPlayer != nil) {
            NSLog(@"avPlayer is not nil");
            if (isplay) {
                NSLog(@"isPlay set to YES");
                [self.avPlayer pause];
                NSLog(@"avPlayer is paused");
            } else {
                if (isplayaudio) {
                    NSLog(@"isPlayAudio is set to Yes");
                    [self.avPlayer play];
                    NSLog(@"avPlayer is played");
                }
            }
        }
        
        /*
        if (audioPlayer != nil) {
            NSLog(@"audioPlayer is not nil");
            if (isplay) {
                NSLog(@"isPlay set to YES");
                [audioPlayer pause];
                NSLog(@"audioPlayer is paused");
            } else {
                if ([audioPlayer prepareToPlay]) {
                    if (isplayaudio) {
                        NSLog(@"isPlayAudio is set to Yes");
                        [audioPlayer play];
                        NSLog(@"audioPlayer is played");
                    }
                }
            }
        }
         */
    } else {
        NSLog(@"playWholeAlbum is set to NO");
        
        if (![photoAudioTarget isKindOfClass: [NSNull class]]) {
            NSLog(@"photoAudioTarget is not null");
            
            isplay = YES;
            
            NSFileManager *fm = [NSFileManager defaultManager];
            NSString *audioPath = [file stringByAppendingPathComponent: photoAudioTarget];
            
            if ([fm fileExistsAtPath: audioPath]) {
                NSLog(@"FileManager file Exists At Path audioPath");
                
                NSURL *audioUrl = [NSURL fileURLWithPath: audioPath];
                [self avPlayerSetUp: audioUrl];
                
                if (self.avPlayer != nil) {
                    NSLog(@"avPlayer is initialized");                    
                    if (self.isReadyToPlay) {
                        if (isplayaudio) {
                            NSLog(@"isplayaudio is set to YES");
                            [self.avPlayer play];
                        }
                    }
                }
                
                /*
                NSData *fileData = [NSData dataWithContentsOfFile: audioPath];
                [self avAudioPlayerSetUp: fileData];
                
                if (audioPlayer != nil) {
                    NSLog(@"");
                    NSLog(@"PageaudioPlayer is not initialized");
                    
                    if ([audioPlayer prepareToPlay]) {
                        if (isplayaudio) {
                            NSLog(@"isplayaudio is set to YES");
                            [audioPlayer play];
                            NSLog(@"PageaudioPlayer is played");
                        }
                    }
                }
                 */
            } else {
                NSLog(@"FileManager file Does not Exist AtPath audioPath");
                NSURL *audioUrl = [NSURL URLWithString: photoAudioTarget];
                [self avPlayerSetUp: audioUrl];
                
                if (self.avPlayer != nil) {
                    NSLog(@"avPlayer is initialized");
                    if (self.isReadyToPlay) {
                        if (isplayaudio) {
                            NSLog(@"isplayaudio is set to YES");
                            [self.avPlayer play];
                        }
                    }
                }
            }
        } else {
            NSLog(@"photoAudioTarget is null");
            isplay = NO;
            
            //[audioPlayer pause];
            [self.avPlayer pause];
        }
    }
    
    /*
    if ([audiorefer isEqualToString:@"file"]) {
        isplay=YES;
        
        if (PageaudioPlayer !=nil) {
            [PageaudioPlayer stop];
        }
    }
    */
    
    /*
    if (![photoAudioTarget isKindOfClass: [NSNull class]]) {
        NSLog(@"audioTarget is not null");
        isplay = YES;
        
        NSFileManager *fm=[NSFileManager defaultManager];
        NSString *audioPath=[file stringByAppendingPathComponent: photoAudioTarget];
        
        if ([fm fileExistsAtPath:audioPath]) {
            NSData *fileData = [NSData dataWithContentsOfFile:audioPath];
            
            //註冊audioInterrupted
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
            NSNotificationCenter *center =[NSNotificationCenter defaultCenter];
            [center addObserver:self selector:@selector(audionInterrupted:) name:AVAudioSessionInterruptionNotification object:nil];
            //初始化
            PageaudioPlayer= [[AVAudioPlayer alloc]initWithData:fileData error:nil];
            
            if (PageaudioPlayer !=nil) {
                if ([PageaudioPlayer prepareToPlay]) {
                    if (isplayaudio) {
                        [PageaudioPlayer play];
                    } else {
                        [PageaudioPlayer stop];
                    }
                }
            }
        }
        
    } else {
        [PageaudioPlayer stop];
    }
    */
}

/*
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    lastContentOffset = scrollView.contentOffset.x;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"scrollViewDidEndDragging");
    
    int wNowPage = [mySV getNowPage: 2];
    NSLog(@"current page: %i", wNowPage);
    
    NSLog(@"dic album count_photo: %d", [_dic[@"album"][@"count_photo"] intValue]);
    
    //int totalPage = [_dic[@"album"][@"count_photo"] intValue];
    //NSLog(@"totalPage: %d", totalPage);

    NSLog(@"datalist: %@", datalist);
    NSLog(@"datalist.count: %lu", (unsigned long)datalist.count);
    
    if (lastContentOffset < scrollView.contentOffset.x) {
        NSLog(@"moved right");
        
        if (!_isDownloaded) {
            NSLog(@"isDownloaded: %d", _isDownloaded);
            
            if (wNowPage == datalist.count - 1) {
                NSLog(@"Last Page");
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"" message: @"內容預覽已到最末頁，點擊收藏才能瀏覽完整內容！" preferredStyle: UIAlertControllerStyleAlert];
                UIAlertAction *exitBtn = [UIAlertAction actionWithTitle: @"離開" style: UIAlertActionStyleDefault handler: nil];
                UIAlertAction *collectAndReadBtn = [UIAlertAction actionWithTitle: @"收藏並完整閱讀" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    [self collectAndDowloadBook];
                }];
                
                [alert addAction: exitBtn];
                [alert addAction: collectAndReadBtn];
                
                [self presentViewController: alert animated: YES completion: nil];
            }
        }
    } else if (lastContentOffset > scrollView.contentOffset.x) {
        NSLog(@"moved left");
    } else {
        NSLog(@"didn't move");
    }
}
 */

#pragma mark - Collect & Download Book
//改變成擁有
-(void)own{
    /*
     [_openbtn setTitle:NSLocalizedString(@"Works-viewAlbum", @"") forState:UIControlStateNormal];
     [_openbtn setImage:[UIImage imageNamed:@"button_open.png"] forState:UIControlStateNormal];
     [_openbtn setImage:[UIImage imageNamed:@"button_open_click.png"] forState:UIControlStateHighlighted];
     [_openbtn setImage:[UIImage imageNamed:@"button_open_click.png"] forState:UIControlStateSelected];
     */
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary: _dic];
    NSMutableDictionary *album = [[NSMutableDictionary alloc] initWithDictionary: _dic[@"album"]];
    
    [album setObject: [NSNumber numberWithBool: YES] forKey: @"own"];
    [dictionary setObject: album forKey: @"album"];
    
    _dic = dictionary;
}


- (void)collectAndDowloadBook
{
    //[wTools ShowMBProgressHUD];
    [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString * Pointstr=[boxAPI geturpoints:[wTools getUserID] token:[wTools getUserToken]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[wTools HideMBProgressHUD];
            [MBProgressHUD hideHUDForView: self.view animated: YES];
            
            NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[Pointstr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            
            if ([_dic[@"album"][@"point"] intValue]==0) {
                NSLog(@"收藏相本");
                
                PreviewbookViewController *rv=[[PreviewbookViewController alloc]initWithNibName:@"PreviewbookViewController" bundle:nil];
                rv.albumid=_albumid;
                rv.userbook=@"N";
                
                [self own];
                [self.navigationController pushViewController:rv animated:YES];
                
                // Check whether taskType is createAlbum or collectAlbum
                // Because, these two type will go to the same view controller - BookViewController
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                task_for = @"collect_free_album";
                [defaults setObject: task_for forKey: @"task_for"];
                [defaults synchronize];
            } else {
                //是否足夠
                if ([_dic[@"album"][@"point"] intValue]>[dic[@"data"] intValue]) {
                    Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
                    [rv addtitletext:NSLocalizedString(@"Works-tipAskP", @"")];
                    [rv addSelectBtntext:NSLocalizedString(@"GeneralText-yes", @"") btn2:NSLocalizedString(@"GeneralText-no", @"") ];
                    [rv showView:self.view];
                    
                    rv.btn1select=^(BOOL bo){
                        if (bo) {
                            CurrencyViewController *cvc=[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"CurrencyViewController"];
                            
                            [self.navigationController pushViewController:cvc animated:YES];
                        }
                    };
                } else {                    
                    //可以購買
                    Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
                    [rv addtitletext:[NSString stringWithFormat:@"%@(%d P)",NSLocalizedString(@"Works-tipConfirmGetIt", @""),[_dic[@"album"][@"point"] intValue]]];
                    [rv addSelectBtntext:NSLocalizedString(@"GeneralText-yes", @"") btn2:NSLocalizedString(@"GeneralText-no", @"") ];
                    [rv showView:self.view];
                    rv.btn1select = ^(BOOL bo){
                        
                        if (bo) {
                            PreviewbookViewController *rv=[[PreviewbookViewController alloc]initWithNibName:@"PreviewbookViewController" bundle:nil];
                            rv.albumid=_albumid;
                            rv.userbook=@"N";
                            
                            [self own];
                            [self.navigationController pushViewController:rv animated:YES];
                            
                            
                            // Check whether taskType is createAlbum or collectAlbum
                            // Because, these two type will go to the same view controller - BookViewController
                            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                            task_for = @"collect_pay_album";
                            [defaults setObject: task_for forKey: @"task_for"];
                            [defaults synchronize];
                        }
                    };
                }
            }
        });
    });
}

#pragma mark -
#pragma Video Section

-(void)videoembed:(UIButton *)btn{
    NSLog(@"videoEmbed");
    
    NSURL *url = [NSURL URLWithString: datalist[btn.tag][@"video_target"]];
    NSLog(@"url: %@", url);
    
    NSLog(@"scheme: %@", [url scheme]);
    NSLog(@"host: %@", [url host]);
    NSLog(@"port: %@", [url port]);
    NSLog(@"path: %@", [url path]);
    NSLog(@"path components: %@", [url pathComponents]);
    NSLog(@"parameterString: %@", [url parameterString]);
    NSLog(@"query: %@", [url query]);
    NSLog(@"fragment: %@", [url fragment]);
    
    if (!([[url host] rangeOfString: @"vimeo"].location == NSNotFound)) {
        NSLog(@"url contains vimeo");
        
        [[YTVimeoExtractor sharedExtractor] fetchVideoWithVimeoURL: datalist[btn.tag][@"video_target"] withReferer: nil completionHandler:^(YTVimeoVideo * _Nullable video, NSError * _Nullable error) {
            if (video) {
                NSURL *highQualityURL = [video highestQualityStreamURL];
                AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL: highQualityURL];
                AVPlayer *player = [AVPlayer playerWithPlayerItem: playerItem];
                AVPlayerViewController *playerViewController = [AVPlayerViewController new];
                playerViewController.player = player;
                
                // Play video automatically when presenting AVPlayerViewController
                [player play];
                
                [self presentViewController: playerViewController animated: YES completion: nil];
            }
        }];
    }
    
    if (!([[url host] rangeOfString: @"facebook"].location == NSNotFound)) {
        NSLog(@"url host contains facebook");
        
        [self checkFBSDK: url];
    }
    if (!([[url host] rangeOfString: @"youtube"].location == NSNotFound)) {
        NSLog(@"url host contains youtube");
        
        YoutubeViewController *yv = [[YoutubeViewController alloc] initWithNibName: @"YoutubeViewController" bundle: nil];
        
        yv.url = datalist[btn.tag][@"video_target"];
        //yv.url = urlString;
        yv.bookVC = self;
        
        NSLog(@"yv.url: %@", yv.url);
        
        [self presentViewController:yv animated:YES completion:nil];
    }
}

- (void)checkFBSDK:(NSURL *)url
{
    NSLog(@"checkFBSDK");
    
    // Section Below is to check FBSDK
    
    //NSDictionary *parametersDic = [[NSDictionary alloc] initWithObjectsAndKeys: @"id,source", @"fields", nil];
    NSString *videoStr;
    
    NSCharacterSet *notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    
    for (NSString *str in [url pathComponents]) {
        NSLog(@"str: %@", str);
        
        // Check which string section is all decimal
        if ([str rangeOfCharacterFromSet: notDigits].location == NSNotFound) {
            NSLog(@"str: %@", str);
            
            videoStr = str;
        }
    }
    
    __block NSString *fbVideoLink;
    
    NSLog(@"fbVideoLink: %@", fbVideoLink);
    NSLog(@"Before getting token");
    
    if ([FBSDKAccessToken currentAccessToken]) {
        NSLog(@"FBSDKAccessToken currentAccessToken");
        
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath: videoStr parameters: @{@"fields" : @"id,source"} HTTPMethod: @"GET"];
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (connection) {
                NSLog(@"result: %@", result);
                
                if (result != nil) {
                    NSLog(@"result is null");
                    
                    fbVideoLink = [result objectForKey: @"source"];
                    NSLog(@"fbVideoLink: %@", fbVideoLink);
                    
                    NSURL *videoURL = [NSURL URLWithString: fbVideoLink];
                    
                    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL: videoURL];
                    AVPlayer *player = [AVPlayer playerWithPlayerItem: playerItem];
                    AVPlayerViewController *playerViewController = [AVPlayerViewController new];
                    playerViewController.player = player;
                    
                    // Play video automatically when presenting AVPlayerViewController
                    [player play];
                    
                    [self presentViewController: playerViewController animated: YES completion: nil];
                } else if (result == nil) {
                    [self openSafari: url];
                    
                    //[[UIApplication sharedApplication] openURL: url];
                }
            } else if (!connection) {
                NSLog(@"Get Video Error");
            }
        }];
    } else {
        NSLog(@"login with permissions");
        
        // Try to login with permissions
        [self loginAndRequestPermissionsWithSuccessHandler:^{
            NSLog(@"loginAndRequestPermissionsWithSuccessHandler");
            
            FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath: videoStr parameters: @{@"fields" : @"id,source"} HTTPMethod: @"GET"];
            [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                if (connection) {
                    NSLog(@"result: %@", result);
                    
                    if (result != nil) {
                        NSLog(@"result is null");
                        
                        fbVideoLink = [result objectForKey: @"source"];
                        NSLog(@"fbVideoLink: %@", fbVideoLink);
                        
                        NSURL *videoURL = [NSURL URLWithString: fbVideoLink];
                        
                        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL: videoURL];
                        AVPlayer *player = [AVPlayer playerWithPlayerItem: playerItem];
                        AVPlayerViewController *playerViewController = [AVPlayerViewController new];
                        playerViewController.player = player;
                        
                        // Play video automatically when presenting AVPlayerViewController
                        [player play];
                        
                        [self presentViewController: playerViewController animated: YES completion: nil];
                    } else if (result == nil) {
                        [self openSafari: url];
                        
                        //[[UIApplication sharedApplication] openURL: url];
                    }
                } else if (!connection) {
                    NSLog(@"Get Video Error");
                }
            }];
        } declinedOrCanceledHandler:^{
            NSLog(@"declinedOrCanceledHandler");
            
            // If the user declined permissions tell them why we need permissions
            // and ask for permissions again if they want to grant permissions.
            [self alertDeclinedPublishActionsWithCompletion:^{
                [self loginAndRequestPermissionsWithSuccessHandler: nil
                                         declinedOrCanceledHandler: nil
                                                      errorHandler:^(NSError * error) {
                                                          NSLog(@"Error: %@", error.description);
                                                      }];
            }];
        } errorHandler:^(NSError * error) {
            NSLog(@"Error: %@", error.description);
        }];
    }
}

#pragma mark - FaceBook Handler Methods
- (void)loginAndRequestPermissionsWithSuccessHandler:(FBBlock) successHandler
                           declinedOrCanceledHandler:(FBBlock) declinedOrCanceledHandler
                                        errorHandler:(void (^)(NSError *)) errorHandler
{
    NSLog(@"loginAndRequestPermissionsWithSuccessHandler Method");
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logInWithReadPermissions: @[@"user_videos"] fromViewController: self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        
        NSLog(@"result: %@", result);
        
        if (result == nil) {
            NSLog(@"result is null");
        }
        
        if (error) {
            if (errorHandler) {
                errorHandler(error);
            }
            return;
        }
        
        if ([FBSDKAccessToken currentAccessToken]) {
            
            NSLog(@"FBSDKAccessToken currentAccessToken");
            
            if (successHandler) {
                NSLog(@"successHandler");
                successHandler();
            }
            return;
        }
        if (declinedOrCanceledHandler) {
            NSLog(@"declinedOrCanceledHandler");
            declinedOrCanceledHandler();
        }
    }];
}

- (void)alertDeclinedPublishActionsWithCompletion:(FBBlock)completion
{
    NSLog(@"alertDeclinedPublishActionsWithCompletion");
    /*
    UIAlertView *alertViewForFB = [[UIAlertView alloc] initWithTitle:@"Publish Permissions"
                                                             message:@"Publish permissions are needed to share game content automatically. Do you want to enable publish permissions?"
                                                            delegate:self
                                                   cancelButtonTitle:@"No"
                                                   otherButtonTitles:@"Ok", nil];
    [alertViewForFB show];
     */
}

#pragma mark - Open Safari
- (void)openSafari: (NSURL *)url
{
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL: url entersReaderIfAvailable: NO];
    safariVC.preferredBarTintColor = [UIColor whiteColor];
    [self presentViewController: safariVC animated: YES completion: nil];
}

-(void)videofile:(UIButton *)btn{
    NSLog(@"videoFile");
    
    /*
    VideoViewController *vv=[[VideoViewController alloc]initWithNibName:@"VideoViewController" bundle:nil];
    NSString *videoPath=[file stringByAppendingPathComponent:datalist[btn.tag][@"video_target"]];
    vv.videofile=videoPath;
    
    [self presentViewController:vv animated:YES completion:nil];
    */
    
    NSURL *videoURL;
    
    if (![_dic isKindOfClass: [NSNull class]]) {
        NSLog(@"dic is not kind of NSNull class");
        
        NSString *urlString = datalist[btn.tag][@"video_target"];
        NSLog(@"urlString: %@", urlString);
        
        NSString *httpStr = @"http";
        
        if ([urlString rangeOfString: httpStr].location == NSNotFound) {
            NSLog(@"urlString does not contain http");            
            urlString = [file stringByAppendingPathComponent:datalist[btn.tag][@"video_target"]];
            videoURL = [NSURL fileURLWithPath: urlString];
        } else {
            NSLog(@"urlString contains http");
            videoURL = [NSURL URLWithString: urlString];
        }
    } else {
        NSLog(@"dic is kind of NSNull class");
        NSString *urlString = [file stringByAppendingPathComponent:datalist[btn.tag][@"video_target"]];
        NSLog(@"urlString: %@", urlString);
        videoURL = [NSURL fileURLWithPath: urlString];
    }
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL: videoURL];
    AVPlayer *player = [AVPlayer playerWithPlayerItem: playerItem];
    AVPlayerViewController *playerViewController = [AVPlayerViewController new];
    playerViewController.player = player;
    
    // Play video automatically when presenting AVPlayerViewController
    [player play];
    
    [self presentViewController: playerViewController animated: YES completion: nil];
    
    // The music is playing
    // At the beginning, audioSwitch is On, after pressing will be set to NO;
    if (!_audioSwitch) {
        NSLog(@"bookVC.audioSwitch is ON");
        _videoPlay = YES;
        
        [self playCheck: nil];
    }
}


#pragma mark -
#pragma mark Plist Methods

- (void)writePlist: (NSString *)pid type: (NSString *)type
{
    NSLog(@"writePlist");
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex: 0];
    NSString *filePath = [documentsDirectory stringByAppendingString: @"/GiftData.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableDictionary *data;
    NSMutableDictionary *dict;
    NSMutableArray *pidArrayForSlotPressed;
    NSMutableArray *pidArrayForGiftExchanged;
    
    if ([fileManager fileExistsAtPath: filePath]) {
        NSLog(@"file exists");
        data = [[NSMutableDictionary alloc] initWithContentsOfFile: filePath];
        //NSLog(@"data: %@", data);
        
        dict = [data objectForKey: _albumid];
        //NSLog(@"dict: %@", dict);
        
        pidArrayForSlotPressed = [dict objectForKey: @"slot"];
        NSLog(@"pidArrayForSlotPressed: %@", pidArrayForSlotPressed);
        
        pidArrayForGiftExchanged = [dict objectForKey: @"gift"];
        NSLog(@"pidArrayForGiftExchanged: %@", pidArrayForGiftExchanged);
        
        if (dict == NULL) {
            NSLog(@"if dict is null then needs to realloate it, because the albumId is a new one");
            dict = [[NSMutableDictionary alloc] init];
        }
        if (pidArrayForSlotPressed == NULL) {
            NSLog(@"if pidArrayForSlotPressed is null then needs to realloate it, because the albumId is a new one or data is empty");
            pidArrayForSlotPressed = [[NSMutableArray alloc] init];
        }
        if (pidArrayForGiftExchanged == NULL) {
            NSLog(@"if pidArrayForGiftExchanged is null then needs to realloate it, because the albumId is a new one or data is empty");
            pidArrayForGiftExchanged = [[NSMutableArray alloc] init];
        }
        
    } else {
        NSLog(@"file does not exist");
        data = [[NSMutableDictionary alloc] init];
        dict = [[NSMutableDictionary alloc] init];
        pidArrayForSlotPressed = [[NSMutableArray alloc] init];
        pidArrayForGiftExchanged = [[NSMutableArray alloc] init];
    }
    
    if ([type isEqualToString: @"slot"]) {
        NSLog(@"type: %@", type);
        
        NSLog(@"pid: %@", pid);
        
        // Load information of gift
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *giftImage = [defaults objectForKey: @"giftImage"];
        NSString *giftName = [defaults objectForKey: @"giftName"];
        NSString *photoDescription = [defaults objectForKey: @"photoDescription"];
        NSString *photoUseForUserId = [defaults objectForKey: @"photoUseForUserId"];
        
        NSLog(@"giftImage: %@", giftImage);
        NSLog(@"giftName: %@", giftName);
        NSLog(@"photoDescription: %@", photoDescription);
        NSLog(@"photoUseForUserId: %@", photoUseForUserId);
        
        NSDictionary *imageDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   giftImage, @"giftImage",
                                   giftName, @"giftName",
                                   photoDescription, @"photoDescription",
                                   photoUseForUserId, @"photoUseForUserId",
                                   nil];
        
        //NSLog(@"imageDict: %@", imageDict);
        
        NSDictionary *pidImageDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                      imageDict, pid, nil];
        
        [pidArrayForSlotPressed addObject: pidImageDict];
        //[pidArrayForSlotPressed addObject: pid];
        //NSLog(@"pidArrayForSlotPressed: %@", pidArrayForSlotPressed);
        
        [dict setValue: pidArrayForSlotPressed forKey: @"slot"];
        //NSLog(@"dict: %@", dict);
        
        [data setValue: dict forKey: _albumid];
        //NSLog(@"data: %@", data);
        
    } else if ([type isEqualToString: @"gift"]) {
        NSLog(@"type: %@", type);
        
        NSLog(@"pid: %@", pid);
        
        [pidArrayForGiftExchanged addObject: pid];
        //NSLog(@"pidArrayForGiftExchanged: %@", pidArrayForGiftExchanged);
        
        [dict setValue: pidArrayForGiftExchanged forKey: @"gift"];
        //NSLog(@"dict: %@", dict);
        
        [data setValue: dict forKey: _albumid];
        //NSLog(@"data: %@", data);
    }
    
    if ([data writeToFile: filePath atomically: YES]) {
        NSLog(@"Data saving is successful");
    } else {
        NSLog(@"Data saving is failed");
    }
   
    /*
    NSLog(@"pid: %@", pid);
    NSLog(@"pidArrayForSlotPressed: %@", pidArrayForSlotPressed);
    NSLog(@"pidArrayForGiftExchanged: %@", pidArrayForGiftExchanged);
    NSLog(@"dict: %@", dict);
    NSLog(@"data: %@", data);
     */
}

- (NSArray *)readPlist: (NSString *)type
{
    NSLog(@"readPlist");
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex: 0];
    NSString *filePath = [documentsDirectory stringByAppendingString: @"/GiftData.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *array;
    NSDictionary *dict;
    
    if ([fileManager fileExistsAtPath: filePath]) {
        NSDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile: filePath];
        
        //NSLog(@"albumId: %@", _albumid);
        //NSLog(@"data: %@", data);
        
        dict = [data objectForKey: _albumid];
        //NSLog(@"dict: %@", dict);
        
        if ([type isEqualToString: @"slot"]) {
            NSLog(@"if type is slot");
            array = [dict objectForKey: @"slot"];
            //NSLog(@"slot array: %@", array);
            
        } else if ([type isEqualToString: @"gift"]) {
            NSLog(@"if type is gift");
            array = [dict objectForKey: @"gift"];
            //NSLog(@"gift array: %@", array);
        }
        
    } else {
        NSLog(@"No data, reading failed");
    }
    
    return array;
}

#pragma mark -
#pragma mark Gift Related Methods

//拉霸
-(void)showSlot:(UIButton *)btn {
    
    NSLog(@"show slot");
    
    // Button is hidden when pressing slot picture
    btn.hidden = YES;
    
    NSMutableArray *array = [NSMutableArray new];
    
    for (int i = 0; i < 8; i++) {
        UIImage *image = [UIImage imageNamed: [NSString stringWithFormat: @"gift_0000%i.png", i]];
        [array addObject: image];
    }
    
    UIImageView *animatimageview;
    animatimageview = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 180, 200)];
    //animatimageview.center = CGPointMake(self.view.bounds.size.width / 2, showview.frame.origin.y + vc.frame.size.height / 2);
    animatimageview.center = CGPointMake(mySV.bounds.size.width / 2, mySV.bounds.size.height / 2);
    animatimageview.contentMode = UIViewContentModeScaleAspectFill;
    animatimageview.animationImages = array;
    animatimageview.animationDuration = 1.0;
    animatimageview.animationRepeatCount = 1;
    
    // Getting the current scrollview page
    NSLog(@"contentOffset.x: %f", mySV.contentOffset.x);
    NSLog(@"scrollview.frame.size.width: %f", mySV.frame.size.width);
    
    int page = mySV.contentOffset.x / mySV.frame.size.width;
    NSLog(@"page: %d", page);
    
    UIView *back = [[UIView alloc] initWithFrame: CGRectMake(mySV.bounds.size.width * page, 0, mySV.bounds.size.width, mySV.bounds.size.height)];
    [back addSubview: animatimageview];
    [mySV addSubview: back];
    
    /*
     UIView *back = [[UIView alloc] initWithFrame: self.view.bounds];
     [back addSubview: animatimageview];
     [self.view addSubview: back];
     */
    
    /*
     UIView *v = [[UIView alloc] initWithFrame: CGRectMake(vc.bounds.size.width * pageNumber, 0, vc.bounds.size.width, vc.bounds.size.height)];
     
     NSLog(@"slot x: %f", v.frame.origin.x);
     
     [v addSubview: animatimageview];
     */
    tmpbtn = btn;
    //tmpview = back;
    
    [animatimageview startAnimating];
    
    // Adding gap time after animation is finished
    while ([animatimageview isAnimating]) {
        [[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.05]];
    }
    
    // Button is appeared when animation is finished
    btn.hidden = NO;
    [back removeFromSuperview];
    
    
    // Call Protocol 42
    //[wTools ShowMBProgressHUD];
    [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        int wNowPage = [mySV getNowPage:2];
        NSLog(@"wNowPage: %d", wNowPage);
        
        NSString *pid = [datalist[wNowPage][@"photo_id"] stringValue];
        
        NSString *response;
        
        if ([wTools getUUID]) {
            response = [boxAPI getPhotoUseForUser: [wTools getUserID] token: [wTools getUserToken] photo_id: pid identifier: [OpenUDID value]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (response != nil) {
                NSLog(@"%@", response);
                
                NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                if ([data[@"result"] intValue] == 1) {
                    //[wTools HideMBProgressHUD];
                    [MBProgressHUD hideHUDForView: self.view animated: YES];
                    
                    // Success
                    NSLog(@"Success");
                    
                    NSString *giftImage = data[@"data"][@"photousefor"][@"image"];
                    NSLog(@"image: %@", giftImage);
                    
                    NSString *giftName = data[@"data"][@"photousefor"][@"name"];
                    NSLog(@"name: %@", giftName);
                    
                    NSString *photoUseForUserId = data[@"data"][@"photousefor_user"][@"photousefor_user_id"];
                    NSLog(@"photoUseForUserID: %@", photoUseForUserId);
                    
                    NSString *photoDescription = data[@"data"][@"photousefor"][@"description"];
                    NSLog(@"photoDescription: %@", photoDescription);
                    
                    // Slot can only play once
                    /*
                    BOOL slotPressed = YES;
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject: [NSNumber numberWithBool: slotPressed] forKey: @"slotPressed"];
                    */
                    
                    // Save Information of Gifts
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject: giftImage forKey: @"giftImage"];
                    [defaults setObject: giftName forKey: @"giftName"];
                    [defaults setObject: photoUseForUserId forKey: @"photoUseForUserId"];
                    [defaults setObject: photoDescription forKey: @"photoDescription"];
                    [defaults synchronize];
                    
                    NSLog(@"save plist information for slot");
                    [self writePlist: pid type: @"slot"];
                    
                    NSLog(@"page for Slot Press");
                    
                    // Gift View
                    giftView = [[UIView alloc] initWithFrame: CGRectMake(mySV.bounds.size.width * page, 0, mySV.bounds.size.width, mySV.bounds.size.height)];
                    
                    // Show the exchange image
                    exchangeButton = [wTools W_Button: self frame: CGRectMake(giftView.bounds.size.width - 100 * 1.0, giftView.bounds.size.height - 100 * 1.0, 100 * 1.0, 100 * 1.0) imgname: @"icon_exchange.png" SELL: @selector(showGift) tag: page];
                    [exchangeButton setImage: [UIImage imageNamed: @"icon_exchange_click.png"] forState:UIControlStateHighlighted];
                    exchangeButton.tag = page;
                    NSLog(@"exchangeButton: %@", exchangeButton);
                    NSLog(@"exchangeButton tag: %ld", (long)exchangeButton.tag);
                    
                    [giftView addSubview: exchangeButton];
                    
                    // Show exchange label
                    exchangeLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 100, 26)];
                    exchangeLabel.center = CGPointMake(exchangeButton.center.x + 15, exchangeButton.center.y + 26);
                    exchangeLabel.textAlignment = 1;
                    exchangeLabel.text = @"兌 換";
                    exchangeLabel.font = [UIFont systemFontOfSize: 22];
                    exchangeLabel.textColor = [UIColor whiteColor];
                    exchangeLabel.tag = page;
                    NSLog(@"exchangeLabel: %@", exchangeLabel);
                    NSLog(@"exchangeLabel tag: %ld", (long)exchangeLabel.tag);
                    
                    [giftView addSubview: exchangeLabel];
                    
                    [mySV addSubview: giftView];
                    
                    btn.hidden = YES;
                    
                } else if ([data[@"result"] intValue] == 2) {
                    //[wTools HideMBProgressHUD];
                    [MBProgressHUD hideHUDForView: self.view animated: YES];
                    
                    // 兌換 / 拉霸的對象已被領取
                    NSLog(@"兌換 / 拉霸的對象已被領取");
                    
                    // Remind: Alert Message Function
                    Remind *rv = [[Remind alloc] initWithFrame: self.view.bounds];
                    [rv addtitletext: @"兌換 / 拉霸的對象已被領取"];
                    [rv addBackTouch];
                    [rv showView: self.view];
                    
                    return;
                    
                } else if ([data[@"result"] intValue] == 3) {
                    //[wTools HideMBProgressHUD];
                    [MBProgressHUD hideHUDForView: self.view animated: YES];
                    
                    // 兌換 / 拉霸的對象數量已用盡
                    NSLog(@"兌換 / 拉霸的對象數量已用盡");
                    
                    // Remind: Alert Message Function
                    Remind *rv = [[Remind alloc] initWithFrame: self.view.bounds];
                    [rv addtitletext: @"兌換 / 拉霸的對象數量已用盡"];
                    [rv addBackTouch];
                    [rv showView: self.view];
                    
                    return;
                    
                } else if ([data[@"result"] intValue] == 0) {
                    //[wTools HideMBProgressHUD];
                    [MBProgressHUD hideHUDForView: self.view animated: YES];
                    NSLog(@"Fail");
                } else {
                    [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                }
            }
        });
    });
}

- (void)showGift
{
    NSLog(@"show slot gift");
    
    //mySV.scrollEnabled = NO;
    
    //[exchangeButton setUserInteractionEnabled: NO];
    
    int page = mySV.contentOffset.x / mySV.frame.size.width;
    NSLog(@"page: %d", page);
    
    // Gift View
    giftView = [[UIView alloc] initWithFrame: CGRectMake(mySV.bounds.size.width * page, 0, mySV.bounds.size.width, mySV.bounds.size.height)];
    giftView.tag = 1234;
    
    [self showAlertViewForGift];
    
    [self checkSubViews];
    
    [mySV addSubview: giftView];
}

#pragma mark -
#pragma mark Show Alert View Before Gift Exchanged

- (void)showAlertViewForGift
{
    NSLog(@"showAlertViewForGift");
    
    CustomIOSAlertView *alertViewForGift = [[CustomIOSAlertView alloc] init];
    [alertViewForGift setContainerView: [self createViewForGift]];
    [alertViewForGift setButtonTitles: [NSMutableArray arrayWithObjects: @"否", @"是", nil]];
    [alertViewForGift setOnButtonTouchUpInside:^(CustomIOSAlertView *alertViewForGift, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertViewForGift tag]);
        [alertViewForGift close];
        
        if (buttonIndex == 0) {
            [giftView removeFromSuperview];
        } else if (buttonIndex == 1) {
            [self pressYes];
        }
    }];
    [alertViewForGift setUseMotionEffects: true];
    [alertViewForGift show];
}

- (UIView *)createViewForGift
{
    /*
    // Load information of gift
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *giftImage = [defaults objectForKey: @"giftImage"];
    NSString *giftName = [defaults objectForKey: @"giftName"];
    NSString *photoDescription = [defaults objectForKey: @"photoDescription"];
    */

    int page = mySV.contentOffset.x / mySV.frame.size.width;
    NSLog(@"page: %d", page);
    NSString *pid = [datalist[page][@"photo_id"] stringValue];
    NSArray *slotArray = [self readPlist: @"slot"];
    NSDictionary *imageDict;
    
    for (NSDictionary *dict in slotArray) {
        for (NSString *str in [dict allKeys]) {
            if ([str isEqualToString: pid]) {
                NSLog(@"dict match pid: %@", dict);
                imageDict = [dict objectForKey: pid];
            }
        }
    }
    
    NSLog(@"imageDict: %@", imageDict);
    
    NSString *giftImage = [imageDict objectForKey: @"giftImage"];
    NSString *giftName = [imageDict objectForKey: @"giftName"];
    NSString *photoDescription = [imageDict objectForKey: @"photoDescription"];
    
    NSLog(@"giftImage: %@", giftImage);
    NSLog(@"giftName: %@", giftName);
    NSLog(@"photoDescription: %@", photoDescription);
    
    UIView *gv = [[UIView alloc] initWithFrame: CGRectMake(0, 0, mySV.bounds.size.width - 30, mySV.bounds.size.height - 70)];
    
    NSLog(@"mySV.bounds.size.width: %f", mySV.bounds.size.width);
    NSLog(@"mySV.bounds.size.height: %f", mySV.bounds.size.height);
    
    UILabel *giftTopicLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 10, gv.bounds.size.width, 20)];
    giftTopicLabel.text = giftName;
    giftTopicLabel.textAlignment = NSTextAlignmentCenter;
    [gv addSubview: giftTopicLabel];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 60, 250, 250)];
    imageView.image = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString: giftImage]]];
    imageView.center = CGPointMake(gv.bounds.size.width / 2, gv.bounds.size.height / 2 - 40);
    imageView.layer.cornerRadius = 10;
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [gv addSubview: imageView];
    
    UILabel *giftMessageLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, gv.bounds.size.height / 2 + 90, gv.bounds.size.width, 100)];
    giftMessageLabel.text = photoDescription;
    giftMessageLabel.textAlignment = NSTextAlignmentCenter;
    giftMessageLabel.numberOfLines = 0;
    giftMessageLabel.adjustsFontSizeToFitWidth = YES;
    giftMessageLabel.font = [UIFont systemFontOfSize: 15];
    [gv addSubview: giftMessageLabel];
    
    return gv;
}

#pragma mark -

- (void)pressYes
{
    NSLog(@"Press Yes");
    
    // Avoid more than 1 time tapping
    //btn.userInteractionEnabled = NO;
    
    // Call Protocol 43
    //[wTools ShowMBProgressHUD];
    [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    
    // Load information of gift
    int page = mySV.contentOffset.x / mySV.frame.size.width;
    NSLog(@"page: %d", page);
    
    NSString *pid = [datalist[page][@"photo_id"] stringValue];
    NSArray *slotArray = [self readPlist: @"slot"];
    NSDictionary *imageDict;
    
    for (NSDictionary *dict in slotArray) {
        for (NSString *str in [dict allKeys]) {
            if ([str isEqualToString: pid]) {
                NSLog(@"dict match pid: %@", dict);
                imageDict = [dict objectForKey: pid];
            }
        }
    }
    
    NSLog(@"imageDict: %@", imageDict);
    
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //NSString *photoUseForUserId = [defaults objectForKey: @"photoUseForUserId"];
    NSString *photoUseForUserId = [imageDict objectForKey: @"photoUseForUserId"];
    
    NSLog(@"兌換");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI updatePhotoUseForUser: [wTools getUserID] token: [wTools getUserToken] photoUseForUserId: photoUseForUserId];
        
        NSLog(@"id: %@", [wTools getUserID]);
        NSLog(@"token: %@", [wTools getUserToken]);
        NSLog(@"photoUseForUserId: %@", photoUseForUserId);
        
        int wNowPage = [mySV getNowPage:2];
        NSLog(@"wNowPage: %d", wNowPage);
        //NSString *pid = [datalist[wNowPage][@"photo_id"] stringValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (response != nil) {
                NSLog(@"兌換 response: %@", response);
                
                NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                if ([data[@"result"] intValue] == 1) {
                    //[wTools HideMBProgressHUD];
                    [MBProgressHUD hideHUDForView: self.view animated: YES];
                    // Success
                    NSLog(@"兌換 Success");
                    NSLog(@"check subViews & Set up");
                    
                    UIButton *btn;
                    
                    for (UIView *addedView in mySV.subviews) {
                        for (UIView *sub in [addedView subviews]) {
                            if ([sub isKindOfClass: [UIButton class]]) {
                                btn = (UIButton *)sub;
                                
                                NSLog(@"List all the buttons");
                                NSLog(@"btn: %@", btn);
                                
                                if (btn.tag == page) {
                                    
                                    NSLog(@"List button matches page");
                                    NSLog(@"page: %d", page);
                                    NSLog(@"btn.tag == page");
                                    NSLog(@"btn.tag: %ld", (long)btn.tag);
                                    NSLog(@"btn: %@", btn);
                                    [btn setImage: [UIImage imageNamed: @"icon_exchanged.png"] forState: UIControlStateNormal];
                                }
                            }
                            if ([sub isKindOfClass: [UILabel class]]) {
                                UILabel *label = (UILabel *)sub;
                                
                                NSLog(@"List all the labels");
                                NSLog(@"label: %@", label);
                                
                                if (label.tag == page) {
                                    
                                    NSLog(@"List label matches page");
                                    NSLog(@"page: %d", page);
                                    NSLog(@"label.tag == page");
                                    NSLog(@"label.tag: %ld", (long)label.tag);
                                    
                                    label.text = @"已兌換";
                                    NSLog(@"label: %@", label);
                                }
                            }
                        }
                    }
                    
                    [self showAlertViewForExchange];
                    
                    // Save data about gift is already exchanged
                    NSLog(@"save plist information for gift");
                    [self writePlist: pid type: @"gift"];
                    
                } else if ([data[@"result"] intValue] == 2) {
                    //[wTools HideMBProgressHUD];
                    [MBProgressHUD hideHUDForView: self.view animated: YES];
                    
                    // 兌換 / 拉霸的對象數量已用盡或已被領取
                    NSLog(@"兌換 / 拉霸的對象數量已用盡或已被領取");
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"" message: @"兌換 / 拉霸的對象數量已用盡或已被領取" preferredStyle: UIAlertControllerStyleAlert];
                    
                    UIAlertAction *okBtn = [UIAlertAction actionWithTitle: @"OK" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        NSLog(@"OK");
                        [giftView removeFromSuperview];
                    }];
                    
                    [alert addAction: okBtn];
                    [self presentViewController: alert animated: YES completion: nil];
                    
                } else if ([data[@"result"] intValue] == 0) {
                    //[wTools HideMBProgressHUD];
                    [MBProgressHUD hideHUDForView: self.view animated: YES];
                    
                    NSLog(@"Fail");
                } else {
                    [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                }
            }
        });
    });
}

- (void)checkSubViews
{
    NSLog(@"check subViews");
    
    int page = mySV.contentOffset.x / mySV.frame.size.width;
    NSLog(@"page: %d", page);
    
    for (UIView *addedView in mySV.subviews) {
        for (UIView *sub in [addedView subviews]) {
            if ([sub isKindOfClass: [UIButton class]]) {
                UIButton *btn = (UIButton *)sub;
                
                NSLog(@"List all the buttons");
                NSLog(@"btn: %@", btn);
                
                if (btn.tag == page) {
                    NSLog(@"List button matches page");
                    NSLog(@"page: %d", page);
                    NSLog(@"btn.tag == page");
                    NSLog(@"btn.tag: %ld", (long)btn.tag);
                    NSLog(@"btn: %@", btn);
                }
                
                if (btn.tag == 55) {
                    if (isplayaudio) {
                        [btn setImage: [UIImage imageNamed: @"icon_audioswitch_open_white_75x75"] forState: UIControlStateNormal];
                    } else {
                        [btn setImage: [UIImage imageNamed: @"icon_audioswitch_close_white_75x75"] forState: UIControlStateNormal];
                    }
                }
            }
            if ([sub isKindOfClass: [UILabel class]]) {
                UILabel *label = (UILabel *)sub;
                
                NSLog(@"List all the labels");
                NSLog(@"label: %@", label);
                
                if (label.tag == page) {
                    NSLog(@"List label matches page");
                    NSLog(@"page: %d", page);
                    NSLog(@"label.tag == page");
                    NSLog(@"label.tag: %ld", (long)label.tag);
                    NSLog(@"label: %@", label);
                }
            }
        }
    }
}

#pragma mark -
#pragma mark Show Alert View After Gift Exchanged

- (void)showAlertViewForExchange
{
    NSLog(@"showAlertViewForExchange");
    
    int page = mySV.contentOffset.x / mySV.frame.size.width;
    NSLog(@"page: %d", page);
    NSString *pid = [datalist[page][@"photo_id"] stringValue];
    NSArray *slotArray = [self readPlist: @"slot"];
    NSDictionary *imageDict;
    
    for (NSDictionary *dict in slotArray) {
        for (NSString *str in [dict allKeys]) {
            if ([str isEqualToString: pid]) {
                NSLog(@"dict match pid: %@", dict);
                imageDict = [dict objectForKey: pid];
            }
        }
    }
    
    NSLog(@"imageDict: %@", imageDict);
    
    NSString *giftImage = [imageDict objectForKey: @"giftImage"];
    NSLog(@"giftImage: %@", giftImage);
    
    for (UIView *addedView in mySV.subviews) {
        for (UIView *sub in [addedView subviews]) {
            if ([sub isKindOfClass: [UIImageView class]]) {
                UIImageView *imageView = (UIImageView *)sub;
                NSLog(@"imageView: %@", imageView);
                NSString *imageName = imageView.accessibilityIdentifier;
                NSLog(@"imageName: %@", imageName);
                
                NSString *fileName = [[imageName lastPathComponent] stringByDeletingPathExtension];
                NSLog(@"fileName: %@", fileName);
                
                if ([fileName intValue] == page) {
                    //imageView.image = [UIImage imageNamed: @"05"];
                    imageView.image = [self getImageFromURL: giftImage];
                    NSLog(@"imageName: %@", imageName);
                    
                    fileNameForDeletion = imageName;
                    NSLog(@"fileNameForDeletion: %@", fileNameForDeletion);
                }
            }
        }
    }
    
    alertViewForExchange = [[CustomIOSAlertView alloc] init];
    [alertViewForExchange setContainerView: [self createViewForExchange]];
    [alertViewForExchange setButtonTitles: [NSMutableArray arrayWithObjects: @"已兌換", nil]];
    
    __weak typeof(self) weakSelf = self;
    
    [alertViewForExchange setOnButtonTouchUpInside:^(CustomIOSAlertView *alertViewForExchange, int buttonIndex) {
        
        typeof(weakSelf) __strong strongSelf = weakSelf;
        
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[strongSelf->alertViewForExchange tag]);
        [strongSelf->timer invalidate];
        [strongSelf->alertViewForExchange close];
        
        if (buttonIndex == 0) {
            NSLog(@"已兌換");
            //[self showAlertViewForImageTest];
            
            NSLog(@"page: %d", page);
            [strongSelf removeImage: strongSelf->fileNameForDeletion];
            [strongSelf saveImageForGift: page];
        }
    }];
    
    [self checkSubViews];
    
    [alertViewForExchange setUseMotionEffects: true];
    [alertViewForExchange show];
}

- (UIView *)createViewForExchange
{
    int page = mySV.contentOffset.x / mySV.frame.size.width;
    NSLog(@"page: %d", page);
    NSString *pid = [datalist[page][@"photo_id"] stringValue];
    NSArray *slotArray = [self readPlist: @"slot"];
    NSDictionary *imageDict;
    
    for (NSDictionary *dict in slotArray) {
        for (NSString *str in [dict allKeys]) {
            if ([str isEqualToString: pid]) {
                NSLog(@"dict match pid: %@", dict);
                imageDict = [dict objectForKey: pid];
            }
        }
    }
    
    NSLog(@"imageDict: %@", imageDict);
    
    NSString *giftImage = [imageDict objectForKey: @"giftImage"];
    NSString *giftName = [imageDict objectForKey: @"giftName"];
    NSString *photoDescription = [imageDict objectForKey: @"photoDescription"];
    
    NSLog(@"giftImage: %@", giftImage);
    NSLog(@"giftName: %@", giftName);
    NSLog(@"photoDescription: %@", photoDescription);
    
    UIView *gv = [[UIView alloc] initWithFrame: CGRectMake(0, 0, mySV.bounds.size.width - 30, mySV.bounds.size.height - 70)];
    
    UILabel *giftTopicLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 10, gv.bounds.size.width, 20)];
    giftTopicLabel.text = giftName;
    giftTopicLabel.textAlignment = NSTextAlignmentCenter;
    [gv addSubview: giftTopicLabel];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 60, 250, 250)];
    imageView.image = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString: giftImage]]];
    imageView.center = CGPointMake(gv.bounds.size.width / 2, gv.bounds.size.height / 2 - 40);
    imageView.layer.cornerRadius = 10;
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [gv addSubview: imageView];
    
    UILabel *giftMessageLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, gv.bounds.size.height / 2 + 90, gv.bounds.size.width, 100)];
    //giftMessageLabel.text = @"(請於時效內出示給服務人員)";
    giftMessageLabel.text = photoDescription;
    giftMessageLabel.textAlignment = NSTextAlignmentCenter;
    giftMessageLabel.numberOfLines = 0;
    giftMessageLabel.adjustsFontSizeToFitWidth = YES;
    giftMessageLabel.font = [UIFont systemFontOfSize: 15];
    [gv addSubview: giftMessageLabel];
    
    // Count Down Function Setting
    timeLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 300, 26)];
    timeLabel.center = CGPointMake(gv.bounds.size.width / 2, gv.bounds.size.height / 2 + 100);
    timeLabel.textColor = [UIColor redColor];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    [gv addSubview: timeLabel];
    
    timeTick = 60;
    [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self selector: @selector(tickForExchange) userInfo: nil repeats: YES];
    
    return gv;
}

- (void)tickForExchange
{
    NSLog(@"tick");
    
    if (timeTick == 0) {
        [timer invalidate];
        
        int page = mySV.contentOffset.x / mySV.frame.size.width;
        NSLog(@"page: %d", page);
        
        [self removeImage: fileNameForDeletion];
        [self saveImageForGift: page];
        
        [alertViewForExchange close];
        
    } else {
        timeTick--;
        NSString *timeString = [[NSString alloc] initWithFormat: @"%d", timeTick];
        timeLabel.text = timeString;
    }
}

#pragma mark -
#pragma mark Delete First & Save Image For Replacement

- (void)removeImage: (NSString *)fileName
{
    NSLog(@"removeImage");
    NSLog(@"fileName: %@", fileName);
    
    NSString *name = [NSString stringWithFormat: @"%@%@", [wTools getUserID], _albumid];
    NSString *docDirectoryPath = [filepinpinboxDest stringByAppendingPathComponent: name];
    NSLog(@"docDirectoryPath: %@", docDirectoryPath);
    
    /*
    NSString *filePath = [docDirectoryPath stringByAppendingPathComponent: fileName];
    NSLog(@"filePath: %@", filePath);
    */
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    BOOL success = [fileManager removeItemAtPath: fileName error: &error];
    
    if (success) {
        /*
        UIAlertView *removedSuccessFullyAlert = [[UIAlertView alloc] initWithTitle: @"Congratulations:" message: @"Successfully removed" delegate: self cancelButtonTitle: @"Close" otherButtonTitles: nil];
        [removedSuccessFullyAlert show];
         */
    } else {
        NSLog(@"Could not delete file -:%@", [error localizedDescription]);
    }
}

- (void)saveImageForGift: (int)page
{
    NSLog(@"saveImageForGift");
    NSLog(@"page: %d", page);
    
    NSString *pid = [datalist[page][@"photo_id"] stringValue];
    NSArray *slotArray = [self readPlist: @"slot"];
    NSDictionary *imageDict;
    
    for (NSDictionary *dict in slotArray) {
        for (NSString *str in [dict allKeys]) {
            if ([str isEqualToString: pid]) {
                NSLog(@"dict match pid: %@", dict);
                imageDict = [dict objectForKey: pid];
            }
        }
    }
    NSLog(@"imageDict: %@", imageDict);
    
    NSString *giftImage = [imageDict objectForKey: @"giftImage"];
    NSLog(@"giftImage: %@", giftImage);
    
    // Definitions
    NSString *name = [NSString stringWithFormat: @"%@%@", [wTools getUserID], _albumid];
    NSString *docDirectoryPath = [filepinpinboxDest stringByAppendingPathComponent: name];
    NSLog(@"docDirectoryPath: %@", docDirectoryPath);
    
    // Get Image from URL
    UIImage *imageFromURL = [self getImageFromURL: giftImage];
    
    // Save Image to Directory
    [self saveImage: imageFromURL withFileName: [NSString stringWithFormat: @"%d", page] ofType: @"jpg" inDirectory: docDirectoryPath];
}

#pragma mark -
#pragma mark Image from HTTP Processing

- (UIImage *)getImageFromURL: (NSString *)fileURL {
    UIImage *result;
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString: fileURL]];
    result = [UIImage imageWithData: data];
    
    return result;
}

- (void)saveImage: (UIImage *)image withFileName: (NSString *)imageName ofType: (NSString *)extension inDirectory: (NSString *)directoryPath {
    if ([[extension lowercaseString] isEqualToString: @"png"]) {
        [UIImagePNGRepresentation(image) writeToFile: [directoryPath stringByAppendingPathComponent: [NSString stringWithFormat: @"%@.%@", imageName, @"png"]] options: NSAtomicWrite error: nil];
        
        NSLog(@"directoryPath with fileName: %@", [directoryPath stringByAppendingPathComponent: [NSString stringWithFormat: @"%@.%@", imageName, @"png"]]);
        
    } else if ([[extension lowercaseString] isEqualToString: @"jpg"] || [[extension lowercaseString] isEqualToString: @"jpeg"]) {
        [UIImageJPEGRepresentation(image, 1.0) writeToFile: [directoryPath stringByAppendingPathComponent: [NSString stringWithFormat: @"%@.%@", imageName, @"jpg"]] options: NSAtomicWrite error: nil];
        
        NSLog(@"directoryPath with fileName: %@", [directoryPath stringByAppendingPathComponent: [NSString stringWithFormat: @"%@.%@", imageName, @"jpg"]]);
        
    } else {
        NSLog(@"Image Save Failed\nExtension: (%@) is not recognized, use (PNG/JPG)", extension);
    }
}

- (UIImage *)loadImage: (NSString *)fileName ofType: (NSString *)extension inDirectory: (NSString *)directoryPath {
    
    NSLog(@"directoryPath with fileName: %@", [directoryPath stringByAppendingPathComponent: [NSString stringWithFormat: @"%@.%@", fileName, extension]]);
    UIImage *result = [UIImage imageWithContentsOfFile: [directoryPath stringByAppendingPathComponent: [NSString stringWithFormat: @"%@.%@", fileName, extension]]];
        
    return result;
}

#pragma mark -

//兌換
-(void)showexchange:(UIButton *)btn {
    
    NSLog(@"showExchange");
    
    // Getting the current scrollview page
    NSLog(@"contentOffset.x: %f", mySV.contentOffset.x);
    NSLog(@"scrollview.frame.size.width: %f", mySV.frame.size.width);
    
    int page = mySV.contentOffset.x / mySV.frame.size.width;
    NSLog(@"page: %d", page);
    
    
    // In order to get photoUseForUserId parameter value, we need to call API 42 first
    // Call Protocol 42
    //[wTools ShowMBProgressHUD];
    [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        int wNowPage = [mySV getNowPage:2];
        NSLog(@"wNowPage: %d", wNowPage);
        
        NSString *pid = [datalist[wNowPage][@"photo_id"] stringValue];
        
        NSString *response;
        
        if ([wTools getUUID]) {
            response = [boxAPI getPhotoUseForUser: [wTools getUserID] token: [wTools getUserToken] photo_id: pid identifier: [OpenUDID value]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (response != nil) {
                NSLog(@"response: %@", response);
                
                NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                if ([data[@"result"] intValue] == 1) {
                    //[wTools HideMBProgressHUD];
                    [MBProgressHUD hideHUDForView: self.view animated: YES];
                    
                    // Success
                    NSLog(@"Success");
                    
                    giftImage1 = data[@"data"][@"photousefor"][@"image"];
                    NSLog(@"image: %@", giftImage1);
                    
                    giftName1 = data[@"data"][@"photousefor"][@"name"];
                    NSLog(@"name: %@", giftName1);
                    
                    photoUseForUserId1 = data[@"data"][@"photousefor_user"][@"photousefor_user_id"];
                    NSLog(@"photoUseForUserID: %@", photoUseForUserId1);
                    
                    // Gift View
                    giftView1 = [[UIView alloc] initWithFrame: CGRectMake(mySV.bounds.size.width * page, 0, mySV.bounds.size.width, mySV.bounds.size.height)];
                    [giftView1 addSubview: exchangeButton1];
                    [giftView1 addSubview: exchangeLabel1];
                    [mySV addSubview: giftView1];
                    
                    [self showGift1];
                    
                } else if ([data[@"result"] intValue] == 2) {
                    //[wTools HideMBProgressHUD];
                    [MBProgressHUD hideHUDForView: self.view animated: YES];
                    // 兌換 / 拉霸的對象數量已用盡或已被領取
                    NSLog(@"兌換 / 拉霸的對象數量已用盡或已被領取");
                    
                    // Remind: Alert Message Function
                    Remind *rv = [[Remind alloc] initWithFrame: self.view.bounds];
                    [rv addtitletext: @"兌換 / 拉霸的對象數量已用盡或已被領取"];
                    [rv addBackTouch];
                    [rv showView: self.view];
                    
                    return;
                } else if ([data[@"result"] intValue] == 0) {
                    //[wTools HideMBProgressHUD];
                    [MBProgressHUD hideHUDForView: self.view animated: YES];
                    NSLog(@"Fail");
                } else {
                    [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                }
            }
        });
    });
}

- (void)showGift1
{
    NSLog(@"show exchange gift");
    
    mySV.scrollEnabled = NO;
    
    [exchangeButton1 setUserInteractionEnabled: NO];
    
    // Show the exchange gift
    exchangeGiftImageView1 = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 250, 250)];
    exchangeGiftImageView1.image = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString: giftImage1]]];
    exchangeGiftImageView1.center = CGPointMake(mySV.bounds.size.width / 2, mySV.bounds.size.height - 340);
    exchangeGiftImageView1.layer.cornerRadius = 10;
    exchangeGiftImageView1.clipsToBounds = YES;
    //exchangeGiftImageView1.contentMode = UIViewContentModeScaleAspectFit;
    [giftView1 addSubview: exchangeGiftImageView1];
    
    // Show the Label of Gift
    giftLabel1 = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 300, 26)];
    giftLabel1.center = CGPointMake(mySV.bounds.size.width / 2, mySV.bounds.size.height - 200);
    giftLabel1.text = giftName1;
    giftLabel1.font = [UIFont systemFontOfSize: 18];
    giftLabel1.textColor = [UIColor whiteColor];
    giftLabel1.textAlignment = NSTextAlignmentCenter;
    [giftView1 addSubview: giftLabel1];
    
    noticeLabel1 = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 300, 26)];
    noticeLabel1.center = CGPointMake(mySV.bounds.size.width / 2, mySV.bounds.size.height - 170);
    noticeLabel1.text = @"(注意!須由服務人員認證，是否確認兌換?)";
    noticeLabel1.font = [UIFont systemFontOfSize: 15];
    noticeLabel1.textColor = [UIColor whiteColor];
    noticeLabel1.textAlignment = NSTextAlignmentCenter;
    [giftView1 addSubview: noticeLabel1];
    
    // Button Configuration
    yesButton1 = [UIButton buttonWithType: UIButtonTypeCustom];
    [yesButton1 addTarget: self
                   action: @selector(pressYes1:) forControlEvents: UIControlEventTouchUpInside];
    [yesButton1 setTitle: @"是" forState: UIControlStateNormal];
    yesButton1.frame = CGRectMake(0, 0, 50, 50);
    yesButton1.center = CGPointMake(mySV.bounds.size.width / 2 - 80, mySV.bounds.size.height - 120);
    [giftView1 addSubview: yesButton1];
    
    noButton1 = [UIButton buttonWithType: UIButtonTypeCustom];
    [noButton1 addTarget: self
                  action: @selector(pressNo1:) forControlEvents: UIControlEventTouchUpInside];
    [noButton1 setTitle: @"否" forState: UIControlStateNormal];
    noButton1.frame = CGRectMake(0, 0, 50, 50);
    noButton1.center = CGPointMake(mySV.bounds.size.width / 2 + 80, mySV.bounds.size.height - 120);
    [giftView1 addSubview: noButton1];
    
    [mySV addSubview: giftView1];
}

- (void)pressYes1: (UIButton *)btn
{
    NSLog(@"PressYes1");
    
    // Call Protocol 43
    //[wTools ShowMBProgressHUD];
    [MBProgressHUD showHUDAddedTo: self.view animated: YES];
    
    NSLog(@"兌換");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI updatePhotoUseForUser: [wTools getUserID] token: [wTools getUserToken] photoUseForUserId: photoUseForUserId1];
        
        NSLog(@"id: %@", [wTools getUserID]);
        NSLog(@"token: %@", [wTools getUserToken]);
        NSLog(@"photoUseForUserId: %@", photoUseForUserId1);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (response != nil) {
                NSLog(@"兌換 response: %@", response);
                
                NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                if ([data[@"result"] intValue] == 1) {
                    //[wTools HideMBProgressHUD];
                    [MBProgressHUD hideHUDForView: self.view animated: YES];
                    
                    // Success
                    NSLog(@"兌換 Success");
                    
                    // Change View
                    [yesButton1 removeFromSuperview];
                    [noButton1 removeFromSuperview];
                    [giftLabel1 removeFromSuperview];
                    
                    // Count Down Function Setting
                    timeLabel1 = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 300, 26)];
                    timeLabel1.center = CGPointMake(mySV.bounds.size.width / 2, mySV.bounds.size.height - 190);
                    timeLabel1.textColor = [UIColor redColor];
                    timeLabel1.textAlignment = NSTextAlignmentCenter;
                    //timeLabel.font = [UIFont systemFontOfSize:<#(CGFloat)#>]
                    
                    timeTick1 = 60;
                    [timer1 invalidate];
                    timer1 = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self selector: @selector(tick1) userInfo: nil repeats: YES];
                    
                    // Change value of view
                    [exchangeButton1 setImage: [UIImage imageNamed: @"icon_exchanged.png"] forState: UIControlStateNormal];
                    noticeLabel1.text = @"(請於時效內出示給服務人員)";
                    exchangeLabel1.text = @"已兌換";
                    
                    exchangeCheckButton1 = [UIButton buttonWithType: UIButtonTypeCustom];
                    [exchangeCheckButton1 setTitle: @"已兌換" forState: UIControlStateNormal];
                    exchangeCheckButton1.frame = CGRectMake(0, 0, 100, 50);
                    exchangeCheckButton1.center = CGPointMake(mySV.bounds.size.width / 2, mySV.bounds.size.height - 120);
                    exchangeCheckButton1.backgroundColor = [UIColor lightGrayColor];
                    exchangeCheckButton1.layer.cornerRadius = 10;
                    exchangeCheckButton1.clipsToBounds = YES;
                    
                    [exchangeCheckButton1 addTarget: self action: @selector(removeViews1) forControlEvents: UIControlEventTouchUpInside];
                    
                    [giftView1 addSubview: timeLabel1];
                    [giftView1 addSubview: exchangeCheckButton1];
                    
                    // Save data about gift is already exchanged
                    BOOL giftExchanged = YES;
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject: [NSNumber numberWithBool: giftExchanged] forKey: @"giftExchanged"];
                    [defaults synchronize];
                    
                } else if ([data[@"result"] intValue] == 2) {
                    //[wTools HideMBProgressHUD];
                    [MBProgressHUD hideHUDForView: self.view animated: YES];
                    
                    // 兌換 / 拉霸的對象數量已用盡或已被領取
                    NSLog(@"兌換 / 拉霸的對象數量已用盡或已被領取");
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"" message: @"兌換 / 拉霸的對象數量已用盡或已被領取" preferredStyle: UIAlertControllerStyleAlert];
                    
                    UIAlertAction *okBtn = [UIAlertAction actionWithTitle: @"OK" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        NSLog(@"OK");
                    }];
                    
                    [alert addAction: okBtn];
                    [self presentViewController: alert animated: YES completion: nil];
                    
                } else if ([data[@"result"] intValue] == 0) {
                    //[wTools HideMBProgressHUD];
                    [MBProgressHUD hideHUDForView: self.view animated: YES];
                    
                    NSLog(@"Fail");
                } else {
                    [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                }
            }
        });
    });
}

- (void)pressNo1: (UIButton *)btn
{
    mySV.scrollEnabled = YES;
    
    NSLog(@"PressNo1");
    
    [exchangeButton1 setUserInteractionEnabled: YES];
    
    [exchangeGiftImageView1 removeFromSuperview];
    [giftLabel1 removeFromSuperview];
    [noticeLabel1 removeFromSuperview];
    [yesButton1 removeFromSuperview];
    [noButton1 removeFromSuperview];
    [exchangeCheckButton1 removeFromSuperview];
    [timeLabel1 removeFromSuperview];
}

- (void)tick1
{
    NSLog(@"tick");
    
    if (timeTick1 == 0) {
        [timer1 invalidate];
        [self removeViews1];
    } else {
        timeTick1--;
        NSString *timeString = [[NSString alloc] initWithFormat: @"%d", timeTick1];
        timeLabel1.text = timeString;
    }
}

- (void)removeViews1
{
    mySV.scrollEnabled = YES;
    
    [exchangeGiftImageView1 removeFromSuperview];
    [noticeLabel1 removeFromSuperview];
    [timeLabel1 removeFromSuperview];
    [exchangeCheckButton1 removeFromSuperview];
    
    [timer1 invalidate];
}

#pragma mark -
/*
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}
*/


#pragma mark -

-(IBAction)pagetext:(id)sender {
    
    if (datalist.count==0) {
        
        return;
    }
    
    NSLog(@"bookdata: %@", bookdata);
    NSLog(@"bookdata name: %@", bookdata[@"name"]);
    NSLog(@"bookdata title: %@", bookdata[@"title"]);
    NSLog(@"isplayaudio: %d", isplayaudio);
    NSLog(@"_albumid: %@", _albumid);
    
    PagetextViewController *page=[[PagetextViewController alloc]initWithNibName:@"PagetextViewController" bundle:nil];
    page.bookdata=bookdata;
    page.bookvc=self;
    page.isplay=isplayaudio;
    page.albumId = _albumid;
    page.fromInfoTxt = YES;
    
    //目前頁數
    int wNowPage = [mySV getNowPage:2];
    page.pagedata=datalist[wNowPage];
    page.file=file;
    
    NSLog(@"pagedata: %@", datalist[wNowPage]);
    NSLog(@"file: %@", file);
    
    if (locdata) {
        page.localdata=locdata;
    }
    
    PageNavigationController *nav=[[PageNavigationController alloc]initWithRootViewController:page];
    [nav setNavigationBarHidden:YES animated:NO];
    
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - Custom Error Alert Method
- (void)showCustomErrorAlert: (NSString *)msg {
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

@end
