/* GPGFTController */

/*
 UserDefaults:

 - user_default_action: (int) index of default action from action popup menu in GPGDocument.nib
 - default_armored: (BOOL) whether to check to armor check box by default
 - default_open_after: (BOOL) whether to open document after acting on it by default
 - default_open_unless_ciphered: (BOOL) whether it should open up a file just after it's been gpg'd (most likely in Mac GPG)
 - default_show_after: (BOOL) whether to show the file in the Finder after acting on it by default
 - default_decrypt_and_verify: (BOOL) whether to decrypt and verify by default (rather than decyrypt only)
*/

#import <Cocoa/Cocoa.h>
#import "GPGPrefController.h"

@interface GPGFTController : NSObject
{
    //NSUserDefaults *defaults;

    GPGPrefController *pref_controller;

    IBOutlet NSMenuItem *open_menu;
}

- (IBAction)show_prefs: (id)sender;

@end
