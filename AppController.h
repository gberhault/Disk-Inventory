//
//  AppController.h
//  Disk Inventory X
//
//  Created by Tjark Derlien on 17.02.2019.
//
//  Copyright (C) 2019 Tjark Derlien.
//  
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 3
//  of the License, or any later version.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

//Was an OmniAppKit OAController subclass; OmniAppKit has been removed. This class is
//now a plain object (the real NSApplication delegate is MyDocumentController, wired in
//MainMenu.nib). Kept for the empty IBOutlets/actions the nib may still reference.
@interface AppController : NSObject
{
//    IBOutlet NSMenu* _zoomStackMenu;
//    IBOutlet NSPanel* _donationPanel;
}
/*
- (IBAction) showPreferencesPanel: (id) sender;
- (IBAction) gotoHomepage: (id) sender;
- (IBAction) closeDonationPanel: (id) sender;
*/
@end

NS_ASSUME_NONNULL_END
