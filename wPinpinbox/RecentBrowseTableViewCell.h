//
//  RecentBrowseTableViewCell.h
//  wPinpinbox
//
//  Created by David on 1/20/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecentBrowseTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *browseImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;

@end
