//
//  FileSizeFormatterTests.m
//  Disk Inventory X Tests
//
//  Copyright (C) 2024 Tjark Derlien.
//
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 3
//  of the License, or any later version.
//

#import <XCTest/XCTest.h>
#import "FileSizeFormatter.h"

@interface FileSizeFormatterTests : XCTestCase
@end

@implementation FileSizeFormatterTests
{
    FileSizeFormatter *_formatter;
}

- (void)setUp
{
    _formatter = [[FileSizeFormatter alloc] init];
}

- (void)tearDown
{
    _formatter = nil;
}

- (NSString *)stringForBytes:(double)bytes
{
    return [_formatter stringForObjectValue:[NSNumber numberWithDouble:bytes]];
}

// Bytes and kB are rendered as integers, so these are locale-independent.

- (void)testZeroBytes
{
    XCTAssertEqualObjects([self stringForBytes:0], @"0 Bytes");
}

- (void)testSmallByteCount
{
    XCTAssertEqualObjects([self stringForBytes:512], @"512 Bytes");
}

- (void)testJustUnderOneKilobyteStaysInBytes
{
    XCTAssertEqualObjects([self stringForBytes:999], @"999 Bytes");
}

- (void)testExactlyOneKilobyte
{
    // unit factor is 1000, so 1000 bytes -> "1 kB"
    XCTAssertEqualObjects([self stringForBytes:1000], @"1 kB");
}

- (void)testKilobytesAreRounded
{
    // 1500 / 1000 = 1.5, rounded to 2
    XCTAssertEqualObjects([self stringForBytes:1500], @"2 kB");
}

// For MB/GB/TB the decimal formatting is locale-dependent, so assert the unit
// selection and magnitude rather than the exact decimal string.

- (void)testMegabytesUseTheMBUnit
{
    NSString *result = [self stringForBytes:1000.0 * 1000.0];
    XCTAssertTrue([result hasSuffix:@"MB"], @"expected MB unit, got '%@'", result);
    XCTAssertTrue([result hasPrefix:@"1"], @"expected magnitude 1, got '%@'", result);
}

- (void)testGigabytesUseTheGBUnit
{
    NSString *result = [self stringForBytes:2.0 * 1000.0 * 1000.0 * 1000.0];
    XCTAssertTrue([result hasSuffix:@"GB"], @"expected GB unit, got '%@'", result);
}

- (void)testTerabytesUseTheTBUnit
{
    NSString *result = [self stringForBytes:1000.0 * 1000.0 * 1000.0 * 1000.0];
    XCTAssertTrue([result hasSuffix:@"TB"], @"expected TB unit, got '%@'", result);
}

@end
