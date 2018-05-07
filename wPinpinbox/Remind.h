//
//  Remind.h
//  wPinpinbox
//
//  Created by Angus on 2015/10/27.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^Buttontouch1)(BOOL select);

@interface Remind : UIView
{
    UIButton *backbtn;
    
    UIImageView *image;
}

//更換標示圖
-(void)editiamgetick;

//進入
-(void)showView:(UIView *)v;

//按背景離開
-(void)addBackTouch;


//新增提示文字
-(void)addtitletext:(NSString *)str;
- (void)addMoreTitleText: (NSString *)str;

//新增兩顆按鈕
-(void)addSelectBtntext:(NSString *)btn1text btn2:(NSString *)btn2text;

@property (nonatomic, copy)Buttontouch1 btn1select;
@end
