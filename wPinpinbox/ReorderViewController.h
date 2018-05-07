//
//  ReorderViewController.h
//  wPinpinbox
//
//  Created by David on 7/24/16.
//  Copyright © 2016 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ReorderViewController;
@protocol ReorderViewControllerDelegate <NSObject>
- (void)reorderViewControllerDisappear: (ReorderViewController *)controller imageArray: (NSMutableArray *)ImageArray;
- (void)reorderViewControllerDisappearAfterCalling: (ReorderViewController *)controller;
@end

@interface ReorderViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) NSMutableArray *imageArray;
@property (nonatomic) NSString *albumId;
@property (weak) id <ReorderViewControllerDelegate> delegate;

- (void)callBackButtonFunction;

@end
