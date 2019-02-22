//
//  MultipartInputStream.m
//  wPinpinbox
//
//  Created by Antelis on 2018/10/9.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "MultipartInputStream.h"
#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTType.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define kMultipartHeaderString @"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n"
#define kMultipartData @"--%@\r\nContent-Disposition: form-data; name=\"%@\"; Content-Type: %@\r\n\r\n"
#define kMultipartFileData @"--%@\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: %@\r\n\r\n"
#define kMultipartFooter @"--%@--\r\n"

@protocol  StreamElementProtocol<NSObject>
@property (nonatomic) NSUInteger delivered;
- (NSUInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len;
- (BOOL)hasByteAvailable;
@end

#pragma mark -

@interface MultipartInputStreamElement : NSObject<StreamElementProtocol>
@property (nonatomic, strong) NSData *header;
@property (nonatomic, strong) NSInputStream *body;
@property (nonatomic) NSUInteger headerLength;
@property (nonatomic) NSUInteger bodyLength;
@property (nonatomic) NSUInteger length;
@property (nonatomic) NSUInteger status;
@end

@implementation MultipartInputStreamElement
@synthesize delivered;
+ (NSString *)findContenttypeWithExt:(NSString *)ext {
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,(__bridge CFStringRef)ext, NULL);
    if (uti != NULL) {
        NSString *type = [NSString stringWithString:(__bridge NSString *)uti];
        CFRelease(uti);
        return type;
    }
    return @"application/octet-stream";
}

- (void)updateLength {
    self.length = self.headerLength+ self.bodyLength + ((self.headerLength > 0)? 2: 0);
    [self.body open];
}
- (id)initWithName:(NSString *)name boundary:(NSString *)boundary string:(NSString *)string {
    self = [super init];
    if (self) {
        NSString *he = [NSString stringWithFormat:kMultipartHeaderString,boundary,name];
        self.header = [he dataUsingEncoding:NSUTF8StringEncoding];
        self.headerLength = self.header.length;
        NSData *ns = [string dataUsingEncoding:NSUTF8StringEncoding];
        self.body = [NSInputStream inputStreamWithData:ns];
        self.bodyLength = ns.length;
        [self updateLength];
    }
    return self;
}
- (id)initWithName:(NSString *)name boundary:(NSString *)boundary data:(NSData *)data mime:(NSString *)mime filename:(NSString *)filename{
    self = [super init];
    if (self) {
        if (filename != nil ) {
            NSString *he = [NSString stringWithFormat:kMultipartFileData,boundary,name,filename,mime];
            self.header = [he dataUsingEncoding:NSUTF8StringEncoding];
        } else {
            NSString *he = [NSString stringWithFormat:kMultipartData,boundary,name,mime];
            self.header = [he dataUsingEncoding:NSUTF8StringEncoding];
        }
        self.headerLength = self.header.length;
        self.body = [NSInputStream inputStreamWithData:data];
        self.bodyLength = data.length;
        [self updateLength];
    }
    return self;
}
- (id)initWithUploadHeader:(NSString *)name boundary:(NSString *)boundary filePath:(NSString *)filePath mime:(NSString *)mime {
    self = [super init];
    if (self) {
        NSString *f = [filePath lastPathComponent];
        NSString *ext = [filePath pathExtension];
        NSData *HeaderData = nil;
        if (f != nil ) {
            mime = [MultipartInputStreamElement findContenttypeWithExt:ext];
            NSString *he = [NSString stringWithFormat:kMultipartFileData,boundary,name,f,mime];
            HeaderData = [he dataUsingEncoding:NSUTF8StringEncoding];
            
        } else {
            NSString *he = [NSString stringWithFormat:kMultipartData,boundary,name,mime];
            HeaderData = [he dataUsingEncoding:NSUTF8StringEncoding];
        }
        self.body = [NSInputStream inputStreamWithData:HeaderData];
        self.bodyLength = HeaderData.length;
        self.headerLength = 0;
        self.length = self.bodyLength + self.headerLength;
        [self.body open];
    }
    
    return self;
}
- (id)initWithUploadFooter {
    self = [super init];
    if (self) {
        
        
        self.headerLength = 0;
        const char footer[] = {'\r','\n'};
        
        NSData *HeaderData = [NSData dataWithBytes:footer length:2];
        
        self.body = [NSInputStream inputStreamWithData:HeaderData];
        self.bodyLength = HeaderData.length;
        
        self.length = self.bodyLength + self.headerLength;
        [self.body open];
    }
    
    return self;
}

- (id)initWithName:(NSString *)name boundary:(NSString *)boundary filePath:(NSString *)filePath mime:(NSString *)mime {
    //  One file-uploading stream contains three streams : [MultipartHeader data stream, file stream, MultipartFooter data stream ]
    //  Only open uploading stream after all three are built
    self = [super init];
    if (self) {
        
        self.header = nil;
        self.headerLength = 0;
        self.body = [NSInputStream inputStreamWithFileAtPath:filePath];
        NSDictionary *info = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        self.bodyLength = [[info objectForKey: NSFileSize] unsignedIntegerValue];
        
        self.length = self.bodyLength + self.headerLength;
        [self.body open];
    }
    return self;
}
- (id)initWithName:(NSString *)name boundary:(NSString *)boundary url:(NSURL *)url length:(NSUInteger) length mime:(NSString *)mime {
    self = [super init];
    if (self) {
        NSString *path = [url absoluteString];
        NSString *f = [path lastPathComponent];
        NSString *ext = [path pathExtension];
        if (f != nil ) {
            mime = [MultipartInputStreamElement findContenttypeWithExt:ext];
            NSString *he = [NSString stringWithFormat:kMultipartFileData,boundary,name,f,mime];
            self.header = [he dataUsingEncoding:NSUTF8StringEncoding];
        } else {
            NSString *he = [NSString stringWithFormat:kMultipartData,boundary,name,mime];
            self.header = [he dataUsingEncoding:NSUTF8StringEncoding];
        }
        
        self.headerLength = self.header.length;
        self.body = [NSInputStream inputStreamWithURL:url];
        self.bodyLength = length;
        
        [self updateLength];
    }
    
    return self;
}
- (id)initWithHeaders:(NSDictionary *)headers string:(NSString *)string boundary:(NSString *)boundary {
    self = [super init];
    if (self) {
        _header = [self makeHeadersDataFromHeadersDict:headers boundary:boundary];
        _headerLength = _header.length;
        NSData *ns = [string dataUsingEncoding:NSUTF8StringEncoding];
        self.body = [NSInputStream inputStreamWithData:ns];
        self.bodyLength = ns.length;
        [self updateLength];
    }
    return self;
}
- (id)initWithHeaders:(NSDictionary *)headers path:(NSString *)path boundary:(NSString *)boundary
{
    self = [super init];
    if (self) {
        
        _header = [self makeHeadersDataFromHeadersDict:headers boundary:boundary];
        _headerLength = _header.length;
        _body = [NSInputStream inputStreamWithFileAtPath:path];
        _bodyLength = [[[[NSFileManager defaultManager] attributesOfItemAtPath:path error:NULL] objectForKey:NSFileSize] unsignedIntegerValue];
        [self updateLength];
    }
    return self;
}

- (NSData *)makeHeadersDataFromHeadersDict:(NSDictionary *)headers boundary:(NSString *)boundary
{
    NSMutableString *headersString = [[NSMutableString alloc] initWithFormat:@"--%@", boundary];
    [self appendNewLine:headersString];
    
    for (NSString *key in headers.allKeys) {
        
        [headersString appendString:[[NSString alloc] initWithFormat:@"%@: %@", key, headers[key]]];
        [self appendNewLine:headersString];
    }
    
    [self appendNewLine:headersString];
    
    NSData *result = [headersString dataUsingEncoding:NSUTF8StringEncoding];
    return result;
}

- (void)appendNewLine:(NSMutableString *)string {
    
    [string appendString:@"\r\n"];
}

- (NSUInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len
{
    NSUInteger sent = 0, read;
    
    if (self.delivered >= self.length)
    {
        return 0;
    }
    if (self.delivered < self.headerLength && sent < len)
    {
        read            = MIN(self.headerLength - self.delivered, len - sent);
        [self.header getBytes:buffer + sent range:NSMakeRange(self.delivered, read)];
        sent           += read;
        self.delivered += sent;
    }
    //  count footer if header != nil //
    int footer = (self.headerLength > 0)? 2: 0;
    while (self.delivered >= self.headerLength && self.delivered < (self.length - footer) && sent < len)
    {
        if ((read = [self.body read:buffer + sent maxLength:len - sent]) == 0)
        {
            break;
        }
        sent           += read;
        self.delivered += read;
    }
    
    //  add real footer '\r''\n' when header != nil //
    if (self.headerLength > 0) {
        if (self.delivered >= (self.length - 2) && sent < len)
        {
            if (self.delivered == (self.length - 2))
            {
                *(buffer + sent) = '\r';
                sent ++; self.delivered ++;
            }
            *(buffer + sent) = '\n';
            sent ++; self.delivered ++;
        }
    }
    return sent;
}
- (NSStreamStatus) bodyStatus {
    if (self.body)
        return self.body.streamStatus;
    
    return NSStreamStatusNotOpen;
}
- (BOOL)hasByteAvailable {
    return YES;
}
- (void)recheckBodyStreamOpened {
    if (self.body && self.body.streamStatus != NSStreamStatusOpen) {
        [self.body open];
    }
}
@end

#pragma mark -

@interface MultipartInputStream()
@property (nonatomic, strong) NSMutableArray *parts;
@property (nonatomic, strong, nonnull) NSString *boundary;
@property (nonatomic, strong) NSData *footer;
@property (nonatomic) NSUInteger currentPart, delivered, length;
@property (nonatomic) NSStreamStatus status;
@end
@implementation MultipartInputStream
@synthesize delegate;
- (void)updateLength
{
    self.length = self.footer.length + [[self.parts valueForKeyPath:@"@sum.length"] unsignedIntegerValue];
}
- (id)initWithBoundary:(NSString *)boundary
{
    self = [super init];
    if (self)
    {
        self.parts    = [NSMutableArray array];
        self.boundary = boundary;//[[NSProcessInfo processInfo] globallyUniqueString];
        self.footer   = [[NSString stringWithFormat:kMultipartFooter, self.boundary] dataUsingEncoding:NSUTF8StringEncoding];
        [self updateLength];
    }
    return self;
}
- (void)addPartWithName:(NSString *)name string:(NSString *)string
{
    [self.parts addObject:[[MultipartInputStreamElement alloc] initWithName:name boundary:self.boundary string:string]];
    [self updateLength];
}
- (void)addPartWithName:(NSString *)name data:(NSData *)data
{
    
    [self.parts addObject:[[MultipartInputStreamElement alloc] initWithName:name boundary:self.boundary data:data mime:@"application/octet-stream" filename:nil]];
    [self updateLength];
}
- (void)addPartWithName:(NSString *)name data:(NSData *)data contentType:(NSString *)type
{
    [self.parts addObject:[[MultipartInputStreamElement alloc] initWithName:name boundary:self.boundary data:data mime:type filename:nil]];
    [self updateLength];
}
- (void)addPartWithName:(NSString *)name filename:(NSString*)filename data:(NSData *)data contentType:(NSString *)type
{
    [self.parts addObject:[[MultipartInputStreamElement alloc] initWithName:name boundary:self.boundary data:data mime:type filename:filename ]]; //[[MultipartInputStreamElement alloc] initWithName:name boundary:self.boundary data:data contentType:type filename:filename]];
    [self updateLength];
}
- (void)addPartWithName:(NSString *)name contentOfPath:(NSString *)contentOfPath contentType:(NSString *)type
{
    //  multipart Header data stream
    [self.parts addObject:[[MultipartInputStreamElement alloc] initWithUploadHeader:name boundary:self.boundary filePath:contentOfPath mime:type ]];
    //  file stream
    [self.parts addObject:[[MultipartInputStreamElement alloc] initWithName:name boundary:self.boundary filePath:contentOfPath mime:type]];
    // multipart Footer data stream
    [self.parts addObject:[[MultipartInputStreamElement alloc] initWithUploadFooter]];
    
    [self updateLength];
    
}
- (void)addPartWithName:(NSString *)name filename:(NSString *)filename path:(NSString *)path contentType:(NSString *)type
{
    [self.parts addObject:[[MultipartInputStreamElement alloc] initWithName:name boundary:self.boundary filePath:path mime:@""]];//[[MultipartInputStreamElement alloc] initWithName:name filename:filename boundary:self.boundary path:path contentType:type]];
    [self updateLength];
}

- (void)addPartWithHeaders:(NSDictionary *)headers string:(NSString *)string
{
    [self.parts addObject:[[MultipartInputStreamElement alloc] initWithHeaders:headers string:string boundary:self.boundary]];
    [self updateLength];
}

- (void)addPartWithHeaders:(NSDictionary *)headers path:(NSString *)path
{
    [self.parts addObject:[[MultipartInputStreamElement alloc] initWithHeaders:headers path:path boundary:self.boundary]];
    [self updateLength];
}

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len
{
    NSUInteger sent = 0, read;
    
    self.status = NSStreamStatusReading;
    while (self.delivered < self.length && sent < len && self.currentPart < self.parts.count)
    {
        MultipartInputStreamElement *ele = [self.parts objectAtIndex:self.currentPart];
        [ele recheckBodyStreamOpened];
        
        if ((read = [ele read:(buffer + sent) maxLength:(len - sent)]) == 0)
        {
            self.currentPart ++;
            continue;
        }
        sent            += read;
        self.delivered  += read;
    }
    if (self.delivered >= (self.length - self.footer.length) && sent < len)
    {
        read            = MIN(self.footer.length - (self.delivered - (self.length - self.footer.length)), len - sent);
        [self.footer getBytes:buffer + sent range:NSMakeRange(self.delivered - (self.length - self.footer.length), read)];
        sent           += read;
        self.delivered += read;
    }
    return sent;
}
- (BOOL)hasBytesAvailable
{
    return self.delivered < self.length;
}
- (void)open
{
    self.status = NSStreamStatusOpen;
}
- (void)close
{
    self.status = NSStreamStatusClosed;
}
- (NSStreamStatus)streamStatus
{
    if (self.status != NSStreamStatusClosed && self.delivered >= self.length)
    {
        self.status = NSStreamStatusAtEnd;
    }
    return self.status;
}
- (NSUInteger)totalLength {
    return self.length;
}
- (void)_scheduleInCFRunLoop:(NSRunLoop *)runLoop forMode:(id)mode {}
- (void)_setCFClientFlags:(CFOptionFlags)flags callback:(CFReadStreamClientCallBack)callback context:(CFStreamClientContext)context {}
- (void)removeFromRunLoop:(__unused NSRunLoop *)aRunLoop forMode:(__unused NSString *)mode {}
- (id)propertyForKey:(NSStreamPropertyKey)key {
    return nil;
}

- (BOOL)setProperty:(id)property forKey:(NSStreamPropertyKey)key {
    return NO;
}




- (void)addPartWithName:(NSString *)name filename:(NSString *)filename contentOfStream:(NSInputStream *)stream length:(NSUInteger)length contentType:(NSString *)contentType {}
- (void)addPartWithName:(NSString *)name filename:(NSString *)filename phasset:(PHAsset *)asset length:(NSUInteger)length contentType:(NSString *)contentType {}
- (void)addHeaders:(NSDictionary *)headers {}
@end


/*
 
 link PHAssetResource to NSInputStream
 From PHAsset -> PHAssetResource:
 [PHAssetResource assetResourcesForAsset:PHAsset]
 [[PHAssetResourceManager defaultManager] requestDataForAssetResource:options:dataReceivedHandler:completionHandler:]
 */
