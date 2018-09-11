//
//  CopperatiocTableViewCell.m
//  wPinpinbox
//
//  Created by Angus on 2016/1/12.
//  Copyright (c) 2016年 Angus. All rights reserved.
//

#import "CopperatiocTableViewCell.h"
#import "wTools.h"
@implementation CopperatiocTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)layoutSubviews{
    [super layoutSubviews];
    [[_photo layer] setMasksToBounds:YES];
    [[_photo layer]setCornerRadius:_photo.bounds.size.height/2];
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}
-(IBAction)edittype:(id)sender{
    _btn1select(YES);
}
@end
