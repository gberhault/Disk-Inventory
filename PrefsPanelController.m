//
//  PrefsPanelController.m
//  Disk Inventory X
//
//  Created by Tjark Derlien on 28.11.04.
//
//  Copyright (C) 2004 Tjark Derlien.
//
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 3
//  of the License, or any later version.
//

#import "PrefsPanelController.h"
#import "PrefsPageBase.h"

@implementation PrefsPanelController

+ (PrefsPanelController*) sharedPreferenceController
{
	static PrefsPanelController *sharedPreferenceController = nil;

	if (sharedPreferenceController == nil)
		sharedPreferenceController = [[self alloc] init];

	return sharedPreferenceController;
}

#pragma mark -----------------page loading---------------------

- (void) loadPages
{
	NSDictionary *records = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"PrefsPanelController"];

	NSMutableArray *pages = [NSMutableArray array];
	_pagesById = [[NSMutableDictionary alloc] init];

	for ( NSString *identifier in records )
	{
		NSDictionary *record = [records objectForKey: identifier];

		//skip hidden pages (e.g. the removed Finder plugin page)
		if ( [[record objectForKey: @"hidden"] boolValue] )
			continue;

		//the page's identifier is also the name of its controller class
		Class pageClass = NSClassFromString( identifier );
		if ( pageClass == Nil )
			pageClass = [PrefsPageBase class];

		PrefsPageBase *page = [[[pageClass alloc] initWithRecord: record] autorelease];
		[pages addObject: page];
		[_pagesById setObject: page forKey: identifier];
	}

	//order the pages by their "ordering" value
	[pages sortUsingComparator: ^NSComparisonResult(PrefsPageBase *a, PrefsPageBase *b) {
		NSInteger orderA = [[[records objectForKey: [a identifier]] objectForKey: @"ordering"] integerValue];
		NSInteger orderB = [[[records objectForKey: [b identifier]] objectForKey: @"ordering"] integerValue];
		if ( orderA < orderB ) return NSOrderedAscending;
		if ( orderA > orderB ) return NSOrderedDescending;
		return NSOrderedSame;
	}];

	_pages = [pages retain];
}

#pragma mark -----------------window---------------------

- (void) buildWindow
{
	NSRect contentRect = NSMakeRect( 0, 0, 400, 300 );
	_window = [[NSWindow alloc] initWithContentRect: contentRect
										  styleMask: (NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable)
											backing: NSBackingStoreBuffered
											  defer: YES];
	[_window setReleasedWhenClosed: NO];
	[_window setFrameAutosaveName: @"PreferencesWindow"];

	_toolbar = [[NSToolbar alloc] initWithIdentifier: @"PreferencesToolbar"];
	[_toolbar setDelegate: self];
	[_toolbar setAllowsUserCustomization: NO];
	[_toolbar setDisplayMode: NSToolbarDisplayModeIconAndLabel];
	[_window setToolbar: _toolbar];
}

- (NSArray<NSString*>*) pageIdentifiers
{
	NSMutableArray *ids = [NSMutableArray array];
	for ( PrefsPageBase *page in _pages )
		[ids addObject: [page identifier]];
	return ids;
}

- (void) showPageWithIdentifier: (NSString*) identifier
{
	PrefsPageBase *page = [_pagesById objectForKey: identifier];
	if ( page == nil )
		return;

	NSView *view = [page contentView];

	//swap in an empty content view first so the incoming view isn't autoresized while
	//the window animates to its new size
	NSRect newContentRect = NSMakeRect( 0, 0, NSWidth([view frame]), NSHeight([view frame]) );
	[_window setContentView: [[[NSView alloc] initWithFrame: newContentRect] autorelease]];

	NSRect oldFrame = [_window frame];
	NSRect newFrame = [_window frameRectForContentRect: newContentRect];
	//keep the window's top-left corner fixed
	newFrame.origin.x = oldFrame.origin.x;
	newFrame.origin.y = NSMaxY(oldFrame) - NSHeight(newFrame);

	[_window setFrame: newFrame display: YES animate: [_window isVisible]];
	[_window setContentView: view];

	[_window setTitle: [page title]];
	[_toolbar setSelectedItemIdentifier: identifier];
	[_currentPageId autorelease];
	_currentPageId = [identifier retain];
}

- (IBAction) selectPage: (id) sender
{
	[self showPageWithIdentifier: [(NSToolbarItem*)sender itemIdentifier]];
}

- (IBAction) showPreferencesPanel: (id) sender
{
	if ( _window == nil )
	{
		[self loadPages];
		[self buildWindow];
	}

	if ( _currentPageId == nil && [_pages count] > 0 )
	{
		[self showPageWithIdentifier: [[_pages objectAtIndex: 0] identifier]];
		[_window center];
	}

	[_window makeKeyAndOrderFront: sender];
}

#pragma mark -----------------NSToolbarDelegate---------------------

- (NSArray<NSToolbarItemIdentifier> *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
	return [self pageIdentifiers];
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
	return [self pageIdentifiers];
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
	return [self pageIdentifiers];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)willInsert
{
	PrefsPageBase *page = [_pagesById objectForKey: itemIdentifier];
	if ( page == nil )
		return nil;

	NSToolbarItem *item = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier] autorelease];
	[item setLabel: [page title]];
	[item setPaletteLabel: [page title]];

	NSString *iconName = [page iconName];
	if ( iconName != nil )
	{
		NSImage *image = [NSImage imageNamed: iconName];
		if ( image != nil )
			[item setImage: image];
	}

	[item setTarget: self];
	[item setAction: @selector(selectPage:)];

	return item;
}

@end
