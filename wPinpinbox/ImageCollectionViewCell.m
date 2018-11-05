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
#import "LabelAttributeStyle.h"

@implementation ImageCollectionViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
    NSLog(@"awakeFromNib");
    [self setupBgV1];
    [self setupBgV2];
    [self setupBgSV];
    [self setupFinalPage];
    
    self.checkCollectionLayout.hidden = YES;
    self.checkCollectionLayout.wrapContentHeight = YES;
    self.checkCollectionLayout.padding = UIEdgeInsetsMake(16, 16, 16, 16);
    self.checkCollectionLayout.myWidth = 240;
    self.checkCollectionLayout.myHeight = 150;
    self.checkCollectionLayout.layer.cornerRadius = 16;
    
    self.statusView.hidden = YES;
    self.statusView.backgroundColor = [UIColor whiteColor];
    self.statusView.layer.cornerRadius = kCornerRadius;
    
    self.statusLabel.numberOfLines = 0;
    self.statusLabel.font = [UIFont boldSystemFontOfSize: 18.0];
    self.statusLabel.textColor = [UIColor firstGrey];
    
    self.alphaBgV.hidden = YES;
    self.giftImageBtn.hidden = YES;
    [self.giftImageBtn addTarget: self action: @selector(giftImageBtnPressed:) forControlEvents: UIControlEventTouchUpInside];
    
    self.videoBtn.hidden = YES;
    self.videoView.hidden = YES;
    
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
    self.sponsorTextFieldForBgV2.placeholder = [NSString stringWithFormat: @"最低額度%lu", (unsigned long)albumPoint];
//    self.placeHolderSponsorLabel.text = [NSString stringWithFormat: @"最低額度%lu", (unsigned long)albumPoint];
    self.sponsorTextFieldForBgV3.placeholder = [NSString stringWithFormat: @"最低額度%lu", (unsigned long)albumPoint];
}

- (void)setUserPoint:(NSInteger)userPoint {
    NSLog(@"setUserPoint");
    NSLog(@"userPoint: %ld", (long)userPoint);
    self.currentPointLabelForBgV2.text = [NSString stringWithFormat: @"現有P點：%ld", (long)userPoint];
    self.currentPointLabelForBgV3.text = [NSString stringWithFormat: @"現有P點：%ld", (long)userPoint];
}

- (void)setExchangeNumber:(NSInteger)exchangeNumber {
    NSLog(@"setExchangeNumber");
    NSLog(@"setExchangeNumber: %ld", (long)exchangeNumber);
    self.sponsoredNumberLabel.text = [NSString stringWithFormat: @"已被贊助%ld次", exchangeNumber];
}

- (void)setupFinalPage {
    self.finalPageView.hidden = YES;
    self.finalPageImageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)setConditionCheckStr:(NSString *)conditionCheckStr {
    NSLog(@"setConditionCheckStr");
    NSLog(@"conditionCheckStr: %@", conditionCheckStr);
    // Reset
    self.topicLabelForBgV1.text = @"";
    [self.btnForBgV1 setTitle: @"" forState: UIControlStateNormal];
    
    if ([conditionCheckStr isEqualToString: @"Exit"]) {
        self.bgV1.hidden = NO;
        self.bgV2.hidden = YES;
        self.bgSV.hidden = YES;
        self.topicLabelForBgV1.text = @"已完整閱讀";
        [self.btnForBgV1 setTitle: @"離開" forState: UIControlStateNormal];
        self.btnForBgV1.backgroundColor = [UIColor secondGrey];
        [self.btnForBgV1 setTitleColor: [UIColor firstGrey] forState: UIControlStateNormal];
        [self.btnForBgV1 addTarget: self
                                action: @selector(exitBtnPressed:)
                      forControlEvents: UIControlEventTouchUpInside];
    } else if ([conditionCheckStr isEqualToString: @"FreeCollect"]) {
        self.bgV1.hidden = NO;
        self.bgV2.hidden = YES;
        self.bgSV.hidden = YES;
        self.topicLabelForBgV1.text = @"馬上收藏看全部內容";
        [self.btnForBgV1 setTitle: @"收藏" forState: UIControlStateNormal];
        self.btnForBgV1.backgroundColor = [UIColor firstMain];
        [self.btnForBgV1 setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
        [self.btnForBgV1 addTarget: self
                                action: @selector(collectBtnPressed:)
                      forControlEvents: UIControlEventTouchUpInside];
    } else if ([conditionCheckStr isEqualToString: @"DisplayAllWithoutReward"]) {
        NSLog(@"conditionCheckStr is equal to DisplayAllWithoutReward");
        self.bgV1.hidden = YES;
        self.bgV2.hidden = NO;
        self.bgSV.hidden = YES;
        self.topicLabelForBgV2.text = @"喜歡作品就給個鼓勵吧!";
    } else if ([conditionCheckStr isEqualToString: @"DisplayPreviewWithoutReward"]) {
        NSLog(@"conditionCheckStr is equal to DisplayPreviewWithoutReward");
        self.bgV1.hidden = YES;
        self.bgV2.hidden = NO;
        self.bgSV.hidden = YES;
        self.topicLabelForBgV2.text = @"贊助P點 看全部內容";
    } else if ([conditionCheckStr isEqualToString: @"DisplayAllWithReward"]) {
        NSLog(@"conditionCheckStr is equal to DisplayAllWithReward");
        self.bgV1.hidden = YES;
        self.bgV2.hidden = YES;
        self.bgSV.hidden = NO;
        [self setupBgV3: @"喜歡作品就給個鼓勵吧!"];
    } else if ([conditionCheckStr isEqualToString: @"DisplayPreviewWithReward"]) {
        NSLog(@"conditionCheckStr is equal to DisplayPreviewWithReward");
        self.bgV1.hidden = YES;
        self.bgV2.hidden = YES;
        self.bgSV.hidden = NO;
        [self setupBgV3: @"贊助P點 看全部內容"];
    }
}

- (void)setupBgSV {
    self.bgSV.hidden = YES;
//    self.bgSV.backgroundColor = [UIColor redColor];
    self.bgSV.layer.cornerRadius = kCornerRadius;
//    self.bgSV.contentOffset = CGPointMake(0, 40);
//    self.bgSV.contentInset = UIEdgeInsetsMake(48, 0, 0, 0);
}

- (void)setupBgV3:(NSString *)topicStr {
    self.bgV3.backgroundColor = [UIColor whiteColor];
    self.bgV3.layer.cornerRadius = kCornerRadius;
    
    // TopicLabel
    self.topicLabelForBgV3.myTopMargin = 32;
    self.topicLabelForBgV3.myBottomMargin = 8;
    self.topicLabelForBgV3.myRightMargin = self.topicLabelForBgV3.myLeftMargin = 32;
    self.topicLabelForBgV3.numberOfLines = 0;
    self.topicLabelForBgV3.font = [UIFont boldSystemFontOfSize: 18.0];
    self.topicLabelForBgV3.textAlignment = NSTextAlignmentCenter;
    self.topicLabelForBgV3.textColor = [UIColor firstGrey];
    self.topicLabelForBgV3.text = topicStr;
    [LabelAttributeStyle changeGapString: self.topicLabelForBgV3 content: self.topicLabelForBgV3.text];
    [self.topicLabelForBgV3 sizeToFit];
    self.topicLabelForBgV3.wrapContentHeight = YES;
    
    // CurrentPointLabel
    self.currentPointLabelForBgV3.myTopMargin = self.currentPointLabelForBgV3.myBottomMargin = 8;
    self.currentPointLabelForBgV3.myLeftMargin = self.currentPointLabelForBgV3.myRightMargin = 32;
    self.currentPointLabelForBgV3.numberOfLines = 0;
    self.currentPointLabelForBgV3.font = [UIFont systemFontOfSize: 16.0];
    self.currentPointLabelForBgV3.textAlignment = NSTextAlignmentCenter;
    self.currentPointLabelForBgV3.textColor = [UIColor secondGrey];
    [LabelAttributeStyle changeGapString: self.currentPointLabelForBgV3 content: self.currentPointLabelForBgV3.text];
    [self.currentPointLabelForBgV3 sizeToFit];
    self.currentPointLabelForBgV3.wrapContentHeight = YES;
    
    // SponsorHorzLayout
    self.sponsorHorzLayout.myHeight = 38;
    self.sponsorHorzLayout.myTopMargin = self.sponsorHorzLayout.myBottomMargin = 8;
    self.sponsorHorzLayout.myLeftMargin = self.sponsorHorzLayout.myRightMargin = 32;
//    self.sponsorHorzLayout.backgroundColor = [UIColor thirdPink];
    
    // SponsorLabel
    self.sponsorLabelForBgV3.myWidth = 75;
//    self.sponsorLabelForBgV3.backgroundColor = [UIColor yellowColor];
    self.sponsorLabelForBgV3.myLeftMargin = 0;
    self.sponsorLabelForBgV3.myRightMargin = 4;
    self.sponsorLabelForBgV3.myCenterYOffset = 0;
    self.sponsorLabelForBgV3.numberOfLines = 0;
    self.sponsorLabelForBgV3.font = [UIFont systemFontOfSize: 16.0];
    self.sponsorLabelForBgV3.textAlignment = NSTextAlignmentCenter;
    self.sponsorLabelForBgV3.textColor = [UIColor firstGrey];
    self.sponsorLabelForBgV3.text = @"我要贊助";
    [LabelAttributeStyle changeGapString: self.sponsorLabelForBgV3 content: self.sponsorLabelForBgV3.text];
    [self.sponsorLabelForBgV3 sizeToFit];
    
    // ToolBarForDoneBtn
    UIToolbar *toolBarForDoneBtn = [[UIToolbar alloc] initWithFrame: CGRectMake(0, 0, 320, 40)];
    toolBarForDoneBtn.barStyle = UIBarStyleDefault;
    toolBarForDoneBtn.items = [NSArray arrayWithObjects:
                               //[[UIBarButtonItem alloc] initWithTitle: @"取消" style: UIBarButtonItemStylePlain target: self action: @selector(cancelNumberPad)],
                               [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil],
                               [[UIBarButtonItem alloc] initWithTitle: @"完成" style: UIBarButtonItemStyleDone target: self action: @selector(toolBarDoneBtnPressed)] ,nil];
    
    /*
    // SponsorTextView
    self.sponsorTextViewForBgV3.weight = 0.5;
    self.sponsorTextViewForBgV3.myTopMargin = self.sponsorTextViewForBgV3.myBottomMargin = 0;
    self.sponsorTextViewForBgV3.myLeftMargin = self.sponsorTextViewForBgV3.myRightMargin = 4;
    self.sponsorTextViewForBgV3.myCenterYOffset = 0;
    self.sponsorTextViewForBgV3.delegate = self;
    self.sponsorTextViewForBgV3.textColor = [UIColor firstGrey];
    self.sponsorTextViewForBgV3.backgroundColor = [UIColor thirdGrey];
    self.sponsorTextViewForBgV3.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self.sponsorTextViewForBgV3.layer.cornerRadius = kCornerRadius;
    self.sponsorTextViewForBgV3.keyboardType = UIKeyboardTypeNumberPad;
    self.sponsorTextViewForBgV3.inputAccessoryView = toolBarForDoneBtn;
    self.sponsorTextViewForBgV3.wrapContentHeight = YES;
    */
    
//    self.placeHolderSponsorLabel = [[UILabel alloc] initWithFrame: CGRectMake(13, 10, 0, 0)];
//    self.placeHolderSponsorLabel.numberOfLines = 1;
//    self.placeHolderSponsorLabel.font = [UIFont systemFontOfSize: 14.f];
//    self.placeHolderSponsorLabel.textColor = [UIColor hintGrey];
//    [self.placeHolderSponsorLabel sizeToFit];
//    [self.sponsorTextViewForBgV3 addSubview: self.placeHolderSponsorLabel];
    
    
    // SponsorTextField
    self.sponsorTextFieldForBgV3.weight = 0.5;
    self.sponsorTextFieldForBgV3.myHeight = 40;
//    self.sponsorTextFieldForBgV3.backgroundColor = [UIColor greenColor];
    self.sponsorTextFieldForBgV3.delegate = self;
    self.sponsorTextFieldForBgV3.myCenterYOffset = 0;
    self.sponsorTextFieldForBgV3.myLeftMargin = self.sponsorTextFieldForBgV3.myRightMargin = 4;
    self.sponsorTextFieldForBgV3.backgroundColor = [UIColor thirdGrey];
    self.sponsorTextFieldForBgV3.layer.cornerRadius = kCornerRadius;
    self.sponsorTextFieldForBgV3.borderStyle = UITextBorderStyleRoundedRect;
    self.sponsorTextFieldForBgV3.keyboardType = UIKeyboardTypeNumberPad;
    self.sponsorTextFieldForBgV3.inputAccessoryView = toolBarForDoneBtn;
    self.sponsorTextFieldForBgV3.wrapContentWidth = YES;
    
    
    // P TextLabel
    self.pLabelForBgV3.myWidth = 15;
//    self.pLabelForBgV3.backgroundColor = [UIColor blueColor];
    self.pLabelForBgV3.myLeftMargin = 4;
    self.pLabelForBgV3.myRightMargin = 0;
    self.pLabelForBgV3.myCenterYOffset = 0;
    self.pLabelForBgV3.numberOfLines = 0;
    self.pLabelForBgV3.font = [UIFont systemFontOfSize: 16.0];
    self.pLabelForBgV3.text = @"P";
    self.pLabelForBgV3.textColor = [UIColor firstGrey];
    [LabelAttributeStyle changeGapString: self.pLabelForBgV3 content: self.pLabelForBgV3.text];
    [self.pLabelForBgV3 sizeToFit];
    
    // SponsoredNumberLabel
    self.sponsoredNumberLabel.myTopMargin = self.sponsoredNumberLabel.myBottomMargin = 8;
    self.sponsoredNumberLabel.numberOfLines = 0;
    self.sponsoredNumberLabel.font = [UIFont systemFontOfSize: 16.0];
    self.sponsoredNumberLabel.textAlignment = NSTextAlignmentCenter;
    self.sponsoredNumberLabel.textColor = [UIColor firstPink];
    self.sponsoredNumberLabel.myLeftMargin = self.sponsoredNumberLabel.myRightMargin = 32;
    [LabelAttributeStyle changeGapString: self.sponsoredNumberLabel content: self.sponsoredNumberLabel.text];
    [self.sponsoredNumberLabel sizeToFit];
    self.sponsoredNumberLabel.wrapContentHeight = YES;
    
    // HorzLine
    self.horzLine.myTopMargin = self.horzLine.myBottomMargin = 8;
    self.horzLine.myLeftMargin = self.horzLine.myRightMargin = 32;
    self.horzLine.backgroundColor = [UIColor thirdGrey];
    
    // Reward InfoLabel
    self.rewardInfoLabel.myHeight = 22;
    self.rewardInfoLabel.myWidth = 200;
    self.rewardInfoLabel.myTopMargin = self.rewardInfoLabel.myBottomMargin = 8;
    self.rewardInfoLabel.myRightMargin = 32;
    self.rewardInfoLabel.numberOfLines = 1;
    self.rewardInfoLabel.font = [UIFont systemFontOfSize: 14.0];
    self.rewardInfoLabel.textAlignment = NSTextAlignmentRight;
    self.rewardInfoLabel.textColor = [UIColor secondGrey];
    self.rewardInfoLabel.text = @"回饋寄送填寫";
    [LabelAttributeStyle changeGapString: self.rewardInfoLabel content: self.rewardInfoLabel.text];
    [self.rewardInfoLabel sizeToFit];
    self.rewardInfoLabel.wrapContentWidth = YES;
    
    // NameLabel
    self.nameLabel.myTopMargin = self.nameLabel.myBottomMargin = 4;
    self.nameLabel.myLeftMargin = 32;
    self.nameLabel.numberOfLines = 1;
    self.nameLabel.font = [UIFont systemFontOfSize: 14.0];
    self.nameLabel.textColor = [UIColor firstGrey];
    self.nameLabel.text = @"收件人";
    [LabelAttributeStyle changeGapString: self.nameLabel content: self.nameLabel.text];
    [self.nameLabel sizeToFit];
    self.nameLabel.wrapContentHeight = YES;
    
    // NameTextView
    self.nameTextView.myTopMargin = 4;
    self.nameTextView.myBottomMargin = 8;
    self.nameTextView.myLeftMargin = self.nameTextView.myRightMargin = 32;
    self.nameTextView.delegate = self;
    self.nameTextView.textColor = [UIColor firstGrey];
    self.nameTextView.backgroundColor = [UIColor thirdGrey];
    self.nameTextView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self.nameTextView.layer.cornerRadius = kCornerRadius;
    self.nameTextView.wrapContentHeight = YES;
    self.nameTextView.inputAccessoryView = toolBarForDoneBtn;
    
    // PhoneLabel
    self.phoneLabel.myTopMargin = 8;
    self.phoneLabel.myBottomMargin = 4;
    self.phoneLabel.myLeftMargin = 32;
    self.phoneLabel.numberOfLines = 1;
    self.phoneLabel.font = [UIFont systemFontOfSize: 14.0];
    self.phoneLabel.textColor = [UIColor firstGrey];
    self.phoneLabel.text = @"連絡電話";
    [LabelAttributeStyle changeGapString: self.phoneLabel content: self.phoneLabel.text];
    [self.phoneLabel sizeToFit];
    self.phoneLabel.wrapContentHeight = YES;
    
    // PhoneTextView
    self.phoneTextView.myTopMargin = 4;
    self.phoneTextView.myBottomMargin = 8;
    self.phoneTextView.myLeftMargin = self.phoneTextView.myRightMargin = 32;
    self.phoneTextView.delegate = self;
    self.phoneTextView.textColor = [UIColor firstGrey];
    self.phoneTextView.backgroundColor = [UIColor thirdGrey];
    self.phoneTextView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self.phoneTextView.layer.cornerRadius = kCornerRadius;
    self.phoneTextView.wrapContentHeight = YES;
    self.phoneTextView.inputAccessoryView = toolBarForDoneBtn;
    
    /*
    // PhoneTextField
    self.phoneTextField.myHeight = 40;
    self.phoneTextField.delegate = self;
    self.phoneTextField.myTopMargin = self.phoneTextField.myBottomMargin = 8;
    self.phoneTextField.myLeftMargin = self.phoneTextField.myRightMargin = 32;
    self.phoneTextField.backgroundColor = [UIColor thirdGrey];
    self.phoneTextField.layer.cornerRadius = kCornerRadius;
    self.phoneTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneTextField.inputAccessoryView = toolBarForDoneBtn;
    */
    
    // AddressLabel
    self.addressLabel.myTopMargin = self.addressLabel.myBottomMargin = 4;
    self.addressLabel.myLeftMargin = 32;
    self.addressLabel.numberOfLines = 1;
    self.addressLabel.font = [UIFont systemFontOfSize: 14.0];
    self.addressLabel.textColor = [UIColor firstGrey];
    self.addressLabel.text = @"寄送地址";
    [LabelAttributeStyle changeGapString: self.addressLabel content: self.addressLabel.text];
    [self.addressLabel sizeToFit];
    self.addressLabel.wrapContentHeight = YES;
    
    // AddressTextView
    self.addressTextView.myTopMargin = 4;
    self.addressTextView.myBottomMargin = 8;
    self.addressTextView.myLeftMargin = self.addressTextView.myRightMargin = 32;
    self.addressTextView.delegate = self;
    self.addressTextView.textColor = [UIColor firstGrey];
    self.addressTextView.backgroundColor = [UIColor thirdGrey];
    self.addressTextView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self.addressTextView.layer.cornerRadius = kCornerRadius;
    self.addressTextView.wrapContentHeight = YES;    
    self.addressTextView.inputAccessoryView = toolBarForDoneBtn;
    
    // RewardDescriptionLabel
    self.rewardDescriptionLabel.myTopMargin = self.rewardDescriptionLabel.myBottomMargin = 8;
    self.rewardDescriptionLabel.myLeftMargin = self.rewardDescriptionLabel.myRightMargin = 32;
    self.rewardDescriptionLabel.numberOfLines = 0;
    self.rewardDescriptionLabel.font = [UIFont boldSystemFontOfSize: 14.0];
    self.rewardDescriptionLabel.textColor = [UIColor firstGrey];
    [LabelAttributeStyle changeGapString: self.rewardDescriptionLabel content: self.rewardDescriptionLabel.text];
    self.rewardDescriptionLabel.wrapContentHeight = YES;
    
    // SponsorBtn
    self.sponsorBtnForBgV3.myTopMargin = 8;
    self.sponsorBtnForBgV3.myBottomMargin = 32;
    self.sponsorBtnForBgV3.myLeftMargin = self.sponsorBtnForBgV3.myRightMargin = 32;
    self.sponsorBtnForBgV3.backgroundColor = [UIColor firstMain];
    self.sponsorBtnForBgV3.layer.cornerRadius = kCornerRadius;
    self.sponsorBtnForBgV3.titleLabel.font = [UIFont boldSystemFontOfSize: 18.0];
    [self.sponsorBtnForBgV3 setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    [self.sponsorBtnForBgV3 addTarget: self
                               action: @selector(sponsorBtnPressed:)
                     forControlEvents: UIControlEventTouchUpInside];
    self.bgV3.wrapContentHeight = YES;
}

- (void)setupBgV1 {
    self.bgV1.hidden = YES;
    self.bgV1.backgroundColor = [UIColor whiteColor];
    self.bgV1.layer.cornerRadius = kCornerRadius;
    
    self.topicLabelForBgV1.textColor = [UIColor firstGrey];
    self.btnForBgV1.layer.cornerRadius = kCornerRadius;
    self.btnForBgV1.titleLabel.font = [UIFont boldSystemFontOfSize: 18.0];
}

- (void)setupBgV2 {
    self.bgV2.hidden = YES;
    self.bgV2.backgroundColor = [UIColor whiteColor];
    self.bgV2.layer.cornerRadius = kCornerRadius;
    
    self.topicLabelForBgV2.textColor = [UIColor firstGrey];
    self.currentPointLabelForBgV2.textColor = [UIColor secondGrey];
    
    self.sponsorTextFieldForBgV2.backgroundColor = [UIColor thirdGrey];
    self.sponsorTextFieldForBgV2.delegate = self;
    
    self.sponsorLabelForBgV2.textColor = [UIColor firstGrey];
    
    self.sponsorTextFieldForBgV2.keyboardType = UIKeyboardTypeNumberPad;
    
    UIToolbar *numberToolBar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, 0, 320, 40)];
    numberToolBar.barStyle = UIBarStyleDefault;
    numberToolBar.items = [NSArray arrayWithObjects:
                           //[[UIBarButtonItem alloc] initWithTitle: @"取消" style: UIBarButtonItemStylePlain target: self action: @selector(cancelNumberPad)],
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil],
                           [[UIBarButtonItem alloc] initWithTitle: @"完成" style: UIBarButtonItemStyleDone target: self action: @selector(toolBarDoneBtnPressed)] ,nil];
    self.sponsorTextFieldForBgV2.inputAccessoryView = numberToolBar;
    
    self.pLabelForBgV2.textColor = [UIColor firstGrey];
    
    self.sponsorBtnForBgV2.backgroundColor = [UIColor firstMain];
    self.sponsorBtnForBgV2.layer.cornerRadius = kCornerRadius;
    self.sponsorBtnForBgV2.titleLabel.font = [UIFont boldSystemFontOfSize: 18.0];
    [self.sponsorBtnForBgV2 setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    [self.sponsorBtnForBgV2 addTarget: self
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

- (void)toolBarDoneBtnPressed {
    NSLog(@"toolBarDoneBtnPressed");
    [self.sponsorTextFieldForBgV2 resignFirstResponder];
//    [self.sponsorTextViewForBgV3 resignFirstResponder];
    [self.sponsorTextFieldForBgV3 resignFirstResponder];
    [self.nameTextView resignFirstResponder];
//    [self.phoneTextField resignFirstResponder];
    [self.phoneTextView resignFirstResponder];
    [self.addressTextView resignFirstResponder];
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

/*
#pragma mark - UITextFieldDelegate Methods
- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    if ((textField.text.length + (string.length - range.length)) > 4) {
        return false;
    }
    return true;
}

#pragma mark - UITextViewDelegate Methods
- (void)textViewDidChange:(UITextView *)textView {
    //每次输入变更都让布局重新布局。
    if (textView == self.phoneTextView) {
        return;
    }
    
    MyBaseLayout *layout = (MyBaseLayout*)textView.superview;
    [layout setNeedsLayout];
    
    UITextRange *tp = textView.selectedTextRange;
    CGRect caret = [textView firstRectForRange:tp];
    if (caret.size.width < 1) {
        caret = [textView caretRectForPosition:[textView endOfDocument]];
    }
    
    CGRect r2 = [self.scrollView convertRect:caret fromView:textView];
    
    [self.scrollView scrollRectToVisible:CGRectMake(0, r2.origin.y, self.scrollView.bounds.size.width, r2.size.height) animated:YES];
    
    //这里设置在布局结束后将textView滚动到光标所在的位置了。在布局执行布局完毕后如果设置了endLayoutBlock的话可以在这个block里面读取布局里面子视图的真实布局位置和尺寸，也就是可以在block内部读取每个子视图的真实的frame的值。
    layout.endLayoutBlock = ^{
        NSRange rg = textView.selectedRange;
        [textView scrollRangeToVisible:rg];
    };
    [self.bgV3 setNeedsLayout];
}

- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text {
    if (textView == self.phoneTextView) {
        if ([text isEqualToString: @"\n"]) {
            return NO;
        }
    }
    return YES;
}
 */

@end
