//
//  CategoryTableViewCell.m
//  wPinpinbox
//
//  Created by David on 16/01/2018.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "CategoryTableViewCell.h"
#import "UIColor+Extensions.h"

@implementation HorzAlbumCollectionView

@end

@implementation CategoryTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.albumExploreLabel.textColor = [UIColor firstGrey];
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

@end
