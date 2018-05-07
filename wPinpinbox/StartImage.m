//
//  StartImahe.m
//  wPinpinbox
//
//  Created by Angus on 2015/10/2.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "StartImage.h"

@implementation StartImage


-(void)show{
    self.backgroundColor=[UIColor clearColor];
    
    scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    //scrollView.backgroundColor=[UIColor clearColor];
    scrollView.pagingEnabled=YES;
    scrollView.showsHorizontalScrollIndicator=NO;
    scrollView.showsVerticalScrollIndicator=NO;
    scrollView.scrollsToTop=NO;
    scrollView.delegate=self;
    scrollView.bounces=NO;
    
  
    CGFloat width, height;
    
    width=scrollView.bounds.size.width;
    height=scrollView.bounds.size.height;
    
    
    scrollView.contentSize=CGSizeMake(width*5, height);
    for (int i=1; i<5; i++) {
        CGRect frame = CGRectMake(width*(i-1), 0, width, height);
        
        UIImageView *imv=[[UIImageView alloc]initWithFrame:frame];
        imv.image=[UIImage imageNamed:[NSString stringWithFormat:@"P0%i.png",i]];
        [scrollView addSubview:imv];
    
    }
    
      [self addSubview:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)mscrollView{
    CGFloat width = scrollView.frame.size.width;
    NSInteger currentPage = ((scrollView.contentOffset.x - width / 2) / width) + 1;
    if(currentPage==4){
        [self removeFromSuperview];
    }
}
@end
