/* GPGPrefController */

#import <Cocoa/Cocoa.h>

@interface GPGPrefController : NSWindowController
{
    NSUserDefaults *defaults;
    
    IBOutlet NSButton *ckbox_armored, *ckbox_decrypt_and_verify, *ckbox_open_after, *ckbox_open_unless_cipher,
    *ckbox_show_after;
    IBOutlet NSPopUpButton *action_list;
    
    IBOutlet NSWindow *window;
}
@end
