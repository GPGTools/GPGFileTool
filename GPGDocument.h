//
//  GPGDocument.h
//  GPGFileTool
//
//  Created by Gordon Worley on Wed Mar 27 2002.
//  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import <GPGME/GPGME.h>

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

- (void)write_file_with_data: (GPGData *)data of_type: (NSString *)type;

@end

@interface GPGDocument (IBActions)

- (IBAction)do_it:(id)sender;
- (IBAction)open_file:(id)sender;
- (IBAction)show_file_in_finder:(id)sender;

@end

@interface GPGDocument (GnuPGActions)

- (GPGData *)encrypt_and_sign;
- (GPGData *)encrypt;
- (GPGData *)sign;
- (GPGData *)sign_detached;
- (GPGData *)clearsign;

- (GPGData *)decrypt_and_verify;
- (GPGData *)decrypt;
- (GPGData *)verify;
- (GPGData *)verify_detached;

@end