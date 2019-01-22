//
//  SearchTabCollectionReusableView.h
//  wPinpinbox
//
//  Created by David on 5/11/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwitchButtonView.h"

@interface SearchTabCollectionReusableView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UIKernedLabel *userRecommendationLabel;
@property (weak, nonatomic) IBOutlet UIKernedLabel *albumRecommendationLabel;

@property (weak, nonatomic) IBOutlet UICollectionView *userCollectionView;
@property (weak, nonatomic) IBOutlet UIView *horzLineView;

@end
