//
//  NewMessageTableViewCell.h
//  wPinpinbox
//
//  Created by David on 6/10/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "MyLinearLayout.h"

@interface NewMessageTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet AsyncImageView *pictureImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *insertTimeLabel;
@property (weak, nonatomic) IBOutlet MyLinearLayout *bgContentLayout;
@property (weak, nonatomic) IBOutlet MyLinearLayout *subContentLayout;

@end
