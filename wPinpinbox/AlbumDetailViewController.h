//
//  AlbumDetailViewController.h
//  wPinpinbox
//
//  Created by David on 10/01/2018.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "ParallaxViewController.h"

#import <UIKit/UIKit.h>
#import "ParallaxViewController.h"

@interface AlbumDetailViewController : ParallaxViewController
@property (strong, nonatomic) NSDictionary *data;
@property (strong, nonatomic) NSString *albumId;
@property (nonatomic) BOOL getMessagePush;
@property (nonatomic) NSString *fromVC;

@property (nonatomic) UIImage *snapShotImage;
@end
