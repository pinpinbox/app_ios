//
//  ExProgressView.h
//  PinpinboxShareExtension
//
//  Created by Antelis on 2018/12/26.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExProgressView : UIView
@property (nonatomic) UIImageView *iconView;
- (void)showStartAnimating;
- (void)hideStopAnimating;
@end

NS_ASSUME_NONNULL_END
