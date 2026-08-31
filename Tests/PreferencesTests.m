//
//  PreferencesTests.m
//  Disk Inventory X Tests
//
//  Regression tests for the document-preferences dictionary helpers. These previously
//  used OmniFoundation's NSMutableDictionary -boolForKey:/-setBoolValue:forKey: category
//  methods; after OmniFoundation was removed those threw "unrecognized selector" at
//  runtime, which aborted -[FileSystemDoc init] and stopped any scan from starting.
//
//  Copyright (C) 2024 Tjark Derlien.
//
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 3
//  of the License, or any later version.
//

#import <XCTest/XCTest.h>
#import "Preferences.h"

@interface PreferencesTests : XCTestCase
@end

@implementation PreferencesTests

// Would have thrown -[__NSDictionaryM setBoolValue:forKey:]: unrecognized selector
// before the fix.
- (void)testPackageContentsRoundTrips
{
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];

    [options setShowPackageContents:YES];
    XCTAssertTrue([options showPackageContents]);

    [options setShowPackageContents:NO];
    XCTAssertFalse([options showPackageContents]);
}

- (void)testAllBoolFlagsRoundTrip
{
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];

    [options setShowFreeSpace:YES];
    [options setShowOtherSpace:YES];
    [options setIgnoreCreatorCode:YES];
    [options setShowPhysicalFileSize:YES];

    XCTAssertTrue([options showFreeSpace]);
    XCTAssertTrue([options showOtherSpace]);
    XCTAssertTrue([options ignoreCreatorCode]);
    XCTAssertTrue([options showPhysicalFileSize]);
}

// -initWithDefaults calls -copyValuesFromSharedDefaults, which is exactly the path that
// crashed inside -[FileSystemDoc init]. It must complete and return a usable dictionary.
- (void)testInitWithDefaultsDoesNotThrow
{
    NSMutableDictionary *options = [[NSMutableDictionary alloc] initWithDefaults];
    XCTAssertNotNil(options);
    // showPackageContents should return a valid BOOL derived from user defaults (no throw)
    XCTAssertNoThrow([options showPackageContents]);
}

@end
