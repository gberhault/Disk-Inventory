//
//  NSURLExtensionsTests.m
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
#import <Cocoa/Cocoa.h>
#import "NSURL-Extensions.h"

@interface NSURLExtensionsTests : XCTestCase
@end

@implementation NSURLExtensionsTests
{
    NSFileManager *_fm;
    NSURL *_tempDir;
}

- (void)setUp
{
    _fm = [NSFileManager defaultManager];
    NSString *unique = [@"DIXTests-" stringByAppendingString:[[NSUUID UUID] UUIDString]];
    _tempDir = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:unique] isDirectory:YES];
    [_fm createDirectoryAtURL:_tempDir withIntermediateDirectories:YES attributes:nil error:NULL];
}

- (void)tearDown
{
    [_fm removeItemAtURL:_tempDir error:NULL];
    _tempDir = nil;
}

- (NSURL *)writeFileNamed:(NSString *)name bytes:(NSUInteger)count
{
    NSURL *url = [_tempDir URLByAppendingPathComponent:name];
    XCTAssertTrue([[NSMutableData dataWithLength:count] writeToURL:url atomically:YES]);
    return url;
}

- (void)testRegularFileIsFileAndNotDirectory
{
    NSURL *file = [self writeFileNamed:@"a.bin" bytes:10];
    XCTAssertTrue([file isFile]);
    XCTAssertFalse([file isDirectory]);
}

- (void)testDirectoryIsDirectoryAndNotFile
{
    XCTAssertTrue([_tempDir isDirectory]);
    XCTAssertFalse([_tempDir isFile]);
}

- (void)testNameIsTheFileName
{
    NSURL *file = [self writeFileNamed:@"report.txt" bytes:1];
    XCTAssertEqualObjects([file name], @"report.txt");
}

- (void)testLogicalSizeMatchesBytesWritten
{
    NSURL *file = [self writeFileNamed:@"sized.bin" bytes:1234];
    XCTAssertEqual([[file logicalSize] longLongValue], 1234LL);
}

- (void)testStillExistsReflectsRemoval
{
    NSURL *file = [self writeFileNamed:@"temp.bin" bytes:4];
    XCTAssertTrue([file stillExists]);
    [_fm removeItemAtURL:file error:NULL];
    XCTAssertFalse([file stillExists]);
}

- (void)testResidesInDirectory
{
    NSURL *file = [self writeFileNamed:@"child.bin" bytes:2];
    XCTAssertTrue([file residesInDirectoryURL:_tempDir]);

    NSURL *otherDir = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]] isDirectory:YES];
    [_fm createDirectoryAtURL:otherDir withIntermediateDirectories:YES attributes:nil error:NULL];
    XCTAssertFalse([file residesInDirectoryURL:otherDir]);
    [_fm removeItemAtURL:otherDir error:NULL];
}

- (void)testIsEqualToURL
{
    NSURL *file = [self writeFileNamed:@"same.bin" bytes:3];
    NSURL *sameAgain = [_tempDir URLByAppendingPathComponent:@"same.bin"];
    NSURL *different = [self writeFileNamed:@"other.bin" bytes:3];

    XCTAssertTrue([file isEqualToURL:sameAgain]);
    XCTAssertFalse([file isEqualToURL:different]);
}

@end
