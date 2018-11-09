//
//  ProgressView.h
//  ZDT-DownloadVideoObjC
//
//  Created by Szabolcs Sztanyi on 15/04/15.
//  Copyright (c) 2015 Szabolcs Sztanyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressView : UIView

- (void)animateProgressViewToProgress:(float)progress;
- (void)updateProgressViewLabelWithProgress:(float)progress;
- (void)updateProgressViewWithTotalSent:(float)totalSent andTotalFileSize:(float)fileSize;

- (void)hideProgressView;

@end
