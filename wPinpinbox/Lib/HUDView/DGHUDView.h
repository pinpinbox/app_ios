//
//  DGHUDView.h
//  wPinpinbox
//
//  Created by David on 2019/2/1.
//  Copyright © 2019 Angus. All rights reserved.
//

#import "DGActivityIndicatorView.h"

@interface DGHUDView : DGActivityIndicatorView
+ (void)start;
+ (void)stop;
+ (BOOL)isAnimating;
@end
