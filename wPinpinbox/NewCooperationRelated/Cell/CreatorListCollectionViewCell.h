//
//  CreatorListCollectionViewCell.h
//  wPinpinbox
//
//  Created by David on 2018/9/26.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CreatorListCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userPictureImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *inviteBtn;
- (void)setInviteBtnEnabled:(BOOL)e;
@end

NS_ASSUME_NONNULL_END
