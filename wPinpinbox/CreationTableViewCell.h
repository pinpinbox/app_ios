//
//  CreationTableViewCell.h
//  wPinpinbox
//
//  Created by David on 12/15/16.
//  Copyright © 2016 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface CreationTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet AsyncImageView *picture;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@end
