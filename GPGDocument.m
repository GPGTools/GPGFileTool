//
//  GPGDocument.m
//  GPGFileTool
//
//  Created by Gordon Worley on Wed Mar 27 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//

#import "GPGDocument.h"

@implementation GPGDocument

- (id)init
{
    NSMutableArray *objs, *keys;
    
    [super init];

    defaults = [[NSUserDefaults standardUserDefaults] retain];
    
    gpg_data = nil;

    //needed later on for writing files
    objs = [NSMutableArray array];
    keys = [NSMutableArray array];
    [keys addObject: @"Encrypted file"];
    [objs addObject: @"gpg"];
    [keys addObject: @"Signed file"];
    [objs addObject: @"gpg"];
    [keys addObject: @"Detached signature"];
    [objs addObject: @"sig"];
    [keys addObject: @"Clearsigned file"];
    [objs addObject: @"asc"];
    [keys addObject: @"Data"];
    [objs addObject: @""];
    types = [[NSDictionary alloc] initWithObjects: objs forKeys: keys];

    return self;
}

- (void)dealloc
{
    if (gpg_data)
        [gpg_data release];
    [types release];
    [defaults release];    

    [super dealloc];
}

- (void)write_file_with_data: (GPGData *)data of_type: (NSString *)type
{
    NS_DURING
        NSSavePanel	*sp;
        NSMutableString *new_filename;
        char *old_filename;
        int of_len, i, suffix_start;

        sp = [NSSavePanel savePanel];

        [sp setTreatsFilePackagesAsDirectories: YES];
        [sp setRequiredFileType: type];

        if ([type isNotEqualTo: @"Data"])	{
            old_filename = [[self displayName] cString];
            of_len = [[self displayName] length];
            //remove the suffix
            for (i = of_len - 1; i >= 0; i--)	{
                if (*(old_filename + i) == '.')	{
                    suffix_start = i;
                    i = -1;
                }
            }
            new_filename = [NSString stringWithCString: old_filename length: suffix_start];
        }
        else	{
            new_filename = [NSString stringWithString: [self displayName]];
            [new_filename appendString: @"."];
            [new_filename appendString: [types objectForKey: type]];
        }

        if([sp runModalForDirectory: nil file: new_filename] == NSOKButton){
            [[data data] writeToFile:[sp filename] atomically:NO];
        }
    NS_HANDLER
        //[self handleException: localException];
        NSLog(@"an error occured:  %@", localException);
    NS_ENDHANDLER        
}

/*====================
 NSDocument methods
====================*/

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"GPGDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    [path_to_file setStringValue: [self fileName]];
    if ([[self fileType] isEqualTo: @"Encrypted file"])
        [action_list selectItemAtIndex: [defaults boolForKey: @"default_decrypt_and_verify"] ? 6 : 7];
    else if ([[self fileType] isEqualTo: @"Signed file"])
        [action_list selectItemAtIndex: 8];
    else if ([[self fileType] isEqualTo: @"Detached signature"])
        [action_list selectItemAtIndex: 9];
    else if ([[self fileType] isEqualTo: @"Clearsigned file"])
        [action_list selectItemAtIndex: 8];
    else
        [action_list selectItemAtIndex: [defaults integerForKey: @"user_default_action"]];
    
    [ckbox_armored setState: [defaults boolForKey: @"default_armored"] ? NSOnState : NSOffState];
    [ckbox_show_after setState: [defaults boolForKey: @"default_show_after"] ? NSOnState : NSOffState];
    if (!([defaults boolForKey: @"default_open_unless_ciphered"] && [[self fileType] isNotEqualTo: @"Data"]))
        [ckbox_open_after setState: [defaults boolForKey: @"default_open_after"] ? NSOnState : NSOffState];
}

- (NSData *)dataRepresentationOfType:(NSString *)aType
{
    // nothing happens here
    // since you can't change a file to need to save it
    // just write out a new file
    // but it has to be here, required by NSDocument
    return nil;
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)filetype
{
    
    NS_DURING
#warning something in this next line causes a crash
        gpg_data = [[GPGData alloc] initWithData: data];
        NS_VALUERETURN(YES, BOOL);
    NS_HANDLER
        return NO;
    NS_ENDHANDLER

    //return YES;
}

@end

@implementation GPGDocument (IBActions)

- (IBAction)do_it:(id)sender
{
    GPGData *returned_data;
    NSString *returned_type;

    NSLog(@"%d", [action_list indexOfSelectedItem]);
    switch ([action_list indexOfSelectedItem])	{
        case 0:
            returned_data = [self encrypt_and_sign];
            returned_type = @"Encrypted file";
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
            returned_data = [self sign_detached];
            returned_type = @"Detached signature";
            break;
        case 4:
            returned_data = [self clearsign];
            returned_type = @"Clearsigned file";
            break;
        //case 5 is the seperator
        case 6:
            returned_data = [self decrypt_and_verify];
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
            returned_data = [self verify_detached];
            returned_type = @"Data";
            break;
        default:
            NSBeginAlertSheet(@"D'oh", nil, nil, nil, window, nil, nil, nil, nil, @"Hey, you can't do that on GPGFileTool.");
            break;
    }

    if (returned_data)
        [self write_file_with_data: returned_data of_type: returned_type];
}

- (IBAction)open_file:(id)sender
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

- (IBAction)show_file_in_finder:(id)sender
{
    NSTask *open_file_task = [[NSTask alloc] init];
    NSMutableArray *args = [NSMutableArray array];
    NSMutableString *script = [NSMutableString string];
    char *file_name;
    int i;

    [script appendString: @"tell application \"Finder\" to (reveal file \""];
    //make the filename work with AppleScript
    file_name = [[self fileName] cString];
    for (i = 0; i < [[self fileName] length]; i++)
        if (*(file_name + i) == '/')
            *(file_name + i) = ':';
    [script appendString: [NSString stringWithCString: file_name]];
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

@implementation GPGDocument (GnuPGActions)

- (GPGData *)encrypt_and_sign
{
    return nil;
}

- (GPGData *)encrypt
{
    return nil;
}

- (GPGData *)sign
{
    return nil;
}

- (GPGData *)sign_detached
{
    return nil;
}

- (GPGData *)clearsign
{
    return nil;
}


- (GPGData *)decrypt_and_verify
{
    return nil;
}

- (GPGData *)decrypt
{
    return nil;
}

- (GPGData *)verify
{
    return nil;
}

- (GPGData *)verify_detached
{
    return nil;
}

@end