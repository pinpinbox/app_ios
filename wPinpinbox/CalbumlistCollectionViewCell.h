//
//  CalbumlistCollectionViewCell.h
//  wPinpinbox
//
//  Created by Angus on 2015/10/27.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTRadialMenu.h"
#import "AsyncImageView.h"

typedef NS_ENUM(NSInteger, OpMenuActionType){
    OPEdit,
    OPInvite,
    OPShare,
    OPDelete,
    OPNone
};

@protocol CalbumlistDelegate <NSObject>
@optional
- (void)reloadData;
- (void)opMenuAction:(OpMenuActionType)action index:(NSInteger )index;
- (void)changeAlbumAct:(NSString *)albumid index:(NSInteger)index;
- (void)showCreatorPageWithUserid:(NSString *)userid;
@end

@interface CalbumlistCollectionViewCell : UICollectionViewCell
{
    //MTRadialMenu *menu;
}
@property (weak) id <CalbumlistDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIView *bgview;
@property (weak, nonatomic) IBOutlet AsyncImageView *picture;
@property (weak, nonatomic) IBOutlet UILabel *mytitle;
@property (weak, nonatomic) IBOutlet UILabel *mydate;
@property (weak, nonatomic) IBOutlet UIView *stopview;
@property (weak, nonatomic) IBOutlet UIButton *lockBtn;
@property (weak, nonatomic) IBOutlet UILabel *unfinishedLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coopConstraint;

@property (nonatomic) NSString *templateid;
@property (nonatomic) NSString *albumid;
@property (nonatomic) NSString *userid;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic) NSString *identity;
@property (nonatomic, assign) BOOL zipped;
@property (nonatomic, assign) NSInteger dataIndex;

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *opMenuLeading;
@property (weak, nonatomic) IBOutlet UIView *opMenu;
@property (weak, nonatomic) IBOutlet UIButton *opMenuClose;
@property (weak, nonatomic) IBOutlet UIButton *opMenuEdit;
@property (weak, nonatomic) IBOutlet UIButton *opMenuInvite;
@property (weak, nonatomic) IBOutlet UIButton *opMenuShare;
@property (weak, nonatomic) IBOutlet UIButton *opMenuDelete;

@property (weak, nonatomic) IBOutlet UIImageView *userAvatar;
@property (weak, nonatomic) IBOutlet UIImageView *coopIcon;
@property (weak, nonatomic) IBOutlet UILabel *coopLabel;

- (void)selfAlbumMode;
- (void)coopAlbumMode;
- (void)favAlbumMode;
- (void)setCoopNumber:(int)number;
@end
