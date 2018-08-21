//
//  CategoryTableViewCell.m
//  wPinpinbox
//
//  Created by David on 16/01/2018.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "CategoryTableViewCell.h"
#import "UIColor+Extensions.h"
#import "GlobalVars.h"

@implementation HorzAlbumCollectionView

@end

@implementation CategoryTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.albumExploreLabel.textColor = [UIColor firstGrey];
    self.moreBtn.backgroundColor = [UIColor thirdGrey];
    self.moreBtn.layer.cornerRadius = kCornerRadius;
    [self.moreBtn setTitle: @"更 多" forState: UIControlStateNormal];
    [self.moreBtn setTitleColor: [UIColor firstGrey] forState: UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath
{
    self.collectionView.dataSource = dataSourceDelegate;
    self.collectionView.delegate = dataSourceDelegate;
    self.collectionView.indexPath = indexPath;
    [self.collectionView setContentOffset:self.collectionView.contentOffset animated:NO];
    
    [self.collectionView reloadData];
}
- (IBAction)moreBtnPressed:(id)sender {    
    if (self.customBlock) {
        self.customBlock(self.strData);
    }
}
// set visibility and related constraint of the moreBtn
- (void)setMoreBtnHidden:(BOOL)hidden {
    self.moreBtn.hidden = hidden;
    if (hidden) {
        //  extend the line if moreBtn is hidden
        self.lineConstraint.constant = self.moreBtn.frame.size.width;
    } else {
        self.lineConstraint.constant = -16;
    }
}
@end
