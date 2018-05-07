//
//  NewExistingAlbumViewController.h
//  wPinpinbox
//
//  Created by David Lee on 2017/9/26.
//  Copyright © 2017年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewExistingAlbumViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) NSArray *templateArray;
@property (nonatomic, strong) NSString *eventId;
@property (nonatomic) NSInteger contributionNumber;
@property (nonatomic) NSString *prefixText;
@property (nonatomic) NSString *specialUrl;
@end
