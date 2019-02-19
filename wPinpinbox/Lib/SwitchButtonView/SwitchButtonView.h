//
//  SwitchButton.h
//  wPinpinbox
//
//  Created by Antelis on 2018/11/13.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SwitchButtonViewDelegate
- (void)didFinishedSwitchAnimation;
@end

@interface SwitchButtonView : UIView
@property (nonatomic) UIButton *main;
@property (nonatomic) UIButton *switchBtn;
@property (nonatomic) id<SwitchButtonViewDelegate> switchDelegate;

- (id)initWithFrame:(CGRect)frame
      mainImageName:(NSString *)mainImageName
    switchImageName:(NSString * _Nullable)switchImageName;

- (void)setSwitchButtons:(UIButton *)main
               switchBtn:(UIButton * _Nullable)switchBtn;

- (void)addTarget:(id)target
     mainSelector:(SEL)mainSelector
   switchSelector:(SEL)switchSelector;

- (void)switchOnWithAnimation;
- (void)switchOffWithAnimation;

- (void)setViewHidden:(BOOL)hidden;
@end


@interface CustomTintButton : UIButton
@end


@interface CustomTintBarItem : UITabBarItem
@end

@interface UIKernedButton : UIButton
@property IBInspectable CGFloat spacing;
@end

@interface UIKernedLabel : UILabel
@property IBInspectable CGFloat spacing;
@end


typedef enum
{
    UIImageViewAlignmentMaskCenter = 0,
    
    UIImageViewAlignmentMaskLeft   = 1,
    UIImageViewAlignmentMaskRight  = 2,
    UIImageViewAlignmentMaskTop    = 4,
    UIImageViewAlignmentMaskBottom = 8,
    
    UIImageViewAlignmentMaskBottomLeft = UIImageViewAlignmentMaskBottom | UIImageViewAlignmentMaskLeft,
    UIImageViewAlignmentMaskBottomRight = UIImageViewAlignmentMaskBottom | UIImageViewAlignmentMaskRight,
    UIImageViewAlignmentMaskTopLeft = UIImageViewAlignmentMaskTop | UIImageViewAlignmentMaskLeft,
    UIImageViewAlignmentMaskTopRight = UIImageViewAlignmentMaskTop | UIImageViewAlignmentMaskRight,
    
}UIImageViewAlignmentMask;

typedef UIImageViewAlignmentMask UIImageViewAignmentMask __attribute__((deprecated("Use UIImageViewAlignmentMask. Use of UIImageViewAignmentMask (misspelled) is deprecated.")));



@interface UIImageViewAligned : UIImageView

// Just in case you need access to the inner image view
@property (nonatomic, readonly) UIImageView* realImageView;

@end

NS_ASSUME_NONNULL_END
