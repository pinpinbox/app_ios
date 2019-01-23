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
@class YAlbumDetailVCTransitionController;

@protocol ZoomTransitionDelegate  <NSObject>
@optional
- (void)transitionWillStartWith:(ZoomAnimator *)zoomAnimator;
- (void)transitionDidEndWith:(ZoomAnimator *)zoomAnimator;
- (UIImageView * _Nullable )sourceImageView:(ZoomAnimator *)zoomAnimator;
- (UIImageView *)referenceImageView:(ZoomAnimator *)zoomAnimator;
- (CGRect)sourceImageViewFrameInTransitioningView:(ZoomAnimator *)zoomAnimator;
- (CGRect)referenceImageViewFrameInTransitioningView:(ZoomAnimator *)zoomAnimator;
- (BOOL)isSlim;
@end


@interface YAlbumDetailContainerViewController : UIViewController<ZoomTransitionDelegate>
@property (nonatomic) YAlbumDetailViewController *currentDetailVC; //  content VC to display album detail
@property (nonatomic) YAlbumDetailVCTransitionController *zoomTransitionController; // VC transitioning handler
@property (nonatomic) CGRect sourceRect; //  initial or target rect of transition animation
@property (nonatomic) UIImageView  * _Nullable sourceView; //  get image from sourceView
@property (nonatomic) NSString *album_id;
@property (nonatomic) BOOL noparam; // YES: dont send isViewed, NO: send isViewed to backend
@property (nonatomic) NSString *fromVC; // VC name of presenting Album detail
@property (nonatomic) BOOL getMessagePush; // if show messageboard directly

+ (YAlbumDetailContainerViewController *)albumDetailVCWithAlbumID:(NSString *)albumid
                                                        albumInfo:(NSDictionary * _Nullable )albumInfo;
+ (YAlbumDetailContainerViewController *)albumDetailVCWithAlbumID:(NSString *)albumid
                                                        albumInfo:(NSDictionary *)albumInfo
                                                       sourceRect:(CGRect)sourceRect
                                                  sourceImageView:(UIImageView * _Nullable )sourceImageView;

+ (YAlbumDetailContainerViewController *)albumDetailVCWithAlbumID:(NSString *)albumid
                                                       sourceRect:(CGRect)sourceRect
                                                  sourceImageView:( UIImageView * _Nullable )sourceImageView
                                                          noParam:(BOOL)noParam;

@end

NS_ASSUME_NONNULL_END
