//
//  CoopTopTableViewCell.m
//  wPinpinbox
//
//  Created by Angus on 2016/1/12.
//  Copyright (c) 2016年 Angus. All rights reserved.
//

#import "CoopTopTableViewCell.h"

@implementation CoopTopTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
    wtitle.text=NSLocalizedString(@"CreateAlbumText-owner", @"");
    [_addbtn setTitle:NSLocalizedString(@"CreateAlbumText-inviteMore", @"") forState:UIControlStateNormal];
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

- (IBAction)addbtn:(id)sender{
    _btn1select(YES);
}

- (IBAction)qrcodeScan:(id)sender
{
    _btn2select(YES);
}

@end
