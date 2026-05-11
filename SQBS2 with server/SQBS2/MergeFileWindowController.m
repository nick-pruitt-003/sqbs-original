//
//  MergeFileWindowController.m
//  SQBS2
//
//  Created by Neil Smith on 12-01-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MergeFileWindowController.h"
#import "Tournament.h"

@implementation MergeFileWindowController
@synthesize baseTournament;
@synthesize selectionTable;
@synthesize mergeButton;
@synthesize documentsArray;
@synthesize selectedDocumentIndex;
@synthesize baseTournamentString;

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
    [self setBaseTournamentString:nil];
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    //DebugLog(@"windowDidLoad");
    [baseTournament setStringValue:baseTournamentString];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(void)assignBaseTournament:(NSString *)label {
    //DebugLog(@"assignBaseTournament - %@", label);
    [baseTournament setStringValue:label];
}

- (IBAction)cancelAction:(id)sender {
    //[[baseTournament window] orderOut:self];
    [NSApp endSheet:[baseTournament window] returnCode:NSAlertAlternateReturn];
}

- (IBAction)mergeAction:(id)sender {
    //DebugLog(@"mergeAction row - %@", [selectionTable selectedRow]);
    [self setSelectedDocumentIndex:[selectionTable selectedRow]];
    
    [NSApp endSheet:[baseTournament window] returnCode:NSAlertDefaultReturn];
    //[[baseTournament window] orderOut:self];
}

- (IBAction)selectionTableSelectedAction:(id)sender {
    [mergeButton setEnabled:TRUE];
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
