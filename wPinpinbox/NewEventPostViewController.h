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
@property (nonatomic) NSString *eventTitle;
@property (nonatomic) NSString *imageUrl;
@property (nonatomic) NSString *urlString;
@property (nonatomic) NSArray *templateArray;
@property (nonatomic) NSString *eventId;
@property (nonatomic) NSInteger contributionNumber;
@property (nonatomic) NSInteger popularityNumber;
@property (nonatomic) NSString *prefixText;
@property (nonatomic) NSString *specialUrl;
@property (nonatomic) NSString *contributeStartTime;
@property (nonatomic) NSString *contributeEndTime;
@property (nonatomic) NSString *voteStartTime;
@property (nonatomic) NSString *voteEndtime;
@property (nonatomic) BOOL eventFinished;
@end
