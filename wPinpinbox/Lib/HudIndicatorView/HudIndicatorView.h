//
//  HudIndicatorView.h
//  wPinpinbox
//
//  Created by Antelis on 2018/11/23.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//  preview icon image in progresshud
@interface HudIndicatorView: UIView
- (void)addIconWithIdentifier:(UIImage *)icon identifier:(NSString *)identifier;
- (void)removeIconWithIdentifier:(NSString *)identifier;
@end

NS_ASSUME_NONNULL_END
