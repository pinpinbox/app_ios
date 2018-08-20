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

#import "CustomIOSAlertView.h"
#import "UIColor+Extensions.h"

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
                
                if ([dic[@"result"] intValue] == 1) {
                    classlist=dic[@"data"];
                    //取得分類
                    [pager reloadData];
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
            
            if ([dic[@"result"] intValue] == 1) {
                [boxAPI updatealbumofdiy:[wTools getUserID] token:[wTools getUserToken] album_id:[dic[@"data"][@"album"][@"album_id"] stringValue]];
            } else if ([dic[@"result"] intValue] == 0) {
                NSLog(@"失敗：%@",dic[@"message"]);
                [self showCustomErrorAlert: dic[@"message"]];
            } else {
                [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
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
                if ([dic[@"result"] intValue] == 1) {
                    tempalbum_id=[dic[@"data"] stringValue];
                    
                    FastViewController *fVC = [[UIStoryboard storyboardWithName: @"Fast" bundle: nil] instantiateViewControllerWithIdentifier: @"FastViewController"];
                    fVC.selectrow = [wTools userbook];
                    fVC.albumid = tempalbum_id;
                    fVC.templateid = @"0";
                    fVC.choice = @"Fast";
                    
                    [self.navigationController pushViewController: fVC animated:YES];
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
