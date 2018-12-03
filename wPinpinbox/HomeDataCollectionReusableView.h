//
//  HomeDataCollectionReusableView.h
//  wPinpinbox
//
//  Created by David on 5/2/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeDataCollectionReusableView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UICollectionView *homeBannerCollectionView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UICollectionView *categoryCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *followUserCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *followAlbumCollectionView;

@property (weak, nonatomic) IBOutlet UILabel *followUserLabel;
@property (weak, nonatomic) IBOutlet UIView *followUserHorzView;

@property (weak, nonatomic) IBOutlet UILabel *followAlbumLabel;
@property (weak, nonatomic) IBOutlet UIView *followAlbumHorzView;

@property (weak, nonatomic) IBOutlet UILabel *recommendationLabel;
@property (weak, nonatomic) IBOutlet UIView *recommendationHorzView;

@property (weak, nonatomic) IBOutlet UITableView *recommandListView;

@end
