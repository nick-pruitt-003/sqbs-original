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

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    // if published documents and last window closing, open untitled document
    // done mostly so user can control shut down - might just ignore since server shuts
    // down on app quit
//    if ([publishedTournaments count] > 0) {
//        [[NSDocumentController sharedDocumentController] newDocument:nil];
//        return NO;
//    }
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    //    [self setServerActive:NO];
//    [self setGamesForImport:[NSMutableArray arrayWithCapacity:10]];
//    // find game files in Downloads folder
//    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSError *error;
//    NSArray *filesFound = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:rootPath error:&error];
//    for (NSString *aFileName in filesFound) {
//        if ([[aFileName pathExtension] isEqualToString:kScoringAppFileExtension]) {
//            [gamesForImport addObject:[[aFileName lastPathComponent] stringByDeletingPathExtension]];
//        }
//    }
}

#pragma mark -
#pragma mark Server methods

//-(BOOL)startServer {
//    
//    [self setServerActive:NO];
//    Server *temp = [[Server alloc] init];
//    [self setSqbsServer:temp];
//    [temp release];
//    
//    // Try to start it up
//    if (![sqbsServer start]) {
//        [self setSqbsServer:nil];
//        return NO;
//    }
//    
//    [self setServerActive:YES];
//    return YES;
//}
//
//-(BOOL)stopServer {
//    // Destroy server
//    [sqbsServer stop];
//    [self setSqbsServer:nil];
//    [self setServerActive:NO];
//    // erase any published tournaments
//    [self setPublishedTournaments:nil];
//    return YES;
//}
//
//-(void)addTournamentForPublish:(PublishedTournament *)tournament {
//    if (publishedTournaments == nil) {
//        [self setPublishedTournaments:[NSMutableArray arrayWithCapacity:5]];
//    }
//    if (![publishedTournaments containsObject:tournament]) {
//        //DebugLog(@"addTournamentForPublish - %@", [tournament tournamentName]);
//        [publishedTournaments addObject:tournament];
//    }
//    [sqbsServer publishedTournamentsChanged];
//}
//
//-(void)removeTournamentForPublish:(PublishedTournament *)tournament {
//    if (publishedTournaments == nil) {
//        return;
//    }
//    //DebugLog(@"removeTournamentForPublish - %@", [tournament tournamentName]);
//    [publishedTournaments removeObject:tournament];
//    [sqbsServer publishedTournamentsChanged];
//}
//
//- (IBAction)unpublishTournamentATournament:(id)sender {
//    //DebugLog(@"unpublishTournaments - item: %@", sender);
//    NSString *tName = [(NSMenuItem *)sender title];
//    if ([tName isEqualToString:@"All"]) {
//        while ([publishedTournaments count] > 0) {
//            [self removeTournamentForPublish:[publishedTournaments objectAtIndex:0]];
//        }
//        return;
//    }
//    PublishedTournament *unpublishItem = nil;
//    for (PublishedTournament *anItem in publishedTournaments) {
//        if ([[anItem tournamentName] isEqualToString:tName]) {
//            unpublishItem = anItem;
//            break;
//        }
//    }
//    if (unpublishItem != nil) {
//        [self removeTournamentForPublish:unpublishItem];
//    }
//    unpublishItem = nil;
//}
//
//-(void)addGameForImport:(NSString *)gameFileName {
//    [gamesForImport addObject:gameFileName];
//}
//
//- (void) importGameAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)context {
//    // do nothing
//}
//
//- (IBAction)importAGame:(id)sender {
//    // open up game
//    NSString *gameName = [(NSMenuItem *)sender title];
//    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    rootPath = [rootPath stringByAppendingPathComponent:gameName];
//    rootPath = [rootPath stringByAppendingPathExtension:kScoringAppFileExtension];
//    GameFileContents *theGameFile = nil;
//    @try {
//        theGameFile = [NSKeyedUnarchiver unarchiveObjectWithFile:rootPath];
//    }
//    @catch (NSException *exception) {
//        theGameFile = nil;
//    }
//    if (theGameFile != nil) {
//        // find matching tournament document
//        NSArray *openDocuments = [[NSDocumentController sharedDocumentController] documents];
//        NSString *theGameTournamentName = [[theGameFile theGame] tournamentName];
//        for (Tournament *thisTournament in openDocuments) {
//            NSString *tName = [[thisTournament tournamentName] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//            
//            if ((tName == nil) || ([tName isEqualToString:theGameTournamentName])) {
//                // pass import over to document
//                [thisTournament importGameFile:rootPath];
//                return;
//            }
//        }
//    }
//    // if here either unarchive failed, file not found, or tournament window not open
//    // theGameFile == nil means file not found, or unarchive failed
//    NSAlert *alert;
//    if (theGameFile == nil) {
//        alert = [NSAlert alertWithMessageText:@"Game file not found or not readable." defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
//        // remove from list ??
//    } else {
//        // tournament window not open
//        alert = [NSAlert alertWithMessageText:@"Tournament matching game file tournament name not open." defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:[NSString stringWithFormat:@"Game created with information from tournament named '%@'. Open this tournament file, or rename if tournament name was changed after publishing.", [[theGameFile theGame] tournamentName]]];
//    }
//    [alert beginSheetModalForWindow:[sender mainWindow] modalDelegate:self didEndSelector:@selector(importGameAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
//}

#pragma mark -
#pragma mark NSMenuDelegate methods

//- (void)menuNeedsUpdate:(NSMenu *)menu {
//    if ([[menu title] isEqualToString:@"Unpublish"]) {
//        // add list of published tournaments to menu items
//        // first remove any that might be on list
//        if ([[menu itemArray] count] > 2) {
//            // default is "All" and separator
//            while ([[menu itemArray] count] > 2) {
//                [menu removeItemAtIndex:([[menu itemArray] count] - 1)];
//            }
//        }
//        // add names of published tournaments
//        for (PublishedTournament *pubTournament in publishedTournaments) {
//            [menu addItemWithTitle:[pubTournament tournamentName] action:@selector(unpublishTournamentATournament:) keyEquivalent:[NSString string]];
//        }
//        return;
//    }
//    if ([[menu title] isEqualToString:@"Import Game"]) {
//        // add list of games for import to menu items
//        // first remove any that might be on list
//        if ([[menu itemArray] count] > 2) {
//            // default is "All" and separator
//            while ([[menu itemArray] count] > 2) {
//                [menu removeItemAtIndex:([[menu itemArray] count] - 1)];
//            }
//        }
//        // add names of games available
//        for (NSString *fileName in gamesForImport) {
//            [menu addItemWithTitle:fileName action:@selector(importGame:) keyEquivalent:[NSString string]];
//        }
//    }
//}
@end
