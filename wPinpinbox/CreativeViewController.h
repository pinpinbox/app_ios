//
//  CreativeViewController.h
//  wPinpinbox
//
//  Created by Angus on 2015/10/28.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreativeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *mytitle;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property(nonatomic)NSString *albumid;
@property(nonatomic)NSString *userid;
@property(nonatomic)BOOL follow;
@end
