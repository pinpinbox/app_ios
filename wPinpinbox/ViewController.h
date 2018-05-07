//
//  ViewController.h
//  wPinpinbox
//
//  Created by Angus on 2015/8/6.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{
    __weak IBOutlet UITextField *email;
    __weak IBOutlet UITextField *pwd;
}

- (void)setTimerForUrlScheme: (NSString *)BUID;

@end
