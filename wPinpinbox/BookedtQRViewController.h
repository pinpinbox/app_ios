//
//  BookedtQRViewController.h
//  wPinpinbox
//
//  Created by Angus on 2016/2/18.
//  Copyright (c) 2016年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol BookdetDelegate <NSObject>
-(void)SaveDataString:(NSString *)str;
@end
@interface BookedtQRViewController : UIViewController
@property(weak,nonatomic)id<BookdetDelegate>delegate;
@end
