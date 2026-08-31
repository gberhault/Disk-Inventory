//
//  OAToolbarWindowControllerEx.h
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
//  Was a subclass of OmniAppKit's OAToolbarWindowController. OmniAppKit has been
//  removed; this is now a self-contained NSWindowController that builds its
//  NSToolbar from a "<toolbarConfigurationName>.toolbar" plist resource (the same
//  format OAToolbarWindowController used), deriving item labels/tooltips from the
//  matching main-menu items.
//

#import <Cocoa/Cocoa.h>

//Helper used during menu/toolbar validation so a toolbar item can be validated
//through -validateMenuItem: (which also updates its on/off/mixed-state image).
@interface NSToolbarItemValidationAdapter : NSObject
{
	NSToolbarItem* _toolbarItem;
}

- (void) setToolbarItem: (NSToolbarItem*) toolbarItem;

@end

@interface OAToolbarWindowControllerEx : NSWindowController <NSToolbarDelegate>
{
	NSDictionary *_toolbarConfig;   //parsed ".toolbar" plist
	NSToolbar    *_toolbar;
}

//subclasses override to name the ".toolbar" plist resource (without extension)
- (NSString *) toolbarConfigurationName;

//returns an image for a toolbar item with a specific state (NSControlStateValueOn/Off/Mixed)
- (NSImage*) toolbar: (NSToolbar*) theToolbar imageForToolbarItem: (NSToolbarItem*) item forState: (NSInteger) state;

// properties used to resolve the "target" keypath in the .toolbar plist
@property (readonly) NSDocumentController *documentController;
@property (readonly) NSApplication *application;

@end
