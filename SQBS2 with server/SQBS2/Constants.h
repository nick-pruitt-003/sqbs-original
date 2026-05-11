//
//  Constants.h
//  SQBS
//
//  Created by Neil Smith on 11-10-27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#define kLineEndCharacter @"\r\n"

#define kWindowsFileType @"public.data"
#define kOXsFileType @"com.deckdirector.tournamentosxfiletype"
//#define kScoringAppFileType @"com.deckdirector.scoringAppfiletype"
//#define kScoringAppFileExtension @"qzxs"

#define kBounceBackCodingMultiplier 10000

#define kMaxPlayersPerTeam 12  // # that can be listed on team
#define kMaxPlayersDisplayedPerTeam 8  // # that will be displayed for game stats input
#define kRecordsPerGame 129

#define kMaxDefaultPlayers 4 // first 4 players in game entry have games played set to 1
#define kMaxGamesPlayedPerPlayer 1

#define kTypicalTossupPerGame 10

#define kImportTeamInfoToolbarItemID     @"ImportTeamInfo"
#define kSortGamesToolbarItemID     @"SortGames"
#define kMaxToolbarItems    6  // don't forget any item spacers

#define kTournamentOptionQuestionCheckboxBaseTag 100
#define kTournamentOptionQuestionCheckbox_0_tag 100
#define kTournamentOptionQuestionCheckbox_1_tag 101
#define kTournamentOptionQuestionCheckbox_2_tag 102
#define kTournamentOptionQuestionCheckbox_3_tag 103

#define kTournamentOptionQuestionValueBaseTag 110
#define kTournamentOptionQuestionValue_0_tag 110
#define kTournamentOptionQuestionValue_1_tag 111
#define kTournamentOptionQuestionValue_2_tag 112
#define kTournamentOptionQuestionValue_3_tag 113

#define kTournamentOptionTrackTUHCheckboxTag 200
#define kTournamentOptionTrackPowerCheckboxTag 201
#define kTournamentOptionTrackLightRndCheckboxTag 202
#define kTournamentOptionUseDivisionCheckboxTag 203

#define kTournamentOptionAutomaticRadioButtonTag 300
#define kTournamentOptionManualRadioButtonTag 301
#define kTournamentOptionNoneRadioButtonTag 302
#define kTournamentOptionManualAHRadioButtonTag 303
#define kTournamentOptionManualBounceBackRadioButtonTag 304
#define kTournamentOptionAutoBounceBackRadioButtonTag 305
#define kTournamentOptionBonusRadioButtonTag 306

#define kTeamNameKey @"name"
#define kExhibitionTeamKey @"exhibition"
#define kDivisionKey @"division"
#define kPlayerBaseKey @"player"
#define kPlayerBaseKeyFormat @"player%i"
#define kPlayer1Key @"player1"
#define kPlayer2Key @"player2"
#define kPlayer3Key @"player3"
#define kPlayer4Key @"player4"
#define kPlayer5Key @"player5"
#define kPlayer6Key @"player6"
#define kPlayer7Key @"player7"
#define kPlayer8Key @"player8"
#define kPlayer9Key @"player9"
#define kPlayer10Key @"player10"
#define kPlayer11Key @"player11"
#define kPlayer12Key @"player12"
#define kOriginalTeamIndexKey @"origIndex"
#define kSortedTeamIndexKey @"sortIndex"
#define kDefaultNonSavedKeyCount 2 // origIndex and sortIndex - used to determine how to iterate over player keys

//#define kMissingValueValue @"-"  // used as place holder indicating no value for key (exhibition & packet name)

#define kPacketRoundBaseKey @"round"
#define kPacketRoundBaseKeyFormat @"round%i"
#define kPacketMissingPacketNameValue @"-"
#define kPacketSettingsRoundKey @"round"
#define kPacketSettingsPacketNameKey @"packetName"

//#define kTournamentFileLoadedNotification @"fileLoaded"
#define kTeamFileImportedNotification @"teamImported"
#define kTournamentReportGeneratedNotification @"reportGenerated"
#define kGamesSortedNotification @"gamesSorted"

#define kForfeitWinScore @"W"
#define kForfeitLossScore @"L"

#define kRoundReportName @"_rounds.html"
#define kTeamStandingsReportName @"_standings.html"
#define kIndividualStandingsReportName @"_individuals.html"
#define kScoreboardReportName @"_games.html"
#define kTeamDetailReportName @"_teamdetail.html"
#define kIndividualDetailReportName @"_playerdetail.html"
#define kStatKeyDetailReportName @"_statkey.html"
#define kStyleSheetName @"_style.css"

#define kSettingsRoundsInReportAllRadioTag 100
#define kSettingsRoundsInReportSomeRadioTag 101

#define kSettingSortRadioTagBase 400
#define kSettingSort_RP_RadioTag 401
#define kSettingSort_RHP_RadioTag 402
#define kSettingSort_RS_RadioTag 403
#define kSettingSort_RT_RadioTag 404
#define kSettingSort_RHT_RadioTag 405

#define kSettingsWarnings1Tag 501
#define kSettingsWarnings2Tag 502
#define kSettingsWarnings3Tag 503
#define kSettingsWarnings4Tag 504
#define kSettingsWarnings5Tag 505
#define kSettingsWarnings6Tag 506
#define kSettingsWarnings7Tag 507
#define kWarning4TitleFormat @"Games played by all players in a game exceeds %i. (W-4)"

#define kSettingsReportTeamStandingCheckBoxTag 201
#define kSettingsReportIndividualStandingCheckBoxTag 202
#define kSettingsReportScoreboardCheckBoxTag 203
#define kSettingsReportTeamDetailsCheckBoxTag 204
#define kSettingsReportIndividualDetailsCheckBoxTag 205
#define kSettingsReportRoundsCheckBoxTag 206
#define kSettingsReportStatKeyCheckBoxTag 207
#define kSettingsReportStyleCheckBoxTag 208
#define kSettingsReportBritishStyleCheckBoxTag 209
#define kSettingsReportTeamStandingFileNameTag 211
#define kSettingsReportIndividualStandingFileNameTag 212
#define kSettingsReportScoreboardFileNameTag 213
#define kSettingsReportTeamDetailsFileNameTag 214
#define kSettingsReportIndividualDetailsFileNameTag 215
#define kSettingsReportRoundsFileNameTag 216
#define kSettingsReportStatKeyFileNameTag 217
#define kSettingsReportStyleFileNameTag 218

#define kFileMenuNewTag 101
#define kFileMenuOpenTag 102
#define kFileImportTeamsTag 103
#define kFileMenuCloseTag 104
#define kFileMenuSaveTag 105
#define kFileMenuSaveAsTag 106
#define kFileMenuMergeFilesTag 109

#define kReportsMenuCreateWebTag 201
#define kReportsMenuPostResultsTag 202
#define kReportsMenuPrintTeamsTag 203
#define kReportsMenuPrintIndividualsTag 204
#define kReportsMenuPrintGamesTag 205

#define kServerMenuStartStopTag 501
#define kServerMenuPublishTag 502
#define kServerMenuUnpublishTag 503
#define kServerMenuImportTag 504

#define kSortGamesToolbarTag 301
#define kImportTeamsToolbarTag 5

// Server
//#define kBonjourServiceType @"_quiz._tcp."
//#define kFileServerSeparater @"%_%"
//
//#define kServerIdentityKey @"serverName"
//#define kServerProtocolVersion @"1.0"
//// message format
//#define kServerProtocolVersionElement 0
//#define kServerMessageTypeElement 1
//#define kServerMessageContentElement 2
//
//#define kServerRequestPublishedTournamentsMessage 100
//#define kServerResponsePublishedTournamentsMessage 101
//#define kServerRequestGameUploadMessage 200
//#define kServerAcknowledgeGameUploadMessage 201





enum    // question options
{
    kQuestionNumber_0 = 0,
    kQuestionNumber_1,
    kQuestionNumber_2,
    kQuestionNumber_3
};

enum	// tab choices
{
	kTournamentOptionsView = 0,
	kGameEntryView,
    kReportsView,
    kSettingsView
};

enum	// bonus conversion choices - SQBS autoTrack values
{
	kSQBS_Manual = 0,
	kSQBS_Automatic,
    kSQBS_Combo,
    kSQBS_Bounceback,
    kSQBS_AutoBounceback   // not supported by Windows version
};

enum	// report sorting
{
	kSort_RP = 1, // record / PPG
	kSort_RHP,  // record / h2h / PPG
    kSort_RS,  // record / strength
    kSort_RT,  // record / PPTH
    kSort_RHT  // record / h2h / PPTH
};

enum    // Game sort orders
{
    kGameSortByGame = 1,
    kGameSortByRound,
    kGameSortByRoundThenGame
};

enum    // types of Quick Reports
{
    kQuickReportNoReport = 0,
    kQuickReportTeam,
    kQuickReportIndividual,
    kQuickReportGame
};


enum	// settings tab choices
{
	kGeneralSettings = 0,
    kReportsSettings,
    kSortSettings,
    kWarningsSettings,
    kPacketsSettings
};

#define kGameEntryTeamSelectorTitle @"  Select Team"
#define kGameEntryPlayerSelectorTitle @"  Select Player"

#define kSetupDivisionSelectorTitle @"  Select Division"
//
//// SQBS Scoring User prefs key for scoring
//// Save info for restore if switching between views
//#define kLastSavedGame @"savedGame"
//#define kLastSavedGameTossupNumber @"tossupNumber"
////#define kPrefsTeamA_NameKey @"teamAName"
////#define kPrefsTeamA_PlayerNameGameListKey @"teamAGamePlayers"
//#define kPrefsTeamA_PlayerDisplayListKey @"teamAPlayerDisplay" // list of currently display players
////#define kPrefsTeamB_NameKey @"teamBName"
////#define kPrefsTeamB_PlayerNameGameListKey @"teamBGamePlayers"
//#define kPrefsTeamB_PlayerDisplayListKey @"teamBPlayerDisplay" // list of currently display players
//
//#define kImportedTournamentsDirectoryName @"importedTournaments"
//#define kSavedGamesDirectoryName @"savedGames"
//
//#define kPlayerTossupListSeparater @"#"
