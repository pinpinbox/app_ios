//
//  Recommend2ViewController.m
//  wPinpinbox
//
//  Created by Angus on 2015/12/9.
//  Copyright © 2015年 Angus. All rights reserved.
//

#import "Recommend2ViewController.h"
#import "RecommendTableViewCell.h"
#import "wTools.h"
#import "boxAPI.h"
#import "AsyncImageView.h"
#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <AddressBook/AddressBook.h>
#import "CustomIOSAlertView.h"
#import "UIColor+Extensions.h"

typedef void (^FBBlock)(void);typedef void (^FBBlock)(void);

@interface Recommend2ViewController ()
{
    BOOL isLoading;
    
    NSMutableArray *pictures;
    NSInteger  nextId;
    
    NSMutableArray *tmpAdduserid;
    
    FBBlock _alertOkHandler;
    
    NSString *datarank;
    
    BOOL isfbdata;
    BOOL isPhonebook;
    
      NSMutableArray *userContacts;
    NSMutableDictionary* userDictionary;
    NSArray *userFilterArray;
}
@property(weak,nonatomic) IBOutlet UITableView *tableView;
@end

@implementation Recommend2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    tmpAdduserid=[NSMutableArray new];
    nextId = 0;
    isLoading = NO;
    pictures = [NSMutableArray new];
    isfbdata=YES;
    isPhonebook=YES;
    
    
    wtitle.text=NSLocalizedString(@"AttentionText-recommendPRO", @"");
    lab_text.text=NSLocalizedString(@"AttentionText-mayuKnow", @"");
    [button_attAll setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@.png",@"button_attAll_",[wTools localstring]]] forState:UIControlStateNormal];
 
}
-(IBAction)AddAlldata:(id)sender{
    
    [wTools ShowMBProgressHUD];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        for (int i=0; i<pictures.count; i++) {
            NSDictionary *data=pictures[i];
            if ([tmpAdduserid containsObject:data[@"user" ][@"user_id"]] ) {
                // 已加入
            }else{
                NSString *userid=data[@"user"][@"user_id"];
                NSString *respone=[boxAPI changefollowstatus:[wTools getUserID] token:[wTools getUserToken] authorid:userid];
                
                if (respone!=nil) {
                    NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        NSDictionary *d=dic[@"data"];
                        if ([d[@"followstatus" ]boolValue]) {
                            
                            if (![tmpAdduserid containsObject:userid]){
                                [tmpAdduserid addObject:userid];
                            }
                        } else {
                            if ([tmpAdduserid containsObject:userid]){
                                [tmpAdduserid removeObject:userid];
                            }
                        }
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗：%@",dic[@"message"]);
                        [self showCustomErrorAlert: dic[@"message"]];
                    } else {
                        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
             [_tableView reloadData];
        });
        
    });

}

//FB相關處理
-(void)Facebook{
    if ([FBSDKAccessToken currentAccessToken]) {
        [self facebookFriends];
    }else{
        // Try to login with permissions
        [self loginAndRequestPermissionsWithSuccessHandler:^{
            [self facebookFriends];
            
        }
                                 declinedOrCanceledHandler:^{
                                     // If the user declined permissions tell them why we need permissions
                                     // and ask for permissions again if they want to grant permissions.
                                     [self alertDeclinedPublishActionsWithCompletion:^{
                                         [self loginAndRequestPermissionsWithSuccessHandler:nil
                                                                  declinedOrCanceledHandler:nil
                                                                               errorHandler:^(NSError * error) {
                                                                                   isLoading=YES;
                                                                                   NSLog(@"Error: %@", error.description);
                                                                               }];
                                     }];
                                 }
                                              errorHandler:^(NSError * error) {
                                                  NSLog(@"Error: %@", error.description);
                                                  isLoading=YES;
                                              }];
    }

}
-(void)facebookFriends{
    
    if ( [[FBSDKAccessToken currentAccessToken].permissions containsObject:@"user_friends"]) {
        
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                      initWithGraphPath:@"/me/friends"
                                      parameters:[NSDictionary new]
                                      HTTPMethod:@"GET"];
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                              NSDictionary* result,
                                              NSError *error) {
            
            if (connection) {
                NSLog(@"Friends = %@",result);
                
                NSArray *data=result[@"data"];
                
                NSString *rank=@"facebook=";
                for (int i=0; i<data.count; i++) {
                    NSDictionary *d=data[i];
                    if (i==0) {
                        rank=[NSString stringWithFormat:@"%@%@",rank,d[@"id"]];
                    }else{
                        rank=[NSString stringWithFormat:@"%@,%@",rank,d[@"id"]];
                    }
                }
                
                
                [self reloadAPI:rank];
                
            }else if (!connection) {
                NSLog(@"Get Friends Error");
            }
            // Handle the result
        }];
        
        return;
    }
    
    
    
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logInWithReadPermissions:@[@"user_friends"]
                        fromViewController:self
                                   handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                       if (error) {
                                           NSLog(@"404");
                                           return;
                                       }
                                       
                                       if ([FBSDKAccessToken currentAccessToken] &&
                                           [[FBSDKAccessToken currentAccessToken].permissions containsObject:@"user_friends"]) {
                                           
                                           
                                           FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                                                         initWithGraphPath:@"/me/friends"
                                                                         parameters:[NSDictionary new]
                                                                         HTTPMethod:@"GET"];
                                           [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                                                                 NSDictionary* result,
                                                                                 NSError *error) {
                                               
                                               if (connection) {
                                                   NSLog(@"Friends = %@",result);
                                                   
                                                   NSArray *data=result[@"data"];
                                                   
                                                   NSString *rank=@"facebook=";
                                                   for (int i=0; i<data.count; i++) {
                                                       NSDictionary *d=data[i];
                                                       if (i==0) {
                                                           rank=[NSString stringWithFormat:@"%@%@",rank,d[@"id"]];
                                                       }else{
                                                          rank=[NSString stringWithFormat:@"%@,%@",rank,d[@"id"]];
                                                       }
                                                   }
                                                   
                                                   
                                                   [self reloadAPI:rank];
                                                   
                                               }else if (!connection) {
                                                   NSLog(@"Get Friends Error");
                                               }
                                               // Handle the result
                                           }];

                                           
                                           
                                           return;
                                       }
                                       
                                       
                                       NSLog(@"100");
                                   }];
    
    
    
}
- (void)loginAndRequestPermissionsWithSuccessHandler:(FBBlock) successHandler
                           declinedOrCanceledHandler:(FBBlock) declinedOrCanceledHandler
                                        errorHandler:(void (^)(NSError *)) errorHandler{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    //public_profile
    //publish_actions
    [login
     logInWithReadPermissions: @[@"public_profile"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         
         if (error) {
             if (errorHandler) {
                 errorHandler(error);
             }
             return;
         }
         
         if ([FBSDKAccessToken currentAccessToken] &&
             [[FBSDKAccessToken currentAccessToken].permissions containsObject:@"public_profile"]) {
             
             if (successHandler) {
                 successHandler();
             }
             return;
         }
         
         if (declinedOrCanceledHandler) {
             declinedOrCanceledHandler();
         }
     }];
}

- (void)alertDeclinedPublishActionsWithCompletion:(FBBlock)completion {
    /*
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Publish Permissions"
                                                        message:@"Publish permissions are needed to share game content automatically. Do you want to enable publish permissions?"
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Ok", nil];
    _alertOkHandler = [completion copy];
    [alertView show];
     */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    if ([_type isEqualToString:@"FB"]) {
        if (isfbdata) {
            isfbdata=NO;
            [self Facebook];
        }
    }else{
        if (isPhonebook) {
            isPhonebook=NO;
            [self phonedata];
        }
    }
}


-(void)phonedata{
    ABAddressBookRef ab = NULL;
    // ABAddressBookCreateWithOptions is iOS 6 and up.
    if (&ABAddressBookCreateWithOptions) {
        CFErrorRef error = nil;
        ab = ABAddressBookCreateWithOptions(NULL, &error);
        
        if (error) {
            isLoading=YES;
            NSLog(@"沒有授權 %@", error);
            return;
        }
    }
    if (ab == NULL)
    {
        ab = ABAddressBookCreate();
    }
    if (ab) {
        // ABAddressBookRequestAccessWithCompletion is iOS 6 and up. 适配IOS6以上版本
        if (/* DISABLES CODE */ (&ABAddressBookRequestAccessWithCompletion)) {
            ABAddressBookRequestAccessWithCompletion(ab,
                                                     ^(bool granted, CFErrorRef error) {
                                                         if (granted) {
                                                             // constructInThread: will CFRelease ab.
                                                             [NSThread detachNewThreadSelector:@selector(constructInThread:)
                                                                                      toTarget:self
                                                                                    withObject:CFBridgingRelease(ab)];
                                                         } else {
                                                             //                                                             CFRelease(ab);
                                                             // Ignore the error
                                                         }
                                                     });
        } else
        {
            // constructInThread: will CFRelease ab.
            [NSThread detachNewThreadSelector:@selector(constructInThread:)
                                     toTarget:self
                                   withObject:CFBridgingRelease(ab)];
        }
    }
}

//获取到addressbook的权限
-(void)constructInThread:(ABAddressBookRef) ab
{
    NSLog(@"we got the access right");
    
    //產生 AddressBook 物件
    CFArrayRef results = ABAddressBookCopyArrayOfAllPeople(ab); ////取出所有聯絡人記錄
    NSMutableArray* contactArray = [[NSMutableArray alloc]init];
    userContacts=nil;
    
    for(int i = 0; i < CFArrayGetCount(results); i++) //取出所有人資料
    {
        ABRecordRef person = CFArrayGetValueAtIndex(results, i);
        //姓
        NSString *firstName = (NSString*)CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        //姓音标
        NSString *firstNamePhonetic = (NSString*)CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNamePhoneticProperty));
        //名
        NSString *lastname = (NSString*)CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
        //名音标
        NSString *lastnamePhonetic = (NSString*)CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNamePhoneticProperty));
        
        
        
        
        //读取电话多值
        NSString * phoneString = @"";
        NSString * phonetype = @"";
        //NSString * phoneCountry=@"";
        
        
        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
        
        
        phoneString = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phone, 0);
        phoneString=[phoneString stringByReplacingOccurrencesOfString:@"-" withString:@""];
//        CFDictionaryRef dict =ABMultiValueCopyValueAtIndex(phone, 0);
        //CFStringRef myCountryCode = CFDictionaryGetValue(dict, kABPersonAddressCountryCodeKey);
        //phoneCountry=[NSString stringWithFormat:@"%@",myCountryCode];
        
        CFStringRef leixin = ABMultiValueCopyLabelAtIndex(phone,0);
        phonetype = (__bridge NSString *)leixin;
        phonetype=[self displayPropertyName:phonetype];
        CFRelease(phone);
        
        
        
        
        //获取email多值
        NSString* emailString = @"";
        ABMultiValueRef email = ABRecordCopyValue(person, kABPersonEmailProperty);
        int emailcount = ABMultiValueGetCount(email);
        for (int x = 0; x < emailcount; x++)
        {
            //获取email Label
            //            NSString* emailLabel = (NSString*)CFBridgingRelease(ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(email, x)));
            //获取email值
            NSString* emailContent = (NSString*)CFBridgingRelease(ABMultiValueCopyValueAtIndex(email, x));
            emailString = [emailString stringByAppendingFormat:@"%@",emailContent];
            emailContent = nil;
        }
        CFRelease(email);
        NSData *photo=(__bridge_transfer NSData *)ABPersonCopyImageData(person);
        
        
        //构造字典
        NSDictionary* dic = @{@"first_name": firstName?firstName:[NSNull null],
                              @"Phonetic_name": firstNamePhonetic?firstNamePhonetic:[NSNull null],
                              @"last_name": lastname?lastname:[NSNull null],
                              @"lastnamePhonetic_name": lastnamePhonetic?lastnamePhonetic:[NSNull null],
                              @"email": emailString?emailString:[NSNull null],
                              @"testNumber": [NSNumber numberWithDouble:i],
                              @"phone": phoneString?phoneString:[NSNull null],
                              @"photo":photo?photo:[NSNull null]
                              };
        
        
        BOOL phonet=[phonetype isEqualToString:@"mobile"] || [phonetype isEqualToString:@"iphone"];
        if (![phoneString isEqualToString:@""] && phonet && (firstName || lastname)) {
            [userDictionary setObject:dic forKey:[NSString stringWithFormat:@"%d",i]];
            
            [contactArray addObject:dic];
            
            if (userContacts)
            {
                [userContacts addObject:dic];
                
            }
            else
            {
                userContacts = [[NSMutableArray alloc]initWithArray:contactArray];
                
            }
        }
        
        emailString = nil;
        phoneString = nil;
    }
    CFRelease(results);
    contactArray = nil;
    
    userFilterArray = [[NSMutableArray alloc]initWithArray:userContacts];
    
    
    
    NSString *str=@"";
    for (NSDictionary *dic in userFilterArray ) {
        id phone=[dic objectForKey:@"phone"];
        NSString *sphone=phone==[NSNull null] ? @"" :phone;
        if ([str isEqualToString:@""]) {
            str=[NSString stringWithFormat:@"%@",sphone];
        }else{
            str=[NSString stringWithFormat:@"%@,%@",str,sphone];
        }
        datarank=[NSString stringWithFormat:@"cellphone=%@",str];
        [self loadData:datarank];
        
    }



}

-(void)reloadAPI:(NSString *)rank{
    datarank=[NSString stringWithFormat:@"%@",rank];
                    nextId = 0;
                    isLoading = NO;
                    [pictures removeAllObjects];
                    
                    [self loadData:rank];
}

- (void)loadData:(NSString *) rank{
    if (!isLoading) {
        if (pictures.count==0) {
            [wTools ShowMBProgressHUD];
        }
        isLoading = YES;
        NSMutableDictionary *data = [NSMutableDictionary new];
        NSString *limit=[NSString stringWithFormat:@"%ld,%d",(long)nextId,nextId+10];
        [data setValue:limit forKey:@"limit"];
        if (rank==nil) {
            [data setObject:@"official=" forKey:@"rank"];
        }else{
            [data setObject:rank forKey:@"rank"];
        }
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
        
        if (datarank) {
            [self loadData:datarank];
        }else{
        [self loadData:nil];
        }
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
    NSLog(@"cellForRowAtIndexPath");
    
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
    
    NSLog(@"data: %@", data);
    
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
    return cell;
}

- (NSString *) displayPropertyName:(NSString *) propConst{
    if ([propConst isEqualToString:@"_$!<Anniversary>!$_"]) return @"anniversary";
    if ([propConst isEqualToString:@"_$!<Assistant>!$_"]) return @"assistant";
    if ([propConst isEqualToString:@"_$!<AssistantPhone>!$_"]) return @"assistant";
    if ([propConst isEqualToString:@"_$!<Brother>!$_"]) return @"brother";
    if ([propConst isEqualToString:@"_$!<Car>!$_"]) return @"car";
    if ([propConst isEqualToString:@"_$!<Child>!$_"]) return @"child";
    if ([propConst isEqualToString:@"_$!<CompanyMain>!$_"]) return @"company main";
    if ([propConst isEqualToString:@"_$!<Father>!$_"]) return @"father";
    if ([propConst isEqualToString:@"_$!<Friend>!$_"]) return @"friend";
    if ([propConst isEqualToString:@"_$!<Home>!$_"]) return @"home";
    if ([propConst isEqualToString:@"_$!<HomeFAX>!$_"]) return @"home fax";
    if ([propConst isEqualToString:@"_$!<HomePage>!$_"]) return @"home page";
    if ([propConst isEqualToString:@"_$!<Main>!$_"]) return @"main";
    if ([propConst isEqualToString:@"_$!<Manager>!$_"]) return @"manager";
    if ([propConst isEqualToString:@"_$!<Mobile>!$_"]) return @"mobile";
    if ([propConst isEqualToString:@"_$!<Mother>!$_"]) return @"mother";
    if ([propConst isEqualToString:@"_$!<Other>!$_"]) return @"other";
    if ([propConst isEqualToString:@"_$!<Pager>!$_"]) return @"pager";
    if ([propConst isEqualToString:@"_$!<Parent>!$_"]) return @"parent";
    if ([propConst isEqualToString:@"_$!<Partner>!$_"]) return @"partner";
    if ([propConst isEqualToString:@"_$!<Radio>!$_"]) return @"radio";
    if ([propConst isEqualToString:@"_$!<Sister>!$_"]) return @"sister";
    if ([propConst isEqualToString:@"_$!<Spouse>!$_"]) return @"spouse";
    if ([propConst isEqualToString:@"_$!<Work>!$_"]) return @"work";
    if ([propConst isEqualToString:@"_$!<WorkFAX>!$_"]) return @"work fax";
    return propConst;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
