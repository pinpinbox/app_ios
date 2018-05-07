//
//  ChooseHobbyCollectionViewCell.h
//  wPinpinbox
//
//  Created by David on 5/15/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface ChooseHobbyCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *hobbyBgView;
@property (weak, nonatomic) IBOutlet AsyncImageView *hobbyImageView;
@property (weak, nonatomic) IBOutlet UILabel *hobbyLabel;

@end
