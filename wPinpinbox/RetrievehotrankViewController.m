//
//  RetrievehotrankViewController.m
//  wPinpinbox
//
//  Created by Angus on 2015/10/23.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "RetrievehotrankViewController.h"
#import "AppDelegate.h"
#import "wTools.h"
#import "boxAPI.h"
#import "RetrievehotrankTableViewCell.h"
#import "AsyncImageView.h"
#import "WdataButton.h"

#import "RetrievealbumpViewController.h"
#import "Remind.h"

#import "CustomIOSAlertView.h"
#import "UIColor+Extensions.h"
#import "UIViewController+ErrorAlert.h"

@interface RetrievehotrankViewController ()
{
    NSMutableArray *titlelist;
    __weak IBOutlet UITableView *mytableview;
    
    NSString *albumIDForSegue;
}
@end

@implementation RetrievehotrankViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    wtitele.text=NSLocalizedString(@"GeneralText-rank", @"");
    [_bottom_HotBtn setTitle:NSLocalizedString(@"RankText-hot", @"") forState:UIControlStateNormal];
    [_bottom_FreeBtn setTitle:NSLocalizedString(@"RankText-free", @"") forState:UIControlStateNormal];
    [_bottom_SupBtn setTitle:NSLocalizedString(@"RankText-sponsor", @"") forState:UIControlStateNormal];
    
    if (!_ranktype) {
        _ranktype=@"0";
    }
    titlelist=[NSMutableArray new];
     [self reloaddata];
    
    mytableview.exclusiveTouch=YES;
    _bottom_HotBtn.exclusiveTouch=YES;
    _bottom_FreeBtn.exclusiveTouch=YES;
    _bottom_SupBtn.exclusiveTouch=YES;
}

- (IBAction)btn:(UIButton *)sender {
    _bottom_HotBtn.selected=NO;
    _bottom_FreeBtn.selected=NO;
    _bottom_SupBtn.selected=NO;
    
    
    sender.selected=YES;
    [mytableview setContentOffset:CGPointZero animated:NO];
    if (_bottom_HotBtn==sender) {
        _ranktype=@"0";
    }else if(_bottom_FreeBtn==sender){
        _ranktype=@"1";
    }else{
        _ranktype=@"2";
    }
    
    [self reloaddata];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)showMenu:(id)sender {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [app.menu showMenu];
}

-(void)reloaddata{    
    //[mytableview setContentOffset:CGPointZero animated:YES];
    [titlelist removeAllObjects];
    
    [wTools ShowMBProgressHUD];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString*retrievecatgeorylist=[boxAPI retrievecatgeorylist:[wTools getUserID] token:[wTools getUserToken]];
        
        BOOL isreloaddata=NO;
      //  NSLog(@"%@",retrievecatgeorylist);
        if (retrievecatgeorylist!=nil){
             NSDictionary *rdic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[retrievecatgeorylist dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            if ([rdic[@"result"] intValue] == 1) {
                NSArray *strArray = [rdic[@"data"] componentsSeparatedByString:@","];
                
                for (int i = 0; i < strArray.count / 2; i++) {
                    
                    int j = i * 2;
                    NSString *categoryId = [NSString stringWithFormat: @"%@", strArray[0 + j]];
                    NSString *title = [NSString stringWithFormat: @"%@", strArray[1 + j]];
                    
                    NSMutableDictionary *adddata=[NSMutableDictionary new];
                    [adddata setObject: categoryId forKey:@"categoryId"];
                    [adddata setObject: title forKey:@"title"];
                    
                    NSString *respone = [boxAPI retrievehotrank: [wTools getUserID] token: [wTools getUserToken] rankid: _ranktype categoryid: categoryId];
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    if (respone != nil) {
                        
                        if ([dic[@"result"]boolValue]) {
                           
                            if (dic[@"data"]) {
                                NSArray *objdata = [dic[@"data"] mutableCopy];
                                [adddata setObject: objdata forKey: @"data"];
                            }
                        }
                    }                    
                    
                    if (!adddata[@"data"]) {
                        [adddata setObject: [NSArray new] forKey: @"data"];
                    }
                    [titlelist addObject:adddata];
                    
                }
                isreloaddata=YES;
            } else if ([rdic[@"result"] intValue] == 0) {
                NSLog(@"失敗：%@",rdic[@"message"]);
                [self showCustomErrorAlert: rdic[@"message"]];
            } else {
                [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (isreloaddata) {
                NSLog(@"成功,%@",titlelist);
                [mytableview reloadData];
            }else{
                NSLog(@"失敗");
            }
        });
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    return titlelist.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (titlelist.count<indexPath.row+1) {
        return 36;
    }
     NSDictionary *data=titlelist[indexPath.row];
    NSArray *list=data[@"data"];
    if ([list count]==0) {
        return 36;
    }
    return 220;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // NSString *identifier = [NSString stringWithFormat:@"HomeTableViewCell_%@", [[[pictures objectAtIndex:indexPath.row] objectForKey:@"album"]objectForKey:@"album_id" ]];
    NSString *CellIdentifier=@"RetrievehotrankTableViewCell";
    
    RetrievehotrankTableViewCell *cell=nil;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        [tableView registerNib:[UINib nibWithNibName:@"RetrievehotrankTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
        cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    if (titlelist.count<indexPath.row+1) {
        return cell;
    }
    NSDictionary *data=[titlelist[indexPath.row] mutableCopy];
    
    for (UIView *v in [cell.myscrollview subviews]) {
        [v removeFromSuperview];
    }
    cell.title.text=data[@"title"];
    
    NSArray *list=data[@"data"];
    
    for (int i=0; i<list.count; i++) {
        
        NSDictionary *d=list[i];
        UIView *v=[[UIView alloc]initWithFrame:CGRectMake(100*i, 0, 95, 190)];
        v.backgroundColor=[UIColor clearColor];
        AsyncImageView *imagev=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0, 95, 140)];
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: imagev];
        imagev.imageURL=[NSURL URLWithString:d[@"coverurl"]];
        imagev.contentMode=UIViewContentModeScaleAspectFit;
        [v addSubview:imagev];
        
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(0, 143, 95, 16)];
        label.font=[UIFont systemFontOfSize:12];
        label.text=d[@"title"];
        label.textColor=[UIColor colorWithRed:(float)110/255 green:(float)110/255 blue:(float)100/255 alpha:1.0];
        [v addSubview:label];
        
        UILabel *prize=[[UILabel alloc]initWithFrame:CGRectMake(0, 159, 95, 16)];
        prize.text=[NSString stringWithFormat:@"%@P",[d[@"prize"] stringValue]];
        prize.font=[UIFont systemFontOfSize:11];
        prize.textColor=[UIColor colorWithRed:(float)204/255 green:(float)71/255 blue:(float)116/255 alpha:1.0];
        
        [v addSubview:prize];
       
        [cell.myscrollview addSubview:v];
        

        WdataButton *Wbut = [WdataButton buttonWithType:UIButtonTypeCustom];
        [Wbut setFrame:CGRectMake(0, 0, v.bounds.size.width, v.bounds.size.height)];
        [Wbut addTarget:self action:@selector(selectbtn:) forControlEvents:UIControlEventTouchUpInside];
        [Wbut setDatastr:[d[@"albumid"]stringValue]  ];
        [v addSubview:Wbut];
    }
    
    cell.myscrollview.contentSize=CGSizeMake(100*list.count, 0);
    
    return cell;
}

-(void)selectbtn:(WdataButton *)sender{
    NSLog(@"albumid=%@",sender.datastr);
    
    [wTools ToRetrievealbumpViewControlleralbumid:sender.datastr];
    //[self ToRetrievealbumpViewControlleralbumid: sender.datastr];
}

- (void)ToRetrievealbumpViewControlleralbumid:(NSString *)albumid {
    
    NSLog(@"ToRetrievealbumpViewControlleralbumid");
    
    [wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *respone=[boxAPI retrievealbump:albumid uid:[wTools getUserID] token:[wTools getUserToken]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (respone!=nil) {
                NSLog(@"check response");
                NSLog(@"respone: %@", respone);
                
                NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [respone dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
                
                if ([dic[@"result"] intValue] == 1) {
                    NSLog(@"result bool value is YES");
                    NSLog(@"dic: %@", dic);
                    NSLog(@"dic data photo: %@", dic[@"data"][@"photo"]);
                    NSLog(@"dic data user name: %@", dic[@"data"][@"user"][@"name"]);
                    
                    RetrievealbumpViewController *rev = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"RetrievealbumpViewController"];
                    rev.data=[dic[@"data"] mutableCopy];
                    
                    NSLog(@"rev.data: %@", rev.data);
                    
                    rev.albumid=albumid;
                    rev.fromXib = YES;
                    
                    [self.navigationController pushViewController: rev animated: YES];
                    
                    albumIDForSegue = albumid;
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

#pragma mark - Custom Error Alert Method
- (void)showCustomErrorAlert: (NSString *)msg {
    
    [UIViewController showCustomErrorAlertWithMessage:msg onButtonTouchUpBlock:^(CustomIOSAlertView *customAlertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[customAlertView tag]);
        [customAlertView close];
    }];
 
}
/*
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
*/
/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString: @"showRetrieveAlbumVC"]) {
        RetrievealbumpViewController *rVC = segue.destinationViewController;
        rVC.albumid = albumIDForSegue;
        //rVC.fromXib = YES;
    }
}
*/

@end
