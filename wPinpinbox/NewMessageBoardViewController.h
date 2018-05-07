//
//  NewMessageBoardViewController.h
//  wPinpinbox
//
//  Created by David on 6/7/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewMessageBoardViewController;
@protocol NewMessageBoardViewControllerDelegate <NSObject>
- (void)newMessageBoardViewControllerDisappear: (NewMessageBoardViewController *)controller msgNumber:(NSUInteger)msgNumber;
@end

@interface NewMessageBoardViewController : UIViewController
@property (strong, nonatomic) NSString *typeId;
@property (strong, nonatomic) NSString *type;
@property (weak) id <NewMessageBoardViewControllerDelegate> delegate;
@end
