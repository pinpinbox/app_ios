//
//  SwitchButton.m
//  wPinpinbox
//
//  Created by Antelis on 2018/11/13.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "SwitchButtonView.h"
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
        [self.main setBackgroundColor:[UIColor grayColor]];
        [self addSubview:self.switchBtn];
        [self addSubview:self.main];
        
        self.main.frame = CGRectMake(0, 0, s.width, s.width);
        self.main.layer.cornerRadius = s.width/2;
        self.main.clipsToBounds = YES;
        
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
    [self.main setBackgroundColor:[UIColor grayColor]];
    [self addSubview:self.switchBtn];
    [self addSubview:self.main];
    
    self.main.frame = CGRectMake(0, 0, s.width, s.width);
    self.main.layer.cornerRadius = s.width/2;
    self.main.clipsToBounds = YES;
    
    self.switchBtn.center = self.main.center;
    self.switchBtn.hidden = YES;
    
}
- (void)setViewHidden:(BOOL)hidden {
    

    CGPoint p = self.frame.origin;
    CGFloat w = self.frame.size.width;
    if (hidden) {
        self.frame = CGRectMake(p.x, p.y, w, 0);
        [self updateConstraints];
        self.heightConstraint.constant = 0;
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
    self.main.clipsToBounds = YES;
    
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
        
        [self updateConstraints];
        self.switchBtn.frame = CGRectMake(0, (w*2+4)-w, w, w);
        self.switchBtn.layer.cornerRadius = w*0.4;
        
        CGSize s = self.frame.size;
        //if (self.switchBtn && !self.switchBtn.hidden) {
        self.connectorLayer.frame = CGRectMake(s.width*0.25, s.width*0.5, s.width*0.5, self.switchBtn.center.y - s.width*0.5);
        //} else {
            
        //}
        
    } completion:^(BOOL finished) {
        for (NSLayoutConstraint *c in  self.constraints ) {
            NSLog(@"NSLayoutConstraint %@",c);
            if (c.firstAttribute == NSLayoutAttributeHeight) {
                c.constant = w*2+4;
                break;
            }
            
        }
        [self layoutIfNeeded];
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
        
    } completion:^(BOOL finished) {
        self.switchBtn.hidden = YES;
        for (NSLayoutConstraint *c in  self.constraints ) {
            NSLog(@"NSLayoutConstraint %@",c);
            if (c.firstAttribute == NSLayoutAttributeHeight) {
                c.constant = w;
                break;
            }
            
        }
        [self layoutIfNeeded];
        if (self.switchDelegate)
            [self.switchDelegate didFinishedSwitchAnimation];
    }];
}

@end
