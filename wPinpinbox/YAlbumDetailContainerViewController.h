//
//  YAlbumDetailContainerViewController.h
//  wPinpinbox
//
//  Created by Antelis on 2019/1/8.
//  Copyright © 2019 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YAlbumDetailViewController.h"
NS_ASSUME_NONNULL_BEGIN

@class ZoomAnimator;

@protocol ZoomTransitionDelegate  <NSObject>
@optional
- (void)transitionWillStartWith:(ZoomAnimator *)zoomAnimator;
- (void)transitionDidEndWith:(ZoomAnimator *)zoomAnimator;
- (UIImageView *)sourceImageView:(ZoomAnimator *)zoomAnimator;
- (UIImageView *)referenceImageView:(ZoomAnimator *)zoomAnimator;
- (CGRect)sourceImageViewFrameInTransitioningView:(ZoomAnimator *)zoomAnimator;
- (CGRect)referenceImageViewFrameInTransitioningView:(ZoomAnimator *)zoomAnimator;
@end
// VC transition animation controller
@interface ZoomAnimator : NSObject <UIViewControllerAnimatedTransitioning>
@property(weak, nonatomic) id<ZoomTransitionDelegate> fromDelegate;
@property(weak, nonatomic) id<ZoomTransitionDelegate> toDelegate;
//  temp cell image
@property(nonatomic) UIImageView *transitionImageView;
@property(nonatomic) BOOL isPresenting;
- (void)animateZoomInTransition:(id<UIViewControllerContextTransitioning>) transitionContext;
- (void)animateZoomOutTransition:(id<UIViewControllerContextTransitioning>) transitionContext;
@end

// VC Transition with user interaction, pan or drag
@interface  ZoomDismissalInteractionController : NSObject <UIViewControllerInteractiveTransitioning>
@property(nonatomic) id<UIViewControllerContextTransitioning> __nullable transitionContext;
@property(nonatomic) id<UIViewControllerAnimatedTransitioning> animator;
@property(nonatomic) BOOL isEasyOut; //  TRUE: dismiss by right-to-left pan, FALSE: drag down to dismiss
@property(nonatomic) CGRect fromReferenceImageViewFrame;
@property(nonatomic) CGRect toReferenceImageViewFrame;
@end

@interface YAlbumDetailVCTransitionController : NSObject <UINavigationControllerDelegate, UIViewControllerTransitioningDelegate>
@property(nonatomic) BOOL isInteractive; //  TRUE: Using pan / drag to dismiss, FALSE: controlled by zoom in/ zoom out effect
@property(nonatomic) BOOL isEasyOut; //  TRUE: dismiss by right-to-left pan, FALSE: drag down to dismiss
@property(nonatomic) ZoomAnimator *animator;
@property(nonatomic) ZoomDismissalInteractionController *interactionController;
@property(weak, nonatomic) id<ZoomTransitionDelegate> fromDelegate;
@property(weak, nonatomic) id<ZoomTransitionDelegate> toDelegate;

@end

@interface YAlbumDetailContainerViewController : UIViewController<ZoomTransitionDelegate>
@property (nonatomic) YAlbumDetailViewController *currentDetailVC; //  content VC to display album detail
@property (nonatomic) YAlbumDetailVCTransitionController *zoomTransitionController;
@property (nonatomic) id<ZoomTransitionDelegate> toVCDelegate;
@property (nonatomic) CGRect sourceRect;
@property (nonatomic) UIImageView *sourceView;
@property (nonatomic) NSString *album_id;
@end

NS_ASSUME_NONNULL_END
