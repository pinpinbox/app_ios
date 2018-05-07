//
//  CheckExchangeViewController.h
//  wPinpinbox
//
//  Created by David on 08/03/2018.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CheckExchangeViewController;
@class CheckExchangeCollectionViewCell;
@class ExchangeStuff;

#pragma mark - Delegate functions
@protocol CheckExchangeViewControllerDelegate <NSObject>
- (void)didSelectCell:(UICollectionView *)collectionView
                 cell:(CheckExchangeCollectionViewCell *)selectedCell
          exchangeDic:(NSMutableDictionary *)exchangeDic
         hasExchanged:(BOOL)hasExchanged;
@end

@interface CheckExchangeViewController : UIViewController
@property (nonatomic) BOOL hasExchanged;
@property (weak) id <CheckExchangeViewControllerDelegate> delegate;

- (void)removeDicData:(NSMutableDictionary *)dic;
- (void)addDicData:(NSMutableDictionary *)dic;

@end
