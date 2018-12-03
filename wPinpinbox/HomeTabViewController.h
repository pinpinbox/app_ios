//
//  HomeTabViewController.h
//  wPinpinbox
//
//  Created by David on 4/22/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface CustomTintButton : UIButton
@end

@interface HomeTabViewController : UIViewController
- (void)getEventData: (NSString *)eventId;
@end
