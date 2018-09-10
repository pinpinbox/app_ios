//
//  TemplateViewController.h
//  wPinpinbox
//
//  Created by Angus on 2016/2/1.
//  Copyright (c) 2016年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Remind.h"

@class TemplateViewController;
@protocol TemplateViewControllerDelegate <NSObject>
- (void)uploadPhotoDidComplete:(TemplateViewController *)controller;
@end

@interface TemplateViewController : UIViewController
{
    __weak IBOutlet UILabel *wtitle;
}

@property (nonatomic) NSString *albumid;
@property (nonatomic) NSString *identity;
@property (nonatomic) NSString *templateid;
@property (nonatomic, strong) NSArray *templatelist;
@property (nonatomic) NSString *event_id;
@property (nonatomic) BOOL postMode;

@property (nonatomic) NSString *choice;

@property (weak) id <TemplateViewControllerDelegate> delegate;

@end
