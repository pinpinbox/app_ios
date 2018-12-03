//
//  HomeBannerCollectionViewCell.m
//  wPinpinbox
//
//  Created by David on 12/01/2018.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "HomeBannerCollectionViewCell.h"
#import "GlobalVars.h"
#import "FLAnimatedImage.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation HomeBannerCollectionViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
    NSLog(@"awakeFromNib");
    
//    self.bannerImageView.layer.cornerRadius = kCornerRadius;
    self.bannerImageView.layer.masksToBounds = YES;
}

- (void)loadCellWithData:(NSDictionary *)data indexPath:(NSIndexPath *)indexPath completionBlock:(void(^)(NSIndexPath *indexpath, HomeBannerCollectionViewCell *cell))completionBlock {
    
    self.bannerImageView.image = nil;
    if (![data[@"event"] isKindOfClass:[NSNull class]] && data[@"event"] != nil) {
        self.bannerTitle.text = data[@"event"];
    } 
    if ([data[@"ad"][@"image"] isEqual: [NSNull null]]) {
        self.bannerImageView.image = [UIImage imageNamed: @"bg200_no_image.jpg"];
    } else {
        NSString *urlString = data[@"ad"][@"image"];
        
        if ([[urlString pathExtension] isEqualToString: @"gif"]) {
            NSLog(@"file is gif");
            NSURL *urlImage = [NSURL URLWithString: urlString];
            __block NSData *data;
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
            dispatch_async(queue, ^{
                NSLog(@"data = [NSData dataWithContentsOfURL: urlImage]");
                data = [NSData dataWithContentsOfURL: urlImage];
                FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData: data];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"dispatch_get_main_queue");
                    NSLog(@"cell.bannerImageView.animatedImage = image");
                    self.bannerImageView.animatedImage = image;
                    NSLog(@"cell.bannerImageView.animatedImage: %@", self.bannerImageView.animatedImage);
                    if (completionBlock)
                        completionBlock(indexPath, self);
                });
            });
        } else {
            NSLog(@"adData ad image: %@", [NSURL URLWithString: data[@"ad"][@"image"]]);
            [self.bannerImageView sd_setImageWithURL: [NSURL URLWithString: data[@"ad"][@"image"]] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                //[self checkToPresentViewOrNot: indexPath cell: cell];
                if (completionBlock)
                    completionBlock(indexPath, self);
            }];
        }
    }
}
@end
