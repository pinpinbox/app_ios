//
//  ChooseVideoViewController.h
//  wPinpinbox
//
//  Created by David on 9/12/16.
//  Copyright © 2016 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChooseVideoViewController;
@protocol ChooseVideoViewDelegate <NSObject>
- (void)videoCropViewController: (ChooseVideoViewController *)controller videoArray: (NSArray *)videos;

@end

@interface ChooseVideoViewController : UIViewController
{
    __weak IBOutlet UICollectionView *myCov;
}

@property (nonatomic) NSString *photoType;
@property (assign) NSInteger selectRow;
@property (weak) id <ChooseVideoViewDelegate> delegate;
@end
