//
//  NSArray+Reverse.m
//  wPinpinbox
//
//  Created by David on 2/14/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "NSArray+Reverse.h"

@implementation NSArray (Reverse)

- (NSArray *)reverseArray
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity: [self count]];
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    
    for (id element in enumerator) {
        [array addObject: element];
    }
    return array;
}

@end
