//
//  NotifTabTableViewCell.m
//  wPinpinbox
//
//  Created by David on 5/10/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "NotifTabTableViewCell.h"
#import "UIColor+Extensions.h"
#import "MyLayout.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+HexString.h"

@implementation NotifTabTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.headshotImaveView.layer.cornerRadius = 4;
    self.headshotImaveView.clipsToBounds = YES;
    
    self.targetTypeImageView.layer.cornerRadius = 4;
    self.targetTypeImageView.clipsToBounds = YES;
    //self.targetTypeImageView.bounds = CGRectInset(self.frame, 2.0f, 2.0f);
    
    self.messageLabel.textColor = [UIColor firstGrey];
    self.messageLabel.wrapContentHeight = YES;
    self.targetTypeLabel.textColor = [UIColor secondGrey];

    self.insertTimeLabel.textColor = [UIColor secondGrey];
    
    // Change Cell Selection Color
    UIView *bgColorView = [[UIView alloc] init];
    [bgColorView setBackgroundColor:[UIColor thirdMain]];
//    bgColorView.layer.cornerRadius = 10;
    [self setSelectedBackgroundView:bgColorView];
}
- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    CGFloat sc = 1 / [UIScreen mainScreen].scale;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [UIColor colorFromHexString:@"d4d4d4"].CGColor);
    CGContextFillRect(ctx, CGRectMake(0, rect.size.height-1, self.frame.size.width, sc));
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
