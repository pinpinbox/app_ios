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
@end


@interface YAlbumDetailContainerViewController : UIViewController<ZoomTransitionDelegate>
@property (nonatomic) YAlbumDetailViewController *currentDetailVC; //  content VC to display album detail
@property (nonatomic) YAlbumDetailVCTransitionController *zoomTransitionController;
@property (nonatomic) id<ZoomTransitionDelegate> toVCDelegate;
@property (nonatomic) CGRect sourceRect;
@property (nonatomic) UIImageView  * _Nullable sourceView;
@property (nonatomic) NSString *album_id;
@property (nonatomic) BOOL noparam;
@property (nonatomic) NSString *fromVC;
@property (nonatomic) BOOL getMessagePush;
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
