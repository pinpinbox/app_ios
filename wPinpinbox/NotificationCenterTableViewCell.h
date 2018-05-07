//
//  NotificationCenterTableViewCell.h
//  wPinpinbox
//
//  Created by David on 12/30/16.
//  Copyright © 2016 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
@interface NotificationCenterTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet AsyncImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
