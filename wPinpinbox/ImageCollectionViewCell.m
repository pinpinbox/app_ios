//
//  ImageCollectionViewCell.m
//  wPinpinbox
//
//  Created by David on 2018/7/23.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "ImageCollectionViewCell.h"
#import "UIColor+Extensions.h"
#import "GlobalVars.h"

@implementation ImageCollectionViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
    NSLog(@"awakeFromNib");
    [self setupBgV1];
    [self setupBgV2];
    [self setupBgV3];
    [self setupBgV4];
    [self setupFinalPage];
    
    self.alphaBgV.hidden = YES;
    self.giftImageBtn.hidden = YES;
    [self.giftImageBtn addTarget: self action: @selector(giftImageBtnPressed:) forControlEvents: UIControlEventTouchUpInside];
    
    self.videoBtn.hidden = YES;
    self.videoView.hidden = YES;
    self.ytPlayerView.hidden = YES;
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.frame = self.bounds;
    
    self.scrollView.delegate = self;
    self.scrollView.alwaysBounceVertical = NO;
    self.scrollView.alwaysBounceHorizontal = NO;
    self.scrollView.showsVerticalScrollIndicator = YES;
    [self.scrollView flashScrollIndicators];
    
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 3.0;    
    
    UITapGestureRecognizer *doubleTapGest = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleDoubleTapScrollView:)];
    doubleTapGest.numberOfTapsRequired = 2;
    [self.scrollView addGestureRecognizer: doubleTapGest];
}

- (void)setAlbumPoint:(NSInteger)albumPoint {
    NSLog(@"setAlbumPoint");
    NSLog(@"albumPoint: %ld", (long)albumPoint);
    
    self.sponsorTextFieldForBgV3.placeholder = [NSString stringWithFormat: @"最低額度%lu", (unsigned long)albumPoint];
    self.sponsorTextFieldForBgV4.placeholder = [NSString stringWithFormat: @"最低額度%lu", (unsigned long)albumPoint];
}

- (void)setUserPoint:(NSInteger)userPoint {
    NSLog(@"setUserPoint");
    NSLog(@"userPoint: %ld", (long)userPoint);
    self.currentPointLabelForBgV3.text = [NSString stringWithFormat: @"現有P點：%ld", (long)userPoint];
    self.currentPointLabelForBgV4.text = [NSString stringWithFormat: @"現有P點：%ld", (long)userPoint];
}

- (void)setupFinalPage {
    self.finalPageView.hidden = YES;
    self.finalPageImageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)setupBgV1 {
    self.bgV1.hidden = YES;
    self.bgV1.backgroundColor = [UIColor whiteColor];
    self.bgV1.layer.cornerRadius = kCornerRadius;
    
    self.topicLabelForBgV1.textColor = [UIColor firstGrey];
    
    self.exitBtnForBgV1.backgroundColor = [UIColor secondGrey];
    self.exitBtnForBgV1.layer.cornerRadius = kCornerRadius;
    [self.exitBtnForBgV1 setTitleColor: [UIColor firstGrey] forState: UIControlStateNormal];
    [self.exitBtnForBgV1 addTarget: self
                            action: @selector(exitBtnPressed:)
                  forControlEvents: UIControlEventTouchUpInside];
}

- (void)setupBgV2 {
    self.bgV2.hidden = YES;
    self.bgV2.backgroundColor = [UIColor whiteColor];
    self.bgV2.layer.cornerRadius = kCornerRadius;
    
    self.topicLabelForBgV2.textColor = [UIColor firstGrey];

    self.collectBtnForBgV2.backgroundColor = [UIColor firstMain];
    self.collectBtnForBgV2.layer.cornerRadius = kCornerRadius;
    [self.collectBtnForBgV2 setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    [self.collectBtnForBgV2 addTarget: self
                            action: @selector(collectBtnPressed:)
                  forControlEvents: UIControlEventTouchUpInside];
}

- (void)setupBgV3 {
    self.bgV3.hidden = YES;
    self.bgV3.backgroundColor = [UIColor whiteColor];
    self.bgV3.layer.cornerRadius = kCornerRadius;
    
    self.topicLabelForBgV3.textColor = [UIColor firstGrey];
    self.currentPointLabelForBgV3.textColor = [UIColor secondGrey];
    
    self.sponsorTextFieldForBgV3.backgroundColor = [UIColor thirdGrey];
    self.sponsorTextFieldForBgV3.delegate = self;
    
    self.sponsorLabelForBgV3.textColor = [UIColor firstGrey];
    
    self.sponsorTextFieldForBgV3.keyboardType = UIKeyboardTypeNumberPad;
    
    UIToolbar *numberToolBar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, 0, 320, 40)];
    numberToolBar.barStyle = UIBarStyleDefault;
    numberToolBar.items = [NSArray arrayWithObjects:
                           //[[UIBarButtonItem alloc] initWithTitle: @"取消" style: UIBarButtonItemStylePlain target: self action: @selector(cancelNumberPad)],
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil],
                           [[UIBarButtonItem alloc] initWithTitle: @"完成" style: UIBarButtonItemStyleDone target: self action: @selector(doneNumberPad)] ,nil];
    self.sponsorTextFieldForBgV3.inputAccessoryView = numberToolBar;
    
    self.pLabelForBgV3.textColor = [UIColor firstGrey];
    
    self.sponsorBtnForBgV3.backgroundColor = [UIColor firstMain];
    self.sponsorBtnForBgV3.layer.cornerRadius = kCornerRadius;
    [self.sponsorBtnForBgV3 setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    [self.sponsorBtnForBgV3 addTarget: self
                               action: @selector(sponsorBtnPressed:)
                     forControlEvents: UIControlEventTouchUpInside];
}

- (void)setupBgV4 {
    NSLog(@"setupBgV4");
    NSLog(@"self.userPoint: %ld", (long)self.userPoint);
    NSLog(@"self.albumPoint: %ld", (long)self.albumPoint);
    
    self.bgV4.hidden = YES;
    self.bgV4.backgroundColor = [UIColor whiteColor];
    self.bgV4.layer.cornerRadius = kCornerRadius;
    
    self.topicLabelForBgV4.textColor = [UIColor firstGrey];
    self.sponsorTextFieldForBgV4.delegate = self;
    
    self.currentPointLabelForBgV4.textColor = [UIColor secondGrey];
    
    self.sponsorTextFieldForBgV4.backgroundColor = [UIColor thirdGrey];
    self.sponsorLabelForBgV4.textColor = [UIColor firstGrey];
    
    self.sponsorTextFieldForBgV4.keyboardType = UIKeyboardTypeNumberPad;
    
    UIToolbar *numberToolBar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, 0, 320, 40)];
    numberToolBar.barStyle = UIBarStyleDefault;
    numberToolBar.items = [NSArray arrayWithObjects:
                           //[[UIBarButtonItem alloc] initWithTitle: @"取消" style: UIBarButtonItemStylePlain target: self action: @selector(cancelNumberPad)],
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil],
                           [[UIBarButtonItem alloc] initWithTitle: @"完成" style: UIBarButtonItemStyleDone target: self action: @selector(doneNumberPad)] ,nil];
    self.sponsorTextFieldForBgV4.inputAccessoryView = numberToolBar;
    
    self.pLabelForBgV4.textColor = [UIColor firstGrey];
    
    self.sponsorBtnForBgV4.backgroundColor = [UIColor firstMain];
    self.sponsorBtnForBgV4.layer.cornerRadius = kCornerRadius;
    [self.sponsorBtnForBgV4 setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    [self.sponsorBtnForBgV4 addTarget: self
                               action: @selector(sponsorBtnPressed:)
                     forControlEvents: UIControlEventTouchUpInside];
}

- (void)exitBtnPressed:(UIButton *)sender {
    NSLog(@"exitBtnPressed");
    if (self.exitBlock) {
        self.exitBlock(sender.selected, sender.tag, sender);
    }
}

- (void)collectBtnPressed:(UIButton *)sender {
    NSLog(@"collectBtnPressed");
    if (self.collectBlock) {
        self.collectBlock(sender.selected, sender.tag, sender);
    }
}

- (void)sponsorBtnPressed:(UIButton *)sender {
    NSLog(@"sponsorBtnPressed");
    if (self.sponsorBlock) {
        self.sponsorBlock(sender.selected, sender.tag, sender);
    }
}

- (void)giftImageBtnPressed:(UIButton *)sender {
    NSLog(@"giftImageBtnPressed");
    if (self.giftImageBlock) {
        self.giftImageBlock(sender.selected, sender.tag, sender);
    }
}

- (void)doneNumberPad {
    NSLog(@"doneNumberPad");
    [self.sponsorTextFieldForBgV3 resignFirstResponder];
    [self.sponsorTextFieldForBgV4 resignFirstResponder];
}

- (void)handleDoubleTapScrollView:(UITapGestureRecognizer *)recognizer {
    NSLog(@"handleDoubleTapScrollView");
    if (self.scrollView.zoomScale == 1) {
        [self.scrollView zoomToRect: [self zoomRectForScale: self.scrollView.maximumZoomScale center: [recognizer locationInView: recognizer.view]] animated: YES];
    } else {
        [self.scrollView setZoomScale: 1 animated: YES];
    }
}

- (CGRect)zoomRectForScale:(CGFloat)scale
                    center:(CGPoint)center {
    CGRect zoomRect = CGRectZero;
    zoomRect.size.height = self.imageView.frame.size.height / scale;
    zoomRect.size.width = self.imageView.frame.size.width / scale;
    CGPoint newCenter = [self.imageView convertPoint: center fromView: self.scrollView];
    zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0);
    zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [scrollView setZoomScale: 1 animated: YES];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.scrollView setZoomScale: 1.0 animated: YES];
}

@end
