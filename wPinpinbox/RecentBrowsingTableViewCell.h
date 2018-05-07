//
//  RecentBrowsingTableViewCell.h
//  wPinpinbox
//
//  Created by David on 5/23/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface RecentBrowsingTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet AsyncImageView *albumImageView;
@property (weak, nonatomic) IBOutlet UILabel *albumNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *creatorNameLabel;

@end
