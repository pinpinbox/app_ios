//
//  RetrievealbumpViewController.h
//  wPinpinbox
//
//  Created by Angus on 2015/10/26.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RetrievealbumpViewController : UIViewController
{
    __weak IBOutlet UILabel *lab_text;
    __weak IBOutlet UIButton *btn_report;
    //__weak IBOutlet UIButton *share;
}

@property (strong, nonatomic) NSString *albumid;

@property (strong, nonatomic) NSDictionary *data;
@property (strong, nonatomic) NSString *userid;

@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UILabel *mytitle;
//@property (weak, nonatomic) IBOutlet UIScrollView *myscrollview;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *local;
@property (weak, nonatomic) IBOutlet UIImageView *locationImage;

@property (weak, nonatomic) IBOutlet UITextView *descriptiontext;

@property (weak,nonatomic) IBOutlet UILabel *albumstatistics;

@property (weak, nonatomic) IBOutlet UIButton *openbtn;
@property (weak, nonatomic) IBOutlet UIButton *activitybtn;

@property (weak, nonatomic) IBOutlet UILabel *collectionNumber;
@property (weak, nonatomic) IBOutlet UIImageView *coverImage;

@property (weak, nonatomic) IBOutlet UIButton *readBtn;
@property (weak, nonatomic) IBOutlet UIButton *collectAndRead;

@property (weak, nonatomic) IBOutlet UIImageView *useForImage1;
@property (weak, nonatomic) IBOutlet UIImageView *useForImage2;
@property (weak, nonatomic) IBOutlet UIImageView *useForImage3;

@property (weak, nonatomic) IBOutlet UIImageView *navigationImageView;

@property (assign, nonatomic) BOOL fromXib;
@property (weak, nonatomic) IBOutlet UIImageView *bgImgForTextView;

@end
