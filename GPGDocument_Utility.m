//
//  GPGDocument_Utility.m
//  GPGFileTool
//
//  Created by Gordon Worley.
//  Copyright (C) 2002 Mac GPG Project.
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

#import "GPGDocument.h"
#import "LocalizableStrings.h"

@implementation GPGDocument (Utility)

- (void)handleException: (NSException *) exception
{
    //NSLog(@"an error occured:  %@", exception);
    NSRunAlertPanel(NSLocalizedString(FTErrorTitle, nil), NSLocalizedString(FTErrorMessage, nil), nil, nil, nil, exception);
}

- (void)openFileWithFilename: (NSString *)filename
{
    NSTask *open_file_task = [[NSTask alloc] init];
    NSMutableArray *args = [NSMutableArray array];

    if ([[self fileType] isEqualTo: @"Data"])	{
        [args addObject: filename];
    }
    else	{
        [args addObject: @"-e"];
        [args addObject: filename];
    }

    [open_file_task setLaunchPath: @"/usr/bin/open"];
    [open_file_task setArguments: args];
    [open_file_task launch];

    [open_file_task waitUntilExit];  //usually runs right away, but a good measure

    [open_file_task release];
}

- (void)showInFinder: (NSString *)filename
{
    NSTask *open_file_task = [[NSTask alloc] init];
    NSMutableArray *args = [NSMutableArray array];
    NSMutableString *script = [NSMutableString string];

    [script appendString: @"tell application \"Finder\" to (reveal file \""];
    [script appendString: [filename unixAsMacPath]];
    [script appendString: @"\") activate"];

    [args addObject: @"-e"];
    [args addObject: script];

    [open_file_task setLaunchPath: @"/usr/bin/osascript"];
    [open_file_task setArguments: args];
    [open_file_task launch];

    [open_file_task waitUntilExit]; //good since this can take several seconds

    [open_file_task release];
}

@end