//
//  IdentityCollectionViewCell.h
//  wPinpinbox
//
//  Created by David on 2018/9/26.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface IdentityCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userPictureImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *userIdentityChangeBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteIdentityBtn;
@end

NS_ASSUME_NONNULL_END
