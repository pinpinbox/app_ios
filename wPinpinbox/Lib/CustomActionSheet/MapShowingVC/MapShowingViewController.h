//
//  MapShowingViewController.h
//  wPinpinbox
//
//  Created by David Lee on 2017/8/20.
//  Copyright © 2017年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MapShowingViewController;
@protocol MapShowingViewControllerDelegate <NSObject>
//- (void)mapViewBtnPress:(MapShowingViewController *)controller;
- (void)mapShowingActionSheetDidSlideOut:(MapShowingViewController *)controller;
@end

@interface MapShowingViewController : UIViewController

@property (weak) id <MapShowingViewControllerDelegate> delegate;

@property (strong, nonatomic) NSString *locationStr;
@property (strong, nonatomic) NSString *mapStr;

- (void)slideOut;

@end
