//
//  CategoryTableViewCell.h
//  wPinpinbox
//
//  Created by David on 16/01/2018.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ButtonTouch)(NSString *strData);

@interface HorzAlbumCollectionView : UICollectionView
@property (nonatomic, strong) NSIndexPath *indexPath;
@end

@interface CategoryTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *albumExploreLabel;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineConstraint;

@property (strong, nonatomic) NSString *strData;
@property (copy, nonatomic) ButtonTouch customBlock;

@property (weak, nonatomic) IBOutlet HorzAlbumCollectionView *collectionView;

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath;
// set visibility and related constraint of the moreBtn
- (void)setMoreBtnHidden:(BOOL)hidden;
@end
