//
//  LocationMapViewController.h
//  wPinpinbox
//
//  Created by Antelis on 2018/11/14.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#if(DEBUG)
#define MAPAPIKEY @"AIzaSyBKCVhRB6zjhZ0d0gcXALT8Ts4s8AfxMBk"
#else
#define MAPAPIKEY @"AIzaSyBccGhjCogT8jAtxA9H8wpjL-chOjJI1HE"
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol AddLocationDelegate
- (void)didSelectLocation:(NSString *)location;
@end

@interface MapPresentationController : UIPresentationController
@end
@interface MapAnimationTransitioning : NSObject<UIViewControllerAnimatedTransitioning>
- (id)initWithType:(BOOL)isPrensenting;
@end
@interface LocationMapViewController : UIViewController<UIViewControllerTransitioningDelegate>
@property (nonatomic) id<AddLocationDelegate> locationDelegate;
- (void)loadLocation:(NSString *)l;

@end

NS_ASSUME_NONNULL_END
