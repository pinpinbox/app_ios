//
//  NewExistingAlbumCollectionViewCell.m
//  wPinpinbox
//
//  Created by David on 07/02/2018.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "NewExistingAlbumCollectionViewCell.h"
#import "LabelAttributeStyle.h"
#import "UIColor+Extensions.h"
#import "MyLayout.h"
#import "GlobalVars.h"

@implementation NewExistingAlbumCollectionViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = kCornerRadius;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.maskView.layer.masksToBounds = YES;
    self.maskView.layer.cornerRadius = kCornerRadius;
    
    self.cancelPostLabel.text = @"取消投稿";
    [LabelAttributeStyle changeGapStringAndLineSpacingCenterAlignment: self.cancelPostLabel content: self.cancelPostLabel.text];
    
    self.cancelPostLabel.textColor = [UIColor whiteColor];
    self.cancelPostLabel.font = [UIFont systemFontOfSize: 18];
    
    self.textLabel.textColor = [UIColor firstGrey];
    self.textLabel.font = [UIFont systemFontOfSize: 12];
    self.textLabel.adjustsFontSizeToFitWidth = YES;
    self.textLabel.numberOfLines = 2;
    self.textLabel.wrapContentHeight = YES;
}
@end
