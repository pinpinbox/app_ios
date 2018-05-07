//
//  EditMemberViewController.h
//  wPinpinbox
//
//  Created by Angus on 2015/10/21.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Remind.h"
@interface EditMemberViewController : UIViewController{
    
    __weak IBOutlet UILabel *wtitle;
    __weak IBOutlet UILabel *lab_about;
    __weak IBOutlet UILabel *lab_nickName;
    __weak IBOutlet UILabel *lab_email;
    __weak IBOutlet UILabel *lab_pwd;
    __weak IBOutlet UIButton *btn_pwd;
    __weak IBOutlet UILabel *labe_phone;
    __weak IBOutlet UIButton *btn_phone;
    __weak IBOutlet UILabel *lab_sex;
    __weak IBOutlet UILabel *lab_birthday;
    __weak IBOutlet UILabel *lab_ok;
}

@property(weak,nonatomic) IBOutlet UITextField *cellphone;
@end
