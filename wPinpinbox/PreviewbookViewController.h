//
//  PreviewbookViewController.h
//  wPinpinbox
//
//  Created by Angus on 2015/10/28.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYMProgressBarView.h"
#import "AsyncImageView.h"

@interface PreviewbookViewController : UIViewController {
    
    __weak IBOutlet UIView *downview1;
    __weak IBOutlet UIView *downview2;
    
    __weak IBOutlet UIButton *stopbtn;
    __weak IBOutlet UIImageView *animatimageview;
}

@property (weak, nonatomic) IBOutlet UIImageView *loadimg;
@property (weak, nonatomic) IBOutlet TYMProgressBarView *loadview;
@property (nonatomic, strong) NSString *albumid;
@property (nonatomic, strong) NSString *userbook;
@property (nonatomic, strong) NSString *albumType;
@property (nonatomic) NSString *eventId;
@property (nonatomic) BOOL postMode;
@property (nonatomic) BOOL fromEventPostVC; 

@end
