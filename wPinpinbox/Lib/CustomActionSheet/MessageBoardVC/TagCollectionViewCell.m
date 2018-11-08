//
//  TagCollectionViewCell.m
//  wPinpinbox
//
//  Created by David on 11/04/2018.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "TagCollectionViewCell.h"
#import "UIColor+Extensions.h"

@implementation TagCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.userPictureImageView.layer.cornerRadius = self.userPictureImageView.bounds.size.width / 2;
    self.userPictureImageView.clipsToBounds = YES;
    
    self.userNameLabel.textColor = [UIColor firstGrey];
    self.userNameLabel.font = [UIFont systemFontOfSize: 10.0];
    self.userNameLabel.numberOfLines = 2;
}

@end
