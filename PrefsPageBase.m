//
//  PrefsPageBase.m
//  Disk Inventory X
//
//  Created by Tjark Derlien on 29.11.04.
//
//  Copyright (C) 2004 Tjark Derlien.
//
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 3
//  of the License, or any later version.
//

#import "PrefsPageBase.h"

@implementation PrefsPageBase

- (instancetype) initWithRecord: (NSDictionary*) record;
{
	self = [super init];
	if ( self != nil )
		_record = [record retain];

	return self;
}

- (void) dealloc
{
	[_topLevelObjects release];
	[_record release];
	[super dealloc];
}

- (NSString *) identifier;
{
	return [_record objectForKey: @"identifier"];
}

- (NSString *) title;
{
	NSString *title = [_record objectForKey: @"title"];
	return title != nil ? NSLocalizedString( title, @"" ) : [self identifier];
}

- (NSString *) iconName;
{
	return [_record objectForKey: @"icon"];
}

- (NSString *) nibName;
{
	return [_record objectForKey: @"nib"];
}

- (NSView*) contentView;
{
	if ( controlBox == nil )
	{
		NSNib *nib = [[[NSNib alloc] initWithNibNamed: [self nibName] bundle: nil] autorelease];
		NSArray *topLevelObjects = nil;

		if ( [nib instantiateWithOwner: self topLevelObjects: &topLevelObjects] )
			_topLevelObjects = [topLevelObjects retain];

		NSAssert1( controlBox != nil, @"preferences page nib '%@' did not connect the controlBox outlet", [self nibName] );
	}

	return controlBox;
}

@end
