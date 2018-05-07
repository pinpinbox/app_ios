//
//  NSString+passwordValidation.m
//  wPinpinbox
//
//  Created by vmage on 6/22/16.
//  Copyright © 2016 Angus. All rights reserved.
//

#import "NSString+passwordValidation.h"

@implementation NSString (passwordValidation)
- (BOOL)isPasswordValid
{
    //NSString *stricterFilterString = @"^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,18}$";
    NSString *stricterFilterString = @"^(?=.{8,18}$).*";
        
    NSPredicate *passwordTest = [NSPredicate predicateWithFormat: @"SELF MATCHES %@", stricterFilterString];
    return [passwordTest evaluateWithObject: self];
}

@end
