//
//  BannerCollectionViewCell.h
//  YoutubeTest
//
//  Created by David on 18/05/2018.
//  Copyright © 2018 David. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTPlayerView.h"

@interface BannerCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *bannerImageView;
@property (weak, nonatomic) IBOutlet YTPlayerView *playerView;

@end
