//
//  GPGDocument.h
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

#import <Cocoa/Cocoa.h>
#import <GPGME/GPGME.h>
#import <GPGAppKit/GPGAppKit.h>

@interface GPGDocument : NSDocument
{
    NSUserDefaults *defaults;
    GPGData *gpg_data;
    NSDictionary *types;
    
    IBOutlet NSTextField *path_to_file;
    IBOutlet NSButton *ckbox_armored, *ckbox_open_after, *ckbox_show_after;
    IBOutlet NSPopUpButton *action_list;
    IBOutlet NSWindow *window;
}

- (BOOL)write_file_with_data: (NSData *)data of_type: (NSString *)type;
- (NSData *)data_for_detached_signature;

@end

@interface GPGDocument (IBActions)

- (IBAction)do_it:(id)sender;
- (IBAction)open_file:(id)sender;
- (IBAction)show_file_in_finder:(id)sender;

@end

@interface GPGDocument (GnuPGActions)

- (GPGRecipients *) get_recipients;
- (GPGKey *) get_signer;
- (void)show_verification_status: (NSArray *) signatures;

- (NSData *)encrypt_and_sign;
- (NSData *)encrypt;
- (NSData *)sign;
- (NSData *)sign_detached;
- (NSData *)clearsign;

- (NSData *)decrypt_and_verify;
- (NSData *)decrypt;
- (NSData *)verify;
- (NSData *)verify_detached;

@end

@interface GPGDocument (Utility)

- (void)handle_exception: (NSException *) exception;

@end