//
//  FBLikeLayout.h
//  collectionViewDemo
//
//  Created by Jinal Patel on 9/3/15.
//

#import <UIKit/UIKit.h>

@protocol customLayoutDelegate <UICollectionViewDelegateFlowLayout>
@optional
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout columnCountForSection:(NSInteger)section;
@end


@interface customLayout: UICollectionViewFlowLayout
@property (nonatomic, weak) id<customLayoutDelegate> delegate;

@property (nonatomic, assign) CGFloat singleCellWidth;
@property (assign,nonatomic) CGFloat columnCount;
@property (nonatomic, assign) CGFloat contentHeight;

@end
