//
//  boxAPI.m
//  wPinpinbox
//
//  Created by Angus on 2015/10/12.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "boxAPI.h"
#import "NSString+MD5.h"
#import  <SystemConfiguration/SCNetworkReachability.h>
#import "ReqHTTP.h"
//#import "wTools.h"
#import "UserInfo.h"

#import "MultipartInputStream.h"
#import <MobileCoreServices/MobileCoreServices.h>

//#import "AFNetworking.h"
//#import "UIKit+AFNetworking.h"
#import "GlobalVars.h"

static NSString *hostURL = @"www.pinpinbox.com";

@implementation boxAPI
{
    void (^requestDoneHandler)(NSDictionary *data);
    void (^requestFailHandler)(NSInteger status);
}

+(void)testAPIcode {
    NSLog(@"");
    NSLog(@"testAPIcode");
    
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:@"Andy Wu" forKey:@"name"];
    [dic setObject:@"1233444" forKey:@"sign"];
    
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://platformvmage5.cloudapp.net/ppbtool/design/api_checker.php"]]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[self httpBodyForParamsDictionary:dic]];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __block NSString *str;
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest: request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            str = [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding];
            NSLog(@"str: %@", str);
        } else {
            NSLog(@"error :%@", error);
        }
        
        dispatch_semaphore_signal(semaphore);
    }];
    [task resume];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}
//條款
+(NSString *)getsettings:(NSString *)keyword {
    NSLog(@"");
    NSLog(@"getsettings");
    
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:keyword forKey:@"keyword"];
    
    NSString * returnstr=[self boxAPI:dic URL:@"/getsettings/1.2"];
    
    return returnstr;
}
//登入
+(NSString*)LoginAccount:(NSString *)account Pwd:(NSString *)Pwd {
    NSLog(@"");
    NSLog(@"LoginAccount");
    
    NSString *returnstr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject: account forKey: @"account"];
    [dic setObject: Pwd forKey: @"pwd"];
    
    returnstr = [self boxAPI:dic URL:@"/login/1.0"];
    
    return returnstr;;
}
+(NSString *)FacebookLoginAccount:(NSString *)fbid{
    NSLog(@"");
    NSLog(@"FacebookLoginAccount");
    
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:fbid forKey:@"facebookid"];
    
    NSString * returnstr=[self boxAPI:dic URL:@"/facebooklogin/1.1"];
    
    return returnstr;
}

//Check 帳號&電話號碼
+ (NSString *)check:(NSString *)checkColumn checkValue:(NSString *)value
{
    NSLog(@"");
    NSLog(@"checkColumn checkValue");
    
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject: checkColumn forKey: @"checkcolumn"];
    [dic setObject: value forKey: @"checkvalue"];
    
    returnStr = [self boxAPI: dic URL: @"/check/1.1"];

    return returnStr;
    /*
    if (returnStr != nil) {
        NSDictionary *json = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [returnStr dataUsingEncoding: NSUTF8StringEncoding]                                                                             options: NSJSONReadingMutableContainers error: nil];
        return [json[@"result"] boolValue];
    }
    return NO;
     */
}

//驗證token
+ (NSString *)checktoken:(NSString *)token usid:(NSString *)usid {
    NSLog(@"");
    NSLog(@"checktoken");
    
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject: token forKey: @"token"];
    [dic setObject: usid forKey: @"id"];
    
    return returnStr = [self boxAPI: dic URL: @"/checktoken/1.0"];
    
    /*
    if (returnstr!=nil) {
        NSDictionary *json= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[returnstr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        return [json[@"result"] boolValue];
    }
    return NO;
     */
}

//取得簡訊碼(註冊)
+(NSString *)requsetsmspwd:(NSString *)cellphone Account:(NSString *)account {
    NSLog(@"");
    NSLog(@"requsetsmspwd");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:account forKey:@"account"];
    [dic setObject:cellphone forKey:@"cellphone"];
    [dic setObject:@"register" forKey:@"usefor"];
    
    returnstr=[self boxAPI:dic URL:@"/requestsmspwd/1.1"];

    return returnstr;
}
//取得簡訊碼(修改)
+(NSString *)requsetsmspwd2:(NSString *)cellphone Account:(NSString *)account {
    NSLog(@"");
    NSLog(@"requsetsmspwd2");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:account forKey:@"account"];
    [dic setObject:cellphone forKey:@"cellphone"];
    [dic setObject:@"editcellphone" forKey:@"usefor"];
    
    returnstr=[self boxAPI:dic URL:@"/requestsmspwd/1.1"];
    
    return returnstr;
}

+(NSString *)updatecellphone:(NSString *)oldphone new:(NSString *)newphone pass:(NSString *)smspass{
    NSLog(@"");
    NSLog(@"updatecellphone");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:[UserInfo getUserID] forKey:@"id"];
    [dic setObject:[UserInfo getUserToken] forKey:@"token"];
    [dic setObject:oldphone forKey:@"oldcellphone"];
    [dic setObject:newphone forKey:@"newcellphone"];
    [dic setObject:smspass forKey:@"smspassword"];

    returnstr=[self boxAPI:dic URL:@"/updatecellphone/1.1"];
    
    return returnstr;
}

//註冊

+(NSString *)registration:(NSDictionary *)data {
    NSLog(@"");
    NSLog(@"registration");
    
    NSString *returnstr=@"";
    returnstr=[self boxAPI:data URL:@"/registration/1.2"];
    
    return returnstr;
}
 
+ (NSString *)registration:(NSString *)account
                  password:(NSString *)password
                      name:(NSString *)name
                 cellphone:(NSString *)cellphone
               smspassword:(NSString *)smspassword
                       way:(NSString *)way
                    way_id:(NSString *)way_id
                newsletter:(NSString *)newsletter {
    NSLog(@"");
    NSLog(@"registration");
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject: account forKey: @"account"];
    [dic setObject: password forKey: @"password"];
    [dic setObject: name forKey: @"name"];
    [dic setObject: cellphone forKey: @"cellphone"];
    [dic setObject: smspassword forKey: @"smspassword"];
    [dic setObject: way forKey: @"way"];
    [dic setObject: way_id forKey: @"way_id"];
    
    NSMutableDictionary *wData = [NSMutableDictionary new];
    
    for (NSString *key in dic.allKeys) {
        if ([dic[key] isKindOfClass: [NSString class]]) {
            [wData setObject: dic[key] forKey: key];
        } else {
            [wData setObject: [dic[key] stringValue] forKey: key];
        }
    }
    [dic setObject: [self signGenerator2: dic] forKey: @"sign"];
    [dic setObject: newsletter forKey: @"newsletter"];
    
    NSLog(@"dic: %@", dic);
    
    returnStr = [self api_Wine: @"/registration/1.2" dic: dic];
    
    return returnStr;
}

//忘記密碼
+(NSString *)retrievepassword:(NSString *)cellphone Account:(NSString *)account{
    NSLog(@"");
    NSLog(@"retiievepassword");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:account forKey:@"account"];
    [dic setObject:cellphone forKey:@"cellphone"];
    
    returnstr=[self boxAPI:dic URL:@"/retrievepassword/1.0"];
    
    return returnstr;
}
//更新個人興趣
+ (NSString *)updateprofilehobby:(NSString *)token usid:(NSString *)usid hobby:(NSString *)hobby {
    NSLog(@"");
    NSLog(@"updateprofilehobby");
    
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject: token forKey: @"token"];
    [dic setObject: usid forKey: @"id"];
    [dic setObject: hobby forKey: @"hobby"];
    returnStr = [self boxAPI: dic URL: @"/updateprofilehobby/1.0"];
    
    return returnStr;
    
    /*
    if (returnstr!=nil) {
        NSDictionary *json= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[returnstr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        return [json[@"result"] boolValue];
    }
    return NO;
     */
}

//取得相本資料
+ (NSString *)retrievealbump:(NSString *)albumid
                         uid:(NSString *)uid
                       token:(NSString *)token {
    NSLog(@"");
    NSLog(@"retrievealbump");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    
    [dic setObject:albumid forKey:@"album_id"];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    
    returnstr=[self boxAPI:dic URL:@"/retrievealbump/1.2"];
        
    return returnstr;
}

+ (NSString *)retrievealbump:(NSString *)albumid
                         uid:(NSString *)uid
                       token:(NSString *)token
                      viewed:(NSString *)viewed {
    NSLog(@"");
    NSLog(@"retrievealbump");
    
    NSString *returnStr = @"";
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject:albumid forKey:@"album_id"];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    
    NSMutableDictionary *wData = [NSMutableDictionary new];
    
    for (NSString *kye in dic.allKeys) {
        if ([dic[kye] isKindOfClass: [NSString class]]) {
            [wData setObject: dic[kye] forKey: kye];
        } else {
            [wData setObject: [dic[kye] stringValue]  forKey: kye];
        }
    }
    [dic setObject:[self signGenerator2: dic] forKey: @"sign"];
    
    [dic setObject: viewed forKey: @"viewed"];
    
    
    
    returnStr = [self api_Wine: @"/retrievealbump/1.2" dic: dic];
    
    return returnStr;
}

//取得相本資料-序號
+(NSString *)retrievealbumpbypn:(NSString *)productn uid:(NSString *)uid token:(NSString *)token{
    NSLog(@"");
    NSLog(@"retrievealbumpbypn");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:productn forKey:@"productn"];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    
    returnstr=[self boxAPI:dic URL:@"/retrievealbumpbypn/1.1"];
    
    return returnstr;
}

//取得相本類別
+(NSString *)retrievecatgeorylist:(NSString *)uid token:(NSString *)token{
    NSLog(@"");
    NSLog(@"retrievecatgeorylist");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    
    returnstr=[self boxAPI:dic URL:@"/retrievecatgeorylist/1.2"];
    
    return returnstr;
}

//取得各類下載清單
+(NSString *)retrievehotrank:(NSString *)uid token:(NSString *)token rankid:(NSString *)rankid categoryid:(NSString *)categoryid{
    NSLog(@"");
    NSLog(@"retrievehotrank");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    [dic setObject:rankid forKey:@"rankid"];;
    [dic setObject:categoryid forKey:@"categoryid"];
    
    returnstr=[self boxAPI:dic URL:@"/retrievehotrank/1.0"];
    
    return returnstr;
}

+(NSString *)retrieveHotRank:(NSString *)uid token:(NSString *)token categoryAreaId:(int)categoryAreaId data:(NSDictionary *)data
{
    NSLog(@"");
    NSLog(@"retrieveHotRank");
    
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject: uid forKey: @"id"];
    [dic setObject: token forKey: @"token"];
    [dic setObject: [NSNumber numberWithInt: categoryAreaId] forKey: @"categoryarea_id"];
    [dic addEntriesFromDictionary: data];
    
    returnStr = [self boxAPI: dic URL: @"/retrievehotrank/1.2"];
    
    return returnStr;
}

//取得作者資料 by 相本id
+(NSString *)retrieveauthor:(NSString *)uid token:(NSString *)token albumid:(NSString *)albumid
{
    NSLog(@"");
    NSLog(@"retrieveauthor");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:albumid forKey:@"albumid"];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    
    returnstr=[self boxAPI:dic URL:@"/retrieveauthor/1.0"];
    
    return returnstr;
}

//更改目前用戶對該作者的關注狀態
+(NSString *)changefollowstatus:(NSString *)uid token:(NSString *)token authorid:(NSString *)authorid{
    NSLog(@"");
    NSLog(@"changefollowstatus");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:authorid forKey:@"authorid"];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    
    returnstr=[self boxAPI:dic URL:@"/changefollowstatus/1.0"];
    
    return returnstr;
}

//購買相本
+(NSString *)buyalbum:(NSString *)uid token:(NSString *)token albumid:(NSString *)albumid {
    NSLog(@"");
    NSLog(@"buyAlbum token albumId");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:albumid forKey:@"albumid"];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    [dic setObject:@"apple" forKey:@"platform"];
    
    returnstr=[self boxAPI:dic URL:@"/buyalbum/1.1"];
    
    return returnstr;
}

+ (NSString *)newBuyAlbum:(NSString *)userId
                    token:(NSString *)token
                  albumId:(NSString *)albumId
                 platform:(NSString *)platform
                    point:(NSString *)point
{
    NSLog(@"");
    NSLog(@"newBuyAlbum");
    
    NSString *returnStr = @"";
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject: userId forKey: @"user_id"];
    [dic setObject: token forKey: @"token"];
    [dic setObject: albumId forKey: @"album_id"];
    [dic setObject: platform forKey: @"platform"];
    [dic setObject: point forKey: @"point"];
    
    returnStr = [self boxAPIWithoutSign: dic URL: @"/buyalbum/2.0"];
    
    return returnStr;
}

+ (NSString *)newBuyAlbum:(NSString *)userId
                    token:(NSString *)token
                  albumId:(NSString *)albumId
                 platform:(NSString *)platform
                    point:(NSString *)point
                   reward:(NSString *)reward {
    NSLog(@"");
    NSLog(@"newBuyAlbum");
    
    NSString *returnStr = @"";
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject: userId forKey: @"user_id"];
    [dic setObject: token forKey: @"token"];
    [dic setObject: albumId forKey: @"album_id"];
    [dic setObject: platform forKey: @"platform"];
    [dic setObject: point forKey: @"point"];
    
    if ([wTools objectExists: reward]) {
        [dic setObject: reward forKey: @"reward"];
    }        
    returnStr = [self boxAPIWithoutSign: dic URL: @"/buyalbum/2.0"];
    
    return returnStr;
}

//下載相本
+(NSString *)downloadalbumzip:(NSString *)uid token:(NSString *)token albumid:(NSString *)albumid{
    NSLog(@"");
    NSLog(@"downloadalbumzip");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:albumid forKey:@"albumid"];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    
    returnstr=[self boxAPI:dic URL:@"/downloadalbumzip/1.0"];
    
    return returnstr;
}

//通知下載完成
+(BOOL)finishalbum:(NSString *)uid token:(NSString *)token downloadid:(NSString *)download_id{
    NSLog(@"");
    NSLog(@"finishalbum");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:download_id forKey:@"download_id"];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    
    returnstr=[self boxAPI:dic URL:@"/finishalbum/1.0"];
    
    if (returnstr!=nil) {
        NSDictionary *json= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[returnstr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        return [json[@"result"] boolValue];
    }
    return NO;
}

//刪除自己的相本
+(NSString *)delalbum:(NSString *)uid token:(NSString *)token albumid:(NSString *)albumid{
    NSLog(@"");
    NSLog(@"delalbum");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:albumid forKey:@"albumid"];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    
    returnstr=[self boxAPI:dic URL:@"/delalbum/1.1"];
    
    if (returnstr!=nil) {
        return returnstr;
    }
    return nil;
}
//隱藏收藏相本
+(NSString *)hidealbumqueue:(NSString *)uid token:(NSString *)token albumid:(NSString *)albumid{
    NSLog(@"");
    NSLog(@"hidealbumqueue");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:albumid forKey:@"album_id"];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    
    returnstr=[self boxAPI:dic URL:@"/hidealbumqueue/1.1"];
    
    if (returnstr!=nil) {
        return returnstr;
    }
    return nil;
}

//取得相本清單
//mine/other/cooperation
+(NSString *)getcalbumlist:(NSString *)uid token:(NSString *)token rank:(NSString *)rank limit:(NSString *)limit{
    NSLog(@"");
    NSLog(@"getcalbumlist");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    
    [dic setObject:rank forKey:@"rank"];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    [dic setObject:limit forKey:@"limit"];
    
    returnstr=[self boxAPI:dic URL:@"/getcalbumlist/1.3"];
    
    return returnstr;
}

+(NSString *)getcalbumlist:(NSString *)uid token:(NSString *)token rank:(NSString *)rank{
    NSLog(@"");
    NSLog(@"getcalbumlist");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    
    [dic setObject:rank forKey:@"rank"];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    
    returnstr=[self boxAPI:dic URL:@"/getcalbumlist/1.1"];
    
    return returnstr;
}
//取得待下載清單
+(NSString *)getdownloadlist:(NSString *)uid token:(NSString *)token{
    NSLog(@"");
    NSLog(@"getdownloadlist");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    
    returnstr=[self boxAPI:dic URL:@"/getdownloadlist/1.0"];
    
    return returnstr;
}

//刪除代下載清單(付費相本無法刪除)
+(BOOL)deldownloadlist:(NSString *)uid token:(NSString *)token downloadid:(NSString *)download_id{
    NSLog(@"");
    NSLog(@"deldownloadlist");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:download_id forKey:@"download_id"];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    
    returnstr=[self boxAPI:dic URL:@"/deldownloadlist/1.0"];
    
    if (returnstr!=nil) {
        NSDictionary *json= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[returnstr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        return [json[@"result"] boolValue];
    }
    return NO;
}

//更新會員密碼
+(NSString *)updatepwd:(NSString *)uid token:(NSString *)token oldpwd:(NSString *)oldpwd newpwd:(NSString *)newpwd{
    NSLog(@"");
    NSLog(@"updatepwd");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:oldpwd forKey:@"oldpwd"];
    [dic setObject:newpwd forKey:@"newpwd"];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    returnstr=[self boxAPI:dic URL:@"/updatepwd/1.0"];
    
    return returnstr;
}

/*
+(BOOL)updatepwd:(NSString *)uid token:(NSString *)token oldpwd:(NSString *)oldpwd newpwd:(NSString *)newpwd{
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:oldpwd forKey:@"oldpwd"];
    [dic setObject:newpwd forKey:@"newpwd"];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    returnstr=[self boxAPI:dic URL:@"/updatepwd/1.0"];
    
    if (returnstr != nil) {
        NSDictionary *json= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[returnstr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    
        NSLog(@"json: %@", json);
        NSLog(@"message: %@", json[@"message"]);
        
        return [json[@"result"] boolValue];
    }
    return NO;
}
*/

//取得會員Ｐ點
+(NSString *)geturpoints:(NSString *)uid token:(NSString *)token{
    NSLog(@"");
    NSLog(@"geturpoints");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    [dic setObject:@"apple" forKey:@"platform"];
    
    returnstr=[self boxAPI:dic URL:@"/geturpoints/1.1"];
    
    return returnstr;
}

//取得Ｐ幣商店資料
+(NSString *)getpointstore:(NSString *)uid token:(NSString *)token{
    NSLog(@"");
    NSLog(@"getpointstore");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    [dic setObject:@"apple" forKey:@"platform"];
    [dic setObject:@"TWD" forKey:@"currency"];
    
    returnstr=[self boxAPI:dic URL:@"/getpointstore/1.1"];
    
    return returnstr;
}
//取得由非官方所制定屬於訂單的唯一識別碼
+(NSString *)getpayload:(NSString *)uid token:(NSString *)token productid:(NSString *)productid{
    NSLog(@"");
    NSLog(@"getpayload");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    [dic setObject:productid forKey:@"platform_flag"];
    [dic setObject:@"apple" forKey:@"platform"];
    
    returnstr=[self boxAPI:dic URL:@"/getpayload/1.1"];
    
    return returnstr;
}

//內購完成
+(NSString *)finishpurchased:(NSString *)uid token:(NSString *)token orderid:(NSString *)orderid dataSignature:(NSString *)dataSignature{
    NSLog(@"");
    NSLog(@"finishpurchased");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    [dic setObject:@"apple" forKey:@"platform"];
    [dic setObject:orderid forKey:@"order_id"];
    [dic setObject:dataSignature forKey:@"dataSignature"];
    
    returnstr=[self boxAPI:dic URL:@"/finishpurchased/1.2"];
    
    return returnstr;
}

//取得會員資料
+(NSString *)getprofile:(NSString *)uid token:(NSString *)token {
    NSLog(@"");
    NSLog(@"getprofile");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    
    returnstr=[self boxAPI:dic URL:@"/getprofile/1.1"];
    
    return returnstr;
}

//更新會員資料
+(NSString *)updateprofile:(NSString *)uid token:(NSString *)token data:(NSDictionary *)data{
    NSLog(@"");
    NSLog(@"updateprofile");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic addEntriesFromDictionary:data];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    
    returnstr=[self boxAPI:dic URL:@"/updateprofile/1.1"];
    
    return returnstr;
}

+ (NSString *)updateUser:(NSString *)uid
                   token:(NSString *)token
                   param:(NSString *)param {
    NSLog(@"");
    NSLog(@"updateUser");
    
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    //[dic addEntriesFromDictionary: data];
    [dic setObject: uid forKey: @"user_id"];
    [dic setObject: token forKey: @"token"];
    [dic setObject: param forKey:@"param"];
    
    returnStr = [self boxAPI: dic URL: @"/updateuser/2.0"];
    
    return returnStr;
}


//測試sign
+(NSString *)testsign{
    NSLog(@"");
    NSLog(@"testsign");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:@"+886" forKey:@"phone"];
    [dic setObject:@"abcd" forKey:@"a"];
    [dic setObject:@"Zi Lun Wu" forKey:@"name"];
    
    returnstr=[self boxAPI:dic URL:@"/testsign"];
    
    return returnstr;
}

//取得通知清單
+(NSString *)updatelist:(NSString *)uid
                  token:(NSString *)token
                   data:(NSDictionary *)data
                   rank:(NSString *)rank
{
    NSLog(@"");
    NSLog(@"updatelist");
    
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic addEntriesFromDictionary: data];
    [dic setObject:uid forKey: @"id"];
    [dic setObject:token forKey: @"token"];
    
    NSMutableDictionary *wData = [NSMutableDictionary new];
    
    for (NSString *kye in dic.allKeys) {
        if ([dic[kye] isKindOfClass: [NSString class]]) {
            [wData setObject: dic[kye] forKey: kye];
        } else {
            [wData setObject: [dic[kye] stringValue]  forKey: kye];
        }
    }
    [dic setObject:[self signGenerator2: dic] forKey: @"sign"];
    
    NSLog(@"rank: %@", rank);
    [dic setObject: rank forKey: @"rank"];
    
    
    
    //returnstr=[self boxAPI:dic URL:@"/getupdatelist/1.1"];
    returnStr = [self api_Wine: @"/getupdatelist/1.2" dic: dic];
    
    return returnStr;
}

//取得推薦清單
+(NSString *)getrecommended:(NSString *)uid token:(NSString *)token data:(NSDictionary *)data{
    NSLog(@"");
    NSLog(@"getrecommended");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic addEntriesFromDictionary:data];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    
    returnstr=[self boxAPI:dic URL:@"/getrecommendedauthor/1.1"];
    
    return returnstr;
}

//取得作者專區資料
+(NSString *)getcreative:(NSString *)uid token:(NSString *)token data:(NSDictionary*)data{
    NSLog(@"");
    NSLog(@"getcreative");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic addEntriesFromDictionary:data];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    
    returnstr=[self boxAPI:dic URL:@"/getcreative/1.1"];
    
    return returnstr;
    
}
//取得版型樣式列表
+(NSString *)gettemplatestylelist:(NSString *)uid token:(NSString *)token{
    NSLog(@"");
    NSLog(@"gettemplatestylelist");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    
    returnstr=[self boxAPI:dic URL:@"/gettemplatestylelist/1.1"];
    
    return returnstr;
}

//取得版型清單
+(NSString *)gettemplatelist:(NSString *)uid token:(NSString *)token data:(NSDictionary *)data event: (NSString *)event_id style:(NSString *)style_id
{
    NSLog(@"");
    NSLog(@"gettemplatelist");
    
    NSString *returnstr = @"";
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic addEntriesFromDictionary: data];
    [dic setObject: uid forKey: @"id"];
    [dic setObject: token forKey: @"token"];
    
    NSMutableDictionary *wData = [NSMutableDictionary new];
    
    for (NSString *kye in dic.allKeys) {
        if ([dic[kye] isKindOfClass: [NSString class]]) {
            [wData setObject: dic[kye] forKey: kye];
        } else {
            [wData setObject: [dic[kye] stringValue]  forKey: kye];
        }
    }
    [dic setObject:[self signGenerator2: dic] forKey: @"sign"];
    
    if (event_id) {
        [dic setObject: event_id forKey: @"event_id"];
    }
    
    if (style_id) {
        [dic setObject: style_id forKey: @"style_id"];
    }
    
    returnstr = [self api_Wine: @"/gettemplatelist/1.1" dic: dic];
    
    return returnstr;
}

//設定推播
+(NSString *)setawssns:(NSString *)uid
                 token:(NSString *)token
           devicetoken:(NSString *)devicetoken
            identifier:(NSString *)identifier
{
    NSLog(@"");
    NSLog(@"setawssns");
    
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject: uid forKey: @"id"];
    [dic setObject: token forKey: @"token"];
    [dic setObject: devicetoken forKey: @"devicetoken"];
    [dic setObject: identifier forKey: @"identifier"];
    [dic setObject: @"ios" forKey: @"os"];
    
    returnStr = [self boxAPI: dic URL: @"/setawssns/1.1"];
    
    return returnStr;
}

//取得版型資訊
+(NSString *)gettemplate:(NSString *)uid token:(NSString *)token templateid:(NSString *)templateid{
    NSLog(@"");
    NSLog(@"gettemplate");
    
    NSString *returnstr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    [dic setObject:templateid forKey:@"template_id"];
    
    returnstr = [self boxAPI:dic URL:@"/gettemplate/1.1"];
    
    return returnstr;
}

//購買版型
+(NSString *)buytemplate:(NSString *)uid token:(NSString *)token templateid:(NSString *)templateid{
    NSLog(@"");
    NSLog(@"buytemplate");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    [dic setObject:templateid forKey:@"template_id"];
    [dic setObject:@"apple" forKey:@"platform"];

    returnstr=[self boxAPI:dic URL:@"/buytemplate/1.1"];
    
    return returnstr;
}


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
+(NSString *)search:(NSString *)uid token:(NSString *)token data:(NSDictionary *)data{
    NSLog(@"");
    NSLog(@"search");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic addEntriesFromDictionary:data];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    
    returnstr=[self boxAPI:dic URL:@"/search/1.1"];
    
    return returnstr;
}

// Protocol 86
// RecommendedList for Search
+ (NSString *)getRecommendedList: (NSString *)uid token:(NSString *)token data:(NSDictionary *)data {
    NSLog(@"");
    NSLog(@"getRecommendedList");
    
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic addEntriesFromDictionary: data];
    [dic setObject: uid forKey: @"id"];
    [dic setObject: token forKey: @"token"];
        
    returnStr = [self boxAPI: dic URL: @"/getrecommendedlist/1.3"];
    
    return returnStr;
}

#pragma mark -
#pragma mark 共用
//取得共用狀態
+(NSString *)getcooperation:(NSString *)uid token:(NSString *)token data:(NSDictionary *)data{
    NSLog(@"");
    NSLog(@"getcooperation");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic addEntriesFromDictionary:data];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    
    returnstr=[self boxAPI:dic URL:@"/getcooperation/1.1"];
    
    return returnstr;
}

//取得共用清單     type:album   type_id  user_id
+(NSString *)getcooperationlist:(NSString *)uid token:(NSString *)token data:(NSDictionary *)data{
    NSLog(@"");
    NSLog(@"getCooperationList");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic addEntriesFromDictionary:data];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    
    NSLog(@"data: %@", data);
    
    
    returnstr=[self boxAPI:dic URL:@"/getcooperationlist/1.1"];
    
    return returnstr;
}
//刪除共用   type:album   type_id  user_id
+(NSString *)deletecooperation:(NSString *)uid token:(NSString *)token data:(NSDictionary *)data{
    NSLog(@"");
    NSLog(@"deletecooperation");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic addEntriesFromDictionary:data];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    
    returnstr=[self boxAPI:dic URL:@"/deletecooperation/1.1"];
    
    return returnstr;
}

//新增共用   type:album   type_id  user_id
+(NSString *)addcooperation:(NSString *)uid token:(NSString *)token data:(NSDictionary *)data{
    NSLog(@"");
    NSLog(@"addcooperation");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic addEntriesFromDictionary:data];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    
    returnstr=[self boxAPI:dic URL:@"/insertcooperation/1.1"];
    
    return returnstr;
}

//修改更新共用
/*
 type
 "類型
 album / template"
 
 type_id
 類型的 id
 
 user_id
 用戶 id
 
 identity
 "身分
 admin<管理者> / approver<副管理者> / editor<共用者> / viewer<瀏覽者>"
 
 */
+(NSString *)updatecooperation:(NSString *)uid token:(NSString *)token data:(NSDictionary *)data{
    NSLog(@"");
    NSLog(@"updatecooperation");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic addEntriesFromDictionary:data];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    
    returnstr=[self boxAPI:dic URL:@"/updatecooperation/1.1"];
    
    return returnstr;
}

#pragma mark -
#pragma mark 建立相本相關

//檢查是否有處理中 (process) 的相本
+(NSString *)checkalbumofdiy:(NSString *)uid token:(NSString *)token{
    NSLog(@"");
    NSLog(@"checkalbumofdiy");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    
    returnstr=[self boxAPI:dic URL:@"/addcooperation/1.2"];
    
    return returnstr;
}

//新增 diy 的相本
+(NSString *)insertalbumofdiy:(NSString *)uid token:(NSString *)token template_id:(NSString *)template_id{
    NSLog(@"");
    NSLog(@"insertalbumofdiy");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    [dic setObject:template_id forKey:@"template_id"];
    
    returnstr=[self boxAPI:dic URL:@"/insertalbumofdiy/1.1"];
    
    return returnstr;
}

//取得 diy 的相本
+(NSString *)getalbumofdiy:(NSString *)uid token:(NSString *)token album_id:(NSString *)album_id{
    NSLog(@"");
    NSLog(@"getalbumofdiy");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    [dic setObject:album_id forKey:@"album_id"];
    
    returnstr=[self boxAPI:dic URL:@"/getalbumofdiy/1.1"];
    
    return returnstr;
}

//刪除diy相本
+(NSString *)deletephotoofdiy:(NSString *)uid token:(NSString *)token album_id:(NSString *)album_id photo_id:(NSString *)photo_id{
    NSLog(@"");
    NSLog(@"deletephotoofdiy");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    [dic setObject:album_id forKey:@"album_id"];
    [dic setObject:photo_id forKey:@"photo_id"];
    
    returnstr=[self boxAPI:dic URL:@"/deletephotoofdiy/1.2"];
    
    return returnstr;
}

//排序diy的相片
+(NSString *)sortphotoofdiy:(NSString *)uid token:(NSString *)token album_id:(NSString *)album_id {
    return @"";
}

//更新diy相本
+(NSString *)updatealbumofdiy:(NSString *)uid token:(NSString *)token album_id:(NSString *)album_id{
    NSLog(@"");
    NSLog(@"updatealbumofdiy");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    [dic setObject:album_id forKey:@"album_id"];
    
    returnstr=[self boxAPI:dic URL:@"/updatealbumofdiy/1.1"];
    
    return returnstr;
}

//取得相本資訊表單資料
+(NSString *)getalbumdataoptions:(NSString *)uid token:(NSString *)token{
    NSLog(@"");
    NSLog(@"getalbumdataoptions");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    
    returnstr=[self boxAPI:dic URL:@"/getalbumdataoptions/1.0"];
    
    return returnstr;
}

//取的相本資訊ingo
+(NSString *)getalbumsettings:(NSString *)uid token:(NSString *)token album_id:(NSString *)album_id{
    NSLog(@"");
    NSLog(@"getalbumsettings");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    //[dic setObject:uid forKey:@"id"];
    [dic setObject:uid forKey:@"user_id"];
    [dic setObject:token forKey:@"token"];
    //[dic setObject:album_id forKey:@"albumid"];
    [dic setObject:album_id forKey:@"album_id"];
    
    returnstr=[self boxAPI:dic URL:@"/getalbumsettings/2.0"];
    
    return returnstr;
}

//更新相本資訊
+(NSString *)albumsettings:(NSString *)uid
                     token:(NSString *)token
                  album_id:(NSString *)album_id
                  settings:(NSString *)settings{
    NSLog(@"");
    NSLog(@"albumsettings");
    
    NSString *returnstr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:uid forKey:@"user_id"];
    [dic setObject:token forKey:@"token"];    
    [dic setObject:album_id forKey:@"album_id"];
    [dic setObject:settings forKey:@"settings"];
    
//    returnstr = [self boxAPI:dic URL:@"/albumsettings/2.0"];
    returnstr = [self boxAPI:dic URL:@"/updatealbumsettings/2.0"];//@"/albumsettings/2.0"];
    
    return returnstr;
}

//檢查相本是否更新
+(NSString *)checkalbumzip:(NSString *)uid token:(NSString *)token album_id:(NSString *)album_id{
    NSLog(@"");
    NSLog(@"checkalbumzip");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    [dic setObject:album_id forKey:@"album_id"];
    
    returnstr=[self boxAPI:dic URL:@"/checkalbumzip/1.1"];
    
    return returnstr;
}

//取得取得檢舉意向清單
+(NSString *)getreportintentlist:(NSString *)uid token:(NSString *)token{
    NSLog(@"");
    NSLog(@"getreportintentlist");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    
    returnstr=[self boxAPI:dic URL:@"/getreportintentlist/1.2"];
    
    return returnstr;
}

//新增檢舉
+(NSString *)insertreport:(NSString *)uid token:(NSString *)token rid:(NSString *)rid type:(NSString *)type typeid:(NSString *)tid{
    NSLog(@"");
    NSLog(@"insertreport");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    [dic setObject:rid forKey:@"reportintent_id"];
    [dic setObject:type forKey:@"type"];
    [dic setObject:tid forKey:@"type_id"];
    
    returnstr=[self boxAPI:dic URL:@"/insertreport/1.2"];
    
    return returnstr;
}

//更新相片SETTINGS -> settings key : @"settings[description]", @"settings[hyperlink]", @"settings[location]"
+ (void) updatephotoofdiy:(NSString *)uid token:(NSString *)token album_id:(NSString *)album_id photo_id:(NSString *)photo_id  key:(NSString *)key settingStr:(NSString *)settingStr completed:(void(^)(NSDictionary *result, NSError *error))completionBlock {
    
    NSDictionary *p = @{@"id": uid, @"token":token, @"album_id":album_id,@"photo_id":photo_id};
    NSMutableDictionary *param =[NSMutableDictionary dictionaryWithDictionary: p];
    NSString *ss = [self signGenerator2:p];
    [param setObject:ss forKey:@"sign"];
    
    [param setObject:settingStr forKey:[NSString stringWithFormat:@"settings[%@]",key]];
    
    
    NSURL* requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",ServerURL,@"/updatephotoofdiy",@"/1.2"]];
    
    // create request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];//[[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval: [kTimeOut floatValue]];
    [request setHTTPMethod:@"POST"];
    
    NSString *BoundaryConstant =@"----------V2ymHFg03ehbqgZCaKO6jy";
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    for (NSString *p in param) {
        NSLog(@"param: %@", p);
        
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", @"----------V2ymHFg03ehbqgZCaKO6jy"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", p] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [param objectForKey:p]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];

    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];

    [request setValue: @"zh-TW,zh" forHTTPHeaderField: @"HTTP_ACCEPT_LANGUAGE"];

    [request setURL:requestURL];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest: request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *str = nil;
        if (data) {
            str = [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding];
            NSError *er = nil;
            NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &er];
            completionBlock(dic, er);
            NSLog(@"str: %@", dic);
        
        } else {
            NSLog(@"error :%@", error);
            if (error.code == -1001) {
                str = timeOutErrorCode;
            }
            completionBlock(nil, error);
        }
        
    }];
    [task resume];
}

//更新相片
+ (NSString *)updatephotoofdiy:(NSString *)uid token:(NSString *)token album_id:(NSString *)album_id photo_id:(NSString *)photo_id image:(UIImage *)image setting:(NSString *)setting {
    NSLog(@"");
    NSLog(@"updatephotoofdiy");
    
    NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
    [_params setObject:uid forKey:@"id"];
    [_params setObject:token forKey:@"token"];
    [_params setObject:album_id forKey:@"album_id"];
    [_params setObject:photo_id forKey:@"photo_id"];
    [_params setObject:[self signGenerator2:_params] forKey:@"sign"];
    
    // Text Description
    [_params setObject: setting forKey: @"settings[description]"];
    
    // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
    NSString *BoundaryConstant =@"----------V2ymHFg03ehbqgZCaKO6jy";
    
    // string constant for the post parameter 'file'. My server uses this name: `file`. Your's may differ
    NSString* FileParamConstant =@"file";
    
    // the server url to which the image (or the media) is uploaded. Use your server url here
    NSURL* requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",ServerURL,@"/updatephotoofdiy",@"/1.2"]];
    
    // create request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];//[[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval: [kTimeOut floatValue]];
    [request setHTTPMethod:@"POST"];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in _params) {
        NSLog(@"param: %@", param);
        
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add image data
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set HTTP_ACCEPT_LANGUAGE in HTTP Header
    [request setValue: @"zh-TW,zh" forHTTPHeaderField: @"HTTP_ACCEPT_LANGUAGE"];
    
    // set URL
    [request setURL:requestURL];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __block NSString *str;
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest: request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            str = [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding];
            NSLog(@"str: %@", str);
        } else {
            NSLog(@"error :%@", error);
            if (error.code == -1001) {
                str = timeOutErrorCode;
            }
        }
        
        dispatch_semaphore_signal(semaphore);
    }];
    [task resume];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return str;
}

//新增圖片
//+(NSString *)insertphotoofdiy:(NSString *)uid token:(NSString *)token album_id:(NSString *)album_id image:(UIImage *)image{
+ (NSString *)insertphotoofdiy:(NSString *)uid token:(NSString *)token album_id:(NSString *)album_id image:(UIImage *)image compression:(CGFloat)compressionQuality {
    
    NSLog(@"");
    NSLog(@"insertphotoofdiy");
    
    // Dictionary that holds post parameters. You can set your post parameters that your server accepts or programmed to accept.
    NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
    [_params setObject:uid forKey:@"id"];
    [_params setObject:token forKey:@"token"];
    [_params setObject:album_id forKey:@"album_id"];
    [_params setObject:[self signGenerator2:_params] forKey:@"sign"];
    
    // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
    NSString *BoundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";
    
    // string constant for the post parameter 'file'. My server uses this name: `file`. Your's may differ
    NSString* FileParamConstant = @"file";
    
    // the server url to which the image (or the media) is uploaded. Use your server url here
    NSURL* requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",ServerURL,@"/insertphotoofdiy",@"/1.1"]];
    
    // create request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];//[[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval: 10];
    [request setHTTPMethod:@"POST"];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in _params) {
        NSLog(@"");
        NSLog(@"param: %@", param);
        
        // start tag
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        
        // end tag
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];                
    }
    
    // add image data
    NSData *imageData = UIImageJPEGRepresentation(image, compressionQuality);
    
    if (imageData) {
        // start tag
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        
        // end tag
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // close form
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set HTTP_ACCEPT_LANGUAGE in HTTP Header
    [request setValue: @"zh-TW,zh" forHTTPHeaderField: @"HTTP_ACCEPT_LANGUAGE"];
    
    // set URL
    [request setURL:requestURL];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __block NSString *str;
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    //config.timeoutIntervalForRequest = 0.0001;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration: config];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest: request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSLog(@"insertphotoofdiy");
        
        if (data) {
            str = [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding];
            
            NSLog(@"str: %@", str);
        } else {
            str = [NSString stringWithFormat: @"%ld",(long)error.code];
            
            NSLog(@"");
            NSLog(@"error: %@", error);
            NSLog(@"error.userInfo: %@", error.userInfo);
            NSLog(@"error.localizedDescription: %@", error.localizedDescription);
            NSLog(@"error code: %@", [NSString stringWithFormat: @"%ld",(long)error.code]);
        }
        
        dispatch_semaphore_signal(semaphore);
    }];
    NSLog(@"task resume");
    [task resume];
     
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return str;
}

+ (NSString *)insertPhotoOfDiy:(NSString *)uid token:(NSString *)token album_id:(NSString *)album_id image:(UIImage *)image compression:(CGFloat)compressionQuality
{
    NSLog(@"");
    NSLog(@"insertPhotoOfDiy");
    
    NSMutableDictionary *_params = [[NSMutableDictionary alloc] init];
    [_params setObject: uid forKey: @"id"];
    [_params setObject: token forKey: @"token"];
    [_params setObject: album_id forKey: @"album_id"];
    [_params setObject: [self signGenerator2: _params] forKey: @"sign"];
    
//    NSData *imageData = UIImageJPEGRepresentation(image, compressionQuality);
//    
//    NSString *BoundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";
//    NSString* FileParamConstant = @"file";
//    
//    NSString *urlString = [NSString stringWithFormat: @"%@%@%@", ServerURL, @"/insertphotoofdiy", @"/1.1"];
//    NSURL *requestURL = [NSURL URLWithString: urlString];
//    //NSURL *requestURL = [NSURL URLWithString: [NSString stringWithFormat: @"%@%@%@", ServerURL, @"/insertphotoofdiy", @"/1.1"]];
    
    /*
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy: NSURLRequestReloadIgnoringCacheData];
    [request setHTTPShouldHandleCookies: NO];
    [request setTimeoutInterval: 10];
    [request setHTTPMethod: @"POST"];
    */
    
    NSLog(@"NSMutableURLRequest *request");
//    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod: @"POST" URLString: urlString parameters: _params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
//        
//    } error: nil];
    
//    NSLog(@"AFURLSessionManager *manager");
//    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration: [NSURLSessionConfiguration defaultSessionConfiguration]];
//    NSURLSessionUploadTask *uploadTask;
//    uploadTask = [manager uploadTaskWithStreamedRequest: request progress:^(NSProgress * _Nonnull uploadProgress) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLog(@"update for progress");
//        });
//    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
//        if (error) {
//            NSLog(@"Error: %@", error);
//        } else {
//            NSLog(@"%@ %@", response, responseObject);
//        }
//    }];
//    [uploadTask resume];
//
    /*
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue: contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    for (NSString *param in _params) {
        NSLog(@"");
        NSLog(@"param: %@", param);
        
        [body appendData: [[NSString stringWithFormat: @"--%@\r\n", BoundaryConstant] dataUsingEncoding: NSUTF8StringEncoding]];
        [body appendData: [[NSString stringWithFormat: @"%@\r\n", [_params objectForKey: param]] dataUsingEncoding: NSUTF8StringEncoding]];
        NSLog(@"body: %@", body);
    }
    
    if (imageData) {
        [body appendData: [[NSString stringWithFormat: @"--%@\r\n", BoundaryConstant] dataUsingEncoding: NSUTF8StringEncoding]];
        [body appendData: [[NSString stringWithFormat: @"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", FileParamConstant] dataUsingEncoding: NSUTF8StringEncoding]];
        [body appendData: [@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding: NSUTF8StringEncoding]];
        [body appendData: imageData];
        
        [body appendData: [[NSString stringWithFormat: @"\r\n"] dataUsingEncoding: NSUTF8StringEncoding]];
        NSLog(@"");
        NSLog(@"body: %@", body);
    }
    
    [body appendData: [[NSString stringWithFormat: @"--%@--\r\n", BoundaryConstant] dataUsingEncoding: NSUTF8StringEncoding]];
    [request setHTTPBody: body];
    NSString *postLength = [NSString stringWithFormat: @"%lu", (unsigned long)[body length]];
    [request setValue: postLength forHTTPHeaderField: @"Content-Length"];
    [request setValue: @"zh-TW,zh" forHTTPHeaderField: @"HTTP_ACCEPT_LANGUAGE"];
    [request setURL: requestURL];
    */
    
//
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//
//    __block NSString *str;
//    NSURLSession *session = [NSURLSession sharedSession];
//    NSURLSessionTask *task = [session dataTaskWithRequest: request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if (data) {
//            str = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
//            NSLog(@"str: %@", str);
//        } else {
//            NSLog(@"error: %@", error);
//        }
//        dispatch_semaphore_signal(semaphore);
//    }];
//    [task resume];
//
//    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//
//    return str;
    return @"";
}

#pragma mark -
#pragma mark 抽獎
+ (NSString *)getPhotoUseForUser:(NSString *)uid token:(NSString *)token photo_id:(NSString *)photo_id identifier:(NSString *)identifier
{
    NSLog(@"");
    NSLog(@"getPhotoUseForUser");
    
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject: uid forKey: @"id"];
    [dic setObject: token forKey: @"token"];
    [dic setObject: photo_id forKey: @"photo_id"];
    [dic setObject: identifier forKey: @"identifier"];
    
    returnStr = [self boxAPI: dic URL: @"/getphotousefor_user/1.2"];
    
    return returnStr;
}

+ (NSString *)updatePhotoUseForUser:(NSString *)uid
                              token:(NSString *)token
                  photoUseForUserId:(NSString *)photoUseForUserId
{
    NSLog(@"");
    NSLog(@"updatePhotoUseForUser");
    
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject: uid forKey: @"id"];
    [dic setObject: token forKey: @"token"];
    [dic setObject: photoUseForUserId forKey: @"photousefor_user_id"];
    
    returnStr = [self boxAPI: dic URL: @"/updatephotousefor_user/1.1"];

    return returnStr;
}

// 43 New
#pragma mark - Update Photo Use For User
+ (NSString *)updatePhotoUseForUser:(NSString *)param
                  photoUseForUserId:(NSString *)photoUseForUserId
                              token:(NSString *)token
                             userId:(NSString *)userId
{
    NSLog(@"");
    NSLog(@"updatePhotoUseForUser");
    
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject: param forKey: @"param"];
    [dic setObject: photoUseForUserId forKey: @"photousefor_user_id"];
    [dic setObject: token forKey: @"token"];
    [dic setObject: userId forKey: @"user_id"];
    
    returnStr = [self boxAPI: dic URL: @"/updatephotousefor_user/2.0"];
    
    return returnStr;
}

#pragma mark - Sort Photo
+ (NSString *)sortPhotoOfDiy:(NSString *)uid token:(NSString *)token album_id:(NSString *)album_id sort:(NSString *)photo_id
{
    NSLog(@"");
    NSLog(@"sortPhotoOfDiy");
    
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject: uid forKey: @"id"];
    [dic setObject: token forKey: @"token"];
    [dic setObject: album_id forKey: @"album_id"];
    [dic setObject: photo_id forKey: @"sort"];
    
    returnStr = [self boxAPI: dic URL: @"/sortphotoofdiy/1.3"];
    
    return returnStr;
}

#pragma mark -
#pragma mark 投稿活動相關
+ (NSString *)switchstatusofcontribution: (NSString *)uid token: (NSString *)token event_id: (NSString *)event_id album_id: (NSString *)album_id
{
    NSLog(@"");
    NSLog(@"switchstatusofcontribution");
    
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject: uid forKey: @"id"];
    [dic setObject: token forKey: @"token"];
    [dic setObject: event_id forKey: @"event_id"];
    [dic setObject: album_id forKey: @"album_id"];
    
    returnStr = [self boxAPI: dic URL: @"/switchstatusofcontribution/1.2"];
    
    return returnStr;
}

+ (NSString *)getAdList: (NSString *)uid token: (NSString *)token adarea_id: (NSString *)adarea_id
{
    NSLog(@"");
    NSLog(@"getAdList");
    
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject: uid forKey: @"id"];
    [dic setObject: token forKey: @"token"];
    [dic setObject: adarea_id forKey: @"adarea_id"];
    
    returnStr = [self boxAPI: dic URL: @"/getadlist/1.3"];
    
    return returnStr;
}

+ (NSString *)getEvent: (NSString *)uid token: (NSString *)token event_id: (NSString *)event_id
{
    NSLog(@"");
    NSLog(@"getEvent");
    
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject: uid forKey: @"id"];
    [dic setObject: token forKey: @"token"];
    [dic setObject: event_id forKey: @"event_id"];
    
    returnStr = [self boxAPI: dic URL: @"/getevent/1.2"];
    
    return returnStr;
}

#pragma mark -
#pragma mark Audio Related

+ (NSString *)updateAudioOfDiy: (NSString *)uid token: (NSString *)token album_id: (NSString *)album_id photo_id: (NSString *)photo_id file: (NSData *)audioData
{
    NSLog(@"");
    NSLog(@"updateAudioOfDiy");
    
    NSMutableDictionary *_params = [[NSMutableDictionary alloc] init];
    [_params setObject: uid forKey: @"id"];
    [_params setObject: token forKey: @"token"];
    [_params setObject: album_id forKey: @"album_id"];
    [_params setObject: photo_id forKey: @"photo_id"];
    [_params setObject: [self signGenerator2: _params] forKey: @"sign"];
    
    /*
    NSLog(@"id: %@", uid);
    NSLog(@"token: %@", token);
    NSLog(@"album_id: %@", album_id);
    NSLog(@"photo_id: %@", photo_id);
    NSLog(@"sign: %@", [self signGenerator2: _params]);
    */
    
    // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
    NSString *BoundaryConstant =@"----------V2ymHFg03ehbqgZCaKO6jy";
    
    // string constant for the post parameter 'file'. My server uses this name: `file`. Your's may differ
    NSString* FileParamConstant =@"file";
    
    // the server url to which the image (or the media) is uploaded. Use your server url here
    NSURL* requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",ServerURL,@"/updateaudioofdiy",@"/1.2"]];

    // create request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];//[[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval: [kTimeOutForPhoto floatValue]];
    [request setHTTPMethod:@"POST"];

    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in _params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add audio data
    //NSData *data = [NSData dataWithData: audioData];
    
    if (audioData) {
        [body appendData: [[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData: [[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"uploadAudio.m4a\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData: [@"Content-Type: audio/m4a\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData: audioData];
        [body appendData: [[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set HTTP_ACCEPT_LANGUAGE in HTTP Header
    [request setValue: @"zh-TW,zh" forHTTPHeaderField: @"HTTP_ACCEPT_LANGUAGE"];
    
    // set URL
    [request setURL:requestURL];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __block NSString *str;
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest: request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data) {
            str = [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding];
            //NSLog(@"str: %@", str);
        } else {
            NSLog(@"error :%@", error);
            
            str = [NSString stringWithFormat: @"%ld",(long)error.code];
        }
        
        dispatch_semaphore_signal(semaphore);
    }];
    [task resume];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return str;
}

+ (NSString *)deleteAudioOfDiy:(NSString *)uid token:(NSString *)token album_id:(NSString *)album_id photo_id:(NSString *)photo_id
{
    NSLog(@"");
    NSLog(@"deleteAudioOfDiy");
    
    NSString *returnStr = @"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    [dic setObject:album_id forKey:@"album_id"];
    [dic setObject:photo_id forKey:@"photo_id"];
    
    returnStr = [self boxAPI:dic URL:@"/deleteaudioofdiy/1.2"];
    return returnStr;
}

#pragma mark -
#pragma mark Video Related
+ (NSString *)insertVideoOfDiy:(NSString *)uid token:(NSString *)token album_id:(NSString *)album_id file:(NSData *)videoData
{
    NSLog(@"");
    NSLog(@"insertvideoofdiy");
    
    NSMutableDictionary *_params = [[NSMutableDictionary alloc] init];
    [_params setObject: uid forKey: @"id"];
    [_params setObject: token forKey: @"token"];
    [_params setObject: album_id forKey: @"album_id"];
    [_params setObject: [self signGenerator2: _params] forKey: @"sign"];
    
    NSLog(@"id: %@", uid);
    NSLog(@"token: %@", token);
    NSLog(@"album_id: %@", album_id);
    NSLog(@"sign: %@", [self signGenerator2: _params]);
    
    // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
    NSString *BoundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";
    
    // string constant for the post parameter 'file'. My server uses this name: `file`. Your's may differ
    NSString* FileParamConstant = @"file";
    
    // the server url to which the image (or the media) is uploaded. Use your server url here
    NSURL* requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",ServerURL,@"/insertvideoofdiy",@"/1.2"]];
    
    // create request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];//[[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval: [kTimeOutForVideo floatValue]];
    [request setHTTPMethod:@"POST"];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue: contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in _params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add audio data
    //NSData *data = [NSData dataWithData: audioData];
    
    if (videoData) {
        [body appendData: [[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData: [[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"uploadVideo.mov\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData: [@"Content-Type: video/mov\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData: videoData];
        [body appendData: [[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set HTTP_ACCEPT_LANGUAGE in HTTP Header
    [request setValue: @"zh-TW,zh" forHTTPHeaderField: @"HTTP_ACCEPT_LANGUAGE"];
    
    // set URL
    [request setURL:requestURL];
    
    //return request;        
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSString *str;
    
    /*
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = [kTimeOutForVideo floatValue];
    config.timeoutIntervalForResource = [kTimeOutForVideo floatValue];
    NSURLSession *session = [NSURLSession sessionWithConfiguration: config];
    */
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest: request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data) {
            str = [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding];
            NSLog(@"str: %@", str);
        } else {
            str = [NSString stringWithFormat: @"%d", (int)error.code];
            NSLog(@"error :%@", error);
            NSLog(@"error.userInfo: %@", error.userInfo);
            NSLog(@"error.localizedDescription: %@", error.localizedDescription);
            NSLog(@"error code: %@", [NSString stringWithFormat: @"%d", (int)error.code]);
        }
        
        dispatch_semaphore_signal(semaphore);
    }];
    [task resume];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    NSLog(@"return str: %@", str);
    
    return str;
}

+ (NSString *)deleteVideoOfDiy:(NSString *)uid token:(NSString *)token album_id:(NSString *)album_id photo_id:(NSString *)photo_id
{
    NSLog(@"");
    NSLog(@"deleteVideoOfdiy");
    
    NSString *returnStr = @"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    [dic setObject:album_id forKey:@"album_id"];
    [dic setObject:photo_id forKey:@"photo_id"];
    
    returnStr = [self boxAPI:dic URL:@"/deletevideoofdiy/1.2"];
    
    return returnStr;
}

#pragma mark -
#pragma mark 活動任務
+ (NSString *)doTask1: (NSString *)uid token: (NSString *)token task_for: (NSString *)task_for platform: (NSString *)platform
{
    NSLog(@"");
    NSLog(@"doTask1");
    
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject: uid forKey: @"id"];
    [dic setObject: token forKey: @"token"];
    [dic setObject: task_for forKey: @"task_for"];
    [dic setObject: platform forKey: @"platform"];
    
    returnStr = [self boxAPI: dic URL: @"/dotask/1.3"];
    
    return returnStr;
}

+ (NSString *)doTask2: (NSString *)uid token: (NSString *)token task_for: (NSString *)task_for platform: (NSString *)platform type: (NSString *)type type_id: (NSString *)type_id;
{
    NSLog(@"");
    NSLog(@"doTask2");
    
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject: uid forKey: @"id"];
    [dic setObject: token forKey: @"token"];
    [dic setObject: task_for forKey: @"task_for"];
    [dic setObject: platform forKey: @"platform"];
    [dic setObject: type forKey: @"type"];
    [dic setObject: type_id forKey: @"type_id"];
    
    //returnStr = [self boxAPI: dic URL: @"/dotask/1.3"];
    returnStr = [self boxAPIForGettingPoint: dic URL: @"/dotask/1.3"];
    
    return returnStr;
}

+ (NSString *)checkTaskCompleted:(NSString *)uid
                           token:(NSString *)token
                        task_for:(NSString *)task_for
                        platform:(NSString *)platform {
    NSLog(@"");
    NSLog(@"checkTaskCompleted");
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject: uid forKey: @"id"];
    [dic setObject: token forKey: @"token"];
    [dic setObject: task_for forKey: @"task_for"];
    [dic setObject: platform forKey: @"platform"];
    
    returnStr = [self boxAPI: dic URL: @"/checktaskcompleted/1.3"];
    
    return returnStr;
}

+ (NSString *)checkTaskCompleted:(NSString *)uid
                           token:(NSString *)token
                        task_for:(NSString *)task_for
                        platform:(NSString *)platform
                            type:(NSString *)type
                          typeId:(NSString *)typeId {
    NSLog(@"");
    NSLog(@"checkTaskCompleted");
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject: uid forKey: @"id"];
    [dic setObject: token forKey: @"token"];
    [dic setObject: task_for forKey: @"task_for"];
    [dic setObject: platform forKey: @"platform"];
    
    NSMutableDictionary *wData = [NSMutableDictionary new];
    
    for (NSString *key in dic.allKeys) {
        if ([dic[key] isKindOfClass: [NSString class]]) {
            [wData setObject: dic[key] forKey: key];
        } else {
            [wData setObject: [dic[key] stringValue] forKey: key];
        }
    }
    [dic setObject: [self signGenerator2: dic] forKey: @"sign"];
    [dic setObject: type forKey: @"type"];
    [dic setObject: typeId forKey: @"type_id"];
    returnStr = [self api_Wine: @"/checktaskcompleted/1.3" dic: dic];
    
    return returnStr;
}

#pragma mark - Notification Center
+ (NSString *)getPushQueue: (NSString *)uid token: (NSString *)token limit: (NSString *)limit
{
    NSLog(@"");
    NSLog(@"getPushQueue");
    
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject: uid forKey: @"id"];
    [dic setObject: token forKey: @"token"];
    [dic setObject: limit forKey: @"limit"];
    
    returnStr = [self boxAPI: dic URL: @"/getpushqueue/1.0"];
    
    return returnStr;
}

#pragma mark - GetQRCode
+ (NSString *)getQRCode: (NSString *)uid token:(NSString *)token type:(NSString *)type type_id:(NSString *)type_id effect:(NSString *)effect is:(NSString *)is;
{
    NSLog(@"");
    NSLog(@"getQRCode");
    
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject: uid forKey: @"id"];
    [dic setObject: token forKey: @"token"];
    [dic setObject: type forKey: @"type"];
    [dic setObject: type_id forKey: @"type_id"];
    [dic setObject: effect forKey: @"effect"];
    
    NSMutableDictionary *wData = [NSMutableDictionary new];
    
    for (NSString *key in dic.allKeys) {
        if ([dic[key] isKindOfClass: [NSString class]]) {
            [wData setObject: dic[key] forKey: key];
        } else {
            [wData setObject: [dic[key] stringValue] forKey: key];
        }
    }
    [dic setObject: [self signGenerator2: dic] forKey: @"sign"];
    
    NSLog(@"is: %@", is);
    [dic setObject: is forKey: @"is"];
    
    
    
    //returnStr = [self boxAPI: dic URL: @"/getqrcode/1.0"];
    returnStr = [self api_Wine: @"/getqrcode/1.0" dic: dic];
    
    return returnStr;
}

#pragma mark - GetFollowToList
+ (NSString *)getFollowToList: (NSString *)uid token: (NSString *)token limit: (NSString *)limit
{
    NSLog(@"");
    NSLog(@"getFollowToList");
    
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject: uid forKey: @"id"];
    [dic setObject: token forKey: @"token"];
    [dic setObject: limit forKey: @"limit"];
    
    returnStr = [self boxAPI: dic URL: @"/getfollowtolist/1.3"];
    
    return returnStr;
}

#pragma mark - Check Update Version
+ (NSString *)checkUpdateVersion: (NSString *)platform version: (NSString *)version
{
    NSLog(@"");
    NSLog(@"checkUpdateVersion");
    
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject: platform forKey: @"platform"];
    [dic setObject: version forKey: @"version"];
    
    returnStr = [self boxAPI: dic URL: @"/checkupdateversion/1.0"];
    
    return returnStr;
}

#pragma mark - Get Hobby
+ (NSString *)getHobbyList: (NSString *)uid token:(NSString *)token
{
    NSLog(@"");
    NSLog(@"getHobbyList");
    
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject: uid forKey: @"id"];
    [dic setObject: token forKey: @"token"];
    
    returnStr = [self boxAPI: dic URL: @"/gethobbylist/1.3"];
    
    return returnStr;
}

#pragma mark - Message Board
+ (NSString *)getMessageBoardList: (NSString *)uid
                            token:(NSString *)token
                             type:(NSString *)type
                           typeId:(NSString *)typeId
                            limit:(NSString *)limit
{
    NSLog(@"");
    NSLog(@"boxAPI");
    NSLog(@"getMessageBoardList");
    
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject: uid forKey: @"id"];
    [dic setObject: token forKey: @"token"];
    [dic setObject: type forKey: @"type"];
    [dic setObject: typeId forKey: @"type_id"];
    [dic setObject:limit forKey:@"limit"];
    
    returnStr = [self boxAPI: dic URL: @"/getmessageboardlist/1.3"];
    
    return returnStr;
}

+ (NSString *)insertMessageBoard:(NSString *)uid token:(NSString *)token type:(NSString *)type typeId:(NSString *)typeId text:(NSString *)text limit:(NSString *)limit
{
    NSLog(@"");
    NSLog(@"insertMessageBoard");
    
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject: uid forKey: @"id"];
    [dic setObject: token forKey: @"token"];
    [dic setObject: type forKey: @"type"];
    [dic setObject: typeId forKey: @"type_id"];
    [dic setObject: text forKey: @"text"];
    [dic setObject:limit forKey:@"limit"];
    
    returnStr = [self boxAPI: dic URL: @"/insertmessageboard/1.3"];
    
    return returnStr;
}

#pragma mark - Like
+ (NSString *)insertAlbum2Likes: (NSString *)uid token:(NSString *)token albumId:(NSString *)albumId
{
    NSLog(@"");
    NSLog(@"insertAlbum2Likes");
    
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject: uid forKey: @"id"];
    [dic setObject: token forKey: @"token"];
    [dic setObject: albumId forKey: @"album_id"];
    
    returnStr = [self boxAPI: dic URL: @"/insertalbum2likes/1.3"];
    
    return returnStr;
}

+ (NSString *)deleteAlbum2Likes:(NSString *)uid token:(NSString *)token albumId:(NSString *)albumId
{
    NSLog(@"");
    NSLog(@"deleteAlbum2Likes");
    
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject: uid forKey: @"id"];
    [dic setObject: token forKey: @"token"];
    [dic setObject: albumId forKey: @"album_id"];
    
    returnStr = [self boxAPI: dic URL: @"/deletealbum2likes/1.3"];
    
    return returnStr;
}

#pragma mark - Refresh Token
+ (NSString *)refreshToken:(NSString *)userId
{
    NSLog(@"");
    NSLog(@"refreshToken");
    
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject: userId forKey: @"user_id"];
    
    returnStr = [self boxAPI: dic URL: @"/refreshtoken/2.0"];
    
    return returnStr;
}

#pragma mark - BuisnessSubUserFastRegister
+ (NSString *)buisnessSubUserFastRegister:(NSString *)businessUserId
                                     fbId:(NSString *)fbId
                                timeStamp:(NSString *)timeStamp
                                    param:(NSString *)param;
{
    NSLog(@"");
    NSLog(@"buisnessSubUserFastRegister");
    
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject: businessUserId forKey: @"businessuser_id"];
    [dic setObject: fbId forKey: @"facebook_id"];
    [dic setObject: timeStamp forKey: @"timestamp"];
    
    NSMutableDictionary *wData = [NSMutableDictionary new];
    
    for (NSString *key in dic.allKeys) {
        if ([dic[key] isKindOfClass: [NSString class]]) {
            [wData setObject: dic[key] forKey: key];
        } else {
            [wData setObject: [dic[key] stringValue] forKey: key];
        }
    }
    [dic setObject: [self signGenerator2: dic] forKey: @"sign"];
    
    [dic setObject: param forKey: @"param"];
    
    
    
    returnStr = [self api_Wine: @"/businesssubuserfastregister/2.0" dic: dic];
    
    return returnStr;
}

#pragma mark - Vote
+ (NSString *)getEventVoteList:(NSString *)eventId
                         limit:(NSString *)limit
                         token:(NSString *)token
                        userId:(NSString *)userId;
{
    NSLog(@"");
    NSLog(@"getEventVoteList");
    
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject: eventId forKey: @"event_id"];
    [dic setObject: limit forKey: @"limit"];
    [dic setObject: token forKey: @"token"];
    [dic setObject: userId forKey: @"user_id"];
    
    returnStr = [self boxAPI: dic URL: @"/geteventvotelist/2.0"];
    
    return returnStr;
}

+ (NSString *)vote:(NSString *)albumId
           eventId:(NSString *)eventId
             token:(NSString *)token
            userId:(NSString *)userId
{
    NSLog(@"");
    NSLog(@"vote");
    
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject: albumId forKey: @"album_id"];
    [dic setObject: eventId forKey: @"event_id"];
    [dic setObject: token forKey: @"token"];
    [dic setObject: userId forKey: @"user_id"];
    
    returnStr = [self boxAPI: dic URL: @"/vote/2.0"];
    
    return returnStr;
}

// 101
#pragma mark - Set User Cover
#pragma mark  updataimage
+ (NSString *)setUserCover:(UIImage *)image
                     token:(NSString *)token
                    userId:(NSString *)userId
{
    NSLog(@"");
    NSLog(@"setUserCover");
    NSLog(@"userId: %@", userId);
    
    // Dictionary that holds post parameters. You can set your post parameters that your server accepts or programmed to accept.
    NSMutableDictionary *_params = [[NSMutableDictionary alloc] init];
    [_params setObject: userId forKey:@"user_id"];
    [_params setObject: token forKey:@"token"];
    [_params setObject: [self signGenerator2:_params] forKey:@"sign"];
    
    // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
    NSString *BoundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";
    
    // string constant for the post parameter 'file'. My server uses this name: `file`. Your's may differ
    NSString* FileParamConstant = @"file";
    
    // the server url to which the image (or the media) is uploaded. Use your server url here
    NSURL* requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",ServerURL,@"/setusercover",@"/2.0"]];
    
    // create request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];//[[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval: [kTimeOut floatValue]];
    [request setHTTPMethod:@"POST"];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    NSLog(@"_params: %@", _params);
    
    // add params (all params are strings)
    for (NSString *param in _params) {
        NSLog(@"");
        NSLog(@"param: %@", param);
        
        // start tag
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        
        // end tag
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add image data
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    
    if (imageData) {
        // start tag
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        
        // end tag
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // close form
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set HTTP_ACCEPT_LANGUAGE in HTTP Header
    [request setValue: @"zh-TW,zh" forHTTPHeaderField: @"HTTP_ACCEPT_LANGUAGE"];
    
    // set URL
    [request setURL:requestURL];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSString *str;
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = 60;
    config.timeoutIntervalForResource = 60;
    NSURLSession *session = [NSURLSession sessionWithConfiguration: config];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest: request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSLog(@"setusercover");
        
        if (error == nil) {
            str = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
            NSLog(@"str: %@", str);
        } else {
            str = [NSString stringWithFormat: @"%ld", (long)error.code];
            NSLog(@"error: %@", error);
            NSLog(@"error.userInfo: %@", error.userInfo);
            NSLog(@"error.localizedDescription: %@", error.localizedDescription);
            NSLog(@"error code: %@", [NSString stringWithFormat: @"%ld", (long)error.code]);
        }
        
        /*
         if (data) {
         str = [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding];
         
         NSLog(@"str: %@", str);
         } else {
         NSLog(@"error :%@", error);
         }
         */
        dispatch_semaphore_signal(semaphore);
    }];
    NSLog(@"task resume");
    [task resume];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return str;
}

#pragma mark - Get Category Area
+ (NSString *)getCategoryArea:(NSString *)categoryAreaId
                        token:(NSString *)token
                       userId:(NSString *)userId
{
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject: categoryAreaId forKey: @"categoryarea_id"];
    [dic setObject: token forKey: @"token"];
    [dic setObject: userId forKey: @"user_id"];
    
    returnStr = [self boxAPI: dic URL: @"/getcategoryarea/2.1"];
    
    return returnStr;
}

#pragma mark - Get The Me Area
+ (NSString *)getTheMeArea:(NSString *)token
                    userId:(NSString *)userId
{
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject: token forKey: @"token"];
    [dic setObject: userId forKey: @"user_id"];
    
    returnStr = [self boxAPI: dic URL: @"/getthemearea/2.1"];
    
    return returnStr;
}

#pragma mark - Get Sponsor List
// 104
+ (NSString *)getSponsorList:(NSString *)token
                      userId:(NSString *)userId
                       limit:(NSString *)limit {
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject: token forKey: @"token"];
    [dic setObject: userId forKey: @"user_id"];
    [dic setObject: limit forKey: @"limit"];
    
    returnStr = [self boxAPI: dic URL: @"/getsponsorlist/2.0"];
    
    return returnStr;
}

#pragma mark - Get Album2Likes List
// 105
+ (NSString *)getAlbum2LikesList:(NSString *)albumId
                           limit:(NSString *)limit
                           token:(NSString *)token
                          userId:(NSString *)userId {
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject: albumId forKey: @"album_id"];
    [dic setObject: limit forKey: @"limit"];
    [dic setObject: token forKey: @"token"];
    [dic setObject: userId forKey: @"user_id"];
    
    returnStr = [self boxAPI: dic URL: @"/getalbum2likeslist/2.0"];
    
    return returnStr;
}

#pragma mark - Gain Photo Use For User
+ (NSString *)gainPhotoUseForUser:(NSString *)param
                photoUseForUserId:(NSString *)photoUseForUserId
                            token:(NSString *)token
                           userId:(NSString *)userId
{
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject: param forKey:@"param"];
    [dic setObject: photoUseForUserId forKey: @"photousefor_user_id"];
    [dic setObject: token forKey: @"token"];
    [dic setObject: userId forKey: @"user_id"];
    
    returnStr = [self boxAPI: dic URL: @"/gainphotousefor_user/2.0"];
    
    return returnStr;
}

#pragma mark - Get Bookmark List
+ (NSString *)getBookmarkList:(NSString *)token
                       userId:(NSString *)userId
{
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject: token forKey: @"token"];
    [dic setObject: userId forKey: @"user_id"];
    
    returnStr = [self boxAPI: dic URL: @"/getbookmarklist/2.0"];
    
    return returnStr;
}

#pragma mark - Get Photo Use For
//108
+ (NSString *)getPhotoUseFor:(NSString *)photoId
                       token:(NSString *)token
                      userId:(NSString *)userId
{
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject: photoId forKey: @"photo_id"];
    [dic setObject: token forKey: @"token"];
    [dic setObject: userId forKey: @"user_id"];
    
    returnStr = [self boxAPI: dic URL: @"/getphotousefor/2.0"];
    
    return returnStr;
}

// 109
#pragma mark - Insert Bookmark
+ (NSString *)insertBookmark:(NSString *)photoId
                       token:(NSString *)token
                      userId:(NSString *)userId
{
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject: photoId forKey: @"photo_id"];
    [dic setObject: token forKey: @"token"];
    [dic setObject: userId forKey: @"user_id"];
    
    returnStr = [self boxAPI: dic URL: @"/insertbookmark/2.0"];
    
    return returnStr;
}

#pragma mark - Exchange Photo
// 110
+ (NSString *)exchangePhotoUseFor:(NSString *)identifier
                          photoId:(NSString *)photoId
                            token:(NSString *)token
                           userId:(NSString *)userId
{
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject: identifier forKey: @"identifier"];
    [dic setObject: photoId forKey: @"photo_id"];
    [dic setObject: token forKey: @"token"];
    [dic setObject: userId forKey: @"user_id"];
    
    returnStr = [self boxAPI: dic URL: @"/exchangephotousefor/2.0"];
    
    return returnStr;
}

// 111
+ (NSString *)slotPhotoUseFor:(NSString *)identifier
                      photoId:(NSString *)photoId
                        token:(NSString *)token
                       userId:(NSString *)userId
{
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject: identifier forKey: @"identifier"];
    [dic setObject: photoId forKey: @"photo_id"];
    [dic setObject: token forKey: @"token"];
    [dic setObject: userId forKey: @"user_id"];
    
    returnStr = [self boxAPI: dic URL: @"/slotphotousefor/2.0"];
    
    return returnStr;
}

// 113
+ (NSString *)getFollowFromList:(NSString *)token
                         userId:(NSString *)userId
                          limit:(NSString *)limit {
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject: token forKey: @"token"];
    [dic setObject: userId forKey: @"user_id"];
    [dic setObject: limit forKey: @"limit"];
    
    returnStr = [self boxAPI: dic URL: @"/getfollowfromlist/2.0"];
    
    return returnStr;
}

#pragma mark - Get AlbumSponsor List
// 114
+ (NSString *)getAlbumSponsorList:(NSString *)albumId
                            limit:(NSString *)limit
                            token:(NSString *)token
                           userId:(NSString *)userId {
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject: albumId forKey: @"album_id"];
    [dic setObject: limit forKey: @"limit"];
    [dic setObject: token forKey: @"token"];
    [dic setObject: userId forKey: @"user_id"];
    
    returnStr = [self boxAPI: dic URL: @"/getalbumsponsorlist/2.1"];
    
    return returnStr;
}
#pragma mark - 取得熱門清單
//  115
+ (NSString *)getHotList:(NSString *)limit
                   token:(NSString *)token
                  userId:(NSString *)userId {
    
    NSString *returnStr = @"";
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject: limit forKey: @"limit"];
    [dic setObject: token forKey: @"token"];
    [dic setObject: userId forKey: @"user_id"];
    
    returnStr = [self boxAPI: dic URL: @"/gethotlist/2.0"];
    
    return returnStr;
    
}
#pragma mark - Get Newly joined (Hometab)
//  116
+ (NSString *)getNewJoinList:(NSString *)limit
                       token:(NSString *)token
                      userId:(NSString *)userId {
    
    NSString *returnStr = @"";
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject: limit forKey: @"limit"];
    [dic setObject: token forKey: @"token"];
    [dic setObject: userId forKey: @"user_id"];
    
    returnStr = [self boxAPI: dic URL: @"/getnewjoinlist/2.0"];
    
    return returnStr;
}
#pragma mark - albumindex
// 96
+ (NSString *)insertalbumindex:(NSString *)uid
                         token:(NSString *)token
                      album_id:(NSString *)album_id
                         index:(NSString *)index {
    
    NSString *returnStr = @"";
    NSDictionary *dic = @{@"album_id":album_id,
                          @"index":index,//[NSNumber numberWithInt:index],
                          @"user_id":uid,
                          @"token":token};
    returnStr = [self boxAPI: dic URL: @"/insertalbumindex/2.0"];
    
    return returnStr;
}

+ (NSString *)deletealbumindex:(NSString *)uid
                         token:(NSString *)token
                      album_id:(NSString *)album_id
                         index:(NSString *)index {
    NSString *returnStr = @"";
    NSDictionary *dic = @{@"album_id":album_id,
                          @"index":index,//[NSNumber numberWithInt:index],
                          @"user_id":uid,
                          @"token":token};
    returnStr = [self boxAPI: dic URL: @"/deletealbumindex/2.0"];
    
    return returnStr;
}
#pragma mark - 檢測網路
+(BOOL)hostAvailable:(NSString *)theHost
{
    NSLog(@"");
    NSLog(@"hostAvailable");
    
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithName(CFAllocatorGetDefault(), [theHost UTF8String]);
    SCNetworkReachabilityFlags flags;
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags)
    {
        NSLog(@"Error. Could not recover network reachability flags\n");
        return NO;
    }
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    return isReachable ? YES : NO;
}

#pragma mark  updataimage
+ (NSString *)updateProfilePic:(NSString *)userId
                         token:(NSString *)token
                         image:(UIImage *)image
{
    NSLog(@"");
    NSLog(@"updateProfilePic");
    
    // Dictionary that holds post parameters. You can set your post parameters that your server accepts or programmed to accept.
    NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
    [_params setObject: userId forKey:@"id"];
    [_params setObject: token forKey:@"token"];
    [_params setObject: [self signGenerator2:_params] forKey:@"sign"];
    
    // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
    NSString *BoundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";
    
    // string constant for the post parameter 'file'. My server uses this name: `file`. Your's may differ
    NSString* FileParamConstant = @"file";
    
    // the server url to which the image (or the media) is uploaded. Use your server url here
    NSURL* requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",ServerURL,@"/updateprofilepic",@"/1.0"]];
    
    // create request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];//[[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval: [kTimeOut floatValue]];
    [request setHTTPMethod:@"POST"];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in _params) {
        NSLog(@"");
        NSLog(@"param: %@", param);
        
        // start tag
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        
        // end tag
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add image data
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    
    if (imageData) {
        // start tag
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        
        // end tag
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // close form
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    // set HTTP_ACCEPT_LANGUAGE in HTTP Header
    [request setValue: @"zh-TW,zh" forHTTPHeaderField: @"HTTP_ACCEPT_LANGUAGE"];
    
    // set URL
    [request setURL:requestURL];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSString *str;
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = [kTimeOut floatValue];
    config.timeoutIntervalForResource = [kTimeOut floatValue];
    NSURLSession *session = [NSURLSession sessionWithConfiguration: config];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest: request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"updateProfilePic");
        
        if (error == nil) {
            str = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
            NSLog(@"str: %@", str);
        } else {
            NSLog(@"error: %@", error);
            NSLog(@"error.userInfo: %@", error.userInfo);
            NSLog(@"error.localizedDescription: %@", error.localizedDescription);
            NSLog(@"error code: %@", [NSString stringWithFormat: @"%ld", (long)error.code]);
        }
        
        /*
        if (data) {
            str = [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding];
            
            NSLog(@"str: %@", str);
        } else {
            NSLog(@"error :%@", error);
        }
        */
        dispatch_semaphore_signal(semaphore);
    }];
    NSLog(@"task resume");
    [task resume];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return str;
}

//更新大頭貼
-(void)boxIMGAPI:(NSDictionary *)wData
             URL:(NSString *)urls
           image:(UIImage *)image
            done:(void(^)(NSDictionary *responseData)) doneHandler
            fail:(void(^)(NSInteger status)) failHandler
{
    NSLog(@"");
    NSLog(@"boxIMGAPI");
    
    if (![boxAPI hostAvailable:hostURL]) {
        failHandler(-1);
        return ;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ServerURL,urls]];
    NSData *imageData = [[NSData alloc] initWithData:UIImageJPEGRepresentation(image, 1.0)];
    
    NSMutableDictionary* texts = [NSMutableDictionary dictionary];
    NSMutableDictionary* images = [NSMutableDictionary dictionary];
    
    for (NSString * key in wData.allKeys) {
        if ([wData[key] isKindOfClass:[NSString class]]) {
             [texts setObject:wData[key] forKey:key];
        }else{
        [texts setObject:[wData[key] stringValue] forKey:key];
        }
    }
    
    [texts setObject:[boxAPI signGenerator2:texts] forKey:@"sign"];
    [images setObject:imageData forKey:@"file"];//複数ある場合はこれを追加
    
    requestDoneHandler = doneHandler;
    requestFailHandler = failHandler;
    
    ReqHTTP *reqHTTP = [[ReqHTTP alloc] init];
    [reqHTTP postMultiDataWithTextDictionary:texts
                             imageDictionary:images
                                         url:url
                                        done:^(NSDictionary *responseData) {
                                            if (doneHandler) {
                                                doneHandler(responseData);
                                            }
                                            
//                                            NSInteger status = [[responseData objectForKey:@"status"] integerValue];
//                                            if (status < 0) {
//                                                NSLog(@"画像のUploadに失敗");
//                                                return;
//                                            }
//                                            //成功
//                                            NSLog(@"success %@", responseData);
                                            
                                        } fail:^(NSInteger status) {
                                            if (failHandler) {
                                                 failHandler(-1);
                                            }
                                            //NSLog(@"画像のUploadに失敗");
                                        }];
}

+ (NSString *)signGenerator2:(NSDictionary *)parameters {
    NSLog(@"signGenerator2");
    
    NSString *secrectSN = @"d9$kv3fk(ri3mv#d-kg05[vs)F;f2lg/";
    NSString *signSN = @"";
    NSArray *keys = [parameters allKeys];
    
    keys = [keys sortedArrayUsingComparator: ^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare: obj2 options: NSNumericSearch];
    }];
    
//    NSCharacterSet *URLCombinedCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"\"#%/:<>?@[\\]^`{|},="] invertedSet];
    //:/?@!$&'()*+,;=
    
    NSString *requestOriginal = @"";
    
    for (int i = 0 ;i < keys.count ;i++) {
        //NSLog(@"i: %d", i);
        //NSLog(@"keys.count: %lu", (unsigned long)keys.count);
        
        NSString *key = keys[i];
        NSString *value = parameters[key];
        // requestOriginal=[NSString stringWithFormat:@"%@%@=%@",requestOriginal,key,[value stringByAddingPercentEncodingWithAllowedCharacters:URLCombinedCharacterSet]];
        
        requestOriginal = [NSString stringWithFormat:@"%@%@=%@", requestOriginal, key, value];
        //NSLog(@"requestOriginal: %@", requestOriginal);
        
        if (i < keys.count - 1) {
            //NSLog(@"i < keys.count - 1");
            requestOriginal = [NSString stringWithFormat:@"%@&", requestOriginal];
            //NSLog(@"requestOriginal: %@", requestOriginal);
        }
    }
    //requestOriginal=[requestOriginal stringByReplacingOccurrencesOfString:@"%@20" withString:@"+"];
    
    //NSLog(@"requestOriginal lowercaseString");
    NSString *requestLow = [requestOriginal lowercaseString];
    //NSLog(@"%@",requestLow);
    
    //NSLog(@"requestLow,secrectSN");
    requestLow = [NSString stringWithFormat:@"%@%@",requestLow,secrectSN];
    //NSLog(@"%@",requestLow);
    
    //NSLog(@"requestLow.MD5");
    requestLow = requestLow.MD5;
    //NSLog(@"%@",requestLow);
    
    //NSLog(@"requestLow.lowercaseString");
    requestLow = requestLow.lowercaseString;
    //NSLog(@"%@",requestLow);
    
    signSN = requestLow;
    //NSLog(@"signSN: %@", signSN);
    
    return signSN;
}

#pragma mark -
#pragma mark  調用所有API
+(NSString *)boxAPI:(NSDictionary *)wData URL:(NSString *)url {
    NSLog(@"boxAPI wData URL");
    
    //NSLog(@"wData: %@", wData);
    
    NSString *returnstr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    for (NSString *kye in wData.allKeys) {
        if ([wData[kye] isKindOfClass:[NSString class]]) {
            [dic setObject:wData[kye] forKey:kye];
            
            /*
             NSLog(@"isKindOfClass: [NSString class]");
             NSLog(@"kye: %@", kye);
             NSLog(@"wData[kye]: %@", wData[kye]);
             
             */
        } else {
            [dic setObject:[wData[kye] stringValue] forKey:kye];
            
            /*
             NSLog(@"is not KindOfClass: [NSString class]");
             NSLog(@"kye: %@", kye);
             NSLog(@"wData[kye]: %@", wData[kye]);
             
             */
        }
    }
    
    // Get the value of key "sign"
    [dic setObject: [self signGenerator2:dic] forKey: @"sign"];
    
    //NSLog(@"sign: %@", [self signGenerator2:dic]);
    //
    
    // Create NSMutableURLRequest, post data to server for getting response
    returnstr = [self api_Wine: url dic: dic];
    
    return returnstr;
}

+(NSString *)boxAPIWithoutSign:(NSDictionary *)wData URL:(NSString *)url {
    NSLog(@"boxAPIWithoutSign");
    
    //NSLog(@"wData: %@", wData);
    
    NSString *returnstr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    for (NSString *kye in wData.allKeys) {
        if ([wData[kye] isKindOfClass:[NSString class]]) {
            [dic setObject:wData[kye] forKey:kye];
        } else {
            [dic setObject:[wData[kye] stringValue] forKey:kye];
        }
    }
    
    // Create NSMutableURLRequest, post data to server for getting response
    returnstr = [self api_Wine: url dic: dic];
    
    return returnstr;
}

+(NSString *)boxAPIForGettingPoint:(NSDictionary *)wData URL:(NSString *)url {
    NSLog(@"boxAPIForGettingPoint");
    
    NSString *returnstr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    NSMutableDictionary *dicWithoutTypeData = [NSMutableDictionary new];
    
    for (NSString *kye in wData.allKeys) {
        if ([wData[kye] isKindOfClass:[NSString class]]) {
            [dic setObject:wData[kye] forKey:kye];
            
            /*
             NSLog(@"isKindOfClass: [NSString class]");
             NSLog(@"kye: %@", kye);
             NSLog(@"wData[kye]: %@", wData[kye]);
             
             */
            
        } else {
            [dic setObject:[wData[kye]stringValue]  forKey:kye];
            
            /*
             NSLog(@"is not KindOfClass: [NSString class]");
             NSLog(@"kye: %@", kye);
             NSLog(@"wData[kye]: %@", wData[kye]);
             
             */
        }
    }
    
    dicWithoutTypeData = [dic mutableCopy];
    [dicWithoutTypeData removeObjectForKey: @"type"];
    [dicWithoutTypeData removeObjectForKey: @"type_id"];
    NSLog(@"dicWithoutTypeData: %@", dicWithoutTypeData);
    
    [dic setObject: [self signGenerator2: dicWithoutTypeData] forKey: @"sign"];
    
    NSLog(@"sign: %@", [self signGenerator2:dic]);
    
    
    returnstr = [self api_Wine: url dic: dic];
    
    return returnstr;
}

+(NSString *)api_Wine:(NSString *)url dic:(NSMutableDictionary *)dic{
    NSLog(@"api_wine url dic");
    
    if (![self hostAvailable:hostURL]) {
        NSLog(@"");
        NSLog(@"");
        NSLog(@"網路不通");
        NSLog(@"");
        NSLog(@"");
        
        return nil;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ServerURL, url]]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[self httpBodyForParamsDictionary:dic]];
    [request setValue: @"zh-TW,zh" forHTTPHeaderField: @"HTTP_ACCEPT_LANGUAGE"];
    [request setTimeoutInterval: [kTimeOut floatValue]];
    NSLog(@"request.timeoutInterval: %f", request.timeoutInterval);
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSString *str;
    
    /*
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = [kTimeOut floatValue];
    NSLog(@"config.timeoutIntervalForRequest: %f", config.timeoutIntervalForRequest);
    
    config.timeoutIntervalForResource = [kTimeOut floatValue];
    NSLog(@"config.timeoutIntervalForResource: %f", config.timeoutIntervalForResource);
    */
    
    //NSURLSession *session = [NSURLSession sessionWithConfiguration: config];
    NSURLSession *session = [NSURLSession sharedSession];
    NSLog(@"dataTaskWithRequest");
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest: request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error == nil) {
            str = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
            
            NSLog(@"");
            //NSLog(@"str = %@", str);
            
            //[[NSURLSession sharedSession] finishTasksAndInvalidate];
        } else {
            str = [NSString stringWithFormat: @"%ld", (long)error.code];
            
            NSLog(@"");
            NSLog(@"error: %@", error);
            NSLog(@"error.userInfo: %@", error.userInfo);
            NSLog(@"error.localizedDescription: %@", error.localizedDescription);
            NSLog(@"error code: %@", [NSString stringWithFormat: @"%ld", (long)error.code]);
            
            // [[NSURLSession sharedSession] invalidateAndCancel];
        }        
        dispatch_semaphore_signal(semaphore);
    }];
    [task resume];
    NSLog(@"task resume");
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"After dispatch_semaphore_wait");
    
    return str;
}

//GET
+(NSString *)api_GET:(NSString *)url{
    NSLog(@"Call api_Get");
    
    if (![self hostAvailable:hostURL]) {
        NSLog(@"網路不通");
        return nil;
    }
    
    //NSString* webStringURL = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *webStringURL = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *surl=[NSURL URLWithString:webStringURL];
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:surl];
    [request setHTTPMethod:@"GET"];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __block NSString *str;
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest: request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSLog(@"get data from calling api_GET");
        
        if (data) {
            str = [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding];
            NSLog(@"str: %@", str);
        } else {
            NSLog(@"error :%@", error);
        }
        
        dispatch_semaphore_signal(semaphore);
    }];
    [task resume];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return str;
}

+(NSData *)httpBodyForParamsDictionary:(NSDictionary *)paramDictionary
{
    //NSLog(@"httpBodyForParamsDictionary");
    
    NSMutableArray *parameterArray = [NSMutableArray array];
    
    [paramDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        /*
         NSLog(@"enumerateKeysAndObjectsUsingBlock");
         NSLog(@"key: %@", key);
         NSLog(@"obj: %@", obj);
         */
        NSString *param = [NSString stringWithFormat:@"%@=%@", key, [self percentEscapeString:obj]];
        //NSLog(@"param: %@", param);
        [parameterArray addObject:param];
        //NSLog(@"parameterArray: %@", parameterArray);
    }];
    
    //NSLog(@"parameterArray: %@", parameterArray);
    
    NSString *string = [parameterArray componentsJoinedByString:@"&"];
    
    //NSLog(@"after componentsJoinedByString &: %@", string);
    
    //NSLog(@"string dataUsingEncoding:NSUTF8StringEncoding: %@", [string dataUsingEncoding:NSUTF8StringEncoding]);
    
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}
+ (NSString *)encodingByAddingPercentage:(NSString *)str {
    NSMutableCharacterSet *charset = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [charset removeCharactersInString:@"/?@!$&'()*+,;="];
    NSString *result = [str stringByAddingPercentEncodingWithAllowedCharacters:charset];
    return result;
}
+ (NSString *)percentEscapeString:(NSString *)string
{
    //NSLog(@"percentEscapeString");
    //NSLog(@"string: %@", string);

    NSString *result = [boxAPI encodingByAddingPercentage:string];//[string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
//    NSString *result = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
//                                                                                 (CFStringRef)string,
//                                                                                 (CFStringRef)@" ",
//                                                                                 (CFStringRef)@":/?@!$&'()*+,;=",
//                                                                                 kCFStringEncodingUTF8));

    //NSLog(@"result: %@", result);
    
    //NSLog(@"result stringByReplacingOccurrencesOfString withString: %@", [result stringByReplacingOccurrencesOfString:@" " withString:@"+"]);
    
    return [result stringByReplacingOccurrencesOfString:@" " withString:@"+"];
}
+ (void)getAlbumDiyWithAlbumId:(NSString *)albumid completionBlock:(void(^)(NSDictionary *result, NSError *error))completionBlock{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *response = [boxAPI getalbumofdiy: [UserInfo getUserID]
                                                token: [UserInfo getUserToken]
                                             album_id: albumid];
        if (response != nil) {
            if ([response isEqualToString: timeOutErrorCode]) {
                if (completionBlock)
                    completionBlock(nil, [NSError errorWithDomain:@"getAlbumDiyWithAlbumId" code:9000 userInfo:@{NSLocalizedDescriptionKey:response}]) ;
            } else {
                //NSLog(@"Get Real Response");
                NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                if ([dic[@"result"] intValue] == 1) {
                    if (completionBlock)
                        completionBlock(dic,nil);
                } else if ([dic[@"result"] intValue] == 0) {
                    NSLog(@"失敗：%@",dic[@"message"]);
                    if (completionBlock)
                        completionBlock(nil, [NSError errorWithDomain:@"getAlbumDiyWithAlbumId" code:9001 userInfo:@{NSLocalizedDescriptionKey:dic[@"message"]}]) ;
                } else {
                    if (completionBlock)
                        completionBlock(nil, [NSError errorWithDomain:@"getAlbumDiyWithAlbumId" code:9001 userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"Host-NotAvailable", @"")}]) ;
                }
            }
        } else {
            if (completionBlock)
                completionBlock(nil, [NSError errorWithDomain:@"getAlbumDiyWithAlbumId" code:9000 userInfo:@{NSLocalizedDescriptionKey:timeOutErrorCode}]) ;
        }
    });
        
}
+ (void)getAlbumSettingsWithAlbumId:(NSString *)albumid completionBlock:(void(^)(NSDictionary *settings, NSError *error))completionBlock  {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *response = [boxAPI getalbumsettings: [UserInfo getUserID]
                                                token: [UserInfo getUserToken]
                                             album_id: albumid];
        if (response != nil) {
            if ([response isEqualToString: timeOutErrorCode]) {
                if (completionBlock)
                    completionBlock(nil, [NSError errorWithDomain:@"getAlbumSettingsWithAlbumId" code:9000 userInfo:@{NSLocalizedDescriptionKey:response}]) ;
            } else {
                NSLog(@"Get Real Response");
                NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                NSString *res = (NSString *)dic[@"result"];
                if ([res isEqualToString:@"SYSTEM_OK"]) {
                    if (completionBlock)
                        completionBlock(dic,nil);
                } else if (dic[@"message"]) {//[dic[@"result"] intValue] == 0) {
                    NSLog(@"失敗：%@",dic[@"message"]);
                    if (completionBlock)
                        completionBlock(nil, [NSError errorWithDomain:@"getAlbumSettingsWithAlbumId" code:9000 userInfo:@{NSLocalizedDescriptionKey:dic[@"message"]}]) ;
                } else {
                    if (completionBlock)
                        completionBlock(nil, [NSError errorWithDomain:@"getAlbumSettingsWithAlbumId" code:9000 userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"Host-NotAvailable", @"")}]) ;
                }
            }
        } else {
            if (completionBlock)
                completionBlock(nil, [NSError errorWithDomain:@"getAlbumSettingsWithAlbumId" code:9000 userInfo:@{NSLocalizedDescriptionKey:timeOutErrorCode}]) ;
        }
    });
}

+ (void)setAlbumSettingsWithDictionary:(NSString *)settingString albumid:(NSString *)albumid
                       completionBlock:(void(^)(NSDictionary *result, NSError *error))completionBlock {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *response = [boxAPI albumsettings:[UserInfo getUserID] token:[UserInfo getUserToken] album_id:albumid settings:settingString];
        
        if (response != nil) {
            if ([response isEqualToString: timeOutErrorCode]) {
                if (completionBlock)
                    completionBlock(nil, [NSError errorWithDomain:@"setAlbumSettings" code:9000 userInfo:@{NSLocalizedDescriptionKey:response}]) ;
            } else {
                NSLog(@"Get Real Response");
                NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                if ([dic[@"result"] isEqualToString: @"SYSTEM_OK"]) {
                    if (completionBlock)
                        completionBlock(dic,nil);
                } else if ([dic[@"result"] isEqualToString: @"SYSTEM_ERROR"]) {
                    if (completionBlock)
                        completionBlock(nil, [NSError errorWithDomain:@"setAlbumSettings" code:9000 userInfo:@{NSLocalizedDescriptionKey:dic[@"message"]}]) ;
                } else if ([dic[@"result"] isEqualToString:@"TOKEN_ERROR"] ) {
                    if (completionBlock)
                        completionBlock(nil, [NSError errorWithDomain:@"setAlbumSettings" code:1111 userInfo:nil]) ;
                }
                    

            }
        } else {
            if (completionBlock)
                completionBlock(nil, [NSError errorWithDomain:@"setAlbumSettings" code:9000 userInfo:@{NSLocalizedDescriptionKey:timeOutErrorCode}]) ;
        }
    });
}

#pragma mark - upload album music
+ (void)uploadMusicWithAlbumSettings:(NSDictionary *)audioSetting audioUrl:(NSURL *)audioUrl sessionDelegate:(id<NSURLSessionDelegate>)sessionDelegate completionBlock:(void(^)(NSDictionary *result, NSError *error))completionBlock {
    
    NSData *vidData = [NSData dataWithContentsOfURL:audioUrl];
    NSString *audiofile = [audioUrl lastPathComponent];
    
    NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
    [_params addEntriesFromDictionary:audioSetting];
    [_params setObject:[boxAPI signGenerator2:_params] forKey:@"sign"];
    
    // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
    NSString *BoundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";
    
    // string constant for the post parameter 'file'. My server uses this name: `file`. Your's may differ
    NSString* FileParamConstant = @"file";
    
    // the server url to which the image (or the media) is uploaded. Use your server url here
    NSURL* requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",ServerURL,@"/updatealbumsettings",@"/2.0"]];
    
    // create request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];//[[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval: [kTimeOutForVideo floatValue]];
    [request setHTTPMethod:@"POST"];
    
    MultipartInputStream *st = [[MultipartInputStream alloc] initWithBoundary:BoundaryConstant];
    
    for (NSString *e in [_params allKeys]) {
        NSString *d = _params[e];
        [st addPartWithName:e string:d];
    }
    if (vidData && vidData.length > 0) {
        
        
        CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[audiofile pathExtension], NULL);
        CFStringRef mimeType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
        CFRelease(UTI);
        NSString *type = @"application/octet-stream";
        if (mimeType) {
            type = (__bridge NSString *)mimeType;
        }
        [st addPartWithName:FileParamConstant filename:audiofile data:vidData contentType:type];
    }
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    
    [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)st.totalLength] forHTTPHeaderField:@"Content-Length"];
    // set HTTP_ACCEPT_LANGUAGE in HTTP Header
    [request setValue: @"zh-TW,zh" forHTTPHeaderField: @"HTTP_ACCEPT_LANGUAGE"];
    
    [request setHTTPBodyStream:st];
    
    __block NSString *str;
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = [kTimeOutForVideo floatValue];
    NSURLSession *session = [NSURLSession sessionWithConfiguration: config delegate:sessionDelegate delegateQueue:nil];
    
    //__block NSString *desc = [[NSUUID UUID] UUIDString];
    NSURLSessionDataTask *task = [session dataTaskWithRequest: request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[wself.vidHud hideAnimated:YES];
        });
        
        if (data) {
            
            str = [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding];
            NSLog(@"str: %@", str);
            //  time out
            if (str && [str isEqualToString:timeOutErrorCode]) {
                if (completionBlock)
                    completionBlock(nil, [NSError errorWithDomain:@"" code:-1001 userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"Connection-Timeout", @"")}]);
                
            } else {
                NSDictionary *dict = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: nil];
                if (dict != nil) {
                    if ([dict[@"result"] isEqualToString:@"SYSTEM_OK"]) {
                        if (completionBlock)
                            completionBlock(dict,nil);
                    } else {
                        
                        if (dict[@"message"] == nil) {
                            if (completionBlock)
                                completionBlock(nil, [NSError errorWithDomain:@"" code:-1001 userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"Connection-Timeout", @"")}]);
                            
                        } else {
                            if (completionBlock)
                                completionBlock(nil, [NSError errorWithDomain:@"" code:-1002 userInfo:@{NSLocalizedDescriptionKey:dict[@"message"] }]);
                            
                        }
                    
                    }
                } else if (str != nil ) {
                    if (completionBlock)
                        completionBlock(nil, [NSError errorWithDomain:@"" code:-1003 userInfo:@{NSLocalizedDescriptionKey:str }]);
                }
            }
        } else {
            if (completionBlock)
                completionBlock(nil, error);
            
        }
        
    }];
    
    [task resume];
}
@end
