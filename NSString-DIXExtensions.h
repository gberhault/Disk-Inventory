//
//  NSString-DIXExtensions.h
//  Disk Inventory X
//
//  Local replacement for the OmniFoundation NSString(OFExtensions) helpers
//  the app relied on, so the OmniFoundation framework can be removed.
//
//  Copyright (C) 2024 Tjark Derlien.
//
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 3
//  of the License, or any later version.
//

#import <Foundation/Foundation.h>

@interface NSString (DIXExtensions)

//YES if the string is nil or has zero length (matches OmniFoundation's +isEmptyString:)
+ (BOOL)isEmptyString:(NSString *)string;

@end
