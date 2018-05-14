//
//  MessageboardViewController.m
//  wPinpinbox
//
//  Created by Angus on 2015/12/14.
//  Copyright © 2015年 Angus. All rights reserved.
//

#import "MessageboardViewController.h"
#import "MyLayout.h"
#import "UIColor+Extensions.h"
#import "GlobalVars.h"
#import "LabelAttributeStyle.h"
#import "MessageTableViewCell.h"

#import "wTools.h"
#import "boxAPI.h"

#import "CustomIOSAlertView.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import "UIView+Toast.h"

#import "TagCollectionViewCell.h"

#import "MintAnnotationChatView.h"

@interface MessageboardViewController () <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate> {
    BOOL isTouchDown;
    UILabel *placeHolderNameLabel;
//    CGSize kbSize;
    
    BOOL isLoading;
    
    NSInteger nextId;
    NSMutableArray *messageArray;
//    NSMutableArray *rowHeightArray;
    
    NSString *tempStr;
    
    BOOL isSlided;
    
    NSMutableString *searchStr;
    NSMutableArray *userData;
    
    MyFrameLayout *tagBackgroundView;
    UICollectionView *collectionView;
    
//    MintAnnotationChatView *inputTextView;
    UITextView *inputTextView;
    
    NSTextCheckingResult *matchResult;
    
    NSMutableArray *tagArray;
    
    NSString *oldInputText;
    BOOL isInsertBetweenTags;
    NSRange cursorRange;
}
@property (weak, nonatomic) IBOutlet UIView *blackView;
//@property (nonatomic) UIVisualEffectView *effectView;
@property (weak, nonatomic) IBOutlet MyFrameLayout *actionSheetView;
@property (weak, nonatomic) IBOutlet UILabel *topicLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet MyLinearLayout *contentLayout;

@property (weak, nonatomic) UITableView *tableView;

@property (nonatomic) NSDictionary *textAttributes;
@end

@implementation MessageboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"MessageboardViewController");
    NSLog(@"viewDidLoad");
    // Do any additional setup after loading the view from its nib.
//    kbSize = CGSizeZero;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"");
    NSLog(@"");
    NSLog(@"MessageboardViewController");
    NSLog(@"viewWillAppear");
 
//    [self initialValueSetup];
//    [self getMessage];
    
//    [self addKeyboardNotification];
    
    [self slideIn];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"");
    NSLog(@"");
    NSLog(@"MessageboardViewController");
    NSLog(@"viewWillDisappear");
//    [self removeKeyboardNotification];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialValueSetup {
    NSLog(@"initialValueSetup");
    
    isSlided = NO;
    
    nextId = 0;
    isLoading = NO;
    messageArray = [NSMutableArray new];
//    rowHeightArray = [NSMutableArray new];
    userData = [NSMutableArray new];
    searchStr = [[NSMutableString alloc] init];
    tagArray = [[NSMutableArray alloc] init];
    
    self.textAttributes = @{NSForegroundColorAttributeName :[UIColor blackColor], NSFontAttributeName: [UIFont systemFontOfSize: 14.0], NSKernAttributeName: @1};
}

#pragma mark -
- (void)getMessage {
    NSLog(@"getMessage");
    
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
    NSLog(@"getMessageBoardList");
    
    [wTools ShowMBProgressHUD];
    
    NSString *limit = [NSString stringWithFormat: @"%ld,%d", (long)nextId, 10];
    NSLog(@"limit: %@", limit);
    
    NSLog(@"self.type: %@", self.type);
    NSLog(@"self.typeId: %@", self.typeId);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *response = @"";
        response = [boxAPI getMessageBoardList: [wTools getUserID]
                                         token: [wTools getUserToken]
                                          type: self.type
                                        typeId: self.typeId
                                         limit: limit];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [wTools HideMBProgressHUD];
            
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
                    
                    NSLog(@"self.tableView: %@", self.tableView);
                    
                    if (![self.tableView isEqual: [NSNull null]] || self.tableView != nil) {
                        self.tableView.userInteractionEnabled = YES;
                    }
                } else {
                    NSLog(@"Get Real Response");
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                    NSLog(@"dic: %@", dic);
                    
                    if ([dic[@"result"] boolValue]) {
                        NSLog(@"Before");
                        NSLog(@"nextId: %ld", (long)nextId);
                        
                        if (nextId == 0)
                            messageArray = [NSMutableArray new];
                        
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
                        
                        NSLog(@"");
                        NSLog(@"isSlided: %d", isSlided);
                        
                        if (!isSlided) {
                            NSLog(@"self slideIn");
                            
                            if ([self.delegate respondsToSelector: @selector(gotMessageData)]) {
                                [self.delegate gotMessageData];
                            }
//                            [self slideIn];
                            isSlided = YES;
                        }
                        
                        NSLog(@"");
                        NSLog(@"check messageArray.count");
                        NSLog(@"self.tableView: %@", self.tableView);
                        
                        if (![self.tableView isEqual: [NSNull null]] || self.tableView != nil) {
                            if (messageArray.count == 0) {
                                self.tableView.hidden = YES;
                            } else {
                                self.tableView.hidden = NO;
                                [self.tableView reloadData];
                            }
                            // Set userInteractionEnabled to YES for scrolling
                            self.tableView.userInteractionEnabled = YES;
                        }
//                        NSLog(@"messageArray.count: %lu", (unsigned long)messageArray.count);
//                        NSLog(@"messageArray: %@", messageArray);
                    } else {
                        if (![self.tableView isEqual: [NSNull null]] || self.tableView != nil) {
                            self.tableView.userInteractionEnabled = YES;
                        }
                        NSLog(@"失敗： %@", dic[@"message"]);
                        NSString *msg = dic[@"message"];
                        
                        if (msg == nil) {
                            msg = NSLocalizedString(@"Host-NotAvailable", @"");
                        }
                        [self showCustomErrorAlert: msg];
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
    
    [wTools ShowMBProgressHUD];
    
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
            [wTools HideMBProgressHUD];
            
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
                    
                    if ([dic[@"result"] boolValue]) {
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
                            self.tableView.hidden = YES;
                        } else {
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
                        
                    } else {
                        self.tableView.userInteractionEnabled = YES;
                        NSLog(@"失敗： %@", dic[@"message"]);
                        NSString *msg = dic[@"message"];
                        
                        if (msg == nil) {
                            msg = NSLocalizedString(@"Host-NotAvailable", @"");
                        }
                        [self showCustomErrorAlert: msg];
                    }
                }
            }
        });
    });
}

#pragma mark - UITableViewDatasource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    NSLog(@"numberOfRowsInSection");
    NSLog(@"messageArray.count: %lu", (unsigned long)messageArray.count);
    return messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForRowAtIndexPath");
    static NSString *cellIdentifier = @"Cell";

    NSDictionary *dic = [messageArray[indexPath.row] copy];
    NSLog(@"dic: %@", dic);
    
    NSString *imageUrl = dic[@"user"][@"picture"];
    NSString *nameStr = dic[@"user"][@"name"];
    NSString *contentStr = dic[@"pinpinboard"][@"text"];
    NSLog(@"contentStr: %@", contentStr);
    NSString *inserTime = [self hourCalculation: dic[@"pinpinboard"][@"inserttime"]];
    
    MessageTableViewCell *cell = (MessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier: cellIdentifier];
    cell.userId = dic[@"user"][@"user_id"];
    cell.userName = dic[@"user"][@"name"];

    __block NSDictionary *userDic = dic[@"user"];

    cell.customBlock = ^(NSString *userId, NSString *userName) {
        NSLog(@"cell.customBlock");
        NSLog(@"userId: %@", userId);
        NSLog(@"userName: %@", userName);

        if ([userId intValue] == [[wTools getUserID] intValue]) {
            CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
            style.messageColor = [UIColor whiteColor];
            style.backgroundColor = [UIColor thirdPink];
            
            [self.view.superview makeToast: @"不可標記自己"
                                  duration: 2.0
                                  position: CSToastPositionCenter
                                     style: style];
        } else {
            [self checkTagAndCreateTag: userDic viewType: @"tableView"];
        }                
    };
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed: @"MessageTableViewCell" owner: self options: nil];
        cell = [nib objectAtIndex: 0];
    }
    
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
    
    CGSize contentStrSize = [cell.contentLabel.text boundingRectWithSize: CGSizeMake(cell.contentLabel.bounds.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes: @{NSFontAttributeName: [UIFont boldSystemFontOfSize: 14]} context: nil].size;    
    
    NSLog(@"cell.contentLabel.text: %@", cell.contentLabel.text);
    NSLog(@"contentStrSize.height: %f", contentStrSize.height);
    
    CGSize insertTimeSize = [inserTime boundingRectWithSize: CGSizeMake(260, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes: @{NSFontAttributeName: [UIFont boldSystemFontOfSize: 14]} context: nil].size;
    
    CGFloat rowHeight = 16 + nameStrSize.height + 4 + contentStrSize.height + 4 + insertTimeSize.height + 8;
//    [rowHeightArray insertObject: [NSNumber numberWithFloat: rowHeight] atIndex: indexPath.row];
    
    tableView.rowHeight = rowHeight;
    
    return cell;
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidScroll");
    
    // getting the scroll offset
    CGFloat bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    NSLog(@"bottomEdge: %f", bottomEdge);
    NSLog(@"scrollView.contentSize.height: %f", scrollView.contentSize.height);
    
    NSLog(@"isLoading: %d", isLoading);
    
    if (bottomEdge > scrollView.contentSize.height) {
        NSLog(@"We are at the bottom");
        [self getMessage];
    }
}


#pragma mark - Custom ActionSheet Methods
- (void)slideIn {
    NSLog(@"");
    NSLog(@"sldeIn");
    
    self.view.frame = [[UIScreen mainScreen] bounds];
    
//    [inputTextView addObserver: self forKeyPath: @"selectedTextRange" options: NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context: nil];
    
    [self setupTagBackgroundView];
    [self setupCollectionView];
    [self setupActionSheetView];
    [self createMessageInputView];
    
    // Set up an animation for the transition between the views
    CATransition *animation = [CATransition animation];
    [animation setDuration: 0.2];
    [animation setType: kCATransitionPush];
    [animation setSubtype: kCATransitionFromTop];
    [animation setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
    
    //self.view.alpha = 1.0f;
    self.view.backgroundColor = [UIColor clearColor];
    [self.actionSheetView.layer addAnimation: animation forKey: @"TransitionToActionSheet"];
}

- (void)slideOut {
    NSLog(@"");
    NSLog(@"slideOut");
    
//    [inputTextView removeObserver: self forKeyPath: @"selectedTextRange" context: nil];
    
    [tagBackgroundView removeFromSuperview];
    [collectionView removeFromSuperview];
    
//    if (kbSize.height != 0) {
//        NSLog(@"kbSize.height: %f", kbSize.height);
//        CGRect rect = self.actionSheetView.frame;
//        rect.origin.y += kbSize.height;
//        self.actionSheetView.frame = rect;
//
////        NSLog(@"After resetting for keybord shows up");
////        NSLog(@"self.actionSheetView.frame.origin.y: %f", self.actionSheetView.frame.origin.y);
//    } else {
//        NSLog(@"kbSize.height: %f", kbSize.height);
//    }
    
    [UIView beginAnimations: @"removeFromSuperviewWithAnimation" context: nil];
    
    // Set delegate and selector to remove from superview when animation completes
    [UIView setAnimationDelegate: self];
    [UIView setAnimationDidStopSelector: @selector(animationDidStop:finished:context:)];
    
//    NSLog(@"");
//    NSLog(@"Before setting bounds");
//    NSLog(@"self.actionSheetView.frame.origin.y: %f", self.actionSheetView.frame.origin.y);
    
    // Move this view to bottom of superview
    CGRect frame = self.actionSheetView.frame;
    frame.origin = CGPointMake(0.0, self.view.bounds.size.height);
    self.actionSheetView.frame = frame;
    
//    NSLog(@"");
//    NSLog(@"After setting bounds");
//    NSLog(@"self.actionSheetView: %@", self.actionSheetView);
    
    [UIView commitAnimations];
    
    if ([self.delegate respondsToSelector: @selector(actionSheetViewDidSlideOut:)]) {
        [self.delegate actionSheetViewDidSlideOut: self];
    }
}

- (void)animationDidStop:(NSString *)animationID
                finished:(NSNumber *)finished
                 context:(void *)context {
    NSLog(@"");
    NSLog(@"animationDidStop");
    
    if ([animationID isEqualToString: @"removeFromSuperviewWithAnimation"]) {
        [self.view removeFromSuperview];
        
        NSArray *viewsToRemove = self.contentLayout.subviews;
        
        NSLog(@"Before Removing");
        NSLog(@"viewsToRemove: %@", viewsToRemove);
        
        for (UIView *v in viewsToRemove) {
            [v removeFromSuperview];
            NSLog(@"v removeFromSuperview");
        }
        NSLog(@"After Removing");
        NSLog(@"viewsToRemove: %@", viewsToRemove);
    }
}

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    NSLog(@"");
    NSLog(@"");
    NSLog(@"numberOfItemsInSection");
    
    NSLog(@"userData.count: %lu", (unsigned long)userData.count);

    if (userData.count == 0) {
        tagBackgroundView.hidden = YES;
    } else {
        tagBackgroundView.hidden = NO;
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
    if (inputTextView.text.length > 110) {
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
    // Check whether userIdli exists in inputTextView.text or not
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
    tagBackgroundView.hidden = YES;
    
    NSString *userId = [userDic[@"user_id"] stringValue];
    NSString *userName = userDic[@"name"];
    NSString *sendingType = [NSString stringWithFormat: @"[%@:%@]", userId, userName];
    
    if (inputTextView.text.length == 0) {
        placeHolderNameLabel.alpha = 0;
    }
    
    NSRange tempRange = NSMakeRange(0, 0);
    
    if ([viewType isEqualToString: @"collectionView"]) {
        NSLog(@"viewType: %@", viewType);
        tempRange = matchResult.range;
    } else if ([viewType isEqualToString: @"tableView"]) {
        NSLog(@"viewType: %@", viewType);
        NSLog(@"inputTextView.selectedRange: %@", NSStringFromRange(inputTextView.selectedRange));
        tempRange = inputTextView.selectedRange;
    }
    
    NSLog(@"tempRange: %@", NSStringFromRange(tempRange));
    
    inputTextView.text = [inputTextView.text stringByReplacingCharactersInRange: tempRange withString: sendingType];
    cursorRange = inputTextView.selectedRange;
    
    NSLog(@"inputTextView.selectedRange: %@", NSStringFromRange(inputTextView.selectedRange));
    
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
    tagArray = [[self resetTagArray: inputTextView.text] mutableCopy];
    
//    if (isInsertBetweenTags || [viewType isEqualToString: @"tableView"]) {
//        [tagArray removeAllObjects];
//        tagArray = nil;
//        tagArray = [[self resetTagArray: inputTextView.text] mutableCopy];
//    }
    NSLog(@"tagArray: %@", tagArray);
    
    inputTextView.attributedText = [self setTextColor: tagArray];
    NSLog(@"inputTextView.text: %@", inputTextView.text);
    
    cursorRange = NSMakeRange(tempRange.location + sendingType.length, 0);
    inputTextView.selectedRange = cursorRange;
    
    // Reset text attributes for after lighting some texts
    inputTextView.typingAttributes = self.textAttributes;
    
    oldInputText = inputTextView.text;
    
    // Adjust TextView Height based on text
    [self changeTextViewLayout: inputTextView];
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
    NSArray *matches = [regex matchesInString: searchedString
                                      options: 0
                                        range: searchedRange];
    
//    NSLog(@"searchedString: %@", searchedString);
//    NSLog(@"matches: %@", matches);
    
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
    NSLog(@"inputTextView.text: %@", inputTextView.text);
    
    return tagArray;
}

- (NSMutableAttributedString *)setTextColor:(NSMutableArray *)tagArray {
    // Set Text Color
    NSLog(@"Set Text Color");
    
    // Setting data for NSMutableAttributedString
    NSMutableDictionary *attDic = [NSMutableDictionary dictionary];
    [attDic setValue: @1 forKey: NSKernAttributeName]; // 字间距
    [attDic setValue: [UIFont systemFontOfSize: 14.0f] forKey: NSFontAttributeName];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString: inputTextView.text attributes: attDic];
    
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

#pragma mark - UI Setup
- (void)setupTagBackgroundView {
    NSLog(@"setupTagBackgroundView");
    
    CGFloat topMargin = 0;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        switch ((int)[[UIScreen mainScreen] nativeBounds].size.height) {
            case 1136:
                printf("iPhone 5 or 5S or 5C");
                topMargin = 20;
                break;
            case 1334:
                printf("iPhone 6/6S/7/8");
                topMargin = 20;
                break;
            case 2208:
                printf("iPhone 6+/6S+/7+/8+");
                topMargin = 20;
                break;
            case 2436:
                printf("iPhone X");
                topMargin = 44;
                break;
            default:
                printf("unknown");
                topMargin = 20;
                break;
        }
    }
    
    // tagBackgroundView
    tagBackgroundView = [MyFrameLayout new];
    tagBackgroundView.wrapContentWidth = YES;
    tagBackgroundView.myTopMargin = topMargin;
    tagBackgroundView.myLeftMargin = 16;
    tagBackgroundView.myRightMargin = 16;
    tagBackgroundView.myHeight = 90;
    tagBackgroundView.backgroundColor = [UIColor whiteColor];
    tagBackgroundView.layer.cornerRadius = kCornerRadius;
    
    [self.view addSubview: tagBackgroundView];
    
    NSLog(@"collectionView setting");
}

- (void)setupCollectionView {
    NSLog(@"");
    NSLog(@"setupCollectionView");
    
    // collectionView setting
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(80, 90);
    collectionView = [[UICollectionView alloc] initWithFrame: CGRectMake(0, 0, tagBackgroundView.bounds.size.width, tagBackgroundView.bounds.size.height) collectionViewLayout: layout];;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerNib: [UINib nibWithNibName: @"TagCollectionViewCell" bundle: [NSBundle mainBundle]] forCellWithReuseIdentifier: @"Cell"];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.showsHorizontalScrollIndicator = NO;
    
    collectionView.myTopMargin = collectionView.myBottomMargin = 0;
    collectionView.myLeftMargin = collectionView.myRightMargin = 0;
    
    collectionView.contentInset = UIEdgeInsetsMake(0, 8, 0, 8);
    
    [tagBackgroundView addSubview: collectionView];
}

- (void)setupActionSheetView {
    NSLog(@"");
    NSLog(@"setupActionSheetView");
    self.actionSheetView.myLeftMargin = self.actionSheetView.myRightMargin = 0;
    self.actionSheetView.myBottomMargin = 0;
    
    CGRect rect = self.actionSheetView.frame;
    rect.size.height = self.view.frame.size.height - 110;
    rect.origin.y = 127;
//    rect.size.height = self.view.frame.size.height - 110;
//    rect.origin.y = 127;
    self.actionSheetView.frame = rect;
    
    // Topic Label Setting
    self.topicLabel.myLeftMargin = 16;
    self.topicLabel.myTopMargin = 16;
    self.topicLabel.myHeight = 25.0f;
    self.topicLabel.text = self.topicStr;
    [LabelAttributeStyle changeGapString: self.topicLabel content: self.topicStr];
    self.topicLabel.textColor = [UIColor whiteColor];
    self.topicLabel.font = [UIFont boldSystemFontOfSize: 24];
    [self.topicLabel sizeToFit];
    
    NSLog(@"user name label");
    
    if (![self.userName isEqualToString: @""]) {        
        // User Name Label Setting
        self.userNameLabel.myLeftMargin = 8.0;
        self.userNameLabel.myRightMargin = 16.0;
        self.userNameLabel.myTopMargin = 16;
        self.userNameLabel.myHeight = 25.0f;
        NSLog(@"self.userName: %@", self.userName);
        self.userNameLabel.text = self.userName;
        [LabelAttributeStyle changeGapString: self.userNameLabel content: self.userName];
        self.userNameLabel.textColor = [UIColor secondGrey];
        self.userNameLabel.font = [UIFont boldSystemFontOfSize: 20];
        [self.userNameLabel sizeToFit];
    }
    
    NSLog(@"ContentLayout Setting");
    
    // ContentLayout Setting
    self.contentLayout.padding = UIEdgeInsetsMake(16, 0, 16, 0);
    self.contentLayout.myLeftMargin = self.contentLayout.myRightMargin = 0;
    self.contentLayout.myTopMargin = 0.1;
    self.contentLayout.myBottomMargin = 0;
    self.contentLayout.wrapContentHeight = YES;
}

- (void)createMessageInputView {
    NSLog(@"");
    NSLog(@"createMessageInputView");
    [self setupContentLayoutCornerRadius];
    
    // toolBarForDoneBtn
    UIToolbar *toolBarForDoneBtn = [[UIToolbar alloc] initWithFrame: CGRectMake(0, 0, 320, 40)];
    toolBarForDoneBtn.backgroundColor = [UIColor whiteColor];
    toolBarForDoneBtn.barStyle = UIBarStyleDefault;
    toolBarForDoneBtn.items = [NSArray arrayWithObjects:
                               //[[UIBarButtonItem alloc] initWithTitle: @"取消" style: UIBarButtonItemStylePlain target: self action: @selector(cancelNumberPad)],
                               [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil],
                               [[UIBarButtonItem alloc] initWithTitle: @"完成" style: UIBarButtonItemStyleDone target: self action: @selector(dismissKeyboard)], nil];
    
    // horzLayout for imageView & vertical layout
    MyLinearLayout *horzLayout1 = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Horz];
    horzLayout1.wrapContentHeight = YES;
    horzLayout1.myTopMargin = 0;
    horzLayout1.myBottomMargin = 8;
    horzLayout1.myLeftMargin = horzLayout1.myRightMargin = 0;
    [self.contentLayout addSubview: horzLayout1];
    
    // headshotImageView
    UIImageView *headshotImageView = [[UIImageView alloc] initWithFrame: CGRectMake(0.0, 0.0, 36.0, 36.0)];
    headshotImageView.myLeftMargin = 16;
    headshotImageView.myRightMargin = 8;
    
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [userPrefs objectForKey: @"profile"];
    
    NSString *profilePic = dic[@"profilepic"];
    NSLog(@"profilePic: %@", profilePic);
    
    if ([profilePic isEqual: [NSNull null]]) {
        NSLog(@"profilePic is equal to null");
        headshotImageView.image = [UIImage imageNamed: @"member_back_head.png"];
    } else if ([profilePic isEqualToString: @""]) {
        headshotImageView.image = [UIImage imageNamed: @"member_back_head.png"];
    } else {
        [headshotImageView sd_setImageWithURL: [NSURL URLWithString: profilePic]
                             placeholderImage: [UIImage imageNamed: @"member_back_head.png"]];
    }
    headshotImageView.layer.cornerRadius = 18;
    headshotImageView.clipsToBounds = YES;
    headshotImageView.layer.borderColor = [UIColor thirdGrey].CGColor;
    headshotImageView.layer.borderWidth = 0.5;
    
    [horzLayout1 addSubview: headshotImageView];
    
    // inputTextView
    inputTextView = [[UITextView alloc] init];
//    inputTextView = [[MintAnnotationChatView alloc] init];
    inputTextView.myLeftMargin = inputTextView.myRightMargin = 0;
    inputTextView.wrapContentWidth = YES;
    inputTextView.wrapContentHeight = YES;
    inputTextView.myWidth = self.contentLayout.frame.size.width - 16 * 2 - headshotImageView.frame.size.width - 8;
//    inputTextView.myHeight = 36.0;
    
    CGFloat maxValue = [UIScreen mainScreen].bounds.size.height - 100 - 16*2 + 25 - 16 - 36 - 120;
    NSLog(@"maxValue: %f", maxValue);
    inputTextView.heightDime.min(36.0).max(maxValue);
    
    inputTextView.delegate = self;
    inputTextView.textColor = [UIColor firstGrey];
    inputTextView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    inputTextView.backgroundColor = [UIColor thirdGrey];
    inputTextView.layer.cornerRadius = kCornerRadius;
    inputTextView.inputAccessoryView = toolBarForDoneBtn;
    [horzLayout1 addSubview: inputTextView];
    
    placeHolderNameLabel = [[UILabel alloc] initWithFrame: CGRectMake(13, 10, 0, 0)];
    placeHolderNameLabel.numberOfLines = 0;
    placeHolderNameLabel.text = @"有什麼想表達的嗎?";
    placeHolderNameLabel.textColor = [UIColor hintGrey];
    
    [placeHolderNameLabel sizeToFit];
    [LabelAttributeStyle changeGapString: placeHolderNameLabel content: placeHolderNameLabel.text];
    [inputTextView addSubview: placeHolderNameLabel];
    
    inputTextView.font = [UIFont systemFontOfSize: 14.f];
    placeHolderNameLabel.font = [UIFont systemFontOfSize: 14.f];
    
    inputTextView.text = @"";
    
    if ([inputTextView.text isEqualToString: @""]) {
        placeHolderNameLabel.alpha = 1;
    } else {
        placeHolderNameLabel.alpha = 0;
    }
    
    // btnHorzLayout
    MyLinearLayout *horzLayout2 = [MyLinearLayout linearLayoutWithOrientation: MyLayoutViewOrientation_Horz];
    horzLayout2.myTopMargin = 16;
    horzLayout2.myBottomMargin = 8;
    horzLayout2.myRightMargin = 0;
    horzLayout2.myHeight = 36.0;
    [self.contentLayout addSubview: horzLayout2];
    
    UIButton *clearDataBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearDataBtn addTarget:self
                     action:@selector(clearData:)
           forControlEvents:UIControlEventTouchUpInside];
    [clearDataBtn setTitle:@"清除" forState:UIControlStateNormal];
    [clearDataBtn setTitleColor: [UIColor firstGrey] forState: UIControlStateNormal];
    clearDataBtn.titleLabel.font = [UIFont boldSystemFontOfSize: 18.0];
    clearDataBtn.frame = CGRectMake(0.0, 0.0, 90.0, 36.0);
    clearDataBtn.layer.cornerRadius = kCornerRadius;
    clearDataBtn.backgroundColor = [UIColor thirdGrey];
    clearDataBtn.myRightMargin = 8;
    [LabelAttributeStyle changeGapString: clearDataBtn.titleLabel content: clearDataBtn.titleLabel.text];
    [horzLayout2 addSubview:clearDataBtn];
    
    UIButton *sendDataButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendDataButton addTarget:self
                       action:@selector(sendData:)
             forControlEvents:UIControlEventTouchUpInside];
    [sendDataButton setTitle:@"送出" forState:UIControlStateNormal];
    [sendDataButton setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    sendDataButton.titleLabel.font = [UIFont boldSystemFontOfSize: 18.0];
    sendDataButton.frame = CGRectMake(0.0, 0.0, 90.0, 36.0);
    sendDataButton.layer.cornerRadius = kCornerRadius;
    sendDataButton.backgroundColor = [UIColor firstMain];
    sendDataButton.myRightMargin = 16;
    sendDataButton.myLeftMargin = 8;
    [LabelAttributeStyle changeGapString: sendDataButton.titleLabel content: sendDataButton.titleLabel.text];
    [horzLayout2 addSubview:sendDataButton];
    
    [self addHorizontalLine];
    
    UITableView *tableView = [[UITableView alloc] init];
    tableView.myTopMargin = tableView.myBottomMargin = 0;
    tableView.myLeftMargin = tableView.myRightMargin = 0;
    tableView.weight = 1;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.allowsSelection = NO;
    tableView.dataSource = self;
    tableView.delegate = self;
    self.tableView = tableView;
    
    [self.contentLayout addSubview: tableView];
}

#pragma mark -
- (void)setupContentLayoutCornerRadius {
    NSLog(@"");
    NSLog(@"setupContentLayoutCornerRadius");
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect: self.contentLayout.bounds byRoundingCorners: (UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii: CGSizeMake(16, 16)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.contentLayout.bounds;
    maskLayer.path = maskPath.CGPath;
    self.contentLayout.layer.mask = maskLayer;
}

- (void)addHorizontalLine {
    NSLog(@"");
    NSLog(@"addHorizontalLine");
    UIView *horizontalLineView = [UIView new];
    horizontalLineView.backgroundColor = [UIColor thirdGrey];
    horizontalLineView.myHeight = 0.5;
    horizontalLineView.myLeftMargin = horizontalLineView.myRightMargin = 0;
    horizontalLineView.myTopMargin = horizontalLineView.myBottomMargin = 8;
    [self.contentLayout addSubview: horizontalLineView];
}

#pragma mark - UIButton Selector Methods
- (void)sendData:(UIButton *)btn {
    NSLog(@"sendData");
    
    NSLog(@"inputTextView.text: %@", inputTextView.text);
    NSLog(@"tempStr: %@", tempStr);
    
    NSUInteger length;
    length = inputTextView.text.length;
    
    NSLog(@"length: %lu", (unsigned long)length);
    
    if (![inputTextView.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]].length) {
        NSLog(@"string is all whitespace or newline");
        
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor firstGrey];
        
        [self.view.superview makeToast: @"不能發送空白訊息"
                              duration: 2.0
                              position: CSToastPositionBottom
                                 style: style];
    } else if ([inputTextView.text isEqualToString: tempStr]) {
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageColor = [UIColor whiteColor];
        style.backgroundColor = [UIColor firstGrey];
        
        [self.view.superview makeToast: @"不可連續發送"
                              duration: 2.0
                              position: CSToastPositionBottom
                                 style: style];
    } else {
        [self insertMessage: inputTextView.text];
    }
    // tempStr is to check the message is the same or not
    // to avoid the button being press in a short time.
    tempStr = inputTextView.text;
    
    inputTextView.text = @"";
    placeHolderNameLabel.alpha = 1;
    [self.view endEditing: YES];
}

- (void)clearData:(UIButton *)btn {
    NSLog(@"clearData");
    inputTextView.text = @"";
    placeHolderNameLabel.alpha = 1;
}

#pragma mark - dismissKeyboard
- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - UITextViewDelegate Methods
- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text {
    NSString *currentText = textView.text;
    NSLog(@"currentText.length: %lu", (unsigned long)currentText.length);
    NSString *updatedText = [currentText stringByReplacingCharactersInRange: range withString: text];
    NSLog(@"updatedText.length: %lu", (unsigned long)updatedText.length);
    
    return updatedText.length <= 128;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    NSLog(@"");
    NSLog(@"textViewDidBeginEditing");
    //    selectTextView = textView;
    
    NSLog(@"inputTextView.selectedRange: %@", NSStringFromRange(inputTextView.selectedRange));
    
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
    
    NSLog(@"inputTextView.selectedRange: %@", NSStringFromRange(inputTextView.selectedRange));
    
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
        NSLog(@"inputTextView.selectedRange.location: %lu", (unsigned long)inputTextView.selectedRange.location);
        
        // if there is a tag after textView selectedRange then
        // location of tagArray data need to be changed
        
        NSLog(@"oldInputText: %@", oldInputText);
        NSLog(@"inputTextView.text: %@", inputTextView.text);
        NSLog(@"sendingType: %@", tagDic[@"sendingType"]);
        
        if ([oldInputText containsString: tagDic[@"sendingType"]]) {
            if ([inputTextView.text containsString: tagDic[@"sendingType"]]) {
                NSLog(@"Tag Text didn't change");
            } else {
                NSLog(@"Tag Text has been modified");
                dicForDeletion = [tagDic copy];
            }
        }
        
        if (oldLocation > inputTextView.selectedRange.location) {
            NSLog(@"oldLocation > inputTextView.selectedRange.location");
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
        NSLog(@"inputTextView.text: %@", inputTextView.text);
        
        if (oldInputText.length < inputTextView.text.length) {
            NSLog(@"oldInputText.length < inputTextView.text.length");
            oldInputText = [oldInputText stringByReplacingOccurrencesOfString: dicForDeletion[@"sendingType"] withString: [self oneCharacterBeforeCursor: textView]];
            cursorRange.location = [dicForDeletion[@"location"] integerValue] + 1;
        } else {
            NSLog(@"oldInputText.length > inputTextView.text.length");
            oldInputText = [oldInputText stringByReplacingOccurrencesOfString: dicForDeletion[@"sendingType"] withString: @""];
            cursorRange.location = [dicForDeletion[@"location"] integerValue];
        }
        NSLog(@"oldInputText: %@", oldInputText);
        textView.text = oldInputText;
        
        // Change location to the correct one
        [tagArray removeAllObjects];
        tagArray = nil;
        tagArray = [[self resetTagArray: inputTextView.text] mutableCopy];
        
        inputTextView.attributedText = [self setTextColor: tagArray];
        
        NSLog(@"After replacing old cursor range");
        [textView setSelectedRange: cursorRange];
        NSLog(@"textView.selectedRange: %@", NSStringFromRange(textView.selectedRange));
        
        NSLog(@"inputTextView.text: %@", inputTextView.text);
    }
    
    // Reset text attributes for after lighting some texts
    inputTextView.typingAttributes = self.textAttributes;
    
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
    
    NSLog(@"inputTextView.text.length: %lu", (unsigned long)inputTextView.text.length);
    
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
                    
                    if ([dic[@"result"] boolValue]) {
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
                    } else {
                        NSLog(@"失敗： %@", dic[@"message"]);
                        NSString *msg = dic[@"message"];
                        
                        if (msg == nil) {
                            msg = NSLocalizedString(@"Host-NotAvailable", @"");
                        }
                        [self showCustomErrorAlert: msg];
                    }
                }
            }
        });
    });
}

#pragma mark - UITapGestureRecognizer Selector Handler Method
// Method below is to achieve the TouchUpInside Behavior
- (void)handleTapFromView: (UITapGestureRecognizer *)sender
{
    NSLog(@"handleTapFromView");
    [self slideOut];
    
    if (self.customViewBlock) {
        self.customViewBlock(sender.view.tag, isTouchDown, sender.view.accessibilityIdentifier);
    }
    
    /*
     if (sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateChanged) {
     sender.view.backgroundColor = [UIColor lightGrayColor];
     } else if (sender.state == UIGestureRecognizerStateEnded) {
     sender.view.backgroundColor = [UIColor clearColor];
     }
     */
}

// Methods below are to achieve the selected behavior
// If executing slideOut here, then the TouchUpInside behavior can not be achieved
- (void)touchesBegan:(NSSet<UITouch *> *)touches 
           withEvent:(UIEvent *)event {
//    NSLog(@"");
//    NSLog(@"touchesBegan");
//    NSLog(@"");
    
    UITouch *touch = [touches anyObject];
    NSLog(@"touch.view: %@", touch.view);
    NSLog(@"touch.view.tag: %ld", touch.view.tag);
    
    isTouchDown = YES;
    
    if (touch.view.tag != 0 && touch.view.tag != 100 && touch.view.tag != 200 && touch.view.tag != 300) {
        touch.view.backgroundColor = [UIColor thirdMain];
    }
    
    if (touch.view.tag != 300 && touch.view.tag != 0) {
        [self slideOut];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches
           withEvent:(UIEvent *)event {
//    NSLog(@"");
//    NSLog(@"touchesEnded");
//    NSLog(@"");
    
    UITouch *touch = [touches anyObject];
    
    if (touch.view.tag != 0 && touch.view.tag != 100 && touch.view.tag != 200 && touch.view.tag != 300) {
        touch.view.backgroundColor = [UIColor clearColor];
    }
    
    if (isTouchDown) {
        isTouchDown = NO;
        /*
         if (self.customViewBlock) {
         self.customViewBlock(touch.view.tag, isTouchDown);
         }
         */
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches
               withEvent:(UIEvent *)event {
//    NSLog(@"");
//    NSLog(@"touchesCancelled");
//    NSLog(@"");
    
    UITouch *touch = [touches anyObject];
    
    if (touch.view.tag != 0 && touch.view.tag != 100 && touch.view.tag != 200 && touch.view.tag != 300) {
        touch.view.backgroundColor = [UIColor clearColor];
    }
    
    if (isTouchDown) {
        isTouchDown = NO;
        
        /*
         if (self.customViewBlock) {
         self.customViewBlock(touch.view.tag, isTouchDown);
         }
         */
    }
}

/*
#pragma mark - Notifications for Keyboard
// Call this method somewhere in your view controller setup code.
- (void)addKeyboardNotification {
    NSLog(@"addKeyboardNotification");
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)removeKeyboardNotification {
    NSLog(@"removeKeyboardNotification");
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIKeyboardWillShowNotification
                                                  object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIKeyboardWillHideNotification
                                                  object: nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWillShow:(NSNotification *)aNotification {
    NSLog(@"");
    NSLog(@"keyboardWillShow");
    NSDictionary *info = [aNotification userInfo];
    kbSize = [[info objectForKey: UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSLog(@"kbSize: %@", NSStringFromCGSize(kbSize));
    
    NSLog(@"Before changing ");
    NSLog(@"self.actionSheetView.frame.origin.y: %f", self.actionSheetView.frame.origin.y);
    CGRect rect = self.actionSheetView.frame;
    rect.origin.y -= kbSize.height;
    self.actionSheetView.frame = rect;

    NSLog(@"After changing ");
    NSLog(@"self.actionSheetView.frame.origin.y: %f", self.actionSheetView.frame.origin.y);
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification *)aNotification {
    NSLog(@"");
    NSLog(@"keyboardWillBeHidden");
    
    NSLog(@"Before changing ");
    NSLog(@"self.actionSheetView.frame.origin.y: %f", self.actionSheetView.frame.origin.y);
    
    CGRect rect = self.actionSheetView.frame;
    rect.origin.y += kbSize.height;
    self.actionSheetView.frame = rect;
    
    kbSize = CGSizeZero;
    
    NSLog(@"After changing ");
    NSLog(@"self.actionSheetView.frame.origin.y: %f", self.actionSheetView.frame.origin.y);
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

- (UIView *)createContainerView: (NSString *)msg {
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
            } else if ([protocolName isEqualToString: @"filterUserContentForSearchText"]) {
                [weakSelf filterUserContentForSearchText: text];
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
