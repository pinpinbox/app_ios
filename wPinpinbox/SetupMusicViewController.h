//
//  SetupMusicViewController.h
//  wPinpinbox
//
//  Created by David on 6/20/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SetupMusicViewController;
@protocol SetupMusicViewControllerDelegate <NSObject>
- (void)dismissFromSetupMusicVC: (SetupMusicViewController *)controller audioModeChanged:(BOOL)audioModeChanged;
@end

@interface SetupMusicViewController : UIViewController
@property (strong, nonatomic) NSMutableDictionary *data;
@property (strong, nonatomic) NSString *audioMode;
@property (strong, nonatomic) NSString *albumId;
@property (weak) id <SetupMusicViewControllerDelegate> delegate;
@end
