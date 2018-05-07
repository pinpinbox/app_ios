//
//  FTWCache.h
//  wPinpinbox
//
//  Created by David on 2/22/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTWCache : NSObject

+ (void)resetCache;
+ (void)setObject:(NSData *)data forKey:(NSString *)key;
+ (id)objectForKey:(NSString *)key;

@end
