//
//  AlbumCreationViewController.h
//  wPinpinbox
//
//  Created by David on 4/23/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
//

@class AlbumCreationViewController;
@protocol AlbumCreationViewControllerDelegate <NSObject>
- (void)albumCreationViewControllerBackBtnPressed: (AlbumCreationViewController *)controller;
@end

@interface AlbumCreationViewController : UIViewController

@property (weak) id <AlbumCreationViewControllerDelegate> delegate;

@property (nonatomic) NSString *userIdentity;

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
@property (nonatomic) NSString *fromVC;

@property (nonatomic) BOOL isNew;

@property (nonatomic) NSString *prefixText;
@property (nonatomic) NSString *specialUrl;

-(void)reloaddatat: (NSMutableArray *)data;
-(void)reloadItem: (NSInteger)item;

@end
