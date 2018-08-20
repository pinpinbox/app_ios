//
//  CreativeViewController.m
//  wPinpinbox
//
//  Created by Angus on 2015/10/28.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "CreativeViewController.h"
#import "JCCollectionViewWaterfallLayout.h"
#import "wTools.h"
#import "boxAPI.h"
#import "AppDelegate.h"
#import "CreativeCollectionReusableView.h"
#import "CreativeCollectionViewCell.h"

#import "UIImage+AverageColor.h"

#import "RetrievealbumpViewController.h"
#import "Remind.h"

#import "CustomIOSAlertView.h"
#import "UIColor+Extensions.h"

#define kSmallestHeight 31.666667
#define kYAxisValue 303
#define kGap 0

@interface CreativeViewController () <JCCollectionViewWaterfallLayoutDelegate, UICollectionViewDelegateFlowLayout>
{
    NSMutableArray *pictures;
    BOOL isLoading;
    NSInteger  nextId;
    BOOL isReload;
    
    NSString *name;
    NSString *profilepic;
    NSString *bio;
    
    NSString *countf;
    NSString *viewedNumber;
    
    BOOL heightChanged;
    CGSize headerSize;
}

@property (nonatomic, strong) JCCollectionViewWaterfallLayout *layout;
@property (nonatomic, weak) IBOutlet UICollectionView *collectioview;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation CreativeViewController

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"viewDidAppear");
    
    [super viewDidAppear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    //[_collectioview reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"viewDidDisappear");
    
    [super viewDidDisappear:animated];
    
    // Set up for back to the previous one for disable swipe gesture
    // Because the home view controller can not swipe back to Main Screen
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"viewWillAppear");
    [super viewWillAppear:animated];
    
    [UIView animateWithDuration: 1.0 animations:^{
        self.view.alpha = 0;
        self.view.alpha = 1;
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"CreativeViewController");
    NSLog(@"viewDidLoad");
    
    // NavigationBar Text Setup
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:18 weight:UIFontWeightLight], NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    /*
     [self.navigationController.navigationBar setBackgroundImage: [UIImage new] forBarMetrics: UIBarMetricsDefault];
     self.navigationController.navigationBar.shadowImage = [UIImage new];
     self.navigationController.navigationBar.translucent = YES;
     self.navigationController.view.backgroundColor = [UIColor clearColor];
     */
    
    countf=@"0";
    viewedNumber = @"0";
    nextId = 0;
    isLoading = NO;
    isReload = NO;
    pictures = [NSMutableArray new];
    
    self.layout = (JCCollectionViewWaterfallLayout *)self.collectioview.collectionViewLayout;
    
    //self.layout.headerHeight = 400.0f;
    self.layout.headerHeight = kYAxisValue + kSmallestHeight + kGap;
    self.layout.footerHeight = 0.0f;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget: self action: @selector(refresh) forControlEvents: UIControlEventValueChanged];
    [self.collectioview addSubview: self.refreshControl];
    
    
    [_button setTitle:@"" forState:UIControlStateNormal];
    
    NSLog(@"userId: %@, albumId: %@", _userid, _albumid);
    
    if (_userid==nil && _albumid!=nil)
    {
        //先取得作者ID
        [wTools ShowMBProgressHUD];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            
            NSString *respone = [boxAPI retrieveauthor:[wTools getUserID] token:[wTools getUserToken] albumid:_albumid];
            dispatch_async(dispatch_get_main_queue(), ^{
                [wTools HideMBProgressHUD];
                
                if (respone!=nil) {
                    NSLog(@"%@",respone);
                    NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    NSLog(@"dic: %@", dic);
                    
                    if ([dic[@"result"] intValue] == 1) {
                        _follow=[dic[@"data"][@"follow"] boolValue];
                        _userid=[NSString stringWithFormat:@"%@",dic[@"data"][@"authorid"]];
                        [self reloaddata];
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗：%@",dic[@"message"]);
                        [self showCustomErrorAlert: dic[@"message"]];
                    } else {
                        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            });
        });
        
    } else {
        [self reloaddata];
    }
    _collectioview.exclusiveTouch=YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refresh {
    NSLog(@"refresh");
    
    if (!isReload) {
        isReload = YES;
        
        nextId = 0;
        
        [self.collectioview setContentOffset: CGPointMake(0, 0) animated: YES];
        [self reloadData];
    }
}

- (void)reloadData {
    nextId = 0;
    isLoading = NO;
    [self reloaddata];
}

-(void)reloaddata {
    
    NSLog(@"reload data");
    NSLog(@"follow: %d", _follow);
    
    if (_follow) {
        [_button setTitle:NSLocalizedString(@"AuthorText-inAtt", @"") forState:UIControlStateNormal];
        //_button.hidden=YES;
    } else {
        [_button setTitle:NSLocalizedString(@"AuthorText-att", @"") forState:UIControlStateNormal];
        // _button.hidden=NO;
    }
    
    if (!isLoading) {
        if (pictures.count==0) {
            [wTools ShowMBProgressHUD];
        }
        
        isLoading = YES;
        
        NSMutableDictionary *data = [NSMutableDictionary new];
        NSString *limit=[NSString stringWithFormat:@"%ld,%ld",(long)nextId,nextId+10];
        [data setValue:limit forKey:@"limit"];
        [data setObject:_userid forKey:@"authorid"];
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            
            NSString *respone=[boxAPI getcreative:[wTools getUserID] token:[wTools getUserToken] data:data];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [wTools HideMBProgressHUD];
                
                if (respone!=nil) {
                    NSLog(@"response from getCreative is not nil");
                    
                    NSLog(@"%@",respone);
                    NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    NSLog(@"dic: %@", dic);
                    
                    if ([dic[@"result"] intValue] == 1) {
                        name=[wTools stringisnull:dic[@"data"][@"user"][@"name"]];
                        profilepic=[wTools stringisnull:dic[@"data"][@"user"][@"picture"]];
                        bio=[wTools stringisnull:dic[@"data"][@"user"][@"description"]];
                        _mytitle.text=name;
                        
                        if (nextId == 0) {
                            pictures = [NSMutableArray new];
                        }
                        
                        int s=0;
                        
                        for (NSMutableDictionary *picture in [dic objectForKey:@"data"][@"album"]) {
                            s++;
                            [pictures addObject: picture];
                        }
                        
                        nextId = nextId+s;
                        countf = [wTools stringisnull:dic[@"data"][@"follow"][@"count_from"]];
                        viewedNumber = [wTools stringisnull: dic[@"data"][@"user"][@"viewed"]];
                        
                        NSLog(@"dic data follow: %@", dic[@"data"][@"follow"]);
                        
                        _follow=[dic[@"data"][@"follow"][@"follow"] boolValue];
                        
                        if (_follow) {
                            [_button setTitle:NSLocalizedString(@"AuthorText-inAtt", @"") forState:UIControlStateNormal];
                            //_button.hidden=YES;
                        }else{
                            [_button setTitle:NSLocalizedString(@"AuthorText-att", @"") forState:UIControlStateNormal];
                            // _button.hidden=NO;
                        }
                        
                        [self.refreshControl endRefreshing];
                        [_collectioview reloadData];
                        NSLog(@"_collectioview reloadData");
                        
                        if (nextId >= 0)
                            isLoading = NO;
                        
                        if (s == 0) {
                            isLoading=YES;
                        }
                        
                        isReload = NO;
                        
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗：%@",dic[@"message"]);
                        [self showCustomErrorAlert: dic[@"message"]];
                        [self.refreshControl endRefreshing];
                    } else {
                        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                        [self.refreshControl endRefreshing];
                    }
                } else {
                    [self.refreshControl endRefreshing];
                }
            });
        });
    }
}

#pragma mark - IBAction

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//加入關注
- (IBAction)followbtn:(id)sender {
    [wTools ShowMBProgressHUD];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *respone=[boxAPI changefollowstatus:[wTools getUserID] token:[wTools getUserToken] authorid:_userid];
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (respone!=nil) {
                NSLog(@"%@",respone);
                NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                if ([dic[@"result"] intValue] == 1) {
                    [self refresh];
                    
                    NSDictionary *d=dic[@"data"];
                    if ([d[@"followstatus" ]boolValue]) {
                        [_button setTitle:NSLocalizedString(@"AuthorText-inAtt", @"") forState:UIControlStateNormal];
                        //_button.hidden=YES;
                    }else{
                        [_button setTitle:NSLocalizedString(@"AuthorText-att", @"") forState:UIControlStateNormal];
                        // _button.hidden=NO;
                    }
                } else if ([dic[@"result"] intValue] == 0) {
                    NSLog(@"失敗：%@",dic[@"message"]);
                    [self showCustomErrorAlert: dic[@"message"]];
                } else {
                    [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                }
            }
        });
    });
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"numberOfItemsInSection");
    NSLog(@"pictures.count: %lu", (unsigned long)pictures.count);
    return pictures.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cellForItemAtIndexPath");
    
    CreativeCollectionViewCell *Cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"Creative" forIndexPath:indexPath];
    
    NSDictionary *data=pictures[indexPath.row];
    NSLog(@"data cover: %@", data[@"cover"]);
    
    AsyncImageView *img=(AsyncImageView*)Cell.imageView;
    
    img.imageURL=nil;
    
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: img];
    
    if ([data[@"cover"] isEqual: [NSNull null]]) {
        img.imageURL = [NSURL URLWithString: @"https://ppb.sharemomo.com/static_file/pinpinbox/zh_TW/images/origin.jpg"];
    } else {
        img.imageURL = [NSURL URLWithString:data[@"cover"]];
    }
    
    Cell.datestr.text = data[@"inserttime"];
    
    NSLog(@"data insert time: %@", data[@"inserttime"]);
    NSLog(@"cell.datestr: %@", Cell.datestr);
    
    NSString *myString=pictures[indexPath.row][@"description"];
    
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:11]};
    CGSize size = [myString boundingRectWithSize:CGSizeMake(111, 66) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    
    UILabel *label=(UILabel *)[Cell.bgview viewWithTag:1111];
    
    if (label==nil) {
        label=[[UILabel alloc]initWithFrame:CGRectMake(8, 195, 111, 0)];
        label.font=[UIFont systemFontOfSize:11];
        label.textColor=[UIColor colorWithRed:(float)110/255 green:(float)110/255 blue:(float)110/255 alpha:1.0];
        label.tag=1111;
        label.numberOfLines=0;
        [Cell.bgview addSubview:label];
    }
    label.frame=CGRectMake(label.frame.origin.x, label.frame.origin.y, 111, size.height);
    label.text=myString;
    
    return Cell;
}

#pragma mark - UICollectionViewFlowLayoutDelegate
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //選則
    
    NSDictionary *data=pictures[indexPath.row];
    //[wTools ToRetrievealbumpViewControlleralbumid:[data[@"album_id"] stringValue]];
    [self ToRetrievealbumpViewControlleralbumid: [data[@"album_id"] stringValue]];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"viewForSupplementaryElementOfKind");
    
    CreativeCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"headerId"forIndexPath:indexPath];
    
    AsyncImageView *img = headerView.topimage;
    //img.image=[UIImage imageNamed:@"2-01aaphoto.png"];
    //img.image = [UIImage imageNamed: @"member_back_head.png"];
    
    AsyncImageView *subImg = headerView.subImage;
    //subImg.image = [UIImage imageNamed: @"member_back_head.png"];
    
    if (![profilepic isKindOfClass: [NSNull class]]) {
        NSLog(@"profilePic is not NSNull class");
        
        if (![profilepic isEqualToString:@""]) {
            [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: img];
            img.imageURL = [NSURL URLWithString:profilepic];
            
            [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: subImg];
            subImg.imageURL = [NSURL URLWithString:profilepic];
            subImg.alpha = 0.2;
            
            //[self updateColor: [img.image averageColor]];
            //self.navigationController.navigationBar.barTintColor = [img.image averageColor];
        } else {
            //[self updateColor: [img.image averageColor]];
            //self.navigationController.navigationBar.barTintColor = [img.image averageColor];
            
            [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: img];
            img.image = [UIImage imageNamed: @"member_back_head.png"];
            
            [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: subImg];
            subImg.image = [UIImage imageNamed: @"member_back_head.png"];
            subImg.alpha = 0.2;
        }
    } else {
        NSLog(@"profilePic is null");
        
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: img];
        img.image = [UIImage imageNamed: @"member_back_head.png"];
        
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: subImg];
        subImg.image = [UIImage imageNamed: @"member_back_head.png"];
        subImg.alpha = 0.2;
    }
    
    [[img layer] setMasksToBounds:YES];
    [[img layer] setCornerRadius:img.bounds.size.height/2];
    
    if ([countf isEqualToString:@""]) {
        countf=@"0";
    }
    if ([viewedNumber isEqualToString: @""]) {
        viewedNumber = @"0";
    }
    
    headerView.countfrom.text=countf;
    headerView.viewedLabel.text = viewedNumber;
    
    headerView.bio.text=bio;
    //headerView.bio.textColor=[UIColor whiteColor];
    headerView.bio.textColor = [UIColor blackColor];
    //headerView.lab_text.text=NSLocalizedString(@"ProfileText-about", @"");
    headerView.lab_text.text = name;
    
    headerView.followBtn = [self changeFollowBtn: headerView.followBtn];
    
    // Dynamically Change TextView Height
    CGFloat fixedWidth = headerView.bio.frame.size.width;
    CGFloat originalHeight = headerView.bio.frame.size.height;
    
    NSLog(@"originalHeight: %f", originalHeight);
    
    CGSize newSize = [headerView.bio sizeThatFits: CGSizeMake(fixedWidth, MAXFLOAT)];
    NSLog(@"newSize.height: %f", newSize.height);
    
    CGRect newFrame = headerView.bio.frame;
    newFrame.size = CGSizeMake(fmax(newSize.width, fixedWidth), newSize.height);
    NSLog(@"newFrame.height: %f", newFrame.size.height);
    
    headerView.bio.frame = newFrame;
    NSLog(@"headerView.bio.frame.size.height: %f", headerView.bio.frame.size.height);
    
    NSLog(@"kYAxisValue: %d", kYAxisValue);
    NSLog(@"newFrame.size.height: %f", newFrame.size.height);
    NSLog(@"kGap: %d", kGap);
    self.layout.headerHeight = kYAxisValue + newFrame.size.height + kGap;
    NSLog(@"self.layout.headerHeight: %f", self.layout.headerHeight);
    
    headerSize = CGSizeMake(fixedWidth, self.layout.headerHeight);
    
    headerView.bio.scrollEnabled = NO;
    
    // Reload HeaderView
    [self.collectioview.collectionViewLayout invalidateLayout];
    
    return headerView;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForHeaderInSection:(NSInteger)section
{
    NSLog(@"heightForHeaderInSection");
    return self.layout.headerHeight;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"sizeForItemAtIndexPath");
    
    int i=0;
    
    NSString *myString=pictures[indexPath.row][@"description"];
    
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:11]};
    CGSize size = [myString boundingRectWithSize:CGSizeMake(111, 66) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    i=size.height-13;
    // Values are fractional -- you should take the ceilf to get equivalent values
    
    return CGSizeMake(128, 205+17+i);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    NSLog(@"minimumInteritemSpacingForSectionAtIndex");
    
    return 1.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    NSLog(@"minimumLineSpacingForSectionAtIndex");
    
    return 2;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets itemInset = UIEdgeInsetsMake(0, 25, 50, 25);
    return itemInset;
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidScroll");
    
    if (isLoading) {
        NSLog(@"isLoading: %d", isLoading);
        return;
    }
    
    if ((scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height * 2)) {
        NSLog(@"scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height * 2");
        [self reloaddata];
    }
}

#pragma mark - 

- (void)ToRetrievealbumpViewControlleralbumid:(NSString *)albumid {
    
    NSLog(@"ToRetrievealbumpViewControlleralbumid");
    
    [wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *respone = [boxAPI retrievealbump: albumid uid: [wTools getUserID] token: [wTools getUserToken]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (respone != nil) {
                NSLog(@"check response");
                NSLog(@"respone: %@", respone);
                
                NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [respone dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                if ([dic[@"result"] intValue] == 1) {
                    NSLog(@"result bool value is YES");
                    NSLog(@"dic: %@", dic);
                    NSLog(@"dic data photo: %@", dic[@"data"][@"photo"]);
                    NSLog(@"dic data user name: %@", dic[@"data"][@"user"][@"name"]);
                    
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    BOOL fromHomeVC = YES;
                    [defaults setObject: [NSNumber numberWithBool: fromHomeVC]
                                 forKey: @"fromHomeVC"];
                    [defaults synchronize];
                    
                    RetrievealbumpViewController *rev = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"RetrievealbumpViewController"];
                    rev.data=[dic[@"data"] mutableCopy];
                    
                    NSLog(@"rev.data: %@", rev.data);
                    
                    rev.albumid=albumid;
                    //[app.myNav pushViewController:rev animated:YES];
                    [self.navigationController pushViewController: rev animated: YES];
                } else if ([dic[@"result"] intValue] == 0) {
                    NSLog(@"失敗：%@",dic[@"message"]);
                    Remind *rv=[[Remind alloc]initWithFrame: self.view.bounds];
                    [rv addtitletext:dic[@"message"]];
                    [rv addBackTouch];
                    [rv showView: self.view];
                } else {
                    Remind *rv=[[Remind alloc]initWithFrame: self.view.bounds];
                    [rv addtitletext:NSLocalizedString(@"Host-NotAvailable", @"")];
                    [rv addBackTouch];
                    [rv showView: self.view];
                }
            }
        });
    });
}

#pragma mark -

- (UIButton *)changeFollowBtn: (UIButton *)followBtn
{
    if (_follow) {
        [followBtn setTitle: @"取消關注" forState: UIControlStateNormal];
        [followBtn setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
        //followBtn.backgroundColor = [UIColor redColor];
        followBtn.backgroundColor = [UIColor colorWithRed: 233.0/255.0 green: 30.0/255.0 blue: 99.0/255.0 alpha: 1.0];
        
        followBtn.layer.cornerRadius = 2;
        followBtn.clipsToBounds = YES;
        followBtn.layer.masksToBounds = NO;
        followBtn.layer.shadowColor = [UIColor grayColor].CGColor;
        followBtn.layer.shadowOpacity = 1;
        followBtn.layer.shadowRadius = 2;
        followBtn.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    } else {
        [followBtn setTitle: @"關注" forState: UIControlStateNormal];
        [followBtn setTitleColor: [UIColor colorWithRed: 233.0/255.0 green: 30.0/255.0 blue: 99.0/255.0 alpha: 1.0] forState: UIControlStateNormal];
        followBtn.backgroundColor = [UIColor whiteColor];
        
        followBtn.layer.cornerRadius = 2;
        followBtn.clipsToBounds = YES;
        followBtn.layer.masksToBounds = NO;
        followBtn.layer.shadowColor = [UIColor grayColor].CGColor;
        followBtn.layer.shadowOpacity = 1;
        followBtn.layer.shadowRadius = 2;
        followBtn.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    }
    
    return followBtn;
}

- (void)updateColor: (UIColor *)newColor
{
    NSLog(@"updateColor");
    NSLog(@"newColor: %@", newColor);
    
    const CGFloat *componentColors = CGColorGetComponents(newColor.CGColor);
    
    CGFloat colorBrightness = ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000;
    
    if (colorBrightness < 0.5) {
        NSLog(@"my color is dark");
        //[_backBtn setImage: [UIImage imageNamed: @"icon_back_white_120x120"] forState: UIControlStateNormal];
        
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed: 255/255 green: 255/255 blue: 255/255 alpha: 1.0]};
    } else {
        NSLog(@"my color is light");
        //[_backBtn setImage: [UIImage imageNamed: @"icon_back_grey800_120x120"] forState: UIControlStateNormal];
        
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed: 66/255 green: 66/255 blue: 66/255 alpha: 1.0]};
    }
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
