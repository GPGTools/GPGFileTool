//
//  GPGFTController.m
//  GPGFileTool
//
//  Created by Gordon Worley on Wed Mar 27 2002.
//  Copyright (C) 2001 Mac GPG Project.
//
//  This code is free software; you can redistribute it and/or modify it under
//  the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or any later version.
//
//  This code is distributed in the hope that it will be useful, but WITHOUT ANY
//  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
//  FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
//  details.
//
//  For a copy of the GNU General Public License, visit <http://www.gnu.org/> or
//  write to the Free Software Foundation, Inc., 59 Temple Place--Suite 330,
//  Boston, MA 02111-1307, USA.
//
//  More info at <http://macgpg.sourceforge.net/> or <macgpg@rbisland.cx>
//

#import "GPGFTController.h"
#import "GPGDocument.h"

@implementation GPGFTController

- (id)init
{
    [super init];

    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (IBAction) show_prefs: (id)sender
{
    if (pref_controller == nil)
    {
        pref_controller = [[GPGPrefController alloc] initWithWindowNibName:@"Preferences"];
        if (pref_controller == nil)
        {
            NSLog(@"Failed to load Preferences.nib");
            NSBeep();
            return;
        }
    }

    [[pref_controller window] makeKeyAndOrderFront:nil];
}

/*====================
 Application delegate
====================*/

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
    return NO;
}

/*====================
 Application notifications
====================*/

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    //find some way to do openDocument if nothing was dropped on
}
    
@end
