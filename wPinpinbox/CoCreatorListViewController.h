//
//  CoCreatorListViewController.h
//  wPinpinbox
//
//  Created by Antelis on 2018/9/18.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CoCreatorManageDelegate <NSObject>
@optional
- (void)processInviteUserWithIndex:(NSInteger)index;
- (void)processDeleteUserWithIndex:(NSInteger)index;
- (void)processChangeCoCreatorRankWithIndex:(NSInteger)index;
@end

@interface CoCreatorCell : UICollectionViewCell
@property (nonatomic) id<CoCreatorManageDelegate> coDelegate;
@property (nonatomic) NSInteger cindex;
@property (nonatomic) IBOutlet UIImageView *avatar;
@property (nonatomic) IBOutlet UILabel *userName;
@property (nonatomic) IBOutlet UIButton *inviteButton;
@end

@interface CoAdminCell : UICollectionViewCell
@property (nonatomic) id<CoCreatorManageDelegate> coDelegate;
@property (nonatomic) NSInteger cindex;
@property (nonatomic) IBOutlet UIImageView *avatar;
@property (nonatomic) IBOutlet UILabel *userName;
@property (nonatomic) IBOutlet UIButton *editButton;
@property (nonatomic) IBOutlet UIButton *manageButton;
@end

@interface CoCreatorListViewController : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource,CoCreatorManageDelegate>
@property (nonatomic) IBOutlet UICollectionView *creatorListView;
@property (nonatomic) IBOutlet UICollectionView *adminListView;
@property (nonatomic) IBOutlet UIView *searchView;
@property (nonatomic) IBOutlet UILabel *infoView;
@property (nonatomic) IBOutlet UITextField *searchField;
- (void)setAlbumId:(NSString *)aid;
@end

NS_ASSUME_NONNULL_END
