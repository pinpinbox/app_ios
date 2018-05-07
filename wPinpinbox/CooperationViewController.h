//
//  CooperationViewController.h
//  wPinpinbox
//
//  Created by Angus on 2016/1/12.
//  Copyright (c) 2016年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CooperationViewController : UIViewController
{
    __weak IBOutlet UITableView *mytable;
    __weak IBOutlet UILabel *wtitle;
    
}
@property(nonatomic)NSString *albumid;
@property(nonatomic)NSString *identity;

@end
