//
//  DDAUIActionSheetViewController.h
//  CustomActionSheetTest
//
//  Created by David on 7/31/17.
//  Copyright © 2017 vmage. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^buttonTouch)(BOOL selected);
typedef void(^buttonTouchForPreview)(BOOL selected, NSString *previewPageStr);
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
@property (copy, nonatomic) buttonTouchForPreview customButtonBlockForPreview;

@property (strong, nonatomic) NSString *topicStr;

- (void)slideOut;
//- (void)addSelectItem:(NSString *)imgName title:(NSString *)title btnStr:(NSString *)btnStr tagInt:(NSInteger)tagInt;

- (void)addSelectButtons:(NSArray *)btnStrs
          identifierStrs:(NSArray *)identifierStrs;

- (void)addSelectItemForPreviewPage:(BOOL)gridViewSelected
                        hasTextView:(BOOL)hasTextView
                     firstLabelText:(NSString *)firstLabelText
                    secondLabelText:(NSString *)secondLabelText
                     previewPageNum:(NSInteger)previewPageNum
                             tagInt:(NSInteger)tagInt
                      identifierStr:(NSString *)identifierStr;

- (void)addSelectItemForPreviewPage:(BOOL)gridViewSelected
                        hasTextView:(BOOL)hasTextView
                     firstLabelText:(NSString *)firstLabelText
                    secondLabelText:(NSString *)secondLabelText
                     previewPageNum:(NSInteger)previewPageNum
                         allPageNum:(NSInteger)allPageNum
                             tagInt:(NSInteger)tagInt
                      identifierStr:(NSString *)identifierStr;

- (void)addSelectItemForPreviewPage:(NSString *)imgName
                              title:(NSString *)title
                           horzLine:(BOOL)horzLine
                             btnStr:(NSString *)btnStr
                             tagInt:(NSInteger)tagInt
                      identifierStr:(NSString *)identifierStr;

- (void)addSelectItem:(NSString *)imgName
                title:(NSString *)title
               btnStr:(NSString *)btnStr
               tagInt:(NSInteger)tagInt
        identifierStr:(NSString *)identifierStr;

- (void)addSelectItem:(NSString *)imgName
                title:(NSString *)title
               btnStr:(NSString *)btnStr
               tagInt:(NSInteger)tagInt
        identifierStr:(NSString *)identifierStr
          isCollected:(BOOL)isCollected;

- (void)addHorizontalLine;

- (void)addSafeArea;
@end
