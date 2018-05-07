//
//  VideoViewController.h
//  wPinpinbox
//
//  Created by Angus on 2015/11/25.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookViewController.h"

@interface VideoViewController : UIViewController
{
    __weak IBOutlet UIView  *videoView;
}

@property(nonatomic)NSString *videofile;
@property (weak) BookViewController *bookVC;

@end