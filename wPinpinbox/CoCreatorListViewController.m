//
//  CoCreatorListViewController.m
//  wPinpinbox
//
//  Created by Antelis on 2018/9/18.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "CoCreatorListViewController.h"
#import "AppDelegate.h"
#import "UIColor+Extensions.m"

@implementation CoCreatorCell
- (IBAction)inviteCreator:(id)sender {
    
}
@end

@implementation CoAdminCell
- (IBAction)editAdmin:(id)sender {
    
}
- (IBAction)manageAdmin:(id)sender {
    
}
@end


@interface CoCreatorListViewController ()
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *searchViewWidth;
@end

@implementation CoCreatorListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}
- (BOOL)prefersStatusBarHidden {
    return NO;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];    
    [self.navigationController.navigationBar setShadowImage: [UIImage imageNamed:@"navigationbarshadow"]];
}
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    
    //UIBarButtonItem *litem = [[UIBarButtonItem alloc]initWithCustomView:self.backButton];
    //self.searchView.translatesAutoresizingMaskIntoConstraints = NO;
    UIBarButtonItem *l = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic200_arrow_left_darknav"] style:UIBarButtonItemStylePlain target:self action:@selector(onBackButton:)];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:self.searchView];
    UIBarButtonItem *r1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic200_scancamera_darknav"] style:UIBarButtonItemStylePlain target:self action:@selector(onBackButton:)];
    r1.title = @"";
    l.title = @"";
    l.tintColor = [UIColor firstGrey];
    l.width = 44;
    r1.tintColor = [UIColor firstGrey];
    r1.width = 44;
    CGFloat w = self.view.bounds.size.width - 110;
    _searchViewWidth.constant = w;
    //item.width = w;
    
    //ic200_scancamera_dark
    //ic200_arrow_left_darknav
    [self.navigationItem setLeftBarButtonItems:@[l]];
    [self.navigationItem setRightBarButtonItems:@[r1,item]];
    
    //self.edgesForExtendedLayout = UIRectEdgeBottom;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _creatorListView) {
        UICollectionReusableView *v = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"creatorHeader" forIndexPath:indexPath];
        
        return v;
    }
    
    return nil;
}
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    if (collectionView == self.creatorListView) {
        CoCreatorCell *ccell = (CoCreatorCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CoCreatorCell" forIndexPath:indexPath];
        ccell.avatar.image = [UIImage imageNamed:@"36"];
        ccell.userName.text = @"名字";
        return ccell;
        
    } else if (collectionView == self.adminListView) {
        CoAdminCell *ccell = (CoAdminCell *) [collectionView dequeueReusableCellWithReuseIdentifier:@"CoAdminCell" forIndexPath:indexPath];
        ccell.avatar.image = [UIImage imageNamed:@"36"];
        ccell.userName.text = @"123456";
        return ccell;
    }
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == _creatorListView)
        return 0;
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}
- (IBAction)onBackButton:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.myNav popViewControllerAnimated: YES];
    appDelegate.myNav.navigationBarHidden = YES;
}
@end
