//
//  CopperatiocTableViewCell.h
//  wPinpinbox
//
//  Created by Angus on 2016/1/12.
//  Copyright (c) 2016年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^Buttontouch1)(BOOL select);
@interface CopperatiocTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *typetitle;
@property (weak, nonatomic) IBOutlet UIButton *typebtn;
@property (strong, nonatomic) NSString *type;


@property (nonatomic, copy)Buttontouch1 btn1select;
@end
