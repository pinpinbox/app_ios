//
//  LabelAttributeStyle.h
//  wPinpinbox
//
//  Created by David on 11/01/2018.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LabelAttributeStyle : NSObject
+ (void)changeGapString:(UILabel *)label
                content:(NSString *)content;

+ (void)changeGapStringAndLineSpacingCenterAlignment:(UILabel *)label
                                             content:(NSString *)content;

+ (void)changeGapStringAndLineSpacingLeftAlignment:(UILabel *)label
                                           content:(NSString *)content;

+ (void)changeGapStringAndLineSpacingLeftAlignmentForTextView:(UITextView *)textView
                                                      content:(NSString *)content;

+ (void)changeGapStringForTextView:(UITextView *)textView
                           content:(NSString *)content
                             color:(UIColor *)color
                          fontSize:(CGFloat)fontSize;

+ (NSInteger)checkTagString: (NSString *)searchedString;
+ (NSMutableAttributedString *)convertToTagString:(NSString *)searchedString;
//+ (NSMutableAttributedString *)changeTextColor:(NSRange)tagRange stringForReplacement:(NSString *)stringForReplacement;
@end
