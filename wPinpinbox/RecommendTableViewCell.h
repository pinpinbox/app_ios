//
//  RecommendTableViewCell.h
//  wPinpinbox
//
//  Created by Angus on 2015/10/22.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^Buttontouch)(BOOL add,NSString *userid);
@interface RecommendTableViewCell : UITableViewCell
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
