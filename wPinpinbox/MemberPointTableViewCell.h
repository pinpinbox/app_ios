//
//  MemberPointTableViewCell.h
//  wPinpinbox
//
//  Created by Angus on 2015/10/21.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^MemberCustomBlock)(void);
@interface MemberPointTableViewCell : UITableViewCell
{
    __weak IBOutlet UIButton *btn_buy;
}
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *mytext;
@property (nonatomic, copy) MemberCustomBlock customBlock;
@end
