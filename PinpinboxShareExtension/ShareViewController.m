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

#import "UIColor+Extensions.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <UserNotifications/UserNotifications.h>

@interface  ThumbnailCollectionViewCell : UICollectionViewCell<ItemPostLoadDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UIImageView *typeView;
@property (weak, nonatomic) IBOutlet UITextView *comment;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@end

@interface AlbumCellView : UITableViewCell
@property(weak, nonatomic) IBOutlet UIImageView *album;
@property(weak, nonatomic) IBOutlet UILabel *albumName;
@property(weak, nonatomic) IBOutlet UILabel *albumOwner;
@property(weak, nonatomic) IBOutlet UILabel *albumDate;
@property(weak, nonatomic) IBOutlet UIImageView *albumStatus;
@end


@interface ShareViewController ()<UITableViewDelegate, UITableViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>
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
@end



#pragma mark - Cell for photo
@implementation ThumbnailCollectionViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
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
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *dt = [NSData dataWithContentsOfURL:[NSURL URLWithString:c]];
                if (dt) {
                    UIImage *cover = [UIImage imageWithData:dt];
                    if (cover) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            wself.album.image = cover;
                        });
                    }
                }
            });
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
    
    if ([UserInfo getUserID].length < 1 ) {
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
                
                [UserInfo setUserInfo:[UserInfo getUserID] token:tok];
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
                    [self addShareItemWithItemProvider:p type:(__bridge NSString *)kUTTypeURL];
                }
                
            }
        }
        
        [self.photoList reloadData];
    }
}
- (BOOL)checkItemProvider:(NSItemProvider *)p  type:(NSString *)type {
    if ([type isEqualToString:(__bridge NSString *)kUTTypeURL]) {
        return  [p.registeredTypeIdentifiers containsObject:(__bridge NSString *)kUTTypePDF];
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
#pragma mark - post
- (void)processFinishedTask:(NSString *)taskId success:(BOOL)success {
    
    NSUInteger i = [self.postRequestList indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *s = (NSString *)obj;
        if ([s isEqualToString:taskId]) {
            *stop = YES;
            return YES;
        }
        
        return NO;
    }];
    if (success)
        self.successCount++;
    else
        self.failCount++;
    self.postProgressStatus.text = [NSString stringWithFormat:@"上傳完成：%d，上傳失敗：%d",(int)self.successCount, (int)self.failCount];
    [self.postRequestList removeObjectAtIndex:i];
    [self updateProgress];
}
- (void)postItem:(ShareItem *)item {
    __block typeof(self) wself = self;
    if (item.hasVideo) {
        if ([item.objType isEqualToString:(__bridge NSString *) kUTTypeURL] ||
            [item.objType isEqualToString:(__bridge NSString *) kUTTypeText]) {
            NSData *imgdata = nil;
            if (item.thumbnail) {
                imgdata = UIImageJPEGRepresentation(item.thumbnail, 1.0);
            }
            NSString *uuid = [UserAPI insertPhotoWithAlbum_id:_selectedAlbum imageData:imgdata  completionBlock:^(NSDictionary * _Nonnull result, NSString *taskId, NSError * _Nonnull error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [wself processFinishedTask:taskId success:(error == nil)];
                });
            }];
            
            if (uuid)
                [self.postRequestList addObject:uuid];
            
        } else if ([item.objType isEqualToString:(__bridge NSString *) kUTTypeMovie]) {
            if (item.vidDuration <= 31 && item.url) {
                NSString *uuid = [UserAPI insertVideoWithAlbum_id:_selectedAlbum videopath:[item.url path]  completionBlock:^(NSDictionary * _Nonnull result, NSString * _Nonnull taskId, NSError * _Nonnull error) {
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
        
            NSString *uuid = [UserAPI insertPhotoWithAlbum_id:_selectedAlbum imageData:imgdata completionBlock:^(NSDictionary * _Nonnull result, NSString *taskId, NSError * _Nonnull error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [wself processFinishedTask:taskId success:(error == nil)];
                });
                
            }];
            
            if (uuid)
                [self.postRequestList addObject:uuid];
        }
        
    } else if ([item.objType isEqualToString:(__bridge NSString *) kUTTypeURL]) {
        
    }
}
- (IBAction)postShareItem:(id)sender {
    
    self.postProgress.progress = 0;
    if (self.extensionContext) {
        if (_selectedAlbum) {
            for (ShareItem *i in self.shareItems) {
                [self postItem:i];
            }
            
            self.progressView.hidden = NO;
//            [UserAPI postPreCheck:_selectedAlbum completionBlock:^(NSDictionary * _Nonnull result, NSError * _Nonnull error) {
//                if (error) {
//
//                } else {
//                    NSArray *ps = result[@"photo"];
//                    NSInteger cur = ps.count;
//                    if (cur + self.shareItems.count > 22) {
//
//                    }
//                }
//            }];
            
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
    
    if ([UserInfo getUserID].length < 1 ) {
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
    __block typeof(self) wself = self;
    self.isLoading = (self.albumlist.count > 0);
    [UserAPI loadAlbumListWithCompletionBlock:self.albumlist.count completionBlock:^(NSDictionary * _Nonnull result, NSError * _Nonnull error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIActivityIndicatorView *v = (UIActivityIndicatorView *)[wself.albumList viewWithTag:54321];
            
            if (v) {
                [v stopAnimating];
                [wself.albumList setContentInset:UIEdgeInsetsZero];
                [v removeFromSuperview];
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
                
                [wself.albumList reloadData];
                wself.isLoading = NO;
                
                //[self displayExtensionContext];
                
            });
        }
    }];
    self.navigationController.title = @"Pinpinbox";
}
- (void)updateProgress {
    self.progressView.hidden = NO;
    
    self.postProgress.progress = (float)(self.shareItems.count-self.postRequestList.count)/(float)(self.shareItems.count);
    if (self.postRequestList.count <= 0) {
        [self performSelector:@selector(postFinished) withObject:nil afterDelay:1];
    }
}
- (void)postFinished {
    [self trySendLocalNotification:@"" albumid:_albumNames? _albumNames : @""];
    [self cancelAndFinish:nil];
}
#pragma mark -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AlbumCellView *cell = [tableView dequeueReusableCellWithIdentifier:@"AlbumCell"];
    if (!cell)
        cell = [[AlbumCellView alloc] init];
    [cell loadAlbum:[self.albumlist objectAtIndex:indexPath.row]];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albumlist.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 112;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!self.progressView.hidden) return;
    
    if ( (indexPath.row == self.albumlist.count-1) && !self.isLoading) {
    CGFloat contentHeight = tableView.contentSize.height;
    CGFloat listHeight = tableView.frame.size.height ;//- scrollView.contentInset.top - scrollView.contentInset.bottom;
    BOOL canLoad = contentHeight > listHeight;
        if (canLoad ){
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
/*
 *insertphotoofdiy
 *insertvideoofdiy
 *updatephotoofdiy
 *insertalbumofdiy
 retrievealbump
 *updatealbumofdiy
 
 
 Upload binary not thumb
 Movie
 Image
 ---------
 Upload Thumbnail, URL
 URL hasVideo
 Text hasVideo
 ---------
 Upload Thumbnail
 Other
 
 ISSUE:
 How to deal com.adobe.pdf
 *local movie longer than 30 seconds...
 */
#pragma mark -
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSLog(@"indexpath %@", indexPath);
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

@end
