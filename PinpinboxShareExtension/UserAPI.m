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

@interface UserAPI()<NSURLSessionTaskDelegate, NSURLSessionDelegate>
@property(nonatomic) NSURLSession *urlSession;
@property(nonatomic) id<UploadProgressDelegate> progressDelegate;
@end

@implementation UserAPI

#pragma mark - for Share extension
#pragma mark  調用所有API

+(instancetype)sharedUserAPI{
    
    static UserAPI *sharedAPI = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAPI = [[self alloc] init];
    });
    return sharedAPI;
}
+ (NSURLSession *)session {
    return [UserAPI sharedUserAPI].urlSession;
}

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        NSURLSessionConfiguration *c = [NSURLSessionConfiguration defaultSessionConfiguration];
        _urlSession = [NSURLSession sessionWithConfiguration:c delegate:self delegateQueue:nil];
        
    }
    return self;
}

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

+(NSString *)userAPI:(NSDictionary *)wData URL:(NSString *)url withCompletionBlock:(void(^)(NSDictionary *result, NSString *taskId,NSError *error))completionBlock {
    
    NSLog(@"userAPI wData URL");
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
    
    for (NSString *kye in wData.allKeys) {
        if ([wData[kye] isKindOfClass:[NSString class]]) {
            [dic setObject:wData[kye] forKey:kye];
            
        } else {
            [dic setObject:[wData[kye] stringValue] forKey:kye];
            
        }
    }
    
    // Get the value of key "sign"
    [dic setObject: [UserAPI signGenerator2:dic] forKey: @"sign"];
    
    if (![self hostAvailable:@"www.pinpinbox.com"]) {//hostURL]) {
        
        completionBlock(nil, nil, [NSError errorWithDomain:@"pinpinbox.share" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"Host not reachable"}]);
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ServerURL, url]]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[self httpBodyForParamsDictionary:dic]];
    [request setValue: @"zh-TW,zh" forHTTPHeaderField: @"HTTP_ACCEPT_LANGUAGE"];
    [request setTimeoutInterval: [kTimeOut floatValue]];
    //NSLog(@"request.timeoutInterval: %f", request.timeoutInterval);

    __block NSString *uuid = [[NSUUID UUID] UUIDString];
    
    NSURLSessionDataTask *task = [[UserAPI session] dataTaskWithRequest: request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error == nil) {
            NSString *str = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
            if ([str isEqualToString:@"-1001"]) {
                completionBlock(nil,uuid, [NSError errorWithDomain:@"pinpinbox.share" code:-1001 userInfo:@{NSLocalizedDescriptionKey:@"Request timed-out"}]);
            } else {
                NSError *jer = nil;
                NSDictionary *dict = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [str dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &jer];
                if (!jer && [dict isKindOfClass:[NSDictionary class]]) {
                    completionBlock(dict, uuid, nil);
                } else {
                    completionBlock(nil, uuid, jer);
                }
            }
            
        } else {
            completionBlock(nil,uuid, error);
        }
        
    }];
    task.taskDescription = uuid;
    [task resume];
    
    return uuid;
    
}
+ (void)getAlbumSettingOptionsWithCompletionBlock:(void(^)(NSDictionary *result, NSError *error))completionBlock {
    
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:[UserInfo getUserId] forKey:@"id"];
    [dic setObject:[UserInfo getUserToken] forKey:@"token"];
    
    [self userAPI:dic URL:@"/getalbumdataoptions/1.0" withCompletionBlock:^(NSDictionary *result, NSString *taskId, NSError *error) {
        
    }];
    
}
+ (void)postPreCheck:(NSString *)album_id completionBlock:(void(^)(NSDictionary *result, NSError *error))completionBlock {
    
    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:[UserInfo getUserId] forKey:@"id"];
    [dic setObject:[UserInfo getUserToken] forKey:@"token"];
    [dic setObject:album_id forKey:@"album_id"];
    
    [self userAPI:dic URL:@"/getalbumofdiy/1.1" withCompletionBlock:^(NSDictionary *result, NSString *taskId, NSError *error) {
        if (!error) {
            int res = [result[@"result"] intValue];
            if (res == 1) {
                if (completionBlock)
                    completionBlock(result[@"data"], nil);
            } else {
                
                if (completionBlock)
                    completionBlock(nil, [NSError errorWithDomain:@"postPreCheck" code:9000 userInfo:@{NSLocalizedDescriptionKey:result[@"message"]?result[@"message"]:timeOutErrorCode}]) ;
                
            }
        } else {
            completionBlock(nil, error);
        }
    }];
}
+ (void)userProfileWithCompletionBlock:(void(^)(NSDictionary *result, NSError *error))completionBlock {

    NSMutableDictionary *dic=[NSMutableDictionary new];
    [dic setObject:[UserInfo getUserId] forKey:@"id"];
    [dic setObject:[UserInfo getUserToken] forKey:@"token"];
    
    [self userAPI:dic URL:@"/getprofile/1.1" withCompletionBlock:^(NSDictionary *result, NSString *taskId, NSError *error) {
        
        if (!error) {
            int res = [result[@"result"] intValue];
            
            switch (res) {
                case 1: {
                    if (completionBlock)
                        completionBlock(result[@"data"],nil);
                } break;
                case 0: {
                    
                    if (completionBlock)
                        completionBlock(nil, [NSError errorWithDomain:@"getprofile" code:9000 userInfo:@{NSLocalizedDescriptionKey:result[@"message"]}]) ;
                }
                    break;
            }
        } else {
            completionBlock(nil, error);
        }
        
    }];

}
+ (void)loadAlbumListWithCompletionBlock:(NSInteger)curCount  completionBlock:(void(^)(NSDictionary *result, NSError *error))completionBlock {
    NSString *limit = [NSString stringWithFormat:@"%ld,20",(long)curCount];
    
    
    NSMutableDictionary *dic=[NSMutableDictionary new];
    
    [dic setObject:@"mine" forKey:@"rank"];
    [dic setObject:[UserInfo getUserId]  forKey:@"id"];
    [dic setObject:[UserInfo getUserToken]  forKey:@"token"];
    [dic setObject:limit forKey:@"limit"];
    
    [self userAPI:dic URL:@"/getcalbumlist/1.3" withCompletionBlock:^(NSDictionary *result, NSString *taskId, NSError *error) {
        if (!error) {
            int res = [result[@"result"] intValue];
            
            switch (res) {
                case 1: {
                    if (completionBlock)
                        completionBlock(result,nil);
                } break;
                case 0: {
                    
                    if (completionBlock)
                        completionBlock(nil, [NSError errorWithDomain:@"getcalbumlist" code:9000 userInfo:@{NSLocalizedDescriptionKey:result[@"message"]}]) ;
                }
                    break;
            }
        } else {
            completionBlock(result, error);
        }
    }];
    
}
+ (NSString *)insertVideoWithAlbum_id:(NSString *)album_id
                            videopath:(NSString *)videopath
                     progressDelegate:(id<UploadProgressDelegate>)progressDelegate
                      completionBlock:(void(^)(NSDictionary *result, NSString *taskId,NSError *error))completionBlock {
    
    NSString *uuid = [[NSUUID UUID] UUIDString];
    
    NSData *vidData = [NSData dataWithContentsOfFile:videopath];
    if (!vidData) {
        completionBlock(nil,nil, [NSError errorWithDomain:@"insertVideoWithAlbum_id" code:9000 userInfo:@{NSLocalizedDescriptionKey:@"Failed to load video data."}]);
        return nil;
    }
    
    [UserAPI sharedUserAPI].progressDelegate = progressDelegate;
    
    NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
    [_params setObject:[UserInfo getUserId] forKey:@"user_id"];
    [_params setObject:[UserInfo getUserToken] forKey:@"token"];
    [_params setObject:album_id forKey:@"album_id"];
    [_params setObject:@"file" forKey:@"video_refer"];
    [_params setObject:@"<null>" forKey:@"video_target"];
    [_params setObject:[UserAPI signGenerator2:_params] forKey:@"sign"];
    
    // the boundary string : a random string, that will not repeat in post data, to separate post data fields.
    NSString *BoundaryConstant = @"----------V2ymHFg03ehbqgZCaKO6jy";
    
    // string constant for the post parameter 'file'. My server uses this name: `file`. Your's may differ
    NSString* FileParamConstant = @"file";
    
    // the server url to which the image (or the media) is uploaded. Use your server url here
    NSURL* requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",ServerURL,@"/insertvideoofdiy",@"/2.0"]];
    
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
        
        [st addPartWithName:FileParamConstant filename:@"uploadVideo.mov" data:vidData contentType:@"video/mov"];
    }
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    
    [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)st.totalLength] forHTTPHeaderField:@"Content-Length"];
    // set HTTP_ACCEPT_LANGUAGE in HTTP Header
    [request setValue: @"zh-TW,zh" forHTTPHeaderField: @"HTTP_ACCEPT_LANGUAGE"];
    
    [request setHTTPBodyStream:st];
    
    __block NSString *str;
    
    //__block typeof(self) wself = self;
    
    
    request.timeoutInterval = [kTimeOutForVideo intValue];
    
    NSURLSessionDataTask *task = [[UserAPI session] dataTaskWithRequest: request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
            if (data) {
            
                str = [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding];
                
                //  time out
                if (str && [str isEqualToString:timeOutErrorCode]) {
                    completionBlock(nil,uuid, [NSError errorWithDomain:@"insertVideoWithAlbum_id" code:9000 userInfo:@{NSLocalizedDescriptionKey:@"Request timed out"}]);
                } else {
                    //__strong typeof(wself) stSelf = wself;
                    NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: nil];
                
                    NSString *res = dic[@"result"];
                    
                    if ([res isEqualToString:@"SYSTEM_OK"]) {
                        if (completionBlock)
                            completionBlock(dic[@"data"], uuid, nil);
                    } else {
                    
                        if (dic[@"message"] == nil) {
                            completionBlock(nil,uuid, [NSError errorWithDomain:@"insertVideoWithAlbum_id" code:9000 userInfo:@{NSLocalizedDescriptionKey:@"Failed to upload video"}]);
                        
                        } else {
                            completionBlock(nil,uuid, [NSError errorWithDomain:@"insertVideoWithAlbum_id" code:9000 userInfo:@{NSLocalizedDescriptionKey:dic[@"message"]}]);
                        }
                    }
                }
            } else {
                completionBlock(nil,uuid, error? error : [NSError errorWithDomain:@"insertVideoWithAlbum_id" code:9000 userInfo:@{NSLocalizedDescriptionKey:@"Failed to upload video"}]);
            }
    }];
    task.taskDescription = uuid;
    [task resume];
    
    return uuid;
}
+ (NSString *)insertVideoWithAlbum_id:(NSString *)album_id
                            videoURLPath:(NSString *)videopath
                     progressDelegate:(id<UploadProgressDelegate>)progressDelegate
                      completionBlock:(void(^)(NSDictionary *result, NSString *taskId,NSError *error))completionBlock {
    
    [UserAPI sharedUserAPI].progressDelegate = progressDelegate;
    
    NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
    [_params setObject:[UserInfo getUserId] forKey:@"user_id"];
    [_params setObject:[UserInfo getUserToken] forKey:@"token"];
    [_params setObject:album_id forKey:@"album_id"];
    [_params setObject:@"embed" forKey:@"video_refer"];
    [_params setObject:videopath forKey:@"video_target"];
    

    NSString *uuid = [UserAPI userAPI:_params URL:@"/insertvideoofdiy/2.0" withCompletionBlock:^(NSDictionary *result, NSString *taskId, NSError *error) {
        if (!error) {
            NSString *res = result[@"result"];
            
            if ([res isEqualToString:@"SYSTEM_OK"]) {
                if (completionBlock)
                    completionBlock(result[@"data"],taskId,nil);
            } else if (result[@"message"]) {
                if (completionBlock)
                    completionBlock(nil, taskId,[NSError errorWithDomain:@"insertVideoWithAlbum_idEmbed" code:9000 userInfo:@{NSLocalizedDescriptionKey:result[@"message"]}]) ;
            } else {
                completionBlock(nil, taskId,[NSError errorWithDomain:@"insertVideoWithAlbum_idEmbed" code:9000 userInfo:@{NSLocalizedDescriptionKey:timeOutErrorCode}]) ;
            }
        } else {
            completionBlock(nil, taskId, error);
        }
    }];
    
    return uuid;
}

+ (NSString *)insertPhotoWithAlbum_id:(NSString *)album_id
                            imageData:(NSData *)imageData
                     progressDelegate:(id<UploadProgressDelegate>)progressDelegate
                      completionBlock:(void(^)(NSDictionary *result, NSString *taskId,NSError *error))completionBlock {
    
    if (!imageData || imageData.length < 1) {
        completionBlock(nil,nil, [NSError errorWithDomain:@"insertPhotoWithAlbum_id" code:9000 userInfo:@{NSLocalizedDescriptionKey:@"Failed to load image data."}]);
        return nil;
    }
    
    [UserAPI sharedUserAPI].progressDelegate = progressDelegate;
    
    NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];

    [_params setObject:[UserInfo getUserId] forKey:@"id"];
    [_params setObject:[UserInfo getUserToken] forKey:@"token"];
    [_params setObject:album_id forKey:@"album_id"];
    [_params setObject:[UserAPI signGenerator2:_params] forKey:@"sign"];
    
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
    
    NSString *uuid = [[NSUUID UUID] UUIDString];
    
    NSURLSessionDataTask *task = [[UserAPI session] dataTaskWithRequest: request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"insertphotoofdiy");
        
        if ([response isKindOfClass: [NSHTTPURLResponse class]]) {
            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
            
            if (statusCode != 200) {
                if (completionBlock)
                    completionBlock(nil, uuid, [NSError errorWithDomain:@"insertPhotoWithAlbum_id" code:9000 userInfo:@{NSLocalizedDescriptionKey:@"HTTP response is not 200"}]);
                
                return;
            }
        }
        if (!error && data) {
            
            NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: nil];
            
            if ([dic[@"result"] intValue] == 1) {
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
+ (void)loadImageWithURL:(NSURL *)url completionBlock:(void(^)(UIImage * _Nullable image))completionBlock {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval: [kTimeOutForPhoto floatValue]];
    
    //__block NSString *ext = [[url lastPathComponent] pathExtension];
    NSURLSessionDataTask *task = [[UserAPI session] dataTaskWithRequest: request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data && data.length) {
            UIImage *image = [UIImage imageWithData:data];
            completionBlock(image);
        } else {
            NSLog(@"loadImageWithURL %@",error);
            completionBlock(nil);
        }
    }];
 
    [task resume];
}
- (void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    
//    if (task.taskDescription) {
//        //NSLog(@"didSendBodyData %@: %ld/%ld",task.description, (unsigned long)totalBytesSent, (unsigned long)totalBytesExpectedToSend );
//        if ([UserAPI sharedUserAPI].progressDelegate) {
//            double p = (double) totalBytesSent/(double)totalBytesExpectedToSend;
//            [[UserAPI sharedUserAPI].progressDelegate uploadProgress:task.taskDescription progress: (CGFloat)p];
//        }
//    }
}

/*
 @"/getalbumdataoptions/1.0"
 */
@end