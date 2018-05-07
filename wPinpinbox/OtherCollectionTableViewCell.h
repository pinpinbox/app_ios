//
//  OtherCollectionTableViewCell.h
//  wPinpinbox
//
//  Created by David on 6/18/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface OtherCollectionTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet AsyncImageView *albumImageView;
@property (weak, nonatomic) IBOutlet UILabel *albumNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cooperativeImageView;
@property (weak, nonatomic) IBOutlet UILabel *cooperativeNumberLabel;
@property (weak, nonatomic) IBOutlet AsyncImageView *userImageView;
@end
