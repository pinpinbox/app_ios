//
//  FollowListCollectionViewController.m
//  wPinpinbox
//
//  Created by David on 1/20/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "FollowListCollectionViewController.h"
#import "boxAPI.h"
#import "wTools.h"
#import "AsyncImageView.h"
#import "CreativeViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface FollowListCollectionViewController () <UICollectionViewDelegateFlowLayout>
{
    NSMutableArray *followListData;
    
    BOOL isLoading;
    BOOL isReload;
    NSInteger nextId;
}
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation FollowListCollectionViewController

//static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    //[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    // NavigationBar Text Setup
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:18 weight:UIFontWeightLight], NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    // Loading Data Parameters Setup
    nextId = 0;
    isLoading = NO;
    isReload = NO;
    
    followListData = [NSMutableArray new];
    
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget: self action: @selector(refresh) forControlEvents: UIControlEventValueChanged];
    
    [self.collectionView addSubview: self.refreshControl];
    
    self.collectionView.alwaysBounceVertical = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [wTools HideMBProgressHUD];
    //[self loadData];
    [self refresh];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [wTools HideMBProgressHUD];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)followBtnPress:(id)sender
{
    UICollectionViewCell *cell = (UICollectionViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.collectionView indexPathForCell: cell];
    
    if (indexPath == nil) {
        assert(false);
        return;
    }
    
    NSDictionary *dic = [followListData[indexPath.row] mutableCopy];
    NSString *userId = dic[@"user"][@"user_id"];
    NSString *name = dic[@"user"][@"name"];
    
    NSString *titleStr = [NSString stringWithFormat: @"不再關注 %@?", name];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: titleStr message: @"" preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleDefault handler: nil];
    UIAlertAction *okBtn = [UIAlertAction actionWithTitle: @"確定" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self changeFollowStatus: userId name: name];
    }];
    [alert addAction: cancelBtn];
    [alert addAction: okBtn];
    
    [self presentViewController: alert animated: YES completion: nil];
}

- (void)changeFollowStatus: (NSString *)userId name:(NSString *)name
{
    NSLog(@"changeFollowStatus");
    
    [wTools ShowMBProgressHUD];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI changefollowstatus: [wTools getUserID] token: [wTools getUserToken] authorid: userId];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"response from changefollowstatus");
                NSLog(@"response");
                NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                if ([dic[@"result"] boolValue]) {
                    NSDictionary *d = dic[@"data"];
                    
                    NSLog(@"d: %@", d);
                    
                    [self refresh];
                }
            }
        });
    });
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated: YES];
}

- (void)refresh {
    if (!isReload) {
        isReload = YES;
        
        nextId = 0;
        isLoading = NO;
        
        [self loadData];
    }
}

- (void)loadData {
    NSLog(@"loadData");
    
    if (!isLoading) {
        if (nextId == 0) {
            NSLog(@"nextId is: %ld", (long)nextId);
        }
        
        [wTools ShowMBProgressHUD];
        
        isLoading = YES;
        
        NSString *limit = [NSString stringWithFormat: @"%ld,%ld", (long)nextId, 10];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            NSString *response = @"";
            
            response = [boxAPI getFollowToList: [wTools getUserID] token: [wTools getUserToken] limit: limit];
            dispatch_async(dispatch_get_main_queue(), ^{
                [wTools HideMBProgressHUD];
                
                if (response != nil) {
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    NSLog(@"dic: %@", dic);
                    
                    if ([dic[@"result"] boolValue]) {
                        
                        if (nextId == 0)
                            [followListData removeAllObjects];
                        
                        // s for counting how much data is loaded
                        int s = 0;
                        
                        for (NSMutableDictionary *followData in [dic objectForKey: @"data"]) {
                            s++;
                            [followListData addObject: followData];
                        }
                        
                        NSLog(@"followListData: %@", followListData);
                        
                        // If data keeps loading then the nextId is accumulating
                        nextId = nextId + s;
                        NSLog(@"nextId is: %ld", (long)nextId);
                        
                        // If nextId is bigger than 0, that means there are some data loaded already.
                        if (nextId >= 0)
                            isLoading = NO;
                        
                        // If s is 0, that means dic data is empty.
                        if (s == 0) {
                            isLoading = YES;
                        }
                        
                        [self.refreshControl endRefreshing];
                        [self.collectionView reloadData];
                        
                        isReload = NO;
                    } else {
                        [self.refreshControl endRefreshing];
                        NSLog(@"失敗: %@", dic[@"message"]);
                    }
                } else {
                    [self.refreshControl endRefreshing];
                }
            });
        });
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

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"followListData.count: %lu", (unsigned long)followListData.count);
    return followListData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    NSLog(@"cellForItemAtIndexPath");
    
    static NSString *identifier = @"Cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: identifier forIndexPath:indexPath];
    
    // Configure the cell
    //AsyncImageView *followImageView = (AsyncImageView *)[cell viewWithTag: 100];
    UIImageView *followImageView = (UIImageView *)[cell viewWithTag: 100];
    NSDictionary *dic = [followListData[indexPath.row] mutableCopy];
    NSString *name = dic[@"user"][@"name"];
    NSLog(@"name: %@", name);
    
    NSString *imageUrl = dic[@"user"][@"picture"];
    NSLog(@"imageUrl: %@", imageUrl);
    
    if (![imageUrl isKindOfClass: [NSNull class]]) {
        if (![imageUrl isEqualToString: @""]) {
            //[[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: followImageView];
            //followImageView.imageURL = [NSURL URLWithString: imageUrl];
            [followImageView sd_setImageWithURL: [NSURL URLWithString: imageUrl]];
        }
    } else {
        NSLog(@"imageURL is nil");
        //[[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: followImageView];
        followImageView.image = [UIImage imageNamed: @"member_back_head.png"];
    }
    
    [[followImageView layer] setMasksToBounds: YES];
    [[followImageView layer] setCornerRadius: followImageView.bounds.size.height / 2];
    
    /*
    UIImageView *iconImageView = (UIImageView *)[cell viewWithTag: 101];
    iconImageView.image = [UIImage imageNamed: @"icon_attention_withbackground_pink500_72x72"];
    [[iconImageView layer] setMasksToBounds: YES];
    [[iconImageView layer] setCornerRadius: iconImageView.bounds.size.height / 2];
     */
    
    UIImage *btnImage = [UIImage imageNamed: @"icon_attention_withbackground_pink500_72x72"];
    
    UIButton *followSwitchButton = (UIButton *)[cell viewWithTag: 101];
    
    [followSwitchButton setImage: btnImage forState: UIControlStateNormal];
    [[followSwitchButton layer] setMasksToBounds: YES];
    [[followSwitchButton layer] setCornerRadius: followSwitchButton.bounds.size.height / 2];
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag: 102];
    nameLabel.text = name;
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/


// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dic = [followListData[indexPath.row] mutableCopy];
    NSString *userId = dic[@"user"][@"user_id"];
    
    CreativeViewController *cVC = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"CreativeViewController"];
    cVC.userid = userId;
    [self.navigationController pushViewController: cVC animated: NO];
    
    return YES;
}


/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
 
}
*/

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    NSLog(@"screenWidth: %f", screenWidth);
    
    float cellWidth = screenWidth / 2.0;
    CGSize size = CGSizeMake(cellWidth, cellWidth);
    
    return size;
}

@end
