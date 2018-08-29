//
//  SetupTableViewController.m
//  wPinpinbox
//
//  Created by Angus on 2015/11/4.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "SetupTableViewController.h"
#import "wTools.h"
#import "boxAPI.h"
#import "AsyncImageView.h"
#import "ModeTableViewCell.h"
#import "TaobanViewController.h"
#import "AppDelegate.h"
#import "Setup2ViewController.h"

#import "CustomIOSAlertView.h"
#import "UIColor+Extensions.h"

@interface SetupTableViewController ()
{
    NSArray *datalist;
    NSArray *classlist;
    
    BOOL isLoading;
    NSMutableArray *pictures;
    NSInteger  nextId;
    
    NSDictionary *dataForSegue;
}
@end

@implementation SetupTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"SetupTableViewController");
    
    datalist=[NSArray new];
    classlist=_classlist;
    
    self.view.backgroundColor=[UIColor whiteColor];
    nextId = 0;
    isLoading = NO;
    pictures = [NSMutableArray new];
    
     [self loadData:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    if (_type==0) {
        self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    }else{
        self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    if (_type==1) {
        return classlist.count;
    }
    return pictures.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_type==0) {
        return 194;
    }
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    NSString *str=@"ModeTableViewCell";
    if (_type==0) {
        cell= [tableView dequeueReusableCellWithIdentifier:str];
        if (cell == nil) {
            [tableView registerNib:[UINib nibWithNibName:str bundle:nil] forCellReuseIdentifier:str];
            cell=[tableView dequeueReusableCellWithIdentifier:str];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
        
        ModeTableViewCell *mcell=(ModeTableViewCell *)cell;
        
        NSDictionary *data=pictures[indexPath.row];
        
        mcell.topimage.image=[UIImage imageNamed:@""];
        mcell.topimage.backgroundColor=[UIColor grayColor];
        
        if (![data[@"template"][@"image"] isKindOfClass:[NSNull class]]) {
            [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: mcell.topimage];
            mcell.topimage.imageURL=[NSURL URLWithString:data[@"template"][@"image"]];
        }
        
        if (![data[@"template"][@"name"] isKindOfClass:[NSNull class]]) {
             mcell.title1.text=data[@"template"][@"name"];
        } else {
             mcell.title1.text=@"";
             
        }
        if (![data[@"user"][@"name"] isKindOfClass:[NSNull class]]) {
            mcell.title2.text=data[@"user"][@"name"];
        } else {
            mcell.title2.text=@"";
        }

        //價格 是否已取得
        mcell.typeimage.hidden=YES;
        if ([data[@"template"][@"own"] boolValue]) {
            mcell.typeimage.hidden=NO;
            mcell.typelab.text=NSLocalizedString(@"CreateAlbumText-own", @"");
        }else{
            mcell.typelab.text=[NSString stringWithFormat:@"%@P",[data[@"template"][@"point"] stringValue]];
        }
        mcell.downlab.text=[NSString stringWithFormat:@"%@",[data[@"templatestatistics"][@"count"] stringValue]];
        
        mcell.titletext.text=data[@"template"][@"description"];

    } else {
        str=@"CellIdentifier";
        cell= [tableView dequeueReusableCellWithIdentifier:str];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.textLabel.text=classlist[indexPath.row][@"name"];
        
    }// Configure the cell...
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"didSelectRowAtIndexPath");
    
    if (_type == 0) {
        NSLog(@"type: %ld", (long)_type);
        
        //return;
//        NSDictionary *data = pictures[indexPath.row];
        dataForSegue = pictures[indexPath.row];
        
        //TaobanViewController *tv = [[TaobanViewController alloc]initWithNibName:@"TaobanViewController" bundle:nil];
        TaobanViewController *tv = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"TaobanViewController"];
        tv.temolateid = dataForSegue[@"template"][@"template_id"];
        
        NSLog(@"select template_id: %@", dataForSegue[@"template"][@"template_id"]);
        
        [self.navigationController pushViewController: tv animated: YES];
        
        //AppDelegate *app=[[UIApplication sharedApplication]delegate];
        //[app.myNav pushViewController:tv animated:YES];
        
        /*
        if ([self.delegate respondsToSelector: @selector(passTemplateIdForPushing:)]) {
            NSLog(@"self.delegate respondsToSelector passTemplateIdForPushing");
            [self.delegate passTemplateIdForPushing: data[@"template"][@"template_id"]];
        }
        */
        //[self performSegueWithIdentifier: @"showTaobanViewController" sender: self];
        
    } else {
        NSLog(@"type: %ld", (long)_type);
        
        //Setup2ViewController *s2v=[[Setup2ViewController alloc]initWithNibName:@"Setup2ViewController" bundle:nil];
        Setup2ViewController *s2v = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"Setup2ViewController"];
        s2v.rank=_rank;
        s2v.style_id=[classlist[indexPath.row][@"style_id"] stringValue];
        NSString *str= classlist[indexPath.row][@"name"];
        NSArray * menuItems = [[NSArray alloc] initWithObjects:NSLocalizedString(@"CreateAlbumText-hot", @""), NSLocalizedString(@"CreateAlbumText-free", @""), NSLocalizedString(@"CreateAlbumText-sponsor", @""), NSLocalizedString(@"CreateAlbumText-own", @""), nil];
        
        NSArray *menuid=@[@"hot",@"free",@"sponsored",@"own"];
        NSDictionary *dic=[NSDictionary dictionaryWithObjects:menuItems forKeys:menuid];
        s2v.title=[NSString stringWithFormat:@"%@/%@",dic[_rank],str];
        
        //AppDelegate *app=[[UIApplication sharedApplication]delegate];
        //[app.myNav pushViewController:s2v animated:YES];
        [self.navigationController pushViewController: s2v animated: YES];
    }
}

- (void)loadData:(UIAlertView *) alert{
    if (!isLoading) {
        if (pictures.count==0) {
            // [wTools ShowMBProgressHUD];
        }
        isLoading = YES;
        NSMutableDictionary *data = [NSMutableDictionary new];
        NSString *limit=[NSString stringWithFormat:@"%ld,%ld",nextId,nextId+10];
        [data setObject:_rank forKey:@"rank"];
        [data setValue:limit forKey:@"limit"];
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            
            NSString *respone=[boxAPI gettemplatelist:[wTools getUserID] token:[wTools getUserToken] data:data event: nil style:nil];
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
                        
                        if (nextId >= 0)
                            isLoading = NO;
                        if (s==0) {
                            isLoading=YES;
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
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_type!=0) {
        return;
    }
    if (isLoading)
        return;
    
    if ((scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height * 2)) {
        [self loadData:nil];
    }
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

/*
- (void)performSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString: @"showTaobanViewController"]) {
        NSLog(@"perform segue");
        NSLog(@"show TaoBan");
        
        //TaobanViewController *tv = [[TaobanViewController alloc]initWithNibName:@"TaobanViewController" bundle:nil];
        TaobanViewController *tv = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"TaobanViewController"];
        tv.temolateid = dataForSegue[@"template"][@"template_id"];
        
        NSLog(@"select template_id: %@", dataForSegue[@"template"][@"template_id"]);
        
        tv.navigationItem.title = @"版 型 介 紹";
        tv.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:18 weight:UIFontWeightLight], NSForegroundColorAttributeName: [UIColor whiteColor]};
        
        [self.navigationController pushViewController: tv animated: YES];
    }
}
*/

@end
