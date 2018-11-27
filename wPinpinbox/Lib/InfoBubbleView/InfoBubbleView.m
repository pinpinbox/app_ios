//
//  InfoBubbleView.m
//  wPinpinbox
//
//  Created by Antelis on 2018/11/26.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "InfoBubbleView.h"
@interface InfoBubbleView()
@property(nonatomic) UIView *bubblebase;
@property (nonatomic) CAShapeLayer *tipLayer;
@end
@implementation InfoBubbleView
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    if (self) {
        self.tipPosition = InfoBubbleTipBottomLeft;
        self.tipLayer = [[CAShapeLayer alloc] init];
    }
    
    return self;
}
- (void)setTipPosition:(InfoBubbleTipPosition)tipPosition {
    _tipPosition = tipPosition;
    //CAShapeLayer *tip = [[CAShapeLayer alloc] init];
    if (!self.bubblebase) {
        self.bubblebase = [[UIView alloc] init];
        [self addSubview:self.bubblebase];
    }
    CGRect f = self.frame;
    UIBezierPath *path = [UIBezierPath bezierPath];
    switch (tipPosition) {
        case InfoBubbleTipTopRight: {
            self.bubblebase.frame = CGRectMake(0, 16, f.size.width, f.size.height-16);
            [path moveToPoint:CGPointMake(f.size.width, 0)];
            [path addLineToPoint:CGPointMake(f.size.width, 32)];
            [path addLineToPoint:CGPointMake(f.size.width -24, 16)];
            [path addQuadCurveToPoint:CGPointMake(f.size.width, 0) controlPoint:CGPointMake(f.size.width, 16)];
            [path closePath];
            
            [_tipLayer setPath:path.CGPath];
            [_tipLayer setFillColor:[UIColor whiteColor].CGColor];
            if (_tipLayer.superlayer == nil)
                [self.layer addSublayer:_tipLayer];
        }
            break;
        case InfoBubbleTipBottomLeft:
        case InfoBubbleTipBottomRight: {
            self.bubblebase.frame = CGRectMake(0, 0, f.size.width, f.size.height-16);
            if (tipPosition == InfoBubbleTipBottomLeft) {
                [path moveToPoint:CGPointMake(0, f.size.height)];
                [path addLineToPoint:CGPointMake(0, f.size.height-32)];
                [path addLineToPoint:CGPointMake(24, f.size.height-16)];
                [path addQuadCurveToPoint:CGPointMake(0, f.size.height) controlPoint:CGPointMake(0, f.size.height-16)];
                [path closePath];
            } else {
                [path moveToPoint:CGPointMake(f.size.width, f.size.height)];
                [path addLineToPoint:CGPointMake(f.size.width, f.size.height-32)];
                [path addLineToPoint:CGPointMake(f.size.width-24, f.size.height-16)];
                [path addQuadCurveToPoint:CGPointMake(f.size.width, f.size.height) controlPoint:CGPointMake(f.size.width, f.size.height-16)];
                [path closePath];
            }
            
            [_tipLayer setPath:path.CGPath];
            [_tipLayer setFillColor:[UIColor whiteColor].CGColor];
            if (_tipLayer.superlayer == nil) {
                _tipLayer.zPosition = -1;
                [self.layer addSublayer:_tipLayer];
            }
        }
            break;
        default:{
            self.bubblebase.frame = CGRectMake(0, 16, f.size.width, f.size.height-16);
            [path moveToPoint:CGPointMake(0, 0)];
            [path addLineToPoint:CGPointMake(0, 24)];
            [path addLineToPoint:CGPointMake(24, 16)];
            [path addQuadCurveToPoint:CGPointMake(0,0) controlPoint:CGPointMake(0,16)];
            [path closePath];
            
            [_tipLayer setPath:path.CGPath];
            [_tipLayer setFillColor:[UIColor whiteColor].CGColor];
            if (_tipLayer.superlayer == nil)
                [self.layer addSublayer:_tipLayer];
        }
            break;
    }
    [self sendSubviewToBack:self.bubblebase];
    self.bubblebase.backgroundColor = [UIColor whiteColor];
    self.bubblebase.layer.cornerRadius = 16;
    self.layer.shadowOffset = CGSizeMake(1, 5);
    self.layer.shadowRadius = 8;
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowColor = UIColor.blackColor.CGColor;
    
}
- (void)layoutSubviews {
    [super layoutSubviews];
    switch(_tipPosition) {
        case InfoBubbleTipBottomRight:
        {
            
        }
            break;
        case InfoBubbleTipBottomLeft:
        {
            
        }
            break;
        case InfoBubbleTipTopLeft:
        {
            
        }
            break;
        case InfoBubbleTipTopRight:
        {
            
        }
            break;
    }
    
}
@end
