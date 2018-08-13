//
//  ContentCheckingViewController.h
//  wPinpinbox
//
//  Created by David on 2018/7/23.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ContentCheckingViewController;
@protocol ContentCheckingViewControllerDelegate <NSObject>
- (void)contentCheckingViewControllerViewWillDisappear:(ContentCheckingViewController *)controller isLikeBtnPressed:(BOOL)isLikeBtnPressed;
@end

@interface ContentCheckingViewController : UIViewController
@property (weak) id <ContentCheckingViewControllerDelegate> delegate;

@property (nonatomic) BOOL isPresented;
@property (strong, nonatomic) NSString *albumId;

//@property (nonatomic, strong) NSString *eventId;
@property (nonatomic, strong) NSString *eventJoin;
@property (nonatomic) BOOL postMode;

@property (nonatomic) BOOL audioSwitch;
@property (nonatomic) BOOL videoPlay;

@property (nonatomic) BOOL isLikes;
//@property (nonatomic) NSUInteger likeNumber;

@property (nonatomic) NSString *specialUrl;

@end
