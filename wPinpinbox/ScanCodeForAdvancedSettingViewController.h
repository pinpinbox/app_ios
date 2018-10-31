//
//  ScanCodeForAdvancedSettingViewController.h
//  wPinpinbox
//
//  Created by David on 2017/10/23.
//  Copyright © 2017年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ScanFinishedBlock)(NSArray *anyids);

@interface ScanCodeForAdvancedSettingViewController : UIViewController
@property (nonatomic) ScanFinishedBlock finishedBlock;
@end
