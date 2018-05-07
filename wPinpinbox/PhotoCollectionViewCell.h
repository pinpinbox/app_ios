//
//  PhotoCollectionViewCell.h
//  wPinpinbox
//
//  Created by Angus on 2015/9/23.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoCollectionViewCell : UICollectionViewCell
@property(weak,nonatomic) IBOutlet UIImageView *myimage;
@property (nonatomic, strong) UIImage *thumbnailImage;
@property(weak,nonatomic)IBOutlet UIView *bgv;
@property(weak,nonatomic)IBOutlet UILabel *titel;
@property (weak, nonatomic) IBOutlet UIImageView *imageTick;

@property (assign, nonatomic) NSInteger reuseCount;
@end
