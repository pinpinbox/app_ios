//
//  wShowImageList.m
//  wPinpinbox
//
//  Created by Angus on 2015/12/17.
//  Copyright © 2015年 Angus. All rights reserved.
//

#import "wShowImageList.h"
#import "AsyncImageView.h"
#import "wTools.h"

@implementation wShowImageList

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)showView:(int)page{
    self.backgroundColor=[UIColor whiteColor];
    vc=[[MyScrollView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    vc.backgroundColor=[UIColor blackColor];
    vc.dataSourceDelegate=self;
    vc.pagingEnabled=YES;
    [vc initWithDelegate:self atPage:page];
    [self addSubview:vc];
    
    UIButton *btn=[wTools W_Button:self frame:CGRectMake(8, 8, 40, 40) imgname:@"icon_close.png" SELL:@selector(back:) tag:0];
    [self addSubview:btn];
}

-(IBAction)back:(id)sender{
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha=0;
    } completion:^(BOOL anim){
        [self removeFromSuperview];
    }];
}

-(IBAction)ok:(id)sender{
    __block wShowImageList *wself = self;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha=0;
    } completion:^(BOOL anim){
        [self removeFromSuperview];
        [wself.delegate showbook];
    }];
}

#pragma mark - MyScrollViewDataScource
-(UIView *)ScrollView:(MyScrollView *)scrollView atPage:(int)pageId;
{
    UIView *v=[[UIView alloc]initWithFrame:CGRectMake(scrollView.bounds.size.width*pageId, 0, scrollView.bounds.size.width, scrollView.bounds.size.height)];
    
        UIScrollView *sc=[[UIScrollView alloc]initWithFrame:v.bounds];
        sc.maximumZoomScale=2.0;
        sc.minimumZoomScale=1;
        sc.delegate=self;
    
    if (pageId==_imagelist.count) {
        UIImageView *bg=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, v.frame.size.width, v.frame.size.height)];
        if (v.frame.size.height==568) {
            bg.image=[UIImage imageNamed:@"3_05_05.png"];
            UIButton *ok=[wTools W_Button:self frame:CGRectMake(78, 356, 165, 30) imgname:@"3_05_OK.png" SELL:@selector(ok:) tag:0];
            UIButton *back=[wTools W_Button:self frame:CGRectMake(78, 405, 165, 30) imgname:@"3_05_clease.png" SELL:@selector(back:) tag:0];
            
            [v addSubview:bg];
            [v addSubview:ok];
            [v addSubview:back];
        }else{
            bg.image=[UIImage imageNamed:@"3_05_480.png"];
            UIButton *ok=[wTools W_Button:self frame:CGRectMake(78, 314, 165, 30) imgname:@"3_05_OK.png" SELL:@selector(ok:) tag:0];
            UIButton *back=[wTools W_Button:self frame:CGRectMake(78, 363, 165, 30) imgname:@"3_05_clease.png" SELL:@selector(back:) tag:0];
            
            [v addSubview:bg];
            [v addSubview:ok];
            [v addSubview:back];
        }
        
        return v;
    }
    
    AsyncImageView *imav=[[AsyncImageView alloc]initWithFrame:CGRectMake(0, 0, sc.bounds.size.width, sc.bounds.size.height)];
    imav.contentMode=UIViewContentModeScaleAspectFit;
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget: imav];
    imav.imageURL=[NSURL URLWithString:_imagelist[pageId]];
    [sc addSubview:imav];
    [v addSubview:sc];
    
    return v;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView  {
    return [[scrollView subviews]objectAtIndex:0];
}

-(CGSize)ContentSizeInScrollView:(MyScrollView *)scrollView
{
    
    if (_isShow) {
        return CGSizeMake(scrollView.bounds.size.width * (_imagelist.count+1), scrollView.bounds.size.height);
    }
    
    return CGSizeMake(scrollView.bounds.size.width * (_imagelist.count), scrollView.bounds.size.height);
}

-(int)TotalPageInScrollView:(MyScrollView *)scrollView ;
{
    if (_isShow) {
//        _imagelist.count+1;
    }
    return (int)_imagelist.count;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    //目前頁數
//    int wNowPage = [vc getNowPage:2];

}
@end
