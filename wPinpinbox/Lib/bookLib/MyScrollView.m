//
//  MyScrollView.m
//  LexusHD
//
//  Created by Chen Wei Ting on 2010/10/23.
//  Copyright 2010 TTU. All rights reserved.
//

#import "MyScrollView.h"


@implementation MyScrollView
@synthesize dataSource,dataSourceDelegate,outdelegte;

- (id)initWithFrame:(CGRect)frame 
{
    NSLog(@"initWithFrame");
    
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

-(void)initWithDelegate:(id<UIScrollViewDelegate>)_Xdelegate atPage:(int)page;
{
    NSLog(@"initWithDelegate");
    
	for(UIView *vv in self.subviews)
	{
		[vv removeFromSuperview];
	}
	
	if ( dataSource == nil)
	{
		self.dataSource = [[NSMutableArray alloc] init];
	}
	else
    {
		[dataSource removeAllObjects];
	}
	
	self.userInteractionEnabled = YES;
	self.delegate = self;
	outdelegte = _Xdelegate;
	nowPage = page;
    //NSLog(@"page: %d", page);
    
	self.contentSize = [dataSourceDelegate ContentSizeInScrollView:self];
	
	pageCount = [dataSourceDelegate TotalPageInScrollView:self];
	//NSLog(@"pageCount %d",pageCount);
    
	for(int i=0;i<pageCount;i++)
	{
		[dataSource addObject:[NSNull null]];
	}
	
	[self loadNestPage:nowPage];
	
	//移到正確的地方
	int offset = self.frame.size.width *nowPage;
	[self setContentOffset:CGPointMake(offset, 0)];
	
	//[self addSubview:[dataSourceDelegate ScrollView:self atPage:showPage]];
}

#pragma mark -
#pragma mark 處理頁面載入

-(void)loadPage:(int)pageId;
{
    //NSLog(@"loadPage: pageId: %d", pageId);
    
	if (pageId < 0)
    {
        //NSLog(@"pageId < 0 so return");
        return;
    }
    if (pageId >= pageCount)
    {
        //NSLog(@"pageId >= pageCount so return");
        return;
    }
    
    //NSLog(@"pageId: %d", pageId);
    //NSLog(@"pageCount: %d", pageCount);
    
	UIView *controller = [dataSource objectAtIndex:pageId];
	
    if ((NSNull *)controller == [NSNull null]) 
    {
        //NSLog(@"if ((NSNull *)controller == [NSNull null])");
		controller = [dataSourceDelegate ScrollView:self atPage:pageId];
		[dataSource replaceObjectAtIndex:pageId withObject:controller];
    }
	
	// add the controller's view to the scroll view
    if (nil == controller.superview) 
    {
        //NSLog(@"nil == controller.superview");
        //CGRect frame = CGRectMake(rectSelf.size.width*pageId, 0, controller.frame.size.width, controller.frame.size.height);
        //controller.frame = frame;
		//[controller loadImgWithRating:1.0f];
        [self addSubview:controller];
	}
}

-(void)releasePage:(int)pageId;
{
    //NSLog(@"releasePage");
    
	if (pageId < 0) return;
    if (pageId >= pageCount) return;
    
	//NSLog(@"qqqq release page=%d",pageId);
	
	UIView *controller = [dataSource objectAtIndex:pageId];
	if ((NSNull *)controller == [NSNull null]) 
	{
		return;
	}
	else
	{
		//NSLog(@"Release page=%d",pageId);
		[dataSource replaceObjectAtIndex:pageId withObject:[NSNull null]];
		[controller removeFromSuperview];
	}
}

-(void)resetPage:(int)pageId;
{
    //NSLog(@"resetPage");
    
	if (pageId < 0) return;
    if (pageId >= pageCount) return;
	
	UIView *controller = [dataSource objectAtIndex:pageId];
    
	if ((NSNull *)controller == [NSNull null]) 
	{
		return;
	}
	else
	{
		//[controller resetPic];
	}
}

//載入該頁面附近的話面
-(void)loadNestPage:(int)pageId;
{
    //NSLog(@"loadNestPage");
    //NSLog(@"pageId: %d", pageId);
    
	[self loadPage:pageId - 1];
	[self loadPage:pageId];
	[self loadPage:pageId + 1];	
}

//解除該頁面附近的話面
-(void)unLoadNestPage:(int)pageId;
{
    //NSLog(@"unLoadNestPage");
    //NSLog(@"pageId: %d", pageId);
    
	[self releasePage:pageId - 4];
	[self releasePage:pageId - 3];
	[self releasePage:pageId - 2];
	[self releasePage:pageId + 2];
	[self releasePage:pageId + 3];
	[self releasePage:pageId + 4];
}

//釋放目前開啟的畫面
-(void)relaseAllPage;
{
    NSLog(@"relaseAllPage");
    
	int pageId = [self getNowPage:2];
    NSLog(@"pageId: %d", pageId);
    
	//[self releasePage:pageId - 2];
	[self releasePage:pageId - 1];
    NSLog(@"releasePage pageId - 1: %d", pageId - 1);
    
	[self releasePage:pageId - 0];
    NSLog(@"releasePage pageId - 0: %d", pageId - 0);
    
	[self releasePage:pageId + 1];
    NSLog(@"releasePage pageId + 1: %d", pageId + 1);
	//[self releasePage:pageId + 2];
}

-(void)processPage
{
    NSLog(@"processPage");
    
	//NSLog(@"processPage %d",nowPage);
	[self loadNestPage:nowPage];
	[self unLoadNestPage:nowPage];
}

-(int)getNowPage:(int)off;
{
//    NSLog(@"");
//    NSLog(@"Begin getNowPage");
//    NSLog(@"----------");
//    NSLog(@"getNowPage");
//    NSLog(@"");
 
	CGFloat pageWidth = self.frame.size.width;
//    NSLog(@"pageWidth: %f", pageWidth);
//    NSLog(@"self.contentOffset.x: %f", self.contentOffset.x);
    
    int page = floor((self.contentOffset.x - pageWidth / off) / pageWidth) + 1;	
//    NSLog(@"s1=%f s2=%f s3=%f  now Page=%d",self.contentOffset.x,(self.contentOffset.x - pageWidth / off),(self.contentOffset.x - pageWidth / off) / pageWidth,page);
//
//    NSLog(@"page: %d", page);
//
//    NSLog(@"End getNowPage");
//    NSLog(@"----------");
//    NSLog(@"");
    
	return page;
}

#pragma mark - scrollView Delegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ( [outdelegte respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)] )
    {
        [outdelegte scrollViewDidEndDragging:self willDecelerate:decelerate];
    }
	//NSLog(@"scrollViewDidEndDraging");
	int pp = [self getNowPage:2];
	//NSLog(@"scrollViewDidEndDragging at Page=%d",nowPage);	
    
	if ( pp != nowPage )
	{
		[self resetPage:nowPage];
		nowPage = pp;
		[self processPage];
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewDidEndDecelerating");
    if ( [outdelegte respondsToSelector:@selector(scrollViewDidEndDecelerating:)] )
    {
        [outdelegte scrollViewDidEndDecelerating:self];
    }
	
	int pp = [self getNowPage:2];
	//NSLog(@"scrollViewDidEndDecelerating at Page=%d",nowPage);
	
	if ( pp != nowPage )
	{
		[self resetPage:nowPage];
		nowPage = pp;
		[self processPage];
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)sender 
{
    if ( [outdelegte respondsToSelector:@selector(scrollViewDidScroll:)] )
    {
        [outdelegte scrollViewDidScroll:self];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView 
{
    if ( [outdelegte respondsToSelector:@selector(scrollViewWillBeginDragging:)] )
    {
        [outdelegte scrollViewWillBeginDragging:self];
    }
}

-(void)moveToPage:(int)pp
{
    //NSLog(@"moveToPage");
    
	[self relaseAllPage];
	nowPage = pp;
    
    [self loadNestPage:nowPage];
	
	//移到正確的地方
	int offset = self.frame.size.width *nowPage;
    [self setContentOffset:CGPointMake(offset, 0)];
//    [self setContentOffset: CGPointMake(offset, 0) animated: YES];
    
    [dataSourceDelegate scrollViewDidEndDecelerating:nil];
}

-(UIView *)ReturnNowPageView{
    
    //NSLog(@"ReturnNowPageView");
    
    int pp = [self getNowPage:2];
    //NSLog(@"pp: %d", pp);
    
    UIView *controller = [dataSource objectAtIndex:pp];
    return controller;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
