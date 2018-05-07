//
//  CreativeCollectionReusableView.h
//  wPinpinbox
//
//  Created by Angus on 2015/10/28.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
@interface CreativeCollectionReusableView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet AsyncImageView *subImage;
@property (weak, nonatomic) IBOutlet AsyncImageView *topimage;
@property (weak, nonatomic) IBOutlet UILabel *countfrom;
@property (weak, nonatomic) IBOutlet UILabel *viewedLabel;
@property (weak, nonatomic) IBOutlet UITextView *bio;
@property (weak, nonatomic) IBOutlet UILabel *lab_text;
@property (weak, nonatomic) IBOutlet UIButton *followBtn;

@end
