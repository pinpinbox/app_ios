//
//  SeacrhbookTableViewCell.h
//  wPinpinbox
//
//  Created by Angus on 2016/2/4.
//  Copyright (c) 2016年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
@interface SeacrhbookTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet AsyncImageView *picture;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *count;
@property (weak, nonatomic) IBOutlet UILabel *titlename;

@end
