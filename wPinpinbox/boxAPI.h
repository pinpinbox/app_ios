//
//  boxAPI.h
//  wPinpinbox
//
//  Created by Angus on 2015/10/12.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#define sysOK @"SYSTEM_OK"

static NSString *version = @"";
//static NSString *ServerURL = @"https://www.pinpinbox.com/index/api";

@interface boxAPI : NSObject

+(void)testAPIcode;
//條款
+(NSString *)getsettings:(NSString *)keyword;
//登入
+(NSString*)LoginAccount:(NSString *)account
                     Pwd:(NSString *)Pwd;
//ＦＢ登入
+(NSString *)FacebookLoginAccount:(NSString *)fbid;
//驗證token
+ (NSString *)checktoken:(NSString *)token
                    usid:(NSString *)usid;
//取得簡訊碼(註冊)
+(NSString *)requsetsmspwd:(NSString *)cellphone
                   Account:(NSString *)account;

//取得簡訊碼(修改)
+(NSString *)requsetsmspwd2:(NSString *)cellphone
                    Account:(NSString *)account;

+(NSString *)updatecellphone:(NSString *)oldphone
                         new:(NSString *)newphone
                        pass:(NSString *)smspass;

//註冊
+(NSString *)registration:(NSDictionary *)data;

+(NSString *)registration:(NSString *)account
                 password:(NSString *)password
                     name:(NSString *)name
                cellphone:(NSString *)cellphone
              smspassword:(NSString *)smspassword
                      way:(NSString *)way
                   way_id:(NSString *)way_id
               newsletter:(NSString *)newsletter;


//Check 帳號&電話號碼
+ (NSString *)check:(NSString *)checkColumn
         checkValue:(NSString *)value;

//忘記密碼
+(NSString *)retrievepassword:(NSString *)cellphone
                      Account:(NSString *)account;
//更新個人興趣
+ (NSString *)updateprofilehobby:(NSString *)token
                            usid:(NSString *)usid
                           hobby:(NSString *)hobby;
//取得相本資料
+(NSString *)retrievealbump:(NSString *)albumid
                        uid:(NSString *)uid
                      token:(NSString *)token;

+ (NSString *)retrievealbump:(NSString *)albumid
                         uid:(NSString *)uid
                       token:(NSString *)token
                      viewed:(NSString *)viewed;

//取得相本資料-序號
+(NSString *)retrievealbumpbypn:(NSString *)productn
                            uid:(NSString *)uid
                          token:(NSString *)token;
//取得相本類別
+(NSString *)retrievecatgeorylist:(NSString *)uid
                            token:(NSString *)token;

//取得各類下載清單
+(NSString *)retrievehotrank:(NSString *)uid
                       token:(NSString *)token
                      rankid:(NSString *)rankid
                  categoryid:(NSString *)categoryid;

+(NSString *)retrieveHotRank:(NSString *)uid
                       token:(NSString *)token
              categoryAreaId:(int)categoryAreaId
                        data:(NSDictionary *)data;

//取得作者資料 by 相本id
+(NSString *)retrieveauthor:(NSString *)uid
                      token:(NSString *)token
                    albumid:(NSString *)albumid;

//更改目前用戶對該作者的關注狀態
+(NSString *)changefollowstatus:(NSString *)uid
                          token:(NSString *)token
                       authorid:(NSString *)authorid;
//購買相本
+(NSString *)buyalbum:(NSString *)uid token:(NSString *)token albumid:(NSString *)albumid;

+ (NSString *)newBuyAlbum:(NSString *)userId
                    token:(NSString *)token
                  albumId:(NSString *)albumId
                 platform:(NSString *)platform
                    point:(NSString *)point;

+ (NSString *)newBuyAlbum:(NSString *)userId
                    token:(NSString *)token
                  albumId:(NSString *)albumId
                 platform:(NSString *)platform
                    point:(NSString *)point
                   reward:(NSString *)reward;
//下載相本(有問題)
+(NSString *)downloadalbumzip:(NSString *)uid token:(NSString *)token albumid:(NSString *)albumid;
//通知下載完成
+(BOOL)finishalbum:(NSString *)uid token:(NSString *)token downloadid:(NSString *)download_id;
//刪除的相本
+(NSString *)delalbum:(NSString *)uid token:(NSString *)token albumid:(NSString *)albumid;
//隱藏收藏相本
+(NSString *)hidealbumqueue:(NSString *)uid token:(NSString *)token albumid:(NSString *)albumid;

//取得相本清單
//mine/other/cooperation
+(NSString *)getcalbumlist:(NSString *)uid token:(NSString *)token rank:(NSString *)rank limit:(NSString *)limit;
+(NSString *)getcalbumlist:(NSString *)uid token:(NSString *)token rank:(NSString *)rank;
//取得待下載清單
+(NSString *)getdownloadlist:(NSString *)uid token:(NSString *)token;
//刪除代下載清單(付費相本無法刪除)
+(BOOL)deldownloadlist:(NSString *)uid token:(NSString *)token downloadid:(NSString *)download_id;
//更新會員密碼
//+(BOOL)updatepwd:(NSString *)uid token:(NSString *)token oldpwd:(NSString *)oldpwd newpwd:(NSString *)newpwd;
+ (NSString *)updatepwd:(NSString *)uid token:(NSString *)token oldpwd:(NSString *)oldpwd newpwd:(NSString *)newpwd;
//取得會員Ｐ點
+(NSString *)geturpoints:(NSString *)uid token:(NSString *)token;
//取得Ｐ幣商店資料
+(NSString *)getpointstore:(NSString *)uid token:(NSString *)token;
//取得由非官方所制定屬於訂單的唯一識別碼
+(NSString *)getpayload:(NSString *)uid token:(NSString *)token productid:(NSString *)productid;
//內購完成
+(NSString *)finishpurchased:(NSString *)uid token:(NSString *)token orderid:(NSString *)orderid dataSignature:(NSString *)dataSignature;


//取得會員資料
+(NSString *)getprofile:(NSString *)uid token:(NSString *)token;
//更新會員資料
+(NSString *)updateprofile:(NSString *)uid token:(NSString *)token data:(NSDictionary *)data;
+ (NSString *)updateUser:(NSString *)uid token:(NSString *)token param:(NSString *)param;
//取得通知清單
+(NSString *)updatelist:(NSString *)uid token:(NSString *)token data:(NSDictionary *)data rank: (NSString *)rank;
//取得推薦清單
+(NSString *)getrecommended:(NSString *)uid token:(NSString *)token data:(NSDictionary *)data;
//取得作者專區資料
+(NSString *)getcreative:(NSString *)uid token:(NSString *)token data:(NSDictionary*)data;

//取得版型樣式列表
+(NSString *)gettemplatestylelist:(NSString *)uid token:(NSString *)token;
//取得版型清單
+(NSString *)gettemplatelist:(NSString *)uid token:(NSString *)token data:(NSDictionary *)data event: (NSString *)event_id style:(NSString *)style_id;

//取得版型資訊
+(NSString *)gettemplate:(NSString *)uid token:(NSString *)token templateid:(NSString *)templateid;
//購買版型
+(NSString *)buytemplate:(NSString *)uid token:(NSString *)token templateid:(NSString *)templateid;
//設定推播
+(NSString *)setawssns:(NSString *)uid token:(NSString *)token devicetoken:(NSString *)devicetoken identifier:(NSString *)identifier;

#pragma mark -
#pragma mark 搜尋
/*
 searchtype
 搜尋類型
 album (相本) / albumindex (相本索引) / user (用戶)
 
 searchkey
 搜尋鍵
 
 limit
 "列表每次添加的數量,前者數字開始(不列入)；後者為添加數量"
 0,10
 
 */
//搜尋
+(NSString *)search:(NSString *)uid token:(NSString *)token data:(NSDictionary *)data;

// RecommendedList for Search
+ (NSString *)getRecommendedList: (NSString *)uid token:(NSString *)token data:(NSDictionary *)data;


#pragma mark -
#pragma mark 共用
//取得共用狀態
+(NSString *)getcooperation:(NSString *)uid token:(NSString *)token data:(NSDictionary *)data;
//取得共用清單     type:album   type_id  user_id
+(NSString *)getcooperationlist:(NSString *)uid token:(NSString *)token data:(NSDictionary *)data;
//刪除共用   type:album   type_id  user_id
+(NSString *)deletecooperation:(NSString *)uid token:(NSString *)token data:(NSDictionary *)data;
//新增共用   type:album   type_id  user_id
+(NSString *)addcooperation:(NSString *)uid token:(NSString *)token data:(NSDictionary *)data;
//更新共用
+(NSString *)updatecooperation:(NSString *)uid token:(NSString *)token data:(NSDictionary *)data;

#pragma mark -
#pragma mark 建立相本相關

//檢查是否有處理中 (process) 的相本
+(NSString *)checkalbumofdiy:(NSString *)uid token:(NSString *)tokenㄤ;
//新增 diy 的相本
+(NSString *)insertalbumofdiy:(NSString *)uid token:(NSString *)token template_id:(NSString *)template_id;
//取得 diy 的相本
+(NSString *)getalbumofdiy:(NSString *)uid token:(NSString *)token album_id:(NSString *)album_id;
//新增圖片
+(NSString *)insertphotoofdiy:(NSString *)uid token:(NSString *)token album_id:(NSString *)album_id image:(UIImage *)image compression: (CGFloat)compressionQuality;

// InsertPhoto with AFNetworking
+ (NSString *)insertPhotoOfDiy:(NSString *)uid token:(NSString *)token album_id:(NSString *)album_id image:(UIImage *)image compression: (CGFloat)compressionQuality;

//刪除diy相本
+(NSString *)deletephotoofdiy:(NSString *)uid token:(NSString *)token album_id:(NSString *)album_id photo_id:(NSString *)photo_id;
//更新diy相本
+(NSString *)updatealbumofdiy:(NSString *)uid token:(NSString *)token album_id:(NSString *)album_id;

//更新相片SETTINGS  -> settings key : @"settings[description]", @"settings[hyperlink]", @"settings[location]"
+ (void) updatephotoofdiy:(NSString *)uid token:(NSString *)token album_id:(NSString *)album_id photo_id:(NSString *)photo_id  key:(NSString *)key settingStr:(NSString *)settingStr completed:(void(^)(NSDictionary *result, NSError *error))completionBlock;

//更新相片
+(NSString *)updatephotoofdiy:(NSString *)uid token:(NSString *)token album_id:(NSString *)album_id photo_id:(NSString *)photo_id image:(UIImage *)image setting:(NSString *)setting;
//取得相本資訊表單資料
+(NSString *)getalbumdataoptions:(NSString *)uid token:(NSString *)token;
//更新相本資訊
+(NSString *)albumsettings:(NSString *)uid token:(NSString *)token album_id:(NSString *)album_id settings:(NSString *)settings;
//取的相本資訊ingo
+(NSString *)getalbumsettings:(NSString *)uid token:(NSString *)token album_id:(NSString *)album_id;
//檢查相本是否更新
+(NSString *)checkalbumzip:(NSString *)uid token:(NSString *)token album_id:(NSString *)album_id;

//取得取得檢舉意向清單
+(NSString *)getreportintentlist:(NSString *)uid token:(NSString *)token;
//新增檢舉
+(NSString *)insertreport:(NSString *)uid token:(NSString *)token rid:(NSString *)rid type:(NSString *)type typeid:(NSString *)tid;

#pragma mark - 抽獎相關
//+(NSString *)setawssns:(NSString *)uid token:(NSString *)token devicetoken:(NSString *)devicetoken identifier:(NSString *)identifier;

// 42 拉霸 Slot
+ (NSString *)getPhotoUseForUser: (NSString *)uid
                           token: (NSString *)token
                        photo_id: (NSString *)photo_id
                      identifier: (NSString *)identifier;
// 43 兌換
+ (NSString *)updatePhotoUseForUser: (NSString *)uid
                              token: (NSString *)token
                  photoUseForUserId: (NSString *)photoUseForUserId;

// 43 New
#pragma mark - Update Photo Use For User
+ (NSString *)updatePhotoUseForUser:(NSString *)param
                  photoUseForUserId:(NSString *)photoUseForUserId
                              token:(NSString *)token
                             userId:(NSString *)userId;

#pragma mark - Sort Photo
// 62
+ (NSString *)sortPhotoOfDiy:(NSString *)uid token:(NSString *)token album_id:(NSString *)album_id sort:(NSString *)photo_id;

#pragma mark - 投稿活動相關
// 73
+ (NSString *)switchstatusofcontribution: (NSString *)uid token: (NSString *)token event_id: (NSString *)event_id album_id: (NSString *)album_id;
// 75
+ (NSString *)getAdList: (NSString *)uid token: (NSString *)token adarea_id: (NSString *)adarea_id;
// 76
+ (NSString *)getEvent: (NSString *)uid token: (NSString *)token event_id: (NSString *)event_id;

#pragma mark - Audio Related
// 78
+ (NSString *)updateAudioOfDiy: (NSString *)uid token: (NSString *)token album_id: (NSString *)album_id photo_id: (NSString *)photo_id file: (NSData *)audioData;
// 79
+ (NSString *)deleteAudioOfDiy: (NSString *)uid token: (NSString *)token album_id: (NSString *)album_id photo_id: (NSString *)photo_id;

#pragma mark - Video Related
// 80
+ (NSString *)insertVideoOfDiy: (NSString *)uid token: (NSString *)token album_id: (NSString *)album_id file:(NSData *)videoData;
// 82
+ (NSString *)deleteVideoOfDiy:(NSString *)uid token:(NSString *)token album_id:(NSString *)album_id photo_id:(NSString *)photo_id;

#pragma mark - 活動任務相關
// 83
+ (NSString *)doTask1: (NSString *)uid token: (NSString *)token task_for: (NSString *)task_for platform: (NSString *)platform;
+ (NSString *)doTask2: (NSString *)uid token: (NSString *)token task_for: (NSString *)task_for platform: (NSString *)platform type: (NSString *)type type_id: (NSString *)type_id;

// 84 針對FB分享次數
+ (NSString *)checkTaskCompleted:(NSString *)uid
                           token:(NSString *)token
                        task_for:(NSString *)task_for
                        platform:(NSString *)platform;

+ (NSString *)checkTaskCompleted:(NSString *)uid
                           token:(NSString *)token
                        task_for:(NSString *)task_for
                        platform:(NSString *)platform
                            type:(NSString *)type
                          typeId:(NSString *)typeId;


#pragma mark - Notification Center
+ (NSString *)getPushQueue:(NSString *)uid
                     token:(NSString *)token
                     limit:(NSString *)limit;

// 85 關注
+ (NSString *)getFollowToList:(NSString *)uid
                        token:(NSString *)token
                        limit:(NSString *)limit;


#pragma mark - Check Update Version
// 88 確認版本
+ (NSString *)checkUpdateVersion:(NSString *)platform
                         version:(NSString *)version;

// 89
+ (NSString *)getQRCode:(NSString *)uid
                  token:(NSString *)token
                   type:(NSString *)type
                type_id:(NSString *)type_id
                 effect:(NSString *)effect
                     is:(NSString *)is;

#pragma mark - Get Hobby
+ (NSString *)getHobbyList:(NSString *)uid
                     token:(NSString *)token;

#pragma mark - Message Board
// 90
+ (NSString *)getMessageBoardList:(NSString *)uid
                            token:(NSString *)token
                             type:(NSString *)type
                           typeId:(NSString *)typeId
                            limit:(NSString *)limit;
// 91
+ (NSString *)insertMessageBoard:(NSString *)uid
                           token:(NSString *)token
                            type:(NSString *)type
                          typeId:(NSString *)typeId
                            text:(NSString *)text
                           limit:(NSString *)limit;

#pragma mark - Like
// 92
+ (NSString *)insertAlbum2Likes:(NSString *)uid
                          token:(NSString *)token
                        albumId:(NSString *)albumId;
// 93
+ (NSString *)deleteAlbum2Likes:(NSString *)uid
                          token:(NSString *)token
                        albumId:(NSString *)albumId;

#pragma mark - RefreshToken
// 95
+ (NSString *)refreshToken:(NSString *)userId;

#pragma mark - albumindex
// 96
+ (NSString *)insertalbumindex:(NSString *)uid
                         token:(NSString *)token
                      album_id:(NSString *)album_id
                         index:(NSString *)index;

+ (NSString *)deletealbumindex:(NSString *)uid
                         token:(NSString *)token
                      album_id:(NSString *)album_id
                         index:(NSString *)index;

#pragma mark - BuisnessSubUserFastRegister
// 98
+ (NSString *)buisnessSubUserFastRegister:(NSString *)businessUserId
                                     fbId:(NSString *)fbId
                                timeStamp:(NSString *)timeStamp
                                    param:(NSString *)param;

#pragma mark - Vote
// 99
+ (NSString *)getEventVoteList:(NSString *)eventId
                         limit:(NSString *)limit
                         token:(NSString *)token
                        userId:(NSString *)userId;
// 100
+ (NSString *)vote:(NSString *)albumId
           eventId:(NSString *)eventId
             token:(NSString *)token
            userId:(NSString *)userId;

// 101
+ (NSString *)setUserCover:(UIImage *)image
                     token:(NSString *)token
                    userId:(NSString *)userId;

#pragma mark - Get CategoryArea
// 102
+ (NSString *)getCategoryArea:(NSString *)categoryAreaId
                        token:(NSString *)token
                       userId:(NSString *)userId;

#pragma mark - Get The Me Area
// 103
+ (NSString *)getTheMeArea:(NSString *)token userId:(NSString *)userId;

#pragma mark - Get Sponsor List
// 104
+ (NSString *)getSponsorList:(NSString *)token
                      userId:(NSString *)userId
                       limit:(NSString *)limit;

// 105
+ (NSString *)getAlbum2LikesList:(NSString *)albumId
                           limit:(NSString *)limit
                           token:(NSString *)token
                          userId:(NSString *)userId;

#pragma mark - Gain Photo Use For User
+ (NSString *)gainPhotoUseForUser:(NSString *)param
                photoUseForUserId:(NSString *)photoUseForUserId
                            token:(NSString *)token
                           userId:(NSString *)userId;

#pragma mark - Get Bookmark List
// 107
+ (NSString *)getBookmarkList:(NSString *)token
                       userId:(NSString *)userId;

#pragma mark - Get Photo Use For
//108
+ (NSString *)getPhotoUseFor:(NSString *)photoId
                       token:(NSString *)token
                      userId:(NSString *)userId;

// 109
#pragma mark - Insert Bookmark
+ (NSString *)insertBookmark:(NSString *)photoId
                       token:(NSString *)token
                      userId:(NSString *)userId;

#pragma mark - Exchange Photo
// 110
+ (NSString *)exchangePhotoUseFor:(NSString *)identifier
                          photoId:(NSString *)photoId
                            token:(NSString *)token
                           userId:(NSString *)userId;

#pragma mark - Slot Photo
// 111
+ (NSString *)slotPhotoUseFor:(NSString *)identifier
                      photoId:(NSString *)photoId
                        token:(NSString *)token
                       userId:(NSString *)userId;

#pragma mark - Get Follow From List
// 113
+ (NSString *)getFollowFromList:(NSString *)token
                         userId:(NSString *)userId
                          limit:(NSString *)limit;

#pragma mark - Get AlbumSponsor List
// 114
+ (NSString *)getAlbumSponsorList:(NSString *)albumId
                            limit:(NSString *)limit
                            token:(NSString *)token
                           userId:(NSString *)userId;
//  115
+ (NSString *)getHotList:(NSString *)limit
                   token:(NSString *)token
                  userId:(NSString *)userId;
//測試sign
+(NSString *)testsign;

//傳送圖片
+ (NSString *)updateProfilePic:(NSString *)userId
                         token:(NSString *)token
                         image:(UIImage *)image;

-(void)boxIMGAPI:(NSDictionary *)wData
             URL:(NSString *)urls
           image:(UIImage *)image
            done:(void(^)(NSDictionary *responseData))
doneHandler fail:(void(^)(NSInteger status)) failHandler;

+(NSString *)signGenerator2:(NSDictionary *)parameters;

#pragma mark - 檢測網路
+(BOOL)hostAvailable:(NSString *)theHost;

//GET
+(NSString *)api_GET:(NSString *)url;



#pragma mark - get albumsettings with completionBlock
+ (void)getAlbumSettingsWithAlbumId:(NSString *)albumid completionBlock:(void(^)(NSDictionary *settings, NSError *error))completionBlock;
+ (void)getAlbumDiyWithAlbumId:(NSString *)albumid completionBlock:(void(^)(NSDictionary *result, NSError *error))completionBlock;
+ (void)setAlbumSettingsWithDictionary:(NSString *)settingString albumid:(NSString *)albumid
                       completionBlock:(void(^)(NSDictionary *result, NSError *error))completionBlock;
@end
