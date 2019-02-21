//
//  CooperationInfoViewController.h
//  wPinpinbox
//
//  Created by David on 2018/10/1.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^buttonTouch)(BOOL selected);
typedef void(^buttonTap)(NSInteger tag, NSString *identifierStr);
typedef void(^viewTouch)(NSInteger tagId, BOOL isTouchDown, NSString *identifierStr);

@class CooperationViewController;
@protocol CooperationInfoViewControllerDelegate <NSObject>
- (void)actionSheetViewDidSlideOut:(UIViewController *)controller;
@end

@interface CooperationInfoViewController : UIViewController
@property (weak) id <CooperationInfoViewControllerDelegate> delegate;

@property (copy, nonatomic) buttonTouch customButtonBlock;
@property (copy, nonatomic) viewTouch customViewBlock;
@property (copy, nonatomic) buttonTap customButtonTapBlock;
@property (strong, nonatomic) NSString *infoStr;
@property (strong, nonatomic) NSString *topicStr;
@property (nonatomic) BOOL hideQuestionBtn;

- (void)slideOut;
//- (void)addSelectItem:(NSString *)imgName title:(NSString *)title btnStr:(NSString *)btnStr tagInt:(NSInteger)tagInt;

- (void)addSelectItem:(NSString *)imgName title:(NSString *)title btnStr:(NSString *)btnStr tagInt:(NSInteger)tagInt identifierStr:(NSString *)identifierStr;
- (void)addSelectItem:(NSString *)imgName title:(NSString *)title btnStr:(NSString *)btnStr tagInt:(NSInteger)tagInt identifierStr:(NSString *)identifierStr isCollected:(BOOL)isCollected;
- (void)addSelectButtons:(NSArray *)btnStrs identifierStrs:(NSArray *)identifierStrs;
- (void)addHorizontalLine;
@end

NS_ASSUME_NONNULL_END
