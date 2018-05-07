//
//  NotifTabTableViewCell.h
//  wPinpinbox
//
//  Created by David on 5/10/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface NotifTabTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet AsyncImageView *headshotImaveView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *insertTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetTypeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *targetTypeImageView;

@end
