//
//  PhotosViewController.h
//  wPinpinbox
//
//  Created by Angus on 2015/8/11.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotosViewController;
@protocol PhotosViewDelegate <NSObject>
@optional
- (void)imageCropViewController:(PhotosViewController *)controller Image:(UIImage *)Image;
- (void)imageCropViewController:(PhotosViewController *)controller ImageArr:(NSArray *)Images compression: (CGFloat)compressionQuality;
- (void)afterSendingImages:(PhotosViewController *)controller;
@end

@interface PhotosViewController : UIViewController
{
    __weak IBOutlet UICollectionView *mycov;
}
//狀態1 = 多選
//狀態0 = 單選

// If photo type is 1 then you can select more than 1 image
// If photo type is 0 then you can only select 1 image
@property(nonatomic) NSString *phototype;
@property(assign) NSInteger selectrow;
@property(weak) id <PhotosViewDelegate>delegate;

@property (nonatomic) NSString *choice;
@property (nonatomic) NSInteger selectedImgAmount;
@property (nonatomic) NSString *fromVC;

@property (nonatomic) NSString *albumId;

@end
