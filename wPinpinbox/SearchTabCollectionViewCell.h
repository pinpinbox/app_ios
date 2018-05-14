//
//  SearchTabCollectionViewCell.h
//  wPinpinbox
//
//  Created by David on 5/11/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyLayout.h"

@interface SearchTabCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *imgBgView;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UIView *alphaView;
@property (weak, nonatomic) IBOutlet UILabel *albumNameLabel;

@property (weak, nonatomic) IBOutlet MyLinearLayout *userInfoView;
@property (weak, nonatomic) IBOutlet UIButton *btn1;
@property (weak, nonatomic) IBOutlet UIButton *btn2;
@property (weak, nonatomic) IBOutlet UIButton *btn3;

@end
