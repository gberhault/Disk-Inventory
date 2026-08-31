//
//  PrefsPageBase.h
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
//  Was a subclass of OmniAppKit's OAPreferenceClient. OmniAppKit has been removed;
//  this is now a plain controller for one preferences page. It owns its page nib
//  (File's Owner) and exposes the top-level "controlBox" view to PrefsPanelController.
//  Each page's controls are wired to NSUserDefaultsController via bindings in the nib,
//  so the base needs no per-preference code.
//

#import <Cocoa/Cocoa.h>

@interface PrefsPageBase : NSObject
{
	IBOutlet NSView *controlBox;   //top-level view of the page nib
	NSArray         *_topLevelObjects;
	NSDictionary    *_record;      //this page's record from Info.plist (title, icon, nib, identifier)
}

- (instancetype) initWithRecord: (NSDictionary*) record;

@property (readonly) NSString *identifier;
@property (readonly) NSString *title;      //localized
@property (readonly) NSString *iconName;
@property (readonly) NSString *nibName;

//loads the page nib on first use and returns its top-level control view
- (NSView*) contentView;

@end
