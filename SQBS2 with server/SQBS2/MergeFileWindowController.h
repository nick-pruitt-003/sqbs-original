//
//  MergeFileWindowController.h
//  SQBS2
//
//  Created by Neil Smith on 12-01-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define kMergeTournamentNameKey @"name"
#define kMergeTournamentFileNameKey @"fileName"

@interface MergeFileWindowController : NSWindowController
{
    IBOutlet NSTextField *baseTournament;
    IBOutlet NSTableView *selectionTable;
    NSButton *mergeButton;
    NSArray *documentsArray;
    long selectedDocumentIndex;
    NSString *baseTournamentString;
}

@property (assign) IBOutlet NSTextField *baseTournament;
@property (assign) IBOutlet NSTableView *selectionTable;
@property (assign) IBOutlet NSButton *mergeButton;
@property (retain) NSArray *documentsArray;
@property (assign) long selectedDocumentIndex;
@property (retain) NSString *baseTournamentString;

- (IBAction)cancelAction:(id)sender;
- (IBAction)mergeAction:(id)sender;
- (IBAction)selectionTableSelectedAction:(id)sender;

-(void)assignBaseTournament:(NSString *)label;

@end
