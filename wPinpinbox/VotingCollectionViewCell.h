//
//  VotingCollectionViewCell.h
//  wPinpinbox
//
//  Created by David on 2017/10/31.
//  Copyright © 2017年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyLayout.h"
#import "AsyncImageView.h"

typedef void(^buttonTouch)(BOOL selected, NSString *userId, NSString *albumId);

@interface VotingCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet MyLinearLayout *bgLayout;
@property (weak, nonatomic) IBOutlet UIView *coverBgView;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;

@property (weak, nonatomic) IBOutlet MyLinearLayout *userInfoView;
@property (weak, nonatomic) IBOutlet UIButton *btn1;
@property (weak, nonatomic) IBOutlet UIButton *btn2;
@property (weak, nonatomic) IBOutlet UIButton *btn3;

@property (weak, nonatomic) IBOutlet UILabel *votedLabel;
@property (weak, nonatomic) IBOutlet UILabel *rankLabel;

@property (weak, nonatomic) IBOutlet UILabel *albumNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *albumIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventJoinLabel;
@property (weak, nonatomic) IBOutlet UIButton *voteBtn;

@property (weak, nonatomic) IBOutlet UIView *userView;
@property (weak, nonatomic) IBOutlet AsyncImageView *userPictureImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *userBtn;

@property (strong, nonatomic) NSString *albumId;
@property (strong, nonatomic) NSString *userId;
@property (copy, nonatomic) buttonTouch userBtnBlock;
@property (copy, nonatomic) buttonTouch voteBtnBlock;
@end
