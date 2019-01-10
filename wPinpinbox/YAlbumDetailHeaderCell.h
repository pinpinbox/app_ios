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

@interface YAlbumTitleCell : UITableViewCell
@property (nonatomic) IBOutlet UILabel *titleLabel;
@end

@interface YAlbumLocationCell : UITableViewCell
@property (nonatomic) IBOutlet UILabel *locationLabel;
@end
@interface YAlbumContentTypeCell : UITableViewCell
@property (nonatomic) IBOutlet UIImageView *vidIcon;
@property (nonatomic) IBOutlet UIImageView *audIcon;
@property (nonatomic) IBOutlet UIImageView *giftIcon;
@end
@interface YAlbumDescCell : UITableViewCell
@property (nonatomic) IBOutlet UITextView *albumDesc;
@end
@interface YAlbumFollowerCell : UITableViewCell
@property (nonatomic) IBOutlet UILabel *followerCount;
@end
@interface YAlbumPointCell: UITableViewCell
@property (nonatomic) IBOutlet UILabel *pointCount;
@end
@interface YAlbumMessageCell: UITableViewCell
@property (nonatomic) IBOutlet UILabel *messageCount;
@end
@interface YAlbumCreatorCell: UITableViewCell
@property (nonatomic) IBOutlet UILabel *creatorName;
@property (nonatomic) IBOutlet UIImageView *creatorAvatar;
@property (nonatomic) IBOutlet UIButton *creatorWorks;
@end
@interface YAlbumEventCell: UITableViewCell
@property (nonatomic) IBOutlet UITextView *eventDesc;
@property (nonatomic) IBOutlet UIButton *voteBtn;
@end


NS_ASSUME_NONNULL_END
