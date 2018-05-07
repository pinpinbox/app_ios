//
//  UserCollectionViewCell.m
//  wPinpinbox
//
//  Created by David on 18/01/2018.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "UserCollectionViewCell.h"

@implementation UserCollectionViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
    self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width / 2;
    self.userImageView.clipsToBounds = YES;
}
@end
