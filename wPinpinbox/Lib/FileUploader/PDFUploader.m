//
//  PDFReader.m
//  wPinpinbox
//
//  Created by Antelis on 2018/11/12.
//  Copyright © 2018 Angus. All rights reserved.
//

// upload by order
// opted out if os < 11.0

#import "PDFUploader.h"
#import <PDFKit/PDFKit.h>
#import "GlobalVars.h"
#import "MultipartInputStream.h"

API_AVAILABLE(ios(11.0))
@interface PDFUploader ()
@property (nonatomic) id<PDFUploaderDelegate>infoDelegate;
@property (nonatomic,strong) PDFDocument *curPDFDocument;
@property (nonatomic) NSString *albumID;
@property (nonatomic) PDFReadProgressBlock progressblock;
@property (nonatomic) PDFReadExportFinishedBlock exportFinishedblock;
@property (nonatomic) PDFUploaderProgressBlock uploadProgressBlock;
@property (nonatomic) PDFUploaderResultBlock uploadResultBlock;
@property (nonatomic) int availablePages;
@property (nonatomic) NSMutableArray *imageDataArray;
@property (nonatomic) NSURLSession *session;
@property (nonatomic) NSMutableArray *dataTaskArray;
@property (nonatomic) NSInteger pageFinished;
@property (nonatomic) NSInteger pageFailed;
@property (nonatomic) NSInteger totalPages;
@property (nonatomic) NSString *uuid;
@end


@implementation PDFUploader
- (id) initWithAlbumID:(NSString *)albumID
        availablePages:(int)availablePages
          infoDelegate:(id<PDFUploaderDelegate>)infoDelegate
         progressblock:(PDFReadProgressBlock)progressblock
   exportFinishedblock:(PDFReadExportFinishedBlock)finishedblock
   uploadProgressBlock:(PDFUploaderProgressBlock)uploadblock
     uploadResultBlock:(PDFUploaderResultBlock)resultblock {
    
    self = [super init];
    if (self) {
        self.uuid = [[NSUUID UUID] UUIDString];
        self.infoDelegate = infoDelegate;
        self.availablePages = availablePages;
        self.albumID = albumID;
        self.progressblock = progressblock;
        self.exportFinishedblock = finishedblock;
        self.uploadProgressBlock = uploadblock;
        self.uploadResultBlock = resultblock;
        self.imageDataArray = [NSMutableArray array];
        self.dataTaskArray = [NSMutableArray array];
    }
    return self;
}
- (void)exportPagesToImages:(NSURL *)pdfURL {
    
    if (@available(iOS 11.0, *)) {
        self.curPDFDocument = [[PDFDocument alloc] initWithURL:pdfURL];
        self.totalPages = (NSInteger)self.curPDFDocument.pageCount;
        __block typeof(self) wself = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                    
            //  number of pdf page is more than upload limit
            if (wself.totalPages > wself.availablePages) {
                if (wself.exportFinishedblock)
                    wself.exportFinishedblock([NSError errorWithDomain:@"" code:-1111 userInfo:@{NSLocalizedDescriptionKey:@"PDF檔頁數超過可上傳上限"}], nil,nil);
                [wself cleanUp];
                
                return;
            }
            NSMutableArray *descs = [NSMutableArray array];
            NSMutableArray *icons = [NSMutableArray array];
            for(int i = 0; i < wself.totalPages;i++ ) {
                [descs addObject:[[NSUUID UUID] UUIDString]];
                PDFPage *page = [wself.curPDFDocument pageAtIndex:i];
                
                
                CGRect frame0 = [page boundsForBox: kPDFDisplayBoxMediaBox];
                CGAffineTransform tf = [page transformForBox:kPDFDisplayBoxMediaBox];
                CGRect frame = CGRectApplyAffineTransform(frame0, tf);
                CGSize ssize = frame.size;
                
                UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc]initWithSize:ssize];
                NSData *imageData = [renderer PNGDataWithActions:^(UIGraphicsImageRendererContext *rendererContext) {
                /*[renderer JPEGDataWithCompressionQuality:1 actions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {*/
                    [[UIColor whiteColor] setFill];
                    
                    [rendererContext fillRect:CGRectMake(0, 0, ssize.width, ssize.height)];
                    CGContextTranslateCTM(rendererContext.CGContext, 0, ssize.height);
                    CGContextScaleCTM(rendererContext.CGContext, 1.0, -1.0);
                    [page drawWithBox:kPDFDisplayBoxMediaBox toContext:rendererContext.CGContext];
                }];
                
                if (imageData) {
                    UIImage *icon = [UIImage imageWithData:imageData scale:0.25];
                    [icons addObject:icon];
                    [wself.imageDataArray addObject:imageData];
                }
                if (wself.progressblock) {
                    wself.progressblock(i, (int)wself.totalPages);
                }
                
            }
            
            if (self.exportFinishedblock) {
                self.exportFinishedblock(nil,icons,descs);
                [self sendingImage:descs];
            }
        });
        
        
    } else {
        
        }

}
- (void)cleanUp {
    
    // if pdf exists, delete the imported file...
    BOOL delete = YES;
    if (self.infoDelegate) {
        delete = [self.infoDelegate isExporter];
    }
    if (delete && self.curPDFDocument.documentURL &&
        [[NSFileManager defaultManager] fileExistsAtPath:self.curPDFDocument.documentURL.path]) {
        
        [[NSFileManager defaultManager] removeItemAtURL:self.curPDFDocument.documentURL error:nil];
    }
    [self.dataTaskArray removeAllObjects];
    [self.imageDataArray removeAllObjects];
}
#pragma mark -
- (void)sendingImage:(NSMutableArray *)descs {
    
    [_dataTaskArray removeAllObjects];
    if (!_session) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = [kTimeOutForPhoto floatValue];
        _session = [NSURLSession sessionWithConfiguration: config delegate:nil delegateQueue:nil];
    }

    int i = 0;
    while ([self.imageDataArray count]) {
        
        @try {
            NSData *imageData = [self.imageDataArray firstObject];
            NSString *desc = [descs objectAtIndex:i];
            [self sendWithStream:[self.infoDelegate userInfo] album_id: self.albumID imageData: imageData taskDesc:desc];
            [self.imageDataArray removeObjectAtIndex:0];
            i++;
            //[descs removeObjectAtIndex:0];
            
        } @catch (NSException *exception) {
            if (self.uploadResultBlock) {
                self.uploadResultBlock([NSError errorWithDomain:@"" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"取消上傳"}]);
                return;
            }
        } @finally {
            
        }
        
    }
}
- (void)sendWithStream:(NSDictionary *)userInfo album_id:(NSString *)album_id imageData:(NSData *)imageData taskDesc:(NSString *) taskDesc {
    
    if (!imageData || imageData.length < 1) return;
    // Dictionary that holds post parameters. You can set your post parameters that your server accepts or programmed to accept.
    NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
    [_params setObject:userInfo[@"id"] forKey:@"id"];
    [_params setObject:userInfo[@"token"] forKey:@"token"];
    [_params setObject:album_id forKey:@"album_id"];
    [_params setObject:[self.infoDelegate retrieveSign:_params] forKey:@"sign"];
    
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
    
    __block typeof(self) wself = self;
    
    
    __block NSString *desc = taskDesc;//[[NSUUID UUID] UUIDString];
    NSURLSessionDataTask *task = [_session dataTaskWithRequest: request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"insertphotoofdiy");
        
        if (wself.uploadProgressBlock)
            wself.uploadProgressBlock((int)wself.pageFinished, (int)wself.totalPages,desc);
        
        __strong typeof(wself) sself = wself;
        if (error) {
            NSLog(@"dataTaskWithRequest error: %@", error);
            
        }
        if ([response isKindOfClass: [NSHTTPURLResponse class]]) {
            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
            
            if (statusCode != 200) {
                NSLog(@"dataTaskWithRequest HTTP status code: %ld", (long)statusCode);
                //dispatch_semaphore_signal(semaphore);
                //return;
            }
        }
        if (!error && data) {
            //str = [NSString stringWithUTF8String:[data bytes]];//[[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding];
            
            //NSLog(@"str: %@", str);
            
            NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData: data /*[str dataUsingEncoding: NSUTF8StringEncoding]*/ options: NSJSONReadingMutableContainers error: nil];
            
            
            
            if ([dic[@"result"] boolValue]) {
                
                //[sself increaseFinished];
                
            } else {
                NSLog(@"Error Message: %@", dic[@"message"]);
                
                //[sself increaseFailed];
            }
            
        } else {
           // [sself increaseFailed];
        }
        [sself increaseFinished];
        [sself removeDataTask:desc];
        //if (sself.uploadProgressBlock)
        //    sself.uploadProgressBlock((int)sself.pageFinished, (int)sself.totalPages);
        
        
    }];
    //NSLog(@"task resume");
    
    [task setTaskDescription:desc];
    [_dataTaskArray addObject: task];
    if ([_dataTaskArray count] <= 1)
        [task resume];
}
- (void)increaseFinished {
    self.pageFinished++;
    //[self updateProgress:0];
}
- (void)removeDataTask:(NSString * )taskDesc {
    for (NSURLSessionDataTask *t in _dataTaskArray) {
        if ([taskDesc isEqualToString: t.taskDescription]) {
            
            [_dataTaskArray removeObject:t];
            if (_dataTaskArray.count > 0) {
                NSURLSessionDataTask *t = [_dataTaskArray firstObject];
                [t resume];
                return;
            }
        }
    }
    
    [self cleanUp];
    if (self.uploadResultBlock)
        self.uploadResultBlock(nil);
        
}
- (void)cacenlCurrentWork {
    NSLog(@"");
    NSLog(@"cancelWork");
    
    [self.imageDataArray removeAllObjects];
    
    if (self.uploadResultBlock) {
        self.uploadResultBlock([NSError errorWithDomain:@"" code:9999 userInfo:@{NSLocalizedDescriptionKey:@"上傳PDF已中止"}]);
        
        self.uploadResultBlock = nil;
    }
    self.progressblock = nil;
    self.exportFinishedblock = nil;
    self.uploadProgressBlock = nil;
    for (NSURLSessionDataTask *task in _dataTaskArray) {
        [task cancel];
    }
    
    
    [_dataTaskArray removeAllObjects];
    
}

- (NSString *)taskId {
    return self.uuid;
}
#pragma mark -
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    
    [controller dismissViewControllerAnimated:YES completion:nil];
    
}
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray <NSURL *>*)urls {
    NSURL *url = [urls firstObject];
    [self exportPagesToImages:url];
}
@end
