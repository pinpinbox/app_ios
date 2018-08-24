//
//  ReqHTTP.h
//  wPinpinbox
//
//  Created by Angus on 2015/10/12.
//  Copyright (c) 2015年 Angus. All rights reserved.
//
//ReqHTTP.h
#import <CoreImage/CoreImage.h>
@interface ReqHTTP : NSObject
- (void)postMultiDataWithTextDictionary:(NSDictionary*)textDictionary
                        imageDictionary:(NSDictionary*)imageDictionary
                                    url:(NSURL*)url done:(void(^)(NSDictionary *responseData)) doneHandler fail:(void(^)(NSInteger status)) failHandler;
@end

//ReqHTTP.m
@implementation ReqHTTP
{
    void (^requestDoneHandler)(NSDictionary *data);
    void (^requestFailHandler)(NSInteger status);
}
- (void)postMultiDataWithTextDictionary:(NSDictionary*)textDictionary
                        imageDictionary:(NSDictionary*)imageDictionary
                                    url:(NSURL*)url done:(void(^)(NSDictionary *responseData)) doneHandler fail:(void(^)(NSInteger status)) failHandler
{
    requestDoneHandler = doneHandler;
    requestFailHandler = failHandler;
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSString* boundary = @"1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    config.HTTPAdditionalHeaders =
    @{
      @"Content-Type" : [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary]
      };
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    // postデータの作成
    NSMutableData* data = [NSMutableData data];
    // テキスト部分の設定
    for (id key in [textDictionary keyEnumerator])
    {
        NSString* value = [textDictionary valueForKey:key];
        
        [data appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data;"] dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:[[NSString stringWithFormat:@"name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:[[NSString stringWithFormat:@"%@\r\n", value] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // 画像の設定
    for (int i = 0; i < [imageDictionary count]; i++)
    {
        NSString* key = [[imageDictionary allKeys] objectAtIndex:i];
        NSData* value = [imageDictionary valueForKey:key];
        NSString* name = [NSString stringWithFormat:@"file%d", i];
        if (imageDictionary.count==1) {
            name = [NSString stringWithFormat:@"file"];
        }
        
        
        [data appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data;"] dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:[[NSString stringWithFormat:@"name=\"%@\";", name] dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:[[NSString stringWithFormat:@"filename=\"%@\"\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:[[NSString stringWithFormat:@"Content-Type: image/jpeg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:value];
        [data appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // 最後にバウンダリを付ける
    [data appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = data;
    
    __block typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        __strong typeof(weakSelf) stSelf = weakSelf;
        [session invalidateAndCancel];//メモリリーク対策
        if(error){
            stSelf->requestFailHandler(-1);
        }else{
            NSError *err = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&err];
            if (err) {
                stSelf->requestFailHandler(-1);
                return;
            }
            stSelf->requestDoneHandler(json);
        }
        
    }];
    
    [task resume];
}
@end
