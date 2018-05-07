//
//  Remind.m
//  wPinpinbox
//
//  Created by Angus on 2015/10/27.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "Remind.h"
#import "wTools.h"

@implementation Remind

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
     //新增背景色
        self.backgroundColor=[UIColor colorWithRed:(float)1/255 green:(float)1/255 blue:(float)1/255 alpha:0.8];
        
        backbtn=[wTools W_Button:self frame:self.bounds imgname:@"" SELL:@selector(backbtn:) tag:1];
        [self addSubview:backbtn];
        backbtn.hidden=YES;
        
        image=[[UIImageView alloc]initWithFrame:CGRectMake(88, 148, 145, 145)];
        image.image=[UIImage imageNamed:@"icon_exclamation.png"];
        [self addSubview:image];
    }
    return self;
}

-(void)backbtn:(id)sender{
     [self myback];
    if (_btn1select) {
        _btn1select(YES);
    }
}
-(void)myback{
    UIView *b=[[UIView alloc]initWithFrame:self.bounds];
    b.backgroundColor=[UIColor clearColor];
    [self addSubview:b];
    
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha=0;
    } completion:^(BOOL anim){
        
        [self removeFromSuperview];
    }];

}

-(void)editiamgetick{
    image.image=[UIImage imageNamed:@"icon_tick.png"];
}
//進入
-(void)showView:(UIView *)v{
  
    self.alpha=0;
    UIView *b=[[UIView alloc]initWithFrame:self.bounds];
    b.backgroundColor=[UIColor clearColor];
    [self addSubview:b];
    
    [v addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha=1;
    } completion:^(BOOL anim){
        [b removeFromSuperview];
    }];
    
}


//按背景離開
-(void)addBackTouch{
    backbtn.hidden=NO;
}


//新增提示文字
-(void)addtitletext:(NSString *)str {
    UILabel *lab = (UILabel *)[self viewWithTag: 1111];
    if (lab == nil) {
        lab = [[UILabel alloc] initWithFrame: CGRectMake(51, 301, 219, 100)];
        lab.textColor = [UIColor whiteColor];
        lab.numberOfLines = 0;
        lab.tag = 1111;
        lab.backgroundColor = [UIColor clearColor];
        lab.textAlignment = NSTextAlignmentCenter;
        [self addSubview: lab];
    }
    
    if ([str isEqualToString:@""] || str == nil) {
        lab.text = @"404";
    } else {
        lab.text = str;
    }
}

// For lots of text displaying
- (void)addMoreTitleText: (NSString *)str
{
    UILabel *lab = (UILabel *)[self viewWithTag: 1111];
    if (lab == nil) {
        lab = [[UILabel alloc] initWithFrame: CGRectMake(51, 301, 219, 130)];
        lab.textColor = [UIColor whiteColor];
        lab.numberOfLines = 0;
        lab.tag = 1111;
        lab.backgroundColor = [UIColor clearColor];
        lab.textAlignment = NSTextAlignmentCenter;
        [self addSubview: lab];
    }
    
    if ([str isEqualToString:@""] || str == nil) {
        lab.text = @"404";
    } else {
        lab.text = str;
    }
}

//新增兩顆按鈕
-(void)addSelectBtntext:(NSString *)btn1text btn2:(NSString *)btn2text{
   
    UIButton *btn1=(UIButton*)[self viewWithTag:1001];
    UIButton *btn2=(UIButton*)[self viewWithTag:1002];
    
    if (btn1==nil) {
        btn1=[wTools W_Button:self frame:CGRectMake(89, 362, 52, 30) imgname:@"" SELL:@selector(btn1) tag:1001];
        [self addSubview:btn1];
    }
    if (btn2==nil) {
        btn2=[wTools W_Button:self frame:CGRectMake(180, 362, 52, 30) imgname:@"" SELL:@selector(btn2) tag:1002];
        [self addSubview:btn2];
    }
    
    [btn1 setTitle:btn1text forState:UIControlStateNormal];
    [btn2 setTitle:btn2text forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
}

-(void)btn1{
    [self myback];
    if (_btn1select) {
        _btn1select(YES);
    }
}
-(void)btn2{
    [self myback];
    if (_btn1select) {
        _btn1select(NO);
    }
}
@end
