//
//  OASplitView.h
//  Disk Inventory X
//
//  Local replacement for OmniAppKit's OASplitView so the OmniAppKit framework
//  can be removed. The main window nib archives an "OASplitView" instance, so
//  this class keeps that name; it is a thin NSSplitView subclass that maps the
//  -setPositionAutosaveName: API the app uses onto NSSplitView's autosaveName.
//
//  Copyright (C) 2024 Tjark Derlien.
//
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 3
//  of the License, or any later version.
//

#import <Cocoa/Cocoa.h>

@interface OASplitView : NSSplitView

//Kept for source compatibility with the old OmniAppKit API; forwards to -setAutosaveName:.
- (void)setPositionAutosaveName:(NSString *)name;
- (NSString *)positionAutosaveName;

@end
