//
//  NewSearchViewController.m
//  wPinpinbox
//
//  Created by David on 12/28/16.
//  Copyright © 2016 Angus. All rights reserved.
//

#import "NewSearchViewController.h"
#import "QrcordViewController.h"
#import "wTools.h"
#import "SHViewPager.h"
#import "SearchTableViewController.h"
#import "boxAPI.h"
#import "wTools.h"

#import "AppDelegate.h"
#import "PageRankViewController.h"

@interface NewSearchViewController () <UISearchBarDelegate>
{
    NSArray *menuItems;
    NSArray *menuid;
    SearchTableViewController *mainvc;
    
    BOOL isLoading;
    NSMutableArray *alldata;
    NSMutableArray *pictures;
    NSInteger  nextId;
    NSMutableArray *tmpAdduserid;
    
    // Record Index
    NSInteger indexForBack;
}

@property (nonatomic, strong) UISearchController *searchController;
@property (strong, nonatomic) IBOutlet SHViewPager *pager;

@end

@implementation NewSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"viewDidLoad");
    
    [self navigationBarSetup];
    [self configureSearchController];
    
    // Pager Setup
    pictures=[NSMutableArray new];
    tmpAdduserid=[NSMutableArray new];
    menuItems = [[NSArray alloc] initWithObjects: [NSString stringWithFormat:@" %@ ",NSLocalizedString(@"SearchText-PRO", @"")],[NSString stringWithFormat:@" %@ ",NSLocalizedString(@"SearchText-works", @"")], nil];
    menuid=@[@"user",@"album",@"album",@"album",@"album"];
    
    NSLog(@"pager reloadData");
    [self.pager reloadData];
}

- (void)navigationBarSetup {
    // NavigationBar Setup
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:18 weight:UIFontWeightLight], NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    // BarButtonItem Setup
    UIButton *btnC = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 22, 22)];
    [btnC setBackgroundImage: [UIImage imageNamed: @"icon_searchcode_white.png"] forState: UIControlStateNormal];
    [btnC addTarget: self action: @selector(clickCode) forControlEvents: UIControlEventTouchUpInside];
    
    UIButton *btnR = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 22, 22)];
    [btnR setBackgroundImage: [UIImage imageNamed: @"icon_rank.png"] forState: UIControlStateNormal];
    [btnR addTarget: self action: @selector(clickRank) forControlEvents: UIControlEventTouchUpInside];
    
    UIBarButtonItem *btnCode = [[UIBarButtonItem alloc] initWithCustomView: btnC];
    //btnCode.tintColor = [UIColor whiteColor];
    UIBarButtonItem *btnRank = [[UIBarButtonItem alloc] initWithCustomView: btnR];
    
    [self.navigationItem setRightBarButtonItems: [NSArray arrayWithObjects: btnCode, btnRank, nil]];
}

- (void)configureSearchController {
    NSLog(@"configureSearchController");
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    //self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = YES;
    self.searchController.searchBar.placeholder = @"搜 尋";
    self.searchController.searchBar.delegate = self;
    [self.searchController.searchBar sizeToFit];
    
    // Prevent navigationBar to go up when clicking searchBar
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.definesPresentationContext = NO;
    
    self.navigationItem.titleView = self.searchController.searchBar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // For going to the previous page
    [self.pager goBackToOldPage: indexForBack];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed: 32.0/255.0 green: 191.0/255.0 blue: 193.0/255.0 alpha: 1.0];
}

- (void)clickCode {
    NSLog(@"clickCode");
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    for (UIViewController *temp in app.myNav.viewControllers) {
        if ([temp isKindOfClass:[QrcordViewController class]]) {
            [app.myNav popToViewController:temp animated:NO];
            return;
        }
    }
    
    [self performSegueWithIdentifier: @"showQrcordViewController" sender: self];
}

- (void)clickRank {
    [self performSegueWithIdentifier: @"showPageRankViewController" sender: self];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // fixes bug for scrollview's content offset reset.
    // check SHViewPager's reloadData method to get the idea.
    // this is a hacky solution, any better solution is welcome.
    // check closed issues #1 & #2 for more details.
    // this is the example to fix the bug, to test this
    // comment out the following lines
    // and check what happens.
    
    if (menuItems.count)
    {
        [self.pager pagerWillLayoutSubviews];
    }
}

- (void)showRecommendedList {
    NSLog(@"showRecommendedList");
    NSLog(@"mainVC.searchType: %@", mainvc.searchtype);
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        isLoading = YES;
        NSString *response = @"";
        NSMutableDictionary *data = [NSMutableDictionary new];
        [data setObject: mainvc.searchtype forKey: @"type"];
        [data setObject: @"0,10" forKey: @"limit"];
        
        response = [boxAPI getRecommendedList: [wTools getUserID] token: [wTools getUserToken] data: data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (response != nil) {
                
                NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                if (![dic[@"result"] boolValue]) {
                    return ;
                }
                /*
                //判斷回傳是否一樣
                if (![text isEqualToString:string]) {
                    return;
                }
                 */
                //判斷目前table和 搜尋結果是否相同
                if (![data[@"type"] isEqualToString:mainvc.searchtype]) {
                    return;
                }
                
                if ([dic[@"result"] boolValue]) {
                    alldata = [NSMutableArray arrayWithArray:dic[@"data"]];
                    nextId = alldata.count;
                    
                    if (nextId >= 0) {
                        isLoading = NO;
                    } else {
                        isLoading = YES;
                    }
                    
                    mainvc.textkey = @"";
                    //NSLog(@"alldata: %@", alldata);
                    [mainvc alldata:alldata];
                    NSLog(@"isLoading: %d", isLoading);
                    [mainvc isLoading:isLoading];
                    NSLog(@"nextId: %ld", (long)nextId);
                    [mainvc nextId:nextId];
                    [mainvc.tableView reloadData];
                } else {
                    NSLog(@"失敗：%@",dic[@"message"]);
                }
            }
        });
    });
}

- (void)filterContentForSearchText: (NSString *)text {
    NSLog(@"filterContentForSearchText");
    NSLog(@"text: %@", text);
    NSLog(@"mainvc.searchtype: %@", mainvc.searchtype);
    
    NSString *string = text;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        isLoading = YES;
        NSString *respone = @"";
        NSMutableDictionary *data = [NSMutableDictionary new];
        [data setObject: mainvc.searchtype forKey: @"searchtype"];
        [data setObject: string forKey: @"searchkey"];
        [data setObject: @"0,40" forKey: @"limit"];
        respone = [boxAPI search:[wTools getUserID] token:[wTools getUserToken] data:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (respone!=nil) {
                
                NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                if (![dic[@"result"] boolValue]) {
                    return ;
                }
                //判斷回傳是否一樣
                if (![text isEqualToString:string]) {
                    return;
                }
                //判斷目前table和 搜尋結果是否相同
                if (![data[@"searchtype"] isEqualToString:mainvc.searchtype]) {
                    return;
                }
                if ([dic[@"result"]boolValue]) {
                    alldata = [NSMutableArray arrayWithArray:dic[@"data"]];
                    nextId = alldata.count;
                    
                    if (nextId >= 0) {
                        isLoading = NO;
                    } else {
                        isLoading = YES;
                    }
                    
                    mainvc.textkey = text;
                    //NSLog(@"alldata: %@", alldata);
                    [mainvc alldata:alldata];
                    NSLog(@"isLoading: %d", isLoading);
                    [mainvc isLoading:isLoading];
                    NSLog(@"nextId: %ld", (long)nextId);
                    [mainvc nextId:nextId];
                    [mainvc.tableView reloadData];
                } else {
                    NSLog(@"失敗：%@",dic[@"message"]);
                }
            }
        });
    });
}

#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString: @"showQrcordViewController"]) {
        QrcordViewController *qVC = segue.destinationViewController;
    }
}
*/

- (void)performSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    if ([identifier isEqualToString: @"showQrcordViewController"]) {
        QrcordViewController *qVC = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"QrcordViewController"];
        [self.navigationController pushViewController: qVC animated: YES];
    }
    
    if ([identifier isEqualToString: @"showPageRankViewController"]) {
        PageRankViewController *pVC = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"PageRankViewController"];
        [self.navigationController pushViewController: pVC animated: YES];
    }
}


#pragma mark - SHViewPagerDataSource stack

- (NSInteger)numberOfPagesInViewPager:(SHViewPager *)viewPager
{
    return menuItems.count;
}

- (UIViewController *)containerControllerForViewPager:(SHViewPager *)viewPager
{
    return self;
}

- (UIViewController *)viewPager:(SHViewPager *)viewPager controllerForPageAtIndex:(NSInteger)index
{
    NSLog(@"controllerForPageAtIndex: %ld", (long)index);
    
    SearchTableViewController *contentVC = [[SearchTableViewController alloc] initWithNibName:@"SearchTableViewController" bundle:nil];
    contentVC.searchtype=menuid[index];
    
    NSLog(@"mainvc.searchtype: %@", mainvc.searchtype);
    
    return contentVC;
}

- (UIImage *)indexIndicatorImageForViewPager:(SHViewPager *)viewPager
{
    return [UIImage imageNamed:@""];
}

- (UIImage *)indexIndicatorImageDuringScrollAnimationForViewPager:(SHViewPager *)viewPager
{
    return [UIImage imageNamed:@""];
}

- (NSString *)viewPager:(SHViewPager *)viewPager titleForPageMenuAtIndex:(NSInteger)index
{
    return [menuItems objectAtIndex:index];
}

- (SHViewPagerMenuWidthType)menuWidthTypeInViewPager:(SHViewPager *)viewPager
{
    return SHViewPagerMenuWidthTypeWide;
}

#pragma mark - SHViewPagerDelegate stack

- (void)firstContentPageLoadedForViewPager:(SHViewPager *)viewPager
{
    NSLog(@"first viewcontroller content loaded");
}

- (void)viewPager:(SHViewPager *)viewPager willMoveToPageAtIndex:(NSInteger)toIndex fromIndex:(NSInteger)fromIndex
{
    NSLog(@"content will move to page %ld from page: %ld", (long)toIndex, (long)fromIndex);
}

- (void)viewPager:(SHViewPager *)viewPager didMoveToPageAtIndex:(NSInteger)toIndex fromIndex:(NSInteger)fromIndex
{
    NSLog(@"didMoveToPageAtIndex");
    
    mainvc = viewPager.wViewControllers[[NSString stringWithFormat:@"contentView-%li",(long)toIndex]];
    NSLog(@"content moved to page %ld from page: %ld", (long)toIndex, (long)fromIndex);
    
    indexForBack = toIndex;
    NSLog(@"indexForBack: %ld", (long)indexForBack);
    
    if ([self.searchController.searchBar.text isEqualToString: @""]) {
        [self showRecommendedList];
    }
}

#pragma mark - SearchBar Delegate Methods
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    NSLog(@"searchBarTextDidBeginEditing");
    
    [self callProtocol: searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"searchBarCancelButtonClicked");
    
    [self callProtocol: searchBar.text];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"searchBarSearchButtonClicked");
    //[self.searchController.searchBar resignFirstResponder];
    
    NSString *str = searchBar.text;
    [self.searchController setActive: NO];
    self.searchController.searchBar.text = str;
    
    [self callProtocol: searchBar.text];
}

- (void)callProtocol: (NSString *)text {
    if ([text isEqualToString: @""]) {
        [self showRecommendedList];
    } else {
        [self filterContentForSearchText: text];
    }
}

#pragma mark - UISearchResultsUpdating Method
/*
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSLog(@"updateSearchResultsForSearchController");
    NSLog(@"from input text: %@", searchController.searchBar.text);
    NSLog(@"from self.searchController.searchBar.text: %@", self.searchController.searchBar.text);
    
    if (searchController.isActive && ![self.searchController.searchBar.text isEqualToString: @""]) {
        NSLog(@"call filterContentForSearchText");
        [self filterContentForSearchText: searchController.searchBar.text];
    } else {
        NSLog(@"call showRecommendedList");
        [self showRecommendedList];
    }
}
*/
@end
