//
//  TournamentDelegate.m
//  SQBS2
//
//  Created by Neil Smith on 12-01-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TournamentAppDelegate.h"
#import "Tournament.h"
#import "TournamentViewController.h"
//#import "Server.h"
//#import "Constants.h"
//#import "GameFileContents.h"
//#import "GameResult.h"


// Declare some private properties and methods
@interface TournamentAppDelegate ()
//@property (nonatomic,retain) Server *sqbsServer;

@end

@implementation TournamentAppDelegate

//@synthesize serverActive;
//@synthesize sqbsServer;
//@synthesize publishedTournaments;
//@synthesize gamesForImport;

NSMutableArray *tournamentDocumentsNeedingAction;

#pragma mark NSApplicationDelegate

- (void) applicationShouldTerminateAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)context {
    //DebugLog(@"applicationShouldTerminateAlertDidEnd change status: %@, button: %i", [self isDocumentEdited]? @"Unsaved changes" : @"no unsaved changes", returnCode);
    switch (returnCode) {
        case NSAlertDefaultReturn: {
            // user wants to save
            for (Tournament *openTournament in tournamentDocumentsNeedingAction) {
                // if no filename need to assign one since SaveAs dialog disappears
                if ([openTournament fileURL] == nil) {
                    // make name for document file
                    NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSDesktopDirectory inDomains:NSUserDomainMask];
                    if ((urls != nil) && ([urls count] > 0)) {
                        NSString *fileName = [(NSURL *)[urls objectAtIndex:0] path];
                        if (([openTournament tournamentName] == nil) || ([[openTournament tournamentName] length] == 0)) {
                            [openTournament setTournamentName:@"untitled Tournament"];
                        }
                        fileName = [fileName stringByAppendingPathComponent:[openTournament tournamentName]];
                        [openTournament setFileURL:[NSURL fileURLWithPath:fileName isDirectory:FALSE]];
                        //DebugLog(@"windowShouldCloseAlertDidEnd - filename: %@, fileURL: %@", fileName, [self fileURL]);
                    }
                }
                [openTournament saveDocument:[[openTournament myTargetView] window]];
            }
            //[self stopServer];
            //[self setGamesForImport:nil];
            [NSApp replyToApplicationShouldTerminate: YES];
            break;
        }
        case NSAlertAlternateReturn: {
            // user wants to ignore unsaved changes, okay to quit
            //[self stopServer];
            //[self setGamesForImport:nil];
            [NSApp replyToApplicationShouldTerminate: YES];
            break;
        }
        case NSAlertOtherReturn: {
            // user wants to cancel, cancel quit
            [NSApp replyToApplicationShouldTerminate: NO];
            break;
        }
            
        default:
            break;
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    //DebugLog(@"applicationShouldTerminate - dcouments: %@", [[NSDocumentController sharedDocumentController] documents]);
    tournamentDocumentsNeedingAction = [NSMutableArray arrayWithCapacity:3];
    for (Tournament *openTournament in [[NSDocumentController sharedDocumentController] documents]) {
        // check if needs saving
        if (![(TournamentViewController *)[openTournament myCurrentViewController] shouldViewClose]) {
            [tournamentDocumentsNeedingAction addObject:openTournament];
        } else {
            // close this tournament
            [openTournament close];
        }
    }
    
    if ([tournamentDocumentsNeedingAction count] > 0) {
        // put up alert
        NSAlert *alert;
        if ([tournamentDocumentsNeedingAction count] == 1) {
            alert = [NSAlert alertWithMessageText:@"Do you want to save changes before quitting?" defaultButton:@"Save..." alternateButton:@"Don't Save" otherButton:@"Cancel" informativeTextWithFormat:@"Changes will be lost when SQBS quits."];
        } else {
            // multiple tournaments
            alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:@"%i tournaments have unsaved changes. Do you want to save changes before quitting?", [tournamentDocumentsNeedingAction count]] defaultButton:@"Save..." alternateButton:@"Don't Save" otherButton:@"Cancel" informativeTextWithFormat:@"Changes will be lost when SQBS quits."];
        }
        [alert beginSheetModalForWindow:[sender mainWindow] modalDelegate:self didEndSelector:@selector(applicationShouldTerminateAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
        // saving / closing / cancel will be done in didEndSelector
        [tournamentDocumentsNeedingAction retain];
        return NSTerminateLater;
    }
    
    // issue alert that server will stop??
//    [self stopServer];
//    [self setGamesForImport:nil];
    return NSTerminateNow;
}
@end
