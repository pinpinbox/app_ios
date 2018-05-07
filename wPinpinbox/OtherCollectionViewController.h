//
//  OtherCollectionViewController.h
//  wPinpinbox
//
//  Created by David on 6/18/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol OtherCollectionViewControllerDelegate <NSObject>
- (void)toReadBookController: (NSString *)albumId;
@end

@interface OtherCollectionViewController : UIViewController
@property (weak) id <OtherCollectionViewControllerDelegate> delegate;
@end
