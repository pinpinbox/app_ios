//
//  DDAUIActionSheetViewController.h
//  CustomActionSheetTest
//
//  Created by David on 7/31/17.
//  Copyright © 2017 vmage. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^buttonTouch)(BOOL selected);
typedef void(^buttonTap)(NSInteger tag, NSString *identifierStr);
typedef void(^viewTouch)(NSInteger tagId, BOOL isTouchDown, NSString *identifierStr);

@class DDAUIActionSheetViewController;
@protocol DDAUIActionSheetViewControllerDelegate <NSObject>
- (void)actionSheetViewDidSlideOut:(DDAUIActionSheetViewController *)controller;
@end

@interface DDAUIActionSheetViewController : UIViewController

@property (weak) id <DDAUIActionSheetViewControllerDelegate> delegate;

@property (copy, nonatomic) buttonTouch customButtonBlock;
@property (copy, nonatomic) viewTouch customViewBlock;
@property (copy, nonatomic) buttonTap customButtonTapBlock;

@property (strong, nonatomic) NSString *topicStr;

- (void)slideOut;
//- (void)addSelectItem:(NSString *)imgName title:(NSString *)title btnStr:(NSString *)btnStr tagInt:(NSInteger)tagInt;

- (void)addSelectItem:(NSString *)imgName title:(NSString *)title btnStr:(NSString *)btnStr tagInt:(NSInteger)tagInt identifierStr:(NSString *)identifierStr;
- (void)addSelectItem:(NSString *)imgName title:(NSString *)title btnStr:(NSString *)btnStr tagInt:(NSInteger)tagInt identifierStr:(NSString *)identifierStr isCollected:(BOOL)isCollected;
- (void)addSelectButtons:(NSArray *)btnStrs identifierStrs:(NSArray *)identifierStrs;
- (void)addHorizontalLine;
@end
