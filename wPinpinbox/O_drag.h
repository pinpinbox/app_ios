//
//  O_drag.h
//  wPinpinbox
//
//  Created by Angus on 2015/8/12.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>


@class O_drag;
@protocol dragDelegate <NSObject>
//呼叫相本、相機
-(void)selectPhoto:(O_drag *)drag;

@end

@interface O_drag : UIView{
    CGFloat scale,rotate;
    CGPoint location;
@private
    CGSize _originalImageViewSize;
}
@property(nonatomic)id<dragDelegate>delegate;
@property(strong,nonatomic)UIImageView *imageView;
@property(strong,nonatomic)UIImage *image;
//旋轉角度
-(CGFloat)imagerotate;

//放大倍率
-(CGFloat)imagescale;
- (UIImage *)finishCropping ;







@end
