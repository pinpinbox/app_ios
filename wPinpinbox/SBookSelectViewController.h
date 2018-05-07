//
//  SBookSelectViewController.h
//  wPinpinbox
//
//  Created by Angus on 2016/1/7.
//  Copyright (c) 2016年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SBookSelectViewController <NSObject>
-(void)SaveDataRow:(NSInteger)row;
-(void)DidselectDataRow:(NSInteger)row;
@end
@interface SBookSelectViewController : UIViewController
{
    NSInteger selectrow;
}
@property(weak)id<SBookSelectViewController>delegate;
@property(weak) UIViewController *topViewController;
@property(strong,nonatomic)NSArray *data;
@property(weak,nonatomic)IBOutlet UILabel *mytitle;
@property(nonatomic)NSString *mytitletext;
@end
