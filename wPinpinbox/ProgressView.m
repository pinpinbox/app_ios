//
//  ProgressView.m
//  ZDT-DownloadVideoObjC
//
//  Created by Szabolcs Sztanyi on 15/04/15.
//  Copyright (c) 2015 Szabolcs Sztanyi. All rights reserved.
//

#import "ProgressView.h"

@interface ProgressView ()
// to show the percentage
@property (nonatomic, strong) UILabel *progressLabel;
// label that shows the total and downloaded size
@property (nonatomic, strong) UILabel *sizeProgressLabel;

 // the layer that shows the actual progress
@property (nonatomic, strong) CAShapeLayer *progressLayer;
// layer to show the dashed circle layer
@property (nonatomic, strong) CAShapeLayer *dashedLayer;
@end

@implementation ProgressView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView
{
    self.backgroundColor = [UIColor clearColor];
    [self createProgressLayer];
    [self createLabel];
}

- (void)createProgressLayer
{
    CGFloat startAngle = M_PI_2;
    CGFloat endAngle = M_PI * 2 + M_PI_2;
    CGPoint centerPoint = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2);
    
    self.progressLayer = [[CAShapeLayer alloc] init];
    self.progressLayer.path = [UIBezierPath bezierPathWithArcCenter:centerPoint radius:CGRectGetWidth(self.frame)/2 startAngle:startAngle endAngle:endAngle clockwise:YES].CGPath;
    self.progressLayer.backgroundColor = [UIColor clearColor].CGColor;
    self.progressLayer.fillColor = nil;
    self.progressLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.progressLayer.lineWidth = 4.0;
    self.progressLayer.strokeStart = 0.0;
    self.progressLayer.strokeEnd = 0.0;
    [self.layer addSublayer:self.progressLayer];
    
    self.dashedLayer = [[CAShapeLayer alloc] init];
    self.dashedLayer.strokeColor = [UIColor colorWithWhite:1.0 alpha:0.5].CGColor;
    self.dashedLayer.fillColor = nil;
    self.dashedLayer.lineDashPattern = @[@(2), @(4)];
    self.dashedLayer.lineJoin = @"round";
    self.dashedLayer.lineWidth = 2.0;
    self.dashedLayer.path = self.progressLayer.path;
    
    [self.layer insertSublayer:self.dashedLayer below:self.progressLayer];
}

- (void)createLabel
{
    self.progressLabel = [[UILabel alloc] init];
    self.progressLabel.textColor = [UIColor whiteColor];
    self.progressLabel.textAlignment = NSTextAlignmentCenter;
    self.progressLabel.text = @"0 %";
    self.progressLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:40.0];
    self.progressLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.progressLabel];
    // add constraints
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.progressLabel attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.progressLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    // label to show the already downloaded size and the total size of the file
    self.sizeProgressLabel = [[UILabel alloc] init];
    self.sizeProgressLabel.textColor = [UIColor whiteColor];
    self.sizeProgressLabel.text = @"0.0 MB / 0.0 MB";
    self.sizeProgressLabel.textAlignment = NSTextAlignmentCenter;
    self.sizeProgressLabel.font = [UIFont fontWithName:@"HelveticeNeue-Light" size:10.0];
    self.sizeProgressLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.sizeProgressLabel];
    // add constraints
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.sizeProgressLabel attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.progressLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.sizeProgressLabel attribute:NSLayoutAttributeTop multiplier:1.0 constant:-10.0]];
}

- (float)convertFileSizeToMegabyte:(float)sizeToConvert
{
    return (sizeToConvert / 1024) / 1024;
}

#pragma mark - public methods
- (void)updateProgressViewLabelWithProgress:(float)progress
{
    self.progressLabel.text = [NSString stringWithFormat:@"%.0f %@", progress, @"%"];
}

- (void)updateProgressViewWithTotalSent:(float)totalSent andTotalFileSize:(float)fileSize
{
    self.sizeProgressLabel.text = [NSString stringWithFormat:@"%.1f MB / %.1f MB", [self convertFileSizeToMegabyte:totalSent], [self convertFileSizeToMegabyte:fileSize]];
}

- (void)animateProgressViewToProgress:(float)progress
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.fromValue = @(self.progressLayer.strokeEnd);
    animation.toValue = @(progress);
    animation.duration = 0.2;
    animation.fillMode = kCAFillModeForwards;
    
    self.progressLayer.strokeEnd = progress;
    [self.progressLayer addAnimation:animation forKey:@"animation"];
}

- (void)hideProgressView
{
    self.progressLayer.strokeEnd = 0.0;
    [self.progressLayer removeAllAnimations];
}

@end
