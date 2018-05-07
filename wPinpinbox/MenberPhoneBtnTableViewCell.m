//
//  MenberPhoneBtnTableViewCell.m
//  wPinpinbox
//
//  Created by Angus on 2015/12/21.
//  Copyright © 2015年 Angus. All rights reserved.
//

#import "MenberPhoneBtnTableViewCell.h"

@implementation MenberPhoneBtnTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(IBAction)btn:(id)sender{
    if (_customBlock) {
        _customBlock();
    }
}
@end
