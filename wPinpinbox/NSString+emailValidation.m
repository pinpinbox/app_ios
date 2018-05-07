//
//  NSString+emailValidation.m
//  wPinpinbox
//
//  Created by vmage on 6/22/16.
//  Copyright © 2016 Angus. All rights reserved.
//

#import "NSString+emailValidation.h"

@implementation NSString (emailValidation)

- (BOOL)isEmailValid
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$||([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]+[A-Za-z]{2}[A-Za-z]*$";
    //NSString *laxString = @"^([a-zA-Z0-9_\\-\\.]+)@((\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\\]?)$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat: @"SELF MATCHES %@", emailRegex];

    return [emailTest evaluateWithObject: self];
}

@end
