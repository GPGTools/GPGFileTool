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
    [ckbox_armored setState: [defaults boolForKey: @"default_armored"] ? NSOnState : NSOffState];
    [ckbox_decrypt_and_verify setState: [defaults boolForKey: @"default_decrypt_and_verify"] ? NSOnState : NSOffState];
    [ckbox_open_after setState: [defaults boolForKey: @"default_open_after"] ? NSOnState : NSOffState];
    [ckbox_open_unless_cipher setState: [defaults boolForKey: @"default_open_unless_ciphered"] ? NSOnState : NSOffState];
    [ckbox_show_after setState: [defaults boolForKey: @"default_show_after"] ? NSOnState : NSOffState];

    [action_list selectItemAtIndex: [defaults integerForKey: @"user_default_action"]];
}

- (BOOL)windowShouldClose: (id)sender
{
    [self apply: self];

    return YES;
}

- (IBAction)apply: (id)sender
{
    [defaults setBool: ([ckbox_armored state] == NSOnState) ? YES : NO forKey: @"default_armored"];
    [defaults setBool: ([ckbox_decrypt_and_verify state] == NSOnState) ? YES : NO forKey: @"default_decrypt_and_verify"];
    [defaults setBool: ([ckbox_open_after state] == NSOnState) ? YES : NO forKey: @"default_open_after"];
    [defaults setBool: ([ckbox_open_unless_cipher state] == NSOnState) ? YES : NO forKey: @"default_open_unless_ciphered"];
    [defaults setBool: ([ckbox_show_after state] == NSOnState) ? YES : NO forKey: @"default_show_after"];

    [defaults setInteger: [action_list indexOfSelectedItem] forKey: @"user_default_action"];

    [defaults synchronize];    
}

- (void)dealloc
{
    [defaults release];
    [super dealloc];
}

@end
