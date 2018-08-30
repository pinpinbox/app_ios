//
//  DMViewController.h
//  wPinpinbox
//
//  Created by David on 2018/8/29.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DMViewController : UIViewController
@property(strong, nonatomic) NSString *baseURL;
@property(strong, nonatomic) NSString *videoID;
@property(strong, nonatomic) NSDictionary *additionalParameters;
@end
