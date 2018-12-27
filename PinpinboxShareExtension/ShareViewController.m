//
//  ShareViewController.m
//  PinpinboxShareExtension
//
//  Created by Antelis on 2018/12/11.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "ShareViewController.h"
#import "UserInfo.h"
#import "UserAPI.h"
#import "ShareItem.h"
#import "PDFUploader.h"

#import "UIColor+Extensions.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <UserNotifications/UserNotifications.h>

@interface  ThumbnailCollectionViewCell : UICollectionViewCell<ItemPostLoadDelegate,CAAnimationDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UIImageView *typeView;
@property (weak, nonatomic) IBOutlet UITextView *comment;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (weak, nonatomic) IBOutlet UIView *progressMask;
@property (nonatomic) CGFloat taskProgress;

@end

@interface AlbumCellView : UITableViewCell
@property(weak, nonatomic) IBOutlet UIImageView *album;
@property(weak, nonatomic) IBOutlet UILabel *albumName;
@property(weak, nonatomic) IBOutlet UILabel *albumOwner;
@property(weak, nonatomic) IBOutlet UILabel *albumDate;
@property(weak, nonatomic) IBOutlet UIImageView *albumStatus;
@end


@interface ShareViewController ()<UITableViewDelegate, UITableViewDataSource,
                                  UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,
                                  UploadProgressDelegate,PDFUploaderDelegate>
@property(weak, nonatomic) IBOutlet UILabel *userName;
@property(weak, nonatomic) IBOutlet UITableView *albumList;
@property(weak, nonatomic) IBOutlet UICollectionView *photoList;
@property(weak, nonatomic) IBOutlet UITextView *textArea;
@property(weak, nonatomic) IBOutlet UIView *notLoginCover;
@property(weak, nonatomic) IBOutlet UITextView *coverNotice;
@property(nonatomic) NSMutableArray *albumlist;
@property(nonatomic ,strong) NSMutableArray *shareItems;
@property(nonatomic, strong) NSString *selectedAlbum;
@property(nonatomic, strong) NSString *albumNames;

@property(nonatomic, strong) NSMutableArray *postRequestList;
@property(nonatomic) IBOutlet UIView *progressView;
@property(nonatomic) IBOutlet UIProgressView *postProgress;
@property(nonatomic) IBOutlet UITextView *postProgressStatus;
@property(nonatomic) BOOL isLoading;
@property(nonatomic) NSInteger successCount;
@property(nonatomic) NSInteger failCount;

//@property(nonatomic) PDFUploader *pdfUploader;
@end



#pragma mark - Cell for photo
@implementation ThumbnailCollectionViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
    self.taskProgress = 0;
    self.layer.shadowOpacity = 0.2f;
    self.layer.shadowRadius = 3;
    self.layer.shadowOffset = CGSizeMake(2,3);
    self.layer.shadowColor = [UIColor grayColor].CGColor;
}
- (void)setTaskProgress:(CGFloat)taskProgress {
    _taskProgress = taskProgress;
    [self updateProgress];
}
- (void)animationDidStart:(CAAnimation *)anim {
    NSLog(@"animationDidStart %@",anim);
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    NSLog(@"animationFinished %@",anim);
}
- (void)animatePieEffectWithInterval:(CGFloat) interval {
    self.progressMask.hidden = YES;
    self.progressMask.layer.mask = nil;
    self.progressMask.hidden = NO;
    self.progressMask.backgroundColor = [UIColor clearColor];
    
    CAShapeLayer *progressLayer = [[CAShapeLayer alloc] init];
    [progressLayer setFillColor:[UIColor grayColor].CGColor];
    
    CGFloat w = self.progressMask.frame.size.width;
    CGFloat h = self.progressMask.frame.size.height;
    progressLayer.frame = CGRectMake(0, 0, w, h);//self.progressMask.layer.frame;
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"path"];
    anim.duration = interval;
    anim.autoreverses = NO;
    anim.removedOnCompletion = YES;
    anim.speed = 1;
    NSMutableArray *vals = [NSMutableArray array];
    CGFloat u = 1.0/30.0;
    
    for (int i = 0; i< 30 ;i++) {
        CGFloat rads =  (u*i)* (M_PI*2)-M_PI*0.5;
        
        UIBezierPath *p = [UIBezierPath bezierPathWithArcCenter:CGPointMake(w/2, h/2) radius:(w*1.25)/2 startAngle:-M_PI*0.5 endAngle:rads clockwise:YES];
        [p addLineToPoint:CGPointMake(w/2, h/2)];
        [vals addObject:(__bridge id)p.CGPath];
    }
    anim.values  = vals;
    anim.delegate = self;
    
    [self.progressMask.layer addSublayer:progressLayer];
    progressLayer.opacity = 0.35;
    progressLayer.masksToBounds = YES;
    
    [progressLayer addAnimation:anim forKey:@"pieAnim"];
    
}
- (void)updateProgress {
    self.progressMask.hidden = NO;
    
    CAShapeLayer *progressLayer = [[CAShapeLayer alloc] init];
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    progressLayer.frame = CGRectMake(0, 0, w, h);
    CGFloat rads = self.taskProgress * (M_PI*2)-M_PI*0.5;
    
    UIBezierPath *p = [UIBezierPath bezierPathWithArcCenter:CGPointMake(w/2, h/2) radius:(w*1.25)/2 startAngle:M_PI*1.5 endAngle:rads clockwise:YES];
    [p addLineToPoint:CGPointMake(w/2, h/2)];
    [progressLayer setFillColor:[UIColor blackColor].CGColor];
    [progressLayer setPath:p.CGPath];
    self.progressMask.layer.mask = progressLayer;
}
- (void)loadCompleted:(UIImage *)thumbnail type:(NSString *)type hasVideo:(BOOL)hasVideo isDark:(BOOL)isDark {
    self.thumbnailView.image = thumbnail;
    self.typeView.hidden = !hasVideo;
    if ([type isEqualToString:(__bridge NSString *)kUTTypeURL] ||
        [type isEqualToString:(__bridge NSString *)kUTTypeText] ||
        [type isEqualToString:(__bridge NSString *)kUTTypeMovie] ) {
        self.comment.text = hasVideo? @"影片": @"其他";
        
    } else if ([type isEqualToString:(__bridge NSString *)kUTTypeImage]){
        self.comment.text = @"圖片";
    } else if ([type isEqualToString:(__bridge NSString *)kUTTypePDF]){
        self.comment.text = @"PDF";
    }
    self.comment.textColor = isDark? [UIColor whiteColor]:[UIColor darkGrayColor];
    [self.loading stopAnimating];
    
}

@end

#pragma mark - Cell for album list
@implementation AlbumCellView
- (void)loadAlbum:(NSDictionary *)data {
    NSDictionary *album = data[@"album"];
    
    if (![album isKindOfClass:[NSNull class]]) {
        self.albumName.text = album[@"name"];
        self.albumDate.text = album[@"insertdate"];
        NSString *act = album[@"act"];
        
        if ([act isEqualToString: @"open"]) {
            UIImage *i = [UIImage imageNamed:@"ic200_act_open_white.png"];
            self.albumStatus.image = [i imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            
        } else {
            UIImage *i = [UIImage imageNamed:@"ic200_act_close_white.png"];
            self.albumStatus.image = [i imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        self.albumStatus.tintColor = [UIColor firstPink];
        self.albumOwner.text = @"";
        
        if (album[@"cover"] && ![album[@"cover"] isKindOfClass:[NSNull class]]) {
            NSString *c = album[@"cover"];
            __block typeof(self) wself = self;
            NSURL *u = [NSURL URLWithString:c];
            
            [UserAPI loadImageWithURL:u completionBlock:^(UIImage * _Nullable image) {
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        wself.album.image = image;
                    });
                }
            }];
            
        }
    }
}
@end

#pragma mark - share extension VC
@implementation ShareViewController

- (void)viewDidLoad {
    
    self.albumlist = [NSMutableArray array];
    self.postRequestList = [NSMutableArray array];
    self.failCount = 0;
    self.successCount = 0;
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    UIView *view = [self.view viewWithTag:1010];
    view.layer.borderColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:0.5].CGColor;
    view.layer.borderWidth = 0.5;
    
    if ([UserInfo getUserId].length < 1 ) {
        self.notLoginCover.hidden = NO;
        return;
    } else {
        [self displayExtensionContext];
        __block typeof(self) wself = self;
        [UserAPI refreshTokenWithCompletionBlock:^(NSDictionary * _Nonnull result, NSError * _Nonnull error) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [wself showErrorMessage:@"無法取得用戶資料，請稍後再試"];
                });
            } else {
                NSString *tok = result[@"token"];
                
                [UserInfo setUserInfo:[UserInfo getUserId] token:tok];
                [UserAPI userProfileWithCompletionBlock:^(NSDictionary *result, NSError *error) {
                    if (result) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            wself.userName.text = result[@"nickname"];
                            [wself loadAlbumList];
                            
                        });
                        
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [wself showErrorMessage:@"無法取得用戶資料，請稍後再試"];
                        });
                    }
                    
                }];
            }
        }];
        
    }
}

- (void)displayExtensionContext {
    self.shareItems = [NSMutableArray array];
    
    NSExtensionContext *cxt = self.extensionContext;
    if (cxt) {
        NSArray *items = cxt.inputItems;
        //__block typeof(self) wself = self;
        for (NSExtensionItem *item in items) {
            NSArray *attachments = item.attachments;
            for (NSItemProvider *p in attachments) {
                if ([p hasItemConformingToTypeIdentifier:(__bridge NSString *)kUTTypeImage]) {
                    [self addShareItemWithItemProvider:p type:(__bridge NSString *)kUTTypeImage];
                } else if ([p hasItemConformingToTypeIdentifier:(__bridge NSString *)kUTTypeText]) {
                    [self addShareItemWithItemProvider:p type:(__bridge NSString *)kUTTypeText];
                } else if ([p hasItemConformingToTypeIdentifier:(__bridge NSString *)kUTTypeMovie]) {
                    [self addShareItemWithItemProvider:p type:(__bridge NSString *)kUTTypeMovie];
                } else if ([p hasItemConformingToTypeIdentifier:(__bridge NSString *)kUTTypeURL]) {
                    if ([p hasItemConformingToTypeIdentifier:(__bridge NSString *)kUTTypePDF])
                        [self addShareItemWithItemProvider:p type:(__bridge NSString *)kUTTypePDF];
                    else
                        [self addShareItemWithItemProvider:p type:(__bridge NSString *)kUTTypeURL];
                }
                
            }
        }
        
        [self.photoList reloadData];
    }
}
- (BOOL)checkItemProvider:(NSItemProvider *)p  type:(NSString *)type {
    if ([type isEqualToString:(__bridge NSString *)kUTTypeURL]) {
        return  ([p.registeredTypeIdentifiers containsObject:(__bridge NSString *)kUTTypeURL] && ![p.registeredTypeIdentifiers containsObject:(__bridge NSString *)kUTTypeFileURL]) ||
                [p.registeredTypeIdentifiers containsObject:(__bridge NSString *)kUTTypePDF];
    }
    return YES;
}
- (void)addShareItemWithItemProvider:(NSItemProvider *)p  type:(NSString *)type{
    if ([self checkItemProvider:p type:type]) {
        ShareItem *i = [[ShareItem alloc] initWithItemProvider:p type:type];
        
        [self.shareItems addObject:i];
    }
    
}
- (void)setTextAreaText:(NSString *)text type:(NSString *)type{
    __block typeof(self) wself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        wself.textArea.text = [NSString stringWithFormat:@"TYPE: %@\n\nPATH: %@",type, text];
    });
}
#pragma mark -
- (BOOL)ifAvailableToAppend:(int)pages {
    if (_selectedAlbum) {
        for (NSDictionary *data in self.albumlist) {
            NSDictionary *a = data[@"album"];
            NSDictionary *user = data[@"usergrade"];
            if ([a[@"album_id"] isEqualToString:_selectedAlbum]) {
                int count = [a[@"count_photo"] intValue];
                int limit = [user[@"photo_limit_of_album"] intValue];
                return (count+pages) <= limit;
            }
        }
    }
    return YES;
}
- (int)availablePages {
    if (_selectedAlbum) {
        for (NSDictionary *data in self.albumlist) {
            NSDictionary *a = data[@"album"];
            NSDictionary *user = data[@"usergrade"];
            NSString *aa = [a[@"album_id"] stringValue];
            if ([aa isEqualToString:_selectedAlbum]) {
                int count = [a[@"count_photo"] intValue];
                int limit = [user[@"photo_limit_of_album"] intValue];
                return limit - count;
            }
        }
    }
    
    return 0;
}
#pragma mark - post
- (void)processFinishedTask:(NSString *)taskId success:(BOOL)success {
    
    NSUInteger i = [self.postRequestList indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[PDFUploader class]]) {
            PDFUploader *p = (PDFUploader *)obj;
            if (p.taskId && [p.taskId isEqualToString:taskId]) {
                *stop = YES;
                return YES;
            }
        } else if ([obj isKindOfClass:[NSString class]]) {
            NSString *s = (NSString *)obj;
            if ([s isEqualToString:taskId]) {
                *stop = YES;
                return YES;
            }
        }
        
        return NO;
    }];
    if (i >= 0 && i < self.postRequestList.count ) {
        if (success)
            self.successCount++;
        else
            self.failCount++;
        self.postProgressStatus.text = [NSString stringWithFormat:@"預定上傳：%d\r\n上傳完成：%d，上傳失敗：%d ",(int)self.shareItems.count,(int)self.successCount, (int)self.failCount];
        [self.postRequestList removeObjectAtIndex:i];
        [self updateProgress];
    }
}
- (void)postItem:(ShareItem *)item {
    __block typeof(self) wself = self;
    if (item.hasVideo) {
        if ([item.objType isEqualToString:(__bridge NSString *) kUTTypeURL] ||
            [item.objType isEqualToString:(__bridge NSString *) kUTTypeText]) {
            NSString *uuid = [UserAPI insertVideoWithAlbum_id:_selectedAlbum videoURLPath:[item.url absoluteString] progressDelegate:self completionBlock:^(NSDictionary * _Nonnull result, NSString * _Nonnull taskId, NSError * _Nonnull error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [wself processFinishedTask:taskId success:(error == nil)];
//                        for (int i = 0; i< self.postRequestList.count; i++){
//                            NSString *uid = [self.postRequestList objectAtIndex:i];
//                            if ([taskId isEqualToString:uid]) {
//                                //[wself finishEffect:i];
//                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                                    [wself processFinishedTask:taskId success:(error == nil)];
//                                });
//
//                                break;
//
//                            }
//                        }
                        
                    });
            }];
            if (uuid)
                [self.postRequestList addObject:uuid];
            
        } else if ([item.objType isEqualToString:(__bridge NSString *) kUTTypeMovie]) {
            if (item.vidDuration <= 31 && item.url) {
                NSString *uuid = [UserAPI insertVideoWithAlbum_id:_selectedAlbum videopath:[item.url path] progressDelegate:self  completionBlock:^(NSDictionary * _Nonnull result, NSString * _Nonnull taskId, NSError * _Nonnull error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [wself processFinishedTask:taskId success:(error == nil)];
                        });
                }];
                
                if (uuid)
                    [self.postRequestList addObject:uuid];
            }
        }
        
        
    } else if ([item.objType isEqualToString:(__bridge NSString *) kUTTypeImage]) {
        
        NSData *imgdata = nil;
        if (item.url) {
            imgdata = [NSData dataWithContentsOfURL:item.url];
        
            NSString *uuid = [UserAPI insertPhotoWithAlbum_id:_selectedAlbum imageData:imgdata progressDelegate:self  completionBlock:^(NSDictionary * _Nonnull result, NSString *taskId, NSError * _Nonnull error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [wself processFinishedTask:taskId success:(error == nil)];
                });
                
            }];
            
            if (uuid)
                [self.postRequestList addObject:uuid];
        }
        
    } else if ([item.objType isEqualToString:(__bridge NSString *) kUTTypePDF]) {
        //if (!_pdfUploader) {
            
            __block PDFUploader *pdfuploader = [[PDFUploader alloc] initWithAlbumID:_selectedAlbum availablePages:[self availablePages] infoDelegate:self progressblock:^(int currentPage, int totalPage) {
                
            } exportFinishedblock:^(NSError * _Nullable error, NSArray * _Nullable icons, NSArray * _Nullable ids) {
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [wself processFinishedTask:pdfuploader.taskId success:NO];
                    });
                }
                
            } uploadProgressBlock:^(int currentPage, int totalPage, NSString * _Nonnull desc) {
                
            } uploadResultBlock:^(NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [wself processFinishedTask:pdfuploader.taskId success:(error == nil)];
                });
            }];
            [self.postRequestList addObject:pdfuploader];
            [pdfuploader exportPagesToImages:item.url];
        //}
    }
}
- (IBAction)postShareItem:(id)sender {
    [self.shareItems filterUsingPredicate:[NSPredicate predicateWithFormat:@"vidDuration < 31"]];
    //[self.shareItems filterUsingPredicate:[NSPredicate predicateWithFormat:@"objType ==  'public.text'"]];
    self.postProgress.progress = 0;
    if (self.extensionContext) {
        
        if (_selectedAlbum) {
            self.progressView.hidden = NO;
            for (ShareItem *i in self.shareItems) {
                [self postItem:i];
            }
            
        }
        
        
    }
}
#pragma mark -
- (void)showErrorMessage:(NSString *)message {
    
    self.coverNotice.text = message;
    self.notLoginCover.hidden = NO;
    [self.shareItems removeAllObjects];
    [self.albumlist removeAllObjects];
}
#pragma mark -
- (IBAction)cancelAndFinish:(id)sender {
    
    for (int i = 0 ; i< self.postRequestList.count;i++) {
        
        if ([[self.postRequestList objectAtIndex:i] isKindOfClass:[PDFUploader class]]) {
            PDFUploader *p = [self.postRequestList objectAtIndex:i];
            [p cacenlCurrentWork];
        }
        
    }
    
    [self.shareItems removeAllObjects];
    [self.albumlist removeAllObjects];
    
    NSExtensionContext *cxt = self.extensionContext;
    
    [cxt completeRequestReturningItems:nil completionHandler:nil];
    
}
- (void)trySendLocalNotification:(NSString *)message albumid:(NSString *)albumid {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    __block typeof(self) wself = self;
    [center requestAuthorizationWithOptions:UNAuthorizationOptionBadge|UNAuthorizationOptionAlert|UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (!error) {
            [wself sendLocalNotification:message albumid: albumid];
        }
    }];
}
- (void)sendLocalNotification:(NSString *)message albumid:(NSString *)albumid {
    
    if ([UserInfo getUserId].length < 1 ) {
        NSExtensionContext *cxt = self.extensionContext;
        [cxt completeRequestReturningItems:nil completionHandler:nil];
        return;
    }
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNMutableNotificationContent *cnt = [[UNMutableNotificationContent alloc] init];
    
    cnt.title = @"已分享至Pinpinbox！";
    cnt.subtitle = message;
    if (albumid.length > 1)
        cnt.body = [NSString stringWithFormat:@"★彡 Pinpinbox相本[%@]已更新 ★彡", albumid];
    else {
        cnt.body = [NSString stringWithFormat:@"★彡 Pinpinbox相本已更新 ★彡"];
    }
    cnt.sound = UNNotificationSound.defaultSound;
    // add album data in cnt.userinfo
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1.0 repeats:false];
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"PinpinboxContentID" content:cnt trigger:trigger];
    NSExtensionContext *cxt = self.extensionContext;
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"addNotificationRequest %@",error);
        }
        
        [cxt completeRequestReturningItems:nil completionHandler:^(BOOL expired) {
            
        }];
    }];
}
#pragma mark -
- (void)loadAlbumList {
    if (!self.isLoading) {
        __block typeof(self) wself = self;
        self.isLoading = (self.albumlist.count > 0);
        [UserAPI loadAlbumListWithCompletionBlock:self.albumlist.count completionBlock:^(NSDictionary * _Nonnull result, NSError * _Nonnull error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIActivityIndicatorView *v = (UIActivityIndicatorView *)[wself.albumList viewWithTag:54321];
                
                if (v) {
                    [v stopAnimating];
                    [v removeFromSuperview];
                    [wself.albumList setContentInset:UIEdgeInsetsZero];
                    wself.albumList.bounces = YES;
                }
                
            });
            
            if (result) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSArray *list = [result objectForKey:@"data"];
                    int itemcount = (int)self.shareItems.count;
                    NSMutableArray *filtered = [NSMutableArray array];
                    [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSDictionary *data = (NSDictionary *)obj;
                        NSDictionary *album = data[@"album"];
                        int count = [album[@"count_photo"] intValue];
                        NSDictionary *user = data[@"usergrade"];
                        int limit = [user[@"photo_limit_of_album"] intValue];
                        if (itemcount + count <= limit)
                            [filtered addObject:obj];
                        
                    }];
                    [wself.albumlist addObjectsFromArray:filtered];
                    if (filtered.count) {
                        [wself.albumList reloadData];
                    }
                    wself.isLoading = NO;
                    
                    //[self displayExtensionContext];
                    
                });
            }
        }];
    }
    self.navigationController.title = @"Pinpinbox";
}
- (void)updateProgress {
    
    self.progressView.hidden = NO;
    
    self.postProgress.progress = (float)(self.successCount+self.failCount)/(float)(self.shareItems.count);
    if (self.shareItems.count <= (self.successCount+self.failCount)) {
        UIBarButtonItem *post = self.navigationItem.rightBarButtonItem;
        if (post)
            post.enabled = NO;
        [self performSelector:@selector(postFinished) withObject:nil afterDelay:3];
    }
}
- (void)postFinished {
    [self trySendLocalNotification:@"" albumid:_albumNames? _albumNames : @""];
    [self cancelAndFinish:nil];
}
- (void)finishEffect:(NSInteger)idx {
    __block typeof(self.photoList) list = self.photoList;
    dispatch_async(dispatch_get_main_queue(), ^{
        ThumbnailCollectionViewCell *cell = (ThumbnailCollectionViewCell *)[list cellForItemAtIndexPath:[NSIndexPath indexPathForItem:idx inSection:0]];
    if (cell) {
        
        [cell animatePieEffectWithInterval:1.0];
    }
    });
}
- (void)tryRefreshThumbnailProgress:(NSInteger)idx progress:(CGFloat)progress {
    __block typeof(self.photoList) list = self.photoList;
    dispatch_async(dispatch_get_main_queue(), ^{
        ThumbnailCollectionViewCell *cell = (ThumbnailCollectionViewCell *)[list cellForItemAtIndexPath:[NSIndexPath indexPathForItem:idx inSection:0]];
        if (cell)
            cell.taskProgress = progress;
        else
            NSLog(@"cell not found %ld",(long)idx);
    });
    
}
#pragma mark -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        UIBarButtonItem *post = self.navigationItem.rightBarButtonItem;
        if (post)
            post.enabled = YES;
        
        _selectedAlbum = nil;
        _albumNames = nil;
        
        if (indexPath.row < self.albumlist.count) {
            NSDictionary *data = self.albumlist[indexPath.row];
            NSDictionary *album = data[@"album"];
            
            _selectedAlbum = [album[@"album_id"] stringValue];
            _albumNames = album[@"name"];
        }
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddAlbumCell"];
            //cell.textLabel.text = @"新增相本";
            return cell;
        }
            break;
    }
    
            
    AlbumCellView *cell = [tableView dequeueReusableCellWithIdentifier:@"AlbumCell"];
    if (!cell)
        cell = [[AlbumCellView alloc] init];
    [cell loadAlbum:[self.albumlist objectAtIndex:indexPath.row]];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
            break;
    }
            
    return self.albumlist.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
/*
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
            break;
    }
    return 28;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"";
            break;
        
    }
    return @"我的作品";
}
 */
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.progressView.hidden) return;
    switch (indexPath.section) {
        case 0:
            break;
        default:{
    
            if ( (indexPath.row == self.albumlist.count-1) && !self.isLoading) {
                CGFloat contentHeight = tableView.contentSize.height;
                CGFloat listHeight = tableView.frame.size.height ;
                BOOL canLoad = contentHeight > listHeight;
                if (canLoad && (contentHeight-tableView.contentOffset.y-96 <= (listHeight))){
                    UIView *v = [tableView viewWithTag:54321];
                    if (!self.isLoading && (v == nil)) {
                        UIEdgeInsets u = tableView.contentInset;
                        [tableView setContentInset:UIEdgeInsetsMake(0, u.left, 96, u.right)];
                        
                        UIActivityIndicatorView *indicator =
                        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
                        [indicator setColor:[UIColor darkGrayColor]];
                        indicator.center = CGPointMake(tableView.center.x, tableView.contentSize.height+48);
                        indicator.tag = 54321;
                        [tableView addSubview:indicator];
                        indicator.hidesWhenStopped = YES;
                        [indicator startAnimating];
                        
                        dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 2.5 * NSEC_PER_SEC);
                        dispatch_after(after, dispatch_get_main_queue(), ^{
                            [self loadAlbumList];
                            self.isLoading = NO;
                        });
                    }
                }
            }
        }
            
    }
}
#pragma mark -
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    //NSLog(@"indexpath %@", indexPath);
    ThumbnailCollectionViewCell *cell = (ThumbnailCollectionViewCell *) [collectionView dequeueReusableCellWithReuseIdentifier:@"ThumbnailCell" forIndexPath:indexPath];
    cell.thumbnailView.image = [UIImage imageNamed:@"videobase.jpg"];
    
    if (indexPath.item < self.shareItems.count) {
        cell.loading.hidden = NO;
        [cell.loading startAnimating];
        cell.tag = indexPath.item;
        ShareItem *t = [self.shareItems objectAtIndex:indexPath.item];
        [t loadThumbnailWithPostload:cell];
        cell.typeView.hidden = ![t.objType isEqualToString:(__bridge NSString *)kUTTypeMovie];
        if (t.vidDuration > 31) {
            cell.typeView.image = [UIImage imageNamed:@"notavailable.png"];
        } else {
            cell.typeView.image = [UIImage imageNamed:@"ic200_videomake_white.png"];
        }
    }
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.shareItems.count;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (self.shareItems.count == 1) {
        CGFloat totalcell = 256* self.shareItems.count;
        CGFloat totalspaceWidth = 10*self.shareItems.count-1;
        if (totalspaceWidth <= 0)
            totalspaceWidth = 0;
        CGFloat left = (collectionView.frame.size.width - (totalspaceWidth+totalcell))/2;
        return UIEdgeInsetsMake(10, left, 10, left);
    }
    
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (void)uploadProgress:(nonnull NSString *)taskUUID progress:(CGFloat)progress {
    __block typeof( self) wself = self;
    [self.postRequestList indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *s = (NSString *)obj;
        if ([s isEqualToString:taskUUID]) {
            [wself tryRefreshThumbnailProgress:idx progress:progress];
            *stop = YES;
            return YES;
        }
        
        return NO;
    }];
    
}
#pragma mark - PDFUploaderDelegate
- (NSDictionary *)userInfo {
    return @{@"id":[UserInfo getUserId],@"token":[UserInfo getUserToken]};
}
- (NSString *)retrieveSign:(NSDictionary *)param {
    return [UserAPI signGenerator2:param];
}
- (BOOL)isExporter {
    return NO;
}

@end
