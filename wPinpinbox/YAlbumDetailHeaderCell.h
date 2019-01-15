//
//  YAlbumDetailHeaderCell.h
//  wPinpinbox
//
//  Created by Antelis on 2019/1/7.
//  Copyright © 2019 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YAlbumDetailHeaderCell : UITableViewCell
@property (nonatomic) IBOutlet UIImageView *albumHeader;
@property (nonatomic) IBOutlet UIButton *viewBtn;
@end

@protocol DetailCellProtocal
- (void)loadData:(NSDictionary *)data;
+ (CGFloat)estimatedHeight:(NSDictionary *)data;
@end

@interface YAlbumTitleCell : UITableViewCell<DetailCellProtocal>
@property (nonatomic) IBOutlet UILabel *titleLabel;
@end

@interface YAlbumLocationCell : UITableViewCell<DetailCellProtocal>
@property (nonatomic) IBOutlet UIImageView *locIcon;
@property (nonatomic) IBOutlet UILabel *viewedCountLabel;
@property (nonatomic) IBOutlet UILabel *locationLabel;
@end
@interface YAlbumContentTypeCell : UITableViewCell<DetailCellProtocal>
@property (nonatomic) IBOutlet UIImageView *vidIcon;
@property (nonatomic) IBOutlet UIImageView *audIcon;
@property (nonatomic) IBOutlet UIImageView *giftIcon;
@property (nonatomic) IBOutlet NSLayoutConstraint *audioLeading;
@property (nonatomic) IBOutlet NSLayoutConstraint *giftLeading;
+ (BOOL)ifVisible:(NSDictionary *)data;
@end
@interface YAlbumDescCell : UITableViewCell<DetailCellProtocal>
@property (nonatomic) IBOutlet UITextView *albumDesc;
@end
@interface YAlbumFollowerCell : UITableViewCell<DetailCellProtocal>
@property (nonatomic) IBOutlet UILabel *followerCount;
@end
@interface YAlbumPointCell: UITableViewCell<DetailCellProtocal>
@property (nonatomic) IBOutlet UILabel *pointCount;
@end
@interface YAlbumMessageCell: UITableViewCell<DetailCellProtocal>
@property (nonatomic) IBOutlet UILabel *messageCount;
@end
@interface YAlbumCreatorCell: UITableViewCell<DetailCellProtocal>
@property (nonatomic) IBOutlet UILabel *creatorName;
@property (nonatomic) IBOutlet UIImageView *creatorAvatar;
@property (nonatomic) IBOutlet UIButton *creatorWorks;
@end
@interface YAlbumEventCell: UITableViewCell<DetailCellProtocal>
@property (nonatomic) IBOutlet UITextView *eventDesc;
@property (nonatomic) IBOutlet UIButton *voteBtn;
@end


NS_ASSUME_NONNULL_END
