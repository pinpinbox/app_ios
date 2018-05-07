//
//  Page_mapTableViewCell.m
//  wPinpinbox
//
//  Created by Angus on 2015/12/14.
//  Copyright © 2015年 Angus. All rights reserved.
//

#import "Page_mapTableViewCell.h"

@implementation Page_mapTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)showloc:(float)lat :(float)lon{
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(lat, lon), 3000, 3000);
    [mapview setRegion:[mapview regionThatFits:region] animated:NO];
    
}
@end
