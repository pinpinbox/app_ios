//
//  AlbumInfoViewController.h
//  wPinpinbox
//
//  Created by David on 6/13/17.
//  Copyright © 2017 Angus. All rights reserved.
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
