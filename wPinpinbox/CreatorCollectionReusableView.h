//
//  CreatorCollectionReusableView.h
//  wPinpinbox
//
//  Created by David on 5/3/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "MyLayout.h"

@interface CreatorCollectionReusableView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coverImageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coverImageBgVHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *gradientView;

@property (weak, nonatomic) IBOutlet UIImageView *userPictureImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userNameLabelHeight;
@property (weak, nonatomic) IBOutlet UILabel *creativeNameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *creativeNameLabelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *creativeNameLabelBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *viewedNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeNumberLabel;

@property (weak, nonatomic) IBOutlet UIStackView *sponsoredStackView;
@property (weak, nonatomic) IBOutlet UILabel *sponsoredNumberLabel;

@property (weak, nonatomic) IBOutlet UILabel *viewedLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeLabel;
@property (weak, nonatomic) IBOutlet UILabel *sponsoredLabel;

@property (weak, nonatomic) IBOutlet UILabel *linkLabel;
@property (weak, nonatomic) IBOutlet UIStackView *linkBgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *linkBgViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *linkBgViewBottomConstraint;

@property (weak, nonatomic) IBOutlet UIButton *fbBtn;
@property (weak, nonatomic) IBOutlet UIButton *googlePlusBtn;
@property (weak, nonatomic) IBOutlet UIButton *igBtn;
@property (weak, nonatomic) IBOutlet UIButton *linkedInBtn;
@property (weak, nonatomic) IBOutlet UIButton *pinterestBtn;
@property (weak, nonatomic) IBOutlet UIButton *twitterBtn;
@property (weak, nonatomic) IBOutlet UIButton *webBtn;
@property (weak, nonatomic) IBOutlet UIButton *youtubeBtn;

@property (weak, nonatomic) IBOutlet UIView *horzLineView;
@property (weak, nonatomic) IBOutlet UILabel *albumCollectionLabel;
@end
