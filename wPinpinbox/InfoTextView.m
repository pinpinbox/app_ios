//
//  UITextView+PlaceHolder.m
//  wPinpinbox
//
//  Created by Antelis on 2018/10/29.
//  Copyright © 2018 Angus. All rights reserved.
//


#import "InfoTextView.h"
@implementation InfoTextView

+ (UIColor *)defaultPlaceholderColor {
    static UIColor *dColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dColor = [UIColor lightTextColor];
    });
    return dColor;
}

- (UIColor *) placeholderColor {
    if (self.placeholderLabel)
        return self.placeholderLabel.textColor;
    
    return [InfoTextView defaultPlaceholderColor];
}
- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    [self checkPlaceholderLabel];
    self.placeholderLabel.textColor = placeholderColor;
}
- (NSString *)placeholder {
    if (self.placeholderLabel)
        return self.placeholderLabel.text;
    
    return @"";
}
- (void)setPlaceholder:(NSString *)placeholder {
    [self checkPlaceholderLabel];
    self.placeholderLabel.text = placeholder;
    
    
}
//- (UILabel *)placeholderLabel {
//    UILabel *label = obj_getAssociatedObject(self, @selector(placeholderLabel));
//    if (!label) {
//
//    }
//    return label;
//}
- (void)checkPlaceholderLabel {
    if (self.placeholderLabel == nil ) {
        self.placeholderLabel = [[UILabel alloc] init];
        self.placeholderLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.placeholderLabel];
        self.textStorage.delegate = self;
        
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize s = self.frame.size;
    if (self.placeholderLabel && !self.placeholderLabel.hidden) {
        NSString *sample = self.placeholder? self.placeholder :@"123";
        CGSize ss = [sample sizeWithAttributes:@{NSFontAttributeName: self.font}];
        
        self.placeholderLabel.frame = CGRectMake(8, (s.height-ss.height)/2, s.width , ss.height);
    }
}

- (void)textStorage:(NSTextStorage *)textStorage willProcessEditing:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delta {
    
    if (self.placeholderLabel ) {
        self.placeholderLabel.hidden = !(textStorage.string.length < 1);
    }
    
}
- (void)setFont:(UIFont *)font {
    if (self.placeholderLabel ) {
        self.placeholderLabel.font = font;
    }
    
    [super setFont:font];
}

@end
