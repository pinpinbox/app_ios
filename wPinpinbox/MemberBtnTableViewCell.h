//
//  MemberBtnTableViewCell.h
//  wPinpinbox
//
//  Created by Angus on 2015/10/21.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^MemberCustomBlock)(void);
@interface MemberBtnTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *title;
@property(weak,nonatomic) IBOutlet UIButton *btn;
@property (nonatomic, copy) MemberCustomBlock customBlock;
@end
