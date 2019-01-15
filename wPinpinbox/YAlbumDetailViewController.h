//
//  YAlbumDetailViewController.h
//  wPinpinbox
//
//  Created by Antelis on 2019/1/7.
//  Copyright © 2019 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YAlbumDetailViewController : UIViewController
@property(nonatomic) IBOutlet UIScrollView *baseView;
@property(nonatomic) IBOutlet UIButton *dismissBtn;
@property(nonatomic) BOOL noparam;
@property(nonatomic) NSString *fromVC;
@property(nonatomic) BOOL isMessageShowing;
- (void)setupAlbumWithInfo:(NSDictionary *)info albumId:(NSString *)albumId;
- (void)setAlubumId:(NSString *)aid;
- (UIImageView *)albumCoverView;
- (void)setContentBtnVisible;
- (void)setHeaderPlaceholder:(UIImage *)placeholder;
- (BOOL)isPointInHeader:(CGPoint)point;
- (BOOL)isPanValid;
@end

NS_ASSUME_NONNULL_END
