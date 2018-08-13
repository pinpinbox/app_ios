//
//  ThumbnailImageCollectionViewCell.m
//  wPinpinbox
//
//  Created by David on 2018/7/24.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "ThumbnailImageCollectionViewCell.h"

@implementation ThumbnailImageCollectionViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
    self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.infoImageView.layer.cornerRadius = self.infoImageView.bounds.size.width / 2;
}
@end
