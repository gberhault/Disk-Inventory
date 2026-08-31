//
//  NSString-DIXExtensions.m
//  Disk Inventory X
//
//  Copyright (C) 2024 Tjark Derlien.
//
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 3
//  of the License, or any later version.
//

#import "NSString-DIXExtensions.h"

@implementation NSString (DIXExtensions)

+ (BOOL)isEmptyString:(NSString *)string;
{
    //nil is an empty string; otherwise check length. Guard against non-NSString just in case.
    return string == nil
        || (![string isKindOfClass:[NSString class]])
        || [string length] == 0;
}

@end
