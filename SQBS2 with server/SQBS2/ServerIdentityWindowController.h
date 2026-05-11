//
//  ServerIdentityWindowController.h
//  SQBS2
//
//  Created by Neil Smith on 12-02-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ServerIdentityWindowController : NSWindowController
<NSTextFieldDelegate>
{
    
    NSButton *okayButton;
    NSTextField *inputTextField;
}

@property (assign) IBOutlet NSTextField *inputTextField;
@property (assign) IBOutlet NSButton *okayButton;

- (IBAction)okayAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@end
