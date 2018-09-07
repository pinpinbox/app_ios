//
//  ExistingAlbumViewController.m
//  wPinpinbox
//
//  Created by vmage on 9/2/16.
//  Copyright © 2016 Angus. All rights reserved.
//

#import "ExistingAlbumViewController.h"
#import "CustomIOSAlertView.h"
#import "OldCustomAlertView.h"
#import "wTools.h"
#import "boxAPI.h"
#import "AsyncImageView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIColor+Extensions.h"

@interface ExistingAlbumViewController () {
    NSMutableArray *existedAlbumArray;
    __weak IBOutlet UICollectionView *myCollectionView;
    
    NSString *albumId;
    NSString *coverImage;
    NSString *descriptionText;
    NSString *nameForAlbum;
    
    NSMutableArray *checkPostArray;    
    NSString *postDescription;
    
    UICollectionViewCell *cellForPost;
    UIImageView *imgForPost;
    UIImageView *tickImageView;
}
@end

@implementation ExistingAlbumViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"ExistingAlbumViewController");
    
    [self getExistedAlbum];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //NSLog(@"existedAlbumArray: %@", _existedAlbumArray);
    checkPostArray = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated: YES];
}

#pragma mark -
#pragma Protocol Methods

- (void)getExistedAlbum
{
    NSLog(@"getExistedAlbum");
    
    existedAlbumArray = [[NSMutableArray alloc] init];
    
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
                
                if ([dic[@"result"] intValue] == 1) {
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
                                    
                                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                                    [dict setValue: array[i][@"album"][@"album_id"] forKey: @"albumId"];
                                    [dict setValue: array[i][@"album"][@"cover"] forKey: @"cover"];
                                    [dict setValue: array[i][@"album"][@"description"] forKey: @"description"];
                                    [dict setValue: array[i][@"album"][@"name"] forKey: @"name"];
                                    
                                    NSArray *eventArray = [[NSArray alloc] init];
                                    eventArray = array[i][@"event"];
                                    
                                    NSMutableArray *eventArrayData = [[NSMutableArray alloc] init];
                                    
                                    for (int k = 0; k < eventArray.count; k++) {
                                        [eventArrayData addObject: array[i][@"event"][k]];
                                        NSLog(@"eventArrayData: %@", eventArrayData);
                                    }
                                    
                                    [dict setValue: eventArrayData forKey: @"eventArrayData"];
                                    
                                    [existedAlbumArray addObject: dict];
                                }
                            }
                        }
                    }
                    NSLog(@"existedAlbumArray: %@", existedAlbumArray);
                    [myCollectionView reloadData];
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

- (void)postAlbum {
    [wTools ShowMBProgressHUD];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = [boxAPI switchstatusofcontribution: [wTools getUserID] token: [wTools getUserToken] event_id: _eventId album_id: albumId];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
            if (response != nil) {
                NSLog(@"%@", response);
                
                NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                if ([dic[@"result"] intValue] == 1) {
                    NSLog(@"post album success");
                    int contributionCheck = [dic[@"data"][@"event"][@"contributionstatus"] boolValue];
                    NSLog(@"contributionCheck: %d", contributionCheck);
                    
                    if (contributionCheck) {
                        [self addImageOnCell: cellForPost imageView: imgForPost];
                    } else {
                        [self removeImageOnCell: cellForPost];
                    }
                } else if ([dic[@"result"] intValue] == 0) {
                    NSLog(@"message: %@", dic[@"message"]);
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"" message: dic[@"message"] preferredStyle: UIAlertControllerStyleAlert];
                    UIAlertAction *okBtn = [UIAlertAction actionWithTitle: @"OK" style: UIAlertActionStyleDefault handler: nil];
                    [alert addAction: okBtn];
                    [self presentViewController: alert animated: YES completion: nil];
                } else {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"" message: NSLocalizedString(@"Host-NotAvailable", @"") preferredStyle: UIAlertControllerStyleAlert];
                    UIAlertAction *okBtn = [UIAlertAction actionWithTitle: @"OK" style: UIAlertActionStyleDefault handler: nil];
                    [alert addAction: okBtn];
                    [self presentViewController: alert animated: YES completion: nil];
                }
            }
        });
    });
}

#pragma mark -
#pragma Collection Delegate & Data Source Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"existedAlbumArray.count: %lu", (unsigned long)existedAlbumArray.count);
    return existedAlbumArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: identifier
                                                                           forIndexPath: indexPath];
    
    // Configure the cell
    //UIImageView *imageView = (UIImageView *)[cell viewWithTag: 100];
    //NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString: existedAlbumArray[indexPath.row][@"cover"]]];
    //imageView.image = [UIImage imageWithData: data];
    
    NSDictionary *data = existedAlbumArray[indexPath.row];
    
    //AsyncImageView *img = (AsyncImageView *)[cell viewWithTag: 100];
    UIImageView *img = (UIImageView *)[cell viewWithTag: 100];
    img.imageURL = nil;
    img.image = nil;
    img.contentMode = UIViewContentModeScaleAspectFit;
    //img.image = [UIImage imageNamed: @"123"];
    
    imgForPost = img;
    cellForPost = cell;
    
    if (![data[@"cover"] isKindOfClass: [NSNull class]]) {
        //[[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: img];
        //img.imageURL = [NSURL URLWithString: data[@"cover"]];
        [img sd_setImageWithURL: [NSURL URLWithString: data[@"cover"]]];
    } else {
        img.image = [UIImage imageNamed: @"bg200_no_image.jpg"];
    }
    
    UILabel *lab = (UILabel *)[cell viewWithTag: 200];
    lab.text = existedAlbumArray[indexPath.row][@"name"];
    lab.adjustsFontSizeToFitWidth = YES;
    
    NSLog(@"cellForItemAtIndexPath");
    NSLog(@"data: %@", data);
    
    NSArray *eventArrayData = data[@"eventArrayData"];
    NSString *checkPost;
    
    for (int i = 0; i < eventArrayData.count; i++) {
        NSString *albumEventId = eventArrayData[i][@"event_id"];
        
        NSString *contribution = eventArrayData[i][@"contributionstatus"];
        NSLog(@"contribution: %@", contribution);
        
        NSLog(@"albumEventId: %@", albumEventId);
        NSLog(@"eventId: %@", _eventId);
        
        if ([albumEventId intValue] == [_eventId intValue]) {
            NSLog(@"eventId is the same");
            
            if ([contribution intValue] == 1) {
                NSLog(@"contribution is 1");
                checkPost = @"1";
                
                NSLog(@"checkPost: %@", checkPost);
            } else {
                checkPost = @"0";
                NSLog(@"contribution is 0");
            }
        }
    }
    NSLog(@"checkPost: %@", checkPost);
    checkPostArray[indexPath.row] = checkPost;
    
    if ([checkPost intValue] == 1) {
        [self addImageOnCell: cell imageView: img];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *data = existedAlbumArray[indexPath.row];
    NSLog(@"data: %@", data);
    
    albumId = data[@"albumId"];
    coverImage = data[@"cover"];
    descriptionText = data[@"description"];
    nameForAlbum = data[@"name"];
    
    NSString *checkPost = checkPostArray[indexPath.row];
    
    cellForPost = [collectionView cellForItemAtIndexPath: indexPath];
    
    [self showAlertView: checkPost cell: cellForPost img: imgForPost];
}

#pragma mark -

- (void)showAlertView: (NSString *)checkPost cell: (UICollectionViewCell *)cell img: (UIImageView *)imageView
{
    OldCustomAlertView *alertView = [[OldCustomAlertView alloc] init];
    [alertView setContainerView: [self createView: checkPost]];
    [alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"取消", @"確定", nil]];
    [alertView setOnButtonTouchUpInside:^(OldCustomAlertView *alertView, int buttonIndex) {
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

- (UIView *)createView: (NSString *)checkPost
{
    UIView *view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 300, 300)];
    UIView *bgView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 300, 200)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 10, bgView.bounds.size.width / 2, bgView.bounds.size.height)];
    imageView.image = [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString: coverImage]]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    NSString *albumName = @"作品名稱";
    NSString *albumDescription = @"作品介紹";
    
    UITextView *textView = [[UITextView alloc] init];
    textView.font = [UIFont fontWithName: @"TrebuchetMS-Bold" size: 15.0f];
    textView.textColor = [UIColor grayColor];
    textView.backgroundColor = [UIColor whiteColor];
    textView.frame = CGRectMake(145, 10, bgView.bounds.size.width / 2, bgView.bounds.size.height);
    textView.text = [NSString stringWithFormat: @"%@:\n%@\n\n\n%@:\n%@", albumName, nameForAlbum, albumDescription, descriptionText];
    
    [bgView addSubview: imageView];
    [bgView addSubview: textView];
    
    UILabel *postLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, view.bounds.size.height / 2 + 90,  view.bounds.size.width, 30)];
    
    if ([checkPost intValue] == 1) {
        postLabel.textColor = [UIColor redColor];
        postDescription = @"此作品已投稿，是否重新選擇? (若取消，則該作品的投票數亦會取消)";
    } else {
        postLabel.textColor = [UIColor blackColor];
        postDescription = @"確定投稿此作品?";
    }
    
    postLabel.text = postDescription;
    postLabel.textAlignment = NSTextAlignmentCenter;
    postLabel.numberOfLines = 0;
    postLabel.adjustsFontSizeToFitWidth = YES;
    
    [view addSubview: postLabel];
    [view addSubview: bgView];
    
    return view;
}

- (void)addImageOnCell: (UICollectionViewCell *)cell imageView: (UIImageView *)img
{
    NSLog(@"addImageOnCell");
    
    UIView *maskView = (UIView *)[cell viewWithTag: 300];
    maskView.alpha = 0.7;
    
    tickImageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 40, 40)];
    //imageView.image = [UIImage imageNamed: @"icon_selectcontribute_white_60x60.png"];
    tickImageView.image = [UIImage imageNamed: @"icon_selectcontribute_white_60x60"];
    tickImageView.center = CGPointMake(img.bounds.size.width / 2, img.bounds.size.height / 2);
    tickImageView.tag = 123;
    [cell.contentView addSubview: tickImageView];
}

- (void)removeImageOnCell: (UICollectionViewCell *)cell
{
    NSLog(@"removeImageOnCell");
    
    UIView *maskView = (UIView *)[cell viewWithTag: 300];
    maskView.alpha = 0;
    
    [[cell.contentView viewWithTag: 123] removeFromSuperview];
}

#pragma mark - Collection view layout things
// Layout: Set cell size
/*
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"SETTING SIZE FOR ITEM AT INDEX %d", indexPath.row);
    CGSize mElementSize = CGSizeMake(104, 104);
    return mElementSize;
}
 */

/*
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionView *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1.0; // This is the minimum inter item spacing, can be more
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 2.0;
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

#pragma mark - Custom Error Alert Method
- (void)showCustomErrorAlert: (NSString *)msg {
    CustomIOSAlertView *errorAlertView = [[CustomIOSAlertView alloc] init];
    //[errorAlertView setContainerView: [self createErrorContainerView: msg]];
    [errorAlertView setContentViewWithMsg:msg contentBackgroundColor:[UIColor firstPink] badgeName:nil];
    [errorAlertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    [errorAlertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    [errorAlertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondPink]]];
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
