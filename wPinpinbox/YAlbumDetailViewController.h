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
- (void)setupAlbumWithInfo:(NSDictionary *)info;
- (void)setAlubumId:(NSString *)aid;
- (UIImageView *)albumCoverView;
- (void)setContentBtnVisible;
- (void)setHeaderPlaceholder:(UIImage *)placeholder;
- (BOOL)isPointInHeader:(CGPoint)point;
- (BOOL)isPanValid;
@end

NS_ASSUME_NONNULL_END
