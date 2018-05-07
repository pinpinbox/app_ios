//
//  MessageTableViewCell.h
//  wPinpinbox
//
//  Created by David on 02/04/2018.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyLinearLayout.h"

typedef void(^Buttontouch)(NSString *userId, NSString *userName);

@interface MessageTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *pictureImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *insertTimeLabel;
@property (weak, nonatomic) IBOutlet MyLinearLayout *bgContentLayout;
@property (weak, nonatomic) IBOutlet MyLinearLayout *subContentLayout;

@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *userName;
@property (copy, nonatomic) Buttontouch customBlock;

@end
