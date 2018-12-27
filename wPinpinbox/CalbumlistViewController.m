//
//  CalbumlistViewController.m
//  wPinpinbox
//
//  Created by Angus on 2015/10/23.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "CalbumlistViewController.h"
#import "CalbumlistCollectionViewCell.h"
#import "JCCollectionViewWaterfallLayout.h"
#import "wTools.h"
#import "boxAPI.h"
#import "AppDelegate.h"
#import "AsyncImageView.h"

#import "GHContextMenuView.h"
#import "CooperationViewController.h"
#import "CustomIOSAlertView.h"
#import "OldCustomAlertView.h"
#import "UIColor+Extensions.h"
#import "GlobalVars.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIViewController+ErrorAlert.h"

#import "DDAUIActionSheetViewController.h"

#import "AlbumCreationViewController.h"
#import "AlbumSettingViewController.h"
#import "UIView+Toast.h"
#import "CreaterViewController.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "NewCooperationViewController.h"
#import <SafariServices/SafariServices.h>

#import "UserInfo.h"

@interface CalbumlistCollectionViewLayout : UICollectionViewFlowLayout
//@property (nonatomic) CGFloat itemHeight;
@end

@implementation CalbumlistCollectionViewLayout
- (id)init {
    self = [super init];
    [self layoutAlbumList];
    return  self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self layoutAlbumList];
    return self;
}

- (void)layoutAlbumList {
    self.minimumInteritemSpacing = 0;
    self.minimumLineSpacing = 0.5;
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
}

- (CGSize)itemSize {
    CGFloat contentWidth = [UIApplication sharedApplication].keyWindow.frame.size.width;//self.collectionView.bounds.size.width;
    return CGSizeMake(contentWidth, 96);
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}
@end

#pragma mark
@interface CalbumlistViewController () <CalbumlistDelegate, GHContextOverlayViewDataSource, GHContextOverlayViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, AlbumCreationViewControllerDelegate, DDAUIActionSheetViewControllerDelegate, AlbumSettingViewControllerDelegate, FBSDKSharingDelegate, NewCooperationVCDelegate, SFSafariViewControllerDelegate>
{
    NSInteger type;
    NSMutableArray *dataarr;
    
    BOOL isLoading;
    NSInteger  nextId;
    BOOL isreload;
    UIView *backview;
    
    BOOL isLoadbtn;
    
    NSString *task_for;
    
    // For Showing Message of Getting Point
    NSString *missionTopicStr;
    NSString *rewardType;
    NSString *rewardValue;
    NSString *eventUrl;
    
    NSString *restriction;
    NSString *restrictionValue;
    NSUInteger numberOfCompleted;
    
    OldCustomAlertView *alertView;
}

//@property (nonatomic, strong) JCCollectionViewWaterfallLayout *layout;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewBottomConstraint;
//  contextmenu selection index (-1,0,1,2)
//@property (nonatomic) NSInteger contextMenuIndex;
@property (nonatomic, strong) DDAUIActionSheetViewController *customEditActionSheet;
@property (nonatomic) UIVisualEffectView *effectView;

@property (nonatomic) NSString *albumId;
@end

@implementation CalbumlistViewController

#pragma mark - View Loading Related Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    //NSLog(@"");
    NSLog(@"CalbumlistViewController");
    NSLog(@"viewDidLoad");
    NSLog(@"Test");
    
    wtitle.text=NSLocalizedString(@"GeneralText-fav", @"");
    dataarr=[NSMutableArray new];
    nextId = 0;
    isLoading = NO;
    isreload = NO;
    isLoadbtn = NO;
    //type=0;
    type = self.collectionType;
    //self.contextMenuIndex = -1;
    
//    self.layout = (JCCollectionViewWaterfallLayout *)self.collectioview.collectionViewLayout;
//    self.layout.headerHeight = 0.0f;
//    self.layout.footerHeight = 0.0f;
//    //self.layout.sectionInset=UIEdgeInsetsMake(0, 25, 0, 25);

    // Do any additional setup after loading the view from its nib.
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
    [_collectionview addSubview:_refreshControl];
    _collectionview.alwaysBounceVertical=YES;
    
//    [_btn1 setTitle:NSLocalizedString(@"FavText-myWorks", @"") forState:UIControlStateNormal];
//    [_btn2 setTitle:NSLocalizedString(@"FavText-otherFav", @"") forState:UIControlStateNormal];
//    [_btn3 setTitle:NSLocalizedString(@"FavText-publicFav", @"") forState:UIControlStateNormal];
//
//    _btn1.exclusiveTouch=YES;
//    _btn2.exclusiveTouch=YES;
//    _btn3.exclusiveTouch=YES;
    _collectionview.exclusiveTouch=YES;
    if (@available(iOS 11.0, *)) {
        _collectionview.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    self.collectionview.showsVerticalScrollIndicator = NO;
    
    // Avoid loading data twice for showing same data in PageCollectionViewController
    
    // CustomActionSheet
    self.customEditActionSheet = [[DDAUIActionSheetViewController alloc] init];
    self.customEditActionSheet.delegate = self;
    self.customEditActionSheet.topicStr = @"編輯作品";
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"CalbumlistViewController");
    NSLog(@"viewWillAppear");
    NSLog(@"Test");
    [self reloaddata];
}

#pragma mark -

- (void)refresh {
    NSLog(@"refresh");
    if (!isreload) {
        isreload=YES;
        nextId = 0;
        [_collectionview setContentOffset:CGPointMake(0, 0) animated:NO];
        [self reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btn:(UIButton *)sender {
    NSLog(@"btn:(UIButton *)sender");
}

- (void)loadDataWhenChangingPage:(NSInteger)page {
    type = page;
    [self refresh];
}

- (void)reloaddata {
    NSLog(@"reloaddata");
    NSLog(@"isLoading: %d", isLoading);
    NSLog(@"before check if !isLoading");
    
    if (!isLoading) {
        isLoading = YES;
        [self getcalbumlist];
    }
}

- (void)getcalbumlist {
    NSLog(@"getcalbumlist");
    
    if (nextId == 0)
        [wTools ShowMBProgressHUD];

    __block typeof(self) wself = self;
    NSString *limit=[NSString stringWithFormat:@"%ld,%d",(long)nextId, 16];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSArray *arr = @[@"mine",@"other",@"cooperation"];
        NSString *response = [boxAPI getcalbumlist: [wTools getUserID]
                                             token: [wTools getUserToken]
                                              rank: arr[wself->type]//type]
                                             limit: limit];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            UIActivityIndicatorView *v = (UIActivityIndicatorView *)[self.collectionview viewWithTag:54321];
                
            if (v) {
                [v stopAnimating];
                [self.collectionview setContentInset:UIEdgeInsetsZero];
                [v removeFromSuperview];
            }
            self.collectionview.bounces = YES;
        });
        
        if (response != nil) {
            NSLog(@"response from getcalbumlist");
            
            if ([response isEqualToString: timeOutErrorCode]) {
                NSLog(@"Time Out Message Return");
                NSLog(@"CalbumlistViewController");
                NSLog(@"getcalbumlist");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getcalbumlist"
                                         albumId: @""];
                    [wself.refreshControl endRefreshing];
                });
                wself->isreload = NO;
            } else {
                NSLog(@"Get Real Response");
                NSDictionary *dict1 = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                NSMutableDictionary *c = [NSMutableDictionary dictionaryWithDictionary:dict1];
                [c setObject:limit forKey:@"section"];
                
                NSLog(@"dic: %@", dict1);
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(wself) ss = wself;
                    [ss processCalbumlist:c];
                });
            }
        } else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [wself.refreshControl endRefreshing];
            });
            wself->isreload = NO;
        }
    });
}

- (void)showBackView {
    if (backview != nil) {
        [backview removeFromSuperview];
        backview = nil;
    }
    if (dataarr.count == 0) {
        NSLog(@"type: %ld", (long)type);
        UILabel *lab1;
        @try {
            NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"CalbumV%i",(int)type+1] owner:self options:nil];
            backview = [subviewArray objectAtIndex:0];
            backview.frame = self.collectionview.frame;
            [self.collectionview addSubview:backview];
            
            lab1 = [(UILabel *)backview viewWithTag:100];
        } @catch (NSException *exception) {
            
        }
        switch (type) {
            case 0:
                lab1.text=NSLocalizedString(@"FavText-tipCreateNow", @"");
                break;
            case 1:
                lab1.text=NSLocalizedString(@"FavText-tipFindFavProducts", @"");
                break;
            case 2:{
                lab1.text=NSLocalizedString(@"FavText-tipInvite", @"");
                UILabel *lab2=[(UILabel *)backview viewWithTag:200];
                lab2.text=NSLocalizedString(@"FavText-tipInvite2", @"");
            }
                break;
            default:
                break;
        }
    }
}

- (int)getSectionStart:(NSString *)limit {
    //NSArray *ls = [limit by]
    return -1;
}

- (void)processCalbumlist:(NSDictionary *)dic {
    if (dic[@"result"]) {
        if ([dic[@"result"] intValue] == 1) {
            NSLog(@"section::: %@",dic[@"section"]);
            NSInteger pn = nextId;
            if (nextId==0) {
                [dataarr removeAllObjects];//=[NSMutableArray new];
            }
            int s=0;
            NSMutableArray *ar = [NSMutableArray arrayWithArray:dataarr];
            
            if (![wTools objectExists: dic[@"data"]]) {
                return;
            }
            
            NSArray *list = [dic objectForKey:@"data"];
            NSMutableArray *ll = [NSMutableArray array];
            int ci = 0;
            for (NSDictionary *c in list) {
                NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:c];
                [d setObject:[NSNumber numberWithInteger:nextId+ci] forKey:@"index"];
                [ll addObject:d];
                ci++;
            }
            
            [ar addObjectsFromArray:ll];
            NSOrderedSet *nset = [NSOrderedSet orderedSetWithArray:ar];
           
            [dataarr setArray:[nset array]];//addObjectsFromArray:list];
            
            s = (int)[list count];
            nextId = nextId+s;
            // dataarr=[dic[@"data"] mutableCopy];
            
            //NSLog(@"dataarr: %@", dataarr);
            if (pn != nextId) {
                [_refreshControl endRefreshing];
                [_collectionview reloadData];
            }
            
            if (nextId  >= 0)
                isLoading = NO;
            
            if (s==0) {
                isLoading = YES;
            }
            
            isreload = NO;
            if (dataarr.count < 1) {
                [self showBackView];
            }
        } else if ([dic[@"result"] intValue] == 0) {
            NSLog(@"失敗：%@",dic[@"message"]);
            if ([wTools objectExists: dic[@"message"]]) {
                [self showCustomErrorAlert: dic[@"message"]];
            } else {
                [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
            }
            [_refreshControl endRefreshing];
            isreload = NO;
        }
    } else {
        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
        [_refreshControl endRefreshing];
        isreload = NO;
    }
}

- (void)logOut {
    [wTools logOut];
}

//沒有資料產生的畫面
#pragma mark - UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section {
    return dataarr.count;
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ( (indexPath.row == dataarr.count-1) && !isLoading) {
        CGFloat contentHeight = collectionView.contentSize.height;
        CGFloat listHeight = collectionView.frame.size.height ;//- scrollView.contentInset.top - scrollView.contentInset.bottom;
        BOOL canLoad = contentHeight > listHeight;
        
        if (canLoad ){//&& diff <= -48) {
            //scrollView.bounces = NO;
            UIView *v = [collectionView viewWithTag:54321];
            if (!isLoading && (v == nil)) {
                UIEdgeInsets u =collectionView.contentInset;
                [collectionView setContentInset:UIEdgeInsetsMake(0, u.left, 96, u.right)];
                [collectionView.collectionViewLayout invalidateLayout];
                
                UIActivityIndicatorView *indicator =
                indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
                [indicator setColor:[UIColor darkGrayColor]];
                indicator.center = CGPointMake(collectionView.center.x, collectionView.contentSize.height+48);
                indicator.tag = 54321;
                [collectionView addSubview:indicator];
                indicator.hidesWhenStopped = YES;
                [indicator startAnimating];
                
                dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 2.5 * NSEC_PER_SEC);
                dispatch_after(after, dispatch_get_main_queue(), ^{
                    [self reloaddata];
                    self->isLoading = NO;
                });
            }
        }
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CalbumlistCollectionViewCell *Cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Calbumlist" forIndexPath:indexPath];
    Cell.delegate = self;
    Cell.type = type;
    
    if (dataarr.count < indexPath.row + 1) {
        return Cell;
    }
    Cell.dataIndex = indexPath.row;
    NSLog(@"cellForItemAtIndexPath");
    //NSLog(@"dataArr: %@", dataarr);
    
    NSDictionary *data = dataarr[indexPath.row][@"album"];
    ////NSLog(@"data: %@", data);
    
    if (![data[@"album_id"] isEqual: [NSNull null]]) {
        Cell.albumid = [data[@"album_id"] stringValue];
    }
    if (![dataarr[indexPath.row][@"template"][@"template_id"] isEqual: [NSNull null]]) {
        Cell.templateid = [dataarr[indexPath.row][@"template"][@"template_id"] stringValue];
    }
    
    //AsyncImageView *img = (AsyncImageView*)Cell.imageView;
    UIImageView *img = (UIImageView *)Cell.imageView;
    
    img.imageURL = nil;
    img.image = nil;
    img.contentMode = UIViewContentModeCenter;//UIViewContentModeScaleAspectFit;
    
    img.layer.borderWidth = 0;
    if (![data[@"cover"] isKindOfClass:[NSNull class]]) {
        
        [img sd_setImageWithURL:[NSURL URLWithString:data[@"cover"]] placeholderImage:[UIImage imageNamed:@"bg_2_0_0_no_image"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (error) {
                img.image = [UIImage imageNamed: @"bg_2_0_0_no_image"] ;
            } else
                img.image = image;
        }];
    } else {
        img.contentMode = UIViewContentModeScaleAspectFit;
        img.imageURL = nil;
        img.image = [UIImage imageNamed:@"bg_2_0_0_no_image"];//nil;
        
        //img.layer.borderColor = [UIColor thirdGrey].CGColor;
        //img.layer.borderWidth = 1;
    }
    img.layer.masksToBounds = YES;
    img.layer.cornerRadius = 6;
    
    Cell.opMenuLeading.constant = collectionView.bounds.size.width;
    
    [Cell displayZippedStatus:[data[@"zipped"] boolValue]];
    //Cell.stopview.hidden = YES;
    
    NSLog(@"data zipped boolvalue: %d", [data[@"zipped"] boolValue]);
    
    if ([data[@"zipped"] boolValue]) {
        //img.alpha = 1;
        Cell.lockBtn.hidden = YES;
        //Cell.unfinishedLabel.hidden = YES;
    } else {
        //img.alpha = 0.3;
        Cell.lockBtn.hidden = NO;
        //Cell.unfinishedLabel.hidden = NO;
    }
    
    NSLog(@"act: %@", data[@"act"]);
    if (type == 0){
        Cell.lockBtn.hidden = NO;
        if (![data[@"act"] isEqualToString: @"open"]) {
            //img.alpha = 0.3;
            [Cell.lockBtn setImage:[UIImage imageNamed: @"ic200_act_close_white"] forState:UIControlStateNormal];//image = ;
            [Cell.lockBtn setTintColor:[UIColor firstPink]];
            //Cell.unfinishedLabel.hidden = NO;
        } else {
            //img.alpha = 1;
            [Cell.lockBtn setTintColor:[UIColor secondGrey]];
            [Cell.lockBtn setImage:[UIImage imageNamed: @"ic200_act_open_white"] forState:UIControlStateNormal];//image = ;
            //Cell.unfinishedLabel.hidden = YES;
        }
    } else {
        Cell.lockBtn.hidden = YES;
    }
    
    
    if (![data[@"insertdate"] isEqual: [NSNull null]]) {
        Cell.mydate.text = data[@"insertdate"];
    }
    
    NSDictionary *cooperation;
    
    if (![dataarr[indexPath.row][@"cooperation"] isEqual: [NSNull null]]) {
        cooperation = dataarr[indexPath.row][@"cooperation"];
    }
    
    NSLog(@"cooperation: %@", cooperation);
    
    if (![cooperation[@"identity"]isKindOfClass:[NSNull class]]) {
        Cell.identity = cooperation[@"identity"];
    }else{
        Cell.identity = nil;
    }
    int coop = 0;
    if (dataarr[indexPath.row][@"cooperationstatistics"][@"count"]  ){
        coop = [dataarr[indexPath.row][@"cooperationstatistics"][@"count"] intValue];
    }
    [Cell setCoopNumber:coop];
    //NSLog(@"");
    //NSLog(@"");
    //NSLog(@"data: %@", data);
    
    [Cell setAlbumDesc:[NSString stringWithFormat:@"%@",data[@"name"]]];
    
    //個人資料
    NSDictionary *userdata=dataarr[indexPath.row][@"user"];
    //  convert to NSString first
    Cell.userid=[userdata[@"user_id"] stringValue];
    img=Cell.userAvatar;
    img.image=[UIImage imageNamed:@"2-01aaphoto.png"];
    
    if (![userdata[@"picture"] isKindOfClass:[NSNull class]]) {
        if (![userdata[@"picture"] isEqualToString:@""]) {
            [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: img];
            img.imageURL=[NSURL URLWithString:userdata[@"picture"]];
        }
    }else{
        img.image=[UIImage imageNamed:@""];
    }
    img.layer.masksToBounds = YES;
    img.layer.cornerRadius = 12;
    
//    if (![userdata[@"name"] isEqual:[NSNull null]]) {
//        Cell.mytitle.text=userdata[@"name"];
//    }
    
    //取得資料ID
//    NSString *name=[NSString stringWithFormat:@"%@%@",[wTools getUserID],[data[@"album_id"] stringValue]];
//    NSString *docDirectoryPath = [filepinpinboxDest stringByAppendingPathComponent:name];
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//
    
    switch (self.collectionType) {
        case 0:
            [Cell selfAlbumMode];
            break;
        case 1:
            [Cell favAlbumMode];
            break;
        case 2:
            [Cell coopAlbumMode];
            break;
    }
    
    return Cell;
}
- (void)checkRefreshContent {
//    if (type != 1) {
//        [dataarr removeAllObjects];
//        [self reloadData];
//    }
}

-(void)reloadData {
    nextId = 0;
    isLoading = NO;
    [self reloaddata];
   // [_collectioview reloadData];
}

#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectItemAtIndexPath");
    NSLog(@"indexPath.row: %ld", (long)indexPath.row);
    
    //  check opMenu mode of cell  //
    CalbumlistCollectionViewCell *cell = (CalbumlistCollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
    if (cell && [cell isOpMode])
        return;
    
    NSDictionary *data = dataarr[indexPath.row][@"album"];
    //NSLog(@"data: %@", data);
    
    if ([data[@"usefor"][@"image"] boolValue] || [data[@"usefor"][@"video"] boolValue]) {
        //BOOL zipped = [data[@"zipped"] boolValue];
        NSString *albumId;
        
        NSDictionary *userdata=dataarr[indexPath.row][@"user"];
        NSString *userId = userdata[@"user_id"];
        
        if (![data[@"album_id"] isEqual: [NSNull null]]) {
            albumId = [data[@"album_id"] stringValue];
        }
        // issue 0002170 //
        //if (zipped) {
        NSLog(@"if zipped is YES");
        if (type == 2) {
            [wTools ReadTestBookalbumid: albumId userbook: @"Y" eventId: nil postMode: NO fromEventPostVC: NO];
            return;
        }
        if ([[(id)userId stringValue] isEqualToString:[wTools getUserID]]) {
            [wTools ReadTestBookalbumid: albumId userbook: @"Y" eventId: nil postMode: NO fromEventPostVC: NO];
        } else {
            [wTools ReadTestBookalbumid: albumId userbook: @"Y" eventId: nil postMode: NO fromEventPostVC: NO];
        }
        //} else if (type == 2) {
        //    [wTools ReadTestBookalbumid: albumId userbook: @"Y" eventId: nil postMode: NO fromEventPostVC: NO];
        //}
    } else {
        [self showToastMessage: @"作品沒有內容"];
    }
}

- (void)collectionView:(UICollectionView *)collectionView
didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didHighlightItemAtIndexPath");
    NSLog(@"indexPath.row: %ld", (long)indexPath.row);
}

#pragma mark - UICollectionViewFlowLayoutDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

}

- (void)updateAlbumact:(NSString *) albumid {
    for (int i = 0; i< [dataarr count];i++) {
        NSMutableDictionary *c = (NSMutableDictionary *)dataarr[i];
        NSDictionary *calbum = c[@"album"];
        if (calbum && [[calbum[@"album_id"] stringValue] isEqualToString:albumid]) {
            [self tryUpdateAlbumSetting:i];
            break;
        }
    }
}

- (void)refreshCellAtIndex:(NSInteger) index {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionview reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
        //[self reloaddata];
    });
}

#pragma mark - GHMenu Methods
- (BOOL)shouldShowMenuAtPoint:(CGPoint)point {
//    NSIndexPath *indexPath = [_collectioview indexPathForItemAtPoint: point];
//    UICollectionViewCell *cell = [_collectioview cellForItemAtIndexPath: indexPath];
//    //_contextMenuIndex = -1;
//    if (cell )
//        _contextMenuIndex = indexPath.row;
//
//    return cell != nil;
    return NO;
}

- (NSInteger)numberOfMenuItems {
    NSLog(@"numberOfMenuItems");
    NSInteger menuItems = 0;
    NSLog(@"self.collectionType: %ld", (long)self.collectionType);
    
    //if (self.collectionType == 0 || self.collectionType == 2) {
    if (self.collectionType == 0) {
        //menuItems = 4;
        menuItems = 3;
    } else if (self.collectionType == 1) {
        menuItems = 2;
    } else if (self.collectionType == 2) {
        menuItems = 0;
    }
    NSLog(@"menuItems: %ld", (long)menuItems);
    
    return menuItems;
}

- (UIImage *)imageForItemAtIndex:(NSInteger)index {
    NSLog(@"imageForItemAtIndex");
    NSString *imageName = nil;
    NSLog(@"self.collectionType: %ld", (long)self.collectionType);
    
    //if (self.collectionType == 0 || self.collectionType == 2) {
    if (self.collectionType == 0) {
        NSLog(@"self.collectionType == 0 && self.collectionType == 2");
        
        switch (index) {
            case 0:
                imageName = @"wbutton_delete";
                break;
            case 1:
                imageName = @"wbutton_edit.png";
                break;
            case 2:
                imageName = @"wbutton_share.png";
                break;
            case 3:
                imageName = @"wbutton_cooperation.png";
            default:
                break;
        }
    } else if (self.collectionType == 1) {
        NSLog(@"self.collectionType == 1");
        
        switch (index) {
            case 0:
                imageName = @"wbutton_delete";
                break;
            case 1:
                imageName = @"wbutton_share.png";
                break;
            default:
                break;
        }
    }
    
    return [UIImage imageNamed: imageName];
}
//  no valid selection is made
- (void)menuCancelled {
//    _contextMenuIndex = -1;
}
- (void)didSelectItemAtIndex:(NSInteger)selectedIndex forMenuAtPoint:(CGPoint)point {
//    NSLog(@"didSelectItemAtIndex");
//    NSIndexPath *indexPath = [_collectioview indexPathForItemAtPoint: point];
//    NSLog(@"indexPath.row: %ld", (unsigned long)indexPath.row);
//
//    NSString *msg = nil;
//
//    //if (self.collectionType == 0 || self.collectionType == 2) {
//    if (self.collectionType == 0) {
//        switch (selectedIndex) {
//            case 0:
//                msg = @"Delete";
//                break;
//            case 1:
//                msg = @"PhotoEdit";
//                break;
//            case 2:
//                msg = @"Share";
//                break;
//            case 3:
//                msg = @"Cooperation";
//            default:
//                break;
//        }
//    } else if (self.collectionType == 1) {
//        switch (selectedIndex) {
//            case 0:
//                msg = @"Delete";
//                break;
//            case 1:
//                msg = @"Share";
//            default:
//                break;
//        }
//    }
////    if (_contextMenuIndex == -1)
////        _contextMenuIndex = indexPath.row;
//    NSDictionary *data = dataarr[_contextMenuIndex][@"album"];
//    NSString *albumId = [data[@"album_id"] stringValue];
//    NSString *templateId = [dataarr[_contextMenuIndex][@"template"][@"template_id"] stringValue];
//    NSLog(@"templateId: %@", templateId);
//    NSDictionary *userdata = dataarr[_contextMenuIndex][@"user"];
//    //NSString *identity = dataarr[_contextMenuIndex][@"cooperation"][@"identity"];
//
//
//    BOOL hasImage = [data[@"usefor"][@"image"] boolValue];
//    NSLog(@"hasImage: %d", hasImage);
//
//    if ([msg isEqualToString: @"Delete"]) {
//        NSLog(@"msg isEqualToString: Delete");
//        NSIndexPath *i = [NSIndexPath indexPathForRow:_contextMenuIndex inSection:0];
//        [self deleteBook:i ];//indexPath];
//
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        [defaults setObject: [NSNumber numberWithBool: YES] forKey: @"deleteAlbum"];
//        [defaults synchronize];
//    }
//    if ([msg isEqualToString: @"PhotoEdit"]) {
//        if (self.collectionType == 2) {
//            if ([identity isEqualToString: @"viewer"]) {
//                [self showCustomAlertNormal: NSLocalizedString(@"CreateAlbumText-tipPermissions", @"")];
//                return;
//            }
//            if ([self.delegate respondsToSelector: @selector(editPhoto:templateId:shareCollection:hasImage:)]) {
//                NSLog(@"self.delegate respondsToSelector editphotoinfo:templateid:eventId:postMode:");
//                [self.delegate editPhoto: albumId templateId: templateId shareCollection: YES hasImage: hasImage];
//            }
//        } else if (self.collectionType == 0) {
//            if ([self.delegate respondsToSelector: @selector(editPhoto:templateId:shareCollection:hasImage:)]) {
//                NSLog(@"self.delegate respondsToSelector editphotoinfo:templateid:eventId:postMode:");
//                [self.delegate editPhoto: albumId templateId: templateId shareCollection: NO hasImage: hasImage];
//            }
//        }
//    }
//    if ([msg isEqualToString: @"Share"]) {
//        NSString *sharingStr = [NSString stringWithFormat:@"%@ http://www.pinpinbox.com/index/album/content/?album_id=%@", userdata[@"name"], albumId];
//
//        if ([self.delegate respondsToSelector: @selector(shareLink:albumId:)]) {
//            [self.delegate shareLink: sharingStr
//                             albumId: albumId];
//        }
//    }
//    if ([msg isEqualToString: @"Cooperation"]) {
//        if (self.collectionType == 2) {
//            NSLog(@"identity: %@", identity);
//
//            if ([identity isEqualToString: @"viewer"] || [identity isEqualToString: @"editor"]) {
//                [self showCustomAlertNormal: NSLocalizedString(@"CreateAlbumText-tipPermissions", @"")];
//                return;
//            }
//            if ([self.delegate respondsToSelector: @selector(editCooperation:identity:)]) {
//                NSLog(@"self.delegate respondsToSelector editCooperation");
//                [self.delegate editCooperation: albumId identity: identity];
//            }
//        } else if (self.collectionType == 0) {
//            NSLog(@"identity: %@", identity);
//
//            if ([self.delegate respondsToSelector: @selector(editCooperation:identity:)]) {
//                NSLog(@"self.delegate respondsToSelector editCooperation");
//                [self.delegate editCooperation: albumId identity: @"admin"];
//            }
//        }
//    }
//    _contextMenuIndex = -1;
}

- (void)getIdentity:(NSString *)albumId
         templateId:(NSString *)templateId
                msg:(NSString *)msg {
    [wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI getalbumofdiy: [wTools getUserID]
                                             token: [wTools getUserToken] album_id:albumId];
        
        NSMutableDictionary *data = [NSMutableDictionary new];
        [data setObject: albumId forKey: @"type_id"];
        [data setObject: [wTools getUserID] forKey: @"user_id"];
        [data setObject: @"album" forKey: @"type"];
        
        NSString *coopid = [boxAPI getcooperation: [wTools getUserID] token: [wTools getUserToken] data: data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"response: %@", response);
                NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                NSDictionary *identdic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [coopid dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                if ([dic[@"result"] intValue] == 1) {
                    NSLog(@"call getalbumofdiy success");
                    NSLog(@"%@", dic[@"data"][@"photo"]);
                    
                    NSString *identity;
                    identity = identdic[@"data"];
                    
                    if (![wTools objectExists: msg]) {
                        return;
                    }
                    
                    if ([msg isEqualToString: @"Cooperation"]) {
                        
                    }
                    if ([msg isEqualToString: @"PhotoEdit"]) {
                        
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
        });
    });
}

//刪除事件
- (void)deleteBook: (NSIndexPath *)indexPath {
    NSDictionary *data = dataarr[indexPath.row][@"album"];
    NSString *albumId = [data[@"album_id"] stringValue];
    
    //取得資料ID
    NSString *name = [NSString stringWithFormat: @"%@%@", [wTools getUserID], albumId];
    NSString *docDirectoryPath = [filepinpinboxDest stringByAppendingPathComponent: name];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //檢查資料夾是否存在
    if ([fileManager fileExistsAtPath: docDirectoryPath]) {
        NSLog(@"fileManager fileExistsAtPath: docDirectoryPath");
        [self showCustomAlert: @"確定要刪除相本?" path: docDirectoryPath albumId: albumId];
    } else {
        NSLog(@"fileManager file does not ExistsAtPath: docDirectoryPath");
        [self showCustomAlert: @"確定要刪除相本?" albumId: albumId];
    }
}

//刪除相本
-(void)deletebook:(NSString *)albumid {
    //NSLog(@"");
    NSLog(@"deletebook albumId: %@", albumid);
    NSLog(@"type: %ld", (long)type);
    
    if (type == 1) {
        [self hidealbumqueue: albumid];
        return;
    }
    if (type == 2) {
        [self deletecooperation: albumid];
        return;
    }
    
    [wTools ShowMBProgressHUD];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI delalbum: [wTools getUserID]
                                        token: [wTools getUserToken]
                                      albumid: albumid];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"response from delalbum");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"CalbumlistViewController");
                    NSLog(@"delalbum");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"") protocolName: @"delalbum" albumId: albumid];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        [self reloadData];
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗：%@", dic[@"message"]);
                        [self showToastMessage: dic[@"message"]];
                        [self reloadData];
                    } else {
                        [self showToastMessage: NSLocalizedString(@"Host-NotAvailable", @"")];
                        [self reloadData];
                    }
                }
            }
        });
    });
}

#pragma mark - message toast
- (void)showToastMessage:(NSString *)msg {
    CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
    style.messageColor = [UIColor whiteColor];
    style.backgroundColor = [UIColor thirdPink];
    
    [self.view makeToast: msg
                 duration: 1.0
                 position: CSToastPositionBottom
                    style: style];
}
#pragma mark - Custom Alert Method
- (void)showCustomAlertNormal: (NSString *)msg {
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    //[alertView setContainerView: [self createContainerViewNormal: msg]];
    [alertView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertView.arrangeStyle = @"Horizontal";
    
    [alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"取消", @"確定", nil]];
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
            //[self changeFollowStatus: userId name: name];
        }
    }];
    [alertView setUseMotionEffects: YES];
    [alertView show];
}

- (UIView *)createContainerViewNormal: (NSString *)msg {
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
    
    //NSLog(@"");
    NSLog(@"contentView: %@", NSStringFromCGRect(contentView.frame));
    //NSLog(@"");
    
    return contentView;
}


- (void)showCustomAlert: (NSString *)msg path:(NSString *)docDirectoryPath albumId:(NSString *)albumId {
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    //[alertView setContainerView: [self createContainerView: msg]];
    [alertView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertView.arrangeStyle = @"Horizontal";
    
    [alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"取消", @"確定", nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor clearColor],nil]];
    [alertView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstGrey], nil]];
    [alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    //alertView.arrangeStyle = @"Vertical";
    
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
        
        [alertView close];
        
        if (buttonIndex == 0) {
            
        } else {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath: docDirectoryPath error: nil];
            [self deletebook: albumId];
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
    
    //NSLog(@"");
    NSLog(@"contentView: %@", NSStringFromCGRect(contentView.frame));
    //NSLog(@"");
    
    return contentView;
}

#pragma mark - Custom Alert Method
- (void)showCustomAlert:(NSString *)msg
                albumId:(NSString *)albumId {
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    //[alertView setContainerView: [self createContainerView1: msg]];
    [alertView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertView.arrangeStyle = @"Horizontal";
    
    [alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"取消", @"確定", nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor clearColor],nil]];
    [alertView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstGrey], nil]];
    [alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    //alertView.arrangeStyle = @"Vertical";
    
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
        [alertView close];
        
        if (buttonIndex == 0) {
            
        } else {
            [self deletebook: albumId];
        }
    }];
    [alertView setUseMotionEffects: YES];
    [alertView show];
}

- (UIView *)createContainerView1: (NSString *)msg {
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
    
    //NSLog(@"");
    NSLog(@"contentView: %@", NSStringFromCGRect(contentView.frame));
    //NSLog(@"");
    
    return contentView;
}

-(void)hidealbumqueue:(NSString *)albumid {
    NSLog(@"hidealbumqueue");
    
    [wTools ShowMBProgressHUD];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *response = @"";
        response = [boxAPI hidealbumqueue: [wTools getUserID]
                                    token: [wTools getUserToken]
                                  albumid: albumid];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"CalbumlistViewController");
                    NSLog(@"hidealbumqueue");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"hidealbumqueue"
                                         albumId: albumid];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        [self reloadData];
                        [self deletePlist: albumid];
                    } else if ([dic[@"result"] intValue] == 0) {
                        [self showToastMessage: dic[@"message"]];
                        [self reloadData];
                    } else {
                        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            }
        });
    });
}

- (void)deletePlist: (NSString *)albumId {
    NSLog(@"deletePlist");
    
    if (![wTools objectExists: albumId]) {
        return;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex: 0];
    NSString *filePath = [documentsDirectory stringByAppendingString: @"/GiftData.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableDictionary *data;
    
    if ([fileManager fileExistsAtPath: filePath]) {
        NSLog(@"file exists");
        
        data = [[NSMutableDictionary alloc] initWithContentsOfFile: filePath];
        //NSLog(@"data: %@", data);
        
        [data removeObjectForKey: albumId];
        //NSLog(@"data: %@", data);
    }
    
    if ([data writeToFile: filePath atomically: YES]) {
        NSLog(@"Data saving is successful");
    } else {
        NSLog(@"Data saving is failed");
    }
}


//刪除共用-共用
-(void)deletecooperation:(NSString *)albumid {
    NSLog(@"deletecooperation");
    
    [wTools ShowMBProgressHUD];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = @"";
        NSMutableDictionary *data = [NSMutableDictionary new];
        [data setObject: [wTools getUserID] forKey: @"user_id"];
        [data setObject: @"album" forKey: @"type"];
        [data setObject: albumid forKey: @"type_id"];
        
        response = [boxAPI deletecooperation: [wTools getUserID]
                                       token: [wTools getUserToken]
                                        data: data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"response from deletecooperation");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"CalbumlistViewController");
                    NSLog(@"deletecooperation");
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"deletecooperation"
                                         albumId: albumid];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([dic[@"result"]boolValue]) {
                        [self reloadData];
                    } else {
                        NSLog(@"失敗：%@", dic[@"message"]);
                        [self showToastMessage: dic[@"message"]];
                        [self reloadData];
                    }
                }
            }
        });
    });
}

#pragma mark - Tap userAvatar
- (void)showCreatorPageWithUserid:(NSString *)userid {
    if (![wTools objectExists: userid]) {
        return;
    }
    CreaterViewController *cVC = [[UIStoryboard storyboardWithName: @"CreaterVC" bundle: nil] instantiateViewControllerWithIdentifier: @"CreaterViewController"];
    cVC.userId = userid;
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav pushViewController: cVC animated: YES];
}

#pragma mark - change album act with albumid & index
- (void)changeAlbumAct:(NSString *)albumid index:(NSInteger)index {
    if (self.collectionType != 0) {
        return;
    }
    
    if (index < dataarr.count) {
        NSDictionary *data = dataarr[index][@"album"];
        NSString *al = [data[@"album_id"] stringValue];
        if ([al isEqualToString:albumid]) {
            __block typeof(self) wself = self;
            [boxAPI getAlbumSettingsWithAlbumId:albumid completionBlock:^(NSDictionary *settings, NSError *error) {
                if (!error) {
                    //NSLog(@"%@",settings);
                    NSDictionary *dt = settings[@"data"];
                    NSString *t = dt[@"name"];//dt[@"title"];
                    NSNumber *f = dt[@"categoryarea_id"];//firstpaging"];
                    NSNumber *s = dt[@"category_id"];
                    if (t && t.length > 0 && ![f isKindOfClass:[NSNull class]] && ![s isKindOfClass:[NSNull class]]) {
                        [boxAPI getAlbumDiyWithAlbumId:albumid completionBlock:^(NSDictionary *result, NSError *error) {
                            if (!error) {
                                NSDictionary *  d = result[@"data"];
                                if (d) {
                                    NSArray *a = d[@"photo"];
                                    if (a.count < 1)
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [wself showToastMessage:@"你的作品還沒有內容"];
                                        });
                                    else {
                                        NSMutableDictionary *va = [NSMutableDictionary dictionaryWithDictionary:settings[@"data"]];
                                        //  modify "act" value in settings
                                        if ([va[@"act"] isEqualToString:@"open"])
                                            [va setObject:@"close" forKey:@"act"];
                                        else
                                            [va setObject:@"open" forKey:@"act"];

                                        //NSString *setting = [NSJSONSerialization dataWithJSONObject:va options: error:]
                                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject: va options: 0 error: nil];
                                        NSString *jsonStr = [[NSString alloc] initWithData: jsonData encoding: NSUTF8StringEncoding];
                                        
                                        [boxAPI setAlbumSettingsWithDictionary:jsonStr albumid:albumid completionBlock:^(NSDictionary *result, NSError *error) {
                                            if (!error) {
                                                [wself updateAlbumact:albumid];
                                            } else if (error.code == 1111) {
                                                CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                                                style.messageColor = [UIColor whiteColor];
                                                style.backgroundColor = [UIColor thirdPink];
                                                
                                                [wself.view makeToast: @"用戶驗證異常請重新登入"
                                                            duration: 2.0
                                                            position: CSToastPositionBottom
                                                               style: style];
                                                
                                                [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                                                 target: self
                                                                               selector: @selector(logOut)
                                                                               userInfo: nil
                                                                                repeats: NO];
                                            } else {
                                                NSString *alert = [error localizedDescription];
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [wself showCustomErrorAlert:alert];
                                                });
                                            }
                                        }];
                                    }
                                } else {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [wself showToastMessage:@"作品資訊不完整不能公開"];
                                    });
                                }
                            } else {
                                NSString *alert = [error localizedDescription];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [wself showToastMessage:alert];
                                });
                            }
                        }];
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [wself showToastMessage:@"作品資訊不完整不能公開"];
                        });
                    }
                } else {
                    NSString *alert = [error localizedDescription];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [wself showToastMessage:alert];
                    });
                }
            }];
        }
    }
}

#pragma mark - cell opMenu action related
- (void)opMenuAction:(OpMenuActionType)action index:(NSInteger )index {
    NSLog(@"opMenuAction");
    
    if (index < dataarr.count) {
        NSDictionary *data = dataarr[index][@"album"];
        switch (action) {
            case OPEdit:{
                //  for refreshing album list
                //nextId = 0;
                isLoading = NO;
                
                NSDictionary *co = dataarr[index][@"cooperation"];
                NSDictionary *user = dataarr[index][@"user"];
                BOOL isSelfWork = [[user[@"user_id"] stringValue] isEqualToString:[wTools getUserID]];
                
                if (![data[@"album_id"] isEqual: [NSNull null]] && co && co[@"identity"]) {
                    NSString *i = co[@"identity"];
                    if (isSelfWork || ![co[@"identity"] isKindOfClass:[NSNull class]]) {
                        if (isSelfWork || ![i isEqualToString:@"viewer"]) {
                            if (![data[@"album_id"] isEqual: [NSNull null]]) {
                                if ([i isEqual: [NSNull null]]) {
                                    [self showCustomEditActionSheet: [data[@"album_id"] stringValue]
                                                       userIdentity: @"admin"
                                                          cellIndex: index];
                                } else if ([i isEqualToString: @"approver"] || [i isEqualToString: @"editor"]) {
//                                    [self toAlbumCreationViewController: [data[@"album_id"] stringValue] templateId: @"0" shareCollection: NO userIdentity: i cellIndex:index];
                                    
                                    [self toAlbumCreationViewController: [data[@"album_id"] stringValue] templateId: @"0" shareCollection: NO userIdentity: i cellIndex: index fromVC: self.fromVC];
                                }
                            }                            
                            return;
                        }
                    }
                }
                [self showToastMessage:@"權限不足"];
            }
                break;
            case OPShare: {
                if ([data[@"zipped"] intValue] != 1) {
                   [self showToastMessage:@"作品尚未完成"];
                } else if (![data[@"act"] isEqualToString:@"open"]){
                   [self showToastMessage:@"隱私必須開啟才能分享"];
                } else {
                    //  proceed to share
                    if (![data[@"album_id"] isEqual: [NSNull null]])
                        [self handleShare:[data[@"album_id"] stringValue]];
                }
            }
                break;
            case OPDelete:
                break;
            case OPInvite: {
                //  for refreshing album list
                //nextId = 0;
                isLoading = NO;
                
                NSDictionary *co = dataarr[index][@"cooperation"];
                NSDictionary *user = dataarr[index][@"user"];
                BOOL isSelfWork = [[user[@"user_id"] stringValue] isEqualToString:[wTools getUserID]];
                if (![data[@"album_id"] isEqual: [NSNull null]] && co && co[@"identity"]) {
                    NSString *i = co[@"identity"];
                    if (isSelfWork || ![co[@"identity"] isKindOfClass:[NSNull class]]) {
                        if (isSelfWork || [i isEqualToString:@"admin"] || [i isEqualToString:@"approver"]) {
                            //  proceed to invite
                            NewCooperationViewController *newCooperationVC = [[UIStoryboard storyboardWithName: @"NewCooperationVC" bundle: nil] instantiateViewControllerWithIdentifier: @"NewCooperationViewController"];
                            newCooperationVC.albumId = [data[@"album_id"] stringValue];
                            newCooperationVC.userIdentity = i;
                            newCooperationVC.vDelegate = self;
                            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                            [appDelegate.myNav pushViewController: newCooperationVC animated: YES];
                            return;
                        }
                    }
                }
                [self showToastMessage:@"權限不足"];
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark - opMenu edit
- (void)showCustomEditActionSheet:(NSString *)albumid
                     userIdentity:(NSString *)userIdentity
                        cellIndex:(NSInteger) index {
    NSLog(@"showCustomEditActionSheet");
    [wTools setStatusBarBackgroundColor: [UIColor clearColor]];
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle: UIBlurEffectStyleDark];
    [UIView animateWithDuration: kAnimateActionSheet animations:^{
        self.effectView = [[UIVisualEffectView alloc] initWithEffect: blurEffect];
    }];
    self.effectView.frame = CGRectMake(0, 0, self.view.frame.size.width, [UIApplication sharedApplication].keyWindow.bounds.size.height);//self.view.frame;
    self.effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.effectView.alpha = 0.8;
    
    [[UIApplication sharedApplication].keyWindow addSubview: self.effectView];
    [[UIApplication sharedApplication].keyWindow addSubview: self.customEditActionSheet.view];
    [self.customEditActionSheet viewWillAppear: NO];
    
    [self.customEditActionSheet addSelectItem: @"" title: @"作品編輯" btnStr: @"" tagInt: 1 identifierStr: @"albumEdit"];
    [self.customEditActionSheet addSelectItem: @"" title: @"修改資訊" btnStr: @"" tagInt: 2 identifierStr: @"modifyInfo"];
    
    __block typeof(self) weakSelf = self;
    self.customEditActionSheet.customViewBlock = ^(NSInteger tagId, BOOL isTouchDown, NSString *identifierStr) {
        if ([identifierStr isEqualToString: @"albumEdit"]) {
            NSLog(@"albumEdit item is pressed");
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf toAlbumCreationViewController: albumid
                                             templateId: @"0"
                                        shareCollection: NO
                                           userIdentity: userIdentity
                                              cellIndex: index
                                                 fromVC: weakSelf.fromVC];
//            [weakSelf toAlbumCreationViewController: albumid
//                                         templateId: @"0"
//                                    shareCollection: NO
//                                       userIdentity: userIdentity
//                                          cellIndex: index];
            });
        } else if ([identifierStr isEqualToString: @"modifyInfo"]) {
            NSLog(@"modifyInfo item is pressed");
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf toAlbumSettingViewController: albumid
                                            templateId: @"0"
                                          userIdentity: userIdentity
                                       shareCollection: NO
                                             cellIndex: index
                                                fromVC: weakSelf.fromVC];
                
//                [weakSelf toAlbumSettingViewController: albumid
//                                            templateId: @"0"
//                                       shareCollection: NO
//                                             cellIndex: index];
            });
        }
    };
}

- (void)toAlbumCreationViewController:(NSString *)albumId
                           templateId:(NSString *)templateId
                      shareCollection:(BOOL)shareCollection
                         userIdentity:(NSString *)userIdentity
                            cellIndex:(NSInteger)index
                               fromVC:(NSString *)fromVC {
    NSLog(@"toAlbumCreationViewController");    
    AlbumCreationViewController *acVC = [[UIStoryboard storyboardWithName: @"AlbumCreationVC" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumCreationViewController"];
    //acVC.selectrow = [wTools userbook];
    NSLog(@"userIdentity: %@", userIdentity);
    acVC.userIdentity = userIdentity;
    acVC.albumid = albumId;
    acVC.templateid = [NSString stringWithFormat:@"%@", templateId];
    acVC.shareCollection = shareCollection;
    acVC.postMode = NO;
    acVC.fromVC = fromVC;
    acVC.delegate = self;
    acVC.isNew = NO;
    
    if ([templateId isEqualToString:@"0"]) {
        acVC.booktype = 0;
        acVC.choice = @"Fast";
    } else {
        acVC.booktype = 1000;
        acVC.choice = @"Template";
    }
    acVC.view.tag = index;
    //[self.navigationController pushViewController: acVC animated: YES];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav pushViewController: acVC animated: YES];
}

- (void)toAlbumSettingViewController:(NSString *)albumId
                          templateId:(NSString *)templateId
                        userIdentity:(NSString *)userIdentity
                     shareCollection:(BOOL)shareCollection
                           cellIndex:(NSInteger)index
                              fromVC:(NSString *)fromVC {
    NSLog(@"toAlbumSettingViewController");
    AlbumSettingViewController *aSVC = [[UIStoryboard storyboardWithName: @"Main" bundle: nil] instantiateViewControllerWithIdentifier: @"AlbumSettingViewController"];
    aSVC.albumId = albumId;
    aSVC.postMode = NO;
    aSVC.templateId = [NSString stringWithFormat:@"%@", templateId];
    aSVC.userIdentity = userIdentity;
    aSVC.shareCollection = shareCollection;
    aSVC.fromVC = fromVC;
    aSVC.delegate = self;
    NSDictionary *al = dataarr[index][@"album"];
    //  check if album has contents
    aSVC.hasImage = ([al[@"usefor"][@"image"] boolValue] || [al[@"usefor"][@"video"] boolValue]) ;
    //[self.navigationController pushViewController: aSVC animated: YES];
    aSVC.view.tag = index;
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav pushViewController: aSVC animated: YES];
}

#pragma mark - opMenu share
- (void)handleShare:(NSString *)albumId {
    self.albumId = albumId;
    
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
        NSString *response = [boxAPI checkTaskCompleted: [wTools getUserID]
                                                  token: [wTools getUserToken]
                                               task_for: @"share_to_fb"
                                               platform: @"apple"
                                                   type: @"album"
                                                 typeId: albumId];
        
//        NSString *response = [boxAPI checkTaskCompleted: [wTools getUserID]
//                                                  token: [wTools getUserToken]
//                                               task_for: @"share_to_fb"
//                                               platform: @"apple"];
        
        NSString *albumDetail = [boxAPI retrievealbump:albumId uid:[wTools getUserID] token:[wTools getUserToken]];
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
                NSLog(@"response from checkTaskCompleted");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"AlbumDetailViewController");
                    NSLog(@"checkTaskComplete");
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                     protocolName: @"checkTaskCompleted"
                                          albumId: albumId];
                     
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *detail = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [albumDetail dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    NSDictionary *dt = detail[@"data"];
                    NSDictionary *eventjoin = [dt objectForKey:@"eventjoin"];
                    NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    //NSLog(@"data: %@", data);
                    NSString *autoPlayStr = @"&autoplay=1";
                    if ([data[@"result"] intValue] == 1) {
                        NSString *message;
                        
                        if (eventjoin) {
                            message = [NSString stringWithFormat: sharingLinkWithAutoPlay, albumId, autoPlayStr];
                        } else {
                            message = [NSString stringWithFormat: sharingLinkWithoutAutoPlay, albumId];
                        }
                        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems: [NSArray arrayWithObjects: message, nil] applicationActivities: nil];
                        [wself presentViewController: activityVC animated: YES completion: nil];
                    } else if ([data[@"result"] intValue] == 2) {
                        NSLog(@"data result intValue: %d", [data[@"result"] intValue]);
                        // Task is not completed, so pop ups alert view
                        //[self showSharingAlertView];
                        //[self showShareActionSheet];
                        [self showCustomShareActionSheet:eventjoin albumid:albumId autoplayStr:autoPlayStr];
                    } else if ([data[@"result"] intValue] == 0) {
                        NSString *message;
                        
                        if ([eventjoin isEqual: [NSNull null]]) {
                            message = [NSString stringWithFormat: sharingLinkWithAutoPlay, albumId, autoPlayStr];
                        } else {
                            message = [NSString stringWithFormat: sharingLinkWithoutAutoPlay, albumId];
                        }
                        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems: [NSArray arrayWithObjects: message, nil] applicationActivities: nil];
                        [wself presentViewController: activityVC animated: YES completion: nil];
                    } else {
                        [wself showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            }
        });
    });
}

- (void)showCustomShareActionSheet:(NSDictionary *)eventjoin
                           albumid:(NSString *)albumid
                       autoplayStr:(NSString *)autoplayStr {
    [wTools setStatusBarBackgroundColor: [UIColor clearColor]];
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle: UIBlurEffectStyleDark];
    [UIView animateWithDuration: kAnimateActionSheet animations:^{
        self.effectView = [[UIVisualEffectView alloc] initWithEffect: blurEffect];
    }];
    self.effectView.frame = CGRectMake(0, 0, self.view.frame.size.width, [UIApplication sharedApplication].keyWindow.bounds.size.height);//self.view.frame;
    self.effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.effectView.alpha = 0.8;
    
    [[UIApplication sharedApplication].keyWindow addSubview: self.effectView];
    [[UIApplication sharedApplication].keyWindow addSubview: self.customEditActionSheet.view];
    [self.customEditActionSheet viewWillAppear: NO];
    
    [self.customEditActionSheet addSelectItem: @"" title: @"獎勵分享(facebook)" btnStr: @"" tagInt: 1 identifierStr: @"fbSharing"];
    [self.customEditActionSheet addSelectItem: @"" title: @"一般分享" btnStr: @"" tagInt: 2 identifierStr: @"normalSharing"];
    
    __weak typeof(self) weakSelf = self;
    
    self.customEditActionSheet.customViewBlock = ^(NSInteger tagId, BOOL isTouchDown, NSString *identifierStr) {
        //NSLog(@"");
        NSLog(@"customShareActionSheet.customViewBlock executes");
        NSLog(@"tagId: %ld", (long)tagId);
        NSLog(@"isTouchDown: %d", isTouchDown);
        NSLog(@"identifierStr: %@", identifierStr);
        
        if ([identifierStr isEqualToString: @"fbSharing"]) {
            NSLog(@"fbSharing is pressed");
            FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
            
            if (eventjoin){//[weakSelf.data[@"eventjoin"] isEqual: [NSNull null]]) {
                NSLog(@"eventjoin is null");
                content.contentURL = [NSURL URLWithString: [NSString stringWithFormat: sharingLinkWithAutoPlay, albumid, autoplayStr]];
            } else {
                NSLog(@"eventjoin is not null");
                content.contentURL = [NSURL URLWithString: [NSString stringWithFormat: sharingLinkWithoutAutoPlay, albumid]];
            }
            
            [FBSDKShareDialog showFromViewController: weakSelf
                                         withContent: content
                                            delegate: weakSelf];
        } else if ([identifierStr isEqualToString: @"normalSharing"]) {
            NSLog(@"normalSharing is pressed");
            NSString *message;
            
            if ([eventjoin isEqual: [NSNull null]]) {
                NSLog(@"eventjoin is null");
                message = [NSString stringWithFormat: sharingLinkWithAutoPlay, albumid, autoplayStr];
            } else {
                NSLog(@"eventjoin is not null");
                message = [NSString stringWithFormat: sharingLinkWithoutAutoPlay, albumid];
            }
            NSLog(@"message: %@", message);
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems: [NSArray arrayWithObjects: message, nil] applicationActivities: nil];
            [weakSelf presentViewController: activityVC animated: YES completion: nil];
        }
    };
}

- (void)tryUpdateAlbumSetting:(NSUInteger)index {
    __block typeof(self) wself = self;
    NSString *limit = [NSString stringWithFormat:@"%ld,%d",(long)index, 1];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSArray *arr = @[@"mine",@"other",@"cooperation"];
        NSString *response = [boxAPI getcalbumlist: [wTools getUserID]
                                             token: [wTools getUserToken]
                                              rank: arr[wself->type]//type]
                                             limit: limit];
        NSLog(@"%@",response);
        if (response != nil) {
            if (![response isEqualToString: timeOutErrorCode]) {
                NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                NSArray *data = dic[@"data"];
                if (data && data.count) {
                    NSMutableDictionary *nd = [NSMutableDictionary dictionaryWithDictionary:data[0]];
                    [nd setObject:[NSNumber numberWithInteger:index] forKey:@"index"];
                    [wself->dataarr replaceObjectAtIndex:index withObject:nd];
                    [wself refreshCellAtIndex:index];
                }
            }
        }
    });
}

- (void)albumSettingViewControllerUpdate:(AlbumSettingViewController *)controller{
    NSString *aid = controller.albumId;
    //NSInteger idx = controller.view.tag;

    for (int i = 0; i< [dataarr count];i++) {
        NSMutableDictionary *c = (NSMutableDictionary *)dataarr[i];
        NSDictionary *calbum = c[@"album"];
        if (calbum && [[calbum[@"album_id"] stringValue] isEqualToString:aid]) {
            [self tryUpdateAlbumSetting:i];
            break;
        }
    }
}

- (void)albumCreationViewControllerBackBtnPressed:(AlbumCreationViewController *)controller {
    [self reloaddata];
}

- (void)newCoopeartionVCFinished:(NSString *)albumId {
    for (int i = 0; i< [dataarr count];i++) {
        NSMutableDictionary *c = (NSMutableDictionary *)dataarr[i];
        NSDictionary *calbum = c[@"album"];
        if (calbum && [[calbum[@"album_id"] stringValue] isEqualToString:albumId]) {
            [self tryUpdateAlbumSetting:i];
            break;
        }
    }
}

- (void)actionSheetViewDidSlideOut:(DDAUIActionSheetViewController *)controller {
    [wTools setStatusBarBackgroundColor: [UIColor whiteColor]];
    [self.effectView removeFromSuperview];
    self.effectView = nil;
}

#pragma mark - FB share SDK
- (void)sharer:(id<FBSDKSharing>)sharer
didCompleteWithResults:(NSDictionary *)results {
    NSLog(@"Sharing Complete");
    // Check whether getting Sharing Point or not
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL share_to_fb = [[defaults objectForKey: @"share_to_fb"] boolValue];
    NSLog(@"Check whether getting sharing point or not");
    NSLog(@"share_to_fb: %d", (int)share_to_fb);
    
    if (share_to_fb) {
        NSLog(@"Getting Sharing Point Already");
    } else {
        NSLog(@"Haven't got the point of sharing yet");
        task_for = @"share_to_fb";
        [self checkPoint];
    }
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    NSLog(@"Sharing didFailWithError");
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    NSLog(@"Sharing Did Cancel");
}

- (void)checkPoint {
    NSLog(@"checkPoint");
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
        NSString *response = [boxAPI doTask2: [wTools getUserID]
                                       token: [wTools getUserToken]
                                    task_for: wself->task_for
                                    platform: @"apple"
                                        type: @"album"
                                     type_id: wself.albumId];
        
        NSLog(@"User ID: %@", [wTools getUserID]);
        NSLog(@"Token: %@", [wTools getUserToken]);
        NSLog(@"Task_For: %@", wself->task_for);
        NSLog(@"Album ID: %@", wself.albumId);
        
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
                NSLog(@"response from doTask2");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"AlbumDetailViewController");
                    NSLog(@"checkPoint");
                    [wself showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                     protocolName: @"doTask2"
                                          albumId: wself.albumId];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *data = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    [wself processCheckPointResult:data];
                }
            }
        });
    });
}

- (void)processCheckPointResult:(NSDictionary *)data {
    if ([data[@"result"] intValue] == 1) {
        missionTopicStr = data[@"data"][@"task"][@"name"];
        NSLog(@"name: %@", missionTopicStr);
        
        rewardType = data[@"data"][@"task"][@"reward"];
        NSLog(@"reward type: %@", rewardType);
        
        rewardValue = data[@"data"][@"task"][@"reward_value"];
        NSLog(@"reward value: %@", rewardValue);
        
        eventUrl = data[@"data"][@"event"][@"url"];
        NSLog(@"event: %@", eventUrl);
        
        restriction = data[@"data"][@"task"][@"restriction"];
        NSLog(@"restriction: %@", restriction);
        
        restrictionValue = data[@"data"][@"task"][@"restriction_value"];
        NSLog(@"restrictionValue: %@", restrictionValue);
        
        numberOfCompleted = [data[@"data"][@"task"][@"numberofcompleted"] unsignedIntegerValue];
        NSLog(@"numberOfCompleted: %lu", (unsigned long)numberOfCompleted);
        
        [self showAlertViewForGettingPoint];
        //[self getPointStore];
    } else if ([data[@"result"] intValue] == 2) {
        NSLog(@"message: %@", data[@"message"]);
    } else if ([data[@"result"] intValue] == 0) {
        NSLog(@"失敗： %@", data[@"message"]);
    } else if ([data[@"result"] intValue] == 3) {
        NSLog(@"data result intValue: %d", [data[@"result"] intValue]);
    } else {
        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
    }
}

#pragma mark - Custom AlertView for Getting Point
- (void)showAlertViewForGettingPoint {
    NSLog(@"showAlertViewForGettingPoint");
    // Custom AlertView shows up when getting the point
    alertView = [[OldCustomAlertView alloc] init];
    [alertView setContainerView: [self createPointView]];
    [alertView setButtonTitles: [NSMutableArray arrayWithObject: @"確     認"]];
    [alertView setUseMotionEffects: true];
    [alertView show];
}

- (UIView *)createPointView {
    NSLog(@"createPointView"); 
    UIView *pointView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 250, 250)];
    // Mission Topic Label
    UILabel *missionTopicLabel = [[UILabel alloc] initWithFrame: CGRectMake(10, 15, 200, 10)];
    //missionTopicLabel.text = @"收藏相本得點";
    
    if ([wTools objectExists: missionTopicStr]) {
        missionTopicLabel.text = missionTopicStr;
        NSLog(@"Topic Label Text: %@", missionTopicStr);
    }
    
    [pointView addSubview: missionTopicLabel];
    
    if ([restriction isEqualToString: @"personal"]) {
        UILabel *restrictionLabel = [[UILabel alloc] initWithFrame: CGRectMake(10, 45, 200, 10)];
        restrictionLabel.textColor = [UIColor firstGrey];
        restrictionLabel.text = [NSString stringWithFormat: @"次數：%lu / %@", (unsigned long)numberOfCompleted, restrictionValue];
        NSLog(@"restrictionLabel.text: %@", restrictionLabel.text);
        [pointView addSubview: restrictionLabel];
    }
    // Gift Image
    UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(50, 90, 100, 100)];
    imageView.image = [UIImage imageNamed: @"icon_present"];
    imageView.center = CGPointMake(pointView.frame.size.width / 2, pointView.frame.size.height / 2);
    [pointView addSubview: imageView];
    
    // Message Label
    UILabel *messageLabel = [[UILabel alloc] initWithFrame: CGRectMake(10, 200, 200, 10)];
    
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
    
    if ([wTools objectExists: rewardValue]) {
        messageLabel.text = [NSString stringWithFormat: @"%@%@%@", congratulate, rewardValue, end];
    }
    
    [pointView addSubview: messageLabel];
    
    if ([eventUrl isEqual: [NSNull null]] || eventUrl == nil) {
        NSLog(@"eventUrl is equal to null or eventUrl is nil");
    } else {
        // Activity Button
        UIButton *activityButton = [UIButton buttonWithType: UIButtonTypeCustom];
        [activityButton addTarget: self action: @selector(showTheActivityPage) forControlEvents: UIControlEventTouchUpInside];
        activityButton.frame = CGRectMake(150, 220, 100, 10);
        [activityButton setTitle: @"活動連結" forState: UIControlStateNormal];
        [activityButton setTitleColor: [UIColor colorWithRed: 26.0/255.0 green: 196.0/255.0 blue: 199.0/255.0 alpha: 1.0]
                             forState: UIControlStateNormal];
        [pointView addSubview: activityButton];
    }
    
    return pointView;
}

- (void)showTheActivityPage {
    NSLog(@"showTheActivityPage");
    //NSString *activityLink = @"http://www.apple.com";
    NSLog(@"eventUrl: %@", eventUrl);
    
    if (![wTools objectExists: eventUrl]) {
        return;
    }
    
    NSString *activityLink = eventUrl;
    NSURL *url = [NSURL URLWithString: activityLink];
    // Close for present safari view controller, otherwise alertView will hide the background
    [alertView close];
    
    SFSafariViewController *safariVC1 = [[SFSafariViewController alloc] initWithURL: url entersReaderIfAvailable: NO];
    safariVC1.delegate = self;
    safariVC1.preferredBarTintColor = [UIColor whiteColor];
    [self presentViewController: safariVC1 animated: YES completion: nil];
}

#pragma mark - SFSafariViewController delegate methods
- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    // Done button pressed
    NSLog(@"show");
    [alertView show];
}

#pragma mark - Custom Error Alert Method
- (void)showCustomErrorAlert: (NSString *)msg {
    [UIViewController showCustomErrorAlertWithMessage:msg onButtonTouchUpBlock:^(CustomIOSAlertView *customAlertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[customAlertView tag]);
        [customAlertView close];
    }];
}

#pragma mark - Custom Method for TimeOut
- (void)showCustomTimeOutAlert:(NSString *)msg
                  protocolName:(NSString *)protocolName
                       albumId:(NSString *)albumId {
    CustomIOSAlertView *alertTimeOutView = [[CustomIOSAlertView alloc] init];
    //[alertTimeOutView setContainerView: [self createTimeOutContainerView: msg]];
    [alertTimeOutView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstMain] badgeName:@"icon_2_0_0_dialog_pinpin.png"];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertTimeOutView.arrangeStyle = @"Horizontal";
    
    alertTimeOutView.parentView = self.view.superview;
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
                [weakSelf getcalbumlist];
            } else if ([protocolName isEqualToString: @"delalbum"]) {
                [weakSelf deletebook: albumId];
            } else if ([protocolName isEqualToString: @"deletecooperation"]) {
                [weakSelf deletecooperation: albumId];
            } else if ([protocolName isEqualToString: @"hidealbumqueue"]) {
                [weakSelf hidealbumqueue: albumId];
            } else if ([protocolName isEqualToString: @"doTask2"]) {
                [weakSelf checkPoint];
            }
        }
    }];
    [alertTimeOutView setUseMotionEffects: YES];
    alertTimeOutView.parentView = nil;
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
    
    //NSLog(@"");
    NSLog(@"contentView: %@", NSStringFromCGRect(contentView.frame));
    //NSLog(@"");
    
    return contentView;
}

@end
