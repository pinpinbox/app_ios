//
//  ShareItem.h
//  PinpinboxShareExtension
//
//  Created by Antelis on 2018/12/17.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@class ShareItem;
@protocol ItemPostLoadDelegate <NSObject>
- (void)loadCompleted:(UIImage *)thumbnail type:(NSString *)type hasVideo:(BOOL)hasVideo isDark:(BOOL)isDark;
@end

@protocol ItemContentDelegate <NSObject>
- (void)processInvalidItem:(ShareItem *)item;
@end

@interface ShareItem : NSObject
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSURL *thumbURL;   // url of image file
@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, strong) NSString *objType; // kuttypeImage, kuttypemovie, etc.
@property (nonatomic, strong) NSItemProvider *shareItem;
@property (nonatomic) BOOL hasVideo;
@property (nonatomic) BOOL thumbIsDark;
@property (nonatomic) Float64 vidDuration;
- (id)initWithItemProvider:(NSItemProvider *)item type:(NSString *)type itemDelegate:(id<ItemContentDelegate>)itemDelegate;
- (void)loadThumbnailWithPostload:(id<ItemPostLoadDelegate>) postload;
@end

NS_ASSUME_NONNULL_END
