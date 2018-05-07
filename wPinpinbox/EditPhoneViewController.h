//
//  EditPhoneViewController.h
//  wPinpinbox
//
//  Created by Angus on 2015/12/21.
//  Copyright © 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "SelectBarViewController.h"
#import "wTools.h"
#import "EditMemberViewController.h"

#import "EditMemberTableViewController.h"

@interface EditPhoneViewController : UIViewController<SelectBarDelegate>
{
    IBOutletCollection(UITextField) NSArray *textlields;
   __weak IBOutlet UITextField *phonetv;
   __weak IBOutlet UITextField *mstv;
   __weak IBOutlet UILabel *phonelab;
    __weak IBOutlet AsyncImageView *myphoto;
    
    
    __weak IBOutlet UILabel *wtitle;
    __weak IBOutlet UILabel *lab_text;
    __weak IBOutlet UILabel *lab_text2;
    __weak IBOutlet UIButton *btn_getvai;
    __weak IBOutlet UILabel *lab_ok;
    
    __weak IBOutlet UILabel *countryLabel;
    __weak IBOutlet UIButton *okBtn;
}

//@property(weak,nonatomic)EditMemberViewController *editview;
@property (weak, nonatomic) EditMemberTableViewController *editview;
@property(strong,nonatomic)NSString *cellphoen;
@property(strong,nonatomic)NSString *email;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;

@end
