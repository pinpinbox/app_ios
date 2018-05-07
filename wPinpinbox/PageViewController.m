//
//  PageViewController.m
//  wPinpinbox
//
//  Created by David on 12/23/16.
//  Copyright © 2016 Angus. All rights reserved.
//

#import "PageViewController.h"
#import "CAPSPageMenu.h"
#import "SearchTableViewController.h"
#import "boxAPI.h"
#import "wTools.h"

@interface PageViewController () <CAPSPageMenuDelegate, UISearchResultsUpdating, UISearchBarDelegate>
{
    NSArray *menuid;
    SearchTableViewController *mainvc;
    
    BOOL isLoading;
    NSMutableArray *alldata;
    //NSMutableArray *pictures;
    NSInteger  nextId;
    NSMutableArray *tmpAdduserid;
}

@property (nonatomic) CAPSPageMenu *pageMenu;
@property (nonatomic, strong) UISearchController *searchController;
@end

@implementation PageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //pictures = [NSMutableArray new];
    tmpAdduserid = [NSMutableArray new];
    menuid = @[@"user",@"album",@"album",@"album",@"album"];
    
    //self.title = @"搜 尋 頁 面";
    // NavigationBar Set Up
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:18 weight:UIFontWeightLight], NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    //self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor orangeColor]};
    
    NSLog(@"currentPageIndex: %ld", (long)self.pageMenu.currentPageIndex);
    NSLog(@"menuid[self.pageMenu.currentPageIndex]: %@", menuid[self.pageMenu.currentPageIndex]);
    
    mainvc = [[SearchTableViewController alloc] initWithNibName: @"SearchTableViewController" bundle: nil];
    mainvc.searchtype = menuid[self.pageMenu.currentPageIndex];
    NSLog(@"mainvc.searchtype: %@", mainvc.searchtype);
    
    SearchTableViewController *sUser = [[SearchTableViewController alloc] initWithNibName: @"SearchTableViewController" bundle: nil];
    sUser.title = @"職人";
    
    SearchTableViewController *sBook = [[SearchTableViewController alloc] initWithNibName: @"SearchTableViewController" bundle: nil];
    sBook.title = @"作品";
    
    NSArray *controllerArray = @[sUser, sBook];
    NSDictionary *parameters = @{
                                 CAPSPageMenuOptionScrollMenuBackgroundColor: [UIColor colorWithRed:32.0/255.0 green:191.0/255.0 blue:193.0/255.0 alpha:1.0],
                                 CAPSPageMenuOptionViewBackgroundColor: [UIColor colorWithRed:20.0/255.0 green:20.0/255.0 blue:20.0/255.0 alpha:1.0],
                                 CAPSPageMenuOptionSelectionIndicatorColor: [UIColor whiteColor],
                                 CAPSPageMenuOptionBottomMenuHairlineColor: [UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0],
                                 CAPSPageMenuOptionMenuItemFont: [UIFont fontWithName:@"HelveticaNeue" size:13.0],
                                 CAPSPageMenuOptionMenuHeight: @(40.0),
                                 CAPSPageMenuOptionMenuItemWidth: @(90.0),
                                 CAPSPageMenuOptionCenterMenuItems: @(YES)
                                 };
    
    _pageMenu = [[CAPSPageMenu alloc] initWithViewControllers: controllerArray
                                                        frame: CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)
                                                      options: parameters];
    _pageMenu.delegate = self;
    
    [self.view addSubview: _pageMenu.view];
    
    [self configureSearchController];
    
    /*
    UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController: self];
    
    // Use the current view controller to update the search results.
    searchController.searchResultsUpdater = self;
    
    // Install the search bar as the table header.
    self.navigationItem.titleView = searchController.searchBar;
    
    // It is usually good to set the presentation context.
    self.definesPresentationContext = YES;
     */
}

- (void)configureSearchController {
    //UISearchController
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = YES;
    self.searchController.searchBar.placeholder = @"Search here...";
    self.searchController.searchBar.delegate = self;
    [self.searchController.searchBar sizeToFit];
    
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.definesPresentationContext = NO;
    
    self.navigationItem.titleView = self.searchController.searchBar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)filterContentForSearchText: (NSString *)text {
    NSLog(@"filterContentForSearchText");
    NSLog(@"text: %@", text);
    NSLog(@"mainvc.searchtype: %@", mainvc.searchtype);
    
    NSString *string = text;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        isLoading = YES;
        NSString *respone=@"";
        NSMutableDictionary *data=[NSMutableDictionary new];
        [data setObject:mainvc.searchtype forKey:@"searchtype"];
        [data setObject:string forKey:@"searchkey"];
        [data setObject:@"0,10" forKey:@"limit"];
        respone=[boxAPI search:[wTools getUserID] token:[wTools getUserToken] data:data];
        
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
                    
                    if (nextId >= 0){
                        isLoading = NO;
                    } else {
                        isLoading = YES;
                    }
                    mainvc.textkey = text;
                    NSLog(@"alldata: %@", alldata);
                    [mainvc alldata:alldata];
                    NSLog(@"isLoading: %d", isLoading);
                    [mainvc isLoading:isLoading];
                    NSLog(@"nextId: %ld", (long)nextId);
                    [mainvc nextId:nextId];
                    [mainvc.tableView reloadData];
                }else{
                    NSLog(@"失敗：%@",dic[@"message"]);
                }
                
            }
        });
        
    });
}

#pragma mark - SearchBar Delegate Methods
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    NSLog(@"searchBarTextDidBeginEditing");
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"searchBarCancelButtonClicked");
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"searchBarSearchButtonClicked");
    [self.searchController.searchBar resignFirstResponder];
}

#pragma mark - UISearchResultsUpdating Method

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSLog(@"updateSearchResultsForSearchController");
    NSLog(@"text: %@", searchController.searchBar.text);
    
    [self filterContentForSearchText: searchController.searchBar.text];
}

#pragma mark - CAPSPageMenuDelegate Methods

- (void)willMoveToPage:(UIViewController *)controller index:(NSInteger)index {
    NSLog(@"willMoveToPage");
    
    NSLog(@"mainvc.searchtype: %@", mainvc.searchtype);
}

- (void)didMoveToPage:(UIViewController *)controller index:(NSInteger)index {
    NSLog(@"didMoveToPage");
    
    mainvc.searchtype = menuid[self.pageMenu.currentPageIndex];
    
    NSLog(@"mainvc.searchtype: %@", mainvc.searchtype);    
}

@end
