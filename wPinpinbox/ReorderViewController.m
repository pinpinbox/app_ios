//
//  ReorderViewController.m
//  wPinpinbox
//
//  Created by David on 7/24/16.
//  Copyright © 2016 Angus. All rights reserved.
//

#import "ReorderViewController.h"
#import "wTools.h"
#import "boxAPI.h"
#import "CustomIOSAlertView.h"
#import "UIColor+Extensions.h"
#import "GlobalVars.h"
#import "AppDelegate.h"

#define kCellHeightForReorder 150
#define kViewHeightForReorder 568

@interface ReorderViewController ()

@property (weak, nonatomic) IBOutlet UIView *navBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBarHeight;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (nonatomic) UILongPressGestureRecognizer *longPress;

@property (nonatomic) NSMutableArray *labelArray;

@end

@implementation ReorderViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Register cell classes
    //[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    NSLog(@"ReorderViewController");
    NSLog(@"imageArray number: %lu", (unsigned long)_imageArray.count);
    //NSLog(@"imageArray: %@", _imageArray);
    
    //_backButton.transform = CGAffineTransformMakeRotation(-90.0 * M_PI / 180.0);
    self.backButton.layer.cornerRadius = 8;
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget: self action: @selector(handleLongGesture:)];
    lpgr.delegate = self;
    lpgr.delaysTouchesBegan = YES;
    [self.collectionView addGestureRecognizer: lpgr];
    self.collectionView.showsVerticalScrollIndicator = NO;
    //NSLog(@"self.imageArray: %@", self.imageArray);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.labelArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.imageArray.count; i++) {
        if (i == 0) {
            [self.labelArray addObject: [NSString stringWithFormat: NSLocalizedString(@"GeneralText-homePage", @"")]];
        } else if (i > 0) {
            [self.labelArray addObject: [NSString stringWithFormat: @"%d", i]];
        }
    }
    [self.collectionView reloadData];
}

- (void)viewDidLayoutSubviews {
    NSLog(@"viewDidLayoutSubviews");
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 1136:
                printf("iPhone 5 or 5S or 5C");
                break;
            case 1334:
                printf("iPhone 6/6S/7/8");
                break;
            case 1920:
                printf("iPhone 6+/6S+/7+/8+");
                break;
            case 2208:
                printf("iPhone 6+/6S+/7+/8+");
                break;
            case 2436:
                printf("iPhone X");
                self.navBarHeight.constant = 80;
                break;
            default:
                printf("unknown");
                break;
        }
    }
}

- (void)handleLongGesture: (UILongPressGestureRecognizer *)gestureRecognizer
{
    //NSLog(@"handleLongPress");
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            {
                NSIndexPath *selectedIndexPath = [self.collectionView indexPathForItemAtPoint: [gestureRecognizer locationInView: self.collectionView]];
                //UICollectionViewCell *cell = (UICollectionViewCell *)[self.collectionView cellForItemAtIndexPath: selectedIndexPath];
                [_collectionView beginInteractiveMovementForItemAtIndexPath: selectedIndexPath];
            }
            break;
        case UIGestureRecognizerStateChanged:
            [self.collectionView updateInteractiveMovementTargetPosition: [gestureRecognizer locationInView: gestureRecognizer.view]];
            break;
        case UIGestureRecognizerStateEnded:
            [self.collectionView endInteractiveMovement];
            break;
        default:
            [self.collectionView cancelInteractiveMovement];
            break;
    }
    
    /*
    CGPoint location = [gestureRecognizer locationInView: self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint: location];
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath: indexPath];
            UIView *snapshotView = [cell snapshotViewAfterScreenUpdates: YES];
            snapshotView.center = cell.center;
            [self.collectionView addSubview: snapshotView];
            cell.contentView.alpha = 0.0;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            
        }
            
        default:
            break;
    }
     */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)callBackButtonFunction
{
    [self back: nil];
}

- (IBAction)back:(id)sender {
    NSLog(@"back button pressed");
    
    // Only for presenting viewController in full screen
    //[self dismissViewControllerAnimated: YES completion: nil];
    
    // For Presenting as ChildViewController
//    [UIView animateWithDuration: 0.3 animations:^{
//        self.view.frame = CGRectMake(0, kViewHeightForReorder, 320, kCellHeightForReorder);
//    } completion:^(BOOL finished) {
//        [self.view removeFromSuperview];
//        [self removeFromParentViewController];
//    }];
    
    double delayInSeconds = 0.6;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector: @selector(reorderViewControllerDisappear:imageArray:)]) {
            [self.delegate reorderViewControllerDisappear: self imageArray: self.imageArray];
        }
    });
    
    [self callSortPhotoOfDiy];
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (void)callSortPhotoOfDiy
{
    NSMutableString *photoIdStr = [NSMutableString string];
    
    for (int i = 0; i < self.imageArray.count; i++) {
        if (i + 1 != self.imageArray.count) {
            [photoIdStr appendString: [NSString stringWithFormat: @"%@%@", self.imageArray[i][@"photo_id"], @","]];
        } else {
            [photoIdStr appendString: [NSString stringWithFormat: @"%@", self.imageArray[i][@"photo_id"]]];
        }
    }
    
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        NSString *response = [boxAPI sortPhotoOfDiy: [wTools getUserID]
                                              token: [wTools getUserToken]
                                           album_id: self.albumId
                                               sort: photoIdStr];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                [wTools HideMBProgressHUD];
            } @catch (NSException *exception) {
                // Print exception information
                NSLog( @"NSException caught" );
                NSLog( @"Name: %@", exception.name);
                NSLog( @"Reason: %@", exception.reason );
                return;
            }
            if (response != nil) {
                NSLog(@"response from sortPhotoOfDiy");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"ReorderViewController");
                    NSLog(@"callSortPhotoOfDiy");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"sortPhotoOfDiy"];
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                    
                    if ([dic[@"result"] intValue] == 1) {
                        NSLog(@"result is successful");
                        NSLog(@"dic: %@", dic);
                        
                        if ([self.delegate respondsToSelector: @selector(reorderViewControllerDisappearAfterCalling:)]) {
                            [self.delegate reorderViewControllerDisappearAfterCalling: self];
                        }
                    } else if ([dic[@"result"] intValue] == 0) {
                        NSLog(@"失敗：%@",dic[@"message"]);
                        [self showCustomErrorAlert: dic[@"message"]];
                    } else {
                        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            }
        });
    });
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    //NSLog(@"numberOfItemsInSection");
    
    return _imageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cellForItemAtIndexPath");
    
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: identifier
                                                                           forIndexPath: indexPath];
    // Configure the cell
    UIImageView *imageView = (UIImageView *)[cell viewWithTag: 100];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(queue, ^{
        NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString: _imageArray[indexPath.row][@"image_url_thumbnail"]]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = [UIImage imageWithData: data];
        });
    });
    
    NSLog(@"indexPath: %li", indexPath.item);
    
    // Set up the label text
    UILabel *lab = (UILabel *)[cell viewWithTag: 200];
    lab.text = self.labelArray[indexPath.row];
    
    /*
    if (indexPath.item == 0) {
        NSLog(@"indexPath.item == %ld", (long)indexPath.item);
        lab.text = NSLocalizedString(@"GeneralText-homePage", @"");
    } else if (indexPath.item >= 0) {
        NSLog(@"indexPath.item == %ld", (long)indexPath.item);
        lab.text = [NSString stringWithFormat: @"%li", indexPath.item];
    }
    */
    NSLog(@"lab.text: %@", lab.text);
    
    return cell;
}

#pragma mark - <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView
   moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath
           toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSLog(@"moveItemAtIndexPath");
    
    //NSIndexPath *selectedIndexPath = [self.collectionView indexPathForItemAtPoint: [_longPress locationInView: self.collectionView]];
    //UICollectionViewCell *cell = (UICollectionViewCell *)[self.collectionView cellForItemAtIndexPath: selectedIndexPath];
    
    NSLog(@"sourceIndexPath.item: %ld", (long)sourceIndexPath.item);
    NSLog(@"destinationIndexPath.item: %ld", (long)destinationIndexPath.item);
    
    NSDictionary *itemDic = self.imageArray[sourceIndexPath.item];
    [self.imageArray removeObjectAtIndex: sourceIndexPath.item];
    [self.imageArray insertObject: itemDic atIndex: destinationIndexPath.item];
    
    //[self.collectionView reloadData];
    
    //UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath: sourceIndexPath];
    //UILabel *lab = (UILabel *)[cell viewWithTag: 200];
    //lab.text = self.labelArray[destinationIndexPath.row];
    
    //[self.labelArray exchangeObjectAtIndex: sourceIndexPath.item withObjectAtIndex: destinationIndexPath.item];
    
    //[_imageArray exchangeObjectAtIndex: sourceIndexPath.item withObjectAtIndex: destinationIndexPath.item];
    //[self.collectionView reloadData];
    
    /*
    NSString *temp = _imageArray[sourceIndexPath.row][@"photo_id"];
    _imageArray[sourceIndexPath.row][@"photo_id"] = _imageArray[destinationIndexPath.row][@"photo_id"];
    _imageArray[destinationIndexPath.row][@"photo_id"] = temp;
    [self.collectionView reloadData];
     */
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectItemAtIndexPath");
    NSLog(@"indexPath.item: %ld", (long)indexPath.item);
}

- (void)collectionView:(UICollectionView *)collectionView
didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didHighlightItemAtIndexPath");
    NSLog(@"indexPath.item: %ld", (long)indexPath.item);
}

- (NSIndexPath *)collectionView:(UICollectionView *)collectionView
targetIndexPathForMoveFromItemAtIndexPath:(NSIndexPath *)originalIndexPath
            toProposedIndexPath:(NSIndexPath *)proposedIndexPath
{
    // Detect every single cell movement
    NSLog(@"targetIndexPathForMoveFromItemAtIndexPath");
    
    NSLog(@"originalIndexPath.item: %ld", (long)originalIndexPath.row);
    NSLog(@"proposedIndexPath.item: %ld", (long)proposedIndexPath.row);
    
    if (originalIndexPath.row != proposedIndexPath.row) {
        NSLog(@"item is not equal");
        NSLog(@"originalIndexPath.row: %ld", (long)originalIndexPath.row);
        NSLog(@"proposedIndexPath.row: %ld", (long)proposedIndexPath.row);
        
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray: self.labelArray];
        NSLog(@"tempArray: %@", tempArray);
        
        // Get the proposed cell first
        UICollectionViewCell *proposedCell = [self.collectionView cellForItemAtIndexPath: proposedIndexPath];
        UILabel *proposedLab = (UILabel *)[proposedCell viewWithTag: 200];
        // Put the original value to the proposed cell
        proposedLab.text = self.labelArray[originalIndexPath.row];
        
        NSString *proposedStr = self.labelArray[proposedIndexPath.row];
        
        NSLog(@"Before");
        NSLog(@"self.labelArray: %@", self.labelArray);
        
        if (proposedIndexPath.row > originalIndexPath.row) {
            NSLog(@"proposedIndexPath.row > originalIndexPath.row");
            for (NSInteger i = originalIndexPath.row; i < proposedIndexPath.row; i++) {
                int tempInt = [self.labelArray[i + 1] intValue];
                NSLog(@"tempInt: %d", tempInt);
                tempInt--;
                self.labelArray[i + 1] = [NSString stringWithFormat: @"%d", tempInt];
                NSLog(@"self.labelArray[i + 1]: %@", self.labelArray[i + 1]);
                
                UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath: [NSIndexPath indexPathForRow: i + 1 inSection: originalIndexPath.section]];
                NSLog(@"create cell");
                UILabel *lab = (UILabel *)[cell viewWithTag: 200];
                NSLog(@"create label");
                
                if ([self.labelArray[i + 1] isEqualToString: @"0"]) {
                    lab.text = NSLocalizedString(@"GeneralText-homePage", @"");
                } else {
                    lab.text = self.labelArray[i + 1];
                }
                
                NSLog(@"lab.text: %@", lab.text);
            }
        }
        
        if (originalIndexPath.row > proposedIndexPath.row) {
            NSLog(@"originalIndexPath.row > proposedIndexPath.row");
            for (NSInteger i = originalIndexPath.row; i > proposedIndexPath.row; i--) {
                int tempInt = [self.labelArray[i - 1] intValue];
                NSLog(@"tempInt: %d", tempInt);
                tempInt++;
                self.labelArray[i - 1] = [NSString stringWithFormat: @"%d", tempInt];
                NSLog(@"self.labelArray[i - 1]: %@", self.labelArray[i - 1]);
                
                UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath: [NSIndexPath indexPathForRow: i - 1 inSection: originalIndexPath.section]];
                NSLog(@"create cell");
                UILabel *lab = (UILabel *)[cell viewWithTag: 200];
                NSLog(@"create label");
                
                if ([self.labelArray[i - 1] isEqualToString: @"0"]) {
                    lab.text = NSLocalizedString(@"GeneralText-homePage", @"");
                } else {
                    lab.text = self.labelArray[i - 1];
                }
                lab.text = self.labelArray[i - 1];
                NSLog(@"lab.text: %@", lab.text);
            }
        }
        
        NSLog(@"After");
        NSLog(@"self.labelArray: %@", self.labelArray);
        
        self.labelArray = tempArray;
        NSLog(@"After Reseting");
        NSLog(@"self.labelArray: %@", self.labelArray);
        
        /*
        [self.labelArray removeObjectAtIndex: originalIndexPath.row];
        [self.labelArray insertObject: [NSNumber numberWithInteger: proposedIndexPath.row]
                              atIndex: proposedIndexPath.row];
        
        NSLog(@"After Removing & Inserting");
        NSLog(@"self.labelArray: %@", self.labelArray);
          */
        
        // Get the original cell first
        UICollectionViewCell *originalCell = [self.collectionView cellForItemAtIndexPath: originalIndexPath];
        UILabel *originalLab = (UILabel *)[originalCell viewWithTag: 200];
        // Put the proposed value to the cell
        //originalLab.text = self.labelArray[proposedIndexPath.row];
        originalLab.text = proposedStr;                
    }
    
    return proposedIndexPath;
}

#pragma mark - Custom Error Alert Method
- (void)showCustomErrorAlert: (NSString *)msg
{
    CustomIOSAlertView *errorAlertView = [[CustomIOSAlertView alloc] init];
    [errorAlertView setContainerView: [self createErrorContainerView: msg]];
    
    [errorAlertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    [errorAlertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    [errorAlertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    errorAlertView.arrangeStyle = @"Horizontal";
    
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

#pragma mark - Custom Method for TimeOut
- (void)showCustomTimeOutAlert: (NSString *)msg
                  protocolName: (NSString *)protocolName
{
    CustomIOSAlertView *alertTimeOutView = [[CustomIOSAlertView alloc] init];
    [alertTimeOutView setContainerView: [self createTimeOutContainerView: msg]];
    
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertTimeOutView.arrangeStyle = @"Horizontal";
    
    alertTimeOutView.parentView = self.view;
    [alertTimeOutView setButtonTitles: [NSMutableArray arrayWithObjects: NSLocalizedString(@"TimeOut-CancelBtnTitle", @""), NSLocalizedString(@"TimeOut-OKBtnTitle", @""), nil]];
    //[alertView setButtonTitles: [NSMutableArray arrayWithObjects: @"Close1", @"Close2", @"Close3", nil]];
    [alertTimeOutView setButtonColors: [NSMutableArray arrayWithObjects: [UIColor secondGrey], [UIColor firstMain],nil]];
    [alertTimeOutView setButtonTitlesColor: [NSMutableArray arrayWithObjects: [UIColor whiteColor], [UIColor whiteColor], nil]];
    [alertTimeOutView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObjects: [UIColor thirdMain], [UIColor darkMain], nil]];
    //alertView.arrangeStyle = @"Vertical";
    
    __weak typeof(self) weakSelf = self;
    __weak CustomIOSAlertView *weakAlertTimeOutView = alertTimeOutView;
    [alertTimeOutView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertTimeOutView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertTimeOutView tag]);
        
        [weakAlertTimeOutView close];
        
        if (buttonIndex == 0) {
            
        } else {                        
            if ([protocolName isEqualToString: @"sortPhotoOfDiy"]) {
                [weakSelf callSortPhotoOfDiy];
            }
        }
    }];
    [alertTimeOutView setUseMotionEffects: YES];
    [alertTimeOutView show];
}

- (UIView *)createTimeOutContainerView: (NSString *)msg
{
    // TextView Setting
    UITextView *textView = [[UITextView alloc] initWithFrame: CGRectMake(10, 30, 280, 20)];
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
    [imageView setImage:[UIImage imageNamed:@"icon_2_0_0_dialog_pinpin.png"]];
    
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
    //contentView.backgroundColor = [UIColor firstPink];
    contentView.backgroundColor = [UIColor firstMain];
    
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
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
