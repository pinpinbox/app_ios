//
//  ImageCollectionViewCell.h
//  wPinpinbox
//
//  Created by David on 2018/7/23.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyLayout.h"
#import "YTPlayerView.h"

typedef void(^ButtonTouch)(BOOL selected, NSInteger tag, UIButton *btn);

@interface ImageCollectionViewCell : UICollectionViewCell
<UIScrollViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIView *finalPageView;
@property (weak, nonatomic) IBOutlet UIImageView *finalPageImageView;

@property (weak, nonatomic) IBOutlet UIView *bgV1;
@property (weak, nonatomic) IBOutlet UILabel *topicLabelForBgV1;
@property (weak, nonatomic) IBOutlet UIButton *exitBtnForBgV1;
@property (copy, nonatomic) ButtonTouch exitBlock;

@property (weak, nonatomic) IBOutlet UIView *bgV2;
@property (weak, nonatomic) IBOutlet UILabel *topicLabelForBgV2;
@property (weak, nonatomic) IBOutlet UIButton *collectBtnForBgV2;
@property (copy, nonatomic) ButtonTouch collectBlock;

@property (weak, nonatomic) IBOutlet UIView *bgV3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgV3CenterYConstraint;
@property (weak, nonatomic) IBOutlet UILabel *topicLabelForBgV3;
@property (weak, nonatomic) IBOutlet UILabel *currentPointLabelForBgV3;
@property (weak, nonatomic) IBOutlet UILabel *sponsorLabelForBgV3;
@property (weak, nonatomic) IBOutlet UITextField *sponsorTextFieldForBgV3;
@property (weak, nonatomic) IBOutlet UILabel *pLabelForBgV3;
@property (weak, nonatomic) IBOutlet UIButton *sponsorBtnForBgV3;
@property (copy, nonatomic) ButtonTouch sponsorBlock;

@property (weak, nonatomic) IBOutlet UIView *bgV4;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgV4CenterYConstraint;
@property (weak, nonatomic) IBOutlet UILabel *topicLabelForBgV4;
@property (weak, nonatomic) IBOutlet UILabel *currentPointLabelForBgV4;
@property (weak, nonatomic) IBOutlet UILabel *sponsorLabelForBgV4;
@property (weak, nonatomic) IBOutlet UITextField *sponsorTextFieldForBgV4;
@property (weak, nonatomic) IBOutlet UILabel *pLabelForBgV4;
@property (weak, nonatomic) IBOutlet UIButton *sponsorBtnForBgV4;

@property (nonatomic) NSInteger albumPoint;
@property (nonatomic) NSInteger userPoint;

@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet YTPlayerView *ytPlayerView;

@property (weak, nonatomic) IBOutlet UIView *alphaBgV;
@property (weak, nonatomic) IBOutlet UIButton *videoBtn;

@property (weak, nonatomic) IBOutlet UIButton *giftImageBtn;
@property (copy, nonatomic) ButtonTouch giftImageBlock;

@end
