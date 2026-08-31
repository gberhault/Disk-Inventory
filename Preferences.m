/*
 *  Preferences.m
 *  Disk Inventory X
 *
 *  Created by Tjark Derlien on 24.11.04.
 *  Copyright 2004 Tjark Derlien. All rights reserved.
 *
 */

#include "Preferences.h"

//keys for preference values
NSString *ShowPackageContents			= @"ShowPackageContents";
NSString *ShowFreeSpace					= @"ShowFreeSpace";
NSString *ShowOtherSpace				= @"ShowOtherSpace";
NSString *IgnoreCreatorCode				= @"IgnoreCreatorCode";
NSString *ShowPhysicalFileSize			= @"ShowPhysicalFileSize"; //logical size otherwise (like the Finder)
NSString *UseSmallFontInKindStatistic	= @"UseSmallFontInKindStatisticView";
NSString *UseSmallFontInFilesView		= @"UseSmallFontInFilesView";
NSString *UseSmallFontInSelectionList	= @"UseSmallFontInSelectionList";
NSString *SplitWindowHorizontally		= @"SplitWindowHorizontally";
NSString *AnimatedZooming				= @"AnimatedZooming";
NSString *EnableLogging					= @"EnableLogging";
NSString *DontShowDonationMessage        = @"DontShowDonationMessage";
NSString *DontShowPrivacyWarningMessage        = @"DontShowPrivacyWarningMessage";
NSString *ShareKindColors				= @"ShareKindColors";


#pragma mark ----------------- NSUserDefaults(VersionDepedantValues) -------------------

@implementation NSUserDefaults(VersionDepedantValues)

- (NSString*) mainBundleVersion
{
    static NSString * _bundleVersion = nil;
    if ( _bundleVersion == nil )
    {
        NSBundle *bundle = [NSBundle mainBundle];
        
        NSArray *keys = [NSArray arrayWithObjects: @"CFBundleShortVersionString", @"CFBundleGetInfoString", nil];
        NSDictionary *dict = [bundle infoDictionary];
                         
         for ( int i = 0;
              i < [keys count]
             && (_bundleVersion == nil || [_bundleVersion length] == 0);
             i++)
         {
             _bundleVersion = [dict objectForKey:[keys objectAtIndex:i]];
         }
    }
    return _bundleVersion == nil ? @"" : _bundleVersion;
}

- (NSString*) versionDependantKeyForKey: (NSString*) key
{
    NSString *mainBundleVer = [self mainBundleVersion];
    
    return [mainBundleVer length] > 0
            ? [key stringByAppendingFormat:@" v%@", mainBundleVer]
            : key;
}

- (bool) boolForVersionDependantKey: (NSString*) key
{
    return [self boolForKey:[self versionDependantKeyForKey:key]];
}

- (void) setBool: (BOOL) val forVersionDependantKey: (NSString*) key
{
    [self setBool: val forKey:[self versionDependantKeyForKey:key]];
}

@end

#pragma mark ----------------- NSMutableDictionary(PreferencesValues) -------------------

@interface NSMutableDictionary(DocumentPreferences_Private)
- (void) copyValuesFromSharedDefaults;
@end


// These helpers previously used OmniFoundation's NSMutableDictionary/NSDictionary
// -boolForKey:/-setBoolValue:forKey: category methods. OmniFoundation has been removed,
// so store/read the flags as NSNumber via the standard dictionary API instead.
@implementation NSMutableDictionary(PreferencesValues)

- (id) initWithDefaults
{
	self = [self init];

	[self copyValuesFromSharedDefaults];

	return self;
}

- (BOOL) boolValueForPreferenceKey: (NSString*) key
{
	return [[self objectForKey: key] boolValue];
}

- (void) setBoolValue: (BOOL) value forPreferenceKey: (NSString*) key
{
	[self setObject: [NSNumber numberWithBool: value] forKey: key];
}

- (BOOL) showPackageContents
{
	return [self boolValueForPreferenceKey: ShowPackageContents];
}

- (void) setShowPackageContents: (BOOL) value;
{
	[self setBoolValue: value forPreferenceKey: ShowPackageContents];
}

- (BOOL) showFreeSpace;
{
	return [self boolValueForPreferenceKey: ShowFreeSpace];
}

- (void) setShowFreeSpace: (BOOL) value;
{
	[self setBoolValue: value forPreferenceKey: ShowFreeSpace];
}

- (BOOL) showOtherSpace;
{
	return [self boolValueForPreferenceKey: ShowOtherSpace];
}

- (void) setShowOtherSpace: (BOOL) value;
{
	[self setBoolValue: value forPreferenceKey: ShowOtherSpace];
}

- (BOOL) ignoreCreatorCode;
{
	return [self boolValueForPreferenceKey: IgnoreCreatorCode];
}

- (void) setIgnoreCreatorCode: (BOOL) value
{
	[self setBoolValue: value forPreferenceKey: IgnoreCreatorCode];
}

- (BOOL) showPhysicalFileSize
{
	return [self boolValueForPreferenceKey: ShowPhysicalFileSize];
}

- (void) setShowPhysicalFileSize: (BOOL) value
{
	[self setBoolValue: value forPreferenceKey: ShowPhysicalFileSize];
}

@end

@implementation NSMutableDictionary(DocumentPreferences_Private)

- (void) copyValuesFromSharedDefaults
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

#define COPYVALUEBOOL( name ) [self setBoolValue: [defaults boolForKey: name] forPreferenceKey: name]

	COPYVALUEBOOL( ShowPackageContents );
	COPYVALUEBOOL( ShowFreeSpace );
	COPYVALUEBOOL( ShowOtherSpace );
	COPYVALUEBOOL( IgnoreCreatorCode );
	COPYVALUEBOOL( ShowPhysicalFileSize );

#undef COPYVALUEBOOL
}

@end

