//
//  URLAddViewController.h
//  wPinpinbox
//
//  Created by Antelis on 2018/11/19.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationMapViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol URLSAddDelegate
- (void)didSetURLs:(NSArray * _Nullable )url;
@end
@interface URLAddViewController : UIViewController<UIViewControllerTransitioningDelegate>
@property (nonatomic) id<URLSAddDelegate> urlDelegate;
- (void)loadURLs:(NSArray *)urls ;
@end

NS_ASSUME_NONNULL_END
