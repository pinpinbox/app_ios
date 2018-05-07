//
//  MyScrollView.h
//  LexusHD
//
//  Created by Chen Wei Ting on 2010/10/23.
//  Copyright 2010 TTU. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyScrollView;
@protocol MyScrollViewDataSource1

-(UIView *)ScrollView:(MyScrollView *)scrollView atPage:(int)pageId;
-(CGSize)ContentSizeInScrollView:(MyScrollView *)scrollView;
-(int)TotalPageInScrollView:(MyScrollView *)scrollView;
-(void)scrollViewDidEndDecelerating:(MyScrollView *)scrollView;
- (void)scrollViewDidEndDragging: (MyScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)scrollViewWillBeginDragging: (MyScrollView *)scrollView;

@end

@interface MyScrollView : UIScrollView <UIScrollViewDelegate> 
{
	int pageCount;
	int nowPage;
	
	NSMutableArray *dataSource;
}

@property(nonatomic, assign) id <MyScrollViewDataSource1> dataSourceDelegate;
@property(nonatomic, assign) id <UIScrollViewDelegate> outdelegte;
@property(nonatomic, retain) NSMutableArray *dataSource;

-(void)initWithDelegate:(id<UIScrollViewDelegate>)_Xdelegate atPage:(int)page;

#pragma mark 處入畫面處理
-(void)moveToPage:(int)pp;
-(void)loadPage:(int)pageId;
//-(UIImage *)loadImageOnPageId:(int)pageId;
-(int)getNowPage:(int)off;//計算目前是在第幾頁
-(void)releasePage:(int)pageId;
-(void)resetPage:(int)pageId;
-(void)loadNestPage:(int)pageId;
-(void)unLoadNestPage:(int)pageId;
-(void)relaseAllPage;
-(void)processPage;
-(UIView *)ReturnNowPageView;

@end
