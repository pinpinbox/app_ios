//
//  FastViewController.h
//  wPinpinbox
//
//  Created by Angus on 2015/10/29.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Remind.h"
#import <AdobeCreativeSDKImage/AdobeCreativeSDKImage.h>

@interface FastViewController : UIViewController

@property (nonatomic) NSArray *imagedata;
@property (assign) NSInteger selectrow;
@property (nonatomic) NSString *albumid;
@property (assign) NSInteger booktype;
@property (nonatomic) NSString *templateid;
@property (nonatomic) NSString *event_id;
@property (nonatomic) BOOL postMode;
@property (nonatomic) BOOL fromEventPostVC;

@property (nonatomic) NSString *choice;

@property (nonatomic) BOOL shareCollection;

-(void)reloaddatat: (NSMutableArray *)data;
-(void)reloadItem: (NSInteger)item;

@end
