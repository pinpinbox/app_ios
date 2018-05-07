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
                
                if ([dic[@"result"]boolValue]) {
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
                    
                }else{
                    NSLog(@"失敗：%@",dic[@"message"]);
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
                    
                    if ([dic[@"result"]boolValue]) {
                        
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
                    }else{
                        NSLog(@"失敗：%@",dic[@"message"]);
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
                    
                    if ([dic[@"result"]boolValue]) {
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
                    }else{
                        NSLog(@"失敗：%@",dic[@"message"]);
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


@end
