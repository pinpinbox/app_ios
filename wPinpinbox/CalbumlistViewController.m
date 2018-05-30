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
#import "Remind.h"
#import "GHContextMenuView.h"
#import "CooperationViewController.h"
#import "CustomIOSAlertView.h"
#import "UIColor+Extensions.h"
#import "GlobalVars.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface CalbumlistViewController () <CalbumlistDelegate, GHContextOverlayViewDataSource, GHContextOverlayViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    NSInteger type;
    NSMutableArray *dataarr;
    
    BOOL isLoading;
    NSInteger  nextId;
    BOOL isreload;
    UIView *backview;
    
    BOOL isLoadbtn;
}

@property (nonatomic, strong) JCCollectionViewWaterfallLayout *layout;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewBottomConstraint;

@end

@implementation CalbumlistViewController

#pragma mark - View Loading Related Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"");
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
    
    self.layout = (JCCollectionViewWaterfallLayout *)self.collectioview.collectionViewLayout;
    self.layout.headerHeight = 0.0f;
    self.layout.footerHeight = 0.0f;
    //self.layout.sectionInset=UIEdgeInsetsMake(0, 25, 0, 25);

    // Do any additional setup after loading the view from its nib.
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
    [_collectioview addSubview:_refreshControl];
    _collectioview.alwaysBounceVertical=YES;
    
    [_btn1 setTitle:NSLocalizedString(@"FavText-myWorks", @"") forState:UIControlStateNormal];
    [_btn2 setTitle:NSLocalizedString(@"FavText-otherFav", @"") forState:UIControlStateNormal];
    [_btn3 setTitle:NSLocalizedString(@"FavText-publicFav", @"") forState:UIControlStateNormal];
    
    _btn1.exclusiveTouch=YES;
    _btn2.exclusiveTouch=YES;
    _btn3.exclusiveTouch=YES;
    _collectioview.exclusiveTouch=YES;
    
    GHContextMenuView *overlay = [[GHContextMenuView alloc] init];
    overlay.dataSource = self;
    overlay.delegate = self;
    
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget: overlay
                                                                                                      action: @selector(longPressDetected:)];
    [_collectioview addGestureRecognizer: longPressRecognizer];
    
    self.collectioview.showsVerticalScrollIndicator = NO;
    
    // Avoid loading data twice for showing same data in PageCollectionViewController
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"");
    NSLog(@"CalbumlistViewController");
    NSLog(@"viewWillAppear");
    NSLog(@"Test");
    [wTools setStatusBarBackgroundColor: [UIColor colorWithRed: 255.0 green: 255.0 blue: 255.0 alpha: 1.0]];
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
    
    //[_collectioview reloadData];    
    //[self refresh];
    [self reloaddata];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];    
    NSLog(@"viewWillDisappear");
    [wTools setStatusBarBackgroundColor: [UIColor colorWithRed: 255.0 green: 255.0 blue: 255.0 alpha: 0.0]];
    //[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear");
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
                self.collectionViewBottomConstraint.constant = -40;
                break;
            default:
                printf("unknown");
                break;
        }
    }
}

#pragma mark -

-(void)refresh {
    NSLog(@"refresh");
    
    if (!isreload) {
        isreload=YES;
        nextId = 0;
  
        [_collectioview setContentOffset:CGPointMake(0, 0) animated:NO];
        [self reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btn:(UIButton *)sender {
    NSLog(@"");
    NSLog(@"btn:(UIButton *)sender");
    
    if (!isLoadbtn) {
        isLoadbtn=YES;
        [_collectioview setContentOffset:CGPointMake(0, 0) animated:NO];
        
        [wTools ShowMBProgressHUD];
        
        _btn1.selected=NO;
        _btn2.selected=NO;
        _btn3.selected=NO;
        
        sender.selected=YES;
        
        if (_btn1==sender) {
            type=0;
            
            NSLog(@"Tab Bar 1");
            NSLog(@"我上傳的相本");
        }else if(_btn2==sender){
            type=1;
            
            NSLog(@"Tab Bar 2");
            NSLog(@"其他收藏");
        }else{
            type=2;
            
            NSLog(@"Tab Bar 3");
            NSLog(@"共用收藏");
        }
        
        dataarr=[NSMutableArray new];
        nextId = 0;
        isLoading = NO;
        
        [self getcalbumlist];
    }
}

-(void)reloaddata {
    NSLog(@"");
    NSLog(@"reloaddata");
    //[mytableview setContentOffset:CGPointZero animated:YES];
    
    NSLog(@"isLoading: %d", isLoading);
    NSLog(@"before check if !isLoading");
    
    if (!isLoading) {
        isLoading = YES;
        [self getcalbumlist];
    }
}

- (void)getcalbumlist {
    NSLog(@"");
    NSLog(@"getcalbumlist");
    
    [wTools ShowMBProgressHUD];
    
    NSString *limit=[NSString stringWithFormat:@"%ld,%ld",(long)nextId, 10];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSArray *arr = @[@"mine",@"other",@"cooperation"];
        NSString *response = [boxAPI getcalbumlist: [wTools getUserID]
                                             token: [wTools getUserToken]
                                              rank: arr[type]
                                             limit: limit];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"response from getcalbumlist");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"CalbumlistViewController");
                    NSLog(@"getcalbumlist");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getcalbumlist"
                                         albumId: @""];
                    [self.refreshControl endRefreshing];
                    isreload = NO;
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    NSLog(@"dic: %@", dic);
                    
                    if ([dic[@"result"]boolValue]) {
                        if (nextId==0) {
                            dataarr=[NSMutableArray new];
                        }
                        int s=0;
                        for (NSMutableDictionary *picture in [dic objectForKey:@"data"]) {
                            s++;
                            [dataarr addObject: picture];
                        }
                        nextId = nextId+s;
                        // dataarr=[dic[@"data"] mutableCopy];
                        
                        //NSLog(@"dataarr: %@", dataarr);
                        
                        [_refreshControl endRefreshing];
                        [_collectioview reloadData];
                        
                        if (nextId  >= 0)
                            isLoading = NO;
                        
                        if (s==0) {
                            isLoading = YES;
                        }
                        
                        isreload = NO;
                    } else {
                        NSLog(@"失敗：%@",dic[@"message"]);
                        [_refreshControl endRefreshing];
                        isreload = NO;
                    }
                }
            }else{
                [_refreshControl endRefreshing];
                isreload = NO;
            }
        });
    });
}

//沒有資料產生的畫面

#pragma mark - UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section {
    if (backview!=nil) {
        [backview removeFromSuperview];
        backview=nil;
    }
    if (dataarr.count == 0) {
        NSLog(@"type: %ld", (long)type);
        
        UILabel *lab1;
        
        @try {
            NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"CalbumV%i",type+1] owner:self options:nil];
            backview = [subviewArray objectAtIndex:0];
            [collectionView addSubview:backview];
            
            lab1=[(UILabel *)backview viewWithTag:100];
        } @catch (NSException *exception) {
            // Print exception information
            NSLog( @"NSException caught" );
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
            return 0;
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
        
        return 0;
        
    }
    return dataarr.count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CalbumlistCollectionViewCell *Cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Calbumlist" forIndexPath:indexPath];
    Cell.delegate = self;
    Cell.type = type;
    
    //[Cell reloadmenu];
    
    if (dataarr.count < indexPath.row + 1) {
        return Cell;
    }
    
    NSLog(@"cellForItemAtIndexPath");
    NSLog(@"dataArr: %@", dataarr);
    
    NSDictionary *data = dataarr[indexPath.row][@"album"];
    NSLog(@"data: %@", data);
    
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
    img.contentMode = UIViewContentModeScaleAspectFit;
    img.image = [UIImage imageNamed:@"123"];
    
    if (![data[@"cover"] isKindOfClass:[NSNull class]]) {
        //[[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: img];
        //img.imageURL = [NSURL URLWithString:data[@"cover"]];
        [img sd_setImageWithURL: [NSURL URLWithString:data[@"cover"]]];
    } else {
        img.imageURL = nil;
    }
    
    Cell.zipped = [data[@"zipped"] boolValue];
    //Cell.stopview.hidden = YES;
    
    NSLog(@"data zipped boolvalue: %d", [data[@"zipped"] boolValue]);
    
    if ([data[@"zipped"] boolValue]) {
        img.alpha = 1;
        Cell.lockImgV.hidden = YES;
        Cell.unfinishedLabel.hidden = YES;
    } else {
        img.alpha = 0.3;
        Cell.lockImgV.hidden = NO;
        Cell.unfinishedLabel.hidden = NO;
    }
    
    /*
    NSLog(@"act: %@", data[@"act"]);
    if ([data[@"act"] isEqualToString: @"close"]) {
        img.alpha = 0.3;
        Cell.lockImgV.hidden = NO;
        Cell.unfinishedLabel.hidden = NO;
    } else {
        img.alpha = 1;
        Cell.lockImgV.hidden = YES;
        Cell.unfinishedLabel.hidden = YES;
    }
    */
    
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
    
    NSLog(@"");
    NSLog(@"");
    NSLog(@"data: %@", data);
    
    NSString *myString=[NSString stringWithFormat:@"    %@",data[@"name"]];
    
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:11]};
    CGSize size = [myString boundingRectWithSize:CGSizeMake(111, MAXFLOAT) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    //UILabel *label=(UILabel *)[Cell.bgview viewWithTag:1111];
    
//    if (label==nil) {
//        //label=[[UILabel alloc]initWithFrame:CGRectMake(8, 230, 111, 0)];
//        label.font = [UIFont systemFontOfSize:11];
//        label.textColor = [UIColor colorWithRed:(float)110/255 green:(float)110/255 blue:(float)110/255 alpha:1.0];
//        //label.tag = 1111;
//        //label.numberOfLines=0;
//        label.numberOfLines = 4;
//        label.lineBreakMode = NSLineBreakByTruncatingTail;
//        //[Cell.bgview addSubview:label];
//    }
    
    NSLog(@"myString: %@", myString);
    NSLog(@"size.height: %f", size.height);
    
    // If line height is higher than 60 then set it to 60 for 4 lines.
//    if (size.height > 60) {
//        label.frame=CGRectMake(label.frame.origin.x, label.frame.origin.y, 111, 60);
//    } else {
//        label.frame=CGRectMake(label.frame.origin.x, label.frame.origin.y, 111, size.height);
//    }
 
    //label.frame=CGRectMake(label.frame.origin.x, label.frame.origin.y, 111, 100);
    //label.text = myString;
    Cell.descriptionLabel.text = myString;

    //個人資料
    NSDictionary *userdata=dataarr[indexPath.row][@"user"];
    Cell.userid=userdata[@"user_id"];
    img=Cell.picture;
    img.image=[UIImage imageNamed:@"2-01aaphoto.png"];
    
    if (![userdata[@"picture"] isKindOfClass:[NSNull class]]) {
        if (![userdata[@"picture"] isEqualToString:@""]) {
            [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: img];
            img.imageURL=[NSURL URLWithString:userdata[@"picture"]];
        }
    }else{
        img.image=[UIImage imageNamed:@""];
    }

    if (![userdata[@"name"] isEqual:[NSNull null]]) {
        Cell.mytitle.text=userdata[@"name"];
    }
    
    //取得資料ID
    NSString *name=[NSString stringWithFormat:@"%@%@",[wTools getUserID],[data[@"album_id"] stringValue]];
    NSString *docDirectoryPath = [filepinpinboxDest stringByAppendingPathComponent:name];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //檢查資料夾是否存在
    if ([fileManager fileExistsAtPath:docDirectoryPath]) {
        Cell.downimage.image=[UIImage imageNamed:@"icon_download-already.png"];
    }else{
        Cell.downimage.image=[UIImage imageNamed :@"icon_download.png"];
    }
    
    return Cell;
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
    
    NSDictionary *data = dataarr[indexPath.row][@"album"];
    NSLog(@"data: %@", data);
    
    if ([data[@"usefor"][@"image"] boolValue] || [data[@"usefor"][@"video"] boolValue]) {
        BOOL zipped = [data[@"zipped"] boolValue];
        NSString *albumId;
        
        NSDictionary *userdata=dataarr[indexPath.row][@"user"];
        NSString *userId = userdata[@"user_id"];
        
        if (![data[@"album_id"] isEqual: [NSNull null]]) {
            albumId = [data[@"album_id"] stringValue];
        }
        if (zipped) {
            NSLog(@"if zipped is YES");
            if (type == 2) {
                [wTools ReadTestBookalbumid: albumId userbook: @"Y" eventId: nil postMode: nil fromEventPostVC: nil];
                return;
            }
            if ([[(id)userId stringValue] isEqualToString:[wTools getUserID]]) {
                [wTools ReadTestBookalbumid: albumId userbook: @"Y" eventId: nil postMode: nil fromEventPostVC: nil];
            } else {
                [wTools ReadTestBookalbumid: albumId userbook: @"Y" eventId: nil postMode: nil fromEventPostVC: nil];
            }
        }
    } else {
        [self showCustomErrorAlert: @"作品沒有內容"];
    }
}

- (void)collectionView:(UICollectionView *)collectionView
didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"didHighlightItemAtIndexPath");
    NSLog(@"indexPath.row: %ld", (long)indexPath.row);
}

#pragma mark - UICollectionViewFlowLayoutDelegate
-(CGSize)collectionView:(UICollectionView *)collectionView
                 layout:(UICollectionViewLayout *)collectionViewLayout
 sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"collectionViewLayout sizeForItemAtIndexPath");
    
    int i = 0;
    //i=arc4random() % 50;
    NSDictionary *data=dataarr[indexPath.row][@"album"];
    NSString *myString=[NSString stringWithFormat:@"    %@",data[@"description"]];
    
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:11]};
    CGSize size = [myString boundingRectWithSize:CGSizeMake(111, MAXFLOAT) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    i = size.height;
    
    NSLog(@"i: %d", i);
    NSLog(@"%@", NSStringFromCGSize(CGSizeMake(128, 242+15+i)));
    
    if (i > 50) {
        i = 50;
    }
    
    NSLog(@"i: %d", i);
    NSLog(@"%@", NSStringFromCGSize(CGSizeMake(128, 242+15+i)));
    
    return CGSizeMake(128, 242+15+i);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 16.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 16.0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 16, 0, 16);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (isLoading)
        return;
    
    if ((scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height * 2)) {
        [self reloaddata];
    }
}

#pragma mark - GHMenu Methods

- (BOOL)shouldShowMenuAtPoint:(CGPoint)point {
    NSIndexPath *indexPath = [_collectioview indexPathForItemAtPoint: point];
    UICollectionViewCell *cell = [_collectioview cellForItemAtIndexPath: indexPath];
    
    return cell != nil;
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

- (void)didSelectItemAtIndex:(NSInteger)selectedIndex forMenuAtPoint:(CGPoint)point {
    NSLog(@"didSelectItemAtIndex");
    NSIndexPath *indexPath = [_collectioview indexPathForItemAtPoint: point];
    NSLog(@"indexPath.row: %ld", (unsigned long)indexPath.row);
    
    NSString *msg = nil;
    
    //if (self.collectionType == 0 || self.collectionType == 2) {
    if (self.collectionType == 0) {
        switch (selectedIndex) {
            case 0:
                msg = @"Delete";
                break;
            case 1:
                msg = @"PhotoEdit";
                break;
            case 2:
                msg = @"Share";
                break;
            case 3:
                msg = @"Cooperation";
            default:
                break;
        }
    } else if (self.collectionType == 1) {
        switch (selectedIndex) {
            case 0:
                msg = @"Delete";
                break;
            case 1:
                msg = @"Share";
            default:
                break;
        }
    }
    
    NSDictionary *data = dataarr[indexPath.row][@"album"];
    NSString *albumId = [data[@"album_id"] stringValue];
    NSString *templateId = [dataarr[indexPath.row][@"template"][@"template_id"] stringValue];
    NSLog(@"templateId: %@", templateId);
    NSDictionary *userdata = dataarr[indexPath.row][@"user"];
    NSString *identity = dataarr[indexPath.row][@"cooperation"][@"identity"];
    
    BOOL hasImage = [data[@"usefor"][@"image"] boolValue];
    NSLog(@"hasImage: %d", hasImage);
    
    if ([msg isEqualToString: @"Delete"]) {
        NSLog(@"msg isEqualToString: Delete");
        [self deleteBook: indexPath];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject: [NSNumber numberWithBool: YES] forKey: @"deleteAlbum"];
        [defaults synchronize];
    }
    if ([msg isEqualToString: @"PhotoEdit"]) {
        if (self.collectionType == 2) {
            if ([identity isEqualToString: @"viewer"]) {
                [self showCustomAlertNormal: NSLocalizedString(@"CreateAlbumText-tipPermissions", @"")];
                return;
            }
            if ([self.delegate respondsToSelector: @selector(editPhoto:templateId:shareCollection:hasImage:)]) {
                NSLog(@"self.delegate respondsToSelector editphotoinfo:templateid:eventId:postMode:");
                [self.delegate editPhoto: albumId templateId: templateId shareCollection: YES hasImage: hasImage];
            }
        } else if (self.collectionType == 0) {
            if ([self.delegate respondsToSelector: @selector(editPhoto:templateId:shareCollection:hasImage:)]) {
                NSLog(@"self.delegate respondsToSelector editphotoinfo:templateid:eventId:postMode:");
                [self.delegate editPhoto: albumId templateId: templateId shareCollection: NO hasImage: hasImage];
            }
        }
    }
    if ([msg isEqualToString: @"Share"]) {
        NSString *sharingStr = [NSString stringWithFormat:@"%@ http://www.pinpinbox.com/index/album/content/?album_id=%@", userdata[@"name"], albumId];
        
        if ([self.delegate respondsToSelector: @selector(shareLink:albumId:)]) {
            [self.delegate shareLink: sharingStr
                             albumId: albumId];
        }
    }
    if ([msg isEqualToString: @"Cooperation"]) {
        if (self.collectionType == 2) {
            NSLog(@"identity: %@", identity);
            
            if ([identity isEqualToString: @"viewer"] || [identity isEqualToString: @"editor"]) {
                [self showCustomAlertNormal: NSLocalizedString(@"CreateAlbumText-tipPermissions", @"")];
                return;
            }
            if ([self.delegate respondsToSelector: @selector(editCooperation:identity:)]) {
                NSLog(@"self.delegate respondsToSelector editCooperation");
                [self.delegate editCooperation: albumId identity: identity];
            }
        } else if (self.collectionType == 0) {
            NSLog(@"identity: %@", identity);
            
            if ([self.delegate respondsToSelector: @selector(editCooperation:identity:)]) {
                NSLog(@"self.delegate respondsToSelector editCooperation");
                [self.delegate editCooperation: albumId identity: @"admin"];
            }
        }
    }
}

- (void)getIdentity:(NSString *)albumId templateId:(NSString *)templateId msg:(NSString *)msg
{
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
                
                if ([dic[@"result"] boolValue]) {
                    NSLog(@"call getalbumofdiy success");
                    NSLog(@"%@", dic[@"data"][@"photo"]);
                    
                    NSString *identity;
                    identity = identdic[@"data"];
                    
                    if ([msg isEqualToString: @"Cooperation"]) {
                        
                        
                    }
                    
                    if ([msg isEqualToString: @"PhotoEdit"]) {
                        
                    }
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
    NSLog(@"");
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
                    
                    if ([dic[@"result"]boolValue]) {
                        [self reloadData];
                    } else {
                        NSLog(@"失敗：%@", dic[@"message"]);
                        [self showCustomAlertNormal: dic[@"message"]];
                        [self reloadData];
                    }
                }
            }
        });
    });
}

#pragma mark - Custom Alert Method
- (void)showCustomAlertNormal: (NSString *)msg
{
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    [alertView setContainerView: [self createContainerViewNormal: msg]];
    
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertView.arrangeStyle = @"Horizontal";
    
    [alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"取消", @"確定", nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor firstMain],nil]];
    [alertView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor whiteColor], nil]];
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

- (UIView *)createContainerViewNormal: (NSString *)msg
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


- (void)showCustomAlert: (NSString *)msg path:(NSString *)docDirectoryPath albumId:(NSString *)albumId
{
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    [alertView setContainerView: [self createContainerView: msg]];
    
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertView.arrangeStyle = @"Horizontal";
    
    [alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"取消", @"確定", nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor firstMain],nil]];
    [alertView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor whiteColor], nil]];
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

#pragma mark - Custom Alert Method
- (void)showCustomAlert: (NSString *)msg albumId:(NSString *)albumId
{
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    [alertView setContainerView: [self createContainerView1: msg]];
    
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertView.arrangeStyle = @"Horizontal";
    
    [alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"取消", @"確定", nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor firstMain],nil]];
    [alertView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor whiteColor], nil]];
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

- (UIView *)createContainerView1: (NSString *)msg
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
                    
                    if ([dic[@"result"] boolValue]) {
                        [self reloadData];
                        [self deletePlist: albumid];
                        
                    } else {
                        [self showCustomAlertNormal: dic[@"message"]];
                        [self reloadData];
                    }
                }
            }
        });
    });
}

- (void)deletePlist: (NSString *)albumId
{
    NSLog(@"deletePlist");
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex: 0];
    NSString *filePath = [documentsDirectory stringByAppendingString: @"/GiftData.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableDictionary *data;
    
    if ([fileManager fileExistsAtPath: filePath]) {
        NSLog(@"file exists");
        
        data = [[NSMutableDictionary alloc] initWithContentsOfFile: filePath];
        NSLog(@"data: %@", data);
        
        [data removeObjectForKey: albumId];
        NSLog(@"data: %@", data);
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
                        [self showCustomAlertNormal: dic[@"message"]];
                        [self reloadData];
                    }
                }
            }
        });
    });
}

#pragma mark - Custom Error Alert Method
- (void)showCustomErrorAlert: (NSString *)msg
{
    CustomIOSAlertView *errorAlertView = [[CustomIOSAlertView alloc] init];
    [errorAlertView setContainerView: [self createErrorContainerView: msg]];
    
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

#pragma mark - Custom Method for TimeOut
- (void)showCustomTimeOutAlert: (NSString *)msg
                  protocolName: (NSString *)protocolName
                       albumId: (NSString *)albumId
{
    CustomIOSAlertView *alertTimeOutView = [[CustomIOSAlertView alloc] init];
    [alertTimeOutView setContainerView: [self createTimeOutContainerView: msg]];
    
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertTimeOutView.arrangeStyle = @"Horizontal";
    
    alertTimeOutView.parentView = self.view.superview;
    [alertTimeOutView setButtonTitles: [NSMutableArray arrayWithObjects: NSLocalizedString(@"TimeOut-CancelBtnTitle", @""), NSLocalizedString(@"TimeOut-OKBtnTitle", @""), nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertTimeOutView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstMain],nil]];
    [alertTimeOutView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor whiteColor], nil]];
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

@end
