//
//  OAToolbarWindowControllerEx.m
//  Disk Inventory X
//
//  Created by Tjark Derlien on 01.12.04.
//
//  Copyright (C) 2004 Tjark Derlien.
//
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 3
//  of the License, or any later version.
//

#import "OAToolbarWindowControllerEx.h"

@implementation NSToolbarItemValidationAdapter

- (void) setToolbarItem: (NSToolbarItem*) toolbarItem
{
	[toolbarItem retain];
	[_toolbarItem release];
	_toolbarItem = toolbarItem;
}

//The validation code (-validateMenuItem:) may send -setTitle: to this adapter as if it
//were a menu item. For a toolbar item the label is fixed (derived from the plist/menu),
//so relabelling is a no-op here.
- (void) setTitle: (NSString*) title
{
}

- (void) forwardInvocation: (NSInvocation*) anInvocation
{
	if ( [_toolbarItem respondsToSelector: [anInvocation selector]] )
	{
		[anInvocation setTarget: _toolbarItem];
		[anInvocation invoke];
	}
	else
		[super forwardInvocation: anInvocation];
}

- (NSMethodSignature *) methodSignatureForSelector:(SEL)aSelector
{
	if ( [_toolbarItem respondsToSelector: aSelector] )
		return [_toolbarItem methodSignatureForSelector: aSelector];
	else
		return [super methodSignatureForSelector: aSelector];
}

- (void)setState:(NSInteger)itemState
{
	OAToolbarWindowControllerEx *controller = (OAToolbarWindowControllerEx *)[[_toolbarItem toolbar] delegate];

    if ( [controller respondsToSelector:@selector(toolbar:imageForToolbarItem:forState:)] )
    {
        NSImage *image = [controller toolbar: [_toolbarItem toolbar]
                         imageForToolbarItem: _toolbarItem
                                    forState: itemState];

        if ( image != nil && image != [_toolbarItem image] )
            [_toolbarItem setImage: image];
    }
}

@end


@interface NSMenu(FindExtensions)

- (NSMenuItem*) menuItemWithAction: (SEL) action;

@end

static NSToolbarItemValidationAdapter *g_toolbarItemValidationAdapter = nil;
static NSMutableDictionary *g_toolbatStateImages = nil;

@implementation OAToolbarWindowControllerEx

#pragma mark -----------------Toolbar support---------------------

+ (void) initialize
{
	g_toolbarItemValidationAdapter = [[NSToolbarItemValidationAdapter alloc] init];
	g_toolbatStateImages = [[NSMutableDictionary alloc] init];
}

- (void) dealloc
{
	[_toolbar release];
	[_toolbarConfig release];
	[super dealloc];
}

//subclasses override
- (NSString *) toolbarConfigurationName
{
	return nil;
}

- (void) windowDidLoad
{
	[super windowDidLoad];

	NSString *name = [self toolbarConfigurationName];
	if ( name != nil && [[self window] toolbar] == nil )
	{
		NSString *path = [[NSBundle mainBundle] pathForResource: name ofType: @"toolbar"];
		_toolbarConfig = [[NSDictionary dictionaryWithContentsOfFile: path] retain];
		NSAssert1( _toolbarConfig != nil, @"couldn't load toolbar configuration '%@.toolbar'", name );

		_toolbar = [[NSToolbar alloc] initWithIdentifier: name];
		[_toolbar setDelegate: self];
		[_toolbar setAllowsUserCustomization: YES];
		[_toolbar setAutosavesConfiguration: YES];

		[[self window] setToolbar: _toolbar];
	}
}

//raw (unlocalized) info dictionary for a toolbar item, straight from the .toolbar plist
- (NSDictionary *) rawItemInfoForItem: (NSString*) identifier
{
	return [[_toolbarConfig objectForKey: @"itemInfoByIdentifier"] objectForKey: identifier];
}

//returns an image for a toolbar item with a specific state (on/off/mixed, like menu items)
- (NSImage*) toolbar: (NSToolbar*) theToolbar imageForToolbarItem: (NSToolbarItem*) item forState: (NSInteger) state;
{
	NSString *imageKey = nil;
	switch( state )
	{
		case NSControlStateValueOn:
			imageKey = @"imageName";
			break;
		case NSControlStateValueOff:
			imageKey = @"imageNameOffState";
			break;
		case NSControlStateValueMixed:
			imageKey = @"imageNameMixedState";
			break;
		default:
			NSAssert( NO, @"invalid item state for ToolbarItem" );
	}

	//get the image cache for our toolbar
	NSMutableDictionary *toolbarImageCache = [g_toolbatStateImages objectForKey: [self toolbarConfigurationName]];
	if ( toolbarImageCache == nil )
	{
		toolbarImageCache = [NSMutableDictionary dictionary];
		[g_toolbatStateImages setObject: toolbarImageCache forKey: [self toolbarConfigurationName]];
	}

	//get image cache for the toolbar item
	NSMutableDictionary *itemImageCache = [toolbarImageCache objectForKey: [item itemIdentifier]];
	if ( itemImageCache == nil )
	{
		itemImageCache = [NSMutableDictionary dictionary];
		[toolbarImageCache setObject: itemImageCache forKey: [item itemIdentifier]];
	}

	//get the state image from the toolbar item image cache
	NSImage *image = [itemImageCache objectForKey: imageKey];
	if ( image == nil )
	{
		NSDictionary *itemInfo = [self rawItemInfoForItem: [item itemIdentifier]];

		//get image name from info dictionary
		NSString *imageName = [itemInfo objectForKey: imageKey];
		if ( imageName == nil )
			imageName = [itemInfo objectForKey: @"imageName"];

		NSAssert1( imageName != nil, @"no image name for item '%@'", [item itemIdentifier] );

		image = [NSImage imageNamed: imageName];
		NSAssert1( image != nil, @"couldn't load image '%@'", imageName );

		[itemImageCache setObject: image forKey: imageKey];
	}

	return image;
}

- (NSDictionary *)toolbarInfoForItem:(NSString *)identifier;
{
	NSDictionary *rawInfo = [self rawItemInfoForItem: identifier];
	if ( rawInfo == nil )
		return nil;

	NSMutableDictionary *itemInfo = [NSMutableDictionary dictionaryWithDictionary: rawInfo];

	//localize existing strings
#define LOCALIZE_PROPERTY( propname )									\
	if ( ![NSString isEmptyString: [itemInfo objectForKey: propname]] )	\
	{																	\
		NSString *localized = NSLocalizedString( [itemInfo objectForKey: propname], @"" ); \
		[itemInfo setObject: localized forKey: propname];				\
	}

	LOCALIZE_PROPERTY( @"label" );
	LOCALIZE_PROPERTY( @"paletteLabel" );
	LOCALIZE_PROPERTY( @"toolTip" );

#undef LOCALIZE_PROPERTY

	//We now try get the title and tooltip for the toolbar item from the menu.
	//This is done by searching for a menu item with the same action as the toolbar item.
	//Doing this, we don't need to type indentical strings in both the menu resource and the toolbar resource (.toolbar plist file).
	//And they only need to be localized in one place!

	NSString *actionString = [itemInfo objectForKey:@"action"];
	//did someone forgot the ':' at the end of the string? (actions always have the sender as a parameter)
	if ( ![NSString isEmptyString: actionString] && [actionString characterAtIndex: [actionString length] -1] != ':' )
	{
		actionString = [actionString stringByAppendingString: @":"];
		[itemInfo setObject: actionString forKey:@"action"];
	}

	SEL action = NSSelectorFromString( actionString );

	if (  action != 0
		  && ( [itemInfo objectForKey:@"label"] == nil || [itemInfo objectForKey:@"toolTip"] == nil ) )
	{
		NSMenuItem * menuItem = [[NSApp mainMenu] menuItemWithAction: action];
		if ( menuItem != nil )
		{
			//set label?
			if ( [itemInfo objectForKey:@"label"] == nil && ![NSString isEmptyString: [menuItem title]] )
			{
				//delete periods at end of title (e.g. "Preferences...")
				NSString *title = [menuItem title];
				NSUInteger numOfRemainingChars = [title length];
				unichar lastChar;
				do
				{
					numOfRemainingChars--;
					lastChar = [title characterAtIndex: numOfRemainingChars];
				}
				while ( ( lastChar == '.' || isspace(lastChar) ) && numOfRemainingChars > 0 );
				title = [title substringToIndex: numOfRemainingChars+1];

				[itemInfo setObject: title forKey: @"label"];
			}
			//set tooltip?
			if ( [itemInfo objectForKey:@"toolTip"] == nil && ![NSString isEmptyString: [menuItem toolTip]] )
				[itemInfo setObject: [menuItem toolTip] forKey: @"toolTip"];
		}
	}

	//if no string for "paletteLabel" is set, use the one for "label"
	//(the paletteLabel is used as the toolbar item's title in the customizable sheet)
	if ( [itemInfo objectForKey:@"paletteLabel"] == nil )
	{
		if ( [itemInfo objectForKey:@"label"] != nil )
			[itemInfo setObject: [itemInfo objectForKey:@"label"] forKey: @"paletteLabel"];
	}

    return itemInfo;
}

#pragma mark -----------------NSToolbarDelegate---------------------

- (NSArray<NSToolbarItemIdentifier> *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
	return [_toolbarConfig objectForKey: @"defaultItemIdentifiers"];
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
	return [_toolbarConfig objectForKey: @"allowedItemIdentifiers"];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)aToolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)willInsert
{
	NSDictionary *itemInfo = [self toolbarInfoForItem: itemIdentifier];

	//standard items (space, flexible space, separator, customize) are handled by AppKit
	if ( itemInfo == nil )
		return nil;

	NSToolbarItem *toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier] autorelease];

	NSString *label = [itemInfo objectForKey: @"label"];
	if ( label != nil )
		[toolbarItem setLabel: label];

	NSString *paletteLabel = [itemInfo objectForKey: @"paletteLabel"];
	[toolbarItem setPaletteLabel: paletteLabel != nil ? paletteLabel : ( label != nil ? label : itemIdentifier )];

	NSString *toolTip = [itemInfo objectForKey: @"toolTip"];
	if ( toolTip != nil )
		[toolbarItem setToolTip: toolTip];

	NSString *imageName = [itemInfo objectForKey: @"imageName"];
	if ( imageName != nil )
	{
		NSImage *image = [NSImage imageNamed: imageName];
		NSAssert1( image != nil, @"couldn't load toolbar image '%@'", imageName );
		[toolbarItem setImage: image];
	}

	SEL action = NSSelectorFromString( [itemInfo objectForKey: @"action"] );
	if ( action != 0 )
		[toolbarItem setAction: action];

	//resolve an explicit target keypath (e.g. "documentController"); otherwise the item
	//targets the first responder (target == nil), letting the responder chain handle it.
	NSString *targetKeyPath = [itemInfo objectForKey: @"target"];
	if ( ![NSString isEmptyString: targetKeyPath] )
		[toolbarItem setTarget: [self valueForKeyPath: targetKeyPath]];

	return toolbarItem;
}

// target keypaths referenced from the .toolbar plist

- (NSDocumentController*) documentController
{
    return [NSDocumentController sharedDocumentController];
}

- (NSApplication*) application
{
    return NSApp;
}


// NSObject (NSToolbarItemValidation)

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem;
{
    if ( ![[self window] isKeyWindow] )
		return NO;

	[g_toolbarItemValidationAdapter setToolbarItem: theItem];

	return [self validateMenuItem: (NSMenuItem*) g_toolbarItemValidationAdapter];
}

@end


@implementation NSMenu(FindExtensions)

//linear search through all menu items (including sub menus)
- (NSMenuItem*) menuItemWithAction: (SEL) action
{
	//we enumerate backwards as for the main menu bar the more application specific actions
	//are often in the menus after "File" and "Edit", so it is more likely to find the
	//item in question in the rear menus (this may not apply to sub menus, but we do a linar search anyway)
	NSInteger i = [self numberOfItems];
	while ( i-- )
	{
		NSMenuItem *menuItem = [self itemAtIndex: i];

		if ( [menuItem action] == action )
			return menuItem;

		if ( [menuItem hasSubmenu] )
		{
			menuItem = [[menuItem submenu] menuItemWithAction: action];
			if ( menuItem != nil )
				return menuItem;
		}
	}

	//not found
	return nil;
}

@end
