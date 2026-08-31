//
//  PrefsPanelController.h
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
//  Was a subclass of OmniAppKit's OAPreferenceController. OmniAppKit has been
//  removed; this is now a self-contained multi-pane preferences window built from
//  plain AppKit. The pages it shows are declared under the "PrefsPanelController"
//  key in Info.plist (identifier -> {title, icon, nib, ordering, hidden}).
//

#import <Cocoa/Cocoa.h>

@interface PrefsPanelController : NSObject <NSToolbarDelegate>
{
	NSWindow            *_window;
	NSArray             *_pages;        //ordered array of PrefsPageBase*
	NSMutableDictionary *_pagesById;    //identifier -> PrefsPageBase*
	NSToolbar           *_toolbar;
	NSString            *_currentPageId;
}

+ (PrefsPanelController*) sharedPreferenceController;

- (IBAction) showPreferencesPanel: (id) sender;

@end
