//
//  CooperationAddTableViewCell.m
//  wPinpinbox
//
//  Created by Angus on 2016/1/13.
//  Copyright (c) 2016年 Angus. All rights reserved.
//

#import "CooperationAddTableViewCell.h"

@implementation CooperationAddTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [[_picture layer] setMasksToBounds:YES];
    [[_picture layer]setCornerRadius:_picture.bounds.size.height/2];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


-(void)isaddData:(BOOL)add{
    _button.selected=add;
}

-(IBAction)btn:(id)sender{
    if (_customBlock) {
        _customBlock(_button.selected,_userid);
    }
}

@end
