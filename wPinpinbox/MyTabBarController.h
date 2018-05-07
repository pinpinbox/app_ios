//
//  MyTabBarController.h
//  wPinpinbox
//
//  Created by David on 12/14/16.
//  Copyright © 2016 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTabBarController : UITabBarController <UITabBarControllerDelegate>
- (void)toHomeTab;
- (void)toMeTab;
- (void)centerBtnPress;
- (void)presentSafariVC:(NSString *)urlStr;
@end
