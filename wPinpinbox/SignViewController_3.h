//
//  SignViewController_3.h
//  wPinpinbox
//
//  Created by Angus on 2015/8/7.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
//
@interface SignViewController_3 : UIViewController
{
    __weak IBOutlet UIButton *btn_send;    
    __weak IBOutlet UIButton *btn_finishedReg;
    
    __weak IBOutlet UIButton *navBackBtn;
}
@property(strong,nonatomic)NSString *facebookID;
@end
