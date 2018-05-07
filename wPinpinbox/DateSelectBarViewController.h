//
//  DateSelectBarViewController.h
//  wPinpinbox
//
//  Created by Angus on 2015/10/12.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol DateSelectBarDelegate <NSObject>
-(void)SaveDataRowData:(NSDate*)date;
@end
@interface DateSelectBarViewController : UIViewController
{
    NSInteger selectrow;
    __weak IBOutlet UIDatePicker *datepicker;
}
@property(weak)id<DateSelectBarDelegate>delegate;
@property(weak) UIViewController *topViewController;
@property(assign,nonatomic)NSDate *selectdate;
@property(assign,nonatomic)NSArray *data;
@end
