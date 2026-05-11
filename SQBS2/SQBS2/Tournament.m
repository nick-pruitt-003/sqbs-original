//
//  Document.m
//  SQBS2
//
//  Created by Neil Smith on 12-01-10.
//  Copyright (c) 2012 Neil F. Smith Consulting, Inc.. All rights reserved.
//

#import "Tournament.h"
#import "TournamentAppDelegate.h"
#import "Constants.h"
#import "TournamentSetupViewController.h"
#import "GameEntryViewController.h"
#import "ReportsViewController.h"
#import "SettingsViewController.h"
#import "Game.h"
#import "Player.h"
#import "Standing.h"
#import "Individuals.h"
#import "RoundData.h"

#import "MergeFileWindowController.h"

//#import "ServerIdentityWindowController.h"
//#import "PublishedTournament.h"
//#import "PublishWindowController.h"

//#import "GameFileContents.h"
//#import "GameResult.h"
//#import "PointsResult.h"
//#import "TossupResult.h"


@interface Tournament()

- (BOOL)loadTournamentFile:(NSString *)fileName;

- (BOOL)saveTournamentFile:(BOOL)fileTypeIsOSX;

@end

@implementation Tournament

@synthesize tournamentFileName;

@synthesize lastSelectedView;
@synthesize myTargetView;
@synthesize myCurrentViewController;

@synthesize teamList;
@synthesize defaultPlayersPerTeam;
@synthesize gameList;
@synthesize sortedGameList;
@synthesize teamStandings;
@synthesize teamStandingsCopy;  // used for reference when sorting teamStandings mutableArray
@synthesize individualStandings;
@synthesize packetNames;
@synthesize packetNamesUsed;

@synthesize question_0_value, question_1_value, question_2_value, question_3_value;
@synthesize question_0_selected, question_1_selected, question_2_selected, question_3_selected;
@synthesize trackTossUpsHeardSetting, trackPowerNegStatsSetting, trackLightRoundSetting, trackBonusSetting;
@synthesize autoTrackSetting;

@synthesize sortMethodSetting;
@synthesize tossUpHeardSortSetting;

@synthesize useDivisionsSetting;
@synthesize divisionList;

@synthesize tournamentName, hostName, userName, passwordName, directoryName, baseName;
@synthesize reportsBaseName;

@synthesize pathsSetting;

@synthesize roundReportSetting, teamStandingsReportSetting, individualStandingsReportSetting;
@synthesize scoreboardReportSetting, teamDetailsReportSetting, individualDetailsReportSetting;
@synthesize statKeyReportSetting, styleReportSetting, britishStyleReportSetting;
@synthesize allRoundsIncludedInReport, minRoundIncludedInReport, maxRoundIncludedInReport;
@synthesize minRoundsAssigned, maxRoundsAssigned;

@synthesize roundReportName;
@synthesize teamStandingsReportName, individualStandingsReportName;
@synthesize scoreboardReportName;
@synthesize teamDetailsReportName, individualDetailsReportName;
@synthesize statKeyReportName, styleReportName;

@synthesize warning_1_Setting, warning_2_Setting, warning_3_Setting, warning_4_Setting, warning_5_Setting, warning_6_Setting, warning_7_Setting;

@synthesize quickReportRequested;

@synthesize openDocumentsForMergeOrPublish;

@synthesize temporaryWindowController;

-(NSString *)description {
    return [NSString stringWithFormat:@"Name: %@, File: %@",tournamentName, [[[self fileURL] path] lastPathComponent]];
}

- (BOOL)validateUserInterfaceItem:(id < NSValidatedUserInterfaceItem >)theMenuItem {
    BOOL enable = [self respondsToSelector:[theMenuItem action]];
    
    //DebugLog(@"validateMenuItem: %i - %@", [theMenuItem tag], theMenuItem);
    
    switch ([theMenuItem tag]) {
        case kFileMenuNewTag: {
            break;
        }
        case kFileImportTeamsTag: {
            // only enable if teams don't exist
            return ((lastSelectedView == kTournamentOptionsView) && ((teamList != nil) && ([teamList count] == 0)));
            break;
        }
        case kFileMenuSaveTag:
        {
            enable = ([self tournamentFileName] != nil);
            break;
        }
        case kReportsMenuCreateWebTag:
        case kReportsMenuPrintTeamsTag:
        case kReportsMenuPrintIndividualsTag:
        case kReportsMenuPrintGamesTag:
        {
            enable = (([self gameList] != nil) && ([[self gameList] count] > 0));
            break;
        }
        case kFileMenuMergeFilesTag: {
            //return FALSE;
            return ([[[NSDocumentController sharedDocumentController] documents] count] > 1);
            break;
        }
//        case kServerMenuPublishTag: {
//            return [(TournamentAppDelegate *)[NSApp delegate] serverActive];
//            break;
//        }
//        case kServerMenuUnpublishTag: {
//            return [[(TournamentAppDelegate *)[NSApp delegate] publishedTournaments] count] > 0;
//            break;
//        }
//        case kServerMenuImportTag: {
//            return [[(TournamentAppDelegate *)[NSApp delegate] gamesForImport] count] > 0;
//            break;
//        }
            
        default:
            // don't know about item - super covers Revert command
            return [super validateUserInterfaceItem:theMenuItem];
            break;
    }
	return enable;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        // If an error occurs here, return nil.
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"Tournament";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    //DebugLog(@"windowControllerDidLoadNib - tournamentName: %@", tournamentName);
    if (tournamentName == nil) {
        // default settings called when tournament window loaded,
        // also if file load failed
        [self setTournamentName:@""];
        [self setTournamentFileName:nil];
        [self setTeamList:[NSMutableArray arrayWithCapacity:10]];
        [self setGameList:[NSMutableArray arrayWithCapacity:10]];
        [self setPacketNames:[NSMutableDictionary dictionaryWithCapacity:10]];
        [self setDivisionList:[NSMutableArray arrayWithCapacity:10]];
        [self setUseDivisionsSetting:FALSE];
        
        // initial default settings
        [self setUseDivisionsSetting:FALSE];
        [self setQuestion_0_value:15];
        [self setQuestion_1_value:10];
        [self setQuestion_2_value:-5];
        [self setQuestion_3_value:0];
        [self setQuestion_0_selected:TRUE];
        [self setQuestion_1_selected:TRUE];
        [self setQuestion_2_selected:TRUE];
        [self setQuestion_3_selected:FALSE];
        
        // tracking defaults
        [self setTrackTossUpsHeardSetting:TRUE];
        [self setTrackPowerNegStatsSetting:TRUE];
        [self setTrackLightRoundSetting:FALSE];
        
        // bonus conversion
        [self setTrackBonusSetting:TRUE];
        [self setAutoTrackSetting:kSQBS_Automatic];
        
        // ftp info
        [self setUserName:@""];
        [self setHostName:@""];
        [self setDirectoryName:@""];
        [self setPasswordName:@""];
        [self setPathsSetting:0]; // used for FTP
        
        // default to all warnings on
        [self setWarning_1_Setting:TRUE];
        [self setWarning_2_Setting:TRUE];
        [self setWarning_3_Setting:TRUE];
        [self setWarning_4_Setting:TRUE];
        [self setWarning_5_Setting:TRUE];
        [self setWarning_6_Setting:TRUE];
        [self setWarning_7_Setting:TRUE];
        
        // sorting
        [self setSortMethodSetting:kSort_RP];
        [self setTossUpHeardSortSetting:FALSE];
        
        // reports
        [self setRoundReportSetting:TRUE];
        [self setTeamStandingsReportSetting:TRUE];
        [self setIndividualStandingsReportSetting:TRUE];
        [self setTeamDetailsReportSetting:TRUE];
        [self setIndividualDetailsReportSetting:TRUE];
        [self setScoreboardReportSetting:TRUE];
        [self setStatKeyReportSetting:TRUE];
        [self setStyleReportSetting:FALSE];
        [self setBritishStyleReportSetting:FALSE];
        [self setRoundReportName:kRoundReportName];
        [self setTeamStandingsReportName:kTeamStandingsReportName];
        [self setIndividualStandingsReportName:kIndividualStandingsReportName];
        [self setTeamDetailsReportName:kTeamDetailReportName];
        [self setIndividualDetailsReportName:kIndividualDetailReportName];
        [self setScoreboardReportName:kScoreboardReportName];
        [self setStatKeyReportName:kStatKeyDetailReportName];
        [self setStyleReportName:@""];
        [self setBaseName:@""];
        
        //[self setDisplayName:@"untitled Tournament"]; 
    }
    
    // following not stored in file
    [self setAllRoundsIncludedInReport:TRUE];
    [self setMinRoundIncludedInReport:minRoundsAssigned];
    [self setMaxRoundIncludedInReport:maxRoundsAssigned];
    
    // value only applies to Mac version, not stored in file so always init
    [self setDefaultPlayersPerTeam:kMaxDefaultPlayers];
    
    //[self updateChangeCount:NSChangeDone];
    
    // make setup tab default view
    lastSelectedView = kTournamentOptionsView;
    [self viewSelectorChangeAction:nil];
	//[self changeViewController: kTournamentOptionsView];
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
    //DebugLog(@"readFromURL - file: %@, type: %@", [absoluteURL path], typeName);
    if ([typeName isEqualToString:kWindowsFileType]) {
        if (![[[absoluteURL path] pathExtension] isEqualToString:@""]) {
            return NO;
        }
    }
    
//    if ([typeName isEqualToString:kScoringAppFileType]) {
//        DebugLog(@"readFromURL - trying to read scoring app game file");
//        return NO;
//    }
    
    return [self loadTournamentFile:[absoluteURL path]];
}

- (BOOL)writeToURL:(NSURL *)inAbsoluteURL ofType:(NSString *)inTypeName error:(NSError **)outError
{
    //DebugLog(@"writeToURL - file: %@, type: %@", [inAbsoluteURL path], inTypeName);
    if (![tournamentFileName isEqualToString:[inAbsoluteURL path]]) {
        [self setTournamentFileName:[inAbsoluteURL path]];
    }
    
    return [self saveTournamentFile:[inTypeName isEqualToString:kOXsFileType]];
}

#pragma mark -
#pragma mark NSWindowDelegate

- (void) windowShouldCloseAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)context {
    //DebugLog(@"windowShouldCloseAlertDidEnd change status: %@, button: %i", [self isDocumentEdited]? @"Unsaved changes" : @"no unsaved changes", returnCode);
    switch (returnCode) {
        case NSAlertDefaultReturn: {
            // user wants to save
            //DebugLog(@"windowShouldCloseAlertDidEnd - do a Save tournament name: %@", tournamentName);
            // if no filename need to assign one since SaveAs dialog disappears
            if ([self fileURL] == nil) {
                // make name for document file
                NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSDesktopDirectory inDomains:NSUserDomainMask];
                if ((urls != nil) && ([urls count] > 0)) {
                    NSString *fileName = [(NSURL *)[urls objectAtIndex:0] path];
                    if ((tournamentName == nil) || ([tournamentName length] == 0)) {
                        [self setTournamentName:@"untitled Tournament"];
                    }
                    fileName = [fileName stringByAppendingPathComponent:tournamentName];
                    [self setFileURL:[NSURL fileURLWithPath:fileName isDirectory:FALSE]];
                    //DebugLog(@"windowShouldCloseAlertDidEnd - filename: %@, fileURL: %@", fileName, [self fileURL]);
                }
            }
            [self saveDocument:[myTargetView window]];
            [[myTargetView window] close];
            break;
        }
        case NSAlertAlternateReturn: {
            // user wants to ignore unsaved changes
            // close window
            //DebugLog(@"windowShouldCloseAlertDidEnd - ignore");
            [[myTargetView window] close];
            break;
        }
        case NSAlertOtherReturn: {
            // user wants to cancel
            //DebugLog(@"windowShouldCloseAlertDidEnd - cancel");
            // nothing more
            return;
            break;
        }
            
        default:
            break;
    }
}

- (BOOL)windowShouldClose:(id)sender {
    //DebugLog(@"windowShouldClose - sender %@", sender);
    
    // clear change count
    // system will put up save message if unsaved changes before now, but doesn't clear if the user
    // ignores.
    [self updateChangeCount:NSChangeCleared];
    BOOL needAlert = ![(TournamentViewController *)myCurrentViewController shouldViewClose];
    
    // if unsaved changes put up alert
    if (needAlert) {
        // put up alert
        NSAlert *alert = [NSAlert alertWithMessageText:@"Do you want to save changes before closing?" defaultButton:@"Save..." alternateButton:@"Don't Save" otherButton:@"Cancel" informativeTextWithFormat:@"Changes will be lost when tournament window is closed."];
        [alert beginSheetModalForWindow:(NSWindow *)sender modalDelegate:self didEndSelector:@selector(windowShouldCloseAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
        // saving / closing / cancel will be done in didEndSelector
        return FALSE;
    }
    //DebugLog(@"windowShouldClose - no alert");
    return TRUE;
}

#pragma mark -
#pragma mark Tournament extensions


#define kBlankRecord @" "


- (long)warningsAsInt {
    long result = 0;
    if (warning_1_Setting) {
        result += 128;
    }
    if (warning_2_Setting) {
        result += 64;
    }
    if (warning_3_Setting) {
        result += 32;
    }
    if (warning_4_Setting) {
        result += 16;
    }
    if (warning_5_Setting) {
        result += 8;
    }
    if (warning_6_Setting) {
        result += 4;
    }
    if (warning_7_Setting) {
        result += 2;
    }
    //DebugLog(@"warningsAsInt - result: %i, {%i, %i, %i, %i, %i, %i, %i}", result, warning_7_Setting, warning_6_Setting, warning_5_Setting, warning_4_Setting, warning_3_Setting, warning_2_Setting, warning_1_Setting);
    return result;
}

- (void)setAllWarningsFromInt:(long)warningValue {
    warning_1_Setting = ((warningValue & 128) != 0);
    warning_2_Setting = ((warningValue & 64) != 0);
    warning_3_Setting = ((warningValue & 32) != 0);
    warning_4_Setting = ((warningValue & 16) != 0);
    warning_5_Setting = ((warningValue & 8) != 0);
    warning_6_Setting = ((warningValue & 4) != 0);
    warning_7_Setting = ((warningValue & 2) != 0);
    //DebugLog(@"setAllWarningsFromInt - value: %i, {%i, %i, %i, %i, %i, %i, %i}", warningValue, warning_7_Setting, warning_6_Setting, warning_5_Setting, warning_4_Setting, warning_3_Setting, warning_2_Setting, warning_1_Setting);
}

- (long)makePathsValue {
    return (britishStyleReportSetting * 2) + pathsSetting;
}

- (void)updateUsingPathsValue:(long)pathsValue {
    britishStyleReportSetting = pathsValue & 2;
    pathsSetting = pathsValue & 1;
}

- (void)closeUntitledDocuments {
    // on app launch new document is opened, close it if user hasn't made changes to it
    // tried putting hooks in openDocument, however not able to stop closing if open is cancelled
    for (int doc = 0; doc < [[[NSDocumentController sharedDocumentController] documents] count]; doc++) {
        Tournament *thisDoc = [[[NSDocumentController sharedDocumentController] documents] objectAtIndex:doc];
        if (thisDoc != self) {
            if (([thisDoc tournamentFileName] == nil) 
                && (([thisDoc teamList] == nil) || ([[thisDoc teamList] count] < 1)) 
                && (![thisDoc hasUnautosavedChanges])) {
                // nothing in this document, probably left over from user launching, then opening a file
                // close the document to eliminate clutter
                [thisDoc close];
            }
        }
    }
}

- (BOOL)loadTournamentFile:(NSString *)fileName {
    BOOL loadSuccess = FALSE;
    
    // these are for compatibility with SQBS vers 2 files (??)
    BOOL readExhibitionInfo = FALSE;
    BOOL readPacketsInfo = FALSE;
    
    [self setDivisionList:nil];    
    
    // process file.
    NSStringEncoding encoding;
    
    NSString *data = [NSString stringWithContentsOfFile:fileName usedEncoding:&encoding error:NULL];
    //DebugLog(@"loadTournamentFile - string length: %i", [data length]);
    
    long maxRecordsPerTeam = kMaxPlayersPerTeam + 1;  // default for not using divisions, includes team name
                                                      // keys contains - team name, players - exhibition info added manually, division info add later
    NSArray *keys = [NSArray arrayWithObjects:kTeamNameKey, kPlayer1Key, kPlayer2Key, kPlayer3Key, kPlayer4Key, kPlayer5Key, kPlayer6Key, kPlayer7Key, kPlayer8Key, kPlayer9Key, kPlayer10Key, kPlayer11Key, kPlayer12Key, nil];
    
    if (data != nil) {
        NSArray *lines = [data componentsSeparatedByString:kLineEndCharacter];
        //DebugLog(@"loaded Tournament file - line count: %i, encoding: %i", [lines count], encoding);
        
        [self setTeamList:nil];
        [self setTeamList:[NSMutableArray arrayWithCapacity:10]];
        
        // read team info
        int numberOfTeams = [[lines objectAtIndex:0] intValue];
        // check in case no a SQBS file (no extension on Windows could allow any file to be read)
        if ((numberOfTeams < 0) || (numberOfTeams > 100)) {
            // exceeded current allowed players on a team - put up warning
            NSString *firstLine = [lines objectAtIndex:0];
            if ([firstLine length] > 4) {
                firstLine = [NSString stringWithFormat:@"%@ ...", [firstLine substringToIndex:4]];
            }
            NSAlert *alert = [NSAlert alertWithMessageText:@"File contents suspect. May not be a tournament file." 
                                             defaultButton:nil 
                                           alternateButton:nil 
                                               otherButton:nil 
                                 informativeTextWithFormat:@"Team count read as \"%@\". Expected number [0 - 100].", firstLine];
            //informativeTextWithFormat:[NSString stringWithFormat:@"Team count read as \"%@\". Expected number [0 - 100].", firstLine]];
            [alert runModal];
            alert = nil;
            data = nil;
            keys = nil;
            // abort loading
            return FALSE;
        }
        int lineIndex = 1;
        BOOL suppressAlert = FALSE;
        for (int teamNumber = 0; teamNumber < numberOfTeams; teamNumber++) {
            if (lineIndex > [lines count]) {
                return loadSuccess;
                data = nil;
                keys = nil;
            }
            int memberCount = [[lines objectAtIndex:lineIndex] intValue]; // includes team name
            if ((lineIndex + memberCount) > [lines count]) {
                return loadSuccess;
                data = nil;
                keys = nil;
            }
            lineIndex ++;
            
            if ((memberCount > maxRecordsPerTeam) && !suppressAlert) {
                // exceeded current allowed players on a team - put up warning
                NSAlert *alert = [NSAlert alertWithMessageText:@"Current max players per team exceeded." 
                                                 defaultButton:@"Continue" 
                                               alternateButton:@"Abort" 
                                                   otherButton:nil 
                                     informativeTextWithFormat:@"Team '%@'. Only first %i players imported.", [lines objectAtIndex:lineIndex], kMaxPlayersPerTeam];
                [alert setShowsSuppressionButton:TRUE];
                long alertResult = [alert runModal];
                suppressAlert = [[alert suppressionButton] state];
                if (alertResult == NSAlertAlternateReturn) {
                    // abort import
                    data = nil;
                    keys = nil;
                    return loadSuccess;
                }
            }
            
            NSRange teamRange = NSMakeRange(lineIndex, fminl(memberCount, maxRecordsPerTeam));
            NSRange keyRange = NSMakeRange(0, fminl(memberCount, maxRecordsPerTeam));
            NSMutableDictionary *aTeam = [NSMutableDictionary dictionaryWithObjects:[lines subarrayWithRange:teamRange] forKeys:[keys subarrayWithRange:keyRange]];
            // add index keys - used to update game team index if teams are sorted
            NSString *teamNumberAsString = [NSString stringWithFormat:@"%i", teamNumber];
            [aTeam setObject:teamNumberAsString forKey:kOriginalTeamIndexKey];
            [aTeam setObject:teamNumberAsString forKey:kSortedTeamIndexKey];
            [teamList addObject:aTeam];
            aTeam = nil;
            lineIndex = lineIndex + memberCount;
        }
        
        //DebugLog(@"loadTournamentFile - teamlist: %@", teamList);
        
        // read game info
        if (lineIndex > [lines count]) return loadSuccess;
        int numberOfGames = [[lines objectAtIndex:lineIndex++] intValue];
        // DebugLog(@"load tournament - # games: %i, lineIndex: %i", numberOfGames, lineIndex);
        // reset game and packet info
        [self setGameList:nil];
        [self setGameList:[NSMutableArray arrayWithCapacity:10]];
        
        [self setPacketNames:nil];
        [self setPacketNames:[NSMutableDictionary dictionaryWithCapacity:10]];
        long minRoundNumber = 9999;
        long maxRoundNumber = -1;
        for (int gameRecord = 0; gameRecord < numberOfGames; gameRecord++) {
            if ([lines count] > (lineIndex + kRecordsPerGame)) {
                Game *theGame = [[Game alloc] init];
                [theGame setGameIndex:[lines objectAtIndex:lineIndex++]];
                //DebugLog(@"game index: %@, lineIndex: %i", [theGame gameIndex], lineIndex);
                [theGame setTeam_A_index:[[lines objectAtIndex:lineIndex++] intValue]];
                [theGame setTeam_B_index:[[lines objectAtIndex:lineIndex++] intValue]];
                [theGame setTeam_A_score:[lines objectAtIndex:lineIndex++]];
                [theGame setTeam_B_score:[lines objectAtIndex:lineIndex++]];
                [theGame setTossUpsHeard:[[lines objectAtIndex:lineIndex++] intValue]];
                long round = [[lines objectAtIndex:lineIndex++] intValue];
                // don't allow negative round numbers
                if (round < 0) {
                    round = 0;
                }
                minRoundNumber = (long)fmin(minRoundNumber, round);
                maxRoundNumber = (long)fmax(maxRoundNumber, round);
                [packetNames setObject:kPacketMissingPacketNameValue forKey:[NSString stringWithFormat:kPacketRoundBaseKeyFormat, round]];
                [theGame setRound:round];
                //DebugLog(@"loadTournament - round/min/max: {%i, %i, %i} dict: %@", round, minRoundNumber, maxRoundNumber, packetNames);
                // bounce back info stored with bonus info : aaaaabbbbb  aaaaa = bounce back, bbbbb = bonus
                long bonusValue = [[lines objectAtIndex:lineIndex++] intValue];
                [theGame setTeam_A_BonusHeard:(bonusValue % kBounceBackCodingMultiplier)];
                [theGame setTeam_A_BounceBacksHeard:(bonusValue / kBounceBackCodingMultiplier)];
                bonusValue = [[lines objectAtIndex:lineIndex++] intValue];
                [theGame setTeam_A_BonusPoints:(bonusValue % kBounceBackCodingMultiplier)];
                [theGame setTeam_A_BounceBacksPoints:(bonusValue / kBounceBackCodingMultiplier)];
                bonusValue = [[lines objectAtIndex:lineIndex++] intValue];
                [theGame setTeam_B_BonusHeard:(bonusValue % kBounceBackCodingMultiplier)];
                [theGame setTeam_B_BounceBacksHeard:(bonusValue / kBounceBackCodingMultiplier)];
                bonusValue = [[lines objectAtIndex:lineIndex++] intValue];
                [theGame setTeam_B_BonusPoints:(bonusValue % kBounceBackCodingMultiplier)];
                [theGame setTeam_B_BounceBacksPoints:(bonusValue / kBounceBackCodingMultiplier)];
                [theGame setOvertime:[[lines objectAtIndex:lineIndex++] intValue]];
                [theGame setTeam_A_OvertimeGets:[[lines objectAtIndex:lineIndex++] intValue]];
                [theGame setTeam_B_OvertimeGets:[[lines objectAtIndex:lineIndex++] intValue]];
                [theGame setForfeit:[[lines objectAtIndex:lineIndex++] intValue]];
                [theGame setTeam_A_LighteningPoints:[[lines objectAtIndex:lineIndex++] intValue]];
                [theGame setTeam_B_LighteningPoints:[[lines objectAtIndex:lineIndex++] intValue]];
                // add player info
                NSString *gamesPlayed;
                long question0;
                long question1;
                long question2;
                long question3;
                long points;
                for (int p = 0; p < 8; p++) {
                    // Team A player p
                    long playerIndex = [[lines objectAtIndex:lineIndex++] intValue];
                    //DebugLog(@"team A - index: %i, playerIndex: %i, lineIndex: %i", p, playerIndex, lineIndex);
                    if (playerIndex < 0) {
                        // no player
                        lineIndex = lineIndex + 6;  // advance to next player
                    } else {
                        // get player info
                        gamesPlayed = [lines objectAtIndex:lineIndex++];
                        question0 = [[lines objectAtIndex:lineIndex++] intValue];
                        question1 = [[lines objectAtIndex:lineIndex++] intValue];
                        question2 = [[lines objectAtIndex:lineIndex++] intValue];
                        question3 = [[lines objectAtIndex:lineIndex++] intValue];
                        points = [[lines objectAtIndex:lineIndex++] intValue];
                        [theGame addTeam_A_player:p playerIndex:playerIndex gp:gamesPlayed q0:question0 q1:question1 q2:question2 q3:question3 points:points];
                    }
                    // Team B player p
                    playerIndex = [[lines objectAtIndex:lineIndex++] intValue];
                    //DebugLog(@"team B - index: %i, playerIndex: %i, lineIndex: %i", p, playerIndex, lineIndex);
                    if (playerIndex < 0) {
                        // no player
                        lineIndex = lineIndex + 6;  // advance to next player
                    } else {
                        // get player info
                        gamesPlayed = [lines objectAtIndex:lineIndex++];
                        question0 = [[lines objectAtIndex:lineIndex++] intValue];
                        question1 = [[lines objectAtIndex:lineIndex++] intValue];
                        question2 = [[lines objectAtIndex:lineIndex++] intValue];
                        question3 = [[lines objectAtIndex:lineIndex++] intValue];
                        points = [[lines objectAtIndex:lineIndex++] intValue];
                        [theGame addTeam_B_player: p playerIndex:playerIndex gp:gamesPlayed q0:question0 q1:question1 q2:question2 q3:question3 points:points];
                    }
                }
                [gameList addObject:theGame];
                [theGame release];
            } else {
                data = nil;
                keys = nil;
                return loadSuccess;
            }
            
        }
        if (minRoundNumber > 999) {
            minRoundNumber = 0;
            maxRoundNumber = 0;
        }
        [self setMinRoundIncludedInReport:minRoundNumber];
        [self setMaxRoundIncludedInReport:maxRoundNumber];
        [self setMinRoundsAssigned:minRoundNumber];
        [self setMaxRoundsAssigned:maxRoundNumber];
        //DebugLog(@"loadTournament - report: {%li, %li}, assign: {%li, %li,}", minRoundIncludedInReport, maxRoundIncludedInReport, minRoundsAssigned, maxRoundsAssigned);
        
        // read tournament options
        if ((lineIndex + 7) > [lines count]) return loadSuccess;
        [self setTrackBonusSetting:[[lines objectAtIndex:lineIndex++] intValue]];
        [self setAutoTrackSetting:[[lines objectAtIndex:lineIndex++] intValue]];
        long value = [[lines objectAtIndex:lineIndex++] intValue];
        // this value is bit shifted with whether exhibition info exists - SQBS 2 feature
        if (value > 1) {
            value = value - 2;
            readExhibitionInfo = TRUE;
        }
        [self setTrackPowerNegStatsSetting:value];
        [self setTrackLightRoundSetting:[[lines objectAtIndex:lineIndex++] boolValue]]; 
        [self setTrackTossUpsHeardSetting:[[lines objectAtIndex:lineIndex++] intValue]];
        value = [[lines objectAtIndex:lineIndex++] intValue];
        // this value is bit shifted with whether packet info exists - SQBS 2 feature
        if (value > 1) {
            value = value - 2;
            readPacketsInfo = TRUE;
        }
        [self setTossUpHeardSortSetting:value];
        [self setAllWarningsFromInt:[[lines objectAtIndex:lineIndex++] intValue]];
        
        // read report settings
        if ((lineIndex + 8) > [lines count]) return loadSuccess;
        [self setRoundReportSetting:[[lines objectAtIndex:lineIndex++] boolValue]];
        [self setTeamStandingsReportSetting:[[lines objectAtIndex:lineIndex++] boolValue]];
        [self setIndividualStandingsReportSetting:[[lines objectAtIndex:lineIndex++] boolValue]];
        [self setScoreboardReportSetting:[[lines objectAtIndex:lineIndex++] boolValue]];
        [self setTeamDetailsReportSetting:[[lines objectAtIndex:lineIndex++] boolValue]];
        [self setIndividualDetailsReportSetting:[[lines objectAtIndex:lineIndex++] boolValue]];
        [self setStatKeyReportSetting:[[lines objectAtIndex:lineIndex++] boolValue]];
        [self setStyleReportSetting:[[lines objectAtIndex:lineIndex++] boolValue]];       
        
        // read division setting
        if ((lineIndex + 8) > [lines count]) return loadSuccess;
        [self setUseDivisionsSetting:[[lines objectAtIndex:lineIndex++] boolValue]];
        
        // more admin info
        [self setSortMethodSetting:[[lines objectAtIndex:lineIndex++] intValue]];
        [self setTournamentName:[lines objectAtIndex:lineIndex++]];
        [self setHostName:[lines objectAtIndex:lineIndex++]];
        [self setUserName:[lines objectAtIndex:lineIndex++]];
        [self setDirectoryName:[lines objectAtIndex:lineIndex++]];
        [self setBaseName:[lines objectAtIndex:lineIndex++]];
        
        [self updateUsingPathsValue:[[lines objectAtIndex:lineIndex++] intValue]];
        
        // read report names
        if ((lineIndex + 8) > [lines count]) return loadSuccess;
        [self setRoundReportName:[lines objectAtIndex:lineIndex++]];
        [self setTeamStandingsReportName:[lines objectAtIndex:lineIndex++]];
        [self setIndividualStandingsReportName:[lines objectAtIndex:lineIndex++]];
        [self setScoreboardReportName:[lines objectAtIndex:lineIndex++]];
        [self setTeamDetailsReportName:[lines objectAtIndex:lineIndex++]];
        [self setIndividualDetailsReportName:[lines objectAtIndex:lineIndex++]];
        [self setStatKeyReportName:[lines objectAtIndex:lineIndex++]];
        [self setStyleReportName:[lines objectAtIndex:lineIndex++]];        
        
        // number of divisions
        if (lineIndex > [lines count]) return loadSuccess;
        long numberOfDivisions = [[lines objectAtIndex:lineIndex++] intValue];
        if (numberOfDivisions > 0) {
            // division names
            if ((lineIndex + numberOfDivisions) > [lines count]) return loadSuccess;
            [self setDivisionList:[NSMutableArray arrayWithCapacity:10]];
            for (int d = 0; d < numberOfDivisions; d++) {
                [divisionList addObject:[lines objectAtIndex:lineIndex++]];
            }
            // assign divisions to each team
            // first entry is # of teams, which should be same above so skip
            lineIndex++;
            if ((lineIndex + numberOfTeams + 1) > [lines count]) return loadSuccess;
            for (int i = 0; i < numberOfTeams; i++) {
                long divisionIndex = [[lines objectAtIndex:lineIndex++] intValue];
                // add info if index is in bounds - could be case of some teams not assigned to division
                if ((divisionIndex >=0) && (divisionIndex < [divisionList count])){
                    NSMutableDictionary *aTeam = [teamList objectAtIndex:i];
                    [aTeam setObject:[divisionList objectAtIndex:divisionIndex] forKey:kDivisionKey];
                    [teamList replaceObjectAtIndex:i withObject:aTeam];
                    aTeam = nil;
                }
            }
        } else {
            // skip next #teams + 1 records since there are no divisions (# teams record + 1 record for each team)
            lineIndex = lineIndex + numberOfTeams + 1;
        }
        
        //DebugLog(@"loadTournamentFile - teamlist: %@", teamList);
        
        // read question values
        if ((lineIndex + 4) > [lines count]) return loadSuccess;
        [self setQuestion_0_value:[[lines objectAtIndex:lineIndex++] intValue]];
        [self setQuestion_0_selected:(question_0_value != 0)];
        [self setQuestion_1_value:[[lines objectAtIndex:lineIndex++] intValue]];
        [self setQuestion_1_selected:(question_1_value != 0)];
        [self setQuestion_2_value:[[lines objectAtIndex:lineIndex++] intValue]];
        [self setQuestion_2_selected:(question_2_value != 0)];
        [self setQuestion_3_value:[[lines objectAtIndex:lineIndex++] intValue]];
        [self setQuestion_3_selected:(question_3_value != 0)];
        
        // read number of packets
        if (readPacketsInfo) {
            if (lineIndex > [lines count]) return loadSuccess;
            long numberOfPackets = [[lines objectAtIndex:lineIndex++] intValue];
            [self setPacketNamesUsed:numberOfPackets];
            //DebugLog(@"load file - packetNamesUsed: %i, packetNames %@", packetNamesUsed, packetNames);
            if ((lineIndex + numberOfPackets) > [lines count]) return loadSuccess;
            if (packetNamesUsed == 0) {
                // empty packet name dictionary
                //[self setPacketNames:[NSMutableDictionary dictionaryWithCapacity:10]];
            } else {
                for (long roundNumber = 0; roundNumber < numberOfPackets; roundNumber++) {
                    NSString *thePacketName = [lines objectAtIndex:lineIndex++];
                    // trim off blanks
                    thePacketName = [thePacketName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    if ([thePacketName length] == 0) {
                        thePacketName = kPacketMissingPacketNameValue;
                    }
                    [packetNames setObject:thePacketName forKey:[NSString stringWithFormat:kPacketRoundBaseKeyFormat, (roundNumber + minRoundNumber)]];
                }
            }
            //DebugLog(@"load file - packet names: %@", packetNames);
        } else {
            // packet names don't exist in this file (older version)
            // empty packet name dictionary
            //[self setPacketNames:[NSMutableDictionary dictionaryWithCapacity:10]];
            [self setPacketNamesUsed:0];
        }
        
        if (readExhibitionInfo) {
            // read exhibition info
            // first entry is # of teams, which should be same above so skip
            lineIndex++;
            if ((lineIndex + numberOfTeams) > [lines count]) return loadSuccess;
            for (int i = 0; i < numberOfTeams; i++) {
                BOOL exhibitionTeam = [[lines objectAtIndex:lineIndex++] boolValue];
                // only add key if it is an exhibition team
                if (exhibitionTeam) {
                    NSMutableDictionary *aTeam = [teamList objectAtIndex:i];
                    [aTeam setObject:[NSNumber numberWithBool:exhibitionTeam] forKey:kExhibitionTeamKey];
                    [teamList replaceObjectAtIndex:i withObject:aTeam];
                    aTeam = nil;
                }
            }
        }
        
        //DebugLog(@"loadTournamentFile - teamlist: %@", teamList);
        
        //DebugLog(@"loaded Tournament file - team count: %i", [teamList count]);
        
        loadSuccess = TRUE;
        
        // on app launch new document is opened, close it if user hasn't made changes to it
        [self closeUntitledDocuments];
        
        [self setTournamentFileName:fileName];
        //[self setDisplayName:[tournamentFileName lastPathComponent]];
        [self updateChangeCount:NSChangeCleared];
        //        if ([[NSDocumentController sharedDocumentController] autosavingDelay] <= 0) {
        //            [[NSDocumentController sharedDocumentController] setAutosavingDelay:(1.0 * 60.0)];
        //        }
    }
    
    keys = nil;
    data = nil;
    
    return loadSuccess;
}

- (NSString *)createFileRecordForTeam:(long)teamIndex {
    if ((teamIndex < 0) || (teamIndex >= [teamList count])) {
        return kBlankRecord;
    }
    NSMutableDictionary *theTeam = [teamList objectAtIndex:teamIndex];
    long recordCount = [theTeam count] - kDefaultNonSavedKeyCount;
    // decrement if division or exhibition keys
    if ([theTeam objectForKey:kDivisionKey]) {
        recordCount = recordCount - 1;
    }
    if ([theTeam objectForKey:kExhibitionTeamKey]) {
        recordCount = recordCount - 1;
    }
    // create record <# / team name / player1 name / player2 name / ... / playerN name>
    NSString *record = [NSString stringWithFormat:@"%@%li%@%@", kLineEndCharacter, recordCount, kLineEndCharacter, [theTeam objectForKey:kTeamNameKey]];
    recordCount = recordCount - 1;
    for (int playerNumber = 1; playerNumber <= recordCount; playerNumber++) {
        NSString *key = [NSString stringWithFormat:kPlayerBaseKeyFormat, playerNumber];
        record = [record stringByAppendingFormat:@"%@%@", kLineEndCharacter, [theTeam objectForKey:key]];
    }
    //DebugLog(@"createFileRecordForTeam - team: %@, record: %@", theTeam, record);
    theTeam = nil;
    
    return record;
}

- (BOOL)saveTournamentFile:(BOOL)fileTypeIsOSX {
    BOOL saveSuccess = FALSE;
    
    if (tournamentFileName == nil) {
        return saveSuccess;
    }
    
    //DebugLog(@"saveTournamentFile - fileType: %@, fileName: %@, URL: %@", [self fileType], tournamentName, [[self fileURL] path]);
    
    // force pending changes to be recorded
    NSArray *windowControllers = [self windowControllers];
    if (windowControllers != nil) {
        [[(NSWindowController *)[windowControllers objectAtIndex:0] window] makeFirstResponder:nil];
    }
    
    NSMutableString *data = [NSMutableString stringWithCapacity:5000];
    long teamCount = [teamList count];
    NSString *teamCountRecord = [NSString stringWithFormat:@"%@%li", kLineEndCharacter, teamCount];
    [data appendFormat:@"%li", teamCount];  // first record so no line end
                                           // add team name info
    for (int i = 0; i < teamCount; i++) {
        [data appendString:[self createFileRecordForTeam:i]];
    }
    
    // add game info
    long gameCount = 0;
    if (gameList != nil) {
        gameCount = [gameList count];
    }
    [data appendFormat:@"%@%li", kLineEndCharacter, gameCount];
    for (int g = 0; g < gameCount; g++) {
        [data appendString:[(Game *)[gameList objectAtIndex:g] createGameRecord]];
    }
    
    [data appendFormat:@"%@%i", kLineEndCharacter, trackBonusSetting];
    // autoBounceBack type not supported in windows, change if necessary
    long tempAutoTrackSetting = autoTrackSetting;
    if (!fileTypeIsOSX && (autoTrackSetting == kSQBS_AutoBounceback)) {
        tempAutoTrackSetting = kSQBS_Bounceback;
    }
    [data appendFormat:@"%@%li", kLineEndCharacter, tempAutoTrackSetting];
    // for SQBS vers 2
    // in SQBS vers 2 (??) powerNeg setting is bit shifted with whether to read exhibition data
    // value = 0/1 is SQBS v2 powerNeg = FALSE / TRUE & no exhibition data
    // value = 2/3 is SQBS v3 powerNeg = FALSE / TRUE
    [data appendFormat:@"%@%li", kLineEndCharacter, (trackPowerNegStatsSetting + 2)];
    [data appendFormat:@"%@%i", kLineEndCharacter, trackLightRoundSetting];
    [data appendFormat:@"%@%li", kLineEndCharacter, trackTossUpsHeardSetting];
    // for SQBS vers 2
    // in SQBS vers 2 (??) tuh sort setting is bit shifted with whether to read packet name data
    // value = 0/1 is SQBS v2 tuh sort = FALSE / TRUE & no packet name data
    // value = 2/3 is SQBS v3 tuh sort = FALSE / TRUE
    [data appendFormat:@"%@%li", kLineEndCharacter, (tossUpHeardSortSetting + 2)];
    [data appendFormat:@"%@%li", kLineEndCharacter, [self warningsAsInt]];
    
    // add report settings
    [data appendFormat:@"%@%i", kLineEndCharacter, roundReportSetting];
    [data appendFormat:@"%@%i", kLineEndCharacter, teamStandingsReportSetting];
    [data appendFormat:@"%@%i", kLineEndCharacter, individualStandingsReportSetting];
    [data appendFormat:@"%@%i", kLineEndCharacter, scoreboardReportSetting];
    [data appendFormat:@"%@%i", kLineEndCharacter, teamDetailsReportSetting];
    [data appendFormat:@"%@%i", kLineEndCharacter, individualDetailsReportSetting];
    [data appendFormat:@"%@%i", kLineEndCharacter, statKeyReportSetting];
    [data appendFormat:@"%@%i", kLineEndCharacter, styleReportSetting];    
    
    // add division setting
    [data appendString:[NSString stringWithFormat:@"%@%i", kLineEndCharacter, useDivisionsSetting]];
    
    // add sort method
    [data appendFormat:@"%@%li", kLineEndCharacter, sortMethodSetting];     
    
    // add admin info
    [data appendString:[NSString stringWithFormat:@"%@%@", kLineEndCharacter, (tournamentName != nil) ? tournamentName : kBlankRecord]];
    [data appendString:[NSString stringWithFormat:@"%@%@", kLineEndCharacter, (hostName != nil) ? hostName : kBlankRecord]];
    [data appendString:[NSString stringWithFormat:@"%@%@", kLineEndCharacter, (userName != nil) ? userName : kBlankRecord]];
    [data appendString:[NSString stringWithFormat:@"%@%@", kLineEndCharacter, (directoryName != nil) ? directoryName : kBlankRecord]];
    [data appendString:[NSString stringWithFormat:@"%@%@", kLineEndCharacter, (baseName != nil) ? baseName : kBlankRecord]];
    
    // add path setting
    [data appendFormat:@"%@%li", kLineEndCharacter, [self makePathsValue]]; 
    
    // add report names
    [data appendFormat:@"%@%@", kLineEndCharacter, roundReportName];
    [data appendFormat:@"%@%@", kLineEndCharacter, teamStandingsReportName];
    [data appendFormat:@"%@%@", kLineEndCharacter, individualStandingsReportName];
    [data appendFormat:@"%@%@", kLineEndCharacter, scoreboardReportName];
    [data appendFormat:@"%@%@", kLineEndCharacter, teamDetailsReportName];
    [data appendFormat:@"%@%@", kLineEndCharacter, individualDetailsReportName];
    [data appendFormat:@"%@%@", kLineEndCharacter, statKeyReportName];
    [data appendFormat:@"%@%@", kLineEndCharacter, styleReportName]; 
    
    // add division names
    long divisionCount = [divisionList count];
    [data appendFormat:@"%@%li", kLineEndCharacter, divisionCount];
    for (int d = 0; d < divisionCount; d++) {
        [data appendFormat:@"%@%@", kLineEndCharacter, [divisionList objectAtIndex:d]];
    }
    
    // add team division name
    [data appendString:teamCountRecord];
    for (int i = 0; i < teamCount; i++) {
        // if not using divisions, record -1
        long divisionIndex = -1;
        if ((divisionList != nil) && ([divisionList count] > 0)) {
            NSString *divisionName = [[teamList objectAtIndex:i] objectForKey:kDivisionKey];
            if (divisionName) {
                divisionIndex = [divisionList indexOfObject:divisionName];
            }
        }
        [data appendFormat:@"%@%li", kLineEndCharacter, divisionIndex];
    }
    
    // add question values
    // unselected questions saved as 0 value regardless of actual value
    [data appendFormat:@"%@%li", kLineEndCharacter, question_0_selected ? question_0_value : 0];
    [data appendFormat:@"%@%li", kLineEndCharacter, question_1_selected ? question_1_value : 0];
    [data appendFormat:@"%@%li", kLineEndCharacter, question_2_selected ? question_2_value : 0];
    [data appendFormat:@"%@%li", kLineEndCharacter, question_3_selected ? question_3_value : 0];
//    [data appendFormat:@"%@%li", kLineEndCharacter, question_0_value];
//    [data appendFormat:@"%@%li", kLineEndCharacter, question_1_value];
//    [data appendFormat:@"%@%li", kLineEndCharacter, question_2_value];
//    [data appendFormat:@"%@%li", kLineEndCharacter, question_3_value];
    
    if (packetNamesUsed > 0) {
        // file storage assumes names assigned to sequential rounds (min to max)
        // gaps may exist though so replace packetNamesUsed value with number of Rounds
        // if packet name is not assigned to that round store blank
        [data appendFormat:@"%@%li", kLineEndCharacter, (maxRoundsAssigned - minRoundsAssigned + 1)];
        for (double roundNumber = minRoundsAssigned; roundNumber <= maxRoundsAssigned; roundNumber++) {
            NSString *name = [packetNames objectForKey:[NSString stringWithFormat:kPacketRoundBaseKeyFormat, (long)roundNumber]];
            if ((name == nil) || [name isEqualToString:kPacketMissingPacketNameValue]) {
                name = @" ";
            }
            [data appendFormat:@"%@%@", kLineEndCharacter, name];
        }
    } else {
        // indicate no packet names used with zero
        [data appendFormat:@"%@0", kLineEndCharacter];
    }
    
    // add team exhibition info
    [data appendString:teamCountRecord];
    for (int i = 0; i < teamCount; i++) {
        long exhibition = 0; // false
        id exhibitionValue = [[teamList objectAtIndex:i] objectForKey:kExhibitionTeamKey];
        if (exhibitionValue) {
            exhibition = [exhibitionValue intValue];
        }
        [data appendFormat:@"%@%li", kLineEndCharacter, exhibition];
    }
    
    // all done
    
    NSError *error;
    saveSuccess = [data writeToFile:tournamentFileName atomically:YES encoding:NSISOLatin1StringEncoding error:&error];
    if (saveSuccess) {
        [self updateChangeCount:NSChangeCleared];
    } else {
        DebugLog(@"save failed: error %i, %@", [error code], [error localizedDescription]);
    }
    
    //DebugLog(@"saveTournamentFile");
    
    return saveSuccess;
}

- (BOOL)importTeamFile:(NSString *)fileName {
    BOOL loadSuccess = FALSE;
    
    [self setDivisionList:nil];
    
    // process file.
    NSStringEncoding encoding;
    
    NSString *data = [NSString stringWithContentsOfFile:fileName usedEncoding:&encoding error:NULL];
    
    long maxRecordsPerTeam = kMaxPlayersPerTeam + 1;  // default for not using divisions, includes team name
    NSArray *keys;
    //DebugLog(@"import file - use divisions: %i", useDivisionsSetting);
    if (useDivisionsSetting) {
        // keys contains - team name, division name, players - exhibition info added manually
        keys = [NSArray arrayWithObjects:kTeamNameKey, kDivisionKey, kPlayer1Key, kPlayer2Key, kPlayer3Key, kPlayer4Key, kPlayer5Key, kPlayer6Key, kPlayer7Key, kPlayer8Key, kPlayer9Key, kPlayer10Key, kPlayer11Key, kPlayer12Key, nil];
        maxRecordsPerTeam = kMaxPlayersPerTeam + 2; // includes team name and division name
        [self setDivisionList:[NSMutableArray arrayWithCapacity:10]];
    } else {
        // keys contains - team name, players - exhibition info added manually
        keys = [NSArray arrayWithObjects:kTeamNameKey, kPlayer1Key, kPlayer2Key, kPlayer3Key, kPlayer4Key, kPlayer5Key, kPlayer6Key, kPlayer7Key, kPlayer8Key, kPlayer9Key, kPlayer10Key, kPlayer11Key, kPlayer12Key, nil];
    }
    
    if (data != nil) {
        NSArray *lines = [data componentsSeparatedByString:kLineEndCharacter];
        
        [self setTeamList:[NSMutableArray arrayWithCapacity:10]];
        
        int numberOfTeams = [[lines objectAtIndex:0] intValue];
        //DebugLog(@"import team - # teams: %i", numberOfTeams);
        // check in case no a SQBS file (no extension on Windows could allow any file to be read)
        if ((numberOfTeams <= 0) || (numberOfTeams > 100)) {
            // exceeded current allowed players on a team - put up warning
            NSString *firstLine = [lines objectAtIndex:0];
            if ([firstLine length] > 4) {
                firstLine = [NSString stringWithFormat:@"%@ ...", [firstLine substringToIndex:4]];
            }
            NSAlert *alert = [NSAlert alertWithMessageText:@"File contents suspect. May not be a team file." 
                                             defaultButton:nil 
                                           alternateButton:nil 
                                               otherButton:nil 
                                 informativeTextWithFormat:@"Team count read as \"%@\". Expected number [1 - 100].", firstLine];
            [alert runModal];
            alert = nil;
            data = nil;
            keys = nil;
            // abort loading
            return FALSE;
        }
        int lineIndex = 1;
        BOOL suppressAlert = FALSE;
        for (int teamNumber = 0; teamNumber < numberOfTeams; teamNumber++) {
            if (lineIndex > [lines count]) {
                data = nil;
                keys = nil;
                return loadSuccess;
            }
            int memberCount = [[lines objectAtIndex:lineIndex] intValue]; // includes team name
            if ((lineIndex + memberCount) > [lines count]) {
                data = nil;
                keys = nil;
                return loadSuccess;
            }
            lineIndex ++;
            
            if ((memberCount > maxRecordsPerTeam) && !suppressAlert) {
                // exceeded current allowed players on a team - put up warning
                NSAlert *alert = [NSAlert alertWithMessageText:@"Current max players per team exceeded." 
                                                 defaultButton:@"Continue" 
                                               alternateButton:@"Abort" 
                                                   otherButton:nil 
                                     informativeTextWithFormat:@"Team '%@'. Only first %i players imported.", [lines objectAtIndex:lineIndex], kMaxPlayersPerTeam];
                [alert setShowsSuppressionButton:TRUE];
                long alertResult = [alert runModal];
                suppressAlert = [[alert suppressionButton] state];
                if (alertResult == NSAlertAlternateReturn) {
                    // abort import
                    data = nil;
                    keys = nil;
                    return loadSuccess;
                }
            }
            
            NSRange teamRange = NSMakeRange(lineIndex, fminl(memberCount, maxRecordsPerTeam));
            NSRange keyRange = NSMakeRange(0, fminl(memberCount, maxRecordsPerTeam));
            NSMutableDictionary *aTeam = [NSMutableDictionary dictionaryWithObjects:[lines subarrayWithRange:teamRange] forKeys:[keys subarrayWithRange:keyRange]];
            // add index keys - used to update game team index if teams are sorted
            NSString *teamNumberAsString = [NSString stringWithFormat:@"%i", teamNumber];
            [aTeam setObject:teamNumberAsString forKey:kOriginalTeamIndexKey];
            [aTeam setObject:teamNumberAsString forKey:kSortedTeamIndexKey];
            [teamList addObject:aTeam];
            aTeam = nil;
            lineIndex = lineIndex + memberCount;
        }
        
        // reset game and packet info
        [self setGameList:nil];
        [self setGameList:[NSMutableArray arrayWithCapacity:10]];
        
        
        //DebugLog(@"loaded Tournament file - team count: %i", [teamList count]);
        
        loadSuccess = TRUE;
        [[NSNotificationCenter defaultCenter] postNotificationName:kTeamFileImportedNotification object:self];
    }
    
    keys = nil;
    data = nil;
    
    return loadSuccess;
}

- (void)dealloc {
    [self setTeamList:nil];
    [self setDivisionList:nil];
    [self setPacketNames:nil];
    [self setGameList:nil];
    [self setSortedGameList:nil];
    [self setIndividualStandings:nil];
    [self setTeamStandings:nil];
    [self setTeamStandingsCopy:nil];
    
    [self setTournamentName:nil];
    [self setTournamentFileName:nil];
    [self setReportsBaseName:nil];
    [self setRoundReportName:nil];
    [self setTeamStandingsReportName:nil];
    [self setTeamDetailsReportName:nil];
    [self setIndividualStandings:nil];
    [self setIndividualDetailsReportName:nil];
    [self setScoreboardReportName:nil];
    [self setStyleReportName:nil];
    [self setStatKeyReportName:nil];
    
    
    [super dealloc];
}

- (void)getMergeAlertDidEnd:(NSAlert *)alert returnCode: (int)code contextInfo: (void *)context {
    // clean-up only
    [self setOpenDocumentsForMergeOrPublish:nil];
}

- (void)getMergeDidEnd:(NSWindow *)mergePanel returnCode: (int)code contextInfo: (void *)context {
    [mergePanel close];
    if (code == NSAlertAlternateReturn) {
        // cancel
        [self setTemporaryWindowController:nil];
        [self setOpenDocumentsForMergeOrPublish:nil];
        return;
    }
    for (Tournament *mergingTournament in openDocumentsForMergeOrPublish) {
        // get selected tournament
        //Tournament *mergingTournament = [openDocumentsForMerge objectAtIndex:[mergeFileController selectedDocumentIndex]];
        
        // do merge
        BOOL proceedWithMerge = TRUE;  // set to FALSe if any pre-check fail
        NSMutableString *failReason = [NSMutableString stringWithString:@""];
        
        // check tournament options
        // question info
        if (question_0_selected) {
            if (![mergingTournament question_0_selected] || (question_0_value != [mergingTournament question_0_value])) {
                // question 0 different
                [failReason appendString:@"Question 0#"];
                proceedWithMerge = FALSE;
            }
        }
        if (question_1_selected) {
            if (![mergingTournament question_1_selected] || (question_1_value != [mergingTournament question_1_value])) {
                // question 1 different
                [failReason appendString:@"Question 1#"];
                proceedWithMerge = FALSE;
            }
        }
        if (question_2_selected) {
            if (![mergingTournament question_2_selected] || (question_2_value != [mergingTournament question_2_value])) {
                // question 2 different
                [failReason appendString:@"Question 2#"];
                proceedWithMerge = FALSE;
            }
        }
        if (question_3_selected) {
            if (![mergingTournament question_3_selected] || (question_3_value != [mergingTournament question_3_value])) {
                // question 3 different
                [failReason appendString:@"Question 3#"];
                proceedWithMerge = FALSE;
            }
        }
        
        // bonus conversion
        if (trackBonusSetting != [mergingTournament trackBonusSetting]) {
            [failReason appendString:@"Track Bonuses setting#"];
            proceedWithMerge = FALSE;
        } else {
            // if tracking, check that same setting
            if (trackBonusSetting) {
                if (autoTrackSetting != [mergingTournament autoTrackSetting]) {
                    [failReason appendString:@"Bonus Conversion setting#"];
                    proceedWithMerge = FALSE;
                }
            }
        }
        
        // TUH tracking
        if (trackTossUpsHeardSetting != [mergingTournament trackTossUpsHeardSetting]) {
            [failReason appendString:@"Track Toss Ups Heard setting#"];
            proceedWithMerge = FALSE;
        }
        
        // lightning round
        if (trackLightRoundSetting != [mergingTournament trackLightRoundSetting]) {
            [failReason appendString:@"Track Lightning Rounds setting#"];
            proceedWithMerge = FALSE;
        }
        
        // divisions ??
        // don't care about P/N tracking - only impacts reports
        
        // check that teams are same
        // need to check name, division and players individually due to sort key
        double maxTeamCount = fmax([teamList count], [[mergingTournament teamList] count]);
        // team count must be same if merging more that 1 file
        if (([teamList count] != [[mergingTournament teamList] count]) && ([openDocumentsForMergeOrPublish count] > 1)) {
            // teams not the same
            [failReason appendString:@"Team count for tournament must be the same when merging more than 1 tournament file."];
            proceedWithMerge = FALSE;
        }
        for (int teamIndex = 0; teamIndex < maxTeamCount; teamIndex++) {
            NSMutableDictionary *thisTeam = [NSMutableDictionary dictionaryWithDictionary:[teamList objectAtIndex:teamIndex]];
            NSMutableDictionary *mergeTeam = [NSMutableDictionary dictionaryWithDictionary:[[mergingTournament teamList] objectAtIndex:teamIndex]];
            // remove sort keys
            [thisTeam removeObjectForKey:kOriginalTeamIndexKey];
            [thisTeam removeObjectForKey:kSortedTeamIndexKey];
            [mergeTeam removeObjectForKey:kOriginalTeamIndexKey];
            [mergeTeam removeObjectForKey:kSortedTeamIndexKey];
            // compare
            if (![thisTeam isEqualToDictionary:mergeTeam]) {
                // teams not the same
                [failReason appendFormat:@"Team (%@) at index: %i#", [thisTeam objectForKey:kTeamNameKey], teamIndex];
                proceedWithMerge = FALSE;
            }
        }
        
        if (proceedWithMerge) {
            // check if teams need to be imported
            if ([teamList count] < [[mergingTournament teamList] count]) {
                // add extra teams
                for (long teamIndex = [teamList count]; teamIndex < [[mergingTournament teamList] count]; teamIndex++) {
                    [teamList addObject:[[mergingTournament teamList] objectAtIndex:teamIndex]];
                }
            }
            
            // import games
            for (Game *mergeGame in [mergingTournament gameList]) {
                [gameList addObject:mergeGame];
            }
            if ([mergingTournament minRoundsAssigned] < minRoundsAssigned) {
                [self setMinRoundsAssigned:[mergingTournament minRoundsAssigned]];
            }
            if ([mergingTournament maxRoundsAssigned] > maxRoundsAssigned) {
                [self setMaxRoundsAssigned:[mergingTournament maxRoundsAssigned]];
            }
            
            // import division list differences
            if (useDivisionsSetting) {
                for (NSString *mergeDivisionName in [mergingTournament divisionList]) {
                    if ([divisionList indexOfObject:mergeDivisionName] == NSNotFound) {
                        [divisionList addObject:mergeDivisionName];
                    }
                }
            }
            
            // import packet names
            // if base tournament packet name is "missing", over-write, otherwise leave
            for (double roundNumber = minRoundsAssigned; roundNumber <= maxRoundsAssigned; roundNumber++) {
                NSString *packetName = [packetNames objectForKey:[NSString stringWithFormat:kPacketRoundBaseKeyFormat, (long)roundNumber]];
                if ((packetName == nil) || [packetName isEqualToString:kPacketMissingPacketNameValue]) {
                    // okay to replace if there is an entry in merge file
                    NSString *mergePacketName = [[mergingTournament packetNames] objectForKey:[NSString stringWithFormat:kPacketRoundBaseKeyFormat, (long)roundNumber]];
                    if (mergePacketName != nil) {
                        // copy even if missing packet name as this might be round that doesn't exist in base tournament
                        [packetNames setObject:mergePacketName forKey:[NSString stringWithFormat:kPacketRoundBaseKeyFormat, (long)roundNumber]];
                    }
                }
            }
            
            
        } else {
            // put up alert and stop
            // clean-up fail reason
            // drop last eol indicator
            failReason = [NSMutableString stringWithFormat:@" - %@", [failReason substringToIndex:([failReason length] - 2)]];
            [failReason replaceOccurrencesOfString:@"#" withString:@"\n - " options:NSCaseInsensitiveSearch range:NSMakeRange(0, [failReason length])];
            NSAlert *failAlert = [NSAlert alertWithMessageText:[NSString stringWithFormat: @"The following differences exist between this tournament and merging tournament - %@.", mergingTournament]
                                                 defaultButton:nil
                                               alternateButton:nil
                                                   otherButton:nil
                                     informativeTextWithFormat:@"%@", failReason];
            [failAlert beginSheetModalForWindow:[viewSelectorSegmentedControl window] modalDelegate:self didEndSelector:@selector(getMergeAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
            failAlert = nil;
        }
    }
    
    [self setOpenDocumentsForMergeOrPublish:nil];
    [self setTemporaryWindowController:nil];
}

- (IBAction)mergeTournamentFileAction:(id)sender {
    // find other open tournaments
    NSArray *openDocuments = [[NSDocumentController sharedDocumentController] documents];
    
    MergeFileWindowController *mergeFileWindowController = [[MergeFileWindowController alloc] initWithWindowNibName:@"MergeFileWindow"];
    [mergeFileWindowController setBaseTournamentString:[NSString stringWithFormat:@"%@\n%@", tournamentName, [tournamentFileName lastPathComponent]]];
    NSMutableArray *docs = [NSMutableArray arrayWithCapacity:3];
    for (Tournament *thisTournament in openDocuments) {
        if (thisTournament != self) {
            [docs addObject:thisTournament];
        }
    }
    [mergeFileWindowController setDocumentsArray:docs];
    [self  setTemporaryWindowController:mergeFileWindowController];
    [self setOpenDocumentsForMergeOrPublish:docs];
    [mergeFileWindowController release];
    docs = nil;
    [NSApp beginSheet:[temporaryWindowController window] modalForWindow:[viewSelectorSegmentedControl window] modalDelegate:self didEndSelector:@selector(getMergeDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (IBAction)importTeamInfoAction:(id)sender {
    // any existing games will be deleted, warn
    if ((gameList != nil) && ([gameList count] > 0)) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Importing team info will erase existing games." 
                                         defaultButton:@"Continue" 
                                       alternateButton:@"Abort" 
                                           otherButton:nil 
                             informativeTextWithFormat:@""];
        long alertResult = [alert runModal];
        if (alertResult == NSAlertAlternateReturn) {
            // abort import
        }
    }
    // open file dialog
    NSOpenPanel *openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:TRUE];
    [openDlg setCanChooseDirectories:FALSE];
    
    // Display the dialog.  If the OK button was pressed,
    // process the files.
    if ([openDlg runModal] == NSFileHandlingPanelOKButton)
    {
        NSArray *files = [openDlg URLs];
        NSString *filename = [[files objectAtIndex:0] path];
        // process file.
        
        //DebugLog(@"importTeamInfoAction: %@", filename);
        if ([self importTeamFile:filename]) {
            [self setTournamentFileName:[[files objectAtIndex:0] path]];
            //[self setDisplayName:[tournamentFileName lastPathComponent]];
            //[self setUnsavedChangesMain:TRUE];
            [self updateChangeCount:NSChangeDone];
        }
    }
}

- (IBAction)gameSortOrderAction:(id)sender {
    //DebugLog(@"gameSortOrderAction selected: %@, index: %i", [(NSPopUpButton *)sender titleOfSelectedItem], [(NSPopUpButton *)sender indexOfSelectedItem]);
    if ((gameList != nil) && ([gameList count] > 1)) {
        // Game Entry might have unsaved game
        if (lastSelectedView == kGameEntryView) {
            if ([myCurrentViewController respondsToSelector:@selector(prepareForGameSort:)]) {
                [(GameEntryViewController *)myCurrentViewController prepareForGameSort];
            }
        }
        switch ([(NSPopUpButton *)sender indexOfSelectedItem]) {
            case kGameSortByGame: {
                [gameList sortUsingSelector:@selector(sortGameByGameID:)];
                break;
            }
            case kGameSortByRound: {
                [gameList sortUsingSelector:@selector(sortGameByRound:)];
                break;
            }
            case kGameSortByRoundThenGame: {
                [gameList sortUsingSelector:@selector(sortGameByRoundThenGame:)];
                break;
            }
                
            default:
                return;
                break;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kGamesSortedNotification object:nil];
        //[self setUnsavedChangesMain:TRUE];
        [self updateChangeCount:NSChangeDone];
    }
}

#pragma mark -
#pragma mark Toolbar

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem {
    //DebugLog(@"validateToolbarItem tag: %i, name: %@, %@", [theItem tag], [theItem label], theItem);
    switch ([theItem tag]) {
        case kFileMenuSaveTag: {
            return (tournamentFileName != nil);
            break;
        }
        case kFileMenuNewTag: {
            return TRUE;
            break;
        }
            // case kSortGamesToolbarTag: can't be done here because it is view based.
        case kReportsMenuCreateWebTag: {
            BOOL enableSetting = ((gameList != nil) && ([gameList count] > 0));
            
            return enableSetting;
            break;
        }
        case kImportTeamsToolbarTag: {
            // only enable if teams don't exist
            return ((lastSelectedView == kTournamentOptionsView) && ((teamList != nil) && ([teamList count] == 0)));
            break;
        }
            
        default:
            break;
    }
    return TRUE;
}

#pragma mark -
#pragma mark View Management

//- (void)changeViewController:(NSInteger)whichViewTag
//{
//	//DebugLog(@"changeViewController whichView: %i, currentController: %@", whichViewTag, myCurrentViewController);
//	if (myCurrentViewController != nil) {
//        //DebugLog(@"changeViewController - current: %@, delegate: %@", myCurrentViewController, [(TournamentViewController *)myCurrentViewController documentDelegate]);
//        if (lastSelectedView == whichViewTag) {
//            // changing to same view controller - can happen on New -> Open
//            // just to be sure!
//            [(TournamentViewController *)myCurrentViewController setDocumentDelegate:self];
//            return;
//        }
//        [(TournamentViewController *)myCurrentViewController  handleViewControllerClosing];
//		[[myCurrentViewController view] removeFromSuperview];	// remove the current view
//        [self setMyCurrentViewController:nil];
//    }
//    
//	
//	switch (whichViewTag)
//	{
//		case kTournamentOptionsView:
//		{
//			TournamentSetupViewController *viewController = [[TournamentSetupViewController alloc] initWithNibName:NSStringFromClass([TournamentSetupViewController class]) bundle:nil];
//			if (viewController != nil)
//			{
//				//myCurrentViewController = viewController;	// keep track of the current view controller
//                [self setMyCurrentViewController:viewController];
//			}
//            
//			break;
//		}
//            
//		case kGameEntryView:
//		{
//			GameEntryViewController *viewController = [[GameEntryViewController alloc] initWithNibName:NSStringFromClass([GameEntryViewController class]) bundle:nil];
//			if (viewController != nil)
//			{
//				//myCurrentViewController = viewController;	// keep track of the current view controller
//                [self setMyCurrentViewController:viewController];
//			}
//			
//			break;
//		}
//            
//		case kReportsView:
//		{
//			ReportsViewController *viewController = [[ReportsViewController alloc] initWithNibName:NSStringFromClass([ReportsViewController class]) bundle:nil];
//			if (viewController != nil)
//			{
//				//myCurrentViewController = viewController;	// keep track of the current view controller
//                [self setMyCurrentViewController:viewController];
//			}
//			
//			break;
//		}
//            
//		case kSettingsView:
//		{
//			SettingsViewController *viewController = [[SettingsViewController alloc] initWithNibName:NSStringFromClass([SettingsViewController class]) bundle:nil];
//			if (viewController != nil)
//			{
//				//myCurrentViewController = viewController;	// keep track of the current view controller
//                [self setMyCurrentViewController:viewController];
//			}
//			
//			break;
//		}
//	}
//    
//    if (myCurrentViewController != nil) {
//        // embed the current view to our host view
//        [(TournamentViewController *)myCurrentViewController setDocumentDelegate:self];
//        [(TournamentViewController *)myCurrentViewController viewWillAppear];
//        [myTargetView addSubview: [myCurrentViewController view]];
//        
//        // make sure we automatically resize the controller's view to the current window size
//        [[myCurrentViewController view] setFrame: [myTargetView bounds]];
//        
//        //DebugLog(@"changeViewController - done viewController: %@, delegate: %@", myCurrentViewController, [(TournamentViewController *)myCurrentViewController documentDelegate]);
//    }
//	
//}

- (IBAction)viewSelectorChangeAction:(id)sender
{
    long currentView = [(NSSegmentedControl *)sender selectedSegment];
	if (myCurrentViewController != nil) {
        //DebugLog(@"viewSelectorChangeAction - current: %@, delegate: %@", myCurrentViewController, [(TournamentViewController *)myCurrentViewController documentDelegate]);
        if (lastSelectedView == currentView) {
            // changing to same view controller - can happen on New -> Open
            // just to be sure!
            [(TournamentViewController *)myCurrentViewController setDocumentDelegate:self];
            return;
        }
        [(TournamentViewController *)myCurrentViewController  handleViewControllerClosing];
		[[myCurrentViewController view] removeFromSuperview];	// remove the current view
        [self setMyCurrentViewController:nil];
    }
    
	switch (currentView)
	{
		case kTournamentOptionsView:
		{
			TournamentSetupViewController *viewController = [[TournamentSetupViewController alloc] initWithNibName:NSStringFromClass([TournamentSetupViewController class]) bundle:nil];
            // keep track of the current view controller
            [self setMyCurrentViewController:viewController];
            [viewController release];
			break;
		}
            
		case kGameEntryView:
		{
			GameEntryViewController *viewController = [[GameEntryViewController alloc] initWithNibName:NSStringFromClass([GameEntryViewController class]) bundle:nil];
			// keep track of the current view controller
            [self setMyCurrentViewController:viewController];
            [viewController release];
			break;
		}
            
		case kReportsView:
		{
			ReportsViewController *viewController = [[ReportsViewController alloc] initWithNibName:NSStringFromClass([ReportsViewController class]) bundle:nil];
			// keep track of the current view controller
            [self setMyCurrentViewController:viewController];
            [viewController release];
			break;
		}
            
		case kSettingsView:
		{
			SettingsViewController *viewController = [[SettingsViewController alloc] initWithNibName:NSStringFromClass([SettingsViewController class]) bundle:nil];
			// keep track of the current view controller
            [self setMyCurrentViewController:viewController];
            [viewController release];
			break;
		}
	}
    
    if (myCurrentViewController != nil) {
        // embed the current view to our host view
        [(TournamentViewController *)myCurrentViewController setDocumentDelegate:self];
        [(TournamentViewController *)myCurrentViewController viewWillAppear];
        [myTargetView addSubview: [myCurrentViewController view]];
        
        // make sure we automatically resize the controller's view to the current window size
        [[myCurrentViewController view] setFrame: [myTargetView bounds]];
        
        //DebugLog(@"viewSelectorChangeAction - done viewController: %@, delegate: %@", myCurrentViewController, [(TournamentViewController *)myCurrentViewController documentDelegate]);
    }
    
    [self setLastSelectedView:currentView];
}

#pragma mark -
#pragma mark Team index adjustment

- (void)adjustTeamIndexesInGames {
    if (!((gameList != nil) && ([gameList count] > 0))) {
        return;
    }
    // create mapping dictionary of original index to sorted index
    NSMutableDictionary *map = [NSMutableDictionary dictionaryWithCapacity:10];
    for (NSMutableDictionary *aTeam in teamList) {
        [map setObject:[aTeam objectForKey:kSortedTeamIndexKey] forKey:[aTeam objectForKey:kOriginalTeamIndexKey]];
    }
    // update team index in game list
    for (int gID = 0; gID < [gameList count]; gID++) {
        Game *theGame = [gameList objectAtIndex:gID];
        NSString *indexKey;
        if ([theGame team_A_index] >= 0) {
            indexKey = [NSString stringWithFormat:@"%li", [theGame team_A_index]];
            [theGame setTeam_A_index:[(NSString *)[map objectForKey:indexKey] intValue]];
        }
        if ([theGame team_B_index] >= 0) {
            indexKey = [NSString stringWithFormat:@"%li", [theGame team_B_index]];
            [theGame setTeam_B_index:[(NSString *)[map objectForKey:indexKey] intValue]];
        }
        [gameList replaceObjectAtIndex:gID withObject:theGame];
    }
    //unsavedChangesMain = TRUE;
    [self updateChangeCount:NSChangeDone];
}

#pragma mark -
#pragma mark Report actions and methods

NSInteger individualsSort_TUH(Individuals *individual1, Individuals *individual2, void *context); // context is question values as string separated by "/"
NSInteger individualsSort_TUH(Individuals *individual1, Individuals *individual2, void *context) {
    float ppt1, ppt2;
    // sort based on toss ups standings
    if ([individual1 tossUpsHeard] == 0) {
        ppt1 = 0;
    } else {
        ppt1 = (float)[individual1 points] / (float)[individual1 tossUpsHeard];
    }
    if ([individual2 tossUpsHeard] == 0) {
        ppt2 = 0;
    } else {
        ppt2 = (float)[individual2 points] / (float)[individual2 tossUpsHeard];
    }
    if (fabs(ppt1 - ppt2) < 0.00001) {
        NSArray *q = [(NSString *)context componentsSeparatedByString:@"/"];
        if (([[q objectAtIndex:0] intValue] > 0) && ([individual1 q0] != [individual2 q0])) {
            return ([individual1 q0] > [individual2 q0])? NSOrderedAscending : NSOrderedDescending;
        }
        if (([[q objectAtIndex:1] intValue] > 0) && ([individual1 q1] != [individual2 q1])) {
            return ([individual1 q1] > [individual2 q1])? NSOrderedAscending : NSOrderedDescending;
        }
        if (([[q objectAtIndex:2] intValue] > 0) && ([individual1 q2] != [individual2 q2])) {
            return ([individual1 q0] > [individual2 q0])? NSOrderedAscending : NSOrderedDescending;
        }
        if (([[q objectAtIndex:3] intValue] > 0) && ([individual1 q3] != [individual2 q3])) {
            return ([individual1 q3] > [individual2 q3])? NSOrderedAscending : NSOrderedDescending;
        }
    }
    return (ppt1 > ppt2)? NSOrderedAscending : NSOrderedDescending;
}

NSInteger individualsSort(Individuals *individual1, Individuals *individual2, void *context); // context is question values as string separated by "/"
NSInteger individualsSort(Individuals *individual1, Individuals *individual2, void *context) {
    float ppg1, ppg2;
    // sort based on record
    if ([individual1 gamesPlayed] == 0) {
        ppg1 = 0;
    } else {
        ppg1 = ((float)[individual1 points] / (float)[individual1 gamesPlayed]);
    }
    if ([individual2 gamesPlayed] == 0) {
        ppg2 = 0;
    } else {
        ppg2 = ((float)[individual2 points] / (float)[individual2 gamesPlayed]);
    }
    if (fabs(ppg1 - ppg2) < 0.00001) {
        NSArray *q = [(NSString *)context componentsSeparatedByString:@"/"];
        if (([[q objectAtIndex:0] intValue] > 0) && ([individual1 q0] != [individual2 q0])) {
            return ([individual1 q0] > [individual2 q0])? NSOrderedAscending : NSOrderedAscending;
        }
        if (([[q objectAtIndex:1] intValue] > 0) && ([individual1 q1] != [individual2 q1])) {
            return ([individual1 q1] > [individual2 q1])? NSOrderedAscending : NSOrderedDescending;
        }
        if (([[q objectAtIndex:2] intValue] > 0) && ([individual1 q2] != [individual2 q2])) {
            return ([individual1 q0] > [individual2 q0])? NSOrderedAscending : NSOrderedDescending;
        }
        if (([[q objectAtIndex:3] intValue] > 0) && ([individual1 q3] != [individual2 q3])) {
            return ([individual1 q3] > [individual2 q3])? NSOrderedAscending : NSOrderedDescending;
        }
    }
    return (ppg1 > ppg2)? NSOrderedAscending : NSOrderedDescending;
}

NSInteger standingsSort(Standing *standing1, Standing *standing2, void *context); // context is self (TournamentWindowController)
NSInteger standingsSort(Standing *standing1, Standing *standing2, void *context) {
    if (fabs([standing1 pct] - [standing2 pct]) < 0.00001) {
        Tournament *me = context;
        // ---------------------------------------
        if (([me sortMethodSetting] == kSort_RHP) || ([me sortMethodSetting] == kSort_RHT)) {
            long s1Win = 0; long s1Loss = 0; long s1Tie = 0;
            long s2Win = 0; long s2Loss = 0; long s2Tie = 0;
            for (Game *thisGame in [me sortedGameList]) {
                if ([thisGame team_A_index] == [standing1 teamIndex]) {
                    for (Standing *thisTeamStanding in [me teamStandingsCopy]) {
                        if ([thisGame team_B_index] == [thisTeamStanding teamIndex]) {
                            if (fabs([standing1 pct] - [thisTeamStanding pct]) < 0.00001) {
                                if ([thisGame forfeit]) {
                                    s1Win++;
                                }
                                long scoreA = [[thisGame team_A_score] intValue];
                                long scoreB = [[thisGame team_B_score] intValue];
                                if (scoreA > scoreB) {
                                    s1Win++;
                                } else {
                                    if (scoreA < scoreB) {
                                        s1Loss++;
                                    } else {
                                        s1Tie++;
                                    }
                                }
                            }
                        }
                    }
                }
                if ([thisGame team_B_index] == [standing1 teamIndex]) {
                    for (Standing *thisTeamStanding in [me teamStandingsCopy]) {
                        if ([thisGame team_A_index] == [thisTeamStanding teamIndex]) {
                            if (fabs([standing1 pct] - [thisTeamStanding pct]) < 0.00001) {
                                if ([thisGame forfeit]) {
                                    s1Loss++;
                                }
                                long scoreA = [[thisGame team_A_score] intValue];
                                long scoreB = [[thisGame team_B_score] intValue];
                                if (scoreA > scoreB) {
                                    s1Loss++;
                                } else {
                                    if (scoreA < scoreB) {
                                        s1Win++;
                                    } else {
                                        s1Tie++;
                                    }
                                }
                            }
                        }
                    }
                }
                if ([thisGame team_A_index] == [standing2 teamIndex]) {
                    for (Standing *thisTeamStanding in [me teamStandingsCopy]) {
                        if ([thisGame team_B_index] == [thisTeamStanding teamIndex]) {
                            if (fabs([standing2 pct] - [thisTeamStanding pct]) < 0.00001) {
                                if ([thisGame forfeit]) {
                                    s2Win++;
                                }
                                long scoreA = [[thisGame team_A_score] intValue];
                                long scoreB = [[thisGame team_B_score] intValue];
                                if (scoreA > scoreB) {
                                    s2Win++;
                                } else {
                                    if (scoreA < scoreB) {
                                        s2Loss++;
                                    } else {
                                        s2Tie++;
                                    }
                                }
                            }
                        }
                    }
                }
                if ([thisGame team_B_index] == [standing2 teamIndex]) {
                    for (Standing *thisTeamStanding in [me teamStandingsCopy]) {
                        if ([thisGame team_A_index] == [thisTeamStanding teamIndex]) {
                            if (fabs([standing2 pct] - [thisTeamStanding pct]) < 0.00001) {
                                if ([thisGame forfeit]) {
                                    s2Loss++;
                                }
                                long scoreA = [[thisGame team_A_score] intValue];
                                long scoreB = [[thisGame team_B_score] intValue];
                                if (scoreA > scoreB) {
                                    s2Loss++;
                                } else {
                                    if (scoreA < scoreB) {
                                        s2Win++;
                                    } else {
                                        s2Tie++;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            double pct1, pct2;
            long gp1 = s1Win + s1Loss + s1Tie;
            if (gp1 == 0) {
                pct1 = 0;
            } else {
                pct1 = (s1Win + (0.5 * s1Tie)) / gp1;
            }
            long gp2 = s2Win + s2Loss + s2Tie;
            if (gp2 == 0) {
                pct2 = 0;
            } else {
                pct2 = (s2Win + (0.5 * s2Tie)) / gp2;
            }
            if (fabs(pct1 - pct2) < 0.00001) {
                return (pct1 > pct2)? NSOrderedAscending : NSOrderedDescending;
            }
        }
        // ---------------------------------------
        if ([me sortMethodSetting] == kSort_RS) {
            float sspg1 = safeDivide((float)[standing1 strengthStanding], (float)([standing1 win] + [standing1 loss] + [standing1 tie]));
            float sspg2 = safeDivide((float)[standing2 strengthStanding], (float)([standing2 win] + [standing2 loss] + [standing2 tie]));
            return (sspg1 > sspg2)? NSOrderedAscending : NSOrderedDescending;
        }
        // ---------------------------------------
        if (([me sortMethodSetting] == kSort_RT) || ([me sortMethodSetting] == kSort_RHT)){
            float ppth1, ppth2;
            if ([standing1 tossUpsHeard] == 0) {
                ppth1 = 0;
            } else {
                ppth1 = (float)[standing1 pointsFor] / (float)[standing1 tossUpsHeard];
            }
            if ([standing2 tossUpsHeard] == 0) {
                ppth2 = 0;
            } else {
                ppth2 = (float)[standing2 pointsFor] / (float)[standing2 tossUpsHeard];
            }
            return (ppth1 > ppth2)? NSOrderedAscending : NSOrderedDescending;
        }
        // ---------------------------------------
        return ([standing1 ptsPerGame] > [standing2 ptsPerGame])? NSOrderedAscending : NSOrderedDescending;
        
    }
    
    return ([standing1 pct] > [standing2 pct])? NSOrderedAscending : NSOrderedDescending;
}

- (void)teamTotals {
    [self setTeamStandings:nil];
    NSMutableArray *teamNames = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray *exhibitionTeams = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray *tempTeamStandings = [NSMutableArray arrayWithCapacity:10];
    for (NSDictionary *aTeamEntry in teamList) {
        [teamNames addObject:[aTeamEntry objectForKey:kTeamNameKey]];
        if ([aTeamEntry objectForKey:kExhibitionTeamKey] != nil) {
            [exhibitionTeams addObject:@"+"];
        } else {
            [exhibitionTeams addObject:@"-"];
        }
    }
    for (int tIndex = 0; tIndex < [teamList count]; tIndex++) {
        Standing *aTeam = [[Standing alloc] init];
        [aTeam setTeamName:[teamNames objectAtIndex:tIndex]];
        [aTeam setTeamIndex:tIndex];
        for (int gIndex = 0; gIndex < [gameList count]; gIndex++) {
            Game *thisGame = (Game *)[gameList objectAtIndex:gIndex];
            if (allRoundsIncludedInReport || (([thisGame round] >= minRoundIncludedInReport) && ([thisGame round] <= maxRoundIncludedInReport))) {
                if (([thisGame team_A_index] == tIndex) && ([thisGame team_B_index] >= 0)
                    && ([[exhibitionTeams objectAtIndex:[thisGame team_B_index]] isEqualToString:@"-"])) {
                    // interested in this game
                    if ([thisGame forfeit]) {
                        [aTeam setForfeitWin:([aTeam forfeitWin] + 1)];
                    } else {
                        long aScore = [[thisGame team_A_score] intValue];
                        long bScore = [[thisGame team_B_score] intValue];
                        if ((aScore != -1) && (bScore != -1)) {
                            if (aScore > bScore) {
                                [aTeam setWin:([aTeam win] + 1)];
                            } else {
                                if (bScore > aScore) {
                                    [aTeam setLoss:([aTeam loss] + 1)];
                                } else {
                                    [aTeam setTie:([aTeam tie] + 1)];
                                }
                            }
                        }
                        [aTeam setPointsFor:([aTeam pointsFor] + aScore)];
                        [aTeam setPointsAgainst:([aTeam pointsAgainst] + bScore)];
                        [aTeam setTossUpsHeard:([aTeam tossUpsHeard] + [thisGame tossUpsHeard])];
                        [aTeam setLightning:([aTeam lightning] + [thisGame team_A_LighteningPoints])];
                        [aTeam setBonusHeard:([aTeam bonusHeard] + [thisGame team_A_BonusHeard])];
                        [aTeam setBonusPoints:([aTeam bonusPoints] + [thisGame team_A_BonusPoints])];
                        [aTeam setBouncebacksHeard:([aTeam bouncebacksHeard] + [thisGame team_A_BounceBacksHeard])];
                        [aTeam setBouncebacksPoints:([aTeam bouncebacksPoints] + [thisGame team_A_BounceBacksPoints])];
                        NSString *qTotals = [thisGame getTeamAQuestionPoints];
                        if (qTotals != nil) {
                            NSArray *q = [qTotals componentsSeparatedByString:@"/"];
                            [aTeam setQ0:([aTeam q0] + [[q objectAtIndex:0] intValue])];
                            [aTeam setQ1:([aTeam q1] + [[q objectAtIndex:1] intValue])];
                            [aTeam setQ2:([aTeam q2] + [[q objectAtIndex:2] intValue])];
                            [aTeam setQ3:([aTeam q3] + [[q objectAtIndex:3] intValue])];
                        }
                    }
                }
            }
            if (([thisGame team_B_index] == tIndex) && ([thisGame team_A_index] >= 0)
                && ([[exhibitionTeams objectAtIndex:[thisGame team_A_index]] isEqualToString:@"-"])) {
                // interested in this game
                if ([thisGame forfeit]) {
                    [aTeam setForfeitLoss:([aTeam forfeitLoss] + 1)];
                } else {
                    long aScore = [[thisGame team_A_score] intValue];
                    long bScore = [[thisGame team_B_score] intValue];
                    if ((aScore != -1) && (bScore != -1)) {
                        if (bScore > aScore) {
                            [aTeam setWin:([aTeam win] + 1)];
                        } else {
                            if (aScore > bScore) {
                                [aTeam setLoss:([aTeam loss] + 1)];
                            } else {
                                [aTeam setTie:([aTeam tie] + 1)];
                            }
                        }
                    }
                    [aTeam setPointsFor:([aTeam pointsFor] + bScore)];
                    [aTeam setPointsAgainst:([aTeam pointsAgainst] + aScore)];
                    [aTeam setTossUpsHeard:([aTeam tossUpsHeard] + [thisGame tossUpsHeard])];
                    [aTeam setLightning:([aTeam lightning] + [thisGame team_B_LighteningPoints])];
                    [aTeam setBonusHeard:([aTeam bonusHeard] + [thisGame team_B_BonusHeard])];
                    [aTeam setBonusPoints:([aTeam bonusPoints] + [thisGame team_B_BonusPoints])];
                    [aTeam setBouncebacksHeard:([aTeam bouncebacksHeard] + [thisGame team_B_BounceBacksHeard])];
                    [aTeam setBouncebacksPoints:([aTeam bouncebacksPoints] + [thisGame team_B_BounceBacksPoints])];
                    NSString *qTotals = [thisGame getTeamBQuestionPoints];
                    if (qTotals != nil) {
                        NSArray *q = [qTotals componentsSeparatedByString:@"/"];
                        [aTeam setQ0:([aTeam q0] + [[q objectAtIndex:0] intValue])];
                        [aTeam setQ1:([aTeam q1] + [[q objectAtIndex:1] intValue])];
                        [aTeam setQ2:([aTeam q2] + [[q objectAtIndex:2] intValue])];
                        [aTeam setQ3:([aTeam q3] + [[q objectAtIndex:3] intValue])];
                    }
                }
            }
        }
        [aTeam setPosition:tIndex];
        [aTeam setGamesPlayed:([aTeam win] + [aTeam loss] + [aTeam tie] + [aTeam forfeitWin] + [aTeam forfeitLoss])];
        if ([aTeam gamesPlayed] == 0) {
            [aTeam setPct:0];
            [aTeam setPtsPerGame:0];
        } else {
            [aTeam setPct:((float)([aTeam win] + [aTeam forfeitWin] + 0.5 * [aTeam tie])/(float)([aTeam gamesPlayed]))];
            long winLossTie = [aTeam win] + [aTeam loss] + [aTeam tie];
            if (winLossTie == 0) {
                [aTeam setPtsPerGame:0];
            } else {
                [aTeam setPtsPerGame:(((float)[aTeam pointsFor])/((float)winLossTie))];
            }
        }
        [tempTeamStandings addObject:aTeam];
        [aTeam release];
    }
    [self setTeamStandings:tempTeamStandings];
    tempTeamStandings = nil;
    
    for (int tIndex = 0; tIndex < [teamStandings count]; tIndex++) {
        Standing *theTeam = [teamStandings objectAtIndex:tIndex];
        [theTeam setStrengthStanding:safeDivide((float)[theTeam pointsFor], (float)([theTeam win] + [theTeam loss] + [theTeam tie]))];
        //DebugLog(@"start - %@", theTeam);
        
        for (int gIndex = 0; gIndex < [gameList count]; gIndex++) {
            Game *thisGame = (Game *)[gameList objectAtIndex:gIndex];
            if (allRoundsIncludedInReport || (([thisGame round] >= minRoundIncludedInReport) && ([thisGame round] <= maxRoundIncludedInReport))) {
                if (([thisGame team_A_index] == tIndex) && ([thisGame team_B_index] >= 0)
                    && ([[exhibitionTeams objectAtIndex:[thisGame team_B_index]] isEqualToString:@"-"])) {
                    // interested in this game
                    if (![thisGame forfeit]) {
                        if (([[thisGame team_A_score] intValue] != -1) && ([[thisGame team_B_score] intValue] != -1)) {
                            Standing *theBTeam = [teamStandings objectAtIndex:[thisGame team_B_index]];
                            [theTeam setStrengthStanding:([theTeam strengthStanding] + safeDivide((float)[theBTeam pointsFor], (float)([theBTeam win] + [theBTeam loss] + [theBTeam tie])))];
                        }
                    }
                }
                if (([thisGame team_B_index] == tIndex) && ([thisGame team_A_index] >= 0)
                    && ([[exhibitionTeams objectAtIndex:[thisGame team_A_index]] isEqualToString:@"-"])) {
                    // interested in this game
                    if (![thisGame forfeit]) {
                        if (([[thisGame team_A_score] intValue] != -1) && ([[thisGame team_B_score] intValue] != -1)) {
                            Standing *theATeam = [teamStandings objectAtIndex:[thisGame team_A_index]];
                            [theTeam setStrengthStanding:([theTeam strengthStanding] + safeDivide((float)[theATeam pointsFor], (float)([theATeam win] + [theATeam loss] + [theATeam tie])))];
                        }
                    }
                }
            }
        }
        //DebugLog(@"end - %@", theTeam);
    }
    exhibitionTeams = nil;
    teamNames = nil;
}

- (void)individualTotals {
    [self setIndividualStandings:nil];
    NSMutableArray *tempIndStandings = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray *exhibitionTeams = [NSMutableArray arrayWithCapacity:10];
    for (NSDictionary *aTeamEntry in teamList) {
        if ([aTeamEntry objectForKey:kExhibitionTeamKey] != nil) {
            [exhibitionTeams addObject:@"+"];
        } else {
            [exhibitionTeams addObject:@"-"];
        }
    }
    for (int tIndex = 0; tIndex < [teamList count]; tIndex++) {
        NSDictionary *thisTeam = [teamList objectAtIndex:tIndex];
        NSString *teamName = [thisTeam objectForKey:kTeamNameKey];
        for (int pIndex = 0; pIndex < kMaxPlayersPerTeam; pIndex++) {
            NSString *playerName = [thisTeam objectForKey:[NSString stringWithFormat:kPlayerBaseKeyFormat, (pIndex + 1)]];
            if (playerName != nil) {
                Individuals *thePlayer = [[Individuals alloc] init];
                [thePlayer setTeamName:teamName];
                [thePlayer setPlayerName:playerName];
                for (int gIndex = 0; gIndex < [gameList count]; gIndex++) {
                    Game *thisGame = (Game *)[gameList objectAtIndex:gIndex];
                    if (allRoundsIncludedInReport || (([thisGame round] >= minRoundIncludedInReport) && ([thisGame round] <= maxRoundIncludedInReport))) {
                        if (![thisGame forfeit] && (([[thisGame team_A_score] intValue] != -1) && ([[thisGame team_B_score] intValue] != -1))) {
                            if (([thisGame team_A_index] == tIndex) && ([thisGame team_B_index] >= 0)
                                && ([[exhibitionTeams objectAtIndex:[thisGame team_B_index]] isEqualToString:@"-"])) {
                                NSArray *results = [[thisGame getTeamAResultsForPlayerWithNumber:pIndex] componentsSeparatedByString:@"/"];
                                //NSString *ret = [thisGame getTeamAResultsForPlayerWithIndex:pIndex];
                                //DebugLog(@"A %@ / %@ - %@", teamName, playerName, ret);
                                //NSArray *results = [ret componentsSeparatedByString:@"/"];
                                float gp = [[results objectAtIndex:0] floatValue];
                                if (gp > 0) {
                                    [thePlayer setPoints:([thePlayer points] + [[results objectAtIndex:5] intValue])];
                                    [thePlayer setQ0:([thePlayer q0] + [[results objectAtIndex:1] intValue])];
                                    [thePlayer setQ1:([thePlayer q1] + [[results objectAtIndex:2] intValue])];
                                    [thePlayer setQ2:([thePlayer q2] + [[results objectAtIndex:3] intValue])];
                                    [thePlayer setQ3:([thePlayer q3] + [[results objectAtIndex:4] intValue])];
                                    [thePlayer setGamesPlayed:([thePlayer gamesPlayed] + gp)];
                                    [thePlayer setTossUpsHeard:([thePlayer tossUpsHeard] + (long)(gp * (float)[thisGame tossUpsHeard] + 0.5))];
                                }
                            }
                            if (([thisGame team_B_index] == tIndex) && ([thisGame team_A_index] >= 0)
                                && ([[exhibitionTeams objectAtIndex:[thisGame team_A_index]] isEqualToString:@"-"])) {
                                NSArray *results = [[thisGame getTeamBResultsForPlayerWithNumber:pIndex] componentsSeparatedByString:@"/"];
                                //NSString *ret = [thisGame getTeamBResultsForPlayerWithIndex:pIndex];
                                //DebugLog(@"B %@ / %@ - %@", teamName, playerName, ret);
                                //NSArray *results = [ret componentsSeparatedByString:@"/"];
                                float gp = [[results objectAtIndex:0] floatValue];
                                if (gp > 0) {
                                    [thePlayer setPoints:([thePlayer points] + [[results objectAtIndex:5] intValue])];
                                    [thePlayer setQ0:([thePlayer q0] + [[results objectAtIndex:1] intValue])];
                                    [thePlayer setQ1:([thePlayer q1] + [[results objectAtIndex:2] intValue])];
                                    [thePlayer setQ2:([thePlayer q2] + [[results objectAtIndex:3] intValue])];
                                    [thePlayer setQ3:([thePlayer q3] + [[results objectAtIndex:4] intValue])];
                                    [thePlayer setGamesPlayed:([thePlayer gamesPlayed] + gp)];
                                    [thePlayer setTossUpsHeard:([thePlayer tossUpsHeard] + (long)(gp * (float)[thisGame tossUpsHeard] + 0.5))];
                                }
                            }
                        }
                    }
                }
                [thePlayer setPosition:(pIndex + 1)];
                [thePlayer setTeamIndex:tIndex];
                
                [tempIndStandings addObject:thePlayer];
                //DebugLog(@"final - %@", thePlayer);
                [thePlayer release];
            }
        }
    }
    [self setIndividualStandings:tempIndStandings];
    tempIndStandings = nil;
    exhibitionTeams = nil;
}

- (NSString *)createReportPrefixWithTitle:(NSString *)title {
    NSMutableString *contentString = [NSMutableString stringWithFormat:@"<HTML>\n<HEAD>\n<TITLE>"];
    [contentString appendString:title];
    [contentString appendString:@"</TITLE>\n"];
    if (styleReportSetting) {
        [contentString appendFormat:@"<LINK REL=stylesheet TYPE=\"text/css\" HREF=%@_style.css>", baseName];
    }
    [contentString appendString:@"\n</HEAD>\n<BODY>\n<table border=0 width=100%>\n<tr>\n<meta http-equiv=\"Content-Type\" content=\"text/html;charset=ISO-8859-1\" />"];
    
    if (teamStandingsReportSetting) {
        [contentString appendFormat:@"  <td><A HREF=%@%@>Standings</A></td>\n", baseName, teamStandingsReportName];
    } 
    if (individualStandingsReportSetting) {
        [contentString appendFormat:@"  <td><A HREF=%@%@>Individuals</A></td>\n", baseName, individualStandingsReportName];
    } 
    if (scoreboardReportSetting) {
        [contentString appendFormat:@"  <td><A HREF=%@%@>Scoreboard</A></td>\n", baseName, scoreboardReportName];
    } 
    if (teamDetailsReportSetting) {
        [contentString appendFormat:@"  <td><A HREF=%@%@>Team Detail</A></td>\n", baseName, teamDetailsReportName];
    } 
    if (individualDetailsReportSetting) {
        [contentString appendFormat:@"  <td><A HREF=%@%@>Individual Detail</A></td>\n", baseName, individualDetailsReportName];
    } 
    if (roundReportSetting) {
        [contentString appendFormat:@"  <td><A HREF=%@%@>Round Report</A></td>\n", baseName, roundReportName];
    } 
    if (statKeyReportSetting) {
        [contentString appendFormat:@"  <td><A HREF=%@%@>Stat Key</A></td>\n", baseName, statKeyReportName];
    }
    [contentString appendFormat:@"</tr>\n</table>\n<H1>%@</H1><P>\n", title];
    
    //DebugLog(@"createReportPrefixWithTitle - title: %@, content: %@", title, contentString);
    
    return contentString;
}

- (NSString *)createReportSuffix {
    return @"</BODY>\n</HTML>\n";
}

- (void)roundReportCreate {
    NSString *fileName = [NSString stringWithFormat:@"%@%@", reportsBaseName, roundReportName];
    //DebugLog(@"roundReportCreate - name: %@", fileName);
    [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
    //DebugLog(@"file attributes: %@", [[NSFileManager defaultManager] attributesOfItemAtPath:fileName error:nil]);
    NSFileHandle *outfile = [NSFileHandle fileHandleForWritingAtPath:fileName];
    if (outfile == nil) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"File Error. Report not generated." 
                                         defaultButton:nil 
                                       alternateButton:nil 
                                           otherButton:nil 
                             informativeTextWithFormat:@"file name: %@", fileName];
        [alert runModal];
        return;
    }
    [outfile writeData:[[self createReportPrefixWithTitle:[NSString stringWithFormat:@"%@ Round Report ", tournamentName]] dataUsingEncoding: NSISOLatin1StringEncoding]];
    
    NSMutableString *content = [NSMutableString stringWithString:@""];
    //    BOOL allRoundsValid = TRUE;
    //    long thisRoundNumber;
    //    long maxRoundNumber = 0;
    //    long minRoundNumber = 999999;
    //    for (Game *thisGame in gameList) {
    //        thisRoundNumber = [thisGame round];
    //        if (thisRoundNumber < 0) {
    //            allRoundsValid = FALSE;
    //            break;
    //        }
    //        maxRoundNumber = fmax(thisRoundNumber, maxRoundNumber);
    //        minRoundNumber = fmin(thisRoundNumber, minRoundNumber);
    //    }
    
    //DebugLog(@"rounds - min: %i, max: %i", minRoundNumber, maxRoundNumber);
    
    //    if (allRoundsValid) {
    NSMutableArray *rounds = [NSMutableArray arrayWithCapacity:10];
    for (double r = minRoundsAssigned; r <= maxRoundsAssigned; r++) {
        RoundData *aRound = [[RoundData alloc] init];
        [rounds addObject:aRound];
        [aRound release];
    }
    for (Game *thisGame in sortedGameList) {
        if (![thisGame forfeit] && ([thisGame team_A_index] >= 0) && ([thisGame team_B_index] >= 0)) {
            RoundData *thisRound = [rounds objectAtIndex:(int)([thisGame round] - minRoundsAssigned)];
            [thisRound setPoints:([thisRound points] + [[thisGame team_A_score] intValue] + [[thisGame team_B_score] intValue])];
            [thisRound setGamesPlayed:([thisRound gamesPlayed] + 2)];
            [thisRound setTossUpsHeard:([thisRound tossUpsHeard] + [thisGame tossUpsHeard])];
            [thisRound setLightning:([thisRound lightning] + [thisGame team_A_LighteningPoints] + [thisGame team_B_LighteningPoints])];
            [thisRound setBonusHeard:([thisRound bonusHeard] + [thisGame team_A_BonusHeard] + [thisGame team_B_BonusHeard])];
            [thisRound setBonusPoints:([thisRound bonusPoints] + [thisGame team_A_BonusPoints] + [thisGame team_B_BonusPoints])];
            if ((autoTrackSetting == kSQBS_Bounceback) || (autoTrackSetting == kSQBS_AutoBounceback)) {
                [thisRound setBouncebacksHeard:([thisRound bouncebacksHeard] + [thisGame team_A_BounceBacksHeard] + [thisGame team_B_BounceBacksHeard])];
                [thisRound setBouncebacksPoints:([thisRound bouncebacksPoints] + [thisGame team_A_BounceBacksPoints] + [thisGame team_B_BounceBacksPoints])];
            }
            [thisRound setTossUpsPoints:([thisRound tossUpsPoints] + [thisGame getTeamATotalPlayerPoints] + [thisGame getTeamBTotalPlayerPoints])];
            //DebugLog(@"after total - game: %i, round: %i - %@", gIndex, [thisGame round], thisRound);
        }
    }
    [content appendString:@"<table border=1 width=100%>\n<tr>\n  <td><B>Round</B></td>\n  <td><B>PPG/Team</B></td>\n"];
    if (trackTossUpsHeardSetting) {
        if (britishStyleReportSetting) {
            [content appendString:@"  <td><B>SPts/SH</B></td>\n"];
        } else {
            [content appendString:@"  <td><B>TUPts/TUH</B></td>\n"];
        }
    }
    if (trackLightRoundSetting) {
        [content appendString:@"  <td><B>Pts/LtngRd</B></td>\n"];
    }
    if (trackBonusSetting) {
        [content appendString:@"  <td><B>BPts/BHrd</B></td>\n"];
    }
    if ((autoTrackSetting == kSQBS_Bounceback) || (autoTrackSetting == kSQBS_AutoBounceback)) {
        [content appendString:@"  <td><B>BBPts/BBHrd</B></td>\n"];
    }
    [content appendString:@"</tr>\n"];
    //DebugLog(@"roundReport - assigned {%i, %i}, report {%i, %i}", minRoundsAssigned, maxRoundsAssigned, minRoundIncludedInReport, maxRoundIncludedInReport);
    for (int rIndex = 0; rIndex < [rounds count]; rIndex++) {
        if (allRoundsIncludedInReport || (((rIndex + minRoundsAssigned) >= minRoundIncludedInReport) && ((rIndex + minRoundsAssigned) <= maxRoundIncludedInReport))) {
            RoundData *thisRound = [rounds objectAtIndex:rIndex];
            //DebugLog(@"reporting - round: %i - %@", rIndex, thisRound);
            if ([thisRound gamesPlayed] > 0) {
                NSString *roundName = [packetNames objectForKey:[NSString stringWithFormat:kPacketRoundBaseKeyFormat, (rIndex + minRoundsAssigned)]];
                if ((roundName == nil) || [roundName isEqualToString:kPacketMissingPacketNameValue]) {
                    roundName = [NSString stringWithFormat:@"%li", (rIndex + minRoundsAssigned)];
                }
                [content appendFormat:@"  <td>%@</td>\n", roundName];
                [content appendFormat:@"  <td>%.2f</td>\n", safeDivide((float)[thisRound points], (float)[thisRound gamesPlayed])];
                if (trackTossUpsHeardSetting) {
                    [content appendFormat:@"  <td>%.2f</td>\n", safeDivide((float)[thisRound tossUpsPoints], (float)[thisRound tossUpsHeard])];
                }
                if (trackLightRoundSetting) {
                    [content appendFormat:@"  <td>%.2f</td>\n", safeDivide((float)[thisRound lightning], (float)[thisRound gamesPlayed])];
                }
                if (trackBonusSetting) {
                    [content appendFormat:@"  <td>%.2f</td>\n", safeDivide((float)[thisRound bonusPoints], (float)[thisRound bonusHeard])];
                }
                if ((autoTrackSetting == kSQBS_Bounceback) || (autoTrackSetting == kSQBS_AutoBounceback)) {
                    [content appendFormat:@"  <td>%.2f</td>\n", safeDivide((float)[thisRound bouncebacksPoints], (float)[thisRound bouncebacksHeard])];
                }
                [content appendString:@"</tr>\n"];
            }
        }
    }
    [content appendString:@"</table>\n"];
    rounds = nil;
    //    } else {
    //        [content appendString:@"Invalid round numbers\n"];
    //    }
    
    [outfile writeData:[content dataUsingEncoding: NSISOLatin1StringEncoding]];
    content = nil;
    
    [outfile writeData:[[self createReportSuffix] dataUsingEncoding: NSISOLatin1StringEncoding]];
    
    [outfile closeFile];
    outfile = nil;
}

- (void)teamDetailReportCreate {
    NSString *fileName = [NSString stringWithFormat:@"%@%@", reportsBaseName, teamDetailsReportName];
    //DebugLog(@"roundReportCreate - name: %@", fileName);
    [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
    //DebugLog(@"file attributes: %@", [[NSFileManager defaultManager] attributesOfItemAtPath:fileName error:nil]);
    NSFileHandle *outfile = [NSFileHandle fileHandleForWritingAtPath:fileName];
    if (outfile == nil) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"File Error. Report not generated." 
                                         defaultButton:nil 
                                       alternateButton:nil 
                                           otherButton:nil 
                             informativeTextWithFormat:@"file name: %@", fileName];
        [alert runModal];
        return;
    }
    [outfile writeData:[[self createReportPrefixWithTitle:[NSString stringWithFormat:@"%@ Team Details ", tournamentName]] dataUsingEncoding: NSISOLatin1StringEncoding]];
    NSMutableString *content;
    
    int teamIndex = -1;
    for (NSMutableDictionary *theTeam in teamList) {
        NSString *teamName = [theTeam objectForKey:kTeamNameKey];
        teamIndex++;
        // find in standings
        Standing *thisTeam = nil;
        // find team in standings and display only if w/l/t/fw/fl > 0
        for (int i = 0; i < [teamStandings count]; i++) {
            thisTeam = [teamStandings objectAtIndex:i];
            if ([[thisTeam teamName] isEqualToString:teamName]) {
                if (([thisTeam win] + [thisTeam loss] + [thisTeam tie] + [thisTeam forfeitWin] + [thisTeam forfeitLoss]) > 0) {
                    break;
                }
            }
            thisTeam = nil;
        }
        if (thisTeam == nil) {
            continue;
        }
        content = [NSMutableString stringWithFormat:@"<P><P><H2><A NAME=t%i>%@</A></H2><P>\n", teamIndex, teamName];
        [content appendString:@"<table border=1 width=100%>\n<tr>\n<td ALIGN=LEFT><B>Opponent</B></td>\n<td ALIGN=RIGHT><B>Result</B></td>\n<td ALIGN=RIGHT><B>PF</B></td>\n<td ALIGN=RIGHT><B>PA</B></td>\n"];
        if (question_0_value != 0) {
            [content appendFormat:@"  <td ALIGN=RIGHT><B>%li</B></td>\n", question_0_value];
        }
        if (question_1_value != 0) {
            [content appendFormat:@"  <td ALIGN=RIGHT><B>%li</B></td>\n", question_1_value];
        }
        if (question_2_value != 0) {
            [content appendFormat:@"  <td ALIGN=RIGHT><B>%li</B></td>\n", question_2_value];
        }
        if (question_3_value != 0) {
            [content appendFormat:@"  <td ALIGN=RIGHT><B>%li</B></td>\n", question_3_value];
        }
        if (trackTossUpsHeardSetting) {
            if (britishStyleReportSetting) {
                [content appendString:@"  <td ALIGN=RIGHT><B>SH</B></td>\n  <td ALIGN=RIGHT><B>PPSH</B></td>\n"];
            } else {
                [content appendString:@"  <td ALIGN=RIGHT><B>TUH</B></td>\n  <td ALIGN=RIGHT><B>PPTH</B></td>\n"];
            }
        }
        if (trackPowerNegStatsSetting) {
            [content appendString:@"  <td ALIGN=RIGHT><B>P/N</B></td>\n  <td ALIGN=RIGHT><B>G/N</B></td>\n"];
        }
        if (trackLightRoundSetting) {
            [content appendString:@"  <td ALIGN=RIGHT><B>Ltng</B></td>\n"];
        }
        if (trackBonusSetting) {
            [content appendString:@"  <td ALIGN=RIGHT><B>BHrd</B></td>\n  <td ALIGN=RIGHT><B>BPts</B></td>\n  <td ALIGN=RIGHT><B>P/B</B></td>\n"];
            if ((autoTrackSetting == kSQBS_Bounceback) || (autoTrackSetting == kSQBS_AutoBounceback)) {
                [content appendString:@"  <td ALIGN=RIGHT><B>BBHrd</B></td>\n  <td ALIGN=RIGHT><B>BBPts</B></td>\n  <td ALIGN=RIGHT><B>P/BB</B></td>\n"];
            }
        }
        if (roundReportSetting && (packetNamesUsed > 0)) {
            [content appendString:@"  <td ALIGN=LEFT><B>Packet</B></td>\n"];
        }
        [content appendString:@"</tr>\n"];
        [outfile writeData:[content dataUsingEncoding: NSISOLatin1StringEncoding]];
        content = nil;
        
        // use game list sorted by rounds 
        for (Game *thisGame in sortedGameList) {
            if (allRoundsIncludedInReport || (([thisGame round] >= minRoundIncludedInReport) && ([thisGame round] <= maxRoundIncludedInReport))) {
                // check if this team was A team
                if (([thisGame team_A_index] == teamIndex) && ([thisGame team_B_index] >= 0)) {
                    content = [NSMutableString stringWithFormat:@"<tr>\n  <td ALIGN=LEFT>%@</td>\n", [(NSMutableDictionary *)[teamList objectAtIndex:[thisGame team_B_index]] objectForKey:kTeamNameKey]];
                    if ([thisGame forfeit]) {
                        [content appendString:@"  <td ALIGN=RIGHT>W</td>\n  <td ALIGN=RIGHT>Forfeit</td>\n</tr>\n"];
                    } else {
                        NSString *result = @"W";
                        if ([[thisGame team_A_score] intValue] == [[thisGame team_B_score] intValue]) {
                            result = @"T";
                        }
                        if ([[thisGame team_A_score] intValue] < [[thisGame team_B_score] intValue]) {
                            result = @"L";
                        }
                        [content appendFormat:@"  <td ALIGN=RIGHT>%@</td>\n  <td ALIGN=RIGHT>%@</td>\n  <td ALIGN=RIGHT>%@</td>\n", result, [thisGame team_A_score], [thisGame team_B_score]];
                        NSArray *q = [[thisGame getTeamAQuestionPoints] componentsSeparatedByString:@"/"];
                        if (question_0_value != 0) {
                            [content appendFormat:@"  <td ALIGN=RIGHT>%@</td>\n", [q objectAtIndex:0]];
                        }
                        if (question_1_value != 0) {
                            [content appendFormat:@"  <td ALIGN=RIGHT>%@</td>\n", [q objectAtIndex:1]];
                        }
                        if (question_2_value != 0) {
                            [content appendFormat:@"  <td ALIGN=RIGHT>%@</td>\n", [q objectAtIndex:2]];
                        }
                        if (question_3_value != 0) {
                            [content appendFormat:@"  <td ALIGN=RIGHT>%@</td>\n", [q objectAtIndex:3]];
                        }
                        if (trackTossUpsHeardSetting) {
                            [content appendFormat:@"  <td ALIGN=RIGHT>%li</td>\n  <td ALIGN=RIGHT>%.2f</td>\n", [thisGame tossUpsHeard], safeDivide([[thisGame team_A_score] floatValue], (float)[thisGame tossUpsHeard])];
                        }
                        if (trackPowerNegStatsSetting) {
                            if (([[q objectAtIndex:0] intValue] > 0) && ([[q objectAtIndex:2] intValue] == 0)) {
                                [content appendString:@"  <td ALIGN=RIGHT>inf</td>\n"];
                            } else {
                                [content appendFormat:@"  <td ALIGN=RIGHT>%.2f</td>\n", safeDivide([[q objectAtIndex:0] floatValue], [[q objectAtIndex:2] floatValue])];
                            }
                            long gets = [[q objectAtIndex:0] intValue] + [[q objectAtIndex:1] intValue] + [[q objectAtIndex:3] intValue];
                            if ((gets > 0) && ([[q objectAtIndex:2] intValue] == 0)) {
                                [content appendString:@"  <td ALIGN=RIGHT>inf</td>\n"];
                            } else {
                                [content appendFormat:@"  <td ALIGN=RIGHT>%.2f</td>\n", safeDivide((float)gets, [[q objectAtIndex:2] floatValue])];
                            }
                        }
                        if (trackLightRoundSetting) {
                            [content appendFormat:@"  <td ALIGN=RIGHT>%li</td>\n", [thisGame team_A_LighteningPoints]];
                        }
                        if (trackBonusSetting) {
                            [content appendFormat:@"  <td ALIGN=RIGHT>%li</td>\n  <td ALIGN=RIGHT>%li</td>\n  <td ALIGN=RIGHT>%.2f</td>\n", [thisGame team_A_BonusHeard], [thisGame team_A_BonusPoints], safeDivide((float)[thisGame team_A_BonusPoints], (float)[thisGame team_A_BonusHeard])];
                            if ((autoTrackSetting == kSQBS_Bounceback) || (autoTrackSetting == kSQBS_AutoBounceback)) {
                                [content appendFormat:@"  <td ALIGN=RIGHT>%li</td>\n  <td ALIGN=RIGHT>%li</td>\n  <td ALIGN=RIGHT>%.2f</td>\n", [thisGame team_A_BounceBacksHeard], [thisGame team_A_BounceBacksPoints], safeDivide((float)[thisGame team_A_BounceBacksPoints], (float)[thisGame team_A_BounceBacksHeard])];
                            }
                        }
                        if (roundReportSetting && (packetNamesUsed > 0)) {
                            NSString *roundName = @" ";
                            roundName = [packetNames objectForKey:[NSString stringWithFormat:kPacketRoundBaseKeyFormat, [thisGame round]]];
                            if ((roundName == nil) || [roundName isEqualToString:kPacketMissingPacketNameValue]) {
                                roundName = [NSString stringWithFormat:@"%li", [thisGame round]];
                            }
                            [content appendFormat:@"  <td ALIGN=LEFT>%@</td>\n</tr>\n", roundName];
                        }
                    }
                    [outfile writeData:[content dataUsingEncoding: NSISOLatin1StringEncoding]];
                    content = nil;
                }
                
                // check if this team was B team
                if (([thisGame team_B_index] == teamIndex) && ([thisGame team_A_index] >= 0)) {
                    content = [NSMutableString stringWithFormat:@"<tr>\n  <td ALIGN=LEFT>%@</td>\n", [(NSMutableDictionary *)[teamList objectAtIndex:[thisGame team_A_index]] objectForKey:kTeamNameKey]];
                    if ([thisGame forfeit]) {
                        [content appendString:@"  <td ALIGN=RIGHT>W</td>\n  <td ALIGN=RIGHT>Forfeit</td>\n</tr>\n"];
                    } else {
                        NSString *result = @"W";
                        if ([[thisGame team_A_score] intValue] == [[thisGame team_B_score] intValue]) {
                            result = @"T";
                        }
                        if ([[thisGame team_A_score] intValue] > [[thisGame team_B_score] intValue]) {
                            result = @"L";
                        }
                        [content appendFormat:@"  <td ALIGN=RIGHT>%@</td>\n  <td ALIGN=RIGHT>%@</td>\n  <td ALIGN=RIGHT>%@</td>\n", result, [thisGame team_B_score], [thisGame team_A_score]];
                        NSArray *q = [[thisGame getTeamBQuestionPoints] componentsSeparatedByString:@"/"];
                        if (question_0_value != 0) {
                            [content appendFormat:@"  <td ALIGN=RIGHT>%@</td>\n", [q objectAtIndex:0]];
                        }
                        if (question_1_value != 0) {
                            [content appendFormat:@"  <td ALIGN=RIGHT>%@</td>\n", [q objectAtIndex:1]];
                        }
                        if (question_2_value != 0) {
                            [content appendFormat:@"  <td ALIGN=RIGHT>%@</td>\n", [q objectAtIndex:2]];
                        }
                        if (question_3_value != 0) {
                            [content appendFormat:@"  <td ALIGN=RIGHT>%@</td>\n", [q objectAtIndex:3]];
                        }
                        if (trackTossUpsHeardSetting) {
                            [content appendFormat:@"  <td ALIGN=RIGHT>%li</td>\n  <td ALIGN=RIGHT>%.2f</td>\n", [thisGame tossUpsHeard], safeDivide([[thisGame team_B_score] floatValue], (float)[thisGame tossUpsHeard])];
                        }
                        if (trackPowerNegStatsSetting) {
                            if (([[q objectAtIndex:0] intValue] > 0) && ([[q objectAtIndex:2] intValue] == 0)) {
                                [content appendString:@"  <td ALIGN=RIGHT>inf</td>\n"];
                            } else {
                                [content appendFormat:@"  <td ALIGN=RIGHT>%.2f</td>\n", safeDivide([[q objectAtIndex:0] floatValue], [[q objectAtIndex:2] floatValue])];
                            }
                            long gets = [[q objectAtIndex:0] intValue] + [[q objectAtIndex:1] intValue] + [[q objectAtIndex:3] intValue];
                            if ((gets > 0) && ([[q objectAtIndex:2] intValue] == 0)) {
                                [content appendString:@"  <td ALIGN=RIGHT>inf</td>\n"];
                            } else {
                                [content appendFormat:@"  <td ALIGN=RIGHT>%.2f</td>\n", safeDivide((float)gets, [[q objectAtIndex:2] floatValue])];
                            }
                        }
                        if (trackLightRoundSetting) {
                            [content appendFormat:@"  <td ALIGN=RIGHT>%li</td>\n", [thisGame team_B_LighteningPoints]];
                        }
                        if (trackBonusSetting) {
                            [content appendFormat:@"  <td ALIGN=RIGHT>%li</td>\n  <td ALIGN=RIGHT>%li</td>\n  <td ALIGN=RIGHT>%.2f</td>\n", [thisGame team_B_BonusHeard], [thisGame team_B_BonusPoints], safeDivide((float)[thisGame team_B_BonusPoints], (float)[thisGame team_B_BonusHeard])];
                            if ((autoTrackSetting == kSQBS_Bounceback) || (autoTrackSetting == kSQBS_AutoBounceback)) {
                                [content appendFormat:@"  <td ALIGN=RIGHT>%li</td>\n  <td ALIGN=RIGHT>%li</td>\n  <td ALIGN=RIGHT>%.2f</td>\n", [thisGame team_B_BounceBacksHeard], [thisGame team_B_BounceBacksPoints], safeDivide((float)[thisGame team_B_BounceBacksPoints], (float)[thisGame team_B_BounceBacksHeard])];
                            }
                        }
                        if (roundReportSetting && (packetNamesUsed > 0)) {
                            NSString *roundName = @" ";
                            roundName = [packetNames objectForKey:[NSString stringWithFormat:kPacketRoundBaseKeyFormat, [thisGame round]]];
                            if ((roundName == nil) || [roundName isEqualToString:kPacketMissingPacketNameValue]) {
                                roundName = [NSString stringWithFormat:@"%li", [thisGame round]];
                            }
                            [content appendFormat:@"  <td ALIGN=LEFT>%@</td>\n</tr>\n", roundName];
                        }
                    }
                    [outfile writeData:[content dataUsingEncoding: NSISOLatin1StringEncoding]];
                    content = nil;
                }
            }
        }
        // totals
        content = [NSMutableString stringWithString:@"<tr>\n  <td ALIGN=LEFT><B>Total</B></td>\n  <td></td>\n"];
        [content appendFormat:@"  <td ALIGN=RIGHT><B>%li</B></td>\n  <td ALIGN=RIGHT><B>%li</B>\n", [thisTeam pointsFor], [thisTeam pointsAgainst]];
        if (question_0_value != 0) {
            [content appendFormat:@"  <td ALIGN=RIGHT><B>%li</B></td>\n", [thisTeam q0]];
        }
        if (question_1_value != 0) {
            [content appendFormat:@"  <td ALIGN=RIGHT><B>%li</B></td>\n", [thisTeam q1]];
        }
        if (question_2_value != 0) {
            [content appendFormat:@"  <td ALIGN=RIGHT><B>%li</B></td>\n", [thisTeam q2]];
        }
        if (question_3_value != 0) {
            [content appendFormat:@"  <td ALIGN=RIGHT><B>%li</B></td>\n", [thisTeam q3]];
        }
        if (trackTossUpsHeardSetting) {
            [content appendFormat:@"  <td ALIGN=RIGHT><B>%li</B></td>\n  <td ALIGN=RIGHT><B>%.2f</B></td>\n", [thisTeam tossUpsHeard], safeDivide((float)[thisTeam pointsFor], (float)[thisTeam tossUpsHeard])];
        }
        if (trackPowerNegStatsSetting) {
            if (([thisTeam q0] > 0) && ([thisTeam q2] == 0)) {
                [content appendString:@"  <td ALIGN=RIGHT><B>inf</B></td>\n"];
            } else {
                [content appendFormat:@"  <td ALIGN=RIGHT><B>%.2f</B></td>\n", safeDivide((float)[thisTeam q0], (float)[thisTeam q2])];
            }
            long gets = [thisTeam q0] + [thisTeam q1];
            if ((gets > 0) && ([thisTeam q2] == 0)) {
                [content appendString:@"  <td ALIGN=RIGHT><B>inf</B></td>\n"];
            } else {
                [content appendFormat:@"  <td ALIGN=RIGHT><B>%.2f</B></td>\n", safeDivide((float)gets, (float)[thisTeam q2])];
            }
        }
        if (trackLightRoundSetting) {
            [content appendFormat:@"  <td ALIGN=RIGHT><B>%li</B></td>\n", [thisTeam lightning]];
        }
        if (trackBonusSetting) {
            [content appendFormat:@"  <td ALIGN=RIGHT><B>%li</B></td>\n  <td ALIGN=RIGHT><B>%li</B></td>\n  <td ALIGN=RIGHT><B>%.2f</B></td>\n", [thisTeam bonusHeard], [thisTeam bonusPoints], safeDivide((float)[thisTeam bonusPoints], (float)[thisTeam bonusHeard])];
            if ((autoTrackSetting == kSQBS_Bounceback) || (autoTrackSetting == kSQBS_AutoBounceback)) {
                [content appendFormat:@"  <td ALIGN=RIGHT><B>%li</B></td>\n  <td ALIGN=RIGHT><B>%li</B></td>\n  <td ALIGN=RIGHT><B>%.2f</B></td>\n", [thisTeam bouncebacksHeard], [thisTeam bouncebacksPoints], safeDivide((float)[thisTeam bouncebacksPoints], (float)[thisTeam bouncebacksHeard])];
            }
        }
        if (roundReportSetting && (packetNamesUsed > 0)) {
            [content appendString:@"  <td ALIGN=LEFT> </td>\n"];
        }
        [content appendString:@"</tr>\n</table><P>\n"];
        [outfile writeData:[content dataUsingEncoding: NSISOLatin1StringEncoding]];
        content = nil;
        
        // players
        content = [NSMutableString stringWithString:@"<table border=1 width=100%>\n<tr>\n  <td ALIGN=LEFT><B>Player</B></td>\n  <td ALIGN=LEFT><B>Team</B></td>\n  <td ALIGN=RIGHT><B>GP</B></td>\n"];
        if (question_0_value != 0) {
            [content appendFormat:@"  <td ALIGN=RIGHT><B>%li</B></td>\n", question_0_value];
        }
        if (question_1_value != 0) {
            [content appendFormat:@"  <td ALIGN=RIGHT><B>%li</B></td>\n", question_1_value];
        }
        if (question_2_value != 0) {
            [content appendFormat:@"  <td ALIGN=RIGHT><B>%li</B></td>\n", question_2_value];
        }
        if (question_3_value != 0) {
            [content appendFormat:@"  <td ALIGN=RIGHT><B>%li</B></td>\n", question_3_value];
        }
        if (trackTossUpsHeardSetting) {
            if (britishStyleReportSetting) {
                [content appendString:@"  <td ALIGN=RIGHT><B>SH</B></td>\n  <td ALIGN=RIGHT><B>P/S</B></td>\n"];
            } else {
                [content appendString:@"  <td ALIGN=RIGHT><B>TUH</B></td>\n  <td ALIGN=RIGHT><B>P/TU</B></td>\n"];
            }
        }
        if (trackPowerNegStatsSetting) {
            [content appendString:@"  <td ALIGN=RIGHT><B>P/N</B></td>\n  <td ALIGN=RIGHT><B>G/N</B></td>\n"];
        }
        [content appendString:@"  <td ALIGN=RIGHT><B>Pts</B></td>\n  <td ALIGN=RIGHT><B>PPG</B></td>\n</tr>\n"];
        
        [outfile writeData:[content dataUsingEncoding: NSISOLatin1StringEncoding]];
        content = nil;
        
        for (Individuals *thisPlayer in individualStandings) {
            if ([[thisPlayer teamName] isEqualToString:teamName] && ([thisPlayer gamesPlayed] > 0)) {
                content = [NSMutableString stringWithString:@"<tr>\n  <td ALIGN=LEFT>"];
                if (individualStandingsReportSetting) {
                    [content appendFormat:@"<A HREF=%@%@#p%li_%li>",baseName, individualDetailsReportName, [thisPlayer position], [thisPlayer teamIndex]];
                }
                [content appendFormat:@"%@", [thisPlayer playerName]];
                if (individualStandingsReportSetting) {
                    [content appendString:@"</A>"];
                }
                [content appendFormat:@"</td>\n  <td ALIGN=LEFT>%@</td>\n  <td ALIGN=RIGHT>%.1f</td>\n", [thisPlayer teamName], [thisPlayer gamesPlayed]];
                if (question_0_value != 0) {
                    [content appendFormat:@"  <td ALIGN=RIGHT>%li</td>\n", [thisPlayer q0]];
                }
                if (question_1_value != 0) {
                    [content appendFormat:@"  <td ALIGN=RIGHT>%li</td>\n", [thisPlayer q1]];
                }
                if (question_2_value != 0) {
                    [content appendFormat:@"  <td ALIGN=RIGHT>%li</td>\n", [thisPlayer q2]];
                }
                if (question_3_value != 0) {
                    [content appendFormat:@"  <td ALIGN=RIGHT>%li</td>\n", [thisPlayer q3]];
                }
                if (trackTossUpsHeardSetting) {
                    [content appendFormat:@"  <td ALIGN=RIGHT>%li</td>\n  <td ALIGN=RIGHT>%.2f</td>\n", [thisPlayer tossUpsHeard], safeDivide((float)[thisPlayer points], (float)[thisPlayer tossUpsHeard])];
                }
                if (trackPowerNegStatsSetting) {
                    if (([thisPlayer q0] > 0) && ([thisPlayer q2] == 0)) {
                        [content appendString:@"  <td ALIGN=RIGHT>inf</td>\n"];
                    } else {
                        [content appendFormat:@"  <td ALIGN=RIGHT>%.2f</td>\n", safeDivide((float)[thisPlayer q0], (float)[thisPlayer q2])];
                    }
                    long gets = [thisPlayer q0] + [thisPlayer q1] + [thisPlayer q3];
                    if ((gets > 0) && ([thisPlayer q2] == 0)) {
                        [content appendString:@"  <td ALIGN=RIGHT>inf</td>\n"];
                    } else {
                        [content appendFormat:@"  <td ALIGN=RIGHT>%.2f</td>\n", safeDivide((float)gets, (float)[thisPlayer q2])];
                    }
                }
                [content appendFormat:@"  <td ALIGN=RIGHT>%li</td>\n  <td ALIGN=RIGHT>%.2f</td>\n</tr>\n", [thisPlayer points], safeDivide((float)[thisPlayer points], (float)[thisPlayer gamesPlayed])];
                
                [outfile writeData:[content dataUsingEncoding: NSISOLatin1StringEncoding]];
                content = nil;
            }
        }
        content = [NSMutableString stringWithString:@"</table>\n"];
        [outfile writeData:[content dataUsingEncoding: NSISOLatin1StringEncoding]];
        content = nil;
    }
    
    [outfile writeData:[[self createReportSuffix] dataUsingEncoding: NSISOLatin1StringEncoding]];
    
    [outfile closeFile];
    outfile = nil;
}

- (void)individualDetailReportCreate {
    NSString *fileName = [NSString stringWithFormat:@"%@%@", reportsBaseName, individualDetailsReportName];
    //DebugLog(@"roundReportCreate - name: %@", fileName);
    [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
    //DebugLog(@"file attributes: %@", [[NSFileManager defaultManager] attributesOfItemAtPath:fileName error:nil]);
    NSFileHandle *outfile = [NSFileHandle fileHandleForWritingAtPath:fileName];
    if (outfile == nil) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"File Error. Report not generated." 
                                         defaultButton:nil 
                                       alternateButton:nil 
                                           otherButton:nil 
                             informativeTextWithFormat:@"file name: %@", fileName];
        [alert runModal];
        return;
    }
    [outfile writeData:[[self createReportPrefixWithTitle:[NSString stringWithFormat:@"%@ Individual Detail ", tournamentName]] dataUsingEncoding: NSISOLatin1StringEncoding]];
    
    NSMutableString *content;
    NSMutableDictionary *otherTeam;
    int teamIndex = -1;
    for (NSMutableDictionary *theTeam in teamList) {
        NSString *teamName = [theTeam objectForKey:kTeamNameKey];
        teamIndex++;
        for (int pIndex = 0; pIndex <= kMaxPlayersPerTeam; pIndex++) {
            NSString *playerName = [theTeam objectForKey:[NSString stringWithFormat:kPlayerBaseKeyFormat, (pIndex + 1)]];
            BOOL displayPlayer = FALSE;
            if (playerName != nil) {
                // find player in idividual standings data
                // note: individual standings don't include results for exhibition teams, so players on exhibition teams
                // won't be found / displayed in this report
                // if found however, results against exhibition teams will be included ?? correct?
                for (int p = 0; p < [individualStandings count]; p++) {
                    Individuals *thePlayer = [individualStandings objectAtIndex:p];
                    if ([[thePlayer playerName] isEqualToString:playerName] && [[thePlayer teamName] isEqualToString:teamName]) {
                        if ([thePlayer gamesPlayed] > 0) {
                            displayPlayer = TRUE;
                            break;
                        }
                    }
                }
                if (!displayPlayer) {
                    continue;
                }
                // found player in standings, process
                Individuals *thisPlayer = [[Individuals alloc] init];
                content = [NSMutableString stringWithFormat:@"<P><P><H2><A NAME=p%i_%i>%@</A>, %@</H2><P>\n", (pIndex + 1), teamIndex, playerName, teamName];
                [content appendString:@"<table border=1 width=100%>\n<tr>\n<td ALIGN=LEFT><B>Opponent</B></td>\n"];
                if (roundReportSetting && (packetNamesUsed > 0)) {
                    [content appendString:@"  <td ALIGN=LEFT><B>Packet</B></td>\n"];
                }
                [content appendString:@"  <td ALIGN=RIGHT><B>GP</B></td>\n"];
                if (question_0_value != 0) {
                    [content appendFormat:@"  <td ALIGN=RIGHT><B>%li</B></td>\n", question_0_value];
                }
                if (question_1_value != 0) {
                    [content appendFormat:@"  <td ALIGN=RIGHT><B>%li</B></td>\n", question_1_value];
                }
                if (question_2_value != 0) {
                    [content appendFormat:@"  <td ALIGN=RIGHT><B>%li</B></td>\n", question_2_value];
                }
                if (question_3_value != 0) {
                    [content appendFormat:@"  <td ALIGN=RIGHT><B>%li</B></td>\n", question_3_value];
                }
                if (trackTossUpsHeardSetting) {
                    if (britishStyleReportSetting) {
                        [content appendString:@"  <td ALIGN=RIGHT><B>SH</B></td>\n  <td ALIGN=RIGHT><B>P/S</B></td>\n"];
                    } else {
                        [content appendString:@"  <td ALIGN=RIGHT><B>TUH</B></td>\n  <td ALIGN=RIGHT><B>P/TU</B></td>\n"];
                    }
                }
                if (trackPowerNegStatsSetting) {
                    [content appendString:@"  <td ALIGN=RIGHT><B>P/N</B></td>\n  <td ALIGN=RIGHT><B>G/N</B></td>\n"];
                }
                [content appendString:@"  <td ALIGN=RIGHT><B>Pts</B></td>\n</tr>\n"];
                
                [outfile writeData:[content dataUsingEncoding: NSISOLatin1StringEncoding]];
                content = nil;
                
                for (Game *thisGame in sortedGameList) {
                    if (allRoundsIncludedInReport || (([thisGame round] >= minRoundIncludedInReport) && ([thisGame round] <= maxRoundIncludedInReport))) {
                        if (![thisGame forfeit] && (([[thisGame team_A_score] intValue] != -1) && ([[thisGame team_B_score] intValue] != -1))) {
                            if (([thisGame team_A_index] == teamIndex) && ([thisGame team_B_index] >= 0)) {
                                NSArray *results = [[thisGame getTeamAResultsForPlayerWithNumber:pIndex] componentsSeparatedByString:@"/"];
                                //NSString *ret = [thisGame getTeamAResultsForPlayerWithIndex:pIndex];
                                //DebugLog(@"A %@ / %@ - %@", teamName, playerName, ret);
                                //NSArray *results = [ret componentsSeparatedByString:@"/"];
                                float gp = [[results objectAtIndex:0] floatValue];
                                if (gp > 0) {
                                    otherTeam = [teamList objectAtIndex:[thisGame team_B_index]];
                                    content = [NSMutableString stringWithFormat:@"  <td ALIGN=LEFT>%@</td>\n", [otherTeam objectForKey:kTeamNameKey]];
                                    otherTeam = nil;
                                    if (roundReportSetting && (packetNamesUsed > 0)) {
                                        NSString *roundName = @" ";
                                        roundName = [packetNames objectForKey:[NSString stringWithFormat:kPacketRoundBaseKeyFormat, [thisGame round]]];
                                        if ((roundName == nil) || [roundName isEqualToString:kPacketMissingPacketNameValue]) {
                                            roundName = [NSString stringWithFormat:@"%li", [thisGame round]];;
                                        }
                                        [content appendFormat:@"  <td ALIGN=LEFT>%@</td>\n", roundName];
                                    }
                                    [content appendFormat:@"  <td ALIGN=RIGHT>%.2f</td>\n", gp];
                                    if (question_0_value != 0) {
                                        [content appendFormat:@"  <td ALIGN=RIGHT>%@</td>\n", [results objectAtIndex:1]];
                                    }
                                    if (question_1_value != 0) {
                                        [content appendFormat:@"  <td ALIGN=RIGHT>%@</td>\n", [results objectAtIndex:2]];
                                    }
                                    if (question_2_value != 0) {
                                        [content appendFormat:@"  <td ALIGN=RIGHT>%@</td>\n", [results objectAtIndex:3]];
                                    }
                                    if (question_3_value != 0) {
                                        [content appendFormat:@"  <td ALIGN=RIGHT>%@</td>\n", [results objectAtIndex:4]];
                                    }
                                    long tuh = (long)(gp * (float)[thisGame tossUpsHeard] + 0.5);
                                    if (trackTossUpsHeardSetting) {
                                        [content appendFormat:@"  <td ALIGN=RIGHT>%li</td>\n  <td ALIGN=RIGHT>%.2f</td>\n", tuh, safeDivide([[results objectAtIndex:5] floatValue], (float)tuh)];
                                    }
                                    long q0Val = [[results objectAtIndex:1] intValue];
                                    long q1Val = [[results objectAtIndex:2] intValue];
                                    long q2Val = [[results objectAtIndex:3] intValue];
                                    long q3Val = [[results objectAtIndex:4] intValue];
                                    if (trackPowerNegStatsSetting) {
                                        if ((q0Val > 0) && (q2Val == 0)) {
                                            [content appendString:@"  <td ALIGN=RIGHT>inf</td>\n"];
                                        } else {
                                            [content appendFormat:@"  <td ALIGN=RIGHT>%.2f</td>\n", safeDivide((float)q0Val, (float)q2Val)];
                                        }
                                        long gets = q0Val + q1Val + q3Val;
                                        if ((gets > 0) && (q2Val == 0)) {
                                            [content appendString:@"  <td ALIGN=RIGHT>inf</td>\n"];
                                        } else {
                                            [content appendFormat:@"  <td ALIGN=RIGHT>%.2f</td>\n", safeDivide((float)gets, (float)q2Val)];
                                        }
                                    }
                                    [content appendFormat:@"  <td ALIGN=RIGHT>%@</td>\n</tr>\n", [results objectAtIndex:5]];
                                    [thisPlayer setPoints:([thisPlayer points] + [[results objectAtIndex:5] intValue])];
                                    [thisPlayer setQ0:([thisPlayer q0] + q0Val)];
                                    [thisPlayer setQ1:([thisPlayer q1] + q1Val)];
                                    [thisPlayer setQ2:([thisPlayer q2] + q2Val)];
                                    [thisPlayer setQ3:([thisPlayer q3] + q3Val)];
                                    [thisPlayer setGamesPlayed:([thisPlayer gamesPlayed] + gp)];
                                    [thisPlayer setTossUpsHeard:([thisPlayer tossUpsHeard] + tuh)];
                                    [outfile writeData:[content dataUsingEncoding: NSISOLatin1StringEncoding]];
                                    content = nil;
                                }
                                results = nil;
                            }
                            if (([thisGame team_B_index] == teamIndex) && ([thisGame team_A_index] >= 0)) {
                                NSArray *results = [[thisGame getTeamBResultsForPlayerWithNumber:pIndex] componentsSeparatedByString:@"/"];
                                //NSString *ret = [thisGame getTeamBResultsForPlayerWithIndex:pIndex];
                                //DebugLog(@"B %@ / %@ - %@", teamName, playerName, ret);
                                //NSArray *results = [ret componentsSeparatedByString:@"/"];
                                float gp = [[results objectAtIndex:0] floatValue];
                                if (gp > 0) {
                                    otherTeam = [teamList objectAtIndex:[thisGame team_A_index]];
                                    content = [NSMutableString stringWithFormat:@"  <td ALIGN=LEFT>%@</td>\n", [otherTeam objectForKey:kTeamNameKey]];
                                    otherTeam = nil;
                                    if (roundReportSetting && (packetNamesUsed > 0)) {
                                        NSString *roundName = @" ";
                                        roundName = [packetNames objectForKey:[NSString stringWithFormat:kPacketRoundBaseKeyFormat, [thisGame round]]];
                                        if ((roundName == nil) || [roundName isEqualToString:kPacketMissingPacketNameValue]) {
                                            roundName = [NSString stringWithFormat:@"%li", [thisGame round]];
                                        }
                                        [content appendFormat:@"  <td ALIGN=LEFT>%@</td>\nn", roundName];
                                    }
                                    [content appendFormat:@"  <td ALIGN=RIGHT>%.2f</td>\n", gp];
                                    if (question_0_value != 0) {
                                        [content appendFormat:@"  <td ALIGN=RIGHT>%@</td>\n", [results objectAtIndex:1]];
                                    }
                                    if (question_1_value != 0) {
                                        [content appendFormat:@"  <td ALIGN=RIGHT>%@</td>\n", [results objectAtIndex:2]];
                                    }
                                    if (question_2_value != 0) {
                                        [content appendFormat:@"  <td ALIGN=RIGHT>%@</td>\n", [results objectAtIndex:3]];
                                    }
                                    if (question_3_value != 0) {
                                        [content appendFormat:@"  <td ALIGN=RIGHT>%@</td>\n", [results objectAtIndex:4]];
                                    }
                                    long tuh = (long)(gp * (float)[thisGame tossUpsHeard] + 0.5);
                                    if (trackTossUpsHeardSetting) {
                                        [content appendFormat:@"  <td ALIGN=RIGHT>%li</td>\n  <td ALIGN=RIGHT>%.2f</td>\n", tuh, safeDivide([[results objectAtIndex:5] floatValue], (float)tuh)];
                                    }
                                    long q0Val = [[results objectAtIndex:1] intValue];
                                    long q1Val = [[results objectAtIndex:2] intValue];
                                    long q2Val = [[results objectAtIndex:3] intValue];
                                    long q3Val = [[results objectAtIndex:4] intValue];
                                    if (trackPowerNegStatsSetting) {
                                        if ((q0Val > 0) && (q2Val == 0)) {
                                            [content appendString:@"  <td ALIGN=RIGHT>inf</td>\n"];
                                        } else {
                                            [content appendFormat:@"  <td ALIGN=RIGHT>%.2f</td>\n", safeDivide((float)q0Val, (float)q2Val)];
                                        }
                                        long gets = q0Val + q1Val + q3Val;
                                        if ((gets > 0) && (q2Val == 0)) {
                                            [content appendString:@"  <td ALIGN=RIGHT>inf</td>\n"];
                                        } else {
                                            [content appendFormat:@"  <td ALIGN=RIGHT>%.2f</td>\n", safeDivide((float)gets, (float)q2Val)];
                                        }
                                    }
                                    [content appendFormat:@"  <td ALIGN=RIGHT>%@</td>\n</tr>\n", [results objectAtIndex:5]];
                                    [thisPlayer setPoints:([thisPlayer points] + [[results objectAtIndex:5] intValue])];
                                    [thisPlayer setQ0:([thisPlayer q0] + q0Val)];
                                    [thisPlayer setQ1:([thisPlayer q1] + q1Val)];
                                    [thisPlayer setQ2:([thisPlayer q2] + q2Val)];
                                    [thisPlayer setQ3:([thisPlayer q3] + q3Val)];
                                    [thisPlayer setGamesPlayed:([thisPlayer gamesPlayed] + gp)];
                                    [thisPlayer setTossUpsHeard:([thisPlayer tossUpsHeard] + tuh)];
                                    [outfile writeData:[content dataUsingEncoding: NSISOLatin1StringEncoding]];
                                    content = nil;
                                }
                                results = nil;
                            }
                        }
                    }
                }
                // totals
                content = [NSMutableString stringWithString:@"<tr>\n  <td ALIGN=LEFT><B>Total</B></td>\n"];
                if (roundReportSetting && (packetNamesUsed > 0)) {
                    [content appendString:@"  <td ALIGN=LEFT><B> </B></td>\n"];
                }
                [content appendFormat:@"  <td ALIGN=RIGHT><B>%.2f</B></td>\n", [thisPlayer gamesPlayed]];
                if (question_0_value != 0) {
                    [content appendFormat:@"  <td ALIGN=RIGHT><B>%li</B></td>\n", [thisPlayer q0]];
                }
                if (question_1_value != 0) {
                    [content appendFormat:@"  <td ALIGN=RIGHT><B>%li</B></td>\n", [thisPlayer q1]];
                }
                if (question_2_value != 0) {
                    [content appendFormat:@"  <td ALIGN=RIGHT><B>%li</B></td>\n", [thisPlayer q2]];
                }
                if (question_3_value != 0) {
                    [content appendFormat:@"  <td ALIGN=RIGHT><B>%li</B></td>\n", [thisPlayer q3]];
                }
                if (trackTossUpsHeardSetting) {
                    [content appendFormat:@"  <td ALIGN=RIGHT><B>%li</B></td>\n  <td ALIGN=RIGHT><B>%.2f</B></td>\n", [thisPlayer tossUpsHeard], safeDivide((float)[thisPlayer points], (float)[thisPlayer tossUpsHeard])];
                }
                if (trackPowerNegStatsSetting) {
                    if (([thisPlayer q0] > 0) && ([thisPlayer q2] == 0)) {
                        [content appendString:@"  <td ALIGN=RIGHT><B>inf</B></td>\n"];
                    } else {
                        [content appendFormat:@"  <td ALIGN=RIGHT><B>%.2f</B></td>\n", safeDivide((float)[thisPlayer q0], (float)[thisPlayer q2])];
                    }
                    long gets = [thisPlayer q0] + [thisPlayer q1] + [thisPlayer q3];
                    if ((gets > 0) && ([thisPlayer q2] == 0)) {
                        [content appendString:@"  <td ALIGN=RIGHT><B>inf</B></td>\n"];
                    } else {
                        [content appendFormat:@"  <td ALIGN=RIGHT><B>%.2f</B></td>\n", safeDivide((float)gets, (float)[thisPlayer q2])];
                    }
                }
                [content appendFormat:@"  <td ALIGN=RIGHT><B>%li</B></td>\n</tr>\n</table>\n", [thisPlayer points]];
                [thisPlayer release];
                
                [outfile writeData:[content dataUsingEncoding: NSISOLatin1StringEncoding]];
                content = nil;
            }
        }
    }
    
    [outfile writeData:[[self createReportSuffix] dataUsingEncoding: NSISOLatin1StringEncoding]];
    
    [outfile closeFile];
    outfile = nil;
    
}

- (void)scoreboardReportCreate {
    NSString *fileName = [NSString stringWithFormat:@"%@%@", reportsBaseName, scoreboardReportName];
    //DebugLog(@"roundReportCreate - name: %@", fileName);
    [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
    //DebugLog(@"file attributes: %@", [[NSFileManager defaultManager] attributesOfItemAtPath:fileName error:nil]);
    NSFileHandle *outfile = [NSFileHandle fileHandleForWritingAtPath:fileName];
    if (outfile == nil) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"File Error. Report not generated." 
                                         defaultButton:nil 
                                       alternateButton:nil 
                                           otherButton:nil 
                             informativeTextWithFormat:@"file name: %@", fileName];
        [alert runModal];
        return;
    }
    [outfile writeData:[[self createReportPrefixWithTitle:[NSString stringWithFormat:@"%@ Scoreboard ", tournamentName]] dataUsingEncoding: NSISOLatin1StringEncoding]];
    
    // no report if no games
    if ([sortedGameList count] > 0) {
        // using round sorted list so first game will be starting round
        long currentRound = [(Game *)[sortedGameList objectAtIndex:0] round];
        
        if (!allRoundsIncludedInReport) {
            // use minimum
            currentRound = minRoundIncludedInReport;
        }
        NSMutableString *content = [NSMutableString stringWithString:@""];
        // first round header
        if (roundReportSetting) {
            [content appendFormat:@"<FONT SIZE=+1 COLOR=red>Round %li", currentRound];
            if (packetNamesUsed > 0) {
                NSString *packetName = [packetNames objectForKey:[NSString stringWithFormat:kPacketRoundBaseKeyFormat, currentRound]];
                if ((packetName != nil) && ![packetName isEqualToString:kPacketMissingPacketNameValue]) {
                    [content appendFormat:@" (Packet: %@)", packetName];
                }
            }
            [content appendString:@"</FONT><P>\n"];
        }
        
        for (Game *thisGame in sortedGameList) {
            if (allRoundsIncludedInReport || (([thisGame round] >= minRoundIncludedInReport) && ([thisGame round] <= maxRoundIncludedInReport))) {
                if (([thisGame team_A_index] >= 0) && ([thisGame team_B_index] >= 0)) {
                    if (roundReportSetting && ([thisGame round] > currentRound)) {
                        currentRound = [thisGame round];
                        
                        [content appendFormat:@"<hr><FONT SIZE=+1 COLOR=red>Round %li", currentRound];
                        if (packetNamesUsed > 0) {
                            NSString *packetName = [packetNames objectForKey:[NSString stringWithFormat:kPacketRoundBaseKeyFormat, currentRound]];
                            if ((packetName != nil) && ![packetName isEqualToString:kPacketMissingPacketNameValue]) {
                                [content appendFormat:@" (Packet: %@)", packetName];
                            }
                        }
                        [content appendString:@"</FONT><P>\n"];
                    }
                    NSMutableDictionary *teamA = [teamList objectAtIndex:[thisGame team_A_index]];
                    NSMutableDictionary *teamB = [teamList objectAtIndex:[thisGame team_B_index]];
                    NSString *teamAname = [teamA objectForKey:kTeamNameKey];
                    NSString *teamBname = [teamB objectForKey:kTeamNameKey];
                    
                    if ([thisGame forfeit]) {
                        [content appendFormat:@"<FONT SIZE=+1>%@ defeats %@ by forfeit</H2>\n", teamAname, teamBname];
                    } else {
                        long teamAscore = [[thisGame team_A_score] intValue];
                        long teamBscore = [[thisGame team_B_score] intValue];
                        if ((teamAscore != -1) && (teamBscore != -1)) {
                            if (teamAscore > teamBscore) {
                                [content appendFormat:@"<FONT SIZE=+1>%@ %li, %@ %li", teamAname, teamAscore, teamBname, teamBscore];
                            } else {
                                [content appendFormat:@"<FONT SIZE=+1>%@ %li, %@ %li", teamBname, teamBscore, teamAname, teamAscore];
                            }
                            if (teamAscore == teamBscore) {
                                [content appendString:@" Tie"];
                            }
                            if ([thisGame overtime]) {
                                [content appendString:@" OT"];
                            }
                            [content appendFormat:@"</FONT><br>\n<FONT SIZE=-1>\n%@: ", teamAname];
                            BOOL followOnPlayer = FALSE;
                            for (int pIndex = 0; pIndex <= kMaxPlayersPerTeam; pIndex++) {
                                NSArray *results = [[thisGame getTeamAResultsForPlayerAtIndex:pIndex] componentsSeparatedByString:@"/"];
                                float gp = [[results objectAtIndex:0] floatValue];
                                if (gp > 0) {
                                    if (followOnPlayer) {
                                        [content appendString:@", "];
                                    }
                                    [content appendFormat:@"%@ ", [teamA objectForKey:[NSString stringWithFormat:kPlayerBaseKeyFormat, ([[results objectAtIndex:6] intValue] + 1)]]];
                                    if (question_0_value != 0) {
                                        [content appendFormat:@"%@ ", [results objectAtIndex:1]];
                                    }
                                    if (question_1_value != 0) {
                                        [content appendFormat:@"%@ ", [results objectAtIndex:2]];
                                    }
                                    if (question_2_value != 0) {
                                        [content appendFormat:@"%@ ", [results objectAtIndex:3]];
                                    }
                                    if (question_3_value != 0) {
                                        [content appendFormat:@"%@ ", [results objectAtIndex:4]];
                                    }
                                    [content appendFormat:@"%@", [results objectAtIndex:5]];
                                    followOnPlayer = TRUE;
                                }
                            }
                            [content appendFormat:@"<br>\n%@: ", teamBname];
                            followOnPlayer = FALSE;
                            for (int pIndex = 0; pIndex <= kMaxPlayersPerTeam; pIndex++) {
                                NSArray *results = [[thisGame getTeamBResultsForPlayerAtIndex:pIndex] componentsSeparatedByString:@"/"];
                                float gp = [[results objectAtIndex:0] floatValue];
                                if (gp > 0) {
                                    if (followOnPlayer) {
                                        [content appendString:@", "];
                                    }
                                    [content appendFormat:@"%@ ", [teamB objectForKey:[NSString stringWithFormat:kPlayerBaseKeyFormat, ([[results objectAtIndex:6] intValue] + 1)]]];
                                    if (question_0_value != 0) {
                                        [content appendFormat:@"%@ ", [results objectAtIndex:1]];
                                    }
                                    if (question_1_value != 0) {
                                        [content appendFormat:@"%@ ", [results objectAtIndex:2]];
                                    }
                                    if (question_2_value != 0) {
                                        [content appendFormat:@"%@ ", [results objectAtIndex:3]];
                                    }
                                    if (question_3_value != 0) {
                                        [content appendFormat:@"%@ ", [results objectAtIndex:4]];
                                    }
                                    [content appendFormat:@"%@", [results objectAtIndex:5]];
                                    followOnPlayer = TRUE;
                                }
                            }
                            [content appendString:@"<br>\n"];
                            if (trackLightRoundSetting) {
                                [content appendFormat:@"Lightning: %@ %li, %@ %li<br>\n", teamAname, [thisGame team_A_LighteningPoints], teamBname, [thisGame team_B_LighteningPoints]];
                            }
                            if (trackBonusSetting) {
                                [content appendFormat:@"Bonuses: %@ %li %li %.2f, %@ %li %li %.2f<br>\n", teamAname, [thisGame team_A_BonusHeard], [thisGame team_A_BonusPoints], safeDivide((float)[thisGame team_A_BonusPoints], (float)[thisGame team_A_BonusHeard]), teamBname, [thisGame team_B_BonusHeard], [thisGame team_B_BonusPoints], safeDivide((float)[thisGame team_B_BonusPoints], (float)[thisGame team_B_BonusHeard])];
                                if ((autoTrackSetting == kSQBS_Bounceback) || (autoTrackSetting == kSQBS_AutoBounceback)) {
                                    [content appendFormat:@"Bonus Bouncebacks: %@ %li %li %.2f, %@ %li %li %.2f<br>\n", teamAname, [thisGame team_A_BounceBacksHeard], [thisGame team_A_BounceBacksPoints], safeDivide((float)[thisGame team_A_BounceBacksPoints], (float)[thisGame team_A_BounceBacksHeard]), teamBname, [thisGame team_B_BounceBacksHeard], [thisGame team_B_BounceBacksPoints], safeDivide((float)[thisGame team_B_BounceBacksPoints], (float)[thisGame team_B_BounceBacksHeard])];
                                }
                            }
                        }
                    }
                    [content appendString:@"<P></FONT>\n"];
                    teamA = nil;
                    teamB = nil;
                    
                    // write out after each game
                    [outfile writeData:[content dataUsingEncoding: NSISOLatin1StringEncoding]];
                    content = nil;
                    content = [NSMutableString stringWithString:@""];
                }
            }
        }
        
        content = nil;
    }
    
    [outfile writeData:[[self createReportSuffix] dataUsingEncoding: NSISOLatin1StringEncoding]];
    
    [outfile closeFile];
    outfile = nil;
    
}

- (void)individualStandingsReportCreate:(NSString *)fileName QuickPrint:(BOOL)forQuickPrint {
    //NSString *fileName = [NSString stringWithFormat:@"%@%@", reportsBaseName, individualStandingsReportName];
    //DebugLog(@"roundReportCreate - name: %@", fileName);
    [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
    //DebugLog(@"file attributes: %@", [[NSFileManager defaultManager] attributesOfItemAtPath:fileName error:nil]);
    NSFileHandle *outfile = [NSFileHandle fileHandleForWritingAtPath:fileName];
    if (outfile == nil) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"File Error. Report not generated." 
                                         defaultButton:nil 
                                       alternateButton:nil 
                                           otherButton:nil 
                             informativeTextWithFormat:@"file name: %@", fileName];
        [alert runModal];
        return;
    }
    if (!forQuickPrint) {
        [outfile writeData:[[self createReportPrefixWithTitle:[NSString stringWithFormat:@"%@ Individual Statistics ", tournamentName]] dataUsingEncoding: NSISOLatin1StringEncoding]];
    }
    BOOL individualDetailsSetting = individualDetailsReportSetting && !forQuickPrint;
    
    NSMutableString *content = [NSMutableString stringWithFormat:@"<table border=%i", (forQuickPrint ? 0 : 1)];
    [content appendString:@" width=100%>\n<tr>\n  <td ALIGN=LEFT><B>Rank</B></td>\n  <td ALIGN=LEFT><B>Player</B></td>\n  <td ALIGN=LEFT><B>Team</B></td>\n"];
    if (useDivisionsSetting) {
        [content appendString:@"  <td ALIGN=LEFT><B>Division</B></td>\n"];
    }
    [content appendString:@"  <td ALIGN=RIGHT><B>GP</B></td>\n"];
    if (question_0_value != 0) {
        [content appendFormat:@"  <td ALIGN=RIGHT><B>%li</B></td>\n", question_0_value];
    }
    if (question_1_value != 0) {
        [content appendFormat:@"  <td ALIGN=RIGHT><B>%li</B></td>\n", question_1_value];
    }
    if (question_2_value != 0) {
        [content appendFormat:@"  <td ALIGN=RIGHT><B>%li</B></td>\n", question_2_value];
    }
    if (question_3_value != 0) {
        [content appendFormat:@"  <td ALIGN=RIGHT><B>%li</B></td>\n", question_3_value];
    }
    if (trackTossUpsHeardSetting) {
        if (britishStyleReportSetting) {
            [content appendString:@"  <td ALIGN=RIGHT><B>SH</B></td>\n  <td ALIGN=RIGHT><B>P/S</B></td>\n"];
        } else {
            [content appendString:@"  <td ALIGN=RIGHT><B>TUH</B></td>\n  <td ALIGN=RIGHT><B>P/TU</B></td>\n"];
        }
    }
    if (trackPowerNegStatsSetting) {
        [content appendString:@"  <td ALIGN=RIGHT><B>P/N</B></td>\n  <td ALIGN=RIGHT><B>G/N</B></td>\n"];
    }
    [content appendString:@"  <td ALIGN=RIGHT><B>Pts</B></td>\n  <td ALIGN=RIGHT><B>PPG</B></td>\n</tr>\n"];
    [outfile writeData:[content dataUsingEncoding: NSISOLatin1StringEncoding]];
    content = nil;
    
    int playerCount = 1;
    for (Individuals *thisPlayer in individualStandings) {
        if ([thisPlayer gamesPlayed] > 0) {
            content =  [NSMutableString stringWithFormat:@"<tr>\n  <td ALIGN=LEFT>%i</td>\n  <td ALIGN=LEFT>", playerCount++];
            if (individualDetailsSetting) {
                [content appendFormat:@"<A HREF=%@%@#p%li_%li>", baseName, individualDetailsReportName, [thisPlayer position], [thisPlayer teamIndex]];
            }
            [content appendFormat:@"%@", [thisPlayer playerName]];
            if (individualDetailsSetting) {
                [content appendString:@"</A>"];
            }
            [content appendFormat:@"</td>\n  <td ALIGN=LEFT>%@</td>\n", [thisPlayer teamName]];
            if (useDivisionsSetting) {
                if ([thisPlayer teamIndex] >= 0) {
                    NSString * divisionName = [(NSMutableDictionary *)[teamList objectAtIndex:[thisPlayer teamIndex]] objectForKey:kDivisionKey];
                    if (divisionName) {
                        [content appendFormat:@"  <td ALIGN=LEFT>%@</td>\n", divisionName];
                    } else {
                        [content appendString:@"  <td ALIGN=LEFT> </td>\n"];
                    }
                } else {
                    [content appendString:@"  <td ALIGN=LEFT> </td>\n"];
                }
            }
            [content appendFormat:@"  <td ALIGN=RIGHT>%.2f</td>\n", [thisPlayer gamesPlayed]];
            if (question_0_value != 0) {
                [content appendFormat:@"  <td ALIGN=RIGHT>%li</td>\n", [thisPlayer q0]];
            }
            if (question_1_value != 0) {
                [content appendFormat:@"  <td ALIGN=RIGHT>%li</td>\n", [thisPlayer q1]];
            }
            if (question_2_value != 0) {
                [content appendFormat:@"  <td ALIGN=RIGHT>%li</td>\n", [thisPlayer q2]];
            }
            if (question_3_value != 0) {
                [content appendFormat:@"  <td ALIGN=RIGHT>%li</td>\n", [thisPlayer q3]];
            }
            if (trackTossUpsHeardSetting) {
                [content appendFormat:@"  <td ALIGN=RIGHT>%li</td>\n  <td ALIGN=RIGHT>%.2f</td>\n", [thisPlayer tossUpsHeard], safeDivide((float)[thisPlayer points], (float)[thisPlayer tossUpsHeard])];
            }
            if (trackPowerNegStatsSetting) {
                if (([thisPlayer q0] > 0) && ([thisPlayer q2] == 0)) {
                    [content appendString:@"  <td ALIGN=RIGHT>inf</td>\n"];
                } else {
                    [content appendFormat:@"  <td ALIGN=RIGHT>%.2f</td>\n", safeDivide((float)[thisPlayer q0], (float)[thisPlayer q2])];
                }
                long gets = [thisPlayer q0] + [thisPlayer q1] + [thisPlayer q3];
                if ((gets > 0) && ([thisPlayer q2] == 0)) {
                    [content appendString:@"  <td ALIGN=RIGHT>inf</td>\n"];
                } else {
                    [content appendFormat:@"  <td ALIGN=RIGHT>%.2f</td>\n", safeDivide((float)gets, (float)[thisPlayer q2])];
                }
            }
            [content appendFormat:@"  <td ALIGN=RIGHT>%li</td>\n  <td ALIGN=RIGHT>%.2f</td>\n</tr>\n", [thisPlayer points], safeDivide((float)[thisPlayer points], (float)[thisPlayer gamesPlayed])];
            //DebugLog(@"%@", content);
            [outfile writeData:[content dataUsingEncoding: NSISOLatin1StringEncoding]];
            content = nil;
        }
    }
    
    [content appendString:@"</table>\n"];
    [outfile writeData:[content dataUsingEncoding: NSISOLatin1StringEncoding]];
    content = nil;
    
    [outfile writeData:[[self createReportSuffix] dataUsingEncoding: NSISOLatin1StringEncoding]];
    
    [outfile closeFile];
    outfile = nil;
    
}

- (void)teamStandingsReportCreate:(NSString *)fileName QuickPrint:(BOOL)forQuickPrint {
    //NSString *fileName = [NSString stringWithFormat:@"%@%@", reportsBaseName, teamStandingsReportName];
    //DebugLog(@"roundReportCreate - name: %@", fileName);
    [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
    //DebugLog(@"file attributes: %@", [[NSFileManager defaultManager] attributesOfItemAtPath:fileName error:nil]);
    NSFileHandle *outfile = [NSFileHandle fileHandleForWritingAtPath:fileName];
    if (outfile == nil) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"File Error. Report not generated." 
                                         defaultButton:nil 
                                       alternateButton:nil 
                                           otherButton:nil 
                             informativeTextWithFormat:@"file name: %@", fileName];
        [alert runModal];
        return;
    }
    if (!forQuickPrint) {
        [outfile writeData:[[self createReportPrefixWithTitle:[NSString stringWithFormat:@"%@ Team Standings ", tournamentName]] dataUsingEncoding: NSISOLatin1StringEncoding]];
    }
    BOOL teamDetailsSetting = teamDetailsReportSetting && !forQuickPrint;
    
    long maxDivisions = 1;
    if (useDivisionsSetting && (divisionList != nil)) {
        maxDivisions = [divisionList count];
    }
    for (int dIndex = 0; dIndex < maxDivisions; dIndex++) {
        NSMutableString *content = [NSMutableString stringWithString:@""];
        NSString *divisionName = nil;
        if (useDivisionsSetting) {
            divisionName = [divisionList objectAtIndex:dIndex];
            [content appendFormat:@"<P><P><H2>%@</H2><P>", divisionName];
        }
        [content appendFormat:@"<table border=%i", (forQuickPrint ? 0 : 1)];
        [content appendString:@" width=100%>\n  <td ALIGN=LEFT><B>Rank</B></td>\n  <td ALIGN=LEFT><B>Team</B></td>\n  <td ALIGN=RIGHT><B>W</B></td>\n  <td ALIGN=RIGHT><B>L</B></td>\n  <td ALIGN=RIGHT><B>T</B></td>\n  <td ALIGN=RIGHT><B>Pct</B></td>\n  <td ALIGN=RIGHT><B>PPG</B></td>\n  <td ALIGN=RIGHT><B>PAPG</B></td>\n  <td ALIGN=RIGHT><B>Mrg</B></td>\n"];
        if (sortMethodSetting == kSort_RS) {
            [content appendString:@"  <td ALIGN=RIGHT><B>SoS</B></td>\n"];
        }
        if (question_0_value != 0) {
            [content appendFormat:@"  <td ALIGN=RIGHT><B>%li</B></td>\n", question_0_value];
        }
        if (question_1_value != 0) {
            [content appendFormat:@"  <td ALIGN=RIGHT><B>%li</B></td>\n", question_1_value];
        }
        if (question_2_value != 0) {
            [content appendFormat:@"  <td ALIGN=RIGHT><B>%li</B></td>\n", question_2_value];
        }
        if (question_3_value != 0) {
            [content appendFormat:@"  <td ALIGN=RIGHT><B>%li</B></td>\n", question_3_value];
        }
        if (trackTossUpsHeardSetting) {
            if (britishStyleReportSetting) {
                [content appendString:@"  <td ALIGN=RIGHT><B>SH</B></td>\n  <td ALIGN=RIGHT><B>P/S</B></td>\n"];
            } else {
                [content appendString:@"  <td ALIGN=RIGHT><B>TUH</B></td>\n  <td ALIGN=RIGHT><B>P/TU</B></td>\n"];
            }
        }
        if (trackPowerNegStatsSetting) {
            [content appendString:@"  <td ALIGN=RIGHT><B>P/N</B></td>\n  <td ALIGN=RIGHT><B>G/N</B></td>\n"];
        }
        if (trackLightRoundSetting) {
            [content appendString:@"  <td ALIGN=RIGHT><B>Ltng</B></td>\n"];
        }
        if (trackBonusSetting) {
            [content appendString:@"  <td ALIGN=RIGHT><B>BHrd</B></td>\n  <td ALIGN=RIGHT><B>BPts</B></td>\n  <td ALIGN=RIGHT><B>P/B</B></td>\n"];
            if ((autoTrackSetting == kSQBS_Bounceback) || (autoTrackSetting == kSQBS_AutoBounceback)) {
                [content appendString:@"  <td ALIGN=RIGHT><B>BBHrd</B></td>\n  <td ALIGN=RIGHT><B>BBPts</B></td>\n  <td ALIGN=RIGHT><B>P/BB</B></td>\n"];
            }
        }
        [content appendString:@"</tr>"];
        
        [outfile writeData:[content dataUsingEncoding: NSISOLatin1StringEncoding]];
        content = nil;
        
        long placeCntr = 1;
        for (Standing *thisTeam in teamStandings) {
            if (!useDivisionsSetting || [divisionName isEqualToString:[(NSMutableDictionary *)[teamList objectAtIndex:[thisTeam teamIndex]] objectForKey:kDivisionKey]]) {
                float pct, ppg, papg, mrg;
                long nonForfeitGP = [thisTeam win] + [thisTeam loss] + [thisTeam tie];
                long gp = nonForfeitGP + [thisTeam forfeitWin] + [thisTeam forfeitLoss];
                if (gp > 0) {
                    content = [NSMutableString stringWithFormat:@"<tr>\n  <td ALIGN=LEFT>%li</td>", placeCntr++];
                    if (gp == 0) {
                        pct = 0;
                    } else {
                        pct = (float)([thisTeam win] + [thisTeam forfeitWin] + (0.5 * [thisTeam tie])) / (float)gp;
                    }
                    ppg = safeDivide((float)[thisTeam pointsFor], (float)nonForfeitGP);
                    papg = safeDivide((float)[thisTeam pointsAgainst], (float)nonForfeitGP);
                    mrg = ppg - papg;
                    [content appendString:@"  <td ALIGN=LEFT>\n"];
                    if (teamDetailsSetting) {
                        [content appendFormat:@"<A HREF=%@%@#t%li>", baseName, teamDetailsReportName, [thisTeam teamIndex]];
                    }
                    [content appendString:[thisTeam teamName]];
                    if (teamDetailsSetting) {
                        [content appendString:@"</A>"];
                    }
                    [content appendFormat:@"</td>\n  <td ALIGN=RIGHT>%li</td>\n  <td ALIGN=RIGHT>%li</td>\n  <td ALIGN=RIGHT>%li</td>\n  <td ALIGN=RIGHT>%.3f</td>\n  <td ALIGN=RIGHT>%.1f</td>\n  <td ALIGN=RIGHT>%.1f</td>\n  <td ALIGN=RIGHT>%.1f</td>\n", ([thisTeam win] + [thisTeam forfeitWin]), ([thisTeam loss] + [thisTeam forfeitLoss]), [thisTeam tie], pct, ppg, papg, mrg];
                    if (sortMethodSetting == kSort_RS) {
                        [content appendFormat:@"  <td ALIGN=RIGHT>%.1f</td>\n", safeDivide((float)[thisTeam strengthStanding], (float)(nonForfeitGP + 1))];
                    }
                    if (question_0_value != 0) {
                        [content appendFormat:@"  <td ALIGN=RIGHT>%li</td>\n", [thisTeam q0]];
                    }
                    if (question_1_value != 0) {
                        [content appendFormat:@"  <td ALIGN=RIGHT>%li</td>\n", [thisTeam q1]];
                    }
                    if (question_2_value != 0) {
                        [content appendFormat:@"  <td ALIGN=RIGHT>%li</td>\n", [thisTeam q2]];
                    }
                    if (question_3_value != 0) {
                        [content appendFormat:@"  <td ALIGN=RIGHT>%li</td>\n", [thisTeam q3]];
                    }
                    if (trackTossUpsHeardSetting) {
                        [content appendFormat:@"  <td ALIGN=RIGHT>%li</td>\n  <td ALIGN=RIGHT>%.2f</td>\n", [thisTeam tossUpsHeard], safeDivide((float)[thisTeam pointsFor], (float)[thisTeam tossUpsHeard])];
                    }
                    if (trackPowerNegStatsSetting) {
                        if (([thisTeam q0] > 0) && ([thisTeam q2] == 0)) {
                            [content appendString:@"  <td ALIGN=RIGHT>inf</td>\n"];
                        } else {
                            [content appendFormat:@"  <td ALIGN=RIGHT>%.2f</td>\n", safeDivide((float)[thisTeam q0], (float)[thisTeam q2])];
                        }
                        long gets = [thisTeam q0] + [thisTeam q1] + [thisTeam q3];
                        if ((gets > 0) && ([thisTeam q2] == 0)) {
                            [content appendString:@"  <td ALIGN=RIGHT>inf</td>\n"];
                        } else {
                            [content appendFormat:@"  <td ALIGN=RIGHT>%.2f</td>\n", safeDivide((float)gets, (float)[thisTeam q2])];
                        }
                    }
                    if (trackLightRoundSetting) {
                        [content appendFormat:@"  <td ALIGN=RIGHT>%li</td>\n", [thisTeam lightning]];
                    }
                    if (trackBonusSetting) {
                        [content appendFormat:@"  <td ALIGN=RIGHT>%li</td>\n  <td ALIGN=RIGHT>%li</td>\n  <td ALIGN=RIGHT>%.2f</td>\n", [thisTeam bonusHeard], [thisTeam bonusPoints], safeDivide((float)[thisTeam bonusPoints], (float)[thisTeam bonusHeard])];
                        if ((autoTrackSetting == kSQBS_Bounceback) || (autoTrackSetting == kSQBS_AutoBounceback)) {
                            [content appendFormat:@"  <td ALIGN=RIGHT>%li</td>\n  <td ALIGN=RIGHT>%li</td>\n  <td ALIGN=RIGHT>%.2f</td>\n", [thisTeam bouncebacksHeard], [thisTeam bouncebacksPoints], safeDivide((float)[thisTeam bouncebacksPoints], (float)[thisTeam bouncebacksHeard])];
                        }
                    }
                    [content appendString:@"</tr>"];
                    [outfile writeData:[content dataUsingEncoding: NSISOLatin1StringEncoding]];
                    content = nil;
                }
            }
        }
        
        content = [NSMutableString stringWithString:@"</table>\n"];
        [outfile writeData:[content dataUsingEncoding: NSISOLatin1StringEncoding]];
        content = nil; 
    }
    
    [outfile writeData:[[self createReportSuffix] dataUsingEncoding: NSISOLatin1StringEncoding]];
    
    [outfile closeFile];
    outfile = nil;
    
}


- (void)statKeyReportCreate {
    NSString *fileName = [NSString stringWithFormat:@"%@%@", reportsBaseName, statKeyReportName];
    //DebugLog(@"statKeyReportCreate - name: %@", fileName);
    [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
    //DebugLog(@"file attributes: %@", [[NSFileManager defaultManager] attributesOfItemAtPath:fileName error:nil]);
    NSFileHandle *outfile = [NSFileHandle fileHandleForWritingAtPath:fileName];
    if (outfile == nil) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"File Error. Report not generated." 
                                         defaultButton:nil 
                                       alternateButton:nil 
                                           otherButton:nil 
                             informativeTextWithFormat:@"file name: %@", fileName];
        [alert runModal];
        return;
    }
    [outfile writeData:[[self createReportPrefixWithTitle:[NSString stringWithFormat:@"%@ Stat Key ", tournamentName]] dataUsingEncoding: NSISOLatin1StringEncoding]];
    // team standings
    NSMutableString *content = [NSMutableString stringWithString:@"<H2><A NAME=TeamStandings>Team Standings</A></H2><br>\n<table border=1 width=100%>\n<tr>\n<td>W, L, T</td>\n<td>Number of games won (W), lost (L), or tied (T)</td>\n"];
    [content appendString:@"</tr>\n<tr>\n<td>Pct</td>\n<td>Fraction of games won</td>\n</tr>\n<tr>\n<td>PPG</td>\n<td>Average number of points scored by the team in a game</td>\n</tr>\n<tr>\n<td>PAPG</td>\n<td>Average number of points scored against the team in a game</td>\n</tr>\n<tr>\n"];
    [content appendString:@"<td>Mrg</td>\n<td>Team's average margin of victory (if positive) or defeat (if negative)</td>\n</tr>\n"];
    if (sortMethodSetting == 3) {
        [content appendString:@"<tr>\n<td>SoS</td>\n<td>Strength of schedule: Average of own PPG and all opponents' total PPG</td>\n</tr>\n"];
    }
    [content appendString:@"<tr>\n<td>"];
    if (question_0_value != 0) { [content appendFormat:@"%li ", question_0_value]; }
    if (question_1_value != 0) { [content appendFormat:@"%li ", question_1_value]; }
    if (question_2_value != 0) { [content appendFormat:@"%li ", question_2_value]; }
    if (question_3_value != 0) { [content appendFormat:@"%li ", question_3_value]; }
    if (britishStyleReportSetting) {
        [content appendString:@"</td>\n<td>Number of starters answered for the corresponding point value (negative point values are for incorrect interrupts)</td>\n</tr>\n"];
    } else {
        [content appendString:@"</td>\n<td>Number of toss-ups answered for the corresponding point value (negative point values are for incorrect interrupts)</td>\n</tr>\n"];
    }
    if (trackTossUpsHeardSetting) {
        [content appendString:@"<tr>\n"];
        if (britishStyleReportSetting) {
            [content appendString:@"<td>SH</td>\n<td>Total number of starters heard by the team</td>\n</tr>\n<tr>\n<td>PPSH</td>\n<td>Average number of points scored by the team per starter heard</td>\n</tr>\n"];
        } else {
            [content appendString:@"<td>TUH</td>\n<td>Total number of toss-ups heard by the team</td>\n</tr>\n<tr>\n<td>PPTH</td>\n<td>Average number of points scored by the team per toss-up heard</td>\n</tr>\n"];
        }
    }
    if (trackPowerNegStatsSetting) {
        [content appendString:@"<tr>\n<td>P/N</td>\n<td>Ratio of powers to negs</td>\n</tr>\n<tr>\n<td>G/N</td>\n<td>Ratio of gets (correctly answered questions) to negs</td>\n</tr>\n"];
    }
    if (trackLightRoundSetting) {
        [content appendString:@"<tr>\n<td>Ltng</td>\n<td>Total number of points scored by the team in the lightning round</td>\n</tr>\n"];
    }
    if (trackBonusSetting) {
        [content appendString:@"<tr>\n<td>BHrd</td>\n<td>Total number of bonus questions heard by the team</td>\n</tr>\n"];
        [content appendString:@"<tr>\n<td>BPts</td>\n<td>Total number of points scored by the team on bonus questions</td>\n</tr>\n"];
        [content appendString:@"<tr>\n<td>P/B</td>\n<td>Average number of points scored by the team on bonus questions</td>\n</tr>\n"];
        if ((autoTrackSetting == kSQBS_Bounceback) || (autoTrackSetting == kSQBS_AutoBounceback)) {
            [content appendString:@"<tr>\n<td>BBHrd</td>\n<td>Total number of bonus bouncebacks heard by the team</td>\n</tr>\n"];
            [content appendString:@"<tr>\n<td>BBPts</td>\n<td>Total number of points scored by the team on bonus bouncebacks</td>\n</tr>\n"];
            [content appendString:@"<tr>\n<td>P/BB</td>\n<td>Average number of points scored by the team on bonus bouncebacks</td>\n</tr>\n"];
        }
    }
    [content appendString:@"</table><P>\n"];
    [outfile writeData:[content dataUsingEncoding: NSISOLatin1StringEncoding]];
    content = nil;
    
    // individual standings
    content = [NSMutableString stringWithString:@"<H2><A NAME=IndividualStandings>Individual Statistics</A></H2><br>\n<table border=1 width=100%>\n<tr>\n<td>GP</td>\n<td>Number of games in which the player participated</td>\n</tr>\n<tr>\n<td>"];
    if (question_0_value != 0) { [content appendFormat:@"%li ", question_0_value]; }
    if (question_1_value != 0) { [content appendFormat:@"%li ", question_1_value]; }
    if (question_2_value != 0) { [content appendFormat:@"%li ", question_2_value]; }
    if (question_3_value != 0) { [content appendFormat:@"%li ", question_3_value]; }
    if (britishStyleReportSetting) {
        [content appendString:@"</td>\n<td>Number of starters answered for the corresponding point value (negative point values are for incorrect interrupts)</td>\n</tr>\n"];
    } else {
        [content appendString:@"</td>\n<td>Number of toss-ups answered for the corresponding point value (negative point values are for incorrect interrupts)</td>\n</tr>\n"];
    }
    if (trackTossUpsHeardSetting) {
        [content appendString:@"<tr>\n"];
        if (britishStyleReportSetting) {
            [content appendString:@"<td>SH</td>\n<td>Total number of starters heard by the player</td>\n</tr>\n<tr>\n<td>P/S</td>\n<td>Average number of points scored by the player per starter heard</td>\n</tr>\n"];
        } else {
            [content appendString:@"<td>TUH</td>\n<td>Total number of toss-ups heard by the player</td>\n</tr>\n<tr>\n<td>P/TU</td>\n<td>Average number of points scored by the player per toss-up heard</td>\n</tr>\n"];
        }
    }
    if (trackPowerNegStatsSetting) {
        [content appendString:@"<tr>\n<td>P/N</td>\n<td>Ratio of powers to negs</td>\n</tr>\n<tr>\n<td>G/N</td>\n<td>Ratio of gets (correctly answered questions) to negs</td>\n</tr>\n"];
    }
    [content appendString:@"<tr>\n<td>Pts</td>\n<td>Total number of points scored by the player</td>\n</tr>\n<tr>\n<td>PPG</td>\n<td>Average number of points scored by the player per game</td>\n</tr>\n</table><P>\n"];
    [outfile writeData:[content dataUsingEncoding: NSISOLatin1StringEncoding]];
    content = nil;
    
    // scoreboard
    content = [NSMutableString stringWithString:@"<H2><A NAME=Scoreboard>Scoreboard</A></H2><br>\nFor each game, the score is listed in large bold print on the first line.  Then each individual who played in the game is listed, by team, along with "];
    [content appendString:@"the number of each type of question answered (in the order that they appear in the other reports (usually decreasing order, such as 15 10 -5).  The last number after each name is the individual's total points for the game.\n"];
    if (trackLightRoundSetting) {
        [content appendString:@"The next line of the boxscore gives, for each team, the total number of points scored in the lightning round.  \n"];
    }
    if (trackBonusSetting) {
        [content appendString:@"The next line of the boxscore gives, for each team, the total number of bonuses heard, the total number of points scored on bonuses, and the average number of points scored per bonus heard."];
        if ((autoTrackSetting == kSQBS_Bounceback) || (autoTrackSetting == kSQBS_AutoBounceback)) {
            [content appendString:@"The next line of the boxscore gives, for each team, the total number of bonus bouncebacks heard, the total number of points scored on bonus bouncebacks, and the average number of points scored per bonus bounceback heard."];
        }
    }
    [content appendString:@"<P><P>\n"];
    [outfile writeData:[content dataUsingEncoding: NSISOLatin1StringEncoding]];
    content = nil;
    
    // team details
    content = [NSMutableString stringWithString:@"<H2><A NAME=TeamDetail>Team Detail</A></H2><br>\n<table border=1 width=100%>\n<tr>\n<td>Result</td>\n<td>Whether the team won (W), lost (L), or tied (T) the game</td>\n</tr>\n<tr>\n"];
    [content appendString:@"<td>PF</td>\n<td>Total number of points scored by the team</td>\n</tr>\n<tr>\n<td>PA</td>\n<td>Total number of points scored by the opponent</td>\n</tr>\n<tr>\n<td>"];
    if (question_0_value != 0) { [content appendFormat:@"%li ", question_0_value]; }
    if (question_1_value != 0) { [content appendFormat:@"%li ", question_1_value]; }
    if (question_2_value != 0) { [content appendFormat:@"%li ", question_2_value]; }
    if (question_3_value != 0) { [content appendFormat:@"%li ", question_3_value]; }
    if (britishStyleReportSetting) {
        [content appendString:@"</td>\n<td>Number of starters answered for the corresponding point value (negative point values are for incorrect interrupts)</td>\n</tr>\n"];
    } else {
        [content appendString:@"</td>\n<td>Number of toss-ups answered for the corresponding point value (negative point values are for incorrect interrupts)</td>\n</tr>\n"];
    }
    if (trackTossUpsHeardSetting) {
        [content appendString:@"<tr>\n"];
        if (britishStyleReportSetting) {
            [content appendString:@"<td>SH</td>\n<td>Total number of starters heard</td>\n</tr>\n<tr>\n<td>PPSH</td>\n<td>Average number of points scored by the team per starter heard</td>\n</tr>\n"];
        } else {
            [content appendString:@"<td>TUH</td>\n<td>Total number of toss-ups heard</td>\n</tr>\n<tr>\n<td>PPTH</td>\n<td>Average number of points scored by the team per toss-up heard</td>\n</tr>\n"];
        }
    }
    if (trackPowerNegStatsSetting) {
        [content appendString:@"<tr>\n<td>P/N</td>\n<td>Ratio of powers to negs</td>\n</tr>\n"];
        [content appendString:@"<tr>\n<td>G/N</td>\n<td>Ratio of gets (correctly answered questions) to negs</td>\n</tr>\n"];
    }
    if (trackLightRoundSetting) {
        [content appendString:@"<tr>\n<td>Ltng</td>\n<td>Total number of points scored by the team in the lightning round</td>\n</tr>\n"];
    }
    if (trackBonusSetting) {
        [content appendString:@"<tr>\n<td>BHrd</td>\n<td>Total number of bonus questions heard by the team</td>\n</tr>\n"];
        [content appendString:@"<tr>\n<td>BPts</td>\n<td>Total number of points scored by the team on bonus questions</td>\n</tr>\n"];
        [content appendString:@"<tr>\n<td>P/B</td>\n<td>Average number of points scored by the team on bonus questions</td>\n</tr>\n"];
        if ((autoTrackSetting == kSQBS_Bounceback) || (autoTrackSetting == kSQBS_AutoBounceback)) {
            [content appendString:@"<tr>\n<td>BBHrd</td>\n<td>Total number of bonus bouncebacks heard by the team</td>\n</tr>\n"];
            [content appendString:@"<tr>\n<td>BBPts</td>\n<td>Total number of points scored by the team on bonus bouncebacks</td>\n</tr>\n"];
            [content appendString:@"<tr>\n<td>P/BB</td>\n<td>Average number of points scored by the team on bonus bouncebacks</td>\n</tr>\n"];
        }
    }
    [content appendString:@"</table><P>\n"];
    [outfile writeData:[content dataUsingEncoding: NSISOLatin1StringEncoding]];
    content = nil;
    
    // individual details
    content = [NSMutableString stringWithString:@"<H2><A NAME=IndividualDetail>Individual Detail</A></H2><br>\n<table border=1 width=100%>\n<tr>\n<td>GP</td>\n<td>Number of games in which the player participated</td>\n</tr>\n<tr>\n<td>"];
    if (question_0_value != 0) { [content appendFormat:@"%li ", question_0_value]; }
    if (question_1_value != 0) { [content appendFormat:@"%li ", question_1_value]; }
    if (question_2_value != 0) { [content appendFormat:@"%li ", question_2_value]; }
    if (question_3_value != 0) { [content appendFormat:@"%li ", question_3_value]; }
    if (britishStyleReportSetting) {
        [content appendString:@"</td>\n<td>Number of starters answered for the corresponding point value (negative point values are for incorrect interrupts)</td>\n</tr>\n"];
    } else {
        [content appendString:@"</td>\n<td>Number of toss-ups answered for the corresponding point value (negative point values are for incorrect interrupts)</td>\n</tr>\n"];
    }
    if (trackTossUpsHeardSetting) {
        [content appendString:@"<tr>\n"];
        if (britishStyleReportSetting) {
            [content appendString:@"<td>SH</td>\n<td>Total number of starters heard by the player</td>\n</tr>\n<tr>\n<td>P/S</td>\n<td>Average number of points scored by the player per starter heard</td>\n</tr>\n"];
        } else {
            [content appendString:@"<td>TUH</td>\n<td>Total number of toss-ups heard by the player</td>\n</tr>\n<tr>\n<td>P/TU</td>\n<td>Average number of points scored by the player per toss-up heard</td>\n</tr>\n"];
        }
    }
    if (trackPowerNegStatsSetting) {
        [content appendString:@"<tr>\n<td>P/N</td>\n<td>Ratio of powers to negs</td>\n</tr>\n<tr>\n<td>G/N</td>\n<td>Ratio of gets (correctly answered questions) to negs</td>\n</tr>\n"];
    }
    [content appendString:@"<tr>\n<td>Pts</td>\n<td>Total number of points scored by the player</td>\n</tr>\n<tr>\n<td>PPG</td>\n<td>Average number of points scored by the player per game</td>\n</tr>\n</table><P>\n"];
    [outfile writeData:[content dataUsingEncoding: NSISOLatin1StringEncoding]];
    content = nil;
    
    // round
    content = [NSMutableString stringWithString:@"<H2><A NAME=RoundReport>Round Report</A></H2><br>\n<table border=1 width=100%>\n<tr>\n<td>PPG/Team</td>\n<td>Average number of points scored per team per game</td>\n</tr>\n"];
    if (trackTossUpsHeardSetting) {
        [content appendString:@"<tr>\n<td>TUPts/TUH.</td>\n<td>Average number of points scored on toss-up questions per toss-up heard</td>\n</tr>\n"];
    }
    if (trackLightRoundSetting) {
        [content appendString:@"<tr>\n<td>Pts/LtngRd</td>\n<td>Average number of points scored in the lightning round per team per game</td></td>\n</tr>\n"];
    }
    if (trackBonusSetting) {
        [content appendString:@"<tr>\n<td>BPts/BH</td>\n<td>Average number of points scored on bonus questions per bonus heard</td>\n</tr>\n"];
        if ((autoTrackSetting == kSQBS_Bounceback) || (autoTrackSetting == kSQBS_AutoBounceback)) {
            [content appendString:@"<tr>\n<td>BBPts/BBH</td>\n<td>Average number of points scored on bonus bouncebacks per bonus bounceback heard</td>\n</tr>\n"];
        }
    }
    [content appendString:@"</table><P>\n"];
    [content appendString:@"For information about this statistics program, visit the <A HREF=http://www.stanford.edu/~csewell/sqbs/index.htm>SQBS homepage</A>."];
    [outfile writeData:[content dataUsingEncoding: NSISOLatin1StringEncoding]];
    content = nil;
    
    [outfile writeData:[[self createReportSuffix] dataUsingEncoding: NSISOLatin1StringEncoding]];
    
    [outfile closeFile];
    outfile = nil;
    
}

- (IBAction)createWebReports:(id)sender {
    // use save panel to folder and base name of reports
    NSSavePanel *saveDlg = [NSSavePanel savePanel];
    [saveDlg setTitle:@"Create Reports In Folder"];
    NSString *initialFolderName = [self displayName];
    initialFolderName = [initialFolderName stringByDeletingPathExtension];
    [saveDlg setNameFieldStringValue:initialFolderName];
    //[saveDlg setNameFieldStringValue:[[tournamentFileName lastPathComponent] stringByDeletingPathExtension]];  // didn't work on 10.6 ??
    [saveDlg setCanCreateDirectories:TRUE];
    [saveDlg setPrompt:@"Create"];
    
    // Display the dialog.  If the OK button was pressed,
    // process the files.
    if ([saveDlg runModal] == NSFileHandlingPanelOKButton)
    {
        //DebugLog(@"createWebReports - url: %@", [[saveDlg URL] path]);
        [self setBaseName:[[[[saveDlg URL] path] lastPathComponent] stringByAddingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding]];
        [self setReportsBaseName:[[saveDlg URL] path]];
        
        [self teamTotals];
        [self individualTotals];
        //DebugLog(@"individual totals: %i", [individualStandings count]);
        
        [self setSortedGameList:nil];
        [self setSortedGameList:[NSMutableArray arrayWithArray:[gameList sortedArrayUsingSelector:@selector(sortGameByRound:)]]];
        
        if (styleReportSetting) {
            if (styleReportName != nil && [[NSFileManager defaultManager] fileExistsAtPath:styleReportName]) {
                if ([[NSFileManager defaultManager] copyItemAtPath:styleReportName toPath:[NSString stringWithFormat:@"%@%@", reportsBaseName, kStyleSheetName] error:nil]) {
                    NSAlert *alert = [NSAlert alertWithMessageText:@"File Error. Style sheet not copied." 
                                                     defaultButton:nil 
                                                   alternateButton:nil 
                                                       otherButton:nil 
                                         informativeTextWithFormat:@"style sheet location: %@", styleReportName];
                    [alert runModal];
                }
            } else {
                NSAlert *alert = [NSAlert alertWithMessageText:@"Style sheet not found." 
                                                 defaultButton:nil 
                                               alternateButton:nil 
                                                   otherButton:nil 
                                     informativeTextWithFormat:@"style sheet name from Settings/Report: %@", styleReportName];
                [alert runModal];
            }
        }
        
        if (roundReportSetting) {
            [self roundReportCreate];
        }
        if (teamDetailsReportSetting) {
            [self teamDetailReportCreate];
        }
        if (individualDetailsReportSetting) {
            [self individualDetailReportCreate];
        }
        if (scoreboardReportSetting) {
            [self scoreboardReportCreate];
        }
        
        // sort standings before doing standings reports
        NSString *qValues = [NSString stringWithFormat:@"%li/%li/%li/%li", question_0_value, question_1_value, question_2_value, question_3_value];
        if (tossUpHeardSortSetting) {
            [individualStandings sortUsingFunction:individualsSort_TUH context:qValues];
        } else {
            [individualStandings sortUsingFunction:individualsSort context:qValues];
        }
        // assign a copy of teamStandings before sort as sorter refers to teamStandings
        [self setTeamStandingsCopy:nil];
        [self setTeamStandingsCopy:[NSArray arrayWithArray:teamStandings]];
        [teamStandings sortUsingFunction:standingsSort context:self];
        
        if (individualStandingsReportSetting) {
            [self individualStandingsReportCreate:[NSString stringWithFormat:@"%@%@", reportsBaseName, individualStandingsReportName] QuickPrint:FALSE];
        }
        if (teamStandingsReportSetting) {
            [self teamStandingsReportCreate:[NSString stringWithFormat:@"%@%@", reportsBaseName, teamStandingsReportName] QuickPrint:FALSE];
        }
        if (statKeyReportSetting) {
            [self statKeyReportCreate];
        }
        
        // release arrays created for reports
        [self setTeamStandings:nil];
        [self setTeamStandingsCopy:nil];
        [self setSortedGameList:nil];
        [self setIndividualStandings:nil];
    }
}

-(void)selectReportsView {
    // select reports view if not already selected
    if (lastSelectedView != kReportsView) {
        [viewSelectorSegmentedControl setSelectedSegment:kReportsView];
        [self viewSelectorChangeAction:viewSelectorSegmentedControl];
    }
}

- (IBAction)quickPrintTeamReport:(id)sender {
    [self selectReportsView];
    [self teamTotals];
    // assign a copy of teamStandings before sort as sorter refers to teamStandings
    [self setTeamStandingsCopy:nil];
    [self setTeamStandingsCopy:[NSArray arrayWithArray:teamStandings]];
    [teamStandings sortUsingFunction:standingsSort context:self];
    
    NSString *fileName = [NSTemporaryDirectory() stringByAppendingPathComponent:@"SQBS_temp_Team_Report.html"];
    //DebugLog(@"quickPrintTeamReport - name: %@", fileName);
    
    [self teamStandingsReportCreate:fileName QuickPrint:TRUE];
    
    [self setQuickReportRequested:kQuickReportTeam];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTournamentReportGeneratedNotification object:self userInfo:[NSDictionary dictionaryWithObject:fileName forKey:@"fileName"]];
    
    // release arrays created for reports
    [self setTeamStandings:nil];
    [self setTeamStandingsCopy:nil];
}

- (IBAction)quickPrintIndividualReport:(id)sender {
    [self selectReportsView];
    [self individualTotals];
    
    NSString *fileName = [NSTemporaryDirectory() stringByAppendingPathComponent:@"SQBS_temp_Individual_Report.html"];
    //DebugLog(@"quickPrintIndividualReport - name: %@", fileName);
    
    // sort standings before doing standings reports
    NSString *qValues = [NSString stringWithFormat:@"%li/%li/%li/%li", question_0_value, question_1_value, question_2_value, question_3_value];
    if (tossUpHeardSortSetting) {
        [individualStandings sortUsingFunction:individualsSort_TUH context:qValues];
    } else {
        [individualStandings sortUsingFunction:individualsSort context:qValues];
    }
    
    [self individualStandingsReportCreate:fileName QuickPrint:TRUE];
    
    [self setQuickReportRequested:kQuickReportIndividual];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTournamentReportGeneratedNotification object:self userInfo:[NSDictionary dictionaryWithObject:fileName forKey:@"fileName"]];
    
    // release arrays created for reports
    [self setIndividualStandings:nil];
}

- (IBAction)quickPrintGameReport:(id)sender {
    [self selectReportsView];
    [self setSortedGameList:nil];
    [self setSortedGameList:[NSMutableArray arrayWithArray:[gameList sortedArrayUsingSelector:@selector(sortGameByRound:)]]];
    
    NSString *fileName = [NSTemporaryDirectory() stringByAppendingPathComponent:@"SQBS_temp_Game_Report.html"];
    //DebugLog(@"quickPrintGameReport - name: %@", fileName);
    [[NSFileManager defaultManager] createFileAtPath:fileName contents:nil attributes:nil];
    //DebugLog(@"file attributes: %@", [[NSFileManager defaultManager] attributesOfItemAtPath:fileName error:nil]);
    NSFileHandle *outfile = [NSFileHandle fileHandleForWritingAtPath:fileName];
    if (outfile == nil) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"File Error. Report not generated." 
                                         defaultButton:nil 
                                       alternateButton:nil 
                                           otherButton:nil 
                             informativeTextWithFormat:@"file name: %@", fileName];
        [alert runModal];
        return;
    }
    
    // no report if no games
    if ([sortedGameList count] > 0) {
        // using round sorted list so first game will be starting round
        long currentRound = [(Game *)[sortedGameList objectAtIndex:0] round];
        
        if (!allRoundsIncludedInReport) {
            // use minimum
            currentRound = minRoundIncludedInReport;
        }
        NSMutableString *content = [NSMutableString stringWithString:@"<table border=0  style=\"width:500px\""];
        // first round header
        if (roundReportSetting) {
            [content appendFormat:@"<tr>\n  <td></td>\n</tr>\n<tr>\n  <td colspan=4><B>Round %li", currentRound];
            if (packetNamesUsed > 0) {
                NSString *packetName = [packetNames objectForKey:[NSString stringWithFormat:kPacketRoundBaseKeyFormat, currentRound]];
                //DebugLog(@"[%@] [%@]", kPacketMissingPacketNameValue, packetName);
                if ((packetName != nil) && ![packetName isEqualToString:kPacketMissingPacketNameValue]) {
                    [content appendFormat:@" (Packet: %@)", packetName];
                }
            }
            [content appendString:@"</B></td>\n</tr>\n<tr>\n"];
        }
        
        for (Game *thisGame in sortedGameList) {
            if (allRoundsIncludedInReport || (([thisGame round] >= minRoundIncludedInReport) && ([thisGame round] <= maxRoundIncludedInReport))) {
                if (([thisGame team_A_index] >= 0) && ([thisGame team_B_index] >= 0)) {
                    if (roundReportSetting && ([thisGame round] > currentRound)) {
                        currentRound = [thisGame round];
                        
                        [content appendFormat:@"<tr>\n  <td></td>\n</tr>\n<tr>\n  <td colspan=4><B>Round %li", currentRound];
                        if (packetNamesUsed > 0) {
                            NSString *packetName = [packetNames objectForKey:[NSString stringWithFormat:kPacketRoundBaseKeyFormat, currentRound]];
                            //DebugLog(@"[%@] [%@]", kPacketMissingPacketNameValue, packetName);
                            if ((packetName != nil) && ![packetName isEqualToString:kPacketMissingPacketNameValue]) {
                                [content appendFormat:@" (Packet: %@)", packetName];
                            }
                        }
                        [content appendString:@"</B></td>\n</tr>\n<tr>\n"];
                    }
                    NSMutableDictionary *teamA = [teamList objectAtIndex:[thisGame team_A_index]];
                    NSMutableDictionary *teamB = [teamList objectAtIndex:[thisGame team_B_index]];
                    NSString *teamAname = [teamA objectForKey:kTeamNameKey];
                    NSString *teamBname = [teamB objectForKey:kTeamNameKey];
                    [content appendString:@"<tr>\n"];
                    if ([thisGame forfeit]) {
                        [content appendFormat:@"  <td colspan=4>%@ defeats %@ by forfeit</td>\n", teamAname, teamBname];
                    } else {
                        long teamAscore = [[thisGame team_A_score] intValue];
                        long teamBscore = [[thisGame team_B_score] intValue];
                        if ((teamAscore != -1) && (teamBscore != -1)) {
                            if (teamAscore > teamBscore) {
                                [content appendString:@"  <td style=\"width:30%\">\n"];
                                [content appendString:teamAname];
                                [content appendString:@"  <td style=\"width:15%\">\n"];
                                [content appendFormat:@"%li", teamAscore];
                                [content appendString:@"  <td style=\"width:30%\">\n"];
                                [content appendString:teamBname];
                                [content appendString:@"  <td style=\"width:15%\">\n"];
                                [content appendFormat:@"%li", teamBscore];
                            } else {
                                [content appendString:@"  <td style=\"width:30%\">\n"];
                                [content appendString:teamBname];
                                [content appendString:@"  <td style=\"width:15%\">\n"];
                                [content appendFormat:@"%li", teamBscore];
                                [content appendString:@"  <td style=\"width:30%\">\n"];
                                [content appendString:teamAname];
                                [content appendString:@"  <td style=\"width:15%\">\n"];
                                [content appendFormat:@"%li", teamAscore];
                            }
                            if (teamAscore == teamBscore) {
                                [content appendString:@"  <td style=\"width:10%\">\nTie</td>\n"];
                            }
                            if ([thisGame overtime]) {
                                [content appendString:@"  <td style=\"width:10%\">\nOT</td>\n"];
                            }
                        }
                    }
                    [content appendString:@"</tr>\n"];
                }
            }
        }
        [content appendString:@"</table>\n"];
        //DebugLog(@"%@", content);
        [outfile writeData:[content dataUsingEncoding: NSISOLatin1StringEncoding]];
        content = nil;
        
        [outfile writeData:[[self createReportSuffix] dataUsingEncoding: NSISOLatin1StringEncoding]];
        
        [outfile closeFile];
        
        [self setQuickReportRequested:kQuickReportGame];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTournamentReportGeneratedNotification object:self userInfo:[NSDictionary dictionaryWithObject:fileName forKey:@"fileName"]];
    }
    
    // release arrays created for reports
    [self setSortedGameList:nil];
    
}

@end
