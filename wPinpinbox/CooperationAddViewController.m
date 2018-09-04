//
//  CooperationAddViewController.m
//  wPinpinbox
//
//  Created by Angus on 2016/1/12.
//  Copyright (c) 2016年 Angus. All rights reserved.
//

#import "CooperationAddViewController.h"
#import "CooperationAddTableViewCell.h"
#import "AsyncImageView.h"
#import "wTools.h"
#import "boxAPI.h"
#import "CustomIOSAlertView.h"
#import "UIColor+Extensions.h"

@interface CooperationAddViewController () <UITextFieldDelegate, UISearchBarDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate> {
    __weak IBOutlet UIButton *deleteBtn;
    __weak IBOutlet UITextField *searchText;
    __weak IBOutlet UITableView *mytable;
    
    BOOL isLoading;
    NSMutableArray *alldata;
    NSMutableArray *pictures;
    NSInteger  nextId;
    NSMutableArray *tmpAdduserid;
}

@property (nonatomic, strong) UISearchController *searchController;
@end

@implementation CooperationAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    [self configureSearchController];
    
    pictures=[NSMutableArray new];
    tmpAdduserid=[NSMutableArray new];
    
    [wTools ShowMBProgressHUD];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSMutableDictionary *data=[NSMutableDictionary new];
        [data setObject:_albumid forKey:@"type_id"];
        [data setObject:@"album" forKey:@"type"];
        
        NSString *respone=[boxAPI getcooperationlist:[wTools getUserID] token:[wTools getUserToken] data:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [wTools HideMBProgressHUD];
            
            if (respone!=nil) {
                NSLog(@"response from getcooperationlist");
                NSLog(@"%@",respone);
                NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                if ([dic[@"result"] intValue] == 1) {
                    for (NSDictionary *udic in dic[@"data"]) {
                        [tmpAdduserid addObject:[udic[@"user"][@"user_id"] stringValue]];
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

    // Do any additional setup after loading the view from its nib.
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SearchController Configuration
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

#pragma mark -

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"numberOfSectionsInTableView");
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"numberOfRowsInSection");
    
    // Return the number of rows in the section.
    
    if (pictures ==nil ) {
        pictures=[NSMutableArray new];
    }
    [pictures removeAllObjects];
    
    for (NSDictionary *dic in alldata) {
        //NSString *userid=[dic[@"user"][@"user_id"] stringValue];
        //if (![tmpAdduserid containsObject:userid]) {
            [pictures addObject:dic];
        //}
    }
    
    return pictures.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    return 95;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForRowAtIndexPath");
    
    // NSString *identifier = [NSString stringWithFormat:@"HomeTableViewCell_%@", [[[pictures objectAtIndex:indexPath.row] objectForKey:@"album"]objectForKey:@"album_id" ]];
    NSString *CellIdentifier=@"CooperationAddTableViewCell";
    
    CooperationAddTableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"CooperationAddTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
        cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    //cell.picture.image=[UIImage imageNamed:@"user_photo.png"];
    cell.picture.image = [UIImage imageNamed: @"member_back_head.png"];
    
    NSDictionary *data=pictures[indexPath.row];
    
    // NSLog(@"%@",data);
    AsyncImageView *imav=(AsyncImageView*)cell.picture;
    imav.imageURL=nil;
    //imav.image=[UIImage imageNamed:@"1-02a1track_photo.png"];
    imav.image = [UIImage imageNamed: @"member_back_head.png"];
    NSDictionary *count=data[@"user"][@"picture"];
    
    if (![count isKindOfClass:[NSNull class]]) {
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: imav];
        imav.imageURL=[NSURL URLWithString:data[@"user"][@"picture"]];
    }
    
    cell.name.text=data[@"user"][@"name"];
    
    if ([data[@"follow"][@"count_from"] isKindOfClass:[NSNumber class]]) {
        cell.count.text=[data[@"follow"][@"count_from"] stringValue];
    }else{
        cell.count.text=data[@"follow"][@"count_from"];
    }
    
    
    //cell.inserttime.text=[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"CreateAlbumText-pDate", @""),[dateFormatter stringFromDate:date]];
    cell.userid=[data[@"user" ][@"user_id"] stringValue];
    cell.touser=NO;
    
    if ([tmpAdduserid containsObject:[data[@"user"][@"user_id"] stringValue]] ) {
        [cell isaddData:YES];
    }else{
        [cell isaddData:NO];
    }
    
    cell.customBlock=^(BOOL add,NSString *userid){
        [wTools ShowMBProgressHUD];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            
            NSString *respone=@"";
            NSMutableDictionary *data=[NSMutableDictionary new];
            [data setObject:userid forKey:@"user_id"];
            [data setObject:@"album" forKey:@"type"];
            [data setObject:_albumid forKey:@"type_id"];
            
            if (add) {
                respone=[boxAPI deletecooperation:[wTools getUserID] token:[wTools getUserToken] data:data];
            }else{
                respone=[boxAPI addcooperation:[wTools getUserID] token:[wTools getUserToken] data:data];
            }
                                                
            dispatch_async(dispatch_get_main_queue(), ^{
                [wTools HideMBProgressHUD];
                if (respone!=nil) {
                    NSLog(@"%@",respone);
                    NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        if (!add) {
                            if (![tmpAdduserid containsObject:userid]){
                                [tmpAdduserid addObject:userid];
                                
                            }
                        }else{
                            if ([tmpAdduserid containsObject:userid]){
                                [tmpAdduserid removeObject:userid];
                            }                            
                        }
                        [mytable reloadData];
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗：%@",dic[@"message"]);
                        [self showCustomErrorAlert: dic[@"message"]];
                    } else {
                        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            });
        });
    };    
    return cell;
}

- (void)loadData:(UIAlertView *) alert{
    NSLog(@"loadData");
    
    if (!isLoading) {
        if (alldata.count==0) {
            [wTools ShowMBProgressHUD];
        }
        isLoading = YES;
        NSString *respone=@"";
        NSMutableDictionary *data=[NSMutableDictionary new];
        [data setObject:@"user" forKey:@"searchtype"];
        //[data setObject:searchText.text forKey:@"searchkey"];
        [data setObject: self.searchController.searchBar.text forKey: @"searchkey"];
        
        NSString *limit=[NSString stringWithFormat:@"%d,%d",nextId,nextId+10];
        [data setObject:limit forKey:@"limit"];
        
        respone=[boxAPI search:[wTools getUserID] token:[wTools getUserToken] data:data];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            
            NSString *respone=[boxAPI getrecommended:[wTools getUserID] token:[wTools getUserToken] data:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                [wTools HideMBProgressHUD];
                if (respone!=nil) {
                    NSLog(@"%@",respone);
                    NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        int s=0;
                        for (NSMutableDictionary *picture in [dic objectForKey:@"data"]) {
                            s++;
                            [alldata addObject: picture];
                        }
                        nextId = nextId+s;
                        
                        if (alert != nil)
                            [alert dismissWithClickedButtonIndex:-1 animated:YES];
                        [mytable reloadData];
                        
                        if (nextId  >= 0)
                            isLoading = NO;
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
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"scrollViewWillBeginDragging");
    
    if (isLoading)
        return;
    
    if ((scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height * 2)) {
        [self loadData:nil];
    }
}

// scrollViewDidScroll: gets called every time the scroll bounds change. This means it gets called during the scroll, as well as when it starts. You may want to try scrollViewWillBeginDragging: instead.
/*
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidScroll");
    
    if (isLoading)
        return;
    
    if ((scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height * 2)) {
        [self loadData:nil];
    }
}
*/
 
#pragma mark - SearchBar Delegate Methods
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    NSLog(@"searchBarTextDidBeginEditing");
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"searchBarCancelButtonClicked");
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"searchBarSearchButtonClicked");
    //[self.searchController.searchBar resignFirstResponder];
    
    NSString *str = searchBar.text;
    [self.searchController setActive: NO];
    self.searchController.searchBar.text = str;
    
    [self callProtocolSearch: str];
}

- (void)callProtocolSearch: (NSString *)text {
    NSLog(@"callProtocolSearch");
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        isLoading = YES;
        NSString *respone=@"";
        NSMutableDictionary *data=[NSMutableDictionary new];
        [data setObject: @"user" forKey:@"searchtype"];
        [data setObject: text forKey:@"searchkey"];
        [data setObject: @"0,10" forKey:@"limit"];
        respone=[boxAPI search:[wTools getUserID] token:[wTools getUserToken] data:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (respone!=nil) {
                NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                if ([dic[@"result"] intValue] == 1) {
                    alldata=[NSMutableArray arrayWithArray:dic[@"data"]];
                    nextId=alldata.count;
                    
                    if (nextId  >= 0){
                        isLoading = NO;
                    }
                    [mytable reloadData];
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
