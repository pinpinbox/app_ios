//
//  CreativeCollectionViewCell.h
//  wPinpinbox
//
//  Created by Angus on 2015/10/28.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreativeCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *datestr;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIView *bgview;
@end
