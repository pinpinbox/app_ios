//
//  GlobalVars.h
//  wPinpinbox
//
//  Created by David on 2017/10/13.
//  Copyright © 2017年 Angus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define fileDest [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/data/Download"]
#define filepinpinboxDest [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/data/pinpinbox"]
#define DownloadCompletedNotif @"DownloadCompletedNotif"

#define AppGroup @"group.pinpinbox"

extern NSString *timeOutErrorCode;
extern NSString *timeOutErrorCode1;

extern NSString *cancelErrorCode;
extern NSString *kTimeOut;
extern NSString *kTimeOutForVideo;
extern NSString *kTimeOutForPhoto;
extern NSInteger kMinWidthAndHeight;
extern NSTimeInterval kAnimateActionSheet;
extern NSTimeInterval kHUDGraceTime;
extern CGFloat kMessageBarDuration;
extern CGFloat kCornerRadius;

extern NSString *appStoreUrl;

extern NSString *ServerURL;
extern NSString *pinpinbox;

extern NSString *sharingLinkWithAutoPlay;
extern NSString *sharingLinkWithoutAutoPlay;

extern NSString *userIdSharingLink;

extern NSString *aboutPageLink;

extern NSString *wwwFlurryAPIKey;
extern NSString *w3FlurryAPIKey;

extern CGFloat navBarHeightConstant;
extern CGFloat kBtnInset;

extern CGFloat kHomeTabIndex;
extern CGFloat kMeTabIndex;
extern CGFloat kNotifTabIndex;

extern CGFloat kToolBarButtonHeight;
extern CGFloat kToolBarViewHeight;
extern CGFloat kToolBarViewHeightForX;

@interface GlobalVars : NSObject

@end
