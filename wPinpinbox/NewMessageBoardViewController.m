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
#import "MyLayout.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "UIColor+Extensions.h"
#import "NewMessageTableViewCell.h"
#import "UIView+Toast.h"
#import "CustomIOSAlertView.h"
#import "GlobalVars.h"
#import "AppDelegate.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "LabelAttributeStyle.h"
#import "TagCollectionViewCell.h"

@interface NewMessageBoardViewController () <UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate> {
    UITextView *selectTextView;
    UILabel *placeHolderNameLabel;
    
    BOOL isLoading;
    
    NSInteger nextId;
    NSMutableArray *messageArray;
//    NSMutableArray *rowHeightArray;
    
    NSString *tempStr;
    
    NSMutableString *searchStr;
    NSMutableArray *userData;
    
//    MyFrameLayout *tagBackgroundView;
    UICollectionView *collectionView;
//    UITextView *self.inputTextView;
    
    NSTextCheckingResult *matchResult;
    
    NSMutableArray *tagArray;
    
    NSString *oldInputText;
    BOOL isInsertBetweenTags;
    NSRange cursorRange;
}

@property (weak, nonatomic) IBOutlet MyLinearLayout *firstBgView;
@property (weak, nonatomic) IBOutlet UILabel *topicLabel;
@property (weak, nonatomic) IBOutlet UIButton *exitBtn;

@property (weak, nonatomic) IBOutlet MyFrameLayout *tagBackgroundView;

@property (weak, nonatomic) IBOutlet MyLinearLayout *secondBgView;
@property (weak, nonatomic) IBOutlet AsyncImageView *userImageView;
@property (weak, nonatomic) IBOutlet UITextView *inputTextView;

@property (weak, nonatomic) IBOutlet MyLinearLayout *thirdBgView;
@property (weak, nonatomic) IBOutlet UIButton *sendMsgBtn;
@property (weak, nonatomic) IBOutlet UIButton *clearMsgBtn;

@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSDictionary *textAttributes;
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

#pragma mark -
- (void)initialValueSetup {
    NSLog(@"initialValueSetup");
    
    nextId = 0;
    isLoading = NO;
    messageArray = [NSMutableArray new];
//    rowHeightArray = [NSMutableArray new];

    userData = [NSMutableArray new];
    searchStr = [[NSMutableString alloc] init];
    tagArray = [[NSMutableArray alloc] init];
    
    self.textAttributes = @{NSForegroundColorAttributeName :[UIColor blackColor], NSFontAttributeName: [UIFont systemFontOfSize: 14.0], NSKernAttributeName: @1};
    
//    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleTap)];
//    [self.view addGestureRecognizer: tapGR];
    
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
    
    [self setupTagBackgroundView];
    [self setupCollectionView];
    
    
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
//        self.userImageView.imageURL = [NSURL URLWithString: profilePic];
        [self.userImageView sd_setImageWithURL: [NSURL URLWithString: profilePic]
                              placeholderImage: [UIImage imageNamed: @"member_back_head.png"]];
    }
    
//    self.userImageView.imageURL = [NSURL URLWithString: dic[@"profilepic"]];
    
    // Text Input Section
    self.self.inputTextView.layer.cornerRadius = kCornerRadius;
    self.self.inputTextView.backgroundColor = [UIColor thirdGrey];
    self.self.inputTextView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self.self.inputTextView.textColor = [UIColor firstGrey];
    self.self.inputTextView.weight = 1;
    self.self.inputTextView.delegate = self;
    
    UIToolbar *toolBarForDoneBtn = [[UIToolbar alloc] initWithFrame: CGRectMake(0, 0, 320, 40)];
    toolBarForDoneBtn.barStyle = UIBarStyleDefault;
    toolBarForDoneBtn.items = [NSArray arrayWithObjects:
                               //[[UIBarButtonItem alloc] initWithTitle: @"取消" style: UIBarButtonItemStylePlain target: self action: @selector(cancelNumberPad)],
                               [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil],
                               [[UIBarButtonItem alloc] initWithTitle: @"完成" style: UIBarButtonItemStyleDone target: self action: @selector(dismissKeyboard)], nil];
    
    self.self.inputTextView.inputAccessoryView = toolBarForDoneBtn;
    
    placeHolderNameLabel = [[UILabel alloc] initWithFrame: CGRectMake(13, 10, 0, 0)];
    placeHolderNameLabel.text = @"有什麼想要表達的嗎？";
    placeHolderNameLabel.numberOfLines = 0;
    placeHolderNameLabel.textColor = [UIColor hintGrey];
    [placeHolderNameLabel sizeToFit];
    [self.self.inputTextView addSubview: placeHolderNameLabel];
    
    self.self.inputTextView.font = [UIFont systemFontOfSize: 14.f];
    placeHolderNameLabel.font = [UIFont systemFontOfSize: 14.f];
    
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
    
    self.lineView.myLeftMargin = self.lineView.myRightMargin = 0;
    self.lineView.myTopMargin = self.lineView.myBottomMargin = 0;
    self.lineView.hidden = YES;
    
//    self.tableView.backgroundColor = [UIColor greenColor];
    self.tableView.myLeftMargin = self.tableView.myRightMargin = 0;
    self.tableView.myTopMargin = self.tableView.myBottomMargin = 0;
    self.tableView.hidden = YES;
    self.tableView.allowsSelection = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
}

- (void)setupTagBackgroundView {
    NSLog(@"setupTagBackgroundView");
    self.tagBackgroundView.wrapContentWidth = YES;
    self.tagBackgroundView.myTopMargin = 0;
    self.tagBackgroundView.myLeftMargin = 16;
    self.tagBackgroundView.myRightMargin = 16;
    self.tagBackgroundView.myHeight = 90;
    self.tagBackgroundView.backgroundColor = [UIColor thirdGrey];
    self.tagBackgroundView.layer.cornerRadius = kCornerRadius;
    
    NSLog(@"collectionView setting");
}

- (void)setupCollectionView {
    NSLog(@"");
    NSLog(@"setupCollectionView");
    
    // collectionView setting
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(80, 90);
    collectionView = [[UICollectionView alloc] initWithFrame: CGRectMake(0, 0, self.tagBackgroundView.bounds.size.width, self.tagBackgroundView.bounds.size.height) collectionViewLayout: layout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerNib: [UINib nibWithNibName: @"TagCollectionViewCell" bundle: [NSBundle mainBundle]] forCellWithReuseIdentifier: @"Cell"];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.showsHorizontalScrollIndicator = NO;
    
    collectionView.myTopMargin = collectionView.myBottomMargin = 0;
    collectionView.myLeftMargin = collectionView.myRightMargin = 0;
    
    collectionView.contentInset = UIEdgeInsetsMake(0, 8, 0, 8);
    
    [self.tagBackgroundView addSubview: collectionView];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)exitBtnHighLight: (UIButton *)sender {
    NSLog(@"exitBtnHighLight");
    sender.backgroundColor = [UIColor thirdMain];
}

- (void)exitBtnNormal: (UIButton *)sender {
    NSLog(@"exitBtnNormal");
    sender.backgroundColor = [UIColor clearColor];
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
                        self.self.inputTextView.userInteractionEnabled = YES;
                        
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
                        //                        rowHeightArray = [NSMutableArray new];
                        
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
                        
                        [self changeTextViewLayout: self.inputTextView];
                        
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

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    NSLog(@"section: %ld", (long)section);
    NSLog(@"messageArray.count: %lu", (unsigned long)messageArray.count);
    return messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
            [cell.pictureImageView sd_setImageWithURL: [NSURL URLWithString: imageUrl]];
        }
    } else {
        NSLog(@"imageUrl is nil");
        cell.pictureImageView.image = [UIImage imageNamed: @"member_back_head.png"];
    }
    
    if (![nameStr isEqual: [NSNull null]]) {
        cell.nameLabel.text = nameStr;
    }
    if (![contentStr isEqual: [NSNull null]]) {
        if ([LabelAttributeStyle checkTagString: contentStr] != 0) {
            NSLog(@"Got Tag");
            cell.contentLabel.attributedText = [LabelAttributeStyle convertToTagString: contentStr];
        } else {
            NSLog(@"No Tag");
            cell.contentLabel.text = contentStr;
            [LabelAttributeStyle changeGapString: cell.contentLabel content: cell.contentLabel.text];
        }
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
    
    tableView.rowHeight = rowHeight;
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"willDisplayCell");
    
    if (indexPath.item == (messageArray.count - 1)) {
        [self getMessage];
    }
}

#pragma mark - hourCalculation method
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

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    NSLog(@"");
    NSLog(@"");
    NSLog(@"numberOfItemsInSection");
    
    NSLog(@"userData.count: %lu", (unsigned long)userData.count);
    
    if (userData.count == 0) {
        self.tagBackgroundView.hidden = YES;
    } else {
        self.tagBackgroundView.hidden = NO;
    }
    
    return userData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"");
    NSLog(@"");
    NSLog(@"cellForItemAtIndexPath");
    
    NSDictionary *userDic = userData[indexPath.row][@"user"];
    
    TagCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"Cell" forIndexPath: indexPath];
    
    if (![userDic isKindOfClass: [NSNull class]]) {
        if ([userDic[@"picture"] isEqual: [NSNull null]]) {
            cell.userPictureImageView.image = [UIImage imageNamed: @"member_back_head.png"];
        } else {
            [cell.userPictureImageView sd_setImageWithURL: [NSURL URLWithString: userDic[@"picture"]]];
        }
        cell.userNameLabel.text = userDic[@"name"];
        NSLog(@"cell.userNameLabel.text: %@", cell.userNameLabel.text);
        [LabelAttributeStyle changeGapString: cell.userNameLabel content: cell.userNameLabel.text];
    } else {
        NSLog(@"userData is nil");
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate Methods
- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *userDic = userData[indexPath.row][@"user"];
    NSLog(@"userDic: %@", userDic);
    
    // 110 is an estimate for avoid exceeding the characters limit not for typing
    if (self.inputTextView.text.length > 110) {
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor thirdPink];
        
        [self.view.superview makeToast: @"最多輸入128個字元"
                              duration: 2.0
                              position: CSToastPositionCenter
                                 style: style];
        return;
    }
    
    [self checkTagAndCreateTag: userDic viewType: @"collectionView"];
}

- (void)checkTagAndCreateTag:(NSDictionary *)userDic
                    viewType:(NSString *)viewType {
    // Check whether userIdli exists in self.inputTextView.text or not
    NSLog(@"tagArray.count: %lu", (unsigned long)tagArray.count);
    
    if (tagArray.count == 0) {
        NSLog(@"tagArray.count == 0");
        [self createTagText: userDic viewType: viewType];
        
    } else if (tagArray.count != 0) {
        NSLog(@"tagArray.count != 0");
        NSLog(@"tagArray: %@", tagArray);
        
        BOOL hasTaggedAlready = NO;
        
        for (NSDictionary *dic in tagArray) {
            NSUInteger userId = [[dic objectForKey: @"userId"] integerValue];
            
            if (userId == [userDic[@"user_id"] integerValue]) {
                hasTaggedAlready = YES;
                break;
            }
        }
        
        if (hasTaggedAlready) {
            NSLog(@"userId is the same");
            CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
            style.messageColor = [UIColor whiteColor];
            style.backgroundColor = [UIColor thirdPink];
            
            [self.view.superview makeToast: @"已標記"
                                  duration: 2.0
                                  position: CSToastPositionCenter
                                     style: style];
        } else {
            NSLog(@"userId is not the same");
            [self createTagText: userDic viewType: viewType];
        }
    }
}

- (void)createTagText:(NSDictionary *)userDic
             viewType:(NSString *)viewType {
    NSLog(@"");
    NSLog(@"createTagText");
    self.tagBackgroundView.hidden = YES;
    
    NSString *userId = [userDic[@"user_id"] stringValue];
    NSString *userName = userDic[@"name"];
    NSString *sendingType = [NSString stringWithFormat: @"[%@:%@]", userId, userName];
    
    if (self.inputTextView.text.length == 0) {
        placeHolderNameLabel.alpha = 0;
    }
    
    NSRange tempRange = NSMakeRange(0, 0);
    
    if ([viewType isEqualToString: @"collectionView"]) {
        NSLog(@"viewType: %@", viewType);
        tempRange = matchResult.range;
    } else if ([viewType isEqualToString: @"tableView"]) {
        NSLog(@"viewType: %@", viewType);
        NSLog(@"self.inputTextView.selectedRange: %@", NSStringFromRange(self.inputTextView.selectedRange));
        tempRange = self.inputTextView.selectedRange;
    }
    
    NSLog(@"tempRange: %@", NSStringFromRange(tempRange));
    
    self.inputTextView.text = [self.inputTextView.text stringByReplacingCharactersInRange: tempRange withString: sendingType];
    cursorRange = self.inputTextView.selectedRange;
    
    NSLog(@"self.inputTextView.selectedRange: %@", NSStringFromRange(self.inputTextView.selectedRange));
    
    NSLog(@"userId.length: %lu", (unsigned long)userId.length);
    NSLog(@"userName.length: %lu", (unsigned long)userName.length);
    //    NSUInteger tagLength = userId.length + userName.length + 3;
    //    NSLog(@"tagLength: %lu", (unsigned long)tagLength);
    
    NSLog(@"sendingType.length: %lu", (unsigned long)sendingType.length);
    
    // Record every tag info
    NSMutableDictionary *tagDic = [[NSMutableDictionary alloc] init];
    [tagDic setObject: userName forKey: @"userName"];
    [tagDic setObject: [NSNumber numberWithUnsignedInteger: [userId integerValue]] forKey: @"userId"];
    [tagDic setObject: sendingType forKey: @"sendingType"];
    [tagDic setObject: [NSNumber numberWithUnsignedInteger: tempRange.location] forKey: @"location"];
    [tagDic setObject: [NSNumber numberWithUnsignedInteger: sendingType.length] forKey: @"length"];
    
    NSLog(@"tagDic: %@", tagDic);
    [tagArray addObject: tagDic];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"location" ascending: YES];
    NSArray *sortedArray = [tagArray sortedArrayUsingDescriptors: @[sortDescriptor]];
    NSLog(@"sortedArray: %@", sortedArray);
    
    NSLog(@"Before");
    NSLog(@"tagArray: %@", tagArray);
    
    tagArray = nil;
    tagArray = [sortedArray mutableCopy];
    
    NSLog(@"After");
    NSLog(@"tagArray: %@", tagArray);
    
    // Check If there is a tag inserting between Tag Texts
    // then reset tagArray Data
    
    NSLog(@"isInsertBetweenTags: %d", isInsertBetweenTags);
    
    [tagArray removeAllObjects];
    tagArray = nil;
    tagArray = [[self resetTagArray: self.inputTextView.text] mutableCopy];
    
    //    if (isInsertBetweenTags || [viewType isEqualToString: @"tableView"]) {
    //        [tagArray removeAllObjects];
    //        tagArray = nil;
    //        tagArray = [[self resetTagArray: self.inputTextView.text] mutableCopy];
    //    }
    NSLog(@"tagArray: %@", tagArray);
    
    self.inputTextView.attributedText = [self setTextColor: tagArray];
    NSLog(@"self.inputTextView.text: %@", self.inputTextView.text);
    
    cursorRange = NSMakeRange(tempRange.location + sendingType.length, 0);
    self.inputTextView.selectedRange = cursorRange;
    
    // Reset text attributes for after lighting some texts
    self.inputTextView.typingAttributes = self.textAttributes;
    
    oldInputText = self.inputTextView.text;
    
    // Adjust TextView Height based on text
    [self changeTextViewLayout: self.inputTextView];
}

- (NSMutableArray *)resetTagArray:(NSString *)searchedString {
    NSLog(@"resetTagArray");
    NSRange searchedRange = NSMakeRange(0, searchedString.length);
    
    // Regular Expression Setting
    NSString *pattern = @"\\[{1}[0-9]+\\:{1}[^\\[\\]:]+\\]{1}";
    NSError *error = nil;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern: pattern
                                                                           options: 0
                                                                             error: &error];
    NSLog(@"searchedString: %@", searchedString);
    NSArray *matches = [regex matchesInString: searchedString
                                      options: 0
                                        range: searchedRange];
    NSLog(@"matches: %@", matches);
    //    NSLog(@"searchedString: %@", searchedString);
    
    
    // Array for Tag Info
    NSMutableArray *tagArray = [[NSMutableArray alloc] init];
    
    // Loop for getting Tag Info
    for (NSTextCheckingResult *match in matches) {
        // Tag Name Filtering ex: [userId: userName]
        NSString *matchText = [searchedString substringWithRange: [match range]];
        NSLog(@"matchText: %@", matchText);
        
        // Getting range for highlighting text
        NSRange range = [searchedString rangeOfString: matchText];
        NSLog(@"range.length: %lu", (unsigned long)range.length);
        NSLog(@"range.location: %lu", (unsigned long)range.location);
        
        // String Filtering
        NSArray *array = [matchText componentsSeparatedByString: @":"];
        NSLog(@"array: %@", array);
        
        // Getting UserId
        NSString *userId = [array objectAtIndex: 0];
        userId = [userId substringFromIndex: 1];
        NSLog(@"userId: %@", userId);
        
        // Getting UserName
        NSString *userName = [array objectAtIndex: 1];
        userName = [userName substringToIndex: userName.length - 1];
        NSLog(@"userName: %@", userName);
        
        // Dictinoary for TagInfo setup
        NSMutableDictionary *tagDic = [[NSMutableDictionary alloc] init];
        [tagDic setObject: userName forKey: @"userName"];
        [tagDic setObject: userId forKey: @"userId"];
        [tagDic setObject: matchText forKey: @"sendingType"];
        [tagDic setObject: [NSNumber numberWithUnsignedInteger: range.location] forKey: @"location"];
        [tagDic setObject: [NSNumber numberWithUnsignedInteger: range.length] forKey: @"length"];
        
        [tagArray addObject: tagDic];
    }
    
    NSLog(@"tagArray: %@", tagArray);
    NSLog(@"self.inputTextView.text: %@", self.inputTextView.text);
    
    return tagArray;
}

- (NSMutableAttributedString *)setTextColor:(NSMutableArray *)tagArray {
    // Set Text Color
    NSLog(@"Set Text Color");
    
    // Setting data for NSMutableAttributedString
    NSMutableDictionary *attDic = [NSMutableDictionary dictionary];
    [attDic setValue: @1 forKey: NSKernAttributeName]; // 字间距
    [attDic setValue: [UIFont systemFontOfSize: 14.0f] forKey: NSFontAttributeName];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString: self.inputTextView.text attributes: attDic];
    
    // To track the gap text
    NSUInteger oldLocation = 0;
    
    for (int i = 0; i < tagArray.count; i++) {
        NSMutableDictionary *dic = [tagArray objectAtIndex: i];
        NSLog(@"dic: %@", dic);
        NSLog(@"");
        
        // Get End point like
        NSInteger distanceToNewLocation = [dic[@"location"] integerValue] - oldLocation;
        
        NSLog(@"distanceToNewLocation: %ld", (long)distanceToNewLocation);
        
        if (distanceToNewLocation < 0) {
            distanceToNewLocation = 0;
        }
        
        NSLog(@"oldLocation: %lu", (unsigned long)oldLocation);
        NSLog(@"distanceToNewLocation: %lu", (unsigned long)distanceToNewLocation);
        
        NSRange gapRange = NSMakeRange(oldLocation, distanceToNewLocation);
        NSLog(@"gapRange: %@", NSStringFromRange(gapRange));
        
        // For Not Tag Text Setting
        [attStr addAttribute: NSForegroundColorAttributeName
                       value: [UIColor firstGrey]
                       range: gapRange];
        
        NSLog(@"Before Adding");
        NSLog(@"oldLocation: %lu", (unsigned long)oldLocation);
        NSLog(@"length: %ld", [dic[@"length"] integerValue]);
        NSLog(@"gapRange.length: %lu", (unsigned long)gapRange.length);
        
        oldLocation += [dic[@"length"] integerValue] + gapRange.length;
        
        NSLog(@"location: %ld", [dic[@"location"] integerValue]);
        NSLog(@"length: %ld", [dic[@"length"] integerValue]);
        
        // For Tag Text Setting
        [attStr addAttribute: NSForegroundColorAttributeName
                       value: [UIColor firstMain]
                       range: NSMakeRange([dic[@"location"] integerValue], [dic[@"length"] integerValue])];
        
        NSLog(@"After Adding");
        NSLog(@"oldLocation: %lu", (unsigned long)oldLocation);
    }
    return attStr;
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
    self.self.inputTextView.text = @"";
    placeHolderNameLabel.alpha = 1;
}

- (IBAction)sendMsgBtnPress:(id)sender {
    NSLog(@"sendMsgBtnPress");
    NSLog(@"self.self.inputTextView.text: %@", self.self.inputTextView.text);
    NSLog(@"tempStr: %@", tempStr);
    
    NSUInteger length;
    length = self.self.inputTextView.text.length;
    
    NSLog(@"length: %lu", (unsigned long)length);
    
    if (![self.self.inputTextView.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]].length) {
        NSLog(@"string is all whitespace or newline");
        
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor firstGrey];
        
        [self.view.superview makeToast: @"不能發送空白訊息"
                              duration: 2.0
                              position: CSToastPositionBottom
                                 style: style];
    } else if ([self.self.inputTextView.text isEqualToString: tempStr]) {
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor firstGrey];
        
        [self.view.superview makeToast: @"不可連續發送"
                              duration: 2.0
                              position: CSToastPositionBottom
                                 style: style];
    } else {
        [self insertMessage: self.self.inputTextView.text];
    }
    // tempStr is to check the message is the same or not
    // to avoid the button being press in a short time.
    tempStr = self.self.inputTextView.text;
    
    self.self.inputTextView.text = @"";
    placeHolderNameLabel.alpha = 1;
    [self.view endEditing: YES];
}

#pragma mark - UITextViewDelegate Methods
- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text {
    NSString *currentText = textView.text;
    NSLog(@"currentText.length: %lu", (unsigned long)currentText.length);
    NSString *updatedText = [currentText stringByReplacingCharactersInRange: range withString: text];
    NSLog(@"updatedText.length: %lu", (unsigned long)updatedText.length);
    
    return updatedText.length <= 120;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    NSLog(@"");
    NSLog(@"textViewDidBeginEditing");
    //    selectTextView = textView;
    
    NSLog(@"self.inputTextView.selectedRange: %@", NSStringFromRange(self.inputTextView.selectedRange));
    
    // Reset text attributes for after lighting some texts
    textView.typingAttributes = self.textAttributes;
    
    NSLog(@"textView.text: %@", textView.text);
    
    oldInputText = textView.text;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    NSLog(@"");
    NSLog(@"textViewDidEndEditing");
    //    selectTextView = nil;
}

- (void)textViewDidChange:(UITextView *)textView {
    NSLog(@"");
    NSLog(@"textViewDidChange");
    
    NSLog(@"self.inputTextView.selectedRange: %@", NSStringFromRange(self.inputTextView.selectedRange));
    
    // Reset text attributes for after lighting some texts
    textView.typingAttributes = self.textAttributes;
    
    [self changeTextViewLayout: textView];
    
    if ([textView.text isEqualToString: @""]) {
        NSLog(@"textView.text is equal to empty");
        placeHolderNameLabel.alpha = 1;
    } else {
        NSLog(@"textView.text is not equal to empty");
        placeHolderNameLabel.alpha = 0;
    }
    
    isInsertBetweenTags = NO;
    
    if (tagArray.count != 0) {
        [self checkTagData: textView];
    }
    
    oldInputText = textView.text;
    NSLog(@"oldInputText = textView.text");
    NSLog(@"oldInputText: %@", oldInputText);
    
    // Check Tag Symbol Input
    [self checkTagSymbolInput: textView];
}

- (void)changeTextViewLayout:(UITextView *)textView {
    //每次输入变更都让布局重新布局。
    MyBaseLayout *layout = (MyBaseLayout*)textView.superview;
    [layout setNeedsLayout];
    
    //这里设置在布局结束后将textView滚动到光标所在的位置了。在布局执行布局完毕后如果设置了endLayoutBlock的话可以在这个block里面读取布局里面子视图的真实布局位置和尺寸，也就是可以在block内部读取每个子视图的真实的frame的值。
    layout.endLayoutBlock = ^{
        NSRange rg = textView.selectedRange;
        [textView scrollRangeToVisible:rg];
    };
}

#pragma mark - Change Location of Tag Data
- (void)checkTagData:(UITextView *)textView {
    NSLog(@"");
    NSLog(@"checkTagData");
    
    NSLog(@"");
    NSLog(@"oldInputText: %@", oldInputText);
    NSLog(@"textView.text: %@", textView.text);
    
    NSLog(@"Before");
    NSLog(@"tagArray: %@", tagArray);
    
    NSDictionary *dicForDeletion = [[NSDictionary alloc] init];
    
    for (int i = 0; i < tagArray.count; i++) {
        NSLog(@"i: %d", i);
        NSMutableDictionary *tagDic = tagArray[i];
        NSLog(@"");
        NSLog(@"sendingType: %@", tagDic[@"sendingType"]);
        NSUInteger oldLocation = [tagDic[@"location"] integerValue];
        
        NSLog(@"location: %lu", (unsigned long)oldLocation);
        NSLog(@"self.inputTextView.selectedRange.location: %lu", (unsigned long)self.inputTextView.selectedRange.location);
        
        // if there is a tag after textView selectedRange then
        // location of tagArray data need to be changed
        
        NSLog(@"oldInputText: %@", oldInputText);
        NSLog(@"self.inputTextView.text: %@", self.inputTextView.text);
        NSLog(@"sendingType: %@", tagDic[@"sendingType"]);
        
        if ([oldInputText containsString: tagDic[@"sendingType"]]) {
            if ([self.inputTextView.text containsString: tagDic[@"sendingType"]]) {
                NSLog(@"Tag Text didn't change");
            } else {
                NSLog(@"Tag Text has been modified");
                dicForDeletion = [tagDic copy];
            }
        }
        
        if (oldLocation > self.inputTextView.selectedRange.location) {
            NSLog(@"oldLocation > self.inputTextView.selectedRange.location");
            isInsertBetweenTags = YES;
            NSLog(@"tagDic: %@", tagDic);
            NSUInteger newLocation;
            
            if (oldInputText.length < textView.text.length) {
                NSLog(@"Adding Text");
                
                newLocation = oldLocation + (textView.text.length - oldInputText.length);
                [tagDic setObject: [NSNumber numberWithUnsignedInteger: newLocation] forKey: @"location"];
            } else {
                NSLog(@"Removing Text");
                newLocation = oldLocation + (textView.text.length - oldInputText.length);
                [tagDic setObject: [NSNumber numberWithUnsignedInteger: newLocation] forKey: @"location"];
            }
        }
    }
    
    NSLog(@"dicForDeletion: %@", dicForDeletion);
    
    // if the tag text has been modified then replace string
    if (dicForDeletion[@"sendingType"] != nil) {
        NSLog(@"sendingType is not nil");
        NSLog(@"sendingType: %@", dicForDeletion[@"sendingType"]);
        [tagArray removeObject: dicForDeletion];
        
        NSLog(@"oldInputText: %@", oldInputText);
        NSLog(@"self.inputTextView.text: %@", self.inputTextView.text);
        
        if (oldInputText.length < self.inputTextView.text.length) {
            NSLog(@"oldInputText.length < self.inputTextView.text.length");
            oldInputText = [oldInputText stringByReplacingOccurrencesOfString: dicForDeletion[@"sendingType"] withString: [self oneCharacterBeforeCursor: textView]];
            cursorRange.location = [dicForDeletion[@"location"] integerValue] + 1;
        } else {
            NSLog(@"oldInputText.length > self.inputTextView.text.length");
            oldInputText = [oldInputText stringByReplacingOccurrencesOfString: dicForDeletion[@"sendingType"] withString: @""];
            cursorRange.location = [dicForDeletion[@"location"] integerValue];
        }
        NSLog(@"oldInputText: %@", oldInputText);
        textView.text = oldInputText;
        
        // Change location to the correct one
        [tagArray removeAllObjects];
        tagArray = nil;
        tagArray = [[self resetTagArray: self.inputTextView.text] mutableCopy];
        
        self.inputTextView.attributedText = [self setTextColor: tagArray];
        
        NSLog(@"After replacing old cursor range");
        [textView setSelectedRange: cursorRange];
        NSLog(@"textView.selectedRange: %@", NSStringFromRange(textView.selectedRange));
        
        NSLog(@"self.inputTextView.text: %@", self.inputTextView.text);
    }
    
    // Reset text attributes for after lighting some texts
    self.inputTextView.typingAttributes = self.textAttributes;
    
    NSLog(@"After");
    NSLog(@"tagArray: %@", tagArray);
}

#pragma mark - Tag Methods
- (void)checkTagSymbolInput:(UITextView *)textView {
    NSLog(@"");
    NSLog(@"checkTagSymbolInput");
    // Check "@" input
    NSLog(@"textView.text: %@", textView.text);
    
    [self getStringAfterSymbol: textView];
}

- (void)getStringAfterSymbol:(UITextView *)textView {
    NSLog(@"");
    NSLog(@"getStringAfterSymbol");
    NSRange searchedRange = NSMakeRange(0, textView.selectedRange.location);
    
    NSString *pattern;
    
    NSLog(@"textView.selectedRange.location: %lu", (unsigned long)textView.selectedRange.location);
    
    NSString *oneCharacterBeforeCursor = [self oneCharacterBeforeCursor: textView];
    NSLog(@"oneCharacterBeforeCursor: %@", oneCharacterBeforeCursor);
    
    NSLog(@"self.inputTextView.text.length: %lu", (unsigned long)self.inputTextView.text.length);
    
    NSArray *strArray = [textView.text componentsSeparatedByString: @"@"];
    NSLog(@"");
    NSLog(@"strArray: %@", strArray);
    
    if ([strArray[0] isEqualToString: @""]) {
        pattern = [NSString stringWithFormat: @"%@%@", @"@", @"\\S*\\z"];
    } else {
        pattern = [NSString stringWithFormat: @"%@%@", @" @", @"\\S*\\z"];
    }
    
    NSLog(@"pattern: %@", pattern);
    
    NSError *error = nil;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern: pattern
                                                                           options: 0
                                                                             error: &error];
    NSArray *matches = [regex matchesInString: textView.text
                                      options: 0
                                        range: searchedRange];
    //    NSLog(@"matches: %@", matches);
    
    for (NSTextCheckingResult *match in matches) {
        matchResult = match;
        NSString *matchText = [textView.text substringWithRange: [match range]];
        NSLog(@"matchText: %@", matchText);
        NSLog(@"match range length: %lu", (unsigned long)[match range].length);
        NSLog(@"match range location: %lu", (unsigned long)[match range].location);
        [self filterUserContentForSearchText: matchText];
    }
}

- (NSString *)oneCharacterBeforeCursor:(UITextView *)textView {
    UITextRange *cursorRange = textView.selectedTextRange;
    
    if (cursorRange) {
        UITextPosition *newPosition = [textView positionFromPosition: cursorRange.start offset: -1];
        
        if (newPosition) {
            UITextRange *textRange = [textView textRangeFromPosition: newPosition toPosition: cursorRange.start];
            return [textView textInRange: textRange];
        }
    }
    return nil;
}

#pragma mark - Call Server for Searching
- (void)filterUserContentForSearchText: (NSString *)text {
    NSLog(@"");
    NSLog(@"filterUserContentForSearchText");
    NSLog(@"text: %@", text);
    
    NSString *string = text;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = @"";
        
        NSMutableDictionary *data = [NSMutableDictionary new];
        [data setObject: @"user" forKey: @"searchtype"];
        [data setObject: string forKey: @"searchkey"];
        [data setObject: @"0,16" forKey: @"limit"];
        
        response = [boxAPI search: [wTools getUserID]
                            token: [wTools getUserToken]
                             data: data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (response != nil) {
                NSLog(@"response from search");
                
                if ([response isEqualToString: timeOutErrorCode]) {
                    NSLog(@"Time Out Message Return");
                    NSLog(@"SearchTableViewController");
                    NSLog(@"filterUserContentForSearchText");
                    
                    [self showCustomTimeOutAlert: NSLocalizedString(@"Connection-Timeout", @"")
                                    protocolName: @"filterUserContentForSearchText"
                                            text: text];
                    
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    
                    NSLog(@"dic: %@", dic);
                    
                    if (![dic[@"result"] boolValue]) {
                        return ;
                    }
                    //判斷回傳是否一樣
                    if (![text isEqualToString:string]) {
                        return;
                    }
                    //判斷目前table和 搜尋結果是否相同
                    if (![data[@"searchtype"] isEqualToString: @"user"]) {
                        return;
                    }
                    
                    if ([dic[@"result"] intValue] == 1) {
                        NSLog(@"dic result boolValue is 1");
                        
                        userData = [NSMutableArray arrayWithArray: dic[@"data"]];
                        
                        NSLog(@"[wTools getUserID]: %@", [wTools getUserID]);
                        NSLog(@"userData: %@", userData);
                        
                        NSLog(@"userData.count: %lu", (unsigned long)userData.count);
                        
                        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
                        for (NSDictionary *d in userData) {
                            if ([d[@"user"][@"user_id"] intValue] == [[wTools getUserID] intValue]) {
                                [tempArray addObject: d];
                            }
                        }
                        NSLog(@"tempArray: %@", tempArray);
                        
                        [userData removeObjectsInArray: tempArray];
                        [collectionView reloadData];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Custom Alert Method
- (void)showCustomErrorAlert: (NSString *)msg {
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
