//
//  SendingPhoto.m
//  wPinpinbox
//
//  Created by David on 2017/10/24.
//  Copyright © 2017年 Angus. All rights reserved.
//

#import "SendingPhoto.h"
#import "boxAPI.h"
#import "NSString+MD5.h"
#import "GlobalVars.h"

@implementation SendingPhoto
{
    NSMutableArray *imageInfoArray;
    NSInteger totalImage;
}
#pragma mark - New Photo Sending Methods
- (NSString *)insertPhotoOfDiy:(NSString *)uid
                   token:(NSString *)token
                album_id:(NSString *)album_id
               imageData:(NSData *)imageData
               imgNumber:(NSInteger)imgNumber
{
    NSLog(@"");
    NSLog(@"insertphotoofdiy");
    
    //self.img = image;
    //self.compression = compressionQuality;
    self.imgNumber = imgNumber;
    
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
    NSURL* requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",ServerURL,@"/insertphotoofdiy",@"/1.2"]];
    
    // create request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];//[[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    //[request setTimeoutInterval: [kTimeOutForPhoto floatValue]];
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
    //[request setURL:requestURL];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSString *responseStr;
    
    NSURLSession *session = [NSURLSession sharedSession];
    self.task = [session dataTaskWithRequest: request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSLog(@"dataTaskWithRequest completionHandler");
        
        if (data) {
            responseStr = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
            NSLog(@"responseStr: %@", responseStr);
            
            if (responseStr != nil) {
                NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: [responseStr dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: nil];
                
                NSLog(@"dic: %@", dic);
                
                if ([dic[@"result"] boolValue]) {
                    NSLog(@"dic result boolValue: %d", [dic[@"result"] boolValue]);
                    
                    NSLog(@"Sending Data Successfully");
                    
                    imageInfoArray = [NSMutableArray new];
                    
                    for (NSMutableDictionary *photo in dic[@"data"][@"photo"]) {
                        [imageInfoArray addObject: photo[@"photo_id"]];
                    }
                    
                    NSLog(@"imageInfoArray.count: %lu", (unsigned long)imageInfoArray.count);
                    totalImage = imageInfoArray.count;
                    [imageInfoArray removeAllObjects];
                    imageInfoArray = nil;
                    
                    NSLog(@"totalImage: %ld", (long)totalImage);
                    
                    if ([self.delegate respondsToSelector: @selector(sendingPhotoSucceeded:imgNumber:imgAmount:)]) {
                        [self.delegate sendingPhotoSucceeded: self imgNumber: self.imgNumber imgAmount: totalImage];
                    }
                    
                } else {
                    NSLog(@"Error Message: %@", dic[@"message"]);
                    
                    if ([self.delegate respondsToSelector: @selector(sendingPhotoFailed:imgNumber:)]) {
                        [self.delegate sendingPhotoFailed: self
                                                imgNumber: self.imgNumber];
                    }
                }
            }
        } else {
            NSLog(@"error: %@", error);
            
            NSLog(@"error: %@", error);
            NSLog(@"error.userInfo: %@", error.userInfo);
            NSLog(@"error.localizedDescription: %@", error.localizedDescription);
            NSLog(@"error code: %@", [NSString stringWithFormat: @"%ld", (long)error.code]);
            
            if ([self.delegate respondsToSelector: @selector(sendingPhotoFailed:imgNumber:)]) {
                [self.delegate sendingPhotoFailed: self
                                        imgNumber: self.imgNumber];
            }
        }
        dispatch_semaphore_signal(semaphore);
    }];
    NSLog(@"self.task resume");
    [self.task resume];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return responseStr;
}

/*
#pragma mark - NSURLSessionDelegate Methods
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    NSLog(@"");
    NSLog(@"didSendBodyData");
    NSLog(@"bytesSent: %lld", bytesSent);
    NSLog(@"totalBytesSent: %lld", totalBytesSent);
    NSLog(@"totalBytesExpectedToSend: %lld", totalBytesExpectedToSend);
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
        
        NSLog(@"dic: %@", dic);
        
        if ([dic[@"result"] boolValue]) {
            NSLog(@"dic result boolValue: %d", [dic[@"result"] boolValue]);
            
            NSLog(@"Sending Data Successfully");
            
            imageInfoArray = [NSMutableArray new];
            
            for (NSMutableDictionary *photo in dic[@"data"][@"photo"]) {
                [imageInfoArray addObject: photo[@"photo_id"]];
            }
            
            NSLog(@"imageInfoArray.count: %d", imageInfoArray.count);
            totalImage = imageInfoArray.count;
            [imageInfoArray removeAllObjects];
            imageInfoArray = nil;
            
            NSLog(@"totalImage: %d", totalImage);
            
            if ([self.delegate respondsToSelector: @selector(sendingPhotoSucceeded:imgNumber:imgAmount:)]) {
                [self.delegate sendingPhotoSucceeded: self imgNumber: self.imgNumber imgAmount: totalImage];
            }
            
        } else {
            NSLog(@"Error Message: %@", dic[@"message"]);
            
            if ([self.delegate respondsToSelector: @selector(sendingPhotoFailed:imgNumber:)]) {
                [self.delegate sendingPhotoFailed: self
                                        imgNumber: self.imgNumber];
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
    
    if (error != nil) {
        NSLog(@"error: %@", error);
        NSLog(@"error.userInfo: %@", error.userInfo);
        NSLog(@"error.localizedDescription: %@", error.localizedDescription);
        NSLog(@"error code: %@", [NSString stringWithFormat: @"%ld", (long)error.code]);
        
        if ([self.delegate respondsToSelector: @selector(sendingPhotoFailed:imgNumber:)]) {
            [self.delegate sendingPhotoFailed: self
                                    imgNumber: self.imgNumber];
        }
    } else if (error == nil) {
        NSLog(@"no error");
    }
}
*/

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
