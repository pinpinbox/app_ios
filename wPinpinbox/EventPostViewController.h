//
//  EventPostViewController.h
//  wPinpinbox
//
//  Created by vmage on 8/29/16.
//  Copyright © 2016 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventPostViewController : UIViewController

@property (nonatomic) NSString *imageName;
@property (nonatomic) NSString *urlString;
@property (nonatomic) NSArray *templateArray;
@property (nonatomic) NSString *eventId;
//@property (nonatomic) NSString *templateId;
@property (nonatomic) BOOL eventFinished;

@end
