//
//  GameResultDisplayWindowController.m
//  SQBS2
//
//  Created by Neil Smith on 12-02-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameResultDisplayWindowController.h"

#define kTUTableTossupColumn 1
#define kTUTablePlayer1Column 2
#define kTUTablePoints1Column 3
#define kTUTablePlayer2Column 4
#define kTUTablePoints2Column 5

@interface GameResultDisplayWindowController ()

@property (retain, nonatomic) NSMutableArray *playerTossupAttendance;

@end

@implementation GameResultDisplayWindowController
@synthesize tournamentNameTextField;
@synthesize roundNumberTextField;
@synthesize teamNameInfoTextField;
@synthesize tossupResultsTableView;
@synthesize playerTossupRecordTableView;

@synthesize theGameFile;

@synthesize playerTossupAttendance;

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
}

- (void)createPlayerTossupRecordData {
    [self setPlayerTossupAttendance:[NSMutableArray arrayWithCapacity:10]];
}

#pragma mark -
#pragma mark NSTableViewDataSource Protocol

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    if (aTableView == tossupResultsTableView) {
        return [[[theGameFile theGame] tossupResults] count];
    }
    if (aTableView == playerTossupRecordTableView) {
        if (playerTossupAttendance == nil) {
            [self createPlayerTossupRecordData];
        }
        return [playerTossupAttendance count];
    }
    return 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    
    if (aTableView == tossupResultsTableView) {
        TossupResult *theResults = [[[theGameFile theGame] tossupResults] objectAtIndex:rowIndex];
        switch ([[aTableColumn identifier] intValue]) {
            case kTUTableTossupColumn: {
                return [NSNumber numberWithInt:[theResults tossupNumber]];
                break;
            }
            case kTUTablePlayer1Column: {
                if ([[theResults tossupPointsResults] count] > 0) {
                    NSString *playerName = [(PointsResult *)[[theResults tossupPointsResults] objectAtIndex:0] playerName];
                    NSString *teamName = [(PointsResult *)[[theResults tossupPointsResults] objectAtIndex:0] teamName];
                    return [NSString stringWithFormat:@"%@ (%@)", playerName, teamName];
                }
                return @"";
                break;
            }
            case kTUTablePoints1Column: {
                if ([[theResults tossupPointsResults] count] > 0) {
                    return [NSNumber numberWithInt:[(PointsResult *)[[theResults tossupPointsResults] objectAtIndex:0] points]];
                }
                return @"";
                break;
            }
            case kTUTablePlayer2Column: {
                if ([[theResults tossupPointsResults] count] > 1) {
                    NSString *playerName = [(PointsResult *)[[theResults tossupPointsResults] objectAtIndex:1] playerName];
                    NSString *teamName = [(PointsResult *)[[theResults tossupPointsResults] objectAtIndex:1] teamName];
                    return [NSString stringWithFormat:@"%@ (%@)", playerName, teamName];
                }
                return @"";
                break;
            }
            case kTUTablePoints2Column: {
                if ([[theResults tossupPointsResults] count] > 1) {
                    return [NSNumber numberWithInt:[(PointsResult *)[[theResults tossupPointsResults] objectAtIndex:1] points]];
                }
                return @"";
                break;
            }
                
            default:
                break;
        }
        return @"";
    }
    if (aTableView == playerTossupRecordTableView) {
        if (playerTossupAttendance == nil) {
            [self createPlayerTossupRecordData];
        }
        return @"";
    }
    return nil;
}

@end
