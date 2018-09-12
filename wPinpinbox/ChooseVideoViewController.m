//
//  ChooseVideoViewController.m
//  wPinpinbox
//
//  Created by David on 9/12/16.
//  Copyright © 2016 Angus. All rights reserved.
//

#import "ChooseVideoViewController.h"
#import "VideoCollectionViewCell.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "RSKImageCropViewController.h"
#import "UICustomLineLabel.h"
#import "Remind.h"
#import "wTools.h"

#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

#import "AppDelegate.h"

@interface ChooseVideoViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout>
{
    __weak IBOutlet UICustomLineLabel *titleLabel;
    __weak IBOutlet UIButton *okbtn;
    
    NSMutableArray *videoArray;
    PHFetchResult *assetsFetchResults;
    NSCache *videosCache;
    __strong PHImageManager *imageManager;
    
    NSMutableArray *videos;
    BOOL isSelected;
}
@end

@implementation ChooseVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"ChooseVideoViewController");
    
    // Do any additional setup after loading the view.
    titleLabel.lineType=LineTypeDown;
    videoArray = [NSMutableArray new];
    imageManager = [PHImageManager defaultManager];
    videosCache = [[NSCache alloc] init];
    titleLabel.text = NSLocalizedString(@"VideoText-selVideo", @"");
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (authStatus == AVAuthorizationStatusDenied ||authStatus == AVAuthorizationStatusRestricted) {
        [wTools showAlertTile:NSLocalizedString(@"PicText-tipAccessPrivacy", @"") Message:@"" ButtonTitle:nil];
        
    }
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO],[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:NO]];
    
    options.predicate = [NSPredicate predicateWithFormat: @"mediaType == %d AND duration <= %f", 2, 30.0];
    //options.predicate = [NSPredicate predicateWithFormat: @"duration <= %d", timeInterval];
    
    assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    
    [myCov reloadData];
    
    return;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark IBAction Methods
- (IBAction)back:(id)sender {
    //[self.navigationController popViewControllerAnimated:YES];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav popViewControllerAnimated: YES];
}

- (IBAction)selectButtonPressed:(id)sender {
    if (isSelected) {
        isSelected = NO;
        
        okbtn.userInteractionEnabled = NO;
        [okbtn setTitle: @"點選觀看" forState: UIControlStateNormal];
        [okbtn setImage: nil forState: UIControlStateNormal];
        
    } else {
        isSelected = YES;
        
        okbtn.userInteractionEnabled = YES;
        [okbtn setTitle: @"確 認 選 取" forState: UIControlStateNormal];
        [okbtn setImage: [UIImage imageNamed: @"2-01icon_confirm"] forState: UIControlStateNormal];
    }
    
    [myCov reloadData];
}

- (IBAction)okBtnPressed:(id)sender {
    if (videoArray.count == 0) {
        Remind *rv = [[Remind alloc] initWithFrame: self.view.bounds];
        [rv addtitletext: NSLocalizedString(@"VideoText-tipLessVideo", @"")];
        [rv addBackTouch];
        [rv showView: self.view];
        return;
    }
    
    videos = [NSMutableArray new];
    [self addNewVideo: 0];
}

#pragma mark -
- (void)addNewVideo: (int)se {
    PHAsset *asset = videoArray[se];
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionCurrent;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeFastFormat;
    __block typeof(self) wself = self;
    [imageManager requestAVAssetForVideo: asset options: options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        __strong typeof(wself) sself = wself;
        if ([asset isKindOfClass: [AVURLAsset class]]) {
            NSURL *url = [(AVURLAsset *)asset URL];
            NSData *data = [NSData dataWithContentsOfURL: url];
            [sself->videos addObject: data];
            
            if ((se + 1) >= sself->videoArray.count) {
                [sself okVideo];
            } else {
                [sself addNewVideo: se + 1];
            }
        }
    }];
}

- (void)okVideo {
    NSLog(@"輸出%lu個影片", (unsigned long)videos.count);
    
    if ([self.delegate respondsToSelector: @selector(videoCropViewController:videoArray:)]) {
        [self.delegate videoCropViewController: self videoArray: videos];
        NSLog(@"after calling delegate methods videoCropViewController");
    }
    
    //[self.navigationController popViewControllerAnimated: YES];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav popViewControllerAnimated: YES];
}

#pragma mark -
#pragma mark CollectionView Datasource Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSString *str=[NSString stringWithFormat:@" %@（ %lu / %ld ）",NSLocalizedString(@"PicText-confirm", @""),(unsigned long)[videoArray count],(long)_selectRow];
    [okbtn setTitle:str forState:UIControlStateNormal];
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return assetsFetchResults.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 0) {
        UICollectionViewCell *Cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"carmeraCell" forIndexPath: indexPath];
        
        return Cell;
    }
    
    VideoCollectionViewCell *myCell = [collectionView
                                       dequeueReusableCellWithReuseIdentifier:@"CollectionCell"
                                       forIndexPath:indexPath];
    NSInteger currentTag = myCell.tag;
    myCell.tag = currentTag;
    
    PHAsset *asset = assetsFetchResults[indexPath.item - 1];
    NSLog(@"asset.duration: %f", asset.duration);
    
    myCell.durationLabel.text = [self stringFromTimeInterval: round(asset.duration)];
    
    if ([videosCache objectForKey:asset.localIdentifier]) {
        myCell.thumbnailImage = [videosCache objectForKey: asset.localIdentifier];
    } else {
        myCell.thumbnailImage = nil;
        __block typeof(imageManager) wmanager = imageManager;
        __block typeof(videosCache) wvcache = videosCache;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            [options setVersion: PHImageRequestOptionsVersionCurrent];
            [options setResizeMode: PHImageRequestOptionsResizeModeFast];
            [options setDeliveryMode: PHImageRequestOptionsDeliveryModeOpportunistic];
            
            CGSize size = cellSize1(collectionView);
            CGFloat scale = [[UIScreen mainScreen] scale];
            size = CGSizeMake(size.width * scale, size.height * scale);
            NSString *identifier = asset.localIdentifier;
            
            [wmanager requestImageForAsset: asset
                                    targetSize: size
                                   contentMode: PHImageContentModeAspectFill
                                       options: options
                                 resultHandler: ^(UIImage *result, NSDictionary *info) {
                                     
                                     if (myCell.tag == currentTag) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             //cell.thumbnailImage = result;
                                             myCell.thumbnailImage = result;
                                             
                                             if (![info[PHImageResultIsDegradedKey] boolValue]) {
                                                 if (result != nil) {
                                                     [wvcache setObject:result forKey:identifier];
                                                 }
                                             }
                                         });
                                     }
                                 }];
        });
    }
    
    if (isSelected) {
        NSLog(@"is selected");
        myCell.imageTick.hidden = NO;
        myCell.imageTick.image = [UIImage imageNamed: @"icon_v"];
        myCov.allowsMultipleSelection = YES;
        
    } else {
        NSLog(@"is not selected");
        myCell.imageTick.hidden = YES;
        myCov.allowsMultipleSelection = NO;
        
        [videoArray removeAllObjects];
    }
    
    if ([videoArray containsObject: asset]) {
        
        NSLog(@"videoArray containsObject: asset");
        myCell.bgV.hidden = YES;
        //myCell.title.hidden = NO;
        //myCell.title.text = [NSString stringWithFormat: @"%lu", [videoArray indexOfObject: asset] + 1];
        myCell.imageTick.hidden = NO;
        myCell.imageTick.image = [UIImage imageNamed: @"icon_v_click"];
        
    } else {
        NSLog(@"videoArray not containsObject: asset");
        myCell.bgV.hidden = NO;
        //myCell.title.hidden = YES;
    }
    
    return myCell;
}

#pragma mark -
#pragma mark CollectionView Delegate Methods

- (void)collectionView:(UICollectionView *)collectionView
didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType: mediaType];
#if __IPHONE_9_0
    if (authStatus == PHAuthorizationStatusRestricted || authStatus == PHAuthorizationStatusDenied) {
        [wTools showAlertTile: NSLocalizedString(@"PicText-tipAccessPrivacy", @"") Message: @"" ButtonTitle: nil];
    }
#else
    if (authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied) {
        [wTools showAlertTile: NSLocalizedString(@"PicText-tipAccessPrivacy", @"") Message: @"" ButtonTitle: nil];
    }
#endif
    if (indexPath.item == 0) {
        NSLog(@"recorded button pressed");
        
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *videoPicker = [[UIImagePickerController alloc] init];
            videoPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            videoPicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *)kUTTypeMovie, nil];
            videoPicker.delegate = self;
            videoPicker.videoMaximumDuration = 29;
            videoPicker.videoQuality = UIImagePickerControllerQualityTypeLow;
            [self presentViewController: videoPicker animated: YES completion: nil];
        }
        return;
    }
    
    if ([videoArray containsObject: assetsFetchResults[indexPath.item - 1]]) {
        NSLog(@"videoArray containsObject:assetsFetchResults");
        [videoArray removeObject: assetsFetchResults[indexPath.item - 1]];
    } else {
        NSLog(@"videoArray not containsObject:assetsFetchResults");
        
        //@"icon_v_click.png" @"icon_v.png"
        
        if (!isSelected) {
            __block typeof(assetsFetchResults) results = assetsFetchResults;
            __block typeof(imageManager) imgr = imageManager;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                PHAsset *asset = results[indexPath.item - 1];
                PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
                options.version = PHVideoRequestOptionsVersionCurrent;
                options.deliveryMode = PHVideoRequestOptionsDeliveryModeFastFormat;
                
                [imgr requestPlayerItemForVideo: asset options: options resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
                    AVPlayer *avPlayer = [[AVPlayer alloc] initWithPlayerItem: playerItem];
                    AVPlayerViewController *playerViewController = [AVPlayerViewController new];
                    playerViewController.player = avPlayer;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self presentViewController: playerViewController animated: YES completion: nil];
                    });
                }];
            });
            return;
            
        } else {
            if (videoArray.count >= 1) {
                Remind *rv = [[Remind alloc] initWithFrame: self.view.bounds];
                [rv addtitletext:NSLocalizedString(@"PicText-tipLimit", @"")];
                [rv addBackTouch];
                [rv showView: self.view];
            } else {
                [videoArray addObject: assetsFetchResults[indexPath.item - 1]];
            }
        }
        
        /*
        [imageManager requestAVAssetForVideo: asset options: options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            if ([asset isKindOfClass: [AVURLAsset class]]) {
                NSURL *url = [(AVURLAsset *)asset URL];
                AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL: url];
                AVPlayer *avPlayer = [[AVPlayer alloc] initWithPlayerItem: playerItem];
                AVPlayerViewController *playerViewController = [AVPlayerViewController new];
                playerViewController.player = avPlayer;
                [self presentViewController: playerViewController animated: YES completion: nil];
                
                NSLog(@"videoPlayer play");
            }
        }];
         */
    }
    [collectionView reloadData];
}

#pragma mark -
#pragma mark CollectionViewFlowLayout Delegate Methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(77, 77);
    return cellSize1(collectionView);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

#pragma mark -

CGSize cellSize1(UICollectionView *collectionView) {
    int numberOfColumns = 5;
    
    // this is to fix jerky scrolling in iPhone 6 plus
    if ([[UIScreen mainScreen] scale] > 2) {
        numberOfColumns = 4;
    }
    // end of fix
    
    CGFloat collectionViewWidth = collectionView.frame.size.width;
    CGFloat spacing = [(id)collectionView.delegate collectionView:collectionView layout:collectionView.collectionViewLayout minimumInteritemSpacingForSectionAtIndex:0];
    CGFloat width = floorf((collectionViewWidth-spacing*(numberOfColumns-1))/(float)numberOfColumns);
    
    return CGSizeMake(width, width);
}

#pragma mark -
#pragma Convert TimeInterval to String

- (NSString *)stringFromTimeInterval: (NSTimeInterval)interval
{
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    
    return [NSString stringWithFormat: @"%02ld:%02ld", (long)minutes, (long)seconds];
}

#pragma mark -
#pragma mark UIImagePickerController Delegate Methods
- (void)postprocessDismiss {
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey: @"creationDate" ascending: NO]];
    options.predicate = [NSPredicate predicateWithFormat: @"mediaType == %d AND duration <= %f", 2, 30.0];
    assetsFetchResults = [PHAsset fetchAssetsWithOptions: options];
    
    [myCov reloadData];
}
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    __block typeof(self) wself = self;
    [self dismissViewControllerAnimated: YES completion:^(void){
        [wself postprocessDismiss];
    }];
    
    if (CFStringCompare((__bridge_retained CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        NSString *moviePath = [[info objectForKey: UIImagePickerControllerMediaURL] path];
        
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(moviePath)) {
            UISaveVideoAtPathToSavedPhotosAlbum(moviePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }
    }
}

- (void)video:(NSString *)videoPath
didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"錯誤"
                                                                       message: @"影片儲存失敗"
                                                                preferredStyle: UIAlertControllerStyleAlert];
        
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle: @"OK"
                                                                style: UIAlertActionStyleDefault
                                                              handler: nil];
        [alert addAction: defaultAction];
        [self presentViewController: alert animated: YES completion: nil];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"影片儲存成功"
                                                                       message: @"已儲存到相本"
                                                                preferredStyle: UIAlertControllerStyleAlert];
        
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle: @"OK"
                                                                style: UIAlertActionStyleDefault
                                                              handler: nil];
        [alert addAction: defaultAction];
        [self presentViewController: alert animated: YES completion: nil];
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
