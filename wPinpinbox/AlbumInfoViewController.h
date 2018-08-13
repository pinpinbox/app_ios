//
//  AlbumInfoViewController.h
//  wPinpinbox
//
//  Created by David on 2018/8/7.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AlbumInfoViewController;
@protocol AlbumInfoViewControllerDelegate <NSObject>
- (void)albumInfoViewControllerDisappear: (AlbumInfoViewController *)controller;
@end

@interface AlbumInfoViewController : UIViewController
@property (strong, nonatomic) NSDictionary *data;
@property (nonatomic, strong) NSDictionary *localData;
@property (weak) id <AlbumInfoViewControllerDelegate> delegate;
@end
