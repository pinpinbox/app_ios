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

@property (weak, nonatomic) IBOutlet UILabel *exploreLabel;
@property (weak, nonatomic) IBOutlet UIView *exploreHorzView;
@property (weak, nonatomic) IBOutlet UILabel *recommendationLabel;
@property (weak, nonatomic) IBOutlet UIView *recommendationHorzView;

@end
