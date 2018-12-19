//
//  NSURL_Param.m
//  wPinpinbox
//
//  Created by Antelis on 2018/12/17.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "NSURL+Param.h"

@implementation NSURL (quertParams)
- (NSString *)queryParam:(NSString *)param; {
    NSURLComponents *u = [NSURLComponents componentsWithString:self.absoluteString];
    if (u == nil) return @"";
    NSMutableString *result = [NSMutableString stringWithString:@""];
    [u.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.name isEqualToString:param]) {
            [result setString: obj.value];
            *stop = YES;
        }
    }];
    
    return result;
    
}
@end

