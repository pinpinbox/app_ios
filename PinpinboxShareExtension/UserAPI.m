//
//  UserAPI.m
//  PinpinboxShareExtension
//
//  Created by Antelis on 2018/12/14.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "UserAPI.h"
#import "UserInfo.h"
#import "NSString+MD5.h"
#import  <SystemConfiguration/SCNetworkReachability.h>
#import "GlobalVars.h"
#import "MultipartInputStream.h"

@implementation UserAPI

#pragma mark - for Share extension
#pragma mark  調用所有API
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

+ (NSString *)signGenerator2:(NSDictionary *)parameters {
    NSLog(@"signGenerator2");
    
    NSString *secrectSN = @"d9$kv3fk(ri3mv#d-kg05[vs)F;f2lg/";
    NSString *signSN = @"";
    NSArray *keys = [parameters allKeys];
    
    keys = [keys sortedArrayUsingComparator: ^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare: obj2 options: NSNumericSearch];
    }];
    
    NSString *requestOriginal = @"";
    
    for (int i = 0 ;i < keys.count ;i++) {
        NSString *key = keys[i];
        NSString *value = parameters[key];
        requestOriginal = [NSString stringWithFormat:@"%@%@=%@", requestOriginal, key, value];
        if (i < keys.count - 1) {
    
            requestOriginal = [NSString stringWithFormat:@"%@&", requestOriginal];
    
        }
    }
    NSString *requestLow = [requestOriginal lowercaseString];
    requestLow = [NSString stringWithFormat:@"%@%@",requestLow,secrectSN];
    requestLow = requestLow.MD5;
    requestLow = requestLow.lowercaseString;
    signSN = requestLow;
    
    return signSN;
}
+ (NSString *)percentEscapeString:(NSString *)string
{
    NSMutableCharacterSet *charset = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [charset removeCharactersInString:@"/?@!$&'()*+,;="];
    NSString *result = [string stringByAddingPercentEncodingWithAllowedCharacters:charset];
    
    return [result stringByReplacingOccurrencesOfString:@" " withString:@"+"];
}
+(NSData *)httpBodyForParamsDictionary:(NSDictionary *)paramDictionary
{
    NSMutableArray *parameterArray = [NSMutableArray array];
    
    [paramDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        NSString *param = [NSString stringWithFormat:@"%@=%@", key, [self percentEscapeString:obj]];
        [parameterArray addObject:param];
    }];
    NSString *string = [parameterArray componentsJoinedByString:@"&"];
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}
+(NSString *)api_Wine:(NSString *)url dic:(NSMutableDictionary *)dic{
    NSLog(@"api_wine url dic");
    
    if (![self hostAvailable:@"www.pinpinbox.com"]) {//hostURL]) {
        
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

+(NSString *)userAPI:(NSDictionary *)wData URL:(NSString *)url {
    NSLog(@"userAPI wData URL");
    
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


+ (NSString *)refreshToken:(NSString *)userId
{
    NSString *returnStr = @"";
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    [dic setObject: userId forKey: @"user_id"];
    
    returnStr = [self userAPI:dic URL: @"/refreshtoken/2.0"];
    
    return returnStr;
}

+(NSString *)getprofile:(NSString *)uid token:(NSString *)token {
    NSLog(@"");
    NSLog(@"getprofile");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    
    returnstr=[self userAPI:dic URL:@"/getprofile/1.1"];
    
    return returnstr;
}
+(NSString *)getcalbumlist:(NSString *)uid token:(NSString *)token rank:(NSString *)rank limit:(NSString *)limit{
    NSLog(@"");
    NSLog(@"getcalbumlist");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    
    [dic setObject:rank forKey:@"rank"];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    [dic setObject:limit forKey:@"limit"];
    
    returnstr=[self userAPI:dic URL:@"/getcalbumlist/1.3"];
    
    return returnstr;
}
+(NSString *)getalbumofdiy:(NSString *)uid token:(NSString *)token album_id:(NSString *)album_id{
    NSLog(@"");
    NSLog(@"getalbumofdiy");
    
    NSString *returnstr=@"";
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:uid forKey:@"id"];
    [dic setObject:token forKey:@"token"];
    [dic setObject:album_id forKey:@"album_id"];
    
    returnstr=[self userAPI:dic URL:@"/getalbumofdiy/1.1"];
    
    return returnstr;
}
+ (void)postPreCheck:(NSString *)album_id completionBlock:(void(^)(NSDictionary *result, NSError *error))completionBlock {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *response = [UserAPI getalbumofdiy:[UserInfo getUserID] token:[UserInfo getUserToken] album_id:album_id];
        
        if (response != nil) {
            if ([response isEqualToString: @"-1001"]) {
                if (completionBlock)
                    completionBlock(nil, [NSError errorWithDomain:@"postPreCheck" code:9000 userInfo:@{NSLocalizedDescriptionKey:response}]) ;
            } else {
                NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                int res = [dic[@"result"] intValue];
                if (res == 1) {
                    if (completionBlock)
                        completionBlock(dic[@"data"], nil);
                } else {
                    
                    if (completionBlock)
                        completionBlock(nil, [NSError errorWithDomain:@"postPreCheck" code:9000 userInfo:@{NSLocalizedDescriptionKey:dic[@"message"]}]) ;
                    
                }
                
            }
            
        } else {
            if (completionBlock)
                completionBlock(nil, [NSError errorWithDomain:@"postPreCheck" code:9000 userInfo:@{NSLocalizedDescriptionKey:timeOutErrorCode}]) ;
        }
    });
}
+ (void)refreshTokenWithCompletionBlock:(void(^)(NSDictionary *result, NSError *error))completionBlock {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *response = [UserAPI refreshToken:[UserInfo getUserID]];
        
        if (response != nil) {
            if ([response isEqualToString: @"-1001"]) {
                if (completionBlock)
                    completionBlock(nil, [NSError errorWithDomain:@"refreshToken" code:9000 userInfo:@{NSLocalizedDescriptionKey:response}]) ;
            } else {
                NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                NSString *res = dic[@"result"];
                if ([res isEqualToString:@"SYSTEM_OK"]) {
                        if (completionBlock)
                            completionBlock(dic[@"data"][@"token"],nil);
                } else {
                    
                        if (completionBlock)
                            completionBlock(nil, [NSError errorWithDomain:@"refreshToken" code:9000 userInfo:@{NSLocalizedDescriptionKey:dic[@"message"]}]) ;
                    
                }
                
            }
            
        } else {
            if (completionBlock)
                completionBlock(nil, [NSError errorWithDomain:@"refreshToken" code:9000 userInfo:@{NSLocalizedDescriptionKey:timeOutErrorCode}]) ;
        }
    });
}
+ (void)userProfileWithCompletionBlock:(void(^)(NSDictionary *result, NSError *error))completionBlock {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *response = [UserAPI getprofile:[UserInfo getUserID] token:[UserInfo getUserToken]];
        
        if (response != nil) {
            if ([response isEqualToString: @"-1001"]) {
                if (completionBlock)
                    completionBlock(nil, [NSError errorWithDomain:@"getprofile" code:9000 userInfo:@{NSLocalizedDescriptionKey:response}]) ;
            } else {
                NSLog(@"Get Real Response");
                NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                int res = [dic[@"result"] intValue];
                
                switch (res) {
                    case 1: {
                        if (completionBlock)
                            completionBlock(dic[@"data"],nil);
                    } break;
                    case 0: {
                        
                        if (completionBlock)
                            completionBlock(nil, [NSError errorWithDomain:@"getprofile" code:9000 userInfo:@{NSLocalizedDescriptionKey:dic[@"message"]}]) ;
                    }
                        break;
                }
                
            }
            
        } else {
            if (completionBlock)
                completionBlock(nil, [NSError errorWithDomain:@"getprofile" code:9000 userInfo:@{NSLocalizedDescriptionKey:timeOutErrorCode}]) ;
        }
    });
}
+ (void)loadAlbumListWithCompletionBlock:(NSInteger)curCount  completionBlock:(void(^)(NSDictionary *result, NSError *error))completionBlock {
    NSString *limit = [NSString stringWithFormat:@"%ld,20",(long)curCount];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *response = [UserAPI getcalbumlist:[UserInfo getUserID] token:[UserInfo getUserToken] rank:@"mine" limit:limit];
        
        if (response != nil) {
            if ([response isEqualToString: @"-1001"]) {
                if (completionBlock)
                    completionBlock(nil, [NSError errorWithDomain:@"getcalbumlist" code:9000 userInfo:@{NSLocalizedDescriptionKey:response}]) ;
            } else {
                
                NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                int res = [dic[@"result"] intValue];
                
                switch (res) {
                    case 1: {
                        if (completionBlock)
                            completionBlock(dic,nil);
                    } break;
                    case 0: {
                        
                        if (completionBlock)
                            completionBlock(nil, [NSError errorWithDomain:@"getcalbumlist" code:9000 userInfo:@{NSLocalizedDescriptionKey:dic[@"message"]}]) ;
                    }
                        break;
                }
                
            }
            
        } else {
            if (completionBlock)
                completionBlock(nil, [NSError errorWithDomain:@"getcalbumlist" code:9000 userInfo:@{NSLocalizedDescriptionKey:timeOutErrorCode}]) ;
        }
    });
}
+ (NSString *)insertVideoWithAlbum_id:(NSString *)album_id videopath:(NSString *)videopath completionBlock:(void(^)(NSDictionary *result, NSString *taskId,NSError *error))completionBlock {
    
    NSString *uuid = [[NSUUID UUID] UUIDString];
    
    return uuid;
}
+ (NSString *)insertPhotoWithAlbum_id:(NSString *)album_id
                      imageData:(NSData *)imageData
                completionBlock:(void(^)(NSDictionary *result, NSString *taskId,NSError *error))completionBlock {
    
    if (!imageData || imageData.length < 1) return nil;
    // Dictionary that holds post parameters. You can set your post parameters that your server accepts or programmed to accept.
    NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];

    [_params setObject:[UserInfo getUserID] forKey:@"id"];
    [_params setObject:[UserInfo getUserToken] forKey:@"token"];
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
    [request setTimeoutInterval: [kTimeOutForPhoto floatValue]];
    [request setHTTPMethod:@"POST"];
    
    MultipartInputStream *st = [[MultipartInputStream alloc] initWithBoundary:BoundaryConstant];
    
    for (NSString *e in [_params allKeys]) {
        NSString *d = _params[e];
        [st addPartWithName:e string:d];
    }
    if (imageData && imageData.length > 0) {
        
        [st addPartWithName:FileParamConstant filename:@"image.jpg" data:imageData contentType:@"image/jpeg"];
    }
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    
    [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)st.totalLength] forHTTPHeaderField:@"Content-Length"];
    // set HTTP_ACCEPT_LANGUAGE in HTTP Header
    [request setValue: @"zh-TW,zh" forHTTPHeaderField: @"HTTP_ACCEPT_LANGUAGE"];
    
    [request setHTTPBodyStream:st];
    
    //__block NSString *str;

    NSURLSession *session = [NSURLSession sharedSession];
    
    NSString *uuid = [[NSUUID UUID] UUIDString];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest: request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"insertphotoofdiy");
        
        if ([response isKindOfClass: [NSHTTPURLResponse class]]) {
            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
            
            if (statusCode != 200) {
                if (completionBlock)
                    completionBlock(nil, uuid, [NSError errorWithDomain:@"insertPhotoWithAlbum_id" code:9000 userInfo:@{NSLocalizedDescriptionKey:@"HTTP response is 200"}]);
                
                return;
            }
        }
        if (!error && data) {
            
            NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: nil];
            
            if ([dic[@"result"] boolValue]) {
                  if (completionBlock)
                      completionBlock(dic[@"data"], uuid, nil);
                
            } else {
                NSLog(@"Error Message: %@", dic[@"message"]);
                if (completionBlock)
                    completionBlock(nil, uuid, [NSError errorWithDomain:@"insertPhotoWithAlbum_id" code:9000 userInfo:@{NSLocalizedDescriptionKey:dic[@"message"]}]);
            }
            
        } else {
            if (completionBlock)
                completionBlock(nil, uuid, error);
        }
    }];
    task.taskDescription = uuid;
    [task resume];
    
    return uuid;
}

@end
