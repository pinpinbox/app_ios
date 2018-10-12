//
//  CalbumlistViewController.h
//  wPinpinbox
//
//  Created by Angus on 2015/10/23.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CalbumlistViewControllerDelegate <NSObject>
@optional
- (void)editPhoto:(NSString *)albumId
       templateId:(NSString *)templateId
  shareCollection:(BOOL)shareCollection
         hasImage:(BOOL)hasImage;
- (void)editCooperation:(NSString *)albumId
               identity:(NSString *)identity;
- (void)toReadBookController: (NSString *)albumId;
- (void)shareLink:(NSString *)sharingStr
          albumId:(NSString *)albumId;
@end

@interface CalbumlistViewController : UIViewController {
    __weak IBOutlet UILabel *wtitle;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectioview;
//@property (weak, nonatomic) IBOutlet UIButton *btn1;
//@property (weak, nonatomic) IBOutlet UIButton *btn2;
//@property (weak, nonatomic) IBOutlet UIButton *btn3;

@property (nonatomic) NSInteger collectionType;
@property (weak) id <CalbumlistViewControllerDelegate> delegate;
- (void)checkRefreshContent;
- (void)reloadData;
- (void)loadDataWhenChangingPage:(NSInteger)page;
@end
