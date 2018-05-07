//
//  MemberCenterTableViewController.h
//  wPinpinbox
//
//  Created by David on 1/9/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface MemberCenterTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet AsyncImageView *headShotImageView;
@property (weak, nonatomic) IBOutlet AsyncImageView *headShotBgImageView;
@property (weak, nonatomic) IBOutlet UILabel *viewNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *followNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextView *introTextView;

@end
