//
//  GPGDocument.m
//  GPGFileTool
//
//  Created by Gordon Worley on Wed Mar 27 2002.
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

- (BOOL)write_file_with_data: (NSData *)data of_type: (NSString *)type
{
    NS_DURING
        NSSavePanel	*sp;
        NSMutableString *new_filename;
        char *old_filename;
        int of_len, i, suffix_start;

        sp = [NSSavePanel savePanel];

        [sp setTreatsFilePackagesAsDirectories: YES];
        [sp setRequiredFileType: [types objectForKey: type]];

        if ([type isEqualTo: @"Data"])	{
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
            new_filename = [NSMutableString stringWithString: [self displayName]];
            [new_filename appendString: @"."];
            [new_filename appendString: [types objectForKey: type]];
        }

        if([sp runModalForDirectory: nil file: new_filename] == NSOKButton){
            [data writeToFile:[sp filename] atomically:NO];
            NS_VALUERETURN(YES, BOOL);
        }
        else
            NS_VALUERETURN(NO, BOOL);
    NS_HANDLER
        [self handle_exception: localException];
    NS_ENDHANDLER

    return NO;
}

- (NSData *)data_for_detached_signature
{
    NSData *orig_data = nil;

#warning This feature keeps returning null, even though it shouldn't, so the open panel is always used right now
    NS_DURING
        //get the data from the original file
        orig_data = [NSData dataWithContentsOfFile:
            [[self fileName] substringToIndex: [[self fileName] length] - 5]]; //strip the .sig extension
        //NSLog([[self fileName] substringToIndex: [[self fileName] length] - 4]);
        //NSLog(@"%@", orig_data);
    NS_HANDLER
        [self handle_exception: localException];
    NS_ENDHANDLER

    if (orig_data == nil)	{
        NSOpenPanel *op;
        op = [NSOpenPanel openPanel];

        [op setTreatsFilePackagesAsDirectories: YES];
        [op setAllowsMultipleSelection: NO];
        [op setTitle: NSLocalizedString(FTVerifyFileFindTitle, nil)];
        [op setPrompt: NSLocalizedString(FTVerifyFileFindPrompt, nil)];

        if([op runModal] == NSOKButton)	{
            orig_data = [NSData dataWithContentsOfFile: [op filename]];
            //NSLog([op filename]);
        }
    }

    return orig_data;
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
        gpg_data = [[GPGData alloc] initWithData: data];
        NS_VALUERETURN(YES, BOOL);
    NS_HANDLER
        return NO;
    NS_ENDHANDLER
}

@end

@implementation GPGDocument (IBActions)

- (IBAction)do_it:(id)sender
{
    NSData *returned_data;
    NSString *returned_type;
    //NSLog(@"%d", [action_list indexOfSelectedItem]);

    [gpg_data rewind];  //make sure it's at the begining so that we don't get No Data errors
    
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
        //case 5 is the separator
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
            NSBeginAlertSheet(@"D'oh", nil, nil, nil, window, nil, nil, nil, nil,
                              @"Hey, you can't do that on GPGFileTool.");
            break;
    }
    if (returned_data)	{
        BOOL wrote_file = NO;
        wrote_file = [self write_file_with_data: returned_data of_type: returned_type];
        if (wrote_file)	{
            if ([ckbox_open_after state])
                [self open_file: self];
            if ([ckbox_show_after state])
                [self show_file_in_finder: self];
        }
    }
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

- (NSString *) context:(GPGContext *)context passphraseForDescription:(NSString *)description userInfo:(NSMutableDictionary *)userInfo {
    GPGPassphrasePanel *ppanel = [GPGPassphrasePanel panel];
    NSString *new_string;
    NSScanner *scanner = [NSScanner scannerWithString:description];
    
    [scanner scanUpToString:@"\n" intoString:nil];
    [scanner scanUpToString:@" " intoString:nil];
    [scanner scanString:@" " intoString:nil];

    if (![scanner scanUpToString:@"\n" intoString:&new_string])
        new_string = [NSString string];

    [ppanel runModalWithPrompt: [NSString stringWithFormat: @"%@", new_string]];

    return [ppanel passphrase];
}

- (GPGRecipients *) get_recipients
{
    GPGContext * context = [[[GPGContext alloc] init] autorelease];
    GPGRecipients * recipients = [[[GPGRecipients alloc] init] autorelease];
    GPGMultiKeySelectionPanel * panel = [GPGMultiKeySelectionPanel panel];
    NSEnumerator * enumerator;
    BOOL gotRecipient;
    id object;

    // Init the panel
    [panel resetToDefaults];
    [panel setMinimumKeyValidity:GPGValidityMarginal];
    [panel setListsSecretKeys:NO];

    gotRecipient = [panel runModalForKeyWildcard:nil usingContext:context];

    // Populate the recipients
    if (gotRecipient) {
        enumerator = [[panel selectedKeys] objectEnumerator];
        while (object = [enumerator nextObject]) {
            [recipients addName:[object email]];
        }
    }
    else
        recipients = nil;

    return recipients;
}

- (GPGKey *) get_signer
{
    GPGContext * context = [[[GPGContext alloc] init] autorelease];
    GPGSingleKeySelectionPanel * panel = [GPGSingleKeySelectionPanel panel];

    [panel resetToDefaults];
    [panel setMinimumKeyValidity:GPGValidityUltimate];
    [panel setListsSecretKeys:YES];

    [panel runModalForKeyWildcard:nil usingContext:context];

    return [panel selectedKey];
}

- (void)show_verification_status: (NSArray *) signatures
{
    if ([signatures count] == 0)	{
        NSRunInformationalAlertPanel(NSLocalizedString(FTSignatureStatus, nil), NSLocalizedString(FTNoSignatureSigStatus, nil), nil, nil, nil);
    }
    else if ([signatures count] == 1)	{
        GPGSignature *sig;
        GPGKey *sig_key;
        sig = [signatures objectAtIndex: 0];
        sig_key = [sig key];

        switch ([sig status])	{
            case GPGSignatureStatusGood:
                NSRunInformationalAlertPanel(NSLocalizedString(FTSignatureStatus, nil), NSLocalizedString(FTGoodSigStatus, nil), nil, nil, nil, [sig creationDate], GPGValidityDescription([sig validity]), [sig_key userID], [sig_key fingerprint]);
                break;
            case GPGSignatureStatusBad:
                NSRunInformationalAlertPanel(NSLocalizedString(FTSignatureStatus, nil), NSLocalizedString(FTBadSigStatus, nil), nil, nil, nil, [sig creationDate], GPGValidityDescription([sig validity]), [sig_key userID], [sig_key fingerprint]);
                break;
            case GPGSignatureStatusGoodButExpired:
                NSRunInformationalAlertPanel(NSLocalizedString(FTSignatureStatus, nil), NSLocalizedString(FTGoodButExpiredSigStatus, nil), nil, nil, nil, [sig creationDate], GPGValidityDescription([sig validity]), [sig_key userID], [sig_key fingerprint]);
                break;
            case GPGSignatureStatusGoodButKeyExpired:
                NSRunInformationalAlertPanel(NSLocalizedString(FTSignatureStatus, nil), NSLocalizedString(FTGoodButKeyExpiredSigStatus, nil), nil, nil, nil, [sig creationDate], GPGValidityDescription([sig validity]), [sig_key userID], [sig_key fingerprint]);
                break;
            case GPGSignatureStatusNoKey:
                NSRunInformationalAlertPanel(NSLocalizedString(FTSignatureStatus, nil), NSLocalizedString(FTNoKeySigStatus, nil), nil, nil, nil, [sig fingerprint]);
                break;
            case GPGSignatureStatusNoSignature:
                NSRunInformationalAlertPanel(NSLocalizedString(FTSignatureStatus, nil), NSLocalizedString(FTNoSignatureSigStatus, nil), nil, nil, nil);
                break;
            default:
                NSRunInformationalAlertPanel(NSLocalizedString(FTSignatureStatus, nil), NSLocalizedString(FTErrorSigStatus, nil), nil, nil, nil);
                break;
        }
    }
    else	{
        int i;
        //NSMutableArray *keys = [NSMutableArray array];
        NSMutableString *statuses = [NSMutableString string];
        /*
        for (i = 0; i < [signatures count]; i++)	{
            [keys addObject: [(GPGSignature *)[signatures objectAtIndex: i] key]];
        }
        */          
        for (i = 0; i < [signatures count]; i++)	{
            if (i > 0)
                [statuses appendString: NSLocalizedString(FTSigSeparator, nil)];
            switch ([[signatures objectAtIndex: i] status])	{
                case GPGSignatureStatusGood:
                    [statuses appendFormat: NSLocalizedString(FTGoodSigStatus, nil), [[signatures objectAtIndex: i] creationDate], GPGValidityDescription([[signatures objectAtIndex: i] validity]), [[(GPGSignature *)[signatures objectAtIndex: i] key] userID], [(GPGSignature *)[signatures objectAtIndex: i] fingerprint]];
                    break;
                case GPGSignatureStatusBad:
                    [statuses appendFormat: NSLocalizedString(FTBadSigStatus, nil), [[signatures objectAtIndex: i] creationDate], GPGValidityDescription([[signatures objectAtIndex: i] validity]), [[(GPGSignature *)[signatures objectAtIndex: i] key] userID], [(GPGSignature *)[signatures objectAtIndex: i] fingerprint]];
                    break;
                case GPGSignatureStatusGoodButExpired:
                    [statuses appendFormat: NSLocalizedString(FTGoodButExpiredSigStatus, nil), [[signatures objectAtIndex: i] creationDate], GPGValidityDescription([[signatures objectAtIndex: i] validity]), [[(GPGSignature *)[signatures objectAtIndex: i] key] userID], [(GPGSignature *)[signatures objectAtIndex: i] fingerprint]];
                    break;
                case GPGSignatureStatusGoodButKeyExpired:
                    [statuses appendFormat: NSLocalizedString(FTGoodButKeyExpiredSigStatus, nil), [[signatures objectAtIndex: i] creationDate], GPGValidityDescription([[signatures objectAtIndex: i] validity]), [[(GPGSignature *)[signatures objectAtIndex: i] key] userID], [(GPGSignature *)[signatures objectAtIndex: i] fingerprint]];
                    break;
                case GPGSignatureStatusNoKey:
                    [statuses appendFormat: NSLocalizedString(FTNoKeySigStatus, nil), [[signatures objectAtIndex: i] fingerprint]];
                    break;
                case GPGSignatureStatusNoSignature:
                    [statuses appendFormat: NSLocalizedString(FTNoSignatureSigStatus, nil)];
                    break;
                default:
                    [statuses appendFormat: NSLocalizedString(FTErrorSigStatus, nil)];
                    break;
            }            
        }
        
        NSRunInformationalAlertPanel(NSLocalizedString(FTMultipleSignatureStatuses, nil), statuses, nil, nil, nil);
    }
}

- (NSData *)encrypt_and_sign
{
    GPGRecipients *recipients = nil;
    GPGKey *signer = nil;
    NSData *returned_data = nil;

    recipients = [self get_recipients];
    
    if ([recipients count])	{
        signer = [self get_signer];
        
        if (signer)	{
            NS_DURING
                GPGContext *context = [[[GPGContext alloc] init] autorelease];
    
                [context setUsesArmor: [ckbox_armored state] ? YES : NO];
                [context addSignerKey: signer];
                [context setPassphraseDelegate: self];
                
                returned_data = [[context encryptedSignedData:gpg_data
                                        forRecipients:recipients
                                        allRecipientsAreValid:nil]
                    data];

            NS_HANDLER
                [self handle_exception: localException];
            NS_ENDHANDLER
        }
    }

    return returned_data;
}

- (NSData *)encrypt
{
    GPGRecipients *recipients = nil;
    NSData *returned_data = nil;

    recipients = [self get_recipients];

    if ([recipients count])	{
        NS_DURING
            GPGContext *context = [[[GPGContext alloc] init] autorelease];
    
            [context setUsesArmor: [ckbox_armored state] ? YES : NO];

            returned_data = [[context encryptedData:gpg_data forRecipients:recipients allRecipientsAreValid:nil]
                data];

        NS_HANDLER
            [self handle_exception: localException];
        NS_ENDHANDLER
    }

    return returned_data;
}

- (NSData *)sign
{
    GPGKey *signer = nil;
    NSData *returned_data = nil;

    signer = [self get_signer];

    if (signer)	{
        NS_DURING
            GPGContext *context = [[[GPGContext alloc] init] autorelease];

            [context setUsesArmor: [ckbox_armored state] ? YES : NO];
            [context addSignerKey: signer];
            [context setPassphraseDelegate: self];
            
            returned_data = [[context signedData:gpg_data signatureMode: GPGSignatureModeNormal]
                data];
            [context wait: YES];

        NS_HANDLER
            [self handle_exception: localException];
        NS_ENDHANDLER
    }

    return returned_data;
}

- (NSData *)sign_detached
{
    GPGKey *signer = nil;
    NSData *returned_data = nil;

    signer = [self get_signer];

    if (signer)	{
        NS_DURING
            GPGContext *context = [[[GPGContext alloc] init] autorelease];

            [context setUsesArmor: [ckbox_armored state] ? YES : NO];
            [context addSignerKey: signer];
            [context setPassphraseDelegate: self];

            returned_data = [[context signedData:gpg_data signatureMode: GPGSignatureModeDetach]
                data];
            [context wait: YES];

        NS_HANDLER
            [self handle_exception: localException];
        NS_ENDHANDLER
    }

    return returned_data;
}

- (NSData *)clearsign
{
    GPGKey *signer = nil;
    NSData *returned_data = nil;

    signer = [self get_signer];

    if (signer)	{
        NS_DURING
            GPGContext *context = [[[GPGContext alloc] init] autorelease];

            [context setUsesArmor: [ckbox_armored state] ? YES : NO];
            [context addSignerKey: signer];
            [context setPassphraseDelegate: self];

            returned_data = [[context signedData:gpg_data signatureMode: GPGSignatureModeClear]
                data];
            [context wait: YES];

        NS_HANDLER
            [self handle_exception: localException];
        NS_ENDHANDLER
    }

    return returned_data;
}


- (NSData *)decrypt_and_verify
{
    NSData *returned_data = nil;
    GPGSignatureStatus sig_status;
    
    NS_DURING
        GPGContext *context = [[[GPGContext alloc] init] autorelease];
        //GPGKey *signee;

        [context setPassphraseDelegate: self];

        returned_data = [[context decryptedData: gpg_data signatureStatus: &sig_status] data];

        [self show_verification_status: [context signatures]];
    NS_HANDLER
        [self handle_exception: localException];
    NS_ENDHANDLER

    return returned_data;
}

- (NSData *)decrypt
{
    NSData *returned_data = nil;

    NS_DURING
        GPGContext *context = [[[GPGContext alloc] init] autorelease];
        
        [context setPassphraseDelegate: self];

        returned_data = [[context decryptedData: gpg_data] data];
    NS_HANDLER
        [self handle_exception: localException];
    NS_ENDHANDLER

    return returned_data;    
}

- (NSData *)verify
{
    NS_DURING
        GPGContext *context = [[[GPGContext alloc] init] autorelease];

        [context setPassphraseDelegate: self];

        [context verifySignedData: gpg_data];

        [self show_verification_status: [context signatures]];
    NS_HANDLER
        [self handle_exception: localException];
    NS_ENDHANDLER

    return nil;    
}

- (NSData *)verify_detached
{
    GPGSignatureStatus sig_status;

    NS_DURING
        GPGContext *context = [[[GPGContext alloc] init] autorelease];
        GPGData *orig_data;

        orig_data = [[[GPGData alloc] initWithData: [self data_for_detached_signature]] autorelease];

        [context setPassphraseDelegate: self];

        sig_status = [context verifySignatureData: gpg_data againstData: orig_data];

        [self show_verification_status: [context signatures]];
    NS_HANDLER
        [self handle_exception: localException];
    NS_ENDHANDLER

    return nil;
}

@end

@implementation GPGDocument (Utility)

- (void)handle_exception: (NSException *) exception
{
    //NSLog(@"an error occured:  %@", exception);
    NSRunAlertPanel(NSLocalizedString(FTErrorTitle, nil), NSLocalizedString(FTErrorMessage, nil), nil, nil, nil, exception);
}

@end