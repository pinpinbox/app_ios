//
//  MyAlbumCollectionViewController.h
//  wPinpinbox
//
//  Created by David on 6/18/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MyAlbumCollectionViewControllerDelegate <NSObject>
- (void)toReadBookController: (NSString *)albumId;
@end

@interface MyAlbumCollectionViewController : UIViewController
@property (weak) id <MyAlbumCollectionViewControllerDelegate> delegate;
@end
