//
//  NewExistingAlbumCollectionViewCell.h
//  wPinpinbox
//
//  Created by David on 07/02/2018.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewExistingAlbumCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (weak, nonatomic) IBOutlet UILabel *cancelPostLabel;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end
