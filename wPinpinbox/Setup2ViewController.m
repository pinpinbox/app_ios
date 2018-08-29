//
//  Setup2ViewController.m
//  wPinpinbox
//
//  Created by Angus on 2016/2/3.
//  Copyright (c) 2016年 Angus. All rights reserved.
//

#import "Setup2ViewController.h"
#import "ModeTableViewCell.h"
#import "TaobanViewController.h"
#import "wTools.h"
#import "boxAPI.h"
#import "CustomIOSAlertView.h"
#import "UIColor+Extensions.h"

@interface Setup2ViewController ()
{
    BOOL isLoading;
    NSMutableArray *pictures;
    NSInteger  nextId;
}
@property(weak,nonatomic)IBOutlet UITableView *tableView;
@property(weak,nonatomic)IBOutlet UILabel *titlelab;
@end

@implementation Setup2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"Setup2ViewController");
    
    pictures =[NSMutableArray new];
    [self loadData:nil];
    _titlelab.text=NSLocalizedString(@"CreateAlbumText-create", @"");
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSLog(@"viewWillAppear");
    NSLog(@"self.title: %@", self.title);
    self.titlelab.text=self.title;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
        self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
   
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    return pictures.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 194;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    NSString *str=@"ModeTableViewCell";
  
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
    }else{
        mcell.title1.text=@"";
    }
    if (![data[@"user"][@"name"] isKindOfClass:[NSNull class]]) {
        mcell.title2.text=data[@"user"][@"name"];
    }else{
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
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data=pictures[indexPath.row];
    //TaobanViewController *tv=[[TaobanViewController alloc]initWithNibName:@"TaobanViewController" bundle:nil];
    TaobanViewController *tv = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"TaobanViewController"];
    tv.temolateid=data[@"template"][@"template_id"];
    tv.event_id = _event_id;
    tv.postMode = _postMode;
    NSLog(@"postMode: %d", _postMode);
    
    [self.navigationController pushViewController:tv animated:YES];
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
            
            NSString *respone=[boxAPI gettemplatelist:[wTools getUserID] token:[wTools getUserToken] data:data event: _event_id style:_style_id];
            
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
                        
                        if (nextId  >= 0)
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

@end
