//
//  GPGDocument_IBActions.m
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

@implementation GPGDocument (IBActions)

- (IBAction)doIt:(id)sender
{
    NSData *returned_data;
    NSString *returned_type;
    //NSLog(@"%d", [actionList indexOfSelectedItem]);

    [gpgData rewind];  //make sure it's at the begining so that we don't get No Data errors

    switch ([actionList indexOfSelectedItem])	{
        case 0:
            returned_data = [self encryptAndSign];
            returned_type = @"Encrypted & Signed file";
            break;
        case 1:
            returned_data = [self encrypt];
            returned_type = @"Encrypted file";
            break;
        case 2:
            returned_data = [self sign];
            returned_type = @"Signed file";
            break;
        case 3:
            returned_data = [self signDetached];
            returned_type = @"Detached signature";
            break;
        case 4:
            returned_data = [self clearsign];
            returned_type = @"Clearsigned file";
            break;
            //case 5 is the separator
        case 6:
            returned_data = [self decryptAndVerify];
            returned_type = @"Data";
            break;
        case 7:
            returned_data = [self decrypt];
            returned_type = @"Data";
            break;
        case 8:
            returned_data = [self verify];
            returned_type = @"Data";
            break;
        case 9:
            returned_data = [self verifyDetached];
            returned_type = @"Data";
            break;
        default:
            NSBeginAlertSheet(@"D'oh", nil, nil, nil, window, nil, nil, nil, nil,
                              @"Hey, you can't do that on GPGFileTool.");
            break;
    }
    if (returned_data)	{
        BOOL wrote_file = NO;
        wrote_file = [self writeFileWithData: returned_data ofType: returned_type];
        if (wrote_file)	{
            if ([ckbox_openAfter state])
                [self openFile: self];
            if ([ckbox_showAfter state])
                [self showFileInFinder: self];
        }
    }
}

- (IBAction)openFile:(id)sender
{
    NSTask *open_file_task = [[NSTask alloc] init];
    NSMutableArray *args = [NSMutableArray array];

    if ([[self fileType] isEqualTo: @"Data"])	{
        [args addObject: [self fileName]];
    }
    else	{
        [args addObject: @"-e"];
        [args addObject: [self fileName]];
    }

    [open_file_task setLaunchPath: @"/usr/bin/open"];
    [open_file_task setArguments: args];
    [open_file_task launch];

    [open_file_task waitUntilExit];  //usually runs right away, but a good measure

    [open_file_task release];
}

- (IBAction)showFileInFinder:(id)sender
{
    NSTask *open_file_task = [[NSTask alloc] init];
    NSMutableArray *args = [NSMutableArray array];
    NSMutableString *script = [NSMutableString string];

    [script appendString: @"tell application \"Finder\" to (reveal file \""];
    [script appendString: [[self fileName] unixAsMacPath]];
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