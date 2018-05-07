//
//  RetrievehotrankViewController.h
//  wPinpinbox
//
//  Created by Angus on 2015/10/23.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RetrievehotrankViewController : UIViewController{
   __weak IBOutlet UILabel *wtitele;
}
@property (strong,nonatomic) NSString *ranktype;

@property (weak, nonatomic) IBOutlet UIButton *bottom_HotBtn; //熱門
@property (weak, nonatomic) IBOutlet UIButton *bottom_FreeBtn; //免費
@property (weak, nonatomic) IBOutlet UIButton *bottom_SupBtn; //贊助

@end
