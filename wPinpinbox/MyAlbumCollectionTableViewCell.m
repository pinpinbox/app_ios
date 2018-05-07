//
//  MyAlbumCollectionTableViewCell.m
//  wPinpinbox
//
//  Created by David on 6/18/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "MyAlbumCollectionTableViewCell.h"
#import "UIColor+Extensions.h"
#import "GlobalVars.h"

@implementation MyAlbumCollectionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.albumImageView.layer.cornerRadius = kCornerRadius;
    self.albumNameLabel.textColor = [UIColor firstGrey];
    self.albumNameLabel.font = [UIFont boldSystemFontOfSize: 16];
    self.timeLabel.textColor = [UIColor secondGrey];
    self.cooperativeNumberLabel.textColor = [UIColor secondGrey];
    
    [self.settingBtn addTarget: self action: @selector(beginTouch:) forControlEvents: UIControlEventTouchUpInside];
    [self.settingBtn addTarget: self action: @selector(endTouch:) forControlEvents: UIControlEventTouchUpOutside];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)settingBtnPress:(id)sender {
    NSLog(@"settingBtnPress");
    
    if (_customBlock) {
        _customBlock(_settingBtn.selected, _userId, _albumId);
    }
}

- (void)beginTouch: (UIButton *)sender
{
    NSLog(@"beginTouch");
    
    if (_customBlock) {
        _customBlock(_settingBtn.selected, _userId, _albumId);
    }
    
    if (_customBlock) {
        _customBlock(_cellSettingBtn.selected, _userId, _albumId);
    }
    
}

- (void)endTouch: (UIButton *)sender
{
    NSLog(@"endTouch");
    
    self.settingBtn.backgroundColor = [UIColor clearColor];
}

@end
