//
//  FollowFromListTableViewCell.h
//  wPinpinbox
//
//  Created by David on 07/05/2018.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ButtonTouch)(BOOL selected, NSInteger tag);

@interface FollowFromListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headshotImageView;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@property (weak, nonatomic) IBOutlet UIButton *messageBtn;
@property (weak, nonatomic) IBOutlet UIButton *followBtn;
@property (nonatomic) BOOL isFollow;

@property (copy, nonatomic) ButtonTouch customBlock;

@end
