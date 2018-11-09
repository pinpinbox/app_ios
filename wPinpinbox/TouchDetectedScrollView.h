//
//  TouchDetectedScrollView.h
//  wPinpinbox
//
//  Created by David on 6/22/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TouchDetectedScrollView;
@protocol TouchDetectedScrollViewDelegate <NSObject>
@optional
- (void)didTouchBegin:(TouchDetectedScrollView *)controller touches:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)didTouchMove:(TouchDetectedScrollView *)controller touches:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)didTouchEnd:(TouchDetectedScrollView *)controller touches:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)didTouchCancel:(TouchDetectedScrollView *)controller touches:(NSSet *)touches withEvent:(UIEvent *)event;
@end

@interface TouchDetectedScrollView : UIScrollView

@property (nonatomic, assign) id <TouchDetectedScrollViewDelegate> detectedDelegate;

@end
