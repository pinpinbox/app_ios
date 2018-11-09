//
//  NSMutableArray+Reverse.m
//  wPinpinbox
//
//  Created by David on 2/14/17.
//  Copyright © 2017 Angus. All rights reserved.
//

#import "NSMutableArray+Reverse.h"

@implementation NSMutableArray (Reverse)

- (void)reverse
{
    if ([self count] <= 1)
        return;
    
    NSUInteger i = 0;
    NSUInteger j = [self count] - 1;
    
    while (i < j) {
        [self exchangeObjectAtIndex: i
                  withObjectAtIndex: j];
        i++;
        j--;
    }
}

@end
