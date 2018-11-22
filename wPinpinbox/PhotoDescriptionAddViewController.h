//
//  PhotoDescriptionAddViewController.h
//  wPinpinbox
//
//  Created by Antelis on 2018/11/22.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationMapViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^DescSubmitBlock)(NSString *desc);

@interface PhotoDescriptionAddViewController : LocationMapViewController
- (void)addDesc:(NSString *)desc submitBlock:(DescSubmitBlock)submitBlock;
@end

NS_ASSUME_NONNULL_END
