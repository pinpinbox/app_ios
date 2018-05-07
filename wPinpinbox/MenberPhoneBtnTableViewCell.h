//
//  MenberPhoneBtnTableViewCell.h
//  wPinpinbox
//
//  Created by Angus on 2015/12/21.
//  Copyright © 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^MemberCustomBlock)(void);
@interface MenberPhoneBtnTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *phonetitle;
@property (nonatomic, copy) MemberCustomBlock customBlock;
@end
