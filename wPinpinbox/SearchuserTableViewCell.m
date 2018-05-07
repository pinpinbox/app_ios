//
//  SearchuserTableViewCell.m
//  wPinpinbox
//
//  Created by Angus on 2016/2/4.
//  Copyright (c) 2016年 Angus. All rights reserved.
//

#import "SearchuserTableViewCell.h"
#import "wTools.h"
@implementation SearchuserTableViewCell

- (void)awakeFromNib {
    [[_picture layer] setMasksToBounds:YES];
    [[_picture layer]setCornerRadius:_picture.bounds.size.height/2];
    // Initialization code
    [_button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@.png",@"3-01button_track_",[wTools localstring]]] forState:UIControlStateNormal];
    [_button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@.png",@"3-01button_track_click_",[wTools localstring]]] forState:UIControlStateSelected];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (IBAction)btn2:(id)sender {
    if (_touser) {
        //[wTools showCreativeViewuserid:_userid isfollow:_button.selected];
    }
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
