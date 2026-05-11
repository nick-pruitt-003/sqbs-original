//
//  GameResultDisplayWindowController.h
//  SQBS2
//
//  Created by Neil Smith on 12-02-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Constants.h"
#import "GameFileContents.h"
#import "GameResult.h"
#import "TossupResult.h"
#import "PointsResult.h"

@interface GameResultDisplayWindowController : NSWindowController {
    NSTextField *tournamentNameTextField;
    NSTextField *roundNumberTextField;
    NSTextField *teamNameInfoTextField;
    NSTableView *tossupResultsTableView;
    NSTableView *playerTossupRecordTableView;
    
    GameFileContents *theGameFile;
    
    NSMutableArray *playerTossupAttendance;
}

@property (assign) IBOutlet NSTextField *tournamentNameTextField;
@property (assign) IBOutlet NSTextField *roundNumberTextField;
@property (assign) IBOutlet NSTextField *teamNameInfoTextField;
@property (assign) IBOutlet NSTableView *tossupResultsTableView;
@property (assign) IBOutlet NSTableView *playerTossupRecordTableView;

@property (retain) GameFileContents *theGameFile;

@end
