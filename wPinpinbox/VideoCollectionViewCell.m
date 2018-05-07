//
//  VideoCollectionViewCell.m
//  wPinpinbox
//
//  Created by David on 9/13/16.
//  Copyright © 2016 Angus. All rights reserved.
//

#import "VideoCollectionViewCell.h"

@implementation VideoCollectionViewCell
- (void)setThumbnailImage:(UIImage *)thumbnailImage
{
    if (_thumbnailImage != thumbnailImage) {
        _thumbnailImage = thumbnailImage;
        self.myImage.image = thumbnailImage;
    }
}
/*
- (void)awakeFromNib
{
    [[_title layer] setMasksToBounds: YES];
    [[_title layer] setCornerRadius: _title.bounds.size.height / 2];
}
*/
@end