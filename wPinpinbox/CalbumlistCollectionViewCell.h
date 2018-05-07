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

@protocol CalbumlistDelegate <NSObject>
-(void)reloadData;
@end

@interface CalbumlistCollectionViewCell : UICollectionViewCell
{
    MTRadialMenu *menu;
}
@property (weak) id <CalbumlistDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIView *bgview;
@property (weak, nonatomic) IBOutlet AsyncImageView *picture;
@property (weak, nonatomic) IBOutlet UILabel *mytitle;
@property (weak, nonatomic) IBOutlet UILabel *mydate;
@property (weak, nonatomic) IBOutlet UIImageView *downimage;
@property (weak, nonatomic) IBOutlet UIView *stopview;
@property (weak, nonatomic) IBOutlet UIImageView *lockImgV;
@property (weak, nonatomic) IBOutlet UILabel *unfinishedLabel;

@property (nonatomic) NSString *templateid;
@property (nonatomic) NSString *albumid;
@property (nonatomic) NSString *userid;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic) NSString *identity;
@property (nonatomic, assign) BOOL zipped;

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
-(void)reloadmenu;

@end
