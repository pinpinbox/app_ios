//
//  SearchuserTableViewCell.h
//  wPinpinbox
//
//  Created by Angus on 2016/2/4.
//  Copyright (c) 2016年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^Buttontouch)(BOOL add,NSString *userid);

@interface SearchuserTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *picture;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *count;
@property (weak, nonatomic) IBOutlet UILabel *inserttime;
@property(strong,nonatomic) NSString *userid;
@property (nonatomic, assign) BOOL touser;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (nonatomic, copy) Buttontouch customBlock;

-(void)isaddData:(BOOL)add;

@end
