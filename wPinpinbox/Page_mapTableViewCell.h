//
//  Page_mapTableViewCell.h
//  wPinpinbox
//
//  Created by Angus on 2015/12/14.
//  Copyright © 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface Page_mapTableViewCell : UITableViewCell{
    __weak IBOutlet MKMapView *mapview;

}
-(void)showloc:(float)lat :(float)lon;
@end
