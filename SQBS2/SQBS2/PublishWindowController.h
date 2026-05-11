//
//  PublishWindowController.h
//  SQBS2
//
//  Created by Neil Smith on 12-02-05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PublishWindowController : NSWindowController
{
    IBOutlet NSTableView *selectionTable;
    NSButton *publishButton;
    NSArray *documentsArray;
    NSIndexSet *selectedDocumentsIndexSet;
}

@property (assign) IBOutlet NSTableView *selectionTable;
@property (assign) IBOutlet NSButton *publishButton;
@property (retain) NSArray *documentsArray;
@property (retain) NSIndexSet *selectedDocumentsIndexSet;

- (IBAction)cancelAction:(id)sender;
- (IBAction)publishAction:(id)sender;
- (IBAction)selectionTableSelectedAction:(id)sender;

@end
