//
//  PreviewPageSetupViewController.h
//  wPinpinbox
//
//  Created by David on 3/21/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PreviewPageSetupViewController;
@protocol PreviewPageSetupViewControllerDelegate <NSObject>

- (void)previewPageSetupViewControllerDisappear: (PreviewPageSetupViewController *)controller;
- (void)previewPageSetupViewControllerDisappearAfterCalling: (PreviewPageSetupViewController *)controller modifySuccess:(BOOL)modifySuccess imageArray: (NSMutableArray *)ImageArray;

@end

@interface PreviewPageSetupViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic) NSMutableArray *imageArray;
@property (nonatomic) NSString *albumId;
@property (weak) id <PreviewPageSetupViewControllerDelegate> delegate;

- (void)callBackButtonFunction;

@end
