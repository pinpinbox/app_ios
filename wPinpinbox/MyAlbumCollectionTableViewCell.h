//
//  MyAlbumCollectionTableViewCell.h
//  wPinpinbox
//
//  Created by David on 6/18/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

typedef void(^buttonTouch)(BOOL selected, NSString *userId, NSString *albumId);

@interface MyAlbumCollectionTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet AsyncImageView *albumImageView;
@property (weak, nonatomic) IBOutlet UILabel *albumNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cooperativeImageView;
@property (weak, nonatomic) IBOutlet UILabel *cooperativeNumberLabel;
@property (weak, nonatomic) IBOutlet UIButton *settingBtn;

@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *albumId;
@property (copy, nonatomic) buttonTouch customBlock;

@property (weak, nonatomic) IBOutlet UIView *cellSubView;
@property (weak, nonatomic) IBOutlet UIButton *cellSettingBtn;
@end
