//
//  SendingPhoto.h
//  wPinpinbox
//
//  Created by David on 2017/10/24.
//  Copyright © 2017年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class SendingPhoto;
@protocol SendingPhotoDelegate <NSObject>
- (void)sendingPhotoSucceeded:(SendingPhoto *)sendingPhoto
                    imgNumber:(NSInteger)imgNumber
                    imgAmount:(NSInteger)imgAmount;

- (void)sendingPhotoFailed:(SendingPhoto *)sendingPhoto               
                 imgNumber:(NSInteger)imgNumber;
@end

@interface SendingPhoto : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>
@property (weak) id <SendingPhotoDelegate> delegate;
@property (nonatomic) NSURLSessionTask *task;
@property (nonatomic) NSInteger imgNumber;

- (NSString *)insertPhotoOfDiy:(NSString *)uid
                   token:(NSString *)token
                album_id:(NSString *)album_id
               imageData:(NSData *)imageData
               imgNumber:(NSInteger)imgNumber;

@end
