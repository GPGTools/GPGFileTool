#import "GPGPrefController.h"

@implementation GPGPrefController

- (id)initWithWindow:(NSWindow *)window
{
    [super initWithWindow:window];

#warning defaults keeps coming up with nothing in it
    defaults = [[NSUserDefaults standardUserDefaults] retain];

    return self;
}

- (void)awakeFromNib
{
    [ckbox_armored setState: [defaults boolForKey: @"default_armored"] ? NSOnState : NSOffState];
    [ckbox_decrypt_and_verify setState: [defaults boolForKey: @"default_decrypt_and_verify"] ? NSOnState : NSOffState];
    [ckbox_open_after setState: [defaults boolForKey: @"default_open_after"] ? NSOnState : NSOffState];
    [ckbox_open_unless_cipher setState: [defaults boolForKey: @"default_open_unless_ciphered"] ? NSOnState : NSOffState];
    [ckbox_show_after setState: [defaults boolForKey: @"default_show_after"] ? NSOnState : NSOffState];

    [action_list selectItemAtIndex: [defaults integerForKey: @"user_default_action"]];

    NSLog(@"%@", [defaults dictionaryRepresentation]);
}

- (BOOL)windowShouldClose: (id)sender
{
    NSLog(@"pref window should close");
    [defaults setBool: ([ckbox_armored state] == NSOnState) ? YES : NO forKey: @"default_armored"];
    [defaults setBool: ([ckbox_decrypt_and_verify state] == NSOnState) ? YES : NO forKey: @"default_decrypt_and_verify"];
    [defaults setBool: ([ckbox_open_after state] == NSOnState) ? YES : NO forKey: @"default_open_after"];
    [defaults setBool: ([ckbox_open_unless_cipher state] == NSOnState) ? YES : NO forKey: @"default_open_unless_ciphered"];
    [defaults setBool: ([ckbox_show_after state] == NSOnState) ? YES : NO forKey: @"default_show_after"];

    [defaults setInteger: [action_list indexOfSelectedItem] forKey: @"user_default_action"];

    NSLog(@"%@", [defaults dictionaryRepresentation]);
    [defaults synchronize];
    NSLog(@"%@", [defaults dictionaryRepresentation]);
    
    return YES;
}

- (void)dealloc
{
    [defaults release];
    [super dealloc];
}

@end
