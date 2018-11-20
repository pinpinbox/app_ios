//
//  SelectBarViewController.h
//  wPinpinbox
//
//  Created by Angus on 2015/10/10.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SelectBarDelegate <NSObject>
@optional
- (void)SaveDataRow:(NSInteger)row;
- (void)cancelButtonPressed;
@end

@interface SelectBarViewController : UIViewController
{
    NSInteger selectrow;
} 
@property(weak)id<SelectBarDelegate>delegate;
@property(weak) UIViewController *topViewController;
@property(strong,nonatomic)NSArray *data;
@end
