//
//  HomeCategoryCollectionViewCell.h
//  wPinpinbox
//
//  Created by David on 12/01/2018.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeCategoryCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *categoryBgView;
@property (weak, nonatomic) IBOutlet UIImageView *categoryImageView;
@property (weak, nonatomic) IBOutlet UIView *categoryGradientView;
@property (weak, nonatomic) IBOutlet UILabel *categoryNameLabel;
@end
