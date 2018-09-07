//
//  PhotosViewController.m
//  wPinpinbox
//
//  Created by Angus on 2015/8/11.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "PhotosViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "PhotoCollectionViewCell.h"
#import "RSKImageCropViewController.h"
#import "UICustomLineLabel.h"
#import "Remind.h"
#import "wTools.h"
#import "CustomIOSAlertView.h"
#import "UIColor+Extensions.h"
#import "UIView+Toast.h"
#import "boxAPI.h"
#import "MBProgressHUD.h"
#import "NSString+MD5.h"
#import "GlobalVars.h"
#import "MyLinearLayout.h"

#import "UIImage+Resize.h"

#import "AppDelegate.h"

#define kFontSize 18

#define kFontSizeForUploading 18
#define kFontSizeForConnection 16

@interface PhotosViewController () <UICollectionViewDataSource,UICollectionViewDelegate,RSKImageCropViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIGestureRecognizerDelegate>
{
    __weak IBOutlet UICustomLineLabel *titlelab;
    NSMutableArray *imageArray;
    PHFetchResult *assetsFetchResults;
    NSCache *imagesCache;
    
    //__strong PHImageManager *imageManager;
    __weak IBOutlet UIButton *okbtn;
    
    NSMutableArray *imgs;
    
    //CustomIOSAlertView *alertViewForButton;
    
    // For Observing NSOperationQueue
    NSString *responseImageStr;
    
    MBProgressHUD *hud;
    
    NSInteger photoFinished;
    
    NSURLSessionDataTask *dataTask;
    NSMutableArray *dataTaskArray;
}
@property (weak, nonatomic) IBOutlet UIView *toolBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolBarViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *okBtnHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarHeight;
@property (weak, nonatomic) IBOutlet UIView *navBarView;

@property (strong, nonatomic) PHCachingImageManager * imageManager;
@property (strong, nonatomic) NSMutableArray * cachingIndexes;
@property (assign, nonatomic) CGFloat lastCacheFrameCenter;
@property (assign, nonatomic) CGSize assetThumbnailSize;
@property (strong, nonatomic) dispatch_queue_t cacheQueue;

@property (weak, nonatomic) IBOutlet UIButton *dismissBtn;

@property (strong, nonatomic) NSOperationQueue *queue;

@property (weak, nonatomic) IBOutlet UIButton *cameraBtn;
@property (weak, nonatomic) IBOutlet UIButton *compressionBtn;
@property (nonatomic) BOOL shouldResize;
//@property (nonatomic) CGFloat compressionData;

@end

@implementation PhotosViewController

#pragma mark - View Related Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"PhotosViewController");
    NSLog(@"viewDidLoad");
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.delegate = self;
    
    // Default Value set to 1.0 for original
    //self.compressionData = 1.0;
    self.shouldResize = YES;
    
    dataTaskArray = [NSMutableArray new];
    
    mycov.showsVerticalScrollIndicator = NO;
    self.dismissBtn.transform = CGAffineTransformMakeRotation(-90.0 * M_PI / 180.0);
    
    //titlelab.lineType = LineTypeDown;
    imageArray = [NSMutableArray new];
    //imageManager = [PHImageManager defaultManager];
    
    // For quick performance when you are working with many assets, a caching image manager can prepare asset images in the background in order to eliminate delays when you later request individual images. For example, use a caching image manager when you want to populate a collection view or similar UI with thumbnails of photo or video assets.
    self.imageManager = [[PHCachingImageManager alloc] init];
    self.cachingIndexes = [[NSMutableArray alloc] init];
    self.cacheQueue = dispatch_queue_create("cacheQueue", DISPATCH_QUEUE_SERIAL);
    
    imagesCache = [[NSCache alloc] init];
    titlelab.text = NSLocalizedString(@"PicText-selPicture", @"");
    
    // Requests the user’s permission, if needed, for accessing the Photos library.
    //__block PHFetchResult *wresult = assetsFetchResults;
    __block UICollectionView *cov = mycov;
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"dispatch_async");
            
            if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
                NSLog(@"authorized");
                
                // A set of options that affect the filtering, sorting, and management of results that Photos returns when you fetch asset or collection objects.
                PHFetchOptions *options = [[PHFetchOptions alloc] init];
                options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO],[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:NO]];
                options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
                
                // An ordered list of assets or collections returned from a Photos fetch method.
                assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
                
                [cov reloadData];
            } else {
                NSLog(@"Not Authorized");
                
                [self showNoAccessAlertAndCancel];
            }
        });
    }];
    
    return;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear");
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cellSize = ((UICollectionViewFlowLayout *)mycov.collectionViewLayout).itemSize;
    self.assetThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
    NSLog(@"self.assetThumbnailSize: %@", NSStringFromCGSize(self.assetThumbnailSize));
    
    if (assetsFetchResults.count == 0) {
        NSLog(@"assetsFetchResults.count == 0");
    } else {
        NSLog(@"assetsFetchResults.count != 0");
        // Only reloadData when assetsFetchResults.count is not 0
        // Otherwise, the app will crash
        [mycov reloadData];
    }
    [self updateCache];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear");
//    [self.queue removeObserver: self forKeyPath: @"operations" context: NULL];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.myNav.interactivePopGestureRecognizer.enabled = NO;
}

- (void)dealloc {
    NSLog(@"dealloc");
    [self.queue removeObserver: self forKeyPath: @"operations" context: NULL];
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
                mycov.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                self.toolBarViewHeight.constant = kToolBarViewHeight;
                break;
            case 1334:
                printf("iPhone 6/6S/7/8");
                mycov.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                self.toolBarViewHeight.constant = kToolBarViewHeight;
                break;
            case 1920:
                printf("iPhone 6+/6S+/7+/8+");
                mycov.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                self.toolBarViewHeight.constant = kToolBarViewHeight;
                break;
            case 2208:
                printf("iPhone 6+/6S+/7+/8+");
                mycov.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                self.toolBarViewHeight.constant = kToolBarViewHeight;
                break;
            case 2436:
                printf("iPhone X");
                self.navBarHeight.constant = navBarHeightConstant;
                self.toolBarViewHeight.constant = kToolBarViewHeightForX - 20;
                break;
            default:
                printf("unknown");
                mycov.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                self.toolBarViewHeight.constant = kToolBarViewHeight;
                break;
        }
    }
    self.okBtnHeight.constant = 45;
    okbtn.layer.cornerRadius = kCornerRadius;
    //[mycov reloadData];
}

#pragma mark -
- (void)showNoAccessAlertAndCancel {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"沒有照片存取權" message: @"請打開照片權限設定" preferredStyle: UIAlertControllerStyleAlert];
    [alert addAction: [UIAlertAction actionWithTitle: @"設定" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //[[UIApplication sharedApplication] openURL: [NSURL URLWithString: UIApplicationOpenSettingsURLString]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
    }]];
    [self presentViewController: alert animated: YES completion: nil];
}

- (PHAsset *)currentAssetAtIndex: (NSInteger)index {
    return assetsFetchResults[index];
}

- (void)checkCameraPermission {
    NSLog(@"checkCameraPermission");
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
        //无权限
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: NSLocalizedString(@"PicText-tipAccessPrivacy", @"") message: @"" preferredStyle: UIAlertControllerStyleAlert];
        [alert addAction: [UIAlertAction actionWithTitle: @"設定" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //[[UIApplication sharedApplication] openURL: [NSURL URLWithString: UIApplicationOpenSettingsURLString]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        }]];
        
        [self presentViewController: alert animated: YES completion: nil];
    }
    
    //拍照
    // 先檢查裝置是否配備相機
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
        // 設定相片來源為裝置上的相機
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        // 設定imagePicker的delegate為ViewController
        imagePicker.delegate = self;
        //開起相機拍照界面
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (IBAction)cameraBtnPress:(id)sender {
    NSLog(@"cameraBtnPress");
    [self checkCameraPermission];
}

- (IBAction)compressionBtnPress:(id)sender {
    NSLog(@"compressionBtnPress");
    
    if (self.shouldResize) {
        // If shouldResize is TRUE then change to FALSE
        self.shouldResize = !self.shouldResize;
        
        [self.compressionBtn setImage: [UIImage imageNamed: @"ic200_photosize_dark"] forState: UIControlStateNormal];
        [self showToastMsg: @"已選擇原始尺寸" color: [UIColor hintGrey] duration: 0.5];
    } else {
        // If shouldResize is FALSE then change to TRUE
        self.shouldResize = !self.shouldResize;
        
        [self.compressionBtn setImage: [UIImage imageNamed: @"ic200_photosize_light"] forState: UIControlStateNormal];
        [self showToastMsg: @"已取消原始尺寸" color: [UIColor hintGrey] duration: 0.5];
    }
    
    /*
     if (self.compressionData == 1.0) {
     self.compressionData = 0.5;
     [self.compressionBtn setImage: [UIImage imageNamed: @"ic200_photosize_light"] forState: UIControlStateNormal];
     //[self showToastMsg: @"已取消原始尺寸" color: [UIColor hintGrey]];
     [self showToastMsg: @"已取消原始尺寸" color: [UIColor hintGrey] duration: 0.5];
     } else if (self.compressionData == 0.5) {
     self.compressionData = 1.0;
     [self.compressionBtn setImage: [UIImage imageNamed: @"ic200_photosize_dark"] forState: UIControlStateNormal];
     [self showToastMsg: @"已選擇原始尺寸" color: [UIColor hintGrey] duration: 0.5];
     }
     */
}

- (IBAction)back:(id)sender {
    NSLog(@"back");
    NSLog(@"self.fromVC: %@", self.fromVC);
    
    if ([self.fromVC isEqualToString: @"InfoEditViewController"]) {
        [self dismissViewControllerAnimated: YES completion: nil];
    } else if ([self.fromVC isEqualToString: @"AlbumCreationViewController"]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if ([self.fromVC isEqualToString: @"TemplateViewController"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)OKbtn:(id)sender {
    if (imageArray.count == 0) {
        [self showCustomErrorAlert: NSLocalizedString(@"PicText-tipLessPic", @"")];
        return;
    }
    
    okbtn.userInteractionEnabled = NO;
    [self showToastMsg: @"圖片載入中" color: [UIColor secondMain] duration: 2.0];
    
    //處理所有則的圖片
    imgs = [NSMutableArray new];
    //開始用照片
    @try {
        [self addnewimage:0];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
}

- (void)showToastMsg:(NSString *)msg
               color:(UIColor *)color
            duration:(NSTimeInterval)duration {
    CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
    style.messageColor = [UIColor whiteColor];
    style.backgroundColor = color;
    [self.view makeToast: msg
                duration: duration
                position: CSToastPositionBottom
                   style: style];
}

- (void)addnewimage:(int)se {
    NSLog(@"-----------");
    NSLog(@"addnewimage");
    
    PHAsset *asset = imageArray[se];
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    [options setVersion:PHImageRequestOptionsVersionUnadjusted];
    [options setResizeMode:PHImageRequestOptionsResizeModeNone];
    [options setDeliveryMode:PHImageRequestOptionsDeliveryModeOpportunistic];
    
    CGSize size = cellSize(mycov);
    CGFloat scale = [[UIScreen mainScreen] scale];
    scale = 1;
    size = CGSizeMake(size.width * scale, size.height * scale);
    NSLog(@"------------");
    NSLog(@"size: %@", NSStringFromCGSize(size));
    NSLog(@"------------");
    
    __block UIImage *img;
    
    [self.imageManager requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info){
        NSLog(@"requestImageDataForAsset");
        
        // A key whose value indicates whether the result image is
        // a low-quality substitute for the requested image.
        if (![info[PHImageResultIsDegradedKey] boolValue]) {
            NSLog(@"imageData: %@", imageData);
            img = [UIImage imageWithData:imageData];
            [imgs addObject:img];
            
            if ((se+1)>=imageArray.count) {
                NSLog(@"se: %d", se);
                NSLog(@"imageArray.count: %lu", (unsigned long)imageArray.count);
                [self OKimage];
            } else {
                NSLog(@"");
                [self addnewimage:se+1];
            }
        }
    }];
}

- (void)OKimage {
    NSLog(@"OKimage");
    NSLog(@"choice: %@", _choice);
    
    okbtn.userInteractionEnabled = YES;
    
    if ([_choice isEqualToString: @"Template"]) {
        [self.navigationController popViewControllerAnimated:NO];
        
        NSLog(@"輸出%lu張圖片",(unsigned long)imgs.count);
        
        if ([self.delegate respondsToSelector:@selector(imageCropViewController:ImageArr:compression:)]) {
            [self.delegate imageCropViewController: self ImageArr: imgs compression: 0.5];
        }
    } else if ([_choice isEqualToString: @"Fast"]) {
        //[self showImageSizeMode];
        //[self sendingImage: imgs compression: self.compressionData];
        [self sendingImage:imgs resize:self.shouldResize];
    }
}

- (void)cancelWork:(id)sender {
    NSLog(@"");
    NSLog(@"cancelWork");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [hud hideAnimated: YES];
    });
    
    for (NSURLSessionDataTask *task in dataTaskArray) {
        [task cancel];
    }
    
    if (self.queue.operationCount > 0) {
        [self.queue cancelAllOperations];
    }
    
    [self.navigationController popViewControllerAnimated: YES];
    
    if ([self.delegate respondsToSelector: @selector(afterSendingImages:)]) {
        [self.delegate afterSendingImages: self];
    }
}

#pragma mark - Sending Image Function
//- (void)sendingImage:(NSArray *)imgArray compression:(CGFloat)compression {
- (void)sendingImage:(NSArray *)imgArray
              resize:(BOOL)resize {
    NSLog(@"sendingImage");
    NSLog(@"imgArray.count: %lu", (unsigned long)imgArray.count);
    //NSLog(@"compression: %f", compression);
    
    [dataTaskArray removeAllObjects];
    
    @try {
        hud = [MBProgressHUD showHUDAddedTo: self.view animated: YES];
        hud.label.text = [NSString stringWithFormat: @"等待上傳中"];
        hud.label.font = [UIFont systemFontOfSize: kFontSizeForUploading];
        [hud.button setTitle: @"取消" forState: UIControlStateNormal];
        [hud.button addTarget: self action: @selector(cancelWork:) forControlEvents: UIControlEventTouchUpInside];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    
    photoFinished = 0;
    
    self.queue = [[NSOperationQueue alloc] init];
    self.queue.maxConcurrentOperationCount = 5;
    [self.queue addObserver: self forKeyPath: @"operations" options: 0 context: NULL];
    
    NSBlockOperation *operation;
    
    __block NSString *response = @"";
    typeof(self) __weak weakSelf = self;
    
    for (int i = 0; i < imgArray.count; i++) {
        operation = [NSBlockOperation blockOperationWithBlock:^{
            NSLog(@"i = %d, thread = %@", i, [NSThread currentThread]);
            NSLog(@"image: %d", i);
            
            UIImage *imageForResize = [imgArray objectAtIndex: i];
            NSLog(@"Before Resize");
            NSLog(@"width: %f, height: %f", imageForResize.size.width, imageForResize.size.height);
            
            UIImage *image;
            
            if (resize) {
                NSLog(@"resize is YES");
                NSLog(@"resize: %d", resize);
                image = [weakSelf imageRatioCalculation: imageForResize];
            } else {
                NSLog(@"resize is NO");
                NSLog(@"resize: %d", resize);
                image = imageForResize;
            }
            
//            [self saveImage: image];
            
            NSLog(@"After Resize");
            NSLog(@"width: %f, height: %f", image.size.width, image.size.height);
            
            NSLog(@"boxAPI insertPhotoOfDiy");
            response = [self insertphotoofdiy: [wTools getUserID] token: [wTools getUserToken] album_id: weakSelf.albumId image: image];
            
            NSLog(@"response: %@", response);
            responseImageStr = response;
            NSLog(@"responseImageStr: %@", responseImageStr);
        }];
        
        [operation setCompletionBlock:^{
            NSLog(@"Operation 1-%d Completed", i);
            //photoFinished++;
        }];
        [self.queue addOperation: operation];
    }
}

- (UIImage *)imageRatioCalculation:(UIImage *)img {
    NSLog(@"");
    NSLog(@"imageRatioCalculationAndResize");
    NSLog(@"");
    
    // The format of Screen Bounds is in point
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    NSLog(@"screenBounds: %@", NSStringFromCGRect(screenBounds));
    CGFloat heightRatio = 0;
    CGFloat widthRatio = 0;
    
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    NSLog(@"screenScale: %f", screenScale);
    
    // The format of Screen Bounds is in pixel
    CGSize screenSize = CGSizeMake(screenBounds.size.width * screenScale, screenBounds.size.height * screenScale);
    NSLog(@"");
    NSLog(@"screenSize: %@", NSStringFromCGSize(screenSize));
    
    NSLog(@"");
    NSLog(@"img.size: %@", NSStringFromCGSize(img.size));
    
    if ((img.size.height > screenSize.height) || (img.size.width > screenSize.width)) {
        NSLog(@"");
        NSLog(@"img.size.height: %f", img.size.height);
        NSLog(@"screenSize.height: %f", screenSize.height);
        
        NSLog(@"");
        
        heightRatio = img.size.height / screenSize.height;
        NSLog(@"heightRatio: %lu", (unsigned long)heightRatio);
        
        NSLog(@"img.size.width: %f", img.size.width);
        NSLog(@"screenSize.width: %f", screenSize.width);
        
        NSLog(@"");
        
        widthRatio = img.size.width / screenSize.width;
        NSLog(@"widthRatio: %lu", (unsigned long)widthRatio);
    }
    
    CGFloat ratio = heightRatio < widthRatio ? heightRatio : widthRatio;
    
    if (ratio == 0) {
        ratio = 1;
    }
    
    NSLog(@"ratio: %lu", (unsigned long)ratio);
    
    NSLog(@"");
    
    NSLog(@"img.size.width: %f", img.size.width);
    NSLog(@"img.size.height: %f", img.size.height);
    
    NSLog(@"");
    
    NSLog(@"img.size.width / ratio: %f", img.size.width / ratio);
    NSLog(@"img.size.height / ratio: %f", img.size.height / ratio);
    
    NSLog(@"");
    
    CGSize newSize = CGSizeMake(img.size.width / ratio, img.size.height / ratio);
    NSLog(@"newSize.width: %f", newSize.width);
    NSLog(@"newSize.height: %f", newSize.height);
    
//    UIImage *image = [self imageWithImage: img scaledToSize: newSize];
    
//    UIImage *scaledImage = [UIImage imageWithCGImage: [img CGImage]
//                                               scale: img.scale * screenScale
//                                         orientation: img.imageOrientation];

    UIImage *scaledImage = [img resizedImage: newSize
                        interpolationQuality: 4];
    
    return scaledImage;
}

/*
- (UIImage *)imageWithImage:(UIImage *)image
               scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect: CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSLog(@"");
    NSLog(@"newImage: %@", newImage);
    
    return newImage;
}

- (void)saveImage:(UIImage *)newImage {
    NSLog(@"saveImage");
    NSData *imageData = UIImagePNGRepresentation(newImage);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex: 0];
    
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent: [NSString stringWithFormat: @"%@.png", @"cached"]];
    
    NSLog(@"pre writing to file");
    
    if (![imageData writeToFile: imagePath atomically: NO]) {
        NSLog(@"Failed to cache image data to disk");
    } else {
        NSLog(@"the cachedImagedPath is %@",imagePath);
    }
}
 */

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    NSLog(@"----------------------");
    NSLog(@"observeValueForKeyPath");
    NSLog(@"object: %@", object);
    
    NSLog(@"self.queue.operations.count: %lu", (unsigned long)self.queue.operations.count);
    
    if (object == self.queue && [keyPath isEqualToString: @"operations"]) {
        if (self.queue.operations.count == 0) {
            NSLog(@"queue has completed");
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [hud hideAnimated: YES];
                
                [dataTaskArray removeAllObjects];
                
                [self.navigationController popViewControllerAnimated: YES];
                
                if ([self.delegate respondsToSelector: @selector(afterSendingImages:)]) {
                    [self.delegate afterSendingImages: self];
                }
            }];
        }
    }
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if ([_phototype isEqualToString:@"1"]) {
        NSString *str = [NSString stringWithFormat:@" %@（ %lu / %ld ）",NSLocalizedString(@"PicText-confirm", @""),(unsigned long)[imageArray count] + _selectedImgAmount,(long)_selectrow];
        
        [okbtn setTitle:str forState:UIControlStateNormal];
    }
    
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"assetsFetchResults.count: %lu", (unsigned long)assetsFetchResults.count);
    return assetsFetchResults.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    
    //photocell
    UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"photocell" forIndexPath:indexPath];
    
    reusableview = footerview;
    
    //        return myCell;
    
    return reusableview;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCollectionViewCell *myCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"CollerctionCell" forIndexPath:indexPath];
    
    NSInteger currentTag = myCell.tag;
    myCell.tag = currentTag;
    
    //NSInteger reuseCount = ++myCell.reuseCount;
    
    // A representation of an image, video or Live Photo in the Photos library.
    PHAsset *asset = assetsFetchResults[indexPath.item];
    
    // If imagesCache does have this asset, then get the image cache to pass data to
    // cell thumbnailImage
    if ([imagesCache objectForKey:asset.localIdentifier]) {
        if ([[imagesCache objectForKey: asset.localIdentifier] isKindOfClass: [NSNull class]]) {
            NSLog(@"imagesCache objectForKey: asset.localIdentifier is null");
        } else {
            NSLog(@"imagesCache objectForKey: asset.localIdentifier is not null");
            myCell.thumbnailImage = [imagesCache objectForKey: asset.localIdentifier];
        }
    } else {
        // If this asset image does not exist, then get the image from PHCachingImageManager
        myCell.thumbnailImage = nil;
        
        // A set of options affecting the delivery of still image representations
        // of Photos assets you request from an image manager.
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        
        // A Boolean value that specifies whether Photos can download the requested image from iCloud.
        options.networkAccessAllowed = YES;
        [options setVersion: PHImageRequestOptionsVersionCurrent];
        [options setResizeMode: PHImageRequestOptionsResizeModeFast];
        [options setDeliveryMode: PHImageRequestOptionsDeliveryModeOpportunistic];
        
        NSString *identifier = asset.localIdentifier;
        
        // Requests an image representation for the specified asset.
        [self.imageManager requestImageForAsset: asset
                                     targetSize: self.assetThumbnailSize
                                    contentMode: PHImageContentModeAspectFill
                                        options: options
                                  resultHandler: ^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                      
                                      if (myCell.tag == currentTag) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              //cell.thumbnailImage = result;
                                              // Set image
                                              if ([result isKindOfClass: [NSNull class]]) {
                                                  NSLog(@"result image is null");
                                              } else {
                                                  NSLog(@"result image is not null");
                                                  myCell.thumbnailImage = result;
                                              }
                                              if (![info[PHImageResultIsDegradedKey] boolValue]) {
                                                  if (result != nil) {
                                                      // Set Image Cache
                                                      [imagesCache setObject: result forKey: identifier];
                                                  }
                                              }
                                          });
                                      }
                                  }];
    }
    
    if ([imageArray containsObject:asset]) {
        // For Multiple Selection
        myCell.bgv.hidden = NO;
        myCell.imageTick.image = [UIImage imageNamed: @"ic200_circle_select_light"];
        
        // For Choosing 1 image
        //myCell.titel.hidden = NO;
        //myCell.titel.text=[NSString stringWithFormat:@"%lu",[imageArray indexOfObject:asset]+1];
    } else {
        // For Multiple Selection
        myCell.bgv.hidden = YES;
        myCell.imageTick.image = [UIImage imageNamed: @"ic200_circle_select_alpha"];
        
        // For Choosing 1 image
        //myCell.titel.hidden = YES;
    }
    
    return myCell;
}

#pragma mark - UICollectionViewFlowLayoutDelegate
//- (void)collectionView:(UICollectionView *)collectionView
//didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectItemAtIndexPath");
    
    //    if (indexPath.item == 0) {
    //        [self checkCameraPermission];
    //        return;
    //    }
    
    // If selected image in the imageArray, then remove this image object
    if ([imageArray containsObject:assetsFetchResults[indexPath.item]] ) {
        NSLog(@"imageArray containsObject:assetsFetchResults");
        [imageArray removeObject:assetsFetchResults[indexPath.item]];
    } else {
        NSLog(@"imageArray does not containsObject:assetsFetchResults");
        
        // If you only want to select 1 image
        if ([_phototype isEqualToString:@"0"]) {
            PHAsset *asset = assetsFetchResults[indexPath.item];
            
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.networkAccessAllowed = YES;
            [options setVersion:PHImageRequestOptionsVersionCurrent];
            [options setResizeMode:PHImageRequestOptionsResizeModeFast];
            [options setDeliveryMode:PHImageRequestOptionsDeliveryModeOpportunistic];
            
            CGSize size = cellSize(collectionView);
            CGFloat scale = [[UIScreen mainScreen] scale];
            size = CGSizeMake(size.width * scale, size.height * scale);
            NSLog(@"-----------------");
            NSLog(@"size: %@", NSStringFromCGSize(size));
            
            [self.imageManager requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info){
                
                if (![info[PHImageResultIsDegradedKey] boolValue]) {
                    NSLog(@"----------------------------------");
                    NSLog(@"RSKImageCropViewController Section");
                    
                    // If you want to just select 1 image, then crop image
                    RSKImageCropViewController *rsk = [[RSKImageCropViewController alloc]initWithImage:[UIImage imageWithData:imageData]];
                    rsk.delegate = self;
                    [self presentViewController: rsk animated: YES completion: nil];
                }
            }];
            return;
        }
        
        if (_selectedImgAmount != 0) {
            if (imageArray.count + _selectedImgAmount >= _selectrow) {
                //已達最大上限。
                CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                style.messageColor = [UIColor whiteColor];
                style.backgroundColor = [UIColor thirdPink];
                [self.view makeToast: @"已達最大上限"
                            duration: 2.0
                            position: CSToastPositionBottom
                               style: style];
            } else {
                [imageArray addObject:assetsFetchResults[indexPath.item]];
            }
        } else {
            if (imageArray.count >= _selectrow) {
                //已達最大上限。
                CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                style.messageColor = [UIColor whiteColor];
                style.backgroundColor = [UIColor thirdPink];
                [self.view makeToast: @"已達最大上限"
                            duration: 2.0
                            position: CSToastPositionBottom
                               style: style];
            } else {
                [imageArray addObject:assetsFetchResults[indexPath.item]];
            }
        }
    }
    [collectionView reloadData];
}

-(CGSize)collectionView:(UICollectionView *)collectionView
                 layout:(UICollectionViewLayout *)collectionViewLayout
 sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return CGSizeMake(77, 77);
    return cellSize(collectionView);
    
    /*
     NSInteger thumbsPerRow;
     if (collectionView.bounds.size.width < 400) {
     thumbsPerRow = 4;
     }
     else if (collectionView.bounds.size.width < 600) {
     thumbsPerRow = 5;
     }
     else if (collectionView.bounds.size.width < 800) {
     thumbsPerRow = 6;
     }
     else {
     thumbsPerRow = 7;
     }
     
     CGFloat width = collectionView.bounds.size.width / thumbsPerRow;
     CGSize size = {width, width};
     return size;
     */
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

CGSize cellSize(UICollectionView *collectionView) {
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

#pragma mark - ScrollView Delegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidScroll");
    
    dispatch_async(self.cacheQueue, ^{
        //[self updateCache];
    });
}

#pragma mark - RSKImageCropViewControllerDelegate

- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageCropViewController:(RSKImageCropViewController *)controller
                   didCropImage:(UIImage *)croppedImage
                  usingCropRect:(CGRect)cropRect
{
    NSLog(@"");
    NSLog(@"didCropImage");
    NSLog(@"");
    
    //myphoto.image=croppedImage;
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    if (_selectrow==1) {
        if ([self.delegate respondsToSelector:@selector(imageCropViewController:Image:)]) {
            [self.delegate imageCropViewController:self Image:croppedImage];
        }
        //[self.navigationController popViewControllerAnimated:YES];
        [self dismissViewControllerAnimated: YES completion: nil];
        
    }
    //[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark 開啟照相機
-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // 取得使用者拍攝的照片
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    // 存檔
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    // 關閉拍照程式
    [self dismissViewControllerAnimated:YES completion:^(void){
        // For old device such as iPod Touch 5 & iPhone5s
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO],[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:NO]];
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
            assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
            NSLog(@"assetsFetchResults.count: %lu", (unsigned long)assetsFetchResults.count);
            NSLog(@"mycov reloadData");
            
            [imageArray addObject: assetsFetchResults[0]];
            
            [mycov reloadData];
        });
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    // 當使用者按下取消按鈕後關閉拍照程式
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Caching

- (void)resetCache {
    [self.imageManager stopCachingImagesForAllAssets];
    [self.cachingIndexes removeAllObjects];
    self.lastCacheFrameCenter = 0;
}

- (void)updateCache {
    CGFloat currentFrameCenter = CGRectGetMidY(mycov.bounds);
    if (fabs(currentFrameCenter - self.lastCacheFrameCenter) < CGRectGetHeight(mycov.bounds)/3) {
        // Haven't scrolled far enough yet
        return;
    }
    self.lastCacheFrameCenter = currentFrameCenter;
    
    static NSInteger numOffscreenAssetsToCache = 60;
    
    NSArray *visibleIndexes = [mycov.indexPathsForVisibleItems sortedArrayUsingSelector:@selector(compare:)];
    
    if (!visibleIndexes.count) {
        [self.imageManager stopCachingImagesForAllAssets];
        return;
    }
    
    NSInteger firstItemToCache = ((NSIndexPath *)visibleIndexes[0]).item - numOffscreenAssetsToCache/2;
    firstItemToCache = MAX(firstItemToCache, 0);
    
    NSInteger lastItemToCache = ((NSIndexPath *)[visibleIndexes lastObject]).item + numOffscreenAssetsToCache/2;
    if (assetsFetchResults) {
        lastItemToCache = MIN(lastItemToCache, assetsFetchResults.count - 1);
    }
    
    NSMutableArray * indexesToStopCaching = [[NSMutableArray alloc] init];
    NSMutableArray * indexesToStartCaching = [[NSMutableArray alloc] init];
    
    // Stop caching items we scrolled past
    for (NSIndexPath * index in self.cachingIndexes) {
        if (index.item < firstItemToCache || index.item > lastItemToCache) {
            [indexesToStopCaching addObject:index];
        }
    }
    [self.cachingIndexes removeObjectsInArray:indexesToStopCaching];
    
    [self.imageManager stopCachingImagesForAssets:[self assetsAtIndexPaths:indexesToStopCaching]
                                       targetSize:self.assetThumbnailSize
                                      contentMode:PHImageContentModeAspectFill
                                          options:nil];
    
    // Start caching new items in range
    for (NSInteger i = firstItemToCache; i < lastItemToCache; i++) {
        NSIndexPath * index = [NSIndexPath indexPathForItem:i inSection:0];
        if (![self.cachingIndexes containsObject:index]) {
            [indexesToStartCaching addObject:index];
            [self.cachingIndexes addObject:index];
        }
    }
    
    [self.imageManager startCachingImagesForAssets:[self assetsAtIndexPaths:indexesToStartCaching]
                                        targetSize:self.assetThumbnailSize
                                       contentMode:PHImageContentModeAspectFill
                                           options:nil];
    
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths {
    if (!indexPaths.count) {
        return nil;
    }
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    
    for (NSIndexPath *indexPath in indexPaths) {
        PHAsset *asset = [self currentAssetAtIndex:indexPath.item];
        [assets addObject:asset];
    }
    
    return assets;
}

#pragma mark -
- (NSString *)insertphotoofdiy:(NSString *)uid
                         token:(NSString *)token
                      album_id:(NSString *)album_id
                         image:(UIImage *)image
{
    // Dictionary that holds post parameters. You can set your post parameters that your server accepts or programmed to accept.
    NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
    [_params setObject:uid forKey:@"id"];
    [_params setObject:token forKey:@"token"];
    [_params setObject:album_id forKey:@"album_id"];
    [_params setObject:[self signGenerator2:_params] forKey:@"sign"];
    
    // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
    NSString *BoundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";
    
    // string constant for the post parameter 'file'. My server uses this name: `file`. Your's may differ
    NSString* FileParamConstant = @"file";
    
    // the server url to which the image (or the media) is uploaded. Use your server url here
    NSURL* requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",ServerURL,@"/insertphotoofdiy",@"/1.1"]];
    
    // create request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];//[[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval: [kTimeOutForPhoto floatValue]];
    [request setHTTPMethod:@"POST"];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in _params) {
        NSLog(@"");
        NSLog(@"param: %@", param);
        
        // start tag
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        
        // end tag
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add image data
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    
    if (imageData) {
        // start tag
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        
        // end tag
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // close form
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set HTTP_ACCEPT_LANGUAGE in HTTP Header
    [request setValue: @"zh-TW,zh" forHTTPHeaderField: @"HTTP_ACCEPT_LANGUAGE"];
    
    // set URL
    //[request setURL:requestURL];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __block NSString *str;
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = [kTimeOutForPhoto floatValue];
    config.timeoutIntervalForResource = [kTimeOutForPhoto floatValue];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration: config];
    
    dataTask = [session dataTaskWithRequest: request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"insertphotoofdiy");
        
        if (error) {
            NSLog(@"dataTaskWithRequest error: %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                hud.detailsLabel.text = @"網路不穩";
                hud.detailsLabel.font = [UIFont systemFontOfSize: kFontSizeForConnection];
            });
            return;
        }
        if ([response isKindOfClass: [NSHTTPURLResponse class]]) {
            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
            
            if (statusCode != 200) {
                NSLog(@"dataTaskWithRequest HTTP status code: %ld", (long)statusCode);
                return;
            }
        }
        if (!error && data) {
            str = [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding];
            
            NSLog(@"str: %@", str);
            
            NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [str dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
            
            NSLog(@"dic: %@", dic);
            
            if ([dic[@"result"] boolValue]) {
                NSMutableArray *imageInfoArray = [NSMutableArray new];
                
                for (NSMutableDictionary *photo in dic[@"data"][@"photo"]) {
                    [imageInfoArray addObject: photo[@"photo_id"]];
                }
                NSLog(@"imageInfoArray.count: %lu", (unsigned long)imageInfoArray.count);
                
                photoFinished = imageInfoArray.count;
                
                [imageInfoArray removeAllObjects];
                imageInfoArray = nil;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    hud.detailsLabel.text = @"";
                });
            } else {
                NSLog(@"Error Message: %@", dic[@"message"]);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    hud.detailsLabel.text = @"網路不穩";
                    hud.detailsLabel.font = [UIFont systemFontOfSize: kFontSizeForConnection];
                });
            }
        }
        dispatch_semaphore_signal(semaphore);
    }];
    NSLog(@"task resume");
    [dataTask resume];
    [dataTaskArray addObject: dataTask];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        hud.label.text = [NSString stringWithFormat: @"%ld 張照片上傳完成", (long)photoFinished];
    });
    
    return str;
}

- (NSString *)signGenerator2:(NSDictionary *)parameters {
    //NSLog(@"signGenerator2");
    
    NSString *secrectSN = @"d9$kv3fk(ri3mv#d-kg05[vs)F;f2lg/";
    NSString *signSN = @"";
    NSArray *keys = [parameters allKeys];
    
    keys = [keys sortedArrayUsingComparator: ^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare: obj2 options: NSNumericSearch];
    }];
    
//    NSCharacterSet *URLCombinedCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"\"#%/:<>?@[\\]^`{|},="] invertedSet];
    //:/?@!$&'()*+,;=
    
    NSString *requestOriginal = @"";
    
    for (int i = 0 ;i < keys.count ;i++) {
        //NSLog(@"i: %d", i);
        //NSLog(@"keys.count: %lu", (unsigned long)keys.count);
        
        NSString *key = keys[i];
        NSString *value = parameters[key];
        // requestOriginal=[NSString stringWithFormat:@"%@%@=%@",requestOriginal,key,[value stringByAddingPercentEncodingWithAllowedCharacters:URLCombinedCharacterSet]];
        
        requestOriginal = [NSString stringWithFormat:@"%@%@=%@", requestOriginal, key, value];
        //NSLog(@"requestOriginal: %@", requestOriginal);
        
        if (i < keys.count - 1) {
            //NSLog(@"i < keys.count - 1");
            requestOriginal = [NSString stringWithFormat:@"%@&", requestOriginal];
            //NSLog(@"requestOriginal: %@", requestOriginal);
        }
    }
    //requestOriginal=[requestOriginal stringByReplacingOccurrencesOfString:@"%@20" withString:@"+"];
    
    //NSLog(@"requestOriginal lowercaseString");
    NSString *requestLow = [requestOriginal lowercaseString];
    //NSLog(@"%@",requestLow);
    
    //NSLog(@"requestLow,secrectSN");
    requestLow = [NSString stringWithFormat:@"%@%@",requestLow,secrectSN];
    //NSLog(@"%@",requestLow);
    
    //NSLog(@"requestLow.MD5");
    requestLow = requestLow.MD5;
    //NSLog(@"%@",requestLow);
    
    //NSLog(@"requestLow.lowercaseString");
    requestLow = requestLow.lowercaseString;
    //NSLog(@"%@",requestLow);
    
    signSN = requestLow;
    //NSLog(@"signSN: %@", signSN);
    
    return signSN;
}

#pragma mark - Custom Error Alert Method
- (void)showCustomErrorAlert: (NSString *)msg
{
    CustomIOSAlertView *errorAlertView = [[CustomIOSAlertView alloc] init];
    //[errorAlertView setContainerView: [self createErrorContainerView: msg]];
    [errorAlertView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstPink] badgeName:nil];
    [errorAlertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    [errorAlertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    [errorAlertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    errorAlertView.arrangeStyle = @"Horizontal";
    
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

@end

