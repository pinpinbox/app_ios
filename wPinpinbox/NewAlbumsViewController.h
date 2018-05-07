//
//  NewAlbumsViewController.h
//  wPinpinbox
//
//  Created by Angus on 2015/8/11.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "O_drag.h"
@interface NewAlbumsViewController : UIViewController<dragDelegate>
{
    O_drag *selectdrag;
}
@end
