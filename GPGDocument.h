//
//  GPGDocument.h
//  GPGFileTool
//
//  Created by Gordon Worley on Wed Mar 27 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
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

- (void)write_file_with_data: (NSData *)data of_type: (NSString *)type;
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
//- (void)show_verification_status: (GPGSignatureStatus)status with_keys: (NSArray *) signees;

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