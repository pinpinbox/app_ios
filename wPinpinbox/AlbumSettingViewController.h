//
//  AlbumSettingViewController.h
//  wPinpinbox
//
//  Created by David on 6/21/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AlbumSettingViewController;
@protocol  AlbumSettingViewControllerDelegate <NSObject>
- (void)albumSettingViewControllerUpdate:(AlbumSettingViewController *)controller;
@end

@interface AlbumSettingViewController : UIViewController
@property (weak) id <AlbumSettingViewControllerDelegate> delegate;

@property (nonatomic) NSString *userIdentity;
@property (strong, nonatomic) NSString *albumId;
@property (nonatomic) BOOL postMode;
@property (nonatomic) NSString *eventId;
@property (nonatomic) NSString *fromVC;

@property (nonatomic) NSString *templateId;
@property (nonatomic) BOOL shareCollection;
@property (nonatomic) BOOL hasImage;

@property (nonatomic) BOOL isNew;

@property (nonatomic) NSString *prefixText;
@property (nonatomic) NSString *specialUrl;

@end
