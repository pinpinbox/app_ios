//
//  InfoTextView.h
//  wPinpinbox
//
//  Created by Antelis on 2018/10/29.
//  Copyright © 2018 Angus. All rights reserved.
//

#ifndef UITextView_Placeholder_h
#define UITextView_Placeholder_h

@import UIKit;
@import Foundation;

@interface InfoTextView: UITextView<NSTextStorageDelegate>
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic) IBInspectable NSString *placeholder;
@property (nonatomic) IBInspectable UIColor *placeholderColor;
+ (UIColor *)defaultPlaceholderColor;
@end


#endif /* UITextView_Placeholder_h */
