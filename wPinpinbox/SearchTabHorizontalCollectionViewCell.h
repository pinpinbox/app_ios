//
//  SearchTabHorizontalCollectionViewCell.h
//  wPinpinbox
//
//  Created by David on 5/12/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface SearchTabHorizontalCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet AsyncImageView *userPictureImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@end
