//
//  NewEventPostViewController.h
//  wPinpinbox
//
//  Created by David Lee on 2017/9/22.
//  Copyright © 2017年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewEventPostViewController : UIViewController
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *evtTitle;
@property (nonatomic) NSString *imageUrl;
@property (nonatomic) NSString *urlString;
@property (nonatomic) NSArray *templateArray;
@property (nonatomic) NSString *eventId;
@property (nonatomic) NSInteger contributionNumber;
@property (nonatomic) NSInteger popularityNumber;
@property (nonatomic) NSString *prefixText;
@property (nonatomic) NSString *specialUrl;
@property (nonatomic) BOOL eventFinished;
@end
