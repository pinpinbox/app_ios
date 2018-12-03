//
//  RecommandCollectionViewCell.h
//  wPinpinbox
//
//  Created by Antelis on 2018/11/30.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RecommandListViewCell : UITableViewCell
@property (nonatomic) IBOutlet UICollectionView *recommandListView;
@end

@interface RecommandCollectionViewCell : UICollectionViewCell
@property (nonatomic) IBOutlet UIImageView *albumImageView;
@property (nonatomic) IBOutlet UIImageView *personnelView;
@property (nonatomic) IBOutlet UILabel *albumDesc;

@end

NS_ASSUME_NONNULL_END
