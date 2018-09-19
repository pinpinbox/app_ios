//
//  CoCreatorListViewController.h
//  wPinpinbox
//
//  Created by Antelis on 2018/9/18.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CoCreatorCell : UICollectionViewCell
@property (nonatomic) IBOutlet UIImageView *avatar;
@property (nonatomic) IBOutlet UILabel *userName;
@property (nonatomic) IBOutlet UIButton *inviteButton;
@end

@interface CoAdminCell : UICollectionViewCell
@property (nonatomic) IBOutlet UIImageView *avatar;
@property (nonatomic) IBOutlet UILabel *userName;
@property (nonatomic) IBOutlet UIButton *editButton;
@property (nonatomic) IBOutlet UIButton *manageButton;
@end

@interface CoCreatorListViewController : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic) IBOutlet UICollectionView *creatorListView;
@property (nonatomic) IBOutlet UICollectionView *adminListView;
@property (nonatomic) IBOutlet UIView *searchView;
@end

NS_ASSUME_NONNULL_END
