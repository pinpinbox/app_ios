//
//  NSURL_Param.h
//  wPinpinbox
//
//  Created by Antelis on 2018/12/17.
//  Copyright © 2018 Angus. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (queryParams)
- (NSString *)queryParam:(NSString *)param;
@end

NS_ASSUME_NONNULL_END
