//
//  MemberCenterViewController.h
//  wPinpinbox
//
//  Created by David on 1/8/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface MemberCenterViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet AsyncImageView *headShotImageView;
@property (weak, nonatomic) IBOutlet AsyncImageView *headShotBgImageView;
@property (weak, nonatomic) IBOutlet UILabel *viewNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *followNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;


@end
