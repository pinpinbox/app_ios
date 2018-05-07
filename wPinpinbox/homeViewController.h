//
//  homeViewController.h
//  wPinpinbox
//
//  Created by Angus on 2015/8/7.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface homeViewController : UIViewController
{
    __weak IBOutlet UIButton *button_attMore;
}

- (void)getEventDataForURLScheme: (NSString *)eventId;
- (void)showAlertViewForLocation;
- (void)FastBtnPressed;

@property (nonatomic) NSString *urlString;

@end
