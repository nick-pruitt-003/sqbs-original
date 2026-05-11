//
//  Document.h
//  SQBS2
//
//  Created by Neil Smith on 12-01-10.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MergeFileWindowController.h"

@interface Tournament : NSDocument
{
    IBOutlet NSView *myTargetView;				// the host view
	NSViewController *myCurrentViewController;	// the current view controller
    long lastSelectedView;
    IBOutlet NSSegmentedControl *viewSelectorSegmentedControl;
    
    IBOutlet NSToolbar *mainToolBar;
    
    NSString *tournamentFileName;
    
    NSMutableArray *teamList;
    long defaultPlayersPerTeam;
    
    NSMutableArray *gameList;
    NSMutableArray *sortedGameList;
    
    NSMutableArray *teamStandings;
    NSArray *teamStandingsCopy;
    NSMutableArray *individualStandings;
    
    long packetNamesUsed;
    NSMutableDictionary *packetNames;
    
    long question_0_value;
    long question_1_value;
    long question_2_value;
    long question_3_value;
    BOOL question_0_selected;
    BOOL question_1_selected;
    BOOL question_2_selected;
    BOOL question_3_selected;
    
    long trackTossUpsHeardSetting;  // only 0/1 value
    long trackPowerNegStatsSetting;  // only 0/1 value
    BOOL trackLightRoundSetting;  // only 0/1 value
    
    BOOL trackBonusSetting;
    long autoTrackSetting; // value of bonus conversion radio buttons
    long sortMethodSetting; // value of sorting radio buttons
    long tossUpHeardSortSetting; // from sorting settings
    
    BOOL useDivisionsSetting;
    NSMutableArray *divisionList;
    
    // admin & ftp info
    // not used in this app. Storage of values for read/write of files to be compatible with Windows version
    NSString *tournamentName;
    NSString *hostName;
    NSString *userName;
    NSString *passwordName;
    NSString *directoryName;
    NSString *baseName;  // web reports base file name
    NSString *reportsBaseName; // full path extension + base report name
    BOOL pathsSetting;  // whether to use "/" in paths (combined with British report format for saving in file)
    
    // report settings
    BOOL roundReportSetting;
    BOOL teamStandingsReportSetting;
    BOOL individualStandingsReportSetting;
    BOOL scoreboardReportSetting;
    BOOL teamDetailsReportSetting;
    BOOL individualDetailsReportSetting;
    BOOL statKeyReportSetting;
    BOOL styleReportSetting;
    BOOL britishStyleReportSetting;
    
    BOOL allRoundsIncludedInReport;
    long minRoundIncludedInReport;
    long maxRoundIncludedInReport;
    long minRoundsAssigned;
    long maxRoundsAssigned;
    
    // report names
    NSString *roundReportName;
    NSString *teamStandingsReportName;
    NSString *individualStandingsReportName;
    NSString *scoreboardReportName;
    NSString *teamDetailsReportName;
    NSString *individualDetailsReportName;
    NSString *statKeyReportName;
    NSString *styleReportName;
    
    // warning settings
    BOOL warning_1_Setting; // repeated teams
    BOOL warning_2_Setting; // repeated player
    BOOL warning_3_Setting; // individual + bonus != total
    BOOL warning_4_Setting; // individual games played > 4
    BOOL warning_5_Setting; // points / bonus not between 0 & 30
    BOOL warning_6_Setting; // bonus points earned without being heard
    BOOL warning_7_Setting; // toss ups heard < 0
    
    // quick report printed
    long quickReportRequested;
    
    NSSegmentedControl *control;
    
    // merge files
    NSMutableArray *openDocumentsForMergeOrPublish;
    
    NSWindowController *temporaryWindowController;
}


@property (retain) NSString *tournamentFileName;

@property (assign) long lastSelectedView;
@property (retain) NSView *myTargetView;
@property (retain) NSViewController *myCurrentViewController;

@property (nonatomic, retain) NSMutableArray *teamList;
@property (assign) long defaultPlayersPerTeam;

@property (nonatomic, retain) NSMutableArray *gameList;
@property (nonatomic, retain) NSMutableArray *sortedGameList;  // used for reports

@property (retain) NSMutableArray *teamStandings;
@property (retain) NSArray *teamStandingsCopy;  // used for reference when sorting teamStandings mutableArray
@property (retain) NSMutableArray *individualStandings;

@property (assign) long packetNamesUsed; // > 0 if packet names used
@property (nonatomic, retain) NSMutableDictionary *packetNames;

@property (assign) long question_0_value;
@property (assign) long question_1_value;
@property (assign) long question_2_value;
@property (assign) long question_3_value;
@property (assign) BOOL question_0_selected;
@property (assign) BOOL question_1_selected;
@property (assign) BOOL question_2_selected;
@property (assign) BOOL question_3_selected;

@property (assign) long trackTossUpsHeardSetting;  // only 0/1 value
@property (assign) long trackPowerNegStatsSetting;  // only 0/1 value
@property (assign) BOOL trackLightRoundSetting;  // only 0/1 value

@property (assign) BOOL trackBonusSetting;
@property (assign) long autoTrackSetting; // value of bonus conversion radio buttons
@property (assign) long sortMethodSetting; // value of sorting radio buttons
@property (assign) long tossUpHeardSortSetting; // from sorting settings

@property (assign) BOOL useDivisionsSetting;
@property (nonatomic, retain) NSMutableArray *divisionList;

// admin & ftp info
@property (retain) NSString *tournamentName;
@property (retain) NSString *hostName;
@property (retain) NSString *userName;
@property (retain) NSString *passwordName;
@property (retain) NSString *directoryName;
@property (retain) NSString *baseName;  // web reports base file name
@property (retain) NSString *reportsBaseName; // full path extension + base report name
@property (assign) BOOL pathsSetting; // whether to use "/" in paths (combined with British report format for saving in file)

// report settings
@property (assign) BOOL roundReportSetting;
@property (assign) BOOL teamStandingsReportSetting;
@property (assign) BOOL individualStandingsReportSetting;
@property (assign) BOOL scoreboardReportSetting;
@property (assign) BOOL teamDetailsReportSetting;
@property (assign) BOOL individualDetailsReportSetting;
@property (assign) BOOL statKeyReportSetting;
@property (assign) BOOL styleReportSetting;
@property (assign) BOOL britishStyleReportSetting;

@property (assign) BOOL allRoundsIncludedInReport;
@property (assign) long minRoundIncludedInReport;
@property (assign) long maxRoundIncludedInReport;
@property (assign) long minRoundsAssigned;
@property (assign) long maxRoundsAssigned;


// report names
@property (retain) NSString *roundReportName;
@property (retain) NSString *teamStandingsReportName;
@property (retain) NSString *individualStandingsReportName;
@property (retain) NSString *scoreboardReportName;
@property (retain) NSString *teamDetailsReportName;
@property (retain) NSString *individualDetailsReportName;
@property (retain) NSString *statKeyReportName;
@property (retain) NSString *styleReportName;

// warning settings
@property (assign) BOOL warning_1_Setting;
@property (assign) BOOL warning_2_Setting;
@property (assign) BOOL warning_3_Setting;
@property (assign) BOOL warning_4_Setting;
@property (assign) BOOL warning_5_Setting;
@property (assign) BOOL warning_6_Setting;
@property (assign) BOOL warning_7_Setting;

@property (assign) long quickReportRequested;

// merge files
@property (retain) NSMutableArray *openDocumentsForMergeOrPublish;

@property (retain) NSWindowController *temporaryWindowController;


- (IBAction)viewSelectorChangeAction:(id)sender;

- (IBAction)mergeTournamentFileAction:(id)sender;

- (IBAction)importTeamInfoAction:(id)sender;
- (IBAction)gameSortOrderAction:(id)sender;

- (void)adjustTeamIndexesInGames;

// Reports
- (IBAction)createWebReports:(id)sender;
- (IBAction)quickPrintTeamReport:(id)sender;
- (IBAction)quickPrintIndividualReport:(id)sender;
- (IBAction)quickPrintGameReport:(id)sender;

// Server
//- (IBAction)startStopServer:(id)sender;
//- (IBAction)publishTournaments:(id)sender;
//- (IBAction)unpublishTournament:(id)sender;
//- (IBAction)unpublishAllTournaments:(id)sender;
//- (IBAction)importGame:(id)sender;
//- (IBAction)importAllGames:(id)sender;

//- (void)handleTournamentNameUpdate;
//- (void)importGameFile:(NSString *)fileName;

@end
