//
//  EditNewAlbumViewController.h
//  PinpinboxShareExtension
//
//  Created by Antelis on 2018/12/28.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol  AlbumSettingsDelegate<NSObject>
@optional
- (void)reloadAlbumList;
@end
@interface EditNewAlbumViewController : UIViewController
@property (nonatomic) id<AlbumSettingsDelegate> settingDelegate;
@end

NS_ASSUME_NONNULL_END
