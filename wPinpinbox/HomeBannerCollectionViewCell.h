//
//  HomeBannerCollectionViewCell.h
//  wPinpinbox
//
//  Created by David on 12/01/2018.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLAnimatedImageView.h"
#import "SwitchButtonView.h"
@interface HomeBannerCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *bannerImageView;
@property (weak, nonatomic) IBOutlet UIKernedLabel *bannerTitle;
- (void)loadCellWithData:(NSDictionary *)data indexPath:(NSIndexPath *)indexPath completionBlock:(void(^)(NSIndexPath *indexpath, HomeBannerCollectionViewCell *cell))completionBlock;

@end
