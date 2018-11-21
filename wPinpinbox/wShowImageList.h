//
//  wShowImageList.h
//  wPinpinbox
//
//  Created by Angus on 2015/12/17.
//  Copyright © 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyScrollView.h"
@protocol  wShowImageListDelegate <NSObject>
-(void)showbook;
@end
@interface wShowImageList : UIView<MyScrollViewDataSource1,UIScrollViewDelegate>
{
    MyScrollView *vc;
}
@property(nonatomic,strong)NSArray *imagelist;
-(void)showView:(int)page;
@property(weak)id<wShowImageListDelegate>delegate;
@property BOOL isShow;//是否顯示最末頁
@end
