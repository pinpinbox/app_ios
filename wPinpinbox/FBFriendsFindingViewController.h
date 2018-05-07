//
//  FBFriendsFindingViewController.h
//  wPinpinbox
//
//  Created by David on 4/17/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FBFriendsFindingViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *okBtn;
@property (weak, nonatomic) IBOutlet UIButton *skipBtn;
@property (weak, nonatomic) IBOutlet UIView *gradientView;
- (IBAction)findFBFriends:(id)sender;
@end
