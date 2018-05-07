//
//  HomeTableViewCell.h
//  wPinpinbox
//
//  Created by Angus on 2015/10/22.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

typedef void(^buttonTouch)(BOOL selected, NSString *userId);

@interface HomeTableViewCell : UITableViewCell
{
    //__weak IBOutlet UIView *v1;
    //__weak IBOutlet UIView *v2;
    //__weak IBOutlet UIView *v3;
    //__weak IBOutlet UIView *v4;
    
    __weak IBOutlet UIView *bgview;
}

//user
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet AsyncImageView *picture;
@property (strong,nonatomic) NSString *user_id;
@property (nonatomic, copy) buttonTouch customBlock;
@property (weak, nonatomic) IBOutlet UIButton *userBtn;

//時間
@property (weak, nonatomic) IBOutlet UILabel *difftime;

//相本資訊
@property (strong,nonatomic) NSString *album_id;
@property (weak, nonatomic) IBOutlet UILabel *album_name;
@property (weak, nonatomic) IBOutlet AsyncImageView *coverimageview;
@property (weak, nonatomic) IBOutlet AsyncImageView *previewimage1;
@property (weak, nonatomic) IBOutlet AsyncImageView *previewimage2;
@property (weak, nonatomic) IBOutlet AsyncImageView *previewImage3;
@property (weak, nonatomic) IBOutlet UIView *v1ForCover;
@property (weak, nonatomic) IBOutlet UIView *v2ForPreview1;
@property (weak, nonatomic) IBOutlet UIView *v3ForPreview2;
@property (weak, nonatomic) IBOutlet UIView *v4ForPreview3;

@property (weak, nonatomic) IBOutlet UIView *v1ForOnlyP1;
@property (weak, nonatomic) IBOutlet AsyncImageView *p1;
@property (weak, nonatomic) IBOutlet UIView *v2ForP1P2;
@property (weak, nonatomic) IBOutlet AsyncImageView *twoP1;
@property (weak, nonatomic) IBOutlet AsyncImageView *twoP2;


@property (weak, nonatomic) IBOutlet UIView *followview;
@property (weak, nonatomic) IBOutlet UILabel *followlab;

@property (weak, nonatomic) IBOutlet UILabel *viewedLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

//地址
@property (weak, nonatomic) IBOutlet UILabel *locatLab;
@property (weak, nonatomic) IBOutlet UIImageView *locationImage;

@end
