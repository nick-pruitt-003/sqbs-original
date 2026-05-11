//
//  PublishWindowController.m
//  SQBS2
//
//  Created by Neil Smith on 12-02-05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PublishWindowController.h"
#import "Tournament.h"

@implementation PublishWindowController
@synthesize selectionTable;
@synthesize publishButton;
@synthesize documentsArray;
@synthesize selectedDocumentsIndexSet;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void)dealloc {
    [self setDocumentsArray:nil];
    [self setSelectedDocumentsIndexSet:nil];
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)cancelAction:(id)sender {
    [NSApp endSheet:[publishButton window] returnCode:NSAlertAlternateReturn];
}

- (IBAction)publishAction:(id)sender {
    [self setSelectedDocumentsIndexSet:[selectionTable selectedRowIndexes]];
    [NSApp endSheet:[publishButton window] returnCode:NSAlertDefaultReturn];
    
}

- (IBAction)selectionTableSelectedAction:(id)sender {
    [publishButton setEnabled:TRUE];
}

#pragma mark NSTableViewDataSource Protocol

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [documentsArray count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    if (rowIndex < [documentsArray count] && rowIndex >= 0) {
        if ([[aTableColumn identifier] isEqualToString:kMergeTournamentNameKey]) {
            return [(Tournament *)[documentsArray objectAtIndex:rowIndex] tournamentName];
        } else {
            return [[[(Tournament *)[documentsArray objectAtIndex:rowIndex] fileURL] path] lastPathComponent];
        }
        //return [[documentsArray objectAtIndex:rowIndex] objectForKey:[aTableColumn identifier]];
    }
    return nil;
}

@end
