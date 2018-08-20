//
//  NewMessageBoardViewController.m
//  wPinpinbox
//
//  Created by David on 6/7/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "NewMessageBoardViewController.h"
#import "AsyncImageView.h"
#import "boxAPI.h"
#import "wTools.h"
#import "MyLinearLayout.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "UIColor+Extensions.h"
#import "NewMessageTableViewCell.h"
#import "UIView+Toast.h"
#import "CustomIOSAlertView.h"
#import "GlobalVars.h"
#import "AppDelegate.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface NewMessageBoardViewController () <UITextViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    UITextView *selectTextView;
    UILabel *placeHolderInputLabel;
    
    BOOL isLoading;
    
    NSInteger nextId;
    NSMutableArray *messageArray;
    NSMutableArray *rowHeightArray;
    
    NSString *tempStr;
}

@property (weak, nonatomic) IBOutlet MyLinearLayout *firstBgView;
@property (weak, nonatomic) IBOutlet UILabel *topicLabel;
@property (weak, nonatomic) IBOutlet UIButton *exitBtn;

@property (weak, nonatomic) IBOutlet MyLinearLayout *secondBgView;
@property (weak, nonatomic) IBOutlet AsyncImageView *userImageView;
@property (weak, nonatomic) IBOutlet UITextView *inputTextView;

@property (weak, nonatomic) IBOutlet MyLinearLayout *thirdBgView;
@property (weak, nonatomic) IBOutlet UIButton *sendMsgBtn;
@property (weak, nonatomic) IBOutlet UIButton *clearMsgBtn;

@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation NewMessageBoardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent: 0.6];
    [self initialValueSetup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getMessage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Controller Rotation
- (void)viewWillLayoutSubviews {
    NSLog(@"viewWillLayoutSubviews");
}

- (void)checkDeviceOrientation {
    NSLog(@"----------------------");
    NSLog(@"checkDeviceOrientation");
    
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
        NSLog(@"UIDeviceOrientationIsPortrait");
    }
    
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        NSLog(@"UIDeviceOrientationIsLandscape");
    }
}

#pragma mark - IBAction Methods
- (IBAction)exitBtnPress:(id)sender {
    NSLog(@"exitBtnPress");
    NSLog(@"messageArray.count: %lu", (unsigned long)messageArray.count);
    
    if ([self.delegate respondsToSelector: @selector(newMessageBoardViewControllerDisappear:msgNumber:)]) {
        [self.delegate newMessageBoardViewControllerDisappear: self msgNumber: messageArray.count];
    }
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (IBAction)clearBtnPress:(id)sender {
    self.inputTextView.text = @"";
    placeHolderInputLabel.alpha = 1;
}

- (IBAction)sendMsgBtnPress:(id)sender {
    NSLog(@"sendMsgBtnPress");
    NSLog(@"self.inputTextView.text: %@", self.inputTextView.text);
    NSLog(@"tempStr: %@", tempStr);
    
    NSUInteger length;
    length = self.inputTextView.text.length;
    
    NSLog(@"length: %lu", (unsigned long)length);
    
    if (![self.inputTextView.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]].length) {
        NSLog(@"string is all whitespace or newline");
        
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor firstGrey];
        
        [self.view.superview makeToast: @"不能發送空白訊息"
                         duration: 2.0
                         position: CSToastPositionBottom
                            style: style];
    } else if ([self.inputTextView.text isEqualToString: tempStr]) {
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor firstGrey];
        
        [self.view.superview makeToast: @"不可連續發送"
                         duration: 2.0
                         position: CSToastPositionBottom
                            style: style];
    } else {
        [self insertMessage: self.inputTextView.text];
    }
    // tempStr is to check the message is the same or not
    // to avoid the button being press in a short time.
    tempStr = self.inputTextView.text;
    
    self.inputTextView.text = @"";
    placeHolderInputLabel.alpha = 1;
    [self.view endEditing: YES];
}

#pragma mark -

- (void)initialValueSetup {
    NSLog(@"initialValueSetup");
    
    nextId = 0;
    isLoading = NO;
    messageArray = [NSMutableArray new];
    rowHeightArray = [NSMutableArray new];
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleTap)];
    [self.view addGestureRecognizer: tapGR];
    
    self.view.clipsToBounds = YES;
    self.view.layer.cornerRadius = 16;
    //self.view.backgroundColor = [UIColor colorWithWhite: 1.0 alpha:0.5];
    //self.view.myHeight = 300;
    
    // Setting BgView
    // 1st BgView
//    self.firstBgView.backgroundColor = [UIColor greenColor];
    self.firstBgView.padding = UIEdgeInsetsMake(0, 16, 0, 16);
    self.firstBgView.myLeftMargin = 0;
    self.firstBgView.myRightMargin = 0;
    self.firstBgView.myTopMargin = 40;
    self.firstBgView.myBottomMargin = 16;
    
    self.topicLabel.myRightMargin = 0.5;
    
    self.exitBtn.myLeftMargin = 0.5;
    self.exitBtn.layer.cornerRadius = kCornerRadius;
    [self.exitBtn addTarget: self action: @selector(exitBtnHighLight:) forControlEvents: UIControlEventTouchDown];
    [self.exitBtn addTarget: self action: @selector(exitBtnNormal:) forControlEvents: UIControlEventTouchUpInside];
    [self.exitBtn addTarget: self action: @selector(exitBtnNormal:) forControlEvents: UIControlEventTouchUpOutside];
    
    // 2nd BgView
//    self.secondBgView.backgroundColor = [UIColor greenColor];
    self.secondBgView.padding = UIEdgeInsetsMake(0, 16, 0, 16);
    self.secondBgView.myLeftMargin = 0;
    self.secondBgView.myRightMargin = 0;
    self.secondBgView.myTopMargin = 16;
    self.secondBgView.myBottomMargin = 8;
    
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [userPrefs objectForKey: @"profile"];
    
    self.userImageView.layer.cornerRadius = self.userImageView.bounds.size.width / 2;
    self.userImageView.myRightMargin = 8;
    
    NSString *profilePic = dic[@"profilepic"];
    NSLog(@"profilePic: %@", profilePic);
    
    if ([profilePic isEqual: [NSNull null]]) {
        NSLog(@"profilePic is equal to null");
        self.userImageView.image = [UIImage imageNamed: @"member_back_head.png"];
    } else if ([profilePic isEqualToString: @""]) {
        self.userImageView.image = [UIImage imageNamed: @"member_back_head.png"];
    } else {
        self.userImageView.imageURL = [NSURL URLWithString: profilePic];
    }
    
    self.userImageView.imageURL = [NSURL URLWithString: dic[@"profilepic"]];
    
    // Text Input Section
    self.inputTextView.layer.cornerRadius = kCornerRadius;
    self.inputTextView.backgroundColor = [UIColor thirdGrey];
    self.inputTextView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self.inputTextView.textColor = [UIColor firstGrey];
    self.inputTextView.weight = 1;
    
    /*
    UIToolbar *toolBarForDoneBtn = [[UIToolbar alloc] initWithFrame: CGRectMake(0, 0, 320, 40)];
    toolBarForDoneBtn.barStyle = UIBarStyleDefault;
    toolBarForDoneBtn.items = [NSArray arrayWithObjects:
                               //[[UIBarButtonItem alloc] initWithTitle: @"取消" style: UIBarButtonItemStylePlain target: self action: @selector(cancelNumberPad)],
                               [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil],
                               [[UIBarButtonItem alloc] initWithTitle: @"完成" style: UIBarButtonItemStyleDone target: self action: @selector(dismissKeyboard)], nil];
    
    self.inputTextView.inputAccessoryView = toolBarForDoneBtn;
    */
    
    placeHolderInputLabel = [[UILabel alloc] initWithFrame: CGRectMake(13, 10, 0, 0)];
    placeHolderInputLabel.text = @"有什麼想要表達的嗎？";
    placeHolderInputLabel.numberOfLines = 0;
    placeHolderInputLabel.textColor = [UIColor hintGrey];
    [placeHolderInputLabel sizeToFit];
    [self.inputTextView addSubview: placeHolderInputLabel];
    
    self.inputTextView.font = [UIFont systemFontOfSize: 14.f];
    placeHolderInputLabel.font = [UIFont systemFontOfSize: 14.f];
    
    
    // 3rd BgView
//    self.thirdBgView.backgroundColor = [UIColor greenColor];
    self.thirdBgView.padding = UIEdgeInsetsMake(0, 0, 0, 16);
    self.thirdBgView.myRightMargin = 0;
    self.thirdBgView.myTopMargin = 8;
    self.thirdBgView.myBottomMargin = 8;
    
    self.clearMsgBtn.layer.cornerRadius = kCornerRadius;
    self.clearMsgBtn.myRightMargin = 8;
    
    self.sendMsgBtn.layer.cornerRadius = kCornerRadius;
    self.sendMsgBtn.myLeftMargin = 8;
    
//    self.tableView.backgroundColor = [UIColor greenColor];
    self.tableView.myLeftMargin = 0;
    self.tableView.myRightMargin = 0;
    
    self.lineView.myLeftMargin = 0;
    self.lineView.myRightMargin = 0;
    self.lineView.hidden = YES;
    self.tableView.hidden = YES;
    self.tableView.allowsSelection = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)handleTap {
    NSLog(@"handleTap");
    
    [self.view endEditing: YES];
}

- (void)exitBtnHighLight: (UIButton *)sender {
    NSLog(@"exitBtnHighLight");
    sender.backgroundColor = [UIColor thirdMain];
}

- (void)exitBtnNormal: (UIButton *)sender {
    NSLog(@"exitBtnNormal");
    sender.backgroundColor = [UIColor clearColor];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    selectTextView = textView;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    selectTextView = nil;
}

- (void)textViewDidChange:(UITextView *)textView {
    NSLog(@"textViewDidChange");
    
    //每次输入变更都让布局重新布局。
    MyBaseLayout *layout = (MyBaseLayout*)textView.superview;
    [layout setNeedsLayout];
    
    //这里设置在布局结束后将textView滚动到光标所在的位置了。在布局执行布局完毕后如果设置了endLayoutBlock的话可以在这个block里面读取布局里面子视图的真实布局位置和尺寸，也就是可以在block内部读取每个子视图的真实的frame的值。
    layout.endLayoutBlock = ^{
        NSRange rg = textView.selectedRange;
        [textView scrollRangeToVisible:rg];
    };
    
    if ([self.inputTextView.text isEqualToString: @""]) {
        placeHolderInputLabel.alpha = 1;
    } else {
        placeHolderInputLabel.alpha = 0;
    }
}

#pragma mark -
- (void)getMessage {
    NSLog(@"getMessageBoardList");
    
    // If isLoading is NO then run the following code
    if (!isLoading) {
        NSLog(@"");
        NSLog(@"nextId is: %ld", (long)nextId);
        NSLog(@"");
        
        isLoading = YES;
        
        [self getMessageBoardList];
    }
}

- (void)getMessageBoardList {
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    
    NSString *limit = [NSString stringWithFormat: @"%ld,%ld", (long)nextId, 10];
    NSLog(@"limit: %@", limit);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = @"";
        
        response = [boxAPI getMessageBoardList: [wTools getUserID]
                                         token: [wTools getUserToken]
                                          type: self.type
                                        typeId: self.typeId
                                         limit: limit];
        
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
                NSLog(@"");
                NSLog(@"response from getMessageBoardList");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"NewMessageBoardViewController");
                    NSLog(@"getMessageBoardList");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"getMessageBoardList"
                                            text: @""];
                    self.tableView.userInteractionEnabled = YES;
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    NSLog(@"dic: %@", dic);
                    
                    if ([dic[@"result"] intValue] == 1) {
                        NSLog(@"Before");
                        NSLog(@"nextId: %ld", (long)nextId);
                        
                        if (nextId == 0)
                            messageArray = [NSMutableArray new];
                        
                        //[messageArray removeAllObjects];
                        
                        // s for counting how much data is loaded
                        int s = 0;
                        
                        for (NSMutableDictionary *messageData in [dic objectForKey: @"data"]) {
                            s++;
                            
                            [messageArray addObject: messageData];
                        }
                        
                        NSLog(@"After");
                        NSLog(@"nextId: %ld", (long)nextId);
                        NSLog(@"s: %d", s);
                        
                        // If data keeps loading then the nextId is accumulating
                        //nextId = nextId + s;
                        nextId = nextId + s;
                        NSLog(@"nextId is: %ld", (long)nextId);
                        
                        // If nextId is bigger than 0, that means there are some data loaded already.
                        if (nextId >= 0)
                            isLoading = NO;
                        
                        // If s is 0, that means dic data is empty.
                        if (s == 0) {
                            isLoading = YES;
                        }
                        
                        NSLog(@"check messageArray.count");
                        
                        if (messageArray.count == 0) {
                            self.lineView.hidden = YES;
                            self.tableView.hidden = YES;
                        } else {
                            self.lineView.hidden = NO;
                            self.tableView.hidden = NO;
                            [self.tableView reloadData];
                        }
                        
                        // Set userInteractionEnabled to YES for scrolling
                        self.tableView.userInteractionEnabled = YES;
                        self.inputTextView.userInteractionEnabled = YES;
                        
                        NSLog(@"messageArray.count: %lu", (unsigned long)messageArray.count);
                        NSLog(@"messageArray: %@", messageArray);
                    } else if ([dic[@"result"] intValue] == 0) {
                        self.tableView.userInteractionEnabled = YES;
                        NSLog(@"失敗： %@", dic[@"message"]);
                        NSString *msg = dic[@"message"];
                        [self showCustomErrorAlert: msg];
                    } else {
                        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            }
        });
    });
}

- (void)insertMessage: (NSString *)text {
    NSLog(@"");
    NSLog(@"insertMessage");
    NSLog(@"text: %@", text);
    
    // Set userInteractionEnabled to NO to avoid crash when
    // user wants to scroll tableView, but the new data hasn't received yet
    self.tableView.userInteractionEnabled = NO;
    
    @try {
        [wTools ShowMBProgressHUD];
    } @catch (NSException *exception) {
        // Print exception information
        NSLog( @"NSException caught" );
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
        return;
    }
    
    NSLog(@"");
    NSLog(@"nextId: %ld", (long)nextId);
    NSLog(@"");
    
    nextId = 0;
    
    NSString *limit = [NSString stringWithFormat: @"%ld,%d", (long)nextId, 10];
    NSLog(@"limit: %@", limit);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSString *response = @"";
        
        response = [boxAPI insertMessageBoard: [wTools getUserID]
                                        token: [wTools getUserToken]
                                         type: self.type
                                       typeId: self.typeId
                                         text: text
                                        limit: limit];
        
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
                NSLog(@"");
                NSLog(@"response from insertMessageBoard");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"NewMessageBoardViewController");
                    NSLog(@"insertMessage");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"insertMessageBoard"
                                            text: text];
                } else {
                    NSLog(@"Get Real Response");
                    
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    
                    NSLog(@"dic: %@", dic);
                    
                    if ([dic[@"result"] intValue] == 1) {
                        tempStr = @"";
                        
                        NSLog(@"Before");
                        NSLog(@"nextId: %ld", (long)nextId);
                        
                        // If response from server is TRUE
                        // then reset array
                        messageArray = [NSMutableArray new];
                        rowHeightArray = [NSMutableArray new];
                        
                        // After resetting array, tableView has to reload data to reset indexPath.row to 0
                        // Otherwise, the program will crash when adding data to indexPath.row bigger than 0
                        [self.tableView reloadData];
                        
                        //[messageArray removeAllObjects];
                        //[rowHeightArray removeAllObjects];
                        
                        // s for counting how much data is loaded
                        int s = 0;
                        
                        for (NSMutableDictionary *messageData in [dic objectForKey: @"data"])
                        {
                            s++;
                            [messageArray addObject: messageData];
                        }
                        
                        NSLog(@"After");
                        NSLog(@"nextId: %ld", (long)nextId);
                        NSLog(@"s: %d", s);
                        
                        // If data keeps loading then the nextId is accumulating
                        nextId = nextId + s;
                        NSLog(@"nextId is: %ld", (long)nextId);
                        
                        // If nextId is bigger than 0, that means there are some data loaded already.
                        if (nextId >= 0)
                            isLoading = NO;
                        
                        // If s is 0, that means dic data is empty.
                        if (s == 0) {
                            isLoading = YES;
                        }
                        
                        NSLog(@"check messageArray.count");
                        
                        if (messageArray.count == 0) {
                            self.lineView.hidden = YES;
                            self.tableView.hidden = YES;
                        } else {
                            self.lineView.hidden = NO;
                            self.tableView.hidden = NO;
                            [self.tableView reloadData];
                        }
                        
                        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                        style.messageColor = [UIColor whiteColor];
                        style.backgroundColor = [UIColor firstMain];
                        
                        [self.view.superview makeToast: @"留言已送出"
                                              duration: 2.0
                                              position: CSToastPositionBottom
                                                 style: style];
                        
                        // Scroll to the Top when message is added
                        NSLog(@"self.tableView setContentOffset");
                        [self.tableView setContentOffset: CGPointZero animated: YES];
                        
                        // Set userInteractionEnabled to YES for scrolling
                        self.tableView.userInteractionEnabled = YES;
                        
                        //nextId = 0;
                        //isLoading = NO;
                        //[self getMessageBoardList];
                        
                    } else if ([dic[@"result"] intValue] == 0) {
                        self.tableView.userInteractionEnabled = YES;
                        NSLog(@"失敗： %@", dic[@"message"]);
                        NSString *msg = dic[@"message"];
                        
                        [self showCustomErrorAlert: msg];
                    } else {
                        [self showCustomErrorAlert: NSLocalizedString(@"Host-NotAvailable", @"")];
                    }
                }
            }
        });
    });
}

#pragma mark - Custom Alert Method
- (void)showCustomErrorAlert: (NSString *)msg
{
    NSLog(@"");
    NSLog(@"showCustomAlert msg: %@", msg);
    
    CustomIOSAlertView *errorAlertView = [[CustomIOSAlertView alloc] init];
    [errorAlertView setContainerView: [self createContainerView: msg]];
    
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
    [errorAlertView setOnButtonTouchUpInside:^(CustomIOSAlertView *errorAlertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[errorAlertView tag]);
        [weakErrorAlertView close];
    }];
    [errorAlertView setUseMotionEffects: YES];
    [errorAlertView show];
}

- (UIView *)createContainerView: (NSString *)msg
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

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"section: %ld", (long)section);
    NSLog(@"messageArray.count: %lu", (unsigned long)messageArray.count);
    return messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForRowAtIndexPath");
    
    NewMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"Cell" forIndexPath: indexPath];
    
    NSDictionary *dic = [messageArray[indexPath.row] copy];
    NSLog(@"dic: %@", dic);
    
    NSString *imageUrl = dic[@"user"][@"picture"];
    NSString *nameStr = dic[@"user"][@"name"];
    NSString *contentStr = dic[@"pinpinboard"][@"text"];
    NSString *inserTime = [self hourCalculation: dic[@"pinpinboard"][@"inserttime"]];
    
    if (![imageUrl isKindOfClass: [NSNull class]]) {
        if (![imageUrl isEqualToString: @""]) {
            [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: cell.pictureImageView];
            //cell.pictureImageView.imageURL = [NSURL URLWithString: imageUrl];
            [cell.pictureImageView sd_setImageWithURL: [NSURL URLWithString: imageUrl]];
        }
    } else {
        NSLog(@"imageUrl is nil");
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: cell.pictureImageView];
        cell.pictureImageView.image = [UIImage imageNamed: @"member_back_head.png"];
    }
    
    if (![nameStr isEqual: [NSNull null]]) {
        cell.nameLabel.text = nameStr;
    }
    if (![contentStr isEqual: [NSNull null]]) {
        cell.contentLabel.text = contentStr;
        [cell.contentLabel sizeToFit];
    }
    if (![inserTime isEqual: [NSNull null]]) {
        cell.insertTimeLabel.text = inserTime;
    }
    CGSize nameStrSize = [nameStr boundingRectWithSize: CGSizeMake(260, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes: @{NSFontAttributeName: [UIFont boldSystemFontOfSize: 14]} context: nil].size;
    
    CGSize contentStrSize = [contentStr boundingRectWithSize: CGSizeMake(260, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes: @{NSFontAttributeName: [UIFont boldSystemFontOfSize: 14]} context: nil].size;
    
    CGSize insertTimeSize = [inserTime boundingRectWithSize: CGSizeMake(260, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes: @{NSFontAttributeName: [UIFont boldSystemFontOfSize: 14]} context: nil].size;
    
    CGFloat rowHeight = 16 + nameStrSize.height + 4 + contentStrSize.height + 4 + insertTimeSize.height + 8;
    NSLog(@"rowHeight: %f", rowHeight);
    
    NSLog(@"");
    NSLog(@"Before");
    NSLog(@"rowHeightArray: %@", rowHeightArray);
    
    NSLog(@"");
    NSLog(@"indexPath.row: %ld", (long)indexPath.row);
    [rowHeightArray insertObject: [NSNumber numberWithFloat: rowHeight] atIndex: indexPath.row];
    
    NSLog(@"");
    NSLog(@"After");
    NSLog(@"rowHeightArray: %@", rowHeightArray);
    
    tableView.rowHeight = rowHeight;
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"willDisplayCell");
    
    if (indexPath.item == (messageArray.count - 1)) {
        [self getMessage];
    }
}

#pragma mark - Helper Methods
- (void)adjustHeightOfTableView
{
    CGFloat height = self.tableView.contentSize.height;
    CGFloat maxHeight = self.tableView.superview.frame.size.height - self.tableView.frame.origin.y;
    
    // if the height of the content is greater than the maxHeight of
    // total space on the screen, limit the height to the size of the superview
    
    if (height > maxHeight)
        height = maxHeight;
    
    // now set the frame accordingly
    
    [UIView animateWithDuration: 0.25 animations:^{
        CGRect frame = self.tableView.frame;
        frame.size.height = height;
        self.tableView.frame = frame;
        
        // if you have other controls that should be reszied/moved to accommodate
        // the resized tableview, do that here, too
    }];
    
}

// Time Calculation Function
- (NSString *)hourCalculation: (NSString *)postDate {
    NSLog(@"hourCalculation");
    NSLog(@"postDate: %@", postDate);
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSDate *expDate = [dateFormat dateFromString: postDate];
    NSLog(@"expDate: %@", expDate);
    
    NSTimeZone *currentTimeZone = [NSTimeZone localTimeZone];
    NSTimeZone *utcTimeZone = [NSTimeZone timeZoneWithAbbreviation: @"UTC"];
    
    NSInteger currentGMTOffset = [currentTimeZone secondsFromGMTForDate: expDate];
    NSInteger gmtOffset = [utcTimeZone secondsFromGMTForDate: expDate];
    NSTimeInterval gmtInterval = currentGMTOffset - gmtOffset;
    
    NSDate *destinationDate = [[NSDate alloc] initWithTimeInterval: gmtInterval sinceDate: expDate];
    NSLog(@"destinationDate: %@", destinationDate);
    NSDate *currentDate = [[NSDate alloc] initWithTimeInterval: gmtInterval sinceDate: [NSDate date]];
    
    //NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation: @"GMT"];
    //[dateFormat setTimeZone: gmt];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components: (NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond) fromDate: destinationDate toDate: currentDate options: 0];
    NSString *time;
    
    NSLog(@"NSDate date: %@", [NSDate date]);
    NSLog(@"components: %@", components);
    
    if (components.year != 0) {
        if (components.year == 1) {
            time = [NSString stringWithFormat: @"%ld 年", (long)components.year];
        } else {
            time = [NSString stringWithFormat: @"%ld 年", (long)components.year];
        }
    } else if (components.month != 0) {
        if (components.month == 1) {
            time = [NSString stringWithFormat: @"%ld 月", (long)components.month];
        } else {
            time = [NSString stringWithFormat: @"%ld 月", (long)components.month];
        }
    } else if (components.weekday != 0) {
        if (components.weekday == 1) {
            time = [NSString stringWithFormat: @"%ld 週", (long)components.weekday];
        } else {
            time = [NSString stringWithFormat: @"%ld 週", (long)components.weekday];
        }
    } else if (components.day != 0) {
        if (components.day == 1) {
            time = [NSString stringWithFormat: @"%ld 天", (long)components.day];
        } else {
            time = [NSString stringWithFormat: @"%ld 天", (long)components.day];
        }
    } else if (components.hour != 0) {
        if (components.hour == 1) {
            time = [NSString stringWithFormat: @"%ld 小時", (long)components.hour];
        } else {
            time = [NSString stringWithFormat: @"%ld 小時", (long)components.hour];
        }
    } else if (components.minute != 0) {
        if (components.minute == 1) {
            time = [NSString stringWithFormat: @"%ld 分鐘", (long)components.minute];
        } else {
            time = [NSString stringWithFormat: @"%ld 分鐘", (long)components.minute];
        }
    } else if (components.second >= 0) {
        if (components.second == 0) {
            time = [NSString stringWithFormat: @"1 秒"];
        } else {
            time = [NSString stringWithFormat: @"%ld 秒", (long)components.second];
        }
    }
    
    NSLog(@"time: %@", time);
    
    return [NSString stringWithFormat: @"%@前", time];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Custom Method for TimeOut
- (void)showCustomTimeOutAlert: (NSString *)msg
                  protocolName: (NSString *)protocolName
                          text: (NSString *)text
{
    CustomIOSAlertView *alertTimeOutView = [[CustomIOSAlertView alloc] init];
    alertTimeOutView.parentView = self.view;
    [alertTimeOutView setContainerView: [self createTimeOutContainerView: msg]];
    
    //[alertView setButtonTitles: [NSMutableArray arrayWithObject: @"關 閉"]];
    //[alertView setButtonTitlesColor: [NSMutableArray arrayWithObject: [UIColor thirdGrey]]];
    //[alertView setButtonTitlesHighlightColor: [NSMutableArray arrayWithObject: [UIColor secondGrey]]];
    alertTimeOutView.arrangeStyle = @"Horizontal";
    
    alertTimeOutView.parentView = self.view.superview;
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
            if ([protocolName isEqualToString: @"getMessageBoardList"]) {
                [weakSelf getMessageBoardList];
            } else if ([protocolName isEqualToString: @"insertMessageBoard"]) {
                [weakSelf insertMessage: text];
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

@end
