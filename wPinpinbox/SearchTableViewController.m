//
//  SearchTableViewController.m
//  wPinpinbox
//
//  Created by Angus on 2015/11/4.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "SearchTableViewController.h"
#import "SeacrhbookTableViewCell.h"
#import "SearchuserTableViewCell.h"
#import "wTools.h"
#import "boxAPI.h"
#import "AsyncImageView.h"

#import "RetrievealbumpViewController.h"

#import "AppDelegate.h"
#import "Remind.h"

#import "CreativeViewController.h"
#import "CustomIOSAlertView.h"
#import "UIColor+Extensions.h"

@interface SearchTableViewController ()
{
    BOOL isLoading;
    NSMutableArray *alldata;
    NSInteger  nextId;
    NSMutableArray *tmpAdduserid;
}
@end

@implementation SearchTableViewController

-(void)isLoading:(BOOL)bo{
    isLoading=bo;
}
-(void)alldata:(NSMutableArray *)arr{
    alldata=[NSMutableArray arrayWithArray:arr];
    tmpAdduserid=[NSMutableArray new];
    
    for (int i =0; i<alldata.count; i++) {
        NSDictionary *dic=alldata[i];
        NSString *userid=[dic[@"user" ][@"user_id"] stringValue];
        
        if ([dic[@"follow"][@"follow"] boolValue]) {
            if (![tmpAdduserid containsObject:userid]){
                [tmpAdduserid addObject:userid];
            }
        }
    }
}
-(void)nextId:(NSInteger)nid{
    nextId=nid;
}

- (void)viewDidLoad {
    [super viewDidLoad];        
    
    isLoading=YES;
    tmpAdduserid=[NSMutableArray new];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    NSLog(@"numberOfRowsInSection");
    NSLog(@"alldata.count: %lu", (unsigned long)alldata.count);
    return alldata.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"self.searchtype: %@", self.searchtype);
    
    NSString *CellIdentifier=@"SeacrhbookTableViewCell";
    //SeacrhbookTableViewCell
    
    if ([self.searchtype isEqualToString:@"user"]) {
        CellIdentifier=@"SearchuserTableViewCell";
        SearchuserTableViewCell *cell=nil;
        cell= [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            [tableView registerNib:[UINib nibWithNibName:CellIdentifier bundle:nil] forCellReuseIdentifier:CellIdentifier];
            cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.picture.image=[UIImage imageNamed:@"user_photo.png"];
        
        NSDictionary *data=alldata[indexPath.row];
        AsyncImageView *imav=(AsyncImageView*)cell.picture;
        imav.imageURL=nil;
        imav.image=[UIImage imageNamed:@"1-02a1track_photo.png"];
        NSDictionary *count=data[@"user"][@"picture"];
        
        if (![count isKindOfClass:[NSNull class]]) {
            [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: imav];
            imav.imageURL=[NSURL URLWithString:data[@"user"][@"picture"]];
        } else {
            [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: imav];
            imav.image = [UIImage imageNamed: @"member_back_head.png"];
        }
        cell.name.text=data[@"user"][@"name"];
        
        if ([data[@"follow"][@"count_from"] isKindOfClass:[NSNumber class]]) {
            cell.count.text=[data[@"follow"][@"count_from"] stringValue];
        }else{
            cell.count.text=data[@"follow"][@"count_from"];
        }
        
        cell.inserttime.text=[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"SearchText-createDate", @""),data[@"user"][@"inserttime"]];
        cell.userid=[data[@"user" ][@"user_id"] stringValue];
        cell.touser=YES;
        
        
        if ([tmpAdduserid containsObject:cell.userid] ) {
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
                            [self.tableView reloadData];
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
    
    SeacrhbookTableViewCell *cell=nil;
    cell= [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:CellIdentifier bundle:nil] forCellReuseIdentifier:CellIdentifier];
        cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    NSDictionary *data=alldata[indexPath.row];
    AsyncImageView *imav=(AsyncImageView*)cell.picture;
    imav.imageURL=nil;
    imav.image=[UIImage imageNamed:@"1-02a1track_photo.png"];
    
    if (![data[@"album" ][@"cover"] isKindOfClass:[NSNull class]]) {
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: imav];
        imav.imageURL=[NSURL URLWithString:data[@"album"][@"cover"]];
    } else {
        imav.imageURL = [NSURL URLWithString: @"https://ppb.sharemomo.com/static_file/pinpinbox/zh_TW/images/origin.jpg"];
    }
    cell.name.text=data[@"user"][@"name"];
    cell.count.text=[NSString stringWithFormat:@"%@P",[data[@"album"][@"point"]stringValue]];
    cell.titlename.text=data[@"album"][@"name"];
        
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 95;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *data=alldata[indexPath.row];
    
    if ([self.searchtype isEqualToString:@"album"]) {
        //[wTools ToRetrievealbumpViewControlleralbumid:[data[@"album"][@"album_id"] stringValue]];
        [self ToRetrievealbumpViewControlleralbumid: [data[@"album"][@"album_id"] stringValue]];
    }
    
    SearchuserTableViewCell *cell = [self.tableView cellForRowAtIndexPath: indexPath];
    
    if ([self.searchtype isEqualToString: @"user"]) {
        [self showCreativeViewuserid: data[@"user"][@"user_id"] isfollow: cell.button.selected];
    }
}

- (void)ToRetrievealbumpViewControlleralbumid:(NSString *)albumid {
    
    NSLog(@"ToRetrievealbumpViewControlleralbumid");
    
    [wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *respone=[boxAPI retrievealbump:albumid uid:[wTools getUserID] token:[wTools getUserToken]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [wTools HideMBProgressHUD];
            
            if (respone!=nil)
            {
                NSLog(@"check response");
                NSLog(@"respone: %@", respone);
                
                //NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [respone dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
                
                if ([dic[@"result"] intValue] == 1) {
                    NSLog(@"result bool value is YES");
                    NSLog(@"dic: %@", dic);
                    
                    NSLog(@"dic data photo: %@", dic[@"data"][@"photo"]);
                    
                    NSLog(@"dic data user name: %@", dic[@"data"][@"user"][@"name"]);
                    
                    //RetrievealbumpViewController *rev=[[RetrievealbumpViewController alloc]initWithNibName:@"RetrievealbumpViewController" bundle:nil];
                    RetrievealbumpViewController *rev = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"RetrievealbumpViewController"];
                    rev.data=[dic[@"data"] mutableCopy];
                    
                    NSLog(@"rev.data: %@", rev.data);
                    
                    rev.albumid=albumid;
                    rev.fromXib = YES;
                    //[app.myNav pushViewController:rev animated:YES];
                    [self.navigationController pushViewController: rev animated: YES];
                } else if ([dic[@"result"] intValue] == 0) {
                    NSLog(@"失敗：%@",dic[@"message"]);
                    Remind *rv=[[Remind alloc]initWithFrame:app.menu.view.bounds];
                    [rv addtitletext:dic[@"message"]];
                    [rv addBackTouch];
                    [rv showView:app.menu.view];
                } else {
                    Remind *rv=[[Remind alloc]initWithFrame:app.menu.view.bounds];
                    [rv addtitletext:NSLocalizedString(@"Host-NotAvailable", @"")];
                    [rv addBackTouch];
                    [rv showView:app.menu.view];
                }
            }
        });
    });
}

- (void)showCreativeViewuserid:(NSString *)userid isfollow:(BOOL)follow
{
    CreativeViewController *cvc=[[UIStoryboard storyboardWithName: @"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"CreativeViewController"];
    cvc.userid = userid;
    cvc.follow = follow;
    
    [self.navigationController pushViewController: cvc animated: NO];
}


- (void)loadData:(UIAlertView *) alert{
    
    if (!isLoading) {
        if (alldata.count==0) {
            [wTools ShowMBProgressHUD];
        }
        isLoading = YES;
        NSString *respone=@"";
        NSMutableDictionary *data=[NSMutableDictionary new];
        [data setObject:self.searchtype forKey:@"searchtype"];
        [data setObject:_textkey forKey:@"searchkey"];
        NSString *limit=[NSString stringWithFormat:@"%ld,%d",nextId, 10];
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
                            NSDictionary *dic=picture;
                            NSString *userid=[dic[@"user" ][@"user_id"] stringValue];
                            if ([dic[@"follow"][@"follow"] boolValue]) {
                                if (![tmpAdduserid containsObject:userid]){
                                    [tmpAdduserid addObject:userid];
                                }
                            }
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

#pragma mark - Custom Error Alert Method
- (void)showCustomErrorAlert: (NSString *)msg {
    CustomIOSAlertView *errorAlertView = [[CustomIOSAlertView alloc] init];
    //[errorAlertView setContainerView: [self createErrorContainerView: msg]];
    [errorAlertView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstPink] badgeName:nil];
    
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
