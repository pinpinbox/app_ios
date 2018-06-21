//
//  LikeListTableViewCell.h
//  wPinpinbox
//
//  Created by David on 2018/6/21.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^ButtonTouch)(BOOL selected, NSInteger tag);

@interface LikeListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headshotImageView;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@property (weak, nonatomic) IBOutlet UIButton *messageBtn;
@property (weak, nonatomic) IBOutlet UIButton *followBtn;
@property (nonatomic) BOOL isFollow;

@property (copy, nonatomic) ButtonTouch customBlock;
@end
