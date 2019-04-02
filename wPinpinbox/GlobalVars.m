//
//  GlobalVars.m
//  wPinpinbox
//
//  Created by David on 2017/10/13.
//  Copyright © 2017年 Angus. All rights reserved.
//

#import "GlobalVars.h"

NSString *timeOutErrorCode = @"-1001";
NSString *timeOutErrorCode1 = @"-1005";
NSString *cancelErrorCode = @"-999";

NSString *kTimeOut = @"8";
NSString *kTimeOutForVideo = @"1200";
NSString *kTimeOutForPhoto = @"1200";
NSInteger kMinWidthAndHeight = 72;
NSTimeInterval kAnimateActionSheet = 0.2;
NSTimeInterval kHUDGraceTime = 1.0;
CGFloat kMessageBarDuration = 2.0;
CGFloat kCornerRadius = 6.0;

NSString *appStoreUrl = @"https://itunes.apple.com/tw/app/pinpinbox/id1057840696?mt=8";

#if(DEBUG)
NSString *ServerURL = @"https://w3.pinpinbox.com/index/api";
//NSString *ServerURL = @"http://platformvmage5.cloudapp.net/pinpinbox/index/api";
NSString *pinpinbox = @"https://w3.pinpinbox.com/";
NSString *sharingLinkWithAutoPlay = @"http://w3.pinpinbox.com/index/album/content/?album_id=%@%@";
NSString *sharingLinkWithoutAutoPlay = @"http://w3.pinpinbox.com/index/album/content/?album_id=%@";
NSString *userIdSharingLink = @"http://w3.pinpinbox.com/index/creative/content/?user_id=%@%@";
NSString *aboutPageLink = @"https://w3.pinpinbox.com/index/about";
#else
NSString *ServerURL = @"https://www.pinpinbox.com/index/api";
NSString *pinpinbox = @"https://www.pinpinbox.com/";
NSString *sharingLinkWithAutoPlay = @"http://www.pinpinbox.com/index/album/content/?album_id=%@%@";
NSString *sharingLinkWithoutAutoPlay = @"http://www.pinpinbox.com/index/album/content/?album_id=%@";
NSString *userIdSharingLink = @"http://www.pinpinbox.com/index/creative/content/?user_id=%@%@";
NSString *aboutPageLink = @"https://www.pinpinbox.com/index/about";
#endif

NSString *wwwFlurryAPIKey = @"GBGHQY4398WCV4X6HSZN";
NSString *w3FlurryAPIKey = @"GSPHT8B4KV8F89VHQ6D8";

CGFloat navBarHeightConstant = 66;
CGFloat kBtnInset = 6;

CGFloat kHomeTabIndex = 0;
CGFloat kMeTabIndex = 1;
CGFloat kNotifTabIndex = 3;

CGFloat kToolBarButtonHeight = 45;
CGFloat kToolBarViewHeight = 49;
CGFloat kToolBarViewHeightForX = 87;

CGFloat kActivityIndicatorViewSize = 56;

CGFloat kIconForInfoViewWidth = 20;

@implementation GlobalVars
 
@end
