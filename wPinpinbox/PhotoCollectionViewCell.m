//
//  PhotoCollectionViewCell.m
//  wPinpinbox
//
//  Created by Angus on 2015/9/23.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "PhotoCollectionViewCell.h"

@implementation PhotoCollectionViewCell
- (void)setThumbnailImage:(UIImage *)thumbnailImage {
    if (_thumbnailImage != thumbnailImage) {
        _thumbnailImage = thumbnailImage;
        self.myimage.image = thumbnailImage;
    }
    
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    [[_titel layer] setMasksToBounds:YES];
    [[_titel layer]setCornerRadius:_titel.bounds.size.height/2];
}
@end
