//
//  SetupViewController.m
//  wPinpinbox
//
//  Created by Angus on 2015/10/29.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "SetupViewController.h"
#import "wTools.h"
#import "PhotosViewController.h"
#import "FastViewController.h"
#import "SHViewPager.h"
#import "SetupTableViewController.h"
#import "boxAPI.h"
#import "Remind.h"

#import "TaobanViewController.h"

@interface SetupViewController ()<SHViewPagerDataSource,SHViewPagerDelegate, SetupTableViewControllerDelegate>
{
    IBOutlet SHViewPager *pager;
    NSArray *menuItems;
    NSArray *menuid;
    
    NSInteger type;
    
    NSInteger selectview;
    
    NSMutableDictionary *pagerdata;
    
    NSArray *classlist;
    
    NSString *tempalbum_id;
}
@end

@implementation SetupViewController
- (IBAction)listbtn:(UIButton *)sender {
    NSLog(@"listBtn pressed");
    
    if (type==0) {
        sender.selected = YES;
        type=1;
        
    } else {
        sender.selected = NO;
        type=0;
        
    }
    
    //NSString *key=[NSString stringWithFormat:@"contentView-%i",selectview];
    
    for (SetupTableViewController *vc in pager.wViewControllers.allValues) {
        vc.type=type;
        [vc.tableView reloadData];
    }
    
    NSLog(@"type: %ld", (long)type);
}

- (IBAction)backBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    SetupTableViewController *setupTVC = [[SetupTableViewController alloc] initWithNibName: @"SetupTableViewController" bundle: nil];
    setupTVC.delegate = self;
    
    NSLog(@"SetupViewController");        
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:18 weight:UIFontWeightLight], NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    wtitle.text=NSLocalizedString(@"CreateAlbumText-create", @"");
    [btn_rig setTitle:NSLocalizedString(@"CreateAlbumText-quickBuild", @"") forState:UIControlStateNormal];
    [btn_left setTitle:NSLocalizedString(@"CreateAlbumText-applyTemplate", @"") forState:UIControlStateNormal];
    
    menuItems = [[NSArray alloc] initWithObjects:NSLocalizedString(@"CreateAlbumText-hot", @""), NSLocalizedString(@"CreateAlbumText-free", @""), NSLocalizedString(@"CreateAlbumText-sponsor", @""), NSLocalizedString(@"CreateAlbumText-own", @""), nil];
    menuid=@[@"hot",@"free",@"sponsored",@"own"];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *respone=[boxAPI gettemplatestylelist:[wTools getUserID] token:[wTools getUserToken]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [wTools HideMBProgressHUD];
            
            if (respone!=nil) {
                NSLog(@"%@",respone);
                NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                if ([dic[@"result"]boolValue]) {
                    classlist=dic[@"data"];                                       
                    
                    //取得分類
                    [pager reloadData];

                }else{
                    NSLog(@"失敗：%@",dic[@"message"]);
                }
                
            }
        });
        
    });
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // Set up for back to the previous one for disable swipe gesture
    // Because the home view controller can not swipe back to Main Screen
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
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
        [pager pagerWillLayoutSubviews];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)FastBtn:(id)sender {
    
    //判斷是否有編輯中相本
    
    [wTools ShowMBProgressHUD];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *respone=[boxAPI checkalbumofdiy:[wTools getUserID] token:[wTools getUserToken]];
        [wTools HideMBProgressHUD];
        
        if (respone!=nil) {
            NSLog(@"%@",respone);
            NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            
            if ([dic[@"result"]boolValue]) {
                [boxAPI updatealbumofdiy:[wTools getUserID] token:[wTools getUserToken] album_id:[dic[@"data"][@"album"][@"album_id"] stringValue]];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            [self addNewFastMod];
        });
        
    });
}


//快速套版
-(void)addNewFastMod{
    
    NSLog(@"addNewFastMod");
    
    //新增相本id
    [wTools ShowMBProgressHUD];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *respone=[boxAPI insertalbumofdiy:[wTools getUserID] token:[wTools getUserToken] template_id:@"0"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [wTools HideMBProgressHUD];
            
            if (respone!=nil) {
                NSLog(@"%@",respone);
                NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                if ([dic[@"result"]boolValue]) {
                    
                    tempalbum_id=[dic[@"data"] stringValue];
                    
                    FastViewController *fVC = [[UIStoryboard storyboardWithName: @"Fast" bundle: nil] instantiateViewControllerWithIdentifier: @"FastViewController"];
                    fVC.selectrow = [wTools userbook];
                    fVC.albumid = tempalbum_id;
                    fVC.templateid = @"0";
                    fVC.choice = @"Fast";
                    
                    [self.navigationController pushViewController: fVC animated:YES];
                    
                }else{
                    
                }
            }
        });
    });
}


- (IBAction)menu:(id)sender {
    [wTools myMenu];
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
    
    SetupTableViewController *contentVC = [[SetupTableViewController alloc] initWithNibName:@"SetupTableViewController" bundle:nil];
    contentVC.type=type;
    contentVC.classlist=classlist;
    contentVC.rank=menuid[index];
    
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
    return SHViewPagerMenuWidthTypeDefault;
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
    NSLog(@"content moved to page %ld from page: %ld", (long)toIndex, (long)fromIndex);
    
}

- (void)passTemplateIdForPushing:(NSString *)templateId
{
    NSLog(@"passTemplateIdForPushing");
    TaobanViewController *tv = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"TaobanViewController"];
    tv.temolateid = templateId;
    
    tv.navigationItem.title = @"版 型 介 紹";
    tv.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:18 weight:UIFontWeightLight], NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    [self.navigationController pushViewController: tv animated: YES];
}

@end
