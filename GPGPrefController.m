//
//  GPGPrefController.m
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

#import "GPGPrefController.h"

@implementation GPGPrefController

- (id)initWithWindow:(NSWindow *)window
{
    [super initWithWindow:window];

    defaults = [[NSUserDefaults standardUserDefaults] retain];

    return self;
}

- (void)awakeFromNib
{
    //defaults
    [ckbox_armored setState: [defaults boolForKey: @"default_armored"] ? NSOnState : NSOffState];
    [ckbox_decryptAndVerify setState: [defaults boolForKey: @"default_decrypt_and_verify"] ? NSOnState : NSOffState];
    [ckbox_openAfter setState: [defaults boolForKey: @"default_open_after"] ? NSOnState : NSOffState];
    [ckbox_openUnlessCipher setState: [defaults boolForKey: @"default_open_unless_ciphered"] ? NSOnState : NSOffState];
    [ckbox_showAfter setState: [defaults boolForKey: @"default_show_after"] ? NSOnState : NSOffState];

    [actionList selectItemAtIndex: [defaults integerForKey: @"user_default_action"]];

    //interface
    [ckbox_singleRecipient setState: [defaults boolForKey: @"select_single_recipient"] ? NSOnState : NSOffState];
    [ckbox_singleSigner setState: [defaults boolForKey: @"select_single_signer"] ? NSOnState : NSOffState];

    [self openAfterChanged: self];
}

- (BOOL)windowShouldClose: (id)sender
{
    [self apply: self];

    return YES;
}

- (void)dealloc
{
    [defaults release];
    [super dealloc];
}

- (IBAction)apply: (id)sender
{
    //defaults
    [defaults setBool: ([ckbox_armored state] == NSOnState) ? YES : NO forKey: @"default_armored"];
    [defaults setBool: ([ckbox_decryptAndVerify state] == NSOnState) ? YES : NO forKey: @"default_decrypt_and_verify"];
    [defaults setBool: ([ckbox_openAfter state] == NSOnState) ? YES : NO forKey: @"default_open_after"];
    [defaults setBool: ([ckbox_openUnlessCipher state] == NSOnState) ? YES : NO forKey: @"default_open_unless_ciphered"];
    [defaults setBool: ([ckbox_showAfter state] == NSOnState) ? YES : NO forKey: @"default_show_after"];

    [defaults setInteger: [actionList indexOfSelectedItem] forKey: @"user_default_action"];

    //interface
    [defaults setBool: ([ckbox_singleRecipient state] == NSOnState) ? YES : NO forKey: @"select_single_recipient"];
    [defaults setBool: ([ckbox_singleSigner state] == NSOnState) ? YES : NO forKey: @"select_single_signer"];

    [defaults synchronize];
}

- (IBAction)openAfterChanged: (id)sender
{
    if ([ckbox_openAfter state] == NSOffState)
    {
        [ckbox_openUnlessCipher setEnabled: NO];
    }
    else
    {
        [ckbox_openUnlessCipher setEnabled: YES];
    }
}

@end
