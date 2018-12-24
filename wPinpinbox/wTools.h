//
//  wTools.h
//  wPinpinbox
//
//  Created by Angus on 2015/8/10.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface wTools : NSObject

+(wTools * _Nonnull)getInstance;
//圖片按鈕
+(UIButton *)W_Button:(id)sender frame:(CGRect)frame imgname:(NSString *)imgname SELL:(SEL)sel tag:(int)tag;
+(void)showAlertTile:(NSString *)title Message:(NSString *)message ButtonTitle:(NSString *)buttonTitle;
//相片圓邊
+(void)ImageViewRadius:(UIImageView *)imgv borderWidth:(float)borderWidth;
+(void)ShowMBProgressHUD;
+(void)HideMBProgressHUD;
+(void)myMenu;
+(UINavigationController *)myNavigationController;

//userInfo
+(NSString *)getUserID;
+(NSString *)getUserToken;
+(NSString *)getUUID;
+(NSString *)stringisnull:(NSString *)str;

+ (BOOL)objectExists:(id)object;

//書本詳細頁導入 先下載再進入
+(void)ToRetrievealbumpViewControlleralbumid:(NSString *)albumid;

//作者介紹 依據相本ID
+(void)showCreativeViewController:(NSString *)albumid;
//作者介紹 依據作者ID 是否關注
+(void)showCreativeViewuserid:(NSString *)userid  isfollow:(BOOL)follow;
//相本可編輯數量
+(int)userbook;


//留言板
+(void)messageboard:(NSString *)alid;
//分享
+(void)Activitymessage:(NSString *)message;

// Check Album Sample
+ (void)readSampleBook:(NSString *)albumId dictionary: (NSDictionary *)data isFree: (BOOL)isFree;

//預覽本地書本
+(void)ReadBookalbumid:(NSString *)albumid userbook:(NSString *)userbook eventId: (NSString *)eventId postMode: (BOOL)postMode fromEventPostVC:(BOOL)fromEventPostVC;

+(void)ReadTestBookalbumid:(NSString *)albumId userbook:(NSString *)userbook eventId: (NSString *)eventId postMode: (BOOL)postMode fromEventPostVC:(BOOL)fromEventPostVC;

+(void)editphotoinfo:(NSString *)albumid templateid:(NSString *)templateid eventId: (NSString *)eventId postMode: (BOOL)postMode;
//快建相本
+(void)FastBook:(NSString *)alid;
+(void)FastBook:(NSString *)alid choice: (NSString *)choice;
//色碼
+ (UIColor *)colorFromHexString:(NSString *)hexString;
//語系
+(NSString *)localstring;
//圖片縮小
+(UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize;
//密碼大小寫
+(BOOL)pwd:(NSString *)resultString;

//登出
+ (void)logOut;

// Delete All Core Data
+ (void)deleteAllCoreData;

// Change StatusBar Background Color
+ (void)setStatusBarBackgroundColor:(UIColor *)color;

// Remaining Time Calculation
//+ (NSString *)remainingTimeCalculation:(NSMutableDictionary *)dic;
+ (NSString *)remainingTimeCalculation:(NSString *)timeStr;
+ (NSInteger)remainingTimeCalculationOnlyMinute:(NSString *)timeStr;

// Get Snapshot Image
+ (UIImage *)normalSnapshotImage:(UIView *)view;

// GAI Screen
+ (void)sendScreenTrackingWithScreenName:(NSString *)scrnName;
// GAI Event/Action
+ (void)sendActionTrackingWithCategoryName:(NSString *)scrnName action:(NSString *)action label:(NSString *)label value:( NSNumber * _Nullable )value;

//  處理AWSSNS
+(void)processAWSResponse:(NSString *)res;
+(BOOL)isRegisterAWSNeeded;
@end
