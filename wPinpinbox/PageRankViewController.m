//
//  PageRankViewController.m
//  wPinpinbox
//
//  Created by David on 12/29/16.
//  Copyright © 2016 Angus. All rights reserved.
//

#import "PageRankViewController.h"
#import "CAPSPageMenu.h"
#import "RetrievehotrankViewController.h"

@interface PageRankViewController () <CAPSPageMenuDelegate>
@property (nonatomic) CAPSPageMenu *pageMenu;
@end

@implementation PageRankViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // NavigationBar Set Up
    self.title = @"排 行 榜";
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:18 weight:UIFontWeightLight], NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    /*
    RetrievehotrankViewController *prVCHot = [[RetrievehotrankViewController alloc] initWithNibName: @"RetrievehotrankViewController" bundle: nil];
    prVCHot.title = @"熱門收藏";
    
    RetrievehotrankViewController *prVCFree = [[RetrievehotrankViewController alloc] initWithNibName: @"RetrievehotrankViewController" bundle: nil];
    prVCFree.title = @"免費收藏";
    
    RetrievehotrankViewController *prVCSponsor = [[RetrievehotrankViewController alloc] initWithNibName: @"RetrievehotrankViewController" bundle: nil];
    prVCSponsor.title = @"贊助收藏";
    */
    
    RetrievehotrankViewController *prVCHot = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"RetrievehotrankViewController"];
    prVCHot.title = @"熱門收藏";
    prVCHot.ranktype = @"0";
    
    RetrievehotrankViewController *prVCFree = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"RetrievehotrankViewController"];
    prVCFree.title = @"免費收藏";
    prVCFree.ranktype = @"1";
    
    RetrievehotrankViewController *prVCSponsor = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"RetrievehotrankViewController"];
    prVCSponsor.title = @"贊助收藏";
    prVCSponsor.ranktype = @"2";
     
    NSArray *controllerArray = @[prVCHot, prVCFree, prVCSponsor];
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)back:(id)sender {
    NSLog(@"back putton pressed");
    [self.navigationController popViewControllerAnimated: YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - CAPSPageMenuDelegate Methods

- (void)willMoveToPage:(UIViewController *)controller index:(NSInteger)index {
    NSLog(@"willMoveToPage");
}

- (void)didMoveToPage:(UIViewController *)controller index:(NSInteger)index {
    NSLog(@"didMoveToPage");    
}

@end
