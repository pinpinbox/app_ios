//
//  YAlbumDetailHeaderCell.h
//  wPinpinbox
//
//  Created by Antelis on 2019/1/7.
//  Copyright © 2019 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DetailCellProtocal
- (void)loadData:(NSDictionary *)data;
+ (CGFloat)estimatedHeight:(NSDictionary *)data;
@end

@interface UIKernedButton : UIButton
@property IBInspectable CGFloat spacing;
@end

@interface UIKernedLabel : UILabel
@property IBInspectable CGFloat spacing;
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
@property (nonatomic) IBOutlet UIKernedButton *creatorWorks;
@end
@interface YAlbumEventCell: UITableViewCell<DetailCellProtocal>
@property (nonatomic) IBOutlet UILabel *eventDesc;
@property (nonatomic) IBOutlet UIKernedButton *voteBtn;
@end


NS_ASSUME_NONNULL_END
