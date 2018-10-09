//
//  SendingVideo.m
//  wPinpinbox
//
//  Created by David on 2017/10/25.
//  Copyright © 2017年 Angus. All rights reserved.
//

#import "SendingVideo.h"
#import "boxAPI.h"
#import "NSString+MD5.h"
#import "GlobalVars.h"

@implementation SendingVideo
- (void)insertVideoOfDiy:(NSString *)uid
                   token:(NSString *)token
                album_id:(NSString *)album_id
                    file:(NSData *)videoData
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
    //[request setURL:requestURL];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = [kTimeOutForVideo floatValue];
    config.timeoutIntervalForResource = [kTimeOutForVideo floatValue];
    NSURLSession *session = [NSURLSession sessionWithConfiguration: config
                                                          delegate: self
                                                     delegateQueue: [NSOperationQueue mainQueue]];
    self.dataTask = [session dataTaskWithRequest: request];
    [self.dataTask resume];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    NSLog(@"");
    NSLog(@"didReceiveData");
    NSString *response;
    
    response = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSLog(@"response: %@", response);
    
    if (response != nil) {
        NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
        
        
        
        if ([dic[@"result"] boolValue]) {
            NSLog(@"dic result boolValue: %d", [dic[@"result"] boolValue]);
            
            NSLog(@"Sending Data Successfully");
            
            if ([self.delegate respondsToSelector: @selector(sendingVideoSucceeded:)]) {
                [self.delegate sendingVideoSucceeded: self];
            }
        } else {
            NSLog(@"Error Message: %@", dic[@"message"]);
            
            if ([self.delegate respondsToSelector: @selector(sendingVideoFailed:)]) {
                [self.delegate sendingVideoFailed: self];
            }
        }
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    NSLog(@"");
    NSLog(@"didCompleteWithError");
    
    NSLog(@"");
    
    if (error != nil) {
        NSLog(@"error: %@", error);
        NSLog(@"error.userInfo: %@", error.userInfo);
        NSLog(@"error.localizedDescription: %@", error.localizedDescription);
        NSLog(@"error code: %@", [NSString stringWithFormat: @"%ld", (long)error.code]);
        
        if ([self.delegate respondsToSelector: @selector(sendingVideoFailed:)]) {
            [self.delegate sendingVideoFailed: self];
        }
    }
}

- (NSString *)signGenerator2:(NSDictionary *)parameters {
    //NSLog(@"signGenerator2");
    
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

@end
