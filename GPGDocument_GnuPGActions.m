//
//  GPGDocument_GnuPGActions.m
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

@implementation GPGDocument (GnuPGActions)

- (NSString *) context:(GPGContext *)context passphraseForKey:(GPGKey *)key again:(BOOL)again {
    GPGPassphrasePanel *ppanel = [GPGPassphrasePanel panel];
    
    if (again)
    {
        [ppanel runModalWithPrompt: [NSString stringWithFormat:
            NSLocalizedString(FTEnterPassphraseAgainPrompt, nil), [key userID], [key shortKeyID]]
                  relativeToWindow: [self window]];
    }
    else
    {
        [ppanel runModalWithPrompt: [NSString stringWithFormat:
            NSLocalizedString(FTEnterPassphrasePrompt, nil), [key userID], [key shortKeyID]]
                  relativeToWindow: [self window]];
    }

    return [ppanel passphrase];
}

- (GPGRecipients *) getRecipients
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

    gotRecipient = [panel runModalForKeyWildcard:nil usingContext:context relativeToWindow: [self window]];

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

- (GPGKey *) getSigner
{
    GPGContext * context = [[[GPGContext alloc] init] autorelease];
    GPGSingleKeySelectionPanel * panel = [GPGSingleKeySelectionPanel panel];

    [panel resetToDefaults];
    [panel setMinimumKeyValidity:GPGValidityUltimate];
    [panel setListsSecretKeys:YES];

    [panel runModalForKeyWildcard:nil usingContext:context relativeToWindow: [self window]];
    return [panel selectedKey];
}

- (void)showVerificationStatus: (NSArray *) signatures
{
    if ([signatures count] == 0)	{
        NSRunInformationalAlertPanelRelativeToWindow(NSLocalizedString(FTSignatureStatus, nil), NSLocalizedString(FTNoSignatureSigStatus, nil), nil, nil, nil, [self window]);
    }
    else if ([signatures count] == 1)	{
        GPGSignature *sig;
        GPGKey *sig_key;
        sig = [signatures objectAtIndex: 0];
        sig_key = [sig key];

        switch ([sig status])	{
            case GPGSignatureStatusGood:
                NSRunInformationalAlertPanelRelativeToWindow(NSLocalizedString(FTSignatureStatus, nil), NSLocalizedString(FTGoodSigStatus, nil), nil, nil, nil, [self window], [sig creationDate], GPGValidityDescription([sig validity]), [sig_key userID], [sig_key fingerprint]);
                break;
            case GPGSignatureStatusBad:
                NSRunInformationalAlertPanelRelativeToWindow(NSLocalizedString(FTSignatureStatus, nil), NSLocalizedString(FTBadSigStatus, nil), nil, nil, nil, [self window], [sig creationDate], GPGValidityDescription([sig validity]), [sig_key userID], [sig_key fingerprint]);
                break;
            case GPGSignatureStatusGoodButExpired:
                NSRunInformationalAlertPanelRelativeToWindow(NSLocalizedString(FTSignatureStatus, nil), NSLocalizedString(FTGoodButExpiredSigStatus, nil), nil, nil, nil, [self window], [sig creationDate], GPGValidityDescription([sig validity]), [sig_key userID], [sig_key fingerprint]);
                break;
            case GPGSignatureStatusGoodButKeyExpired:
                NSRunInformationalAlertPanelRelativeToWindow(NSLocalizedString(FTSignatureStatus, nil), NSLocalizedString(FTGoodButKeyExpiredSigStatus, nil), nil, nil, nil, [self window], [sig creationDate], GPGValidityDescription([sig validity]), [sig_key userID], [sig_key fingerprint]);
                break;
            case GPGSignatureStatusNoKey:
                NSRunInformationalAlertPanelRelativeToWindow(NSLocalizedString(FTSignatureStatus, nil), NSLocalizedString(FTNoKeySigStatus, nil), nil, nil, nil, [self window], [sig fingerprint]);
                break;
            case GPGSignatureStatusNoSignature:
                NSRunInformationalAlertPanelRelativeToWindow(NSLocalizedString(FTSignatureStatus, nil), NSLocalizedString(FTNoSignatureSigStatus, nil), nil, nil, nil, [self window]);
                break;
            default:
                NSRunInformationalAlertPanelRelativeToWindow(NSLocalizedString(FTSignatureStatus, nil), NSLocalizedString(FTErrorSigStatus, nil), nil, nil, nil, [self window]);
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

        NSRunInformationalAlertPanelRelativeToWindow(NSLocalizedString(FTMultipleSignatureStatuses, nil), statuses, nil, nil, nil, [self window]);
    }
}

- (NSData *)encryptAndSign
{
    GPGRecipients *recipients = nil;
    GPGKey *signer = nil;
    NSData *returned_data = nil;

    recipients = [self getRecipients];

    if ([recipients count])	{
        signer = [self getSigner];

        if (signer)	{
            NS_DURING
                GPGContext *context = [[[GPGContext alloc] init] autorelease];

                [context setUsesArmor: [ckbox_armored state] ? YES : NO];
                [context addSignerKey: signer];
                [context setPassphraseDelegate: self];

                returned_data = [[context encryptedSignedData:gpgData
                                                forRecipients:recipients
                                        allRecipientsAreValid:nil]
                    data];

            NS_HANDLER
                [self handleException: localException];
            NS_ENDHANDLER
        }
    }

    return returned_data;
}

- (NSData *)encrypt
{
    GPGRecipients *recipients = nil;
    NSData *returned_data = nil;

    recipients = [self getRecipients];

    if ([recipients count])	{
        NS_DURING
            GPGContext *context = [[[GPGContext alloc] init] autorelease];

            [context setUsesArmor: [ckbox_armored state] ? YES : NO];

            returned_data = [[context encryptedData:gpgData forRecipients:recipients allRecipientsAreValid:nil]
                data];

        NS_HANDLER
            [self handleException: localException];
        NS_ENDHANDLER
    }

    return returned_data;
}

- (NSData *)sign
{
    GPGKey *signer = nil;
    NSData *returned_data = nil;

    signer = [self getSigner];

    if (signer)	{
        NS_DURING
            GPGContext *context = [[[GPGContext alloc] init] autorelease];

            [context setUsesArmor: [ckbox_armored state] ? YES : NO];
            [context addSignerKey: signer];
            [context setPassphraseDelegate: self];

            returned_data = [[context signedData:gpgData signatureMode: GPGSignatureModeNormal]
                data];
            //[context wait: YES];

        NS_HANDLER
            [self handleException: localException];
        NS_ENDHANDLER
    }

    return returned_data;
}

- (NSData *)signDetached
{
    GPGKey *signer = nil;
    NSData *returned_data = nil;

    signer = [self getSigner];
    //NSLog("%@", signer);

    if (signer)	{
        NS_DURING
            GPGContext *context = [[[GPGContext alloc] init] autorelease];

            [context setUsesArmor: [ckbox_armored state] ? YES : NO];
            [context addSignerKey: signer];
            [context setPassphraseDelegate: self];

            returned_data = [[context signedData:gpgData signatureMode: GPGSignatureModeDetach]
                data];
            //[context wait: YES];

        NS_HANDLER
            [self handleException: localException];
        NS_ENDHANDLER
    }

    return returned_data;
}

- (NSData *)clearsign
{
    GPGKey *signer = nil;
    NSData *returned_data = nil;

    signer = [self getSigner];

    if (signer)	{
        NS_DURING
            GPGContext *context = [[[GPGContext alloc] init] autorelease];

            [context setUsesArmor: [ckbox_armored state] ? YES : NO];
            [context addSignerKey: signer];
            [context setPassphraseDelegate: self];

            returned_data = [[context signedData:gpgData signatureMode: GPGSignatureModeClear]
                data];
            //[context wait: YES];

        NS_HANDLER
            [self handleException: localException];
        NS_ENDHANDLER
    }

    return returned_data;
}


- (NSData *)decryptAndVerify
{
    NSData *returned_data = nil;
    GPGSignatureStatus sig_status;

    NS_DURING
        GPGContext *context = [[[GPGContext alloc] init] autorelease];
        //GPGKey *signee;

        [context setPassphraseDelegate: self];

        returned_data = [[context decryptedData: gpgData signatureStatus: &sig_status] data];

        [self showVerificationStatus: [context signatures]];
    NS_HANDLER
        [self handleException: localException];
    NS_ENDHANDLER

    return returned_data;
}

- (NSData *)decrypt
{
    NSData *returned_data = nil;

    NS_DURING
        GPGContext *context = [[[GPGContext alloc] init] autorelease];

        [context setPassphraseDelegate: self];

        returned_data = [[context decryptedData: gpgData] data];
    NS_HANDLER
        [self handleException: localException];
    NS_ENDHANDLER

    return returned_data;
}

- (NSData *)verify
{
    NS_DURING
        GPGContext *context = [[[GPGContext alloc] init] autorelease];

        [context setPassphraseDelegate: self];

        [context verifySignedData: gpgData];

        [self showVerificationStatus: [context signatures]];
    NS_HANDLER
        [self handleException: localException];
    NS_ENDHANDLER

    return nil;
}

- (NSData *)verifyDetached
{
    GPGSignatureStatus sig_status;

    NS_DURING
        GPGContext *context = [[[GPGContext alloc] init] autorelease];
        GPGData *orig_data;

        orig_data = [[[GPGData alloc] initWithData: [self dataForDetachedSignature]] autorelease];

        [context setPassphraseDelegate: self];

        sig_status = [context verifySignatureData: gpgData againstData: orig_data];

        [self showVerificationStatus: [context signatures]];
    NS_HANDLER
        [self handleException: localException];
    NS_ENDHANDLER

    return nil;
}

@end