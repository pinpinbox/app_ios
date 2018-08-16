//
//  ThumbnailImageCollectionViewCell.m
//  wPinpinbox
//
//  Created by David on 2018/7/24.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "ThumbnailImageCollectionViewCell.h"
#import "UIColor+Extensions.h"

@implementation ThumbnailImageCollectionViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
    self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.infoButton setTitleColor: [UIColor whiteColor] forState: UIControlStateNormal];
    self.infoButton.layer.cornerRadius = self.infoButton.bounds.size.width / 2;
    self.infoButton.backgroundColor = [UIColor firstMain];
    self.infoButton.userInteractionEnabled = NO;
    self.infoButton.hidden = YES;
}
@end
