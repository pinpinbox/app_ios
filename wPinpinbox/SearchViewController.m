//
//  SearchViewController.m
//  wPinpinbox
//
//  Created by Angus on 2015/10/23.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "SearchViewController.h"
#import "AppDelegate.h"
#import "QrcordViewController.h"
#import "wTools.h"
#import "SHViewPager.h"
#import "SearchTableViewController.h"
#import "boxAPI.h"
#import "wTools.h"

@interface SearchViewController ()
{
    IBOutlet SHViewPager *pager;
    NSArray *menuItems;
    NSArray *menuid;
    SearchTableViewController *mainvc;
    
    __weak IBOutlet UIButton *deleteBtn;
    __weak IBOutlet UITextField *searchText;
    
    BOOL isLoading;
    NSMutableArray *alldata;
    NSMutableArray *pictures;
    NSInteger  nextId;
    NSMutableArray *tmpAdduserid;
    
    // Record Index
    NSInteger indexForBack;
}
@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    pictures=[NSMutableArray new];
    tmpAdduserid=[NSMutableArray new];
    menuItems = [[NSArray alloc] initWithObjects: [NSString stringWithFormat:@" %@ ",NSLocalizedString(@"SearchText-PRO", @"")],[NSString stringWithFormat:@" %@ ",NSLocalizedString(@"SearchText-works", @"")], nil];
    menuid=@[@"user",@"album",@"album",@"album",@"album"];
    
    lab_left.text=NSLocalizedString(@"SearchText-keySearch", @"");
    lab_rig.text=NSLocalizedString(@"SearchText-scanSearch", @"");
    
    [searchText addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [pager reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // For going to the previous page
    [pager goBackToOldPage: indexForBack];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)deletebtn:(UIButton *)sender{
    searchText.text=@"";
    sender.hidden=YES;
}
- (IBAction)menu:(id)sender {
    [searchText resignFirstResponder];
    [wTools myMenu];
}
-(IBAction)QRcord:(id)sender{
    AppDelegate *app=[[UIApplication sharedApplication]delegate];

    for (UIViewController *temp in app.myNav.viewControllers) {
        if ([temp isKindOfClass:[QrcordViewController class]]) {
            [app.myNav popToViewController:temp animated:NO];
            return;
        }
    }
    QrcordViewController*mvc=[[QrcordViewController alloc]initWithNibName:@"QrcordViewController" bundle:nil];
    
    [app.myNav pushViewController:mvc animated:NO];
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
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
- (void)textFieldDidChange:(UITextField *)textField{
    NSLog(@"textFieldDidChange");
    NSLog(@"mainvc.searchtype: %@", mainvc.searchtype);
    
    NSString *string=textField.text;
   
    if ([string length]>0) {
        //  your actions for deleteBackward actions
        deleteBtn.hidden=YES;
    }else{
        deleteBtn.hidden=NO;
    }
        
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
                if (![searchText.text isEqualToString:string]) {
                    return;
                }
                //判斷目前table和 搜尋結果是否相同
                if (![data[@"searchtype"] isEqualToString:mainvc.searchtype]) {
                    return;
                }
                if ([dic[@"result"]boolValue]) {
                    alldata=[NSMutableArray arrayWithArray:dic[@"data"]];
                    nextId=alldata.count;
                    if (nextId  >= 0){
                        isLoading = NO;
                    }else{
                        isLoading = YES;
                    }
                    mainvc.textkey=textField.text;
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString *resultString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    return YES;
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
    NSLog(@"content will move to page %d from page: %d", toIndex, fromIndex);
}

- (void)viewPager:(SHViewPager *)viewPager didMoveToPageAtIndex:(NSInteger)toIndex fromIndex:(NSInteger)fromIndex
{
    
    mainvc=viewPager.wViewControllers[[NSString stringWithFormat:@"contentView-%i",toIndex]];
    NSLog(@"content moved to page %d from page: %d", toIndex, fromIndex);
    
    indexForBack = toIndex;
    NSLog(@"indexForBack: %d", indexForBack);
}

@end
