//
//  ModeTableViewCell.h
//  wPinpinbox
//
//  Created by Angus on 2015/11/27.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
@interface ModeTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet AsyncImageView *topimage;
@property (weak, nonatomic) IBOutlet UILabel *title1;
@property (weak, nonatomic) IBOutlet UILabel *title2;
@property (weak, nonatomic) IBOutlet UILabel *typelab;
@property (weak, nonatomic) IBOutlet UIImageView *typeimage;
@property (weak, nonatomic) IBOutlet UILabel *downlab;
@property (weak, nonatomic) IBOutlet UILabel *titletext;

@end
