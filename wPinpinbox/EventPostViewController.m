//
//  EventPostViewController.m
//  wPinpinbox
//
//  Created by vmage on 8/29/16.
//  Copyright © 2016 Angus. All rights reserved.
//

#import "EventPostViewController.h"

#import <SafariServices/SafariServices.h>
#import "CustomIOSAlertView.h"
#import "Setup2ViewController.h"
#import "ExistingAlbumViewController.h"
#import "wTools.h"
#import "boxAPI.h"

#import "FastViewController.h"
#import "UIColor+Extensions.m"

#define kFontSize 18

@interface EventPostViewController ()
{
    Setup2ViewController *s2VC;
    CustomIOSAlertView *alertViewForButton;
    NSMutableDictionary *dict;
    BOOL checkPost;
    
    NSMutableArray *existedAlbumArray;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *navBar;

@end

@implementation EventPostViewController

#pragma mark -
#pragma View Launching Related Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    NSLog(@"imageName: %@", _imageName);
    
    self.navBar.backgroundColor = [UIColor barColor];
    
    self.imageView.image = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString: _imageName]]];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    NSLog(@"w: %f h: %f", self.imageView.bounds.size.width, self.imageView.bounds.size.height);
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    NSLog(@"screenWidth: %f screenHeight: %f", screenWidth, screenHeight);
    
    // NavigationBar Text Setup
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:18 weight:UIFontWeightLight], NSForegroundColorAttributeName: [UIColor whiteColor]};
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

#pragma mark -
#pragma mark IBAction Methods

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated: YES];
}

- (IBAction)toActivity:(id)sender {
    
    NSURL *url = [NSURL URLWithString: _urlString];
    
    /*
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL: url entersReaderIfAvailable: NO];
    [self presentViewController: safariVC animated: YES completion: nil];
     */
    
    [[UIApplication sharedApplication] openURL: url];
}

- (IBAction)postAlbum:(id)sender {
    NSLog(@"postAlbum");
    NSLog(@"self.eventFinished: %d", self.eventFinished);
    
    if (!_eventFinished) {
        //[self showPostMode];
        [self getExistedAlbum];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"" message: @"活動結束" preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction *okBtn = [UIAlertAction actionWithTitle: @"OK" style: UIAlertActionStyleDefault handler: nil];
        [alert addAction: okBtn];
        [self presentViewController: alert animated: YES completion: nil];
    }
}

- (void)getExistedAlbum
{
    NSLog(@"getExistedAlbum");
    
    existedAlbumArray = [[NSMutableArray alloc] init];
    
    [wTools ShowMBProgressHUD];
    
    //NSInteger *nextId = 0;
    //NSString *limit = [NSString stringWithFormat: @"%ld, %ld",(long)nextId, (long)nextId + 10];
    NSString *limit = [NSString stringWithFormat: @"%d, %d", 0, 10000];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI getcalbumlist: [wTools getUserID] token: [wTools getUserToken] rank: @"mine" limit: limit];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"response from getcalbumlist: %@", response);
                
                NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                if ([dic[@"result"] boolValue]) {
                    NSArray *array = dic[@"data"];
                    NSLog(@"array: %@", array);
                    NSLog(@"array.count: %lu", (unsigned long)array.count);
                    
                    for (int i = 0; i < array.count; i++) {
                        NSLog(@"array template: %@", array[i][@"template"][@"template_id"]);
                        
                        NSString *act = array[i][@"album"][@"act"];
                        NSLog(@"act: %@", act);
                        
                        if ([act isEqualToString: @"open"]) {
                            for (int j = 0; j < _templateArray.count; j++) {
                                NSLog(@"templateArray: %@", [_templateArray[j] stringValue]);
                                NSLog(@"array[i] template template_id: %@", array[i][@"template"][@"template_id"]);
                                
                                NSString *currentTemplateId = [array[i][@"template"][@"template_id"] stringValue];
                                
                                if ([currentTemplateId isEqualToString: [_templateArray[j] stringValue]]) {
                                    NSLog(@"same template");
                                    
                                    NSLog(@"array[i]: %@", array[i]);
                                    
                                    NSMutableDictionary *dict1 = [[NSMutableDictionary alloc] init];
                                    [dict1 setValue: array[i][@"album"][@"album_id"] forKey: @"albumId"];
                                    [dict1 setValue: array[i][@"album"][@"cover"] forKey: @"cover"];
                                    [dict1 setValue: array[i][@"album"][@"description"] forKey: @"description"];
                                    [dict1 setValue: array[i][@"album"][@"name"] forKey: @"name"];
                                    
                                    NSArray *eventArray = [[NSArray alloc] init];
                                    eventArray = array[i][@"event"];
                                    
                                    NSMutableArray *eventArrayData = [[NSMutableArray alloc] init];
                                    
                                    for (int k = 0; k < eventArray.count; k++) {
                                        [eventArrayData addObject: array[i][@"event"][k]];
                                        NSLog(@"eventArrayData: %@", eventArrayData);
                                    }
                                    
                                    [dict1 setValue: eventArrayData forKey: @"eventArrayData"];
                                    
                                    [existedAlbumArray addObject: dict1];
                                }
                            }
                        }
                    }
                    NSLog(@"existedAlbumArray: %@", existedAlbumArray);
                    
                    if (existedAlbumArray.count == 0) {
                        NSLog(@"existedAlbumArray.count: %lu", (unsigned long)existedAlbumArray.count);
                        //s2VC = [[Setup2ViewController alloc] initWithNibName: @"Setup2ViewController" bundle: nil];
                        s2VC = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"Setup2ViewController"];
                        s2VC.rank = @"hot";
                        s2VC.event_id = _eventId;
                        s2VC.title = @"選 擇 版 型";
                        s2VC.postMode = YES;
                        
                        checkPost = NO;
                        
                        [self.navigationController pushViewController: s2VC animated: YES];
                    } else {
                        NSLog(@"existedAlbumArray.count: %lu", (unsigned long)existedAlbumArray.count);
                        [self showPostMode];
                    }
                    
                    //[myCollectionView reloadData];
                    
                } else {
                    
                }
            }
        });
    });
}

#pragma mark -
#pragma mark Custom AlertView

- (void)showPostMode
{
    NSLog(@"showPostMode");
    
    // Custom AlertView shows up when getting the point
    alertViewForButton = [[CustomIOSAlertView alloc] init];
    [alertViewForButton setContainerView: [self createView]];
    [alertViewForButton setButtonTitles: [NSMutableArray arrayWithObject: @"確     認"]];
    [alertViewForButton setUseMotionEffects: true];
    
    [alertViewForButton show];
}

- (UIView *)createView
{
    // Parent View
    UIView *buttonView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 250, 220)];
    
    // Topic Label View
    UILabel *topicLabel = [[UILabel alloc] initWithFrame: CGRectMake(25, 25, 200, 10)];
    topicLabel.text = @"請選擇投稿方式";
    topicLabel.textAlignment = NSTextAlignmentCenter;
    
    // 1st UIButton View
    UIButton *buttonNew = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [buttonNew addTarget: self action: @selector(createNewAlbum) forControlEvents: UIControlEventTouchUpInside];
    [buttonNew setTitle: @"建立新作品" forState: UIControlStateNormal];
    buttonNew.titleLabel.font = [UIFont systemFontOfSize: kFontSize];
    buttonNew.frame = CGRectMake(25, 65, 200, 50);
    [buttonNew setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    buttonNew.backgroundColor = [UIColor colorWithRed: 32.0/255.0 green: 191.0/255.0 blue: 193.0/255.0 alpha: 1.0];
    buttonNew.layer.cornerRadius = 10;
    buttonNew.clipsToBounds = YES;
    
    // 2nd UIButton View
    UIButton *buttonOld = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [buttonOld addTarget: self action: @selector(chooseOldAlbum) forControlEvents: UIControlEventTouchUpInside];
    [buttonOld setTitle: @"選擇現有作品" forState: UIControlStateNormal];
    buttonNew.titleLabel.font = [UIFont systemFontOfSize: kFontSize];
    buttonOld.frame = CGRectMake(25, 150, 200, 50);
    [buttonOld setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    buttonOld.backgroundColor = [UIColor colorWithRed: 32.0/255.0 green: 191.0/255.0 blue: 193.0/255.0 alpha: 1.0];
    buttonOld.layer.cornerRadius = 10;
    buttonOld.clipsToBounds = YES;
    
    [buttonView addSubview: topicLabel];
    [buttonView addSubview: buttonNew];
    [buttonView addSubview: buttonOld];
    
    return buttonView;
}

#pragma mark -

- (void)createNewAlbum
{
    [alertViewForButton close];
    
    //s2VC = [[Setup2ViewController alloc] initWithNibName: @"Setup2ViewController" bundle: nil];
    s2VC = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"Setup2ViewController"];
    s2VC.rank = @"hot";
    s2VC.event_id = _eventId;
    s2VC.title = @"選 擇 版 型";
    s2VC.postMode = YES;
    
    checkPost = NO;
    
    [self checkPostedAlbum];
}

- (void)chooseOldAlbum
{
    [alertViewForButton close];
    
    ExistingAlbumViewController *existVC = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"ExistingAlbumViewController"];
    
    existVC.templateArray = _templateArray;
    existVC.eventId = _eventId;
    
    [self.navigationController pushViewController: existVC animated: YES];
}

#pragma mark -
#pragma mark Calling API Methods

- (void)checkPostedAlbum
{
    [wTools ShowMBProgressHUD];
    
    //NSInteger *nextId = 0;
    //NSString *limit = [NSString stringWithFormat: @"%ld, %ld",(long)nextId, (long)nextId + 10];
    NSString *limit = [NSString stringWithFormat: @"%d, %d", 0, 10000];;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI getcalbumlist: [wTools getUserID] token: [wTools getUserToken] rank: @"mine" limit: limit];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"album response");
                NSLog(@"%@", response);
                
                NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                if ([dic[@"result"] boolValue]) {
                    
                    NSArray *array = dic[@"data"];
                    NSLog(@"array.count: %lu", (unsigned long)array.count);
                    
                    NSLog(@"dic data: %@", array);
                    
                    for (int i = 0; i < array.count; i++) {
                        NSString *act = array[i][@"album"][@"act"];
                        
                        if ([act isEqualToString: @"open"]) {
                            NSLog(@"array: %@", array[i]);
                            
                            NSArray *eventArray = [[NSArray alloc] init];
                            eventArray = array[i][@"event"];
                            
                            for (int k = 0; k < eventArray.count; k++) {
                                
                                BOOL contributionStatus = [array[i][@"event"][k][@"contributionstatus"] boolValue];
                                NSString *eventIdCheck = array[i][@"event"][k][@"event_id"];
                                NSLog(@"contributionStatus: %d", contributionStatus);
                                
                                if ([eventIdCheck intValue] == [_eventId intValue]) {
                                    
                                    NSLog(@"match eventId");
                                    
                                    if (contributionStatus) {
                                        NSLog(@"joined post activity already");
                                        NSLog(@"contributionStatus: %d", contributionStatus);
                                        
                                        checkPost = YES;
                                        
                                        dict = [[NSMutableDictionary alloc] init];
                                        [dict setValue: array[i][@"album"][@"album_id"] forKey: @"albumId"];
                                        [dict setValue: array[i][@"album"][@"cover"] forKey: @"cover"];
                                        [dict setValue: array[i][@"album"][@"description"] forKey: @"description"];
                                        [dict setValue: array[i][@"album"][@"name"] forKey: @"name"];
                                        
                                        NSLog(@"match eventId, posted already, dict:%@", dict);
                                    }
                                }
                            }
                        }
                    }
                    
                    if (checkPost) {
                        [self showPostedInfo];
                    } else {
                        
                        NSNumber *eventTemplateId = [self.templateArray objectAtIndex: 0];
                        
                        // Because the return value of element of Array is int
                        if ([eventTemplateId intValue] == 0) {
                            [self addNewFastMod];
                        } else {
                            [self.navigationController pushViewController: s2VC animated: YES];
                        }
                    }
                    
                } else {
                    
                }
            }
        });
    });
}

- (void)showPostedInfo
{
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    [alertView setContainerView: [self createViewForPost]];
    [alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"取消", @"確定", nil]];
    [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
        [alertView close];
        
        if (buttonIndex == 0) {
            
        } else if (buttonIndex == 1) {
            NSLog(@"Yes");
            [self postAlbum];
        }
    }];
    [alertView setUseMotionEffects: true];
    [alertView show];
}

- (UIView *)createViewForPost
{
    UIView *view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 300, 300)];
    UIView *bgView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 300, 200)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 10, bgView.bounds.size.width / 2, bgView.bounds.size.height)];
    imageView.image = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString: [dict valueForKey: @"cover"]]]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    NSString *albumName = @"作品名稱";
    NSString *albumDescription = @"作品介紹";
    
    UITextView *textView = [[UITextView alloc] init];
    textView.font = [UIFont fontWithName: @"TrebuchetMS-Bold" size: 15.0f];
    textView.textColor = [UIColor grayColor];
    textView.backgroundColor = [UIColor whiteColor];
    textView.frame = CGRectMake(145, 10, bgView.bounds.size.width / 2, bgView.bounds.size.height);
    textView.text = [NSString stringWithFormat: @"%@:\n%@\n\n\n%@:\n%@", albumName, [dict valueForKey: @"name"], albumDescription, [dict valueForKey: @"description"]];
    textView.userInteractionEnabled = NO;
    
    [bgView addSubview: imageView];
    [bgView addSubview: textView];
    
    UILabel *postLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, view.bounds.size.height / 2 + 90,  view.bounds.size.width, 30)];
    postLabel.textColor = [UIColor redColor];
    postLabel.text = @"投稿作品數量已達上限，是否確認撤下該作品並建立新作品？（若確定，則原作品的投票數將會歸零）";;
    postLabel.textAlignment = NSTextAlignmentCenter;
    postLabel.numberOfLines = 0;
    postLabel.adjustsFontSizeToFitWidth = YES;
    
    [view addSubview: postLabel];
    [view addSubview: bgView];
    
    return view;
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
            
            if (respone != nil) {
                NSLog(@"response from insertalbumofdiy: %@",respone);
                
                NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[respone dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                
                if ([dic[@"result"]boolValue]) {
                    
                    NSString *tempalbum_id = [dic[@"data"] stringValue];
                    
                    //FastViewController *fVC = [[UIStoryboard storyboardWithName: @"Fast" bundle: nil] instantiateViewControllerWithIdentifier: @"FastViewController"];
                    FastViewController *fVC = [[UIStoryboard storyboardWithName: @"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"FastViewController"];
                    fVC.selectrow = [wTools userbook];
                    fVC.albumid = tempalbum_id;
                    fVC.templateid = @"0";
                    fVC.choice = @"Fast";
                    
                    fVC.postMode = YES;
                    fVC.event_id = self.eventId;
                    fVC.fromEventPostVC = YES;
                    
                    [self.navigationController pushViewController: fVC animated: YES];
                    
                }else{
                    
                }
            }
        });
    });
}

- (void)postAlbum
{
    NSLog(@"postAlbum");
    
    [wTools ShowMBProgressHUD];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI switchstatusofcontribution: [wTools getUserID] token: [wTools getUserToken] event_id: _eventId album_id: [dict valueForKey: @"albumId"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"%@", response);
                
                NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                if ([dic[@"result"] boolValue]) {
                    NSLog(@"post album success");
                    
                    int contributionCheck = [dic[@"data"][@"event"][@"contributionstatus"] boolValue];
                    
                    NSLog(@"contributionCheck: %d", contributionCheck);
                    
                    if (checkPost) {
                        //[self.navigationController pushViewController: s2VC animated: YES];
                        NSNumber *eventTemplateId = [self.templateArray objectAtIndex: 0];
                        
                        // Because the return value of element of Array is int
                        if ([eventTemplateId intValue] == 0) {
                            [self addNewFastMod];
                        } else {
                            [self.navigationController pushViewController: s2VC animated: YES];
                        }
                    }
                    
                } else {
                    NSLog(@"message: %@", dic[@"message"]);
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"" message: dic[@"message"] preferredStyle: UIAlertControllerStyleAlert];
                    UIAlertAction *okBtn = [UIAlertAction actionWithTitle: @"OK" style: UIAlertActionStyleDefault handler: nil];
                    [alert addAction: okBtn];
                    [self presentViewController: alert animated: YES completion: nil];
                }
            }
        });
    });
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
