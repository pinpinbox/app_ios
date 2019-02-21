//
//  MultipartInputStream.h
//  wPinpinbox
//
//  Created by Antelis on 2018/10/9.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PHAsset;

NS_ASSUME_NONNULL_BEGIN

@interface MultipartInputStream : NSInputStream
- (id)initWithBoundary:(NSString *)boundary;
- (void)addPartWithName:(NSString *)name string:(NSString *)string;
- (void)addPartWithName:(NSString *)name filename:(NSString *)filename data:(NSData *)data contentType:(NSString *)contentType;
- (void)addPartWithName:(NSString *)name contentOfPath:(NSString *)path contentType:(NSString *)contentType;
- (void)addPartWithName:(NSString *)name filename:(NSString *)filename contentOfStream:(NSInputStream *)stream length:(NSUInteger)length contentType:(NSString *)contentType;
- (void)addPartWithName:(NSString *)name filename:(NSString *)filename phasset:(PHAsset *)asset length:(NSUInteger)length contentType:(NSString *)contentType;
- (void)addHeaders:(NSDictionary *)headers;

@property (nonatomic, readonly) NSString *boundary;
@property (nonatomic, readonly) NSUInteger totalLength;
@end

NS_ASSUME_NONNULL_END
