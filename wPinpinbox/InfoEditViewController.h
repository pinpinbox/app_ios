//
//  InfoEditViewController.h
//  wPinpinbox
//
//  Created by David on 4/23/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InfoEditViewController;
@protocol InfoEditViewControllerDelegate <NSObject>
- (void)infoEditViewControllerSaveBtnPressed: (InfoEditViewController *)controller;
- (void)profilePictureUpdate: (NSString *)urlString;
@end

@interface InfoEditViewController : UIViewController

@property (weak) id <InfoEditViewControllerDelegate> delegate;
@property (strong, nonatomic) NSDictionary *userDic;

@end

