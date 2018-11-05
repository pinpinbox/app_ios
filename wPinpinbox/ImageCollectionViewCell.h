//
//  ImageCollectionViewCell.h
//  wPinpinbox
//
//  Created by David on 2018/7/23.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyLayout.h"

typedef void(^ButtonTouch)(BOOL selected, NSInteger tag, UIButton *btn);

@interface ImageCollectionViewCell : UICollectionViewCell
<UIScrollViewDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIView *finalPageView;
@property (weak, nonatomic) IBOutlet UIImageView *finalPageImageView;

@property (strong, nonatomic) NSString *conditionCheckStr;

@property (weak, nonatomic) IBOutlet UIView *bgV1;
@property (weak, nonatomic) IBOutlet UILabel *topicLabelForBgV1;
@property (weak, nonatomic) IBOutlet UIButton *btnForBgV1;
@property (copy, nonatomic) ButtonTouch exitBlock;
@property (copy, nonatomic) ButtonTouch collectBlock;

@property (weak, nonatomic) IBOutlet UIView *bgV2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgV2CenterYConstraint;
@property (weak, nonatomic) IBOutlet UILabel *topicLabelForBgV2;
@property (weak, nonatomic) IBOutlet UILabel *currentPointLabelForBgV2;
@property (weak, nonatomic) IBOutlet UILabel *sponsorLabelForBgV2;
@property (weak, nonatomic) IBOutlet UITextField *sponsorTextFieldForBgV2;
@property (weak, nonatomic) IBOutlet UILabel *pLabelForBgV2;
@property (weak, nonatomic) IBOutlet UIButton *sponsorBtnForBgV2;
@property (copy, nonatomic) ButtonTouch sponsorBlock;

@property (weak, nonatomic) IBOutlet UIScrollView *bgSV;
@property (weak, nonatomic) IBOutlet MyLinearLayout *bgV3;
@property (weak, nonatomic) IBOutlet UILabel *topicLabelForBgV3;
@property (weak, nonatomic) IBOutlet UILabel *currentPointLabelForBgV3;
@property (weak, nonatomic) IBOutlet MyLinearLayout *sponsorHorzLayout;
@property (weak, nonatomic) IBOutlet UILabel *sponsorLabelForBgV3;
@property (weak, nonatomic) IBOutlet UITextField *sponsorTextFieldForBgV3;
//@property (weak, nonatomic) IBOutlet UITextView *sponsorTextViewForBgV3;
//@property (nonatomic) UILabel *placeHolderSponsorLabel;
@property (weak, nonatomic) IBOutlet UILabel *pLabelForBgV3;
@property (weak, nonatomic) IBOutlet UILabel *sponsoredNumberLabel;
@property (weak, nonatomic) IBOutlet UIView *horzLine;
@property (weak, nonatomic) IBOutlet UILabel *rewardInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextView *nameTextView;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UITextView *phoneTextView;
//@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UITextView *addressTextView;
@property (weak, nonatomic) IBOutlet UILabel *rewardDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *sponsorBtnForBgV3;

@property (nonatomic) NSInteger albumPoint;
@property (nonatomic) NSInteger userPoint;
@property (nonatomic) NSInteger exchangeNumber;

@property (weak, nonatomic) IBOutlet UIView *videoView;

@property (weak, nonatomic) IBOutlet UIView *alphaBgV;
@property (weak, nonatomic) IBOutlet UIButton *videoBtn;

@property (weak, nonatomic) IBOutlet UIButton *giftImageBtn;
@property (copy, nonatomic) ButtonTouch giftImageBlock;

@property (weak, nonatomic) IBOutlet MyLinearLayout *giftViewBgV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *giftViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *giftViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) IBOutlet MyLinearLayout *checkCollectionLayout;

@end
