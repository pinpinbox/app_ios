//
//  RecommendTableViewCell.m
//  wPinpinbox
//
//  Created by Angus on 2015/10/22.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "RecommendTableViewCell.h"
#import "wTools.h"
@implementation RecommendTableViewCell

- (void)awakeFromNib {
    [[_picture layer] setMasksToBounds:YES];
    [[_picture layer]setCornerRadius:_picture.bounds.size.height/2];
    
    [_button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@.png",@"button_track_",[wTools localstring]]] forState:UIControlStateNormal];
    [_button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@.png",@"button_track_click_",[wTools localstring]]] forState:UIControlStateSelected];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)btn2:(id)sender {
    if (_touser) {
         [wTools showCreativeViewuserid:_userid isfollow:_button.selected];
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
