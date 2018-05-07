//
//  MemberTextViewTableViewCell.m
//  wPinpinbox
//
//  Created by Angus on 2015/10/20.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "MemberTextViewTableViewCell.h"

@implementation MemberTextViewTableViewCell

- (void)awakeFromNib {
    // Initialization code
    _mytextview.textColor=[UIColor whiteColor];
    _title.text=NSLocalizedString(@"ProfileText-about", @"");
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
