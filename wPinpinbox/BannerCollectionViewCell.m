//
//  BannerCollectionViewCell.m
//  YoutubeTest
//
//  Created by David on 18/05/2018.
//  Copyright © 2018 David. All rights reserved.
//

#import "BannerCollectionViewCell.h"

@implementation BannerCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.infoLabel.layer.borderColor = [UIColor grayColor].CGColor;
}
- (void)prepareForReuse{
    [super prepareForReuse];
    
    [self.actionButton removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
}
@end
