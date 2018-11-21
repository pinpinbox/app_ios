//
//  MessageboardViewController.h
//  wPinpinbox
//
//  Created by Angus on 2015/12/14.
//  Copyright © 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^buttonTouch)(BOOL selected);
typedef void(^viewTouch)(NSInteger tagId, BOOL isTouchDown, NSString *identifierStr);

@class MessageboardViewController;
@protocol MessageboardViewControllerDelegate <NSObject>
- (void)actionSheetViewDidSlideOut:(MessageboardViewController *)controller;
- (void)gotMessageData;
@end

@interface MessageboardViewController : UIViewController
@property (weak) id <MessageboardViewControllerDelegate> delegate;

@property (copy, nonatomic) buttonTouch customButtonBlock;
@property (copy, nonatomic) viewTouch customViewBlock;

@property (strong, nonatomic) NSString *topicStr;
@property (strong, nonatomic) NSString *userName;

@property (strong, nonatomic) NSString *typeId;
@property (strong, nonatomic) NSString *type;

- (void)initialValueSetup;
- (void)getMessage;
- (void)slideIn;
- (void)slideOut;

@end
