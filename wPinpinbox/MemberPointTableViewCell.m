//
//  MemberPointTableViewCell.m
//  wPinpinbox
//
//  Created by Angus on 2015/10/21.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "MemberPointTableViewCell.h"
#import "wTools.h"
@implementation MemberPointTableViewCell

- (void)awakeFromNib {
    // Initialization code
    _title.text=NSLocalizedString(@"StoreText-currentP", @"");
    [btn_buy setImage:[UIImage imageNamed:[NSString stringWithFormat:@"button_buy_%@.png",[wTools localstring]]] forState:UIControlStateNormal];
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
