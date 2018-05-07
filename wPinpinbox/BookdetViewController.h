//
//  BookdetViewController.h
//  wPinpinbox
//
//  Created by Angus on 2016/1/5.
//  Copyright (c) 2016年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBookSelectViewController.h"

@interface BookdetViewController : UIViewController<SBookSelectViewController>
{
    __weak IBOutlet UITextField *wtitle;
    __weak IBOutlet UITextView *wdescription;
    __weak IBOutlet UITextField *wlocation;
    __weak IBOutlet UIButton *wfirstpag;
    __weak IBOutlet UIButton *wsecondpag;
    __weak IBOutlet UIButton *wact;
    __weak IBOutlet UIButton *wweather;
    __weak IBOutlet UIButton *wmood;
    __weak IBOutlet UIButton *waudio;
    __weak IBOutlet UILabel *lab_title;
    
    __weak IBOutlet UILabel *notext;
        
    __weak IBOutlet UIButton *wqtbtn;
    
    // Album Name ImageView
    __weak IBOutlet UIImageView *anImageView;
    // Album Description ImageView
    __weak IBOutlet UIImageView *adImageView;
    // Primary ImageView
    __weak IBOutlet UIImageView *pImageView;
    // Secondary ImageView
    __weak IBOutlet UIImageView *sImageView;
    // Switch ImageView
    __weak IBOutlet UIImageView *switchImageView;
    __weak IBOutlet UIView *pickerUIView;
    __weak IBOutlet UIPickerView *selectedPicker;
}

@property(strong,nonatomic)NSDictionary *data;
@property(strong,nonatomic)NSString *album_id;
@property(strong,nonatomic)NSString *backType;
@property(strong,nonatomic)NSString *qrcode;
@property(nonatomic)NSString *templateid;
@property (nonatomic) NSString *eventId;
@property (nonatomic) BOOL postMode;
@property (nonatomic) BOOL fromEventPostVC;

@property (nonatomic) BOOL isRecorded;

@end
