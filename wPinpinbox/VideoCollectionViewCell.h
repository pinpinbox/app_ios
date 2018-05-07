//
//  VideoCollectionViewCell.h
//  wPinpinbox
//
//  Created by David on 9/13/16.
//  Copyright © 2016 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *myImage;
@property (weak, nonatomic) IBOutlet UIView *bgV;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
//@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIImageView *imageTick;

@property (strong, nonatomic) UIImage *thumbnailImage;

@end
