//
//  ExistingAlbumViewController.h
//  wPinpinbox
//
//  Created by vmage on 9/2/16.
//  Copyright © 2016 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExistingAlbumViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSArray *templateArray;
@property (nonatomic, strong) NSString *eventId;

@end