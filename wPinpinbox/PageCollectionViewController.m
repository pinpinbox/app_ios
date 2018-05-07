//
//  PageCollectionViewController.m
//  wPinpinbox
//
//  Created by David on 1/13/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "PageCollectionViewController.h"
#import "CAPSPageMenu.h"
#import "CalbumlistViewController.h"
#import "BookdetViewController.h"

#import "AppDelegate.h"
#import "wTools.h"
#import "boxAPI.h"

#import "Remind.h"
#import "CooperationViewController.h"

#import "FastViewController.h"

@interface PageCollectionViewController () <CAPSPageMenuDelegate, CalbumlistViewControllerDelegate>
@property (nonatomic) CAPSPageMenu *pageMenu;
@end

@implementation PageCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    BOOL fromPageCollection = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: [NSNumber numberWithBool: fromPageCollection]
                 forKey: @"fromPageCollection"];
    [defaults synchronize];
    
    NSLog(@"PageCollectionViewController");
    
    // Do any additional setup after loading the view.
    
    // NavigationBar Setup
    self.navigationController.navigationBarHidden = NO;
    NSLog(@"navigationBar: %@", NSStringFromCGRect(self.navigationController.navigationBar.frame));
    
    self.title = @"收 藏 專 區";
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:18 weight:UIFontWeightLight], NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed: 32/255.0 green: 191.0/255.0 blue: 193.0/255.0 alpha: 1.0];
    self.navigationController.navigationBar.translucent = NO;
    
    
    // ViewController Array Setup
    CalbumlistViewController *myVC = [[UIStoryboard storyboardWithName: @"Calbumlist" bundle: nil] instantiateViewControllerWithIdentifier: @"CalbumlistViewController"];
    myVC.title = @"我的收藏";
    myVC.collectionType = 0;
    myVC.delegate = self;
    
    CalbumlistViewController *otherVC = [[UIStoryboard storyboardWithName: @"Calbumlist" bundle: nil] instantiateViewControllerWithIdentifier: @"CalbumlistViewController"];
    otherVC.title = @"其他收藏";
    otherVC.collectionType = 1;
    otherVC.delegate = self;
    
    CalbumlistViewController *cooperationVC = [[UIStoryboard storyboardWithName: @"Calbumlist" bundle: nil] instantiateViewControllerWithIdentifier: @"CalbumlistViewController"];
    cooperationVC.title = @"共用收藏";
    cooperationVC.collectionType = 2;
    cooperationVC.delegate = self;
    
    
    NSArray *controllerArray = @[myVC, otherVC, cooperationVC];
    
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
    [self.navigationController popViewControllerAnimated: NO];
}

#pragma mark - CAPSPageMenuDelegate Methods
- (void)willMoveToPage:(UIViewController *)controller index:(NSInteger)index
{
    NSLog(@"willMoveToPage");
    NSLog(@"index: %ld", (long)index);
}

- (void)didMoveToPage:(UIViewController *)controller index:(NSInteger)index
{
    NSLog(@"didMoveToPage");
    NSLog(@"index: %ld", (long)index);
}

#pragma mark - CalbumlistViewControllerDelegate Method

- (void)editPhoto:(NSString *)albumId templateId:(NSString *)templateId shareCollection:(BOOL)shareCollection
{
    NSLog(@"editPhoto Delegate Method");
    NSLog(@"albumId: %@", albumId);
    NSLog(@"templateId: %@", templateId);
    
    /*
    //BookdetViewController *bdv = [[BookdetViewController alloc]initWithNibName:@"BookdetViewController" bundle:nil];
    BookdetViewController *bdv = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"BookdetViewController"];
    //bdv.data=[dic[@"data"] mutableCopy];
    bdv.album_id = albumId;
    bdv.templateid = templateId;
    bdv.postMode = nil;
    bdv.eventId = nil;
    */
    
    FastViewController *fvc = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"FastViewController"];
    fvc.selectrow = [wTools userbook];
    fvc.albumid = albumId;
    fvc.templateid = [NSString stringWithFormat:@"%@", templateId];
    fvc.shareCollection = shareCollection;
    
    if ([templateId isEqualToString:@"0"]) {
        fvc.booktype = 0;
        fvc.choice = @"Fast";
    } else {
        fvc.booktype = 1000;
        fvc.choice = @"Template";
    }
    
    // Data storing for FastViewController NavigationBar
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL fromPageCollection = YES;
    [defaults setObject: [NSNumber numberWithBool: fromPageCollection]
                 forKey: @"fromPageCollection"];
    [defaults synchronize];
    
    // Data Storing for FastViewController popToHomeViewController Directly
    BOOL fromHomeVC = NO;
    [defaults setObject: [NSNumber numberWithBool: fromHomeVC]
                 forKey: @"fromHomeVC"];
    [defaults synchronize];
    
    [self.navigationController pushViewController: fvc animated: YES];
    
    //AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //[app.myNav pushViewController: bdv animated: YES];
}

- (void)editCooperation:(NSString *)albumId identity:(NSString *)identity
{
    //CooperationViewController *copv=[[CooperationViewController alloc]initWithNibName:@"CooperationViewController" bundle:nil];
    NSLog(@"identity: %@", identity);
    
    CooperationViewController *copv = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"CooperationViewController"];
    copv.albumid = albumId;
    copv.identity = identity;
    [self.navigationController pushViewController:copv animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
