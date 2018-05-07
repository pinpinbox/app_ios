//
//  CoopTopTableViewCell.h
//  wPinpinbox
//
//  Created by Angus on 2016/1/12.
//  Copyright (c) 2016年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^Buttontouch1)(BOOL select);
typedef void(^Buttontouch2)(BOOL select);

@interface CoopTopTableViewCell : UITableViewCell{
    __weak IBOutlet UILabel *wtitle;
}
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIButton *addbtn;
@property (nonatomic, copy) Buttontouch1 btn1select;
@property (nonatomic, copy) Buttontouch2 btn2select;

@end
