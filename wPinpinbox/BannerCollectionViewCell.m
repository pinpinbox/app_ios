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
    
}
- (void)prepareForReuse{
    [super prepareForReuse];
    
    //[self.actionButton removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
}
/*
- (BOOL)setBtnText:(NSString *)btntext infoText:(NSString *)infotext{
    if (btntext && btntext.length > 0) {
        self.actionButton.hidden = NO;
        self.infoLabel.hidden = NO;
        self.labelLine.hidden = NO;
        [self.actionButton setTitle:btntext forState:UIControlStateNormal];
        if (infotext)
            self.infoLabel.text = infotext;
    } else {
        self.actionButton.hidden = YES;
        self.infoLabel.hidden = YES;
        self.labelLine.hidden = YES;
    }
    
    return  self.actionButton.hidden;
}
 */
@end
