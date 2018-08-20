//
//  RecommendViewController.m
//  wPinpinbox
//
//  Created by Angus on 2015/10/22.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "RecommendViewController.h"
#import "RecommendTableViewCell.h"
#import "wTools.h"
#import "boxAPI.h"
#import "AsyncImageView.h"
#import "AppDelegate.h"
#import "Recommend2ViewController.h"
#import "CustomIOSAlertView.h"
#import "UIColor+Extensions.h"

@interface RecommendViewController ()
{
    BOOL isLoading;
    
    NSMutableArray *pictures;
    NSInteger  nextId;
    
    NSMutableArray *tmpAdduserid;
    
    __weak IBOutlet UIButton *bgbtn;
}

@property(weak,nonatomic) IBOutlet UITableView *tableView;
@end

@implementation RecommendViewController
- (IBAction)back:(id)sender {
    /*
    if (_working) {
          [self.navigationController popViewControllerAnimated:YES];
    } else{
        AppDelegate *app=[[UIApplication sharedApplication]delegate];
        [app.menu showMenu];

    }
     */
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tmpAdduserid=[NSMutableArray new];
    nextId = 0;
    isLoading = NO;
    pictures = [NSMutableArray new];
    wtitle.text=NSLocalizedString(@"AttentionText-more", @"");
    lab_fb.text=NSLocalizedString(@"AttentionText-searchFB", @"");
    lab_contacts.text=NSLocalizedString(@"AttentionText-syncContacts", @"");
    lab_text.text=NSLocalizedString(@"AttentionText-recommendPRO", @"");
   // [self loadData:nil];
    
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"viewWillAppear");
    
    [super viewWillAppear:animated];
    
    if (_working) {
        [bgbtn setImage:[UIImage imageNamed:@"button_back.png"] forState:UIControlStateNormal];
    }else{
        [bgbtn setImage:[UIImage imageNamed:@"button_manu.png"] forState:UIControlStateNormal];
    }
    
    [wTools ShowMBProgressHUD];
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *respone=[boxAPI getprofile:[userPrefs objectForKey:@"id"] token:[userPrefs objectForKey:@"token"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            if (respone!=nil) {
                //NSLog(@"%@",respone);
                NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                if ([dic[@"result"] intValue] == 1) {
                    NSLog(@"got result from calling getProfile");
                    
                    //儲存會員資料
                    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
                    NSMutableDictionary *dataic=[[NSMutableDictionary alloc]initWithDictionary:dic[@"data"] copyItems:YES];
                    for (NSString *kye in [dataic allKeys] ) {
                        id objective =[dataic objectForKey:kye];
                        if ([objective isKindOfClass:[NSNull class]]) {
                            [dataic setObject:@"" forKey:kye];
                        }
                        
                    }
                    [userPrefs setValue:dataic forKey:@"profile"];
                    [userPrefs synchronize];
                    
                    AppDelegate *app=[[UIApplication sharedApplication]delegate];                    
                    [app.menu reloadpic:dic[@"data"][@"profilepic"]];
                    
                    nextId = 0;
                    isLoading = NO;
                    [pictures removeAllObjects];
                    
                    [self loadData:nil];
                    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)loadData:(UIAlertView *) alert{
    
    NSLog(@"loadData");
    
    if (!isLoading) {
        if (pictures.count==0) {
            //[wTools ShowMBProgressHUD];
        }
        
        isLoading = YES;
        NSMutableDictionary *data = [NSMutableDictionary new];
        NSString *limit=[NSString stringWithFormat:@"%d,%d",nextId,nextId+10];
        [data setValue:limit forKey:@"limit"];
        [data setObject:@"official=" forKey:@"rank"];
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
                            [pictures addObject: picture];
                        }
                        nextId = nextId+s;
                        
                        if (alert != nil)
                            [alert dismissWithClickedButtonIndex:-1 animated:YES];
                        
                        [self.tableView reloadData];
                        
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (isLoading)
        return;
    
    if ((scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height * 2)) {
        [self loadData:nil];
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    return pictures.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    return 95;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // NSString *identifier = [NSString stringWithFormat:@"HomeTableViewCell_%@", [[[pictures objectAtIndex:indexPath.row] objectForKey:@"album"]objectForKey:@"album_id" ]];
    NSString *CellIdentifier=@"RecommendTableViewCell";
    
    RecommendTableViewCell *cell=nil;
    cell= [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"RecommendTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
        cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    cell.picture.image=[UIImage imageNamed:@"user_photo.png"];
  
    NSDictionary *data=pictures[indexPath.row];
    
   // NSLog(@"%@",data);
    AsyncImageView *imav=(AsyncImageView*)cell.picture;
    imav.imageURL=nil;
    imav.image=[UIImage imageNamed:@"1-02a1track_photo.png"];
    NSDictionary *count=data[@"user" ][@"picture"];
    
    if (![count isKindOfClass:[NSNull class]]) {
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: imav];
        imav.imageURL=[NSURL URLWithString:data[@"user" ][@"picture"]];
    }
    
    cell.name.text=data[@"user" ][@"name"];
    
    if ([data[@"follow"][@"count_from"] isKindOfClass:[NSNumber class]]) {
        cell.count.text=[data[@"follow"][@"count_from"] stringValue];
    }else{
       cell.count.text=data[@"follow"][@"count_from"];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:data[@"user"][@"inserttime"]];
     [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    cell.inserttime.text=[dateFormatter stringFromDate:date];
    cell.userid=data[@"user"][@"user_id"];
    cell.touser=YES;
    
    if ([tmpAdduserid containsObject:data[@"user" ][@"user_id"]] ) {
        [cell isaddData:YES];
    }else{
        [cell isaddData:NO];
    }
    
    cell.customBlock=^(BOOL add,NSString *userid){
        [wTools ShowMBProgressHUD];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            
            NSString *respone=[boxAPI changefollowstatus:[wTools getUserID] token:[wTools getUserToken] authorid:userid];
            dispatch_async(dispatch_get_main_queue(), ^{
                [wTools HideMBProgressHUD];
                
                if (respone!=nil) {
                    NSLog(@"%@",respone);
                    NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        NSDictionary *d=dic[@"data"];
                        if ([d[@"followstatus" ]boolValue]) {
                            if (![tmpAdduserid containsObject:userid]){
                               [tmpAdduserid addObject:userid];
                            }
                        }else{
                            if ([tmpAdduserid containsObject:userid]){
                               [tmpAdduserid removeObject:userid];
                            }
                        }
                        [_tableView reloadData];
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
    
    
    
    /*
     
     @property (weak, nonatomic) IBOutlet UIImageView *picture;
     @property (weak, nonatomic) IBOutlet UILabel *name;
     @property (weak, nonatomic) IBOutlet UILabel *count;
     @property (weak, nonatomic) IBOutlet UILabel *inserttime;
     */
    
    return cell;
}



//處理
-(IBAction)FBfriend:(id)sender{
    //Recommend2ViewController *rv2=[[Recommend2ViewController alloc]initWithNibName:@"Recommend2ViewController" bundle:nil];
    Recommend2ViewController *rv2 = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"Recommend2ViewController"];
    rv2.type=@"FB";
    
    [self.navigationController pushViewController:rv2 animated:YES];
    
}
-(IBAction)phonefriend:(id)sender{
    //Recommend2ViewController *rv2=[[Recommend2ViewController alloc]initWithNibName:@"Recommend2ViewController" bundle:nil];
    Recommend2ViewController *rv2 = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"Recommend2ViewController"];
    rv2.type=@"PH";
    
    [self.navigationController pushViewController:rv2 animated:YES];
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
