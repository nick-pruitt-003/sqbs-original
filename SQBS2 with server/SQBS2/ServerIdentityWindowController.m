//
//  ServerIdentityWindowController.m
//  SQBS2
//
//  Created by Neil Smith on 12-02-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ServerIdentityWindowController.h"
#import "Constants.h"

@implementation ServerIdentityWindowController
@synthesize inputTextField;
@synthesize okayButton;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    // assign previously used name, or computer name
    NSString *name = [[NSUserDefaults standardUserDefaults] stringForKey:kServerIdentityKey];
    if (name == nil) {
        // get computer name
        name = NSFullUserName();
        // remove any blanks
        //name = [name stringByReplacingOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange(0, [name length])];
    }
    [inputTextField setStringValue:name];
}

- (IBAction)okayAction:(id)sender {
    NSString *name = [inputTextField stringValue];
    name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([name length] > 1) {
        [[NSUserDefaults standardUserDefaults] setObject:name forKey:kServerIdentityKey];
        [NSApp endSheet:[okayButton window] returnCode:NSAlertDefaultReturn];
    }
}

- (IBAction)cancelAction:(id)sender {
    [NSApp endSheet:[okayButton window] returnCode:NSAlertAlternateReturn];
}

@end
