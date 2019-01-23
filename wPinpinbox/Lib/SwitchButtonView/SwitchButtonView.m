//
//  SwitchButton.m
//  wPinpinbox
//
//  Created by Antelis on 2018/11/13.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "SwitchButtonView.h"
#import "UIColor+HexString.h"
@interface SwitchButtonView()
@property (nonatomic) CALayer *connectorLayer;
@property (nonatomic) NSLayoutConstraint *heightConstraint;
@end

@implementation SwitchButtonView
- (id)initWithFrame:(CGRect)frame
      mainImageName:(NSString *)mainImageName
    switchImageName:(NSString * _Nullable)switchImageName {
    self = [super initWithFrame:frame];
    if (self){
        CGSize s = frame.size;
        
        if (!self.connectorLayer) {
            self.connectorLayer = [[CALayer alloc] init];
            self.connectorLayer.backgroundColor = [UIColor whiteColor].CGColor;
            [self.layer addSublayer:self.connectorLayer];
        }
        
        self.switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];//[[UIButton alloc] initWithFrame:
        self.switchBtn.frame = CGRectMake(0,0, s.width*0.8, s.width*0.8);
        self.main = [UIButton buttonWithType:UIButtonTypeCustom];
        //[self.main setBackgroundColor:[UIColor grayColor]];
        [self addSubview:self.switchBtn];
        [self addSubview:self.main];
        
        self.main.frame = CGRectMake(0, 0, s.width, s.width);
        self.main.layer.cornerRadius = s.width/2;
        //self.main.clipsToBounds = YES;
        
        if (!switchImageName ) {
            switchImageName = @"icon_delete_pink_120x120";
        }
        if (!mainImageName) {
            mainImageName = @"MainImage";
        }
        
        [self.switchBtn setImage:[UIImage imageNamed:switchImageName] forState:UIControlStateNormal];
        [self.main setImage:[UIImage imageNamed:mainImageName] forState:UIControlStateNormal];
        
        self.switchBtn.center = self.main.center;
        self.switchBtn.hidden = YES;
    }
    return self;
}

- (void)setSwitchButtons:(UIButton *)main
               switchBtn:(UIButton * _Nullable)switchBtn {
    
    CGSize s = self.frame.size;
    
    if (!self.connectorLayer) {
        self.connectorLayer = [[CALayer alloc] init];
        self.connectorLayer.backgroundColor = [UIColor whiteColor].CGColor;
        [self.layer addSublayer:self.connectorLayer];
    }
    if(!switchBtn) {
        self.switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.switchBtn setImage:[UIImage imageNamed:@"icon_delete_pink_120x120"] forState:UIControlStateNormal];
    }
    else
        _switchBtn = switchBtn;
    
    self.switchBtn.frame = CGRectMake(0,0, s.width*0.8, s.width*0.8);
    if (!main)
        self.main = [UIButton buttonWithType:UIButtonTypeCustom];
    else
        _main = main;
    //[self.main setBackgroundColor:[UIColor grayColor]];
    [self addSubview:self.switchBtn];
    [self addSubview:self.main];
    
    self.main.frame = CGRectMake(0, 0, s.width, s.width);
    self.main.layer.cornerRadius = s.width/2;
    //self.main.clipsToBounds = YES;
    
    self.switchBtn.center = self.main.center;
    self.switchBtn.hidden = YES;
    
}
- (void)setViewHidden:(BOOL)hidden {
    

    CGPoint p = self.frame.origin;
    CGFloat w = self.frame.size.width;
    if (hidden) {
        self.frame = CGRectMake(p.x, p.y, w, w);
        CGSize s = self.frame.size;
        self.connectorLayer.frame = CGRectMake(s.width*0.25, s.width*0.5, s.width*0.5, 0);
        self.switchBtn.center = self.main.center;
        //self.heightConstraint.constant = 0;
        self.frame = CGRectMake(p.x, p.y, w, 0);
        [self updateConstraints];
        [self layoutIfNeeded];
    } else {
        self.frame = CGRectMake(p.x, p.y, w, w);
        [self updateConstraints];
        self.heightConstraint.constant = w;
        [self layoutIfNeeded];
        
        
    }
    
}

- (void)addTarget:(id)target
     mainSelector:(SEL)mainSelector
   switchSelector:(SEL)switchSelector {
    
    CGSize s = self.frame.size;
    self.main.frame = CGRectMake(0, 0, s.width, s.width);
    self.main.layer.cornerRadius = s.width/2;
    //self.main.clipsToBounds = YES;
    
    [self.main addTarget:target action:mainSelector forControlEvents:UIControlEventTouchUpInside];
    [self.switchBtn addTarget:target action:switchSelector forControlEvents:UIControlEventTouchUpInside];
    
}
//- (void)setMain:(UIButton *)main {
//    _main = main;
//    [self setNeedsLayout];
//}
//- (void)setSwitchBtn:(UIButton *)switchBtn {
//    _switchBtn = switchBtn;
//    [self setNeedsLayout];
//}
- (void)switchOnWithAnimation {
    
    
    self.switchBtn.hidden = NO;
    
    CGPoint p = self.frame.origin;
    CGFloat w = self.frame.size.width;
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.frame = CGRectMake(p.x, p.y,w, w*2+4);
        
        //[self updateConstraints];
        self.switchBtn.frame = CGRectMake(0, (w*2+4)-w, w, w);
        self.switchBtn.layer.cornerRadius = w*0.4;
        
        CGSize s = self.frame.size;
        //if (self.switchBtn && !self.switchBtn.hidden) {
        self.connectorLayer.frame = CGRectMake(s.width*0.25, s.width*0.5, s.width*0.5, self.switchBtn.center.y - s.width*0.5);
        for (NSLayoutConstraint *c in  self.constraints ) {
            //NSLog(@"NSLayoutConstraint %@",c);
            if (c.firstAttribute == NSLayoutAttributeHeight) {
                c.constant = w*2+4;
                [self updateConstraints];
                break;
            }
            
        }
        [self layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        if (self.switchDelegate)
            [self.switchDelegate didFinishedSwitchAnimation];
    }];
    
    
}
- (void)switchOffWithAnimation {
    CGPoint p = self.frame.origin;
    CGFloat w = self.frame.size.width;
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.frame = CGRectMake(p.x, p.y, w, w);
        CGSize s = self.frame.size;
        self.connectorLayer.frame = CGRectMake(s.width*0.25, s.width*0.5, s.width*0.5, 0);
        self.switchBtn.center = self.main.center;
        
        for (NSLayoutConstraint *c in  self.constraints ) {
            NSLog(@"NSLayoutConstraint %@",c);
            if (c.firstAttribute == NSLayoutAttributeHeight) {
                c.constant = w;
                [self updateConstraints];
                break;
            }
            
        }
        [self layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        self.switchBtn.hidden = YES;
        if (self.switchDelegate)
            [self.switchDelegate didFinishedSwitchAnimation];
    }];
}

@end


@implementation CustomTintButton
- (void) setImage:(UIImage *)image forState:(UIControlState)state {
    //if (state == UIControlStateNormal) {
    UIImage *aimage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];        
    [super setImage:aimage forState:state];
    //}
}
@end

@implementation CustomTintBarItem
- (void)awakeFromNib {
    [super awakeFromNib];
    [self setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor colorFromHexString:@"#D4d4d4"]} forState:UIControlStateNormal];
    [self setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor colorFromHexString:@"#4d4d4d"]} forState:UIControlStateSelected];
    [self setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor colorFromHexString:@"#4d4d4d"]} forState:UIControlStateHighlighted];
}
@end

#pragma mark -
@interface NSMutableAttributedString (ForButton)
+ (NSMutableAttributedString*)attributedStringWithTitle:(NSString*)title fromExistingAttributedString:(NSAttributedString*)attributedString;
+ (NSMutableAttributedString*)attributedStringWithTitle:(NSString*)title font:(UIFont*)font color:(UIColor*)color;
- (NSRange)fullRange;
@end
@implementation NSMutableAttributedString(ForButton)
+ (NSMutableAttributedString*)attributedStringWithTitle:(NSString*)title fromExistingAttributedString:(NSAttributedString*)attributedString
{
    NSDictionary *attributes = [attributedString attributesAtIndex:0 effectiveRange:NULL];
    return [[NSMutableAttributedString alloc] initWithString:title attributes:attributes];
}

+ (NSMutableAttributedString*)attributedStringWithTitle:(NSString*)title font:(UIFont*)font color:(UIColor*)color
{
    NSMutableAttributedString* mutableTitle = [[NSMutableAttributedString alloc] initWithString:title];
    [mutableTitle addAttribute:NSFontAttributeName value:font range:[mutableTitle fullRange]];
    [mutableTitle addAttribute:NSForegroundColorAttributeName value:color range:[mutableTitle fullRange]];
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [mutableTitle addAttribute:NSParagraphStyleAttributeName value:style range:[mutableTitle fullRange]];
    return mutableTitle;
}
- (NSRange) fullRange {
    return NSMakeRange(0, self.length);
}
@end


@interface UIKernedLabel()
@property (nonatomic) CGFloat kernspace;
@end

@implementation UIKernedLabel
- (void)awakeFromNib {
    [super awakeFromNib];    
}
- (void)setAttributedText:(NSAttributedString *)attributedText
{
    if (!attributedText) return ;
    NSMutableAttributedString* mutableText = [attributedText mutableCopy];
    [mutableText addAttributes:@{NSKernAttributeName: @(_kernspace)} range:[mutableText fullRange]];
    NSMutableParagraphStyle *s = [[NSMutableParagraphStyle alloc] init];
    s.lineBreakMode = NSLineBreakByTruncatingTail;
    [mutableText addAttribute:NSParagraphStyleAttributeName value:s range:[mutableText fullRange]];
    [super setAttributedText:mutableText];
    [self setNeedsDisplay];
}

- (void)setText:(NSString *)text
{
    if (!text) return ;
    if (_kernspace <= 0)
        _kernspace = 1.5;
    NSMutableAttributedString* mutableText;
    if (self.attributedText && self.attributedText.length) {
        mutableText = [NSMutableAttributedString attributedStringWithTitle:text fromExistingAttributedString:self.attributedText];
    } else {
        mutableText = [NSMutableAttributedString attributedStringWithTitle:text font:self.font color:self.textColor];
        
    }
    
    [self setAttributedText:mutableText];
    
}
- (void)updateText {
    if (!self.text) {
        NSLog(@"text is null");
        return;
    }
    NSMutableAttributedString* mutableText;
    NSString *text = [NSString stringWithString: self.text];
    if (self.attributedText && self.attributedText.length) {
        mutableText = [NSMutableAttributedString attributedStringWithTitle:text fromExistingAttributedString:self.attributedText];
    } else {
        
        mutableText = [NSMutableAttributedString attributedStringWithTitle:text font:self.font color:self.textColor];
        
    }
    
    [self setAttributedText:mutableText];
}
- (CGFloat)spacing {
    return _kernspace;
}
- (void)setSpacing:(CGFloat)spacing {
    if (spacing >= 1.5) {
        _kernspace = spacing;
    }
    [self updateText];
}
@end

#pragma mark -
@interface UIKernedButton()
@property (nonatomic) CGFloat kernspace;
@end

@implementation UIKernedButton
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self != nil) {
        self.spacing = 1;
    }
    return self;
}
- (void)setAttributedTitle:(NSAttributedString *)title forState:(UIControlState)state
{
    if (!title) return ;
    NSMutableAttributedString* mutableTitle = [title mutableCopy];
    [mutableTitle addAttributes:@{NSKernAttributeName: @(self.spacing)} range:[mutableTitle fullRange]];
    [super setAttributedTitle:mutableTitle forState:state];
    [self setNeedsDisplay];
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    if (_kernspace <= 0)
        _kernspace = 1;
    
    if (!title) return ;
    
    NSMutableAttributedString* mutableTitle;
    if ([self attributedTitleForState:state]) {
        mutableTitle = [NSMutableAttributedString attributedStringWithTitle:title fromExistingAttributedString:[self attributedTitleForState:state]];
    } else {
        mutableTitle = [NSMutableAttributedString attributedStringWithTitle:title font:self.titleLabel.font color:[self titleColorForState:state]];
    }
    [self setAttributedTitle:mutableTitle forState:state];
}
- (void)updateTitle {
    [self setAttributedTitle:self.titleLabel.attributedText forState:UIControlStateNormal];
    [self setAttributedTitle:self.titleLabel.attributedText forState:UIControlStateDisabled];
}
- (CGFloat)spacing {
    return _kernspace;
}
- (void)setSpacing:(CGFloat)spacing {
    _kernspace = spacing;
    [self updateTitle];
}
@end

@implementation UIImageViewAligned

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}


- (id)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if (self)
    {
        [self commonInit];
        [self setImage:image];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
        [self commonInit];
    return self;
}

- (void)commonInit
{
    self.slim = NO;
    _realImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _realImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _realImageView.contentMode = self.contentMode;
    [self addSubview:_realImageView];
    
    
}

- (UIImage*)image
{
    return _realImageView.image;
}

- (void)setImage:(UIImage *)image
{
    if (!_realImageView) return;
    [_realImageView setImage:image];
    [_realImageView setFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [self setNeedsLayout];
}

- (void)setContentMode:(UIViewContentMode)contentMode
{
    [super setContentMode:contentMode];
    _realImageView.contentMode = contentMode;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    CGSize realsize = [self realContentSize];
    
    // Start centered
    CGRect realframe = CGRectMake((self.bounds.size.width - realsize.width)/2, (self.bounds.size.height - realsize.height) / 2, realsize.width, realsize.height);
    
    realframe.origin.y = 0;
    _realImageView.frame = realframe;
    self.layer.contents = nil;
}

- (CGSize)realContentSize
{
    CGSize size = self.bounds.size;
    
    if (self.image == nil)
        return size;
    
    switch (self.contentMode)
    {
        case UIViewContentModeScaleAspectFit:
        {
            float scalex = self.bounds.size.width / _realImageView.image.size.width;
            float scaley = self.bounds.size.height / _realImageView.image.size.height;
            float scale = MIN(scalex, scaley);

            size = CGSizeMake(_realImageView.image.size.width * scale, _realImageView.image.size.height * scale);
            break;
        }
            
        case UIViewContentModeScaleAspectFill:
        {
            float scalex = self.bounds.size.width / _realImageView.image.size.width;
            if (self.slim) {
                float scaley = self.bounds.size.height / _realImageView.image.size.height;
                float scale = MAX(scalex, scaley);
                scalex = scale;
            }
            
            size = CGSizeMake(_realImageView.image.size.width * scalex, _realImageView.image.size.height * scalex);
            break;
        }
            
        case UIViewContentModeScaleToFill:
        {
            float scalex = self.bounds.size.width / _realImageView.image.size.width;
            float scaley = self.bounds.size.height / _realImageView.image.size.height;
            
            size = CGSizeMake(_realImageView.image.size.width * scalex, _realImageView.image.size.height * scaley);
            break;
        }
            
        default:
            size = _realImageView.image.size;
            break;
    }
    
    return size;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [self.realImageView sizeThatFits:size];
}


@end

