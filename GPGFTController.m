#import "GPGFTController.h"
#import "GPGDocument.h"

@implementation GPGFTController

- (id)init
{
    [super init];

    //defaults = [NSUserDefaults standardUserDefaults];

    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (IBAction) show_prefs: (id)sender
{
    if (pref_controller == nil)
    {
        pref_controller = [[GPGPrefController alloc] initWithWindowNibName:@"Preferences"];
        if (pref_controller == nil)
        {
            NSLog(@"Failed to load Preferences.nib");
            NSBeep();
            return;
        }
    }

    [[pref_controller window] makeKeyAndOrderFront:nil];
}

/*====================
 Application delegate
====================*/

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
    return NO;
}

/*====================
 Application notifications
====================*/

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    //find some way to do openDocument if nothing was dropped on
}
    
@end
