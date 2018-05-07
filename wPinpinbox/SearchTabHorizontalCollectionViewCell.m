//
//  SearchTabHorizontalCollectionViewCell.m
//  wPinpinbox
//
//  Created by David on 5/12/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "SearchTabHorizontalCollectionViewCell.h"

@implementation SearchTabHorizontalCollectionViewCell
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.userPictureImageView.layer.cornerRadius = self.userPictureImageView.bounds.size.width / 2;
    self.userPictureImageView.clipsToBounds = YES;
}
@end
