//
//  SecondViewController.m
//  SQBS Scoring
//
//  Created by Neil Smith on 12-02-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ScoringViewController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "PointsResult.h"
#import "TossupResult.h"
#import "GameFileContents.h"


@interface  ScoringViewController() {
@private
    NSMutableArray *teamNameList;
    NSString *teamA_Name;
    NSString *teamB_Name;
    NSMutableArray *teamA_PlayerList;
    //    NSMutableArray *teamA_GamePlayerList;
    NSMutableArray *teamB_PlayerList;
    //    NSMutableArray *teamB_GamePlayerList;
    
    int gameRoundNumber;
    int currentTossupNumber;
    BOOL unrecordedPoints;
    TossupResult *currentTossup;
    
    GameFileContents *currentGameFile;
}

@property (retain, nonatomic) NSMutableArray *teamNameList;
@property (retain, nonatomic) NSString *teamA_Name;
@property (retain, nonatomic) NSString *teamB_Name;
@property (retain, nonatomic) NSMutableArray *teamA_PlayerList;
//@property (retain, nonatomic) NSMutableArray *teamA_GamePlayerList;
@property (retain, nonatomic) NSMutableArray *teamB_PlayerList;
//@property (retain, nonatomic) NSMutableArray *teamB_GamePlayerList;

@property (retain, nonatomic) TossupResult *currentTossup;

@property (retain, nonatomic) GameFileContents *currentGameFile;

@end


@implementation ScoringViewController
@synthesize configPlayerPickerView;
@synthesize roundNumberTextField;
@synthesize tossupLabel;
@synthesize forfeitButton;
@synthesize questionValueSegmentedControl;
@synthesize teamA_Label;
@synthesize teamA_PlayerSelectSegmentedControl;
@synthesize teamB_Label;
@synthesize teamB_PlayerSelectSegmentedControl;
@synthesize recordTossupButton;
@synthesize previousTossupButton;
@synthesize nextTossupButton;
@synthesize configButton;
@synthesize configView;
@synthesize configTeamSegmentedControl;
@synthesize configPlayerSelectSegmentedControl;
@synthesize configTeamPickerView;

@synthesize teamNameList;
@synthesize teamA_Name, teamB_Name;
@synthesize teamA_PlayerList, teamB_PlayerList;
//@synthesize teamA_GamePlayerList, teamB_GamePlayerList;

@synthesize currentTossup;

@synthesize currentGameFile;

#define kDefaultTeamALabel @"Team A"
#define kDefaultTeamBLabel @"Team B"
#define kSelectTeamTitle @"Select Team"
#define kSelectPlayerTitle @"Select Player"
#define kNoTeamSelectPlayerTitle @"Team not selected"

#define kRoundAndTossupNumberLabelFormatString @"Round: %i - Toss up: %i"
#define kTossupNumberLabelFormatString @"Toss up: %i"   // used if round == 0
#define kTitleSeatPrefix @"Seat "
#define kTitleSeatFormatString @"Seat %i"


#pragma mark -
#pragma mark utility methods

-(void)buildPlayerListFromTeamIndex:(int)teamIndex ForSide:(int)side {
    NSMutableArray *tempNameList = [NSMutableArray arrayWithCapacity:4];
    if ((teamIndex >= 0) && (teamIndex != NSNotFound)) {
        NSDictionary *theTeam = [[(AppDelegate *)[[UIApplication sharedApplication] delegate] selectedTeamList] objectAtIndex:teamIndex];
        for (int i = 1; i <= kMaxPlayersPerTeam; i++) {
            NSString *name = [theTeam objectForKey:[NSString stringWithFormat:kPlayerBaseKeyFormat, i]];
            if (name != nil) {
                [tempNameList addObject:name];
            }
        }
    }
    
    if (side == 0) {
        // team A
        [self setTeamA_PlayerList:tempNameList];
    } else {
        // team B
        [self setTeamB_PlayerList:tempNameList];
    }
    tempNameList = nil;
}

-(void)updateMainSegmentControlTitlesForSide:(int)side {
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    NSMutableArray *displayedPlayers;
    int lastUsedSegment = 1;
    if (side == 0) {
        displayedPlayers = [userPrefs objectForKey:kPrefsTeamA_PlayerDisplayListKey];
        for (NSString *name in displayedPlayers) {
            [teamA_PlayerSelectSegmentedControl setTitle:name forSegmentAtIndex:lastUsedSegment];
            // could be empty seat
            [teamA_PlayerSelectSegmentedControl setEnabled:([name hasPrefix:kTitleSeatPrefix]? NO :YES) forSegmentAtIndex:lastUsedSegment];
            lastUsedSegment++;
        }
        // disable any remaining segments
        for (int i = lastUsedSegment; i < [teamA_PlayerSelectSegmentedControl numberOfSegments]; i++) {
            [teamA_PlayerSelectSegmentedControl setEnabled:NO forSegmentAtIndex:i];
            [teamA_PlayerSelectSegmentedControl setTitle:[NSString stringWithFormat:kTitleSeatFormatString, i] forSegmentAtIndex:i];
        }
    } else {
        displayedPlayers = [userPrefs objectForKey:kPrefsTeamB_PlayerDisplayListKey];
        for (NSString *name in displayedPlayers) {
            [teamB_PlayerSelectSegmentedControl setTitle:name forSegmentAtIndex:lastUsedSegment];
            // could be empty seat
            [teamB_PlayerSelectSegmentedControl setEnabled:([name hasPrefix:kTitleSeatPrefix]? NO :YES) forSegmentAtIndex:lastUsedSegment];
            lastUsedSegment++;
        }
        // disable any remaining segments
        for (int i = lastUsedSegment; i < [teamB_PlayerSelectSegmentedControl numberOfSegments]; i++) {
            [teamB_PlayerSelectSegmentedControl setEnabled:NO forSegmentAtIndex:i];
            [teamB_PlayerSelectSegmentedControl setTitle:[NSString stringWithFormat:kTitleSeatFormatString, i] forSegmentAtIndex:i];
        }
    }
}

-(void)clearTeamInfoForSide:(int)side {
    if (side == 0) {
        [self setTeamA_PlayerList:[NSMutableArray arrayWithCapacity:3]];
        //[self setTeamA_GamePlayerList:[NSMutableArray arrayWithCapacity:3]];
        [self setTeamA_Name:nil];
        [teamA_Label setText:kDefaultTeamALabel];
        // removing player display list pref will cause segment control to go to default
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPrefsTeamA_PlayerDisplayListKey];
        [self updateMainSegmentControlTitlesForSide:0];
    } else {
        [self setTeamB_PlayerList:[NSMutableArray arrayWithCapacity:3]];
        //[self setTeamB_GamePlayerList:[NSMutableArray arrayWithCapacity:3]];
        [self setTeamB_Name:nil];
        [teamB_Label setText:kDefaultTeamBLabel];
        // removing player display list pref will cause segment control to go to default
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPrefsTeamB_PlayerDisplayListKey];
        [self updateMainSegmentControlTitlesForSide:1];
    }
    [configPlayerPickerView reloadComponent:0];
}

-(void)selectTeamIndex:(int)teamIndex ForSide:(int)side {
    // create player name list
    if ((teamIndex >= 0) && (teamIndex != NSNotFound)) {
        [self buildPlayerListFromTeamIndex:teamIndex ForSide:side];
        if (side == 0) {
            // team A
            [self setTeamA_Name:[teamNameList objectAtIndex:teamIndex]];
            [teamA_Label setText:[teamNameList objectAtIndex:teamIndex]];
        } else {
            // team B
            [self setTeamB_Name:[teamNameList objectAtIndex:teamIndex]];
            [teamB_Label setText:[teamNameList objectAtIndex:teamIndex]];
        }
        [configPlayerPickerView reloadComponent:0];
    }
}

-(void)updatePlayerSegmentControlTitle:(NSString *)title ForSegment:(int)segmentIndex ForSide:(int)side {
    if (side == 0) {
        [teamA_PlayerSelectSegmentedControl setTitle:title forSegmentAtIndex:segmentIndex];
        // disable control if empty seat
        [teamA_PlayerSelectSegmentedControl setEnabled:([title hasPrefix:kTitleSeatPrefix]? NO :YES) forSegmentAtIndex:segmentIndex];
    } else {
        // Team B / side 1
        [teamB_PlayerSelectSegmentedControl setTitle:title forSegmentAtIndex:segmentIndex];
        // disable control if empty seat
        [teamB_PlayerSelectSegmentedControl setEnabled:([title hasPrefix:kTitleSeatPrefix]? NO :YES) forSegmentAtIndex:segmentIndex];
    }
    
}

-(void)displayCurrentTossup {
    // reset selections
    [questionValueSegmentedControl setSelectedSegmentIndex:0];
    [teamA_PlayerSelectSegmentedControl setSelectedSegmentIndex:0];
    [teamB_PlayerSelectSegmentedControl setSelectedSegmentIndex:0];
    GameResult *theGame = [(AppDelegate *)[[UIApplication sharedApplication] delegate] currentGame];
    if ([[theGame tossupResults] count] >= currentTossupNumber) {
        [self setCurrentTossup:[[theGame tossupResults] objectAtIndex:(currentTossupNumber - 1)]];
        // display results
        if ([[currentTossup tossupPointsResults] count] > 0) {
            PointsResult *results = [[currentTossup tossupPointsResults] objectAtIndex:0];
            if ([[results teamName] isEqualToString:teamA_Name]) {
                // find player segment for team A
                for (int pIndex = 1; pIndex < [teamA_PlayerSelectSegmentedControl numberOfSegments]; pIndex++) {
                    if ([[teamA_PlayerSelectSegmentedControl titleForSegmentAtIndex:pIndex] isEqualToString:[results playerName]]) {
                        [teamA_PlayerSelectSegmentedControl setSelectedSegmentIndex:pIndex];
                        break;
                    }
                }
            } else {
                // find player segment for team B
                for (int pIndex = 1; pIndex < [teamB_PlayerSelectSegmentedControl numberOfSegments]; pIndex++) {
                    if ([[teamB_PlayerSelectSegmentedControl titleForSegmentAtIndex:pIndex] isEqualToString:[results playerName]]) {
                        [teamB_PlayerSelectSegmentedControl setSelectedSegmentIndex:pIndex];
                        break;
                    }
                }
            }
            // set question value// find player segment
            NSString *pointsSetting = [NSString stringWithFormat:@"%i", [results points]];
            for (int qIndex = 1; qIndex < [questionValueSegmentedControl numberOfSegments]; qIndex++) {
                if ([[questionValueSegmentedControl titleForSegmentAtIndex:qIndex] isEqualToString:pointsSetting]) {
                    [questionValueSegmentedControl setSelectedSegmentIndex:qIndex];
                    break;
                }
            }
        }
    }
}

-(void)setupForNewGame {
    // init current game file
    GameFileContents *newGameFile = [[GameFileContents alloc] init];
    // zero out existing game
    GameResult *newGame = [[GameResult alloc] init];
    [newGame setTournamentName:[(AppDelegate *)[[UIApplication sharedApplication] delegate] selectedTournamentName]];
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setCurrentGame:newGame];
    [newGameFile setTheGame:newGame];
    [newGame release];
    
    [self setCurrentGameFile:newGameFile];
    [newGameFile release];
    
    currentTossupNumber = 1;
    [tossupLabel setText:[NSString stringWithFormat:kTossupNumberLabelFormatString, currentTossupNumber]];
    unrecordedPoints = NO;
    // new toss up
    TossupResult *temp = [[TossupResult alloc] initWith:currentTossupNumber PointsResults:[NSMutableArray arrayWithCapacity:1]];
    [self setCurrentTossup:temp];
    [temp release];
    
    // player select team labels
    [self setTeamA_Name:nil];
    [self setTeamB_Name:nil];
    
    [teamA_Label setText:kDefaultTeamALabel];
    [teamB_Label setText:kDefaultTeamBLabel];
    
    // update titles of player segment controls
    [self updateMainSegmentControlTitlesForSide:0];
    [self updateMainSegmentControlTitlesForSide:1];
    
    // enable config
    [self configAction:configButton];
    if (gameRoundNumber > 0) {
        // change tossup label to include round info
        [tossupLabel setText:[NSString stringWithFormat:kRoundAndTossupNumberLabelFormatString, gameRoundNumber, currentTossupNumber]];
    }
}

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Scoring";
        self.tabBarItem.image = [UIImage imageNamed:@"scoringTab"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    gameRoundNumber = 0;
    currentTossupNumber = 1;
    unrecordedPoints = NO;
    
    // init game
    GameResult *tempGame = [[GameResult alloc] init];
    [tempGame setTournamentName:[(AppDelegate *)[[UIApplication sharedApplication] delegate] selectedTournamentName]];
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setCurrentGame:tempGame];
    [tempGame release];
    
    // load question values
    int qSegment = 1;
    for (NSNumber *value in [(AppDelegate *)[[UIApplication sharedApplication] delegate] selectedTournamentQuestionValues]) {
        if ([value intValue] > 100) {
            // not used
            [questionValueSegmentedControl setTitle:0 forSegmentAtIndex:qSegment];
            [questionValueSegmentedControl setEnabled:NO forSegmentAtIndex:qSegment];
        } else {
            [questionValueSegmentedControl setTitle:[value stringValue] forSegmentAtIndex:qSegment];
            [questionValueSegmentedControl setEnabled:YES forSegmentAtIndex:qSegment];
        }
        qSegment++;
    }
    
    // load team names
    NSMutableArray *tempNameList = [NSMutableArray arrayWithCapacity:10];
    for (NSDictionary *aTeam in [(AppDelegate *)[[UIApplication sharedApplication] delegate] selectedTeamList]) {
        [tempNameList addObject:[aTeam objectForKey:kTeamNameKey]];
    }
    [self setTeamNameList:tempNameList];
    tempNameList = nil;
    [self setTeamA_PlayerList:[NSMutableArray arrayWithCapacity:3]];
    [self setTeamB_PlayerList:[NSMutableArray arrayWithCapacity:3]];
//    [self setTeamA_GamePlayerList:[NSMutableArray arrayWithCapacity:3]];
//    [self setTeamB_GamePlayerList:[NSMutableArray arrayWithCapacity:3]];
    
    // adjust segment control font size
    // only in iOS 5 - setting attributes appears to reset widths
    NSDictionary *attrDict = [NSDictionary dictionaryWithObject:[UIFont boldSystemFontOfSize:14] forKey:UITextAttributeFont];
    [teamA_PlayerSelectSegmentedControl setTitleTextAttributes:attrDict forState:UIControlStateNormal];
    [teamA_PlayerSelectSegmentedControl setWidth:68.0 forSegmentAtIndex:0];
    [teamB_PlayerSelectSegmentedControl setTitleTextAttributes:attrDict forState:UIControlStateNormal];
    [teamB_PlayerSelectSegmentedControl setWidth:68.0 forSegmentAtIndex:0];
}

- (void)viewDidUnload
{
    [self setTossupLabel:nil];
    [self setQuestionValueSegmentedControl:nil];
    [self setTeamA_Label:nil];
    [self setTeamA_PlayerSelectSegmentedControl:nil];
    [self setTeamB_Label:nil];
    [self setTeamB_PlayerSelectSegmentedControl:nil];
    [self setRecordTossupButton:nil];
    [self setPreviousTossupButton:nil];
    [self setNextTossupButton:nil];
    [self setConfigTeamSegmentedControl:nil];
    [self setConfigView:nil];
    [self setConfigPlayerSelectSegmentedControl:nil];
    [self setConfigTeamPickerView:nil];
    [self setConfigPlayerPickerView:nil];
    [self setForfeitButton:nil];
    
    [self setTeamNameList:nil];
    [self setTeamA_Name:nil];
    [self setTeamB_Name:nil];
    [self setTeamA_PlayerList:nil];
    [self setTeamB_PlayerList:nil];
//    [self setTeamA_GamePlayerList:nil];
//    [self setTeamB_GamePlayerList:nil];
    
    [self setRoundNumberTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    currentTossupNumber = 1;
    unrecordedPoints = NO;
    
    [self setTeamA_Name:nil];
    [self setTeamB_Name:nil];
    
    // restore basic setting
    NSString *savedGameFileName = [[NSUserDefaults standardUserDefaults] stringForKey:kLastSavedGame];
    if (savedGameFileName != nil) {
        // retrieve saved game file
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePath = [[rootPath stringByAppendingPathComponent:kSavedGamesDirectoryName] stringByAppendingPathComponent:savedGameFileName];
        
        GameFileContents *aGameFile = nil;
        @try {
            aGameFile = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        }
        @catch (NSException *exception) {
            aGameFile = nil;
        }
        
        [self setCurrentGameFile:aGameFile];
        if (currentGameFile != nil) {
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] setCurrentGame:[currentGameFile theGame]];
            if ([currentGameFile theGame] != nil) {
                // if 10 tossups, show 10th tossup - normal game, otherwise create new tossup
                currentTossupNumber = ([[[currentGameFile theGame] tossupResults] count]);
                if (currentTossupNumber == kTypicalTossupPerGame) {
                    [self setCurrentTossup:[[[currentGameFile theGame] tossupResults] objectAtIndex:currentTossupNumber]];
                } else {
                    currentTossupNumber++;
                    // new toss up
                    TossupResult *temp = [[TossupResult alloc] initWith:currentTossupNumber PointsResults:[NSMutableArray arrayWithCapacity:1]];
                    [self setCurrentTossup:temp];
                    [temp release];
                }
                
                // team names
                [self setTeamA_Name:[[currentGameFile theGame] teamA]];
                [self setTeamB_Name:[[currentGameFile theGame] teamB]];
                // team player lists
                if (teamA_Name != nil) {
                    [self buildPlayerListFromTeamIndex:[teamNameList indexOfObject:teamA_Name] ForSide:0];
                    //[self setTeamA_GamePlayerList:[userPrefs objectForKey:kPrefsTeamA_PlayerNameGameListKey]];
                }
                if (teamB_Name != nil) {
                    [self buildPlayerListFromTeamIndex:[teamNameList indexOfObject:teamB_Name] ForSide:1];
                    //[self setTeamB_GamePlayerList:[userPrefs objectForKey:kPrefsTeamB_PlayerNameGameListKey]];
                }
            }
        }
        // if no team name, remove pref key as it won't be valid
        if (teamA_Name == nil) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPrefsTeamA_PlayerDisplayListKey];
        }
        if (teamB_Name == nil) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPrefsTeamB_PlayerDisplayListKey];
        }
        
    } else {
        [self setCurrentGameFile:nil];
        // new toss up
        TossupResult *temp = [[TossupResult alloc] initWith:currentTossupNumber PointsResults:[NSMutableArray arrayWithCapacity:1]];
        [self setCurrentTossup:temp];
        [temp release];
    }
    
    if (gameRoundNumber > 0) {
        // change tossup label to include round info
        [tossupLabel setText:[NSString stringWithFormat:kRoundAndTossupNumberLabelFormatString, gameRoundNumber, currentTossupNumber]];
    } else {
        [tossupLabel setText:[NSString stringWithFormat:kTossupNumberLabelFormatString, currentTossupNumber]];
    }
    
    // player select team labels
    [teamA_Label setText:(teamA_Name != nil)?teamA_Name : kDefaultTeamALabel];
    [teamB_Label setText:(teamB_Name != nil)?teamB_Name : kDefaultTeamBLabel];
    
    // update titles of player segment controls
    [self updateMainSegmentControlTitlesForSide:0];
    [self updateMainSegmentControlTitlesForSide:1];
    
    // if not configured, disable scoring and enable config
    if ([[teamA_Label text] isEqualToString:kDefaultTeamALabel] && [[teamB_Label text] isEqualToString:kDefaultTeamBLabel]) {
        [self configAction:configButton];
    } else {
        [self displayCurrentTossup];
    }
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // save current tossup data
    if ([recordTossupButton isEnabled] && (currentTossup != nil) && ([[currentTossup tossupPointsResults] count] > 0)) {
        [self nextTossupAction:nil];
    }
    if ([(AppDelegate *)[[UIApplication sharedApplication] delegate] currentGame] != nil) {
        // save current game for restore
        if (currentGameFile == nil) {
            GameFileContents *theGameFile = [[GameFileContents alloc] init];
            [self setCurrentGameFile:theGameFile];
            [theGameFile release];
        }
        [currentGameFile setTheGame:[(AppDelegate *)[[UIApplication sharedApplication] delegate] currentGame]];
        [currentGameFile updateLastSavedDate];
        NSString *archiveFileName = [currentGameFile archiveName];
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePath = [[rootPath stringByAppendingPathComponent:kSavedGamesDirectoryName] stringByAppendingPathComponent:archiveFileName];
        DebugLog(@"viewWillDisappear - %@", filePath);
        //        NSData *gameFileData = [NSKeyedArchiver archivedDataWithRootObject:currentGameFile];
//        NSMutableData *gameFileData = [NSMutableData data];
//        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:gameFileData];
//        [archiver encodeRootObject:currentGameFile];
//        [archiver finishEncoding];
//        [archiver release];
        
        BOOL archiverSuccess = NO;
        
        @try {
            archiverSuccess = [NSKeyedArchiver archiveRootObject:currentGameFile toFile:filePath];
        }
        @catch (NSException *exception) {
            archiverSuccess = NO;
        }
        
        if (archiverSuccess) {
            //if (gameFileData != nil) {
            //[gameFileData writeToFile:filePath atomically:YES];
            NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
            // same file name in users prefs
            [userPrefs setObject:archiveFileName forKey:kLastSavedGame];
           
            if (teamA_Name != nil) {
                NSMutableArray *titles = [NSMutableArray arrayWithCapacity:4];
                for (int i = 1; i < [teamA_PlayerSelectSegmentedControl numberOfSegments]; i++) {
                    [titles addObject:[teamA_PlayerSelectSegmentedControl titleForSegmentAtIndex:i]];
                }
                [userPrefs setObject:titles forKey:kPrefsTeamA_PlayerDisplayListKey];
            } else {
                [userPrefs removeObjectForKey:kPrefsTeamA_PlayerDisplayListKey];
            }
            if (teamB_Name != nil) {
                NSMutableArray *titles = [NSMutableArray arrayWithCapacity:4];
                for (int i = 1; i < [teamB_PlayerSelectSegmentedControl numberOfSegments]; i++) {
                    [titles addObject:[teamB_PlayerSelectSegmentedControl titleForSegmentAtIndex:i]];
                }
                [userPrefs setObject:titles forKey:kPrefsTeamB_PlayerDisplayListKey];
            } else {
                [userPrefs removeObjectForKey:kPrefsTeamB_PlayerDisplayListKey];
            }
        } else {
            // can't do anything if it is not saved
            DebugLog(@"viewWillDisappear - game file not saved");
            NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
            [userPrefs removeObjectForKey:kLastSavedGame];
            [userPrefs removeObjectForKey:kPrefsTeamA_PlayerDisplayListKey];
            [userPrefs removeObjectForKey:kPrefsTeamB_PlayerDisplayListKey];
        }
    } else {
        // make sure any existing prefs are removed
        NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
        [userPrefs removeObjectForKey:kLastSavedGame];
        [userPrefs removeObjectForKey:kPrefsTeamA_PlayerDisplayListKey];
        [userPrefs removeObjectForKey:kPrefsTeamB_PlayerDisplayListKey];
    }
    
	[super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)dealloc {
    [tossupLabel release];
    [questionValueSegmentedControl release];
    [teamA_Label release];
    [teamA_PlayerSelectSegmentedControl release];
    [teamB_Label release];
    [teamB_PlayerSelectSegmentedControl release];
    [recordTossupButton release];
    [previousTossupButton release];
    [nextTossupButton release];
    [configTeamSegmentedControl release];
    [configView release];
    [configPlayerSelectSegmentedControl release];
    [configTeamPickerView release];
    [configPlayerPickerView release];
    [forfeitButton release];
    [roundNumberTextField release];
    [super dealloc];
}

UISlider *test;

#pragma mark -
#pragma mark Action methods

- (IBAction)questionValueChanged:(id)sender {
    // enable record if question & player selected
    if ([questionValueSegmentedControl selectedSegmentIndex] > 0) {
        if (([teamA_PlayerSelectSegmentedControl selectedSegmentIndex] > 0)
            || ([teamB_PlayerSelectSegmentedControl selectedSegmentIndex] > 0)) {
            [recordTossupButton setEnabled:YES];
            unrecordedPoints = YES;
            return;
        }
    }
    [recordTossupButton setEnabled:NO];
}

- (IBAction)forfeitAction:(id)sender {
    GameResult *theGame = [(AppDelegate *)[[UIApplication sharedApplication] delegate] currentGame];
    [theGame setForfeit:YES];
    // clear any existing results ??
}

- (IBAction)configAction:(id)sender {
    if ([[[(UIButton *)sender titleLabel] text] isEqualToString:@"Config"]) {
        // change button title
        [(UIButton *)sender setTitle:@"Done" forState:UIControlStateNormal];
        // reveal view, disable scoring button
        [configView setHidden:NO];
        [forfeitButton setEnabled:NO];
        [recordTossupButton setEnabled:NO];
        [nextTossupButton setEnabled:NO];
        [previousTossupButton setEnabled:NO];
        [questionValueSegmentedControl setEnabled:NO];
        [teamA_PlayerSelectSegmentedControl setEnabled:NO];
        [teamB_PlayerSelectSegmentedControl setEnabled:NO];
        [configTeamPickerView reloadComponent:0];
        [configPlayerPickerView reloadComponent:0];
    } else {
        // configuration complete, check that no duplicate players in seats for each team
        // Team A
        for (int i = 1; i < [teamA_PlayerSelectSegmentedControl numberOfSegments]; i++) {
            NSString *baseName = [teamA_PlayerSelectSegmentedControl titleForSegmentAtIndex:i];
            for (int j = i + 1; j < [teamA_PlayerSelectSegmentedControl numberOfSegments]; j++) {
                if ([[teamA_PlayerSelectSegmentedControl titleForSegmentAtIndex:j] isEqualToString:baseName]) {
                    // put up alert and stop
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Same player duplicated" message:[NSString stringWithFormat:@"Player '%@' on team '%@' is assigned twice.", baseName, teamA_Name] delegate:self cancelButtonTitle:@"OK, will fix." otherButtonTitles:nil, nil];
                    [alert show];
                    [alert release];
                    return;
                }
            }
        }
        
        // Team B
        for (int i = 1; i < [teamB_PlayerSelectSegmentedControl numberOfSegments]; i++) {
            NSString *baseName = [teamB_PlayerSelectSegmentedControl titleForSegmentAtIndex:i];
            for (int j = i + 1; j < [teamB_PlayerSelectSegmentedControl numberOfSegments]; j++) {
                if ([[teamB_PlayerSelectSegmentedControl titleForSegmentAtIndex:j] isEqualToString:baseName]) {
                    // put up alert and stop
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Same player duplicated" message:[NSString stringWithFormat:@"Player '%@' on team '%@' is assigned twice.", baseName, teamA_Name] delegate:self cancelButtonTitle:@"OK, will fix." otherButtonTitles:nil, nil];
                    [alert show];
                    [alert release];
                    return;
                }
            }
        }
        // save info
        GameResult *theGame = [(AppDelegate *)[[UIApplication sharedApplication] delegate] currentGame];
        gameRoundNumber = [[roundNumberTextField text] intValue];
        [theGame setRoundNumber:gameRoundNumber];
        [theGame setTeamA:teamA_Name];
        [theGame setTeamB:teamB_Name];
        [theGame setTeamAPlayers:teamA_PlayerList];
        [theGame setTeamBPlayers:teamB_PlayerList];
        // init tossup arrays
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:4];
        for (NSString *playerName in teamA_PlayerList) {
            [temp addObject:@""];
        }
        [theGame setTossupPlayersA:temp];
        temp = [NSMutableArray arrayWithCapacity:4];
        for (NSString *playerName in teamB_PlayerList) {
            [temp addObject:@""];
        }
        [theGame setTossupPlayersB:temp];
        
        // all okay, change button title
        [(UIButton *)sender setTitle:@"Config" forState:UIControlStateNormal];
        // hide view, enable scoring button
        [configView setHidden:YES];
        [forfeitButton setEnabled:YES];
        [recordTossupButton setEnabled:YES];
        [nextTossupButton setEnabled:YES];
        [previousTossupButton setEnabled:YES];  // depends on current toss-up??
        [questionValueSegmentedControl setEnabled:YES];
        [teamA_PlayerSelectSegmentedControl setEnabled:YES];
        [teamB_PlayerSelectSegmentedControl setEnabled:YES];
    }
}

- (IBAction)teamA_PlayerSelectValueChanged:(id)sender {
    // disable other team if selected player
    if (([teamA_PlayerSelectSegmentedControl selectedSegmentIndex] > 0) && ([teamB_PlayerSelectSegmentedControl selectedSegmentIndex] > 0)) {
        [teamB_PlayerSelectSegmentedControl setSelectedSegmentIndex:0];
    }
    // enable record if question & player selected
    if ([questionValueSegmentedControl selectedSegmentIndex] > 0) {
        if (([teamA_PlayerSelectSegmentedControl selectedSegmentIndex] > 0)
            || ([teamB_PlayerSelectSegmentedControl selectedSegmentIndex] > 0)) {
            [recordTossupButton setEnabled:YES];
            unrecordedPoints = YES;
            return;
        }
    }
    [recordTossupButton setEnabled:NO];
}

- (IBAction)teamB_PlayerSelectValueChanged:(id)sender {
    // disable other team if selected player
    if (([teamA_PlayerSelectSegmentedControl selectedSegmentIndex] > 0) && ([teamB_PlayerSelectSegmentedControl selectedSegmentIndex] > 0)) {
        [teamA_PlayerSelectSegmentedControl setSelectedSegmentIndex:0];
    }
    // enable record if question & player selected
    if ([questionValueSegmentedControl selectedSegmentIndex] > 0) {
        if (([teamA_PlayerSelectSegmentedControl selectedSegmentIndex] > 0)
            || ([teamB_PlayerSelectSegmentedControl selectedSegmentIndex] > 0)) {
            [recordTossupButton setEnabled:YES];
            unrecordedPoints = YES;
            return;
        }
    }
    [recordTossupButton setEnabled:NO];
}

- (IBAction)recordPointsAction:(id)sender {
    NSString *teamName = nil;
    NSString *playerName = nil;
    if ([teamA_PlayerSelectSegmentedControl selectedSegmentIndex] > 0) {
        teamName = [teamA_Label text];
        int playerIndex = [teamA_PlayerSelectSegmentedControl selectedSegmentIndex];
        playerName = [teamA_PlayerSelectSegmentedControl titleForSegmentAtIndex:playerIndex];
    }
    if ([teamB_PlayerSelectSegmentedControl selectedSegmentIndex] > 0) {
        teamName = [teamB_Label text];
        int playerIndex = [teamB_PlayerSelectSegmentedControl selectedSegmentIndex];
        playerName = [teamB_PlayerSelectSegmentedControl titleForSegmentAtIndex:playerIndex];
    }
    if ((teamName == nil) || (playerName == nil)) {
        // alert ??
        NSLog(@"Cannot record points. Team: %@, Player: %@", teamName, playerName);
        return;
    }
//    if (currentTossup == nil) {
//        TossupResult *temp = [[TossupResult alloc] initWith:currentTossupNumber PointsResults:[NSMutableArray arrayWithCapacity:1]];
//        [self setCurrentTossup:temp];
//        [temp release];
//    }
    int qIndex = [questionValueSegmentedControl selectedSegmentIndex];
    PointsResult *results = [[PointsResult alloc] initWithTeam:teamName ForPlayer:playerName WithPoints:[[questionValueSegmentedControl titleForSegmentAtIndex:qIndex] intValue]];
    [[currentTossup tossupPointsResults] addObject:results];
    [results release];
    // reset selections
    [questionValueSegmentedControl setSelectedSegmentIndex:0];
    [teamA_PlayerSelectSegmentedControl setSelectedSegmentIndex:0];
    [teamB_PlayerSelectSegmentedControl setSelectedSegmentIndex:0];
    unrecordedPoints = NO;
}

- (IBAction)previousTossupAction:(id)sender {
    GameResult *theGame = [(AppDelegate *)[[UIApplication sharedApplication] delegate] currentGame];
    // add tossup entry
    if (unrecordedPoints) {
        [self recordPointsAction:recordTossupButton];
        // capture players for this toss up
        for (int i = 1; i < [teamA_PlayerSelectSegmentedControl numberOfSegments]; i++) {
            int pIndex = [teamA_PlayerList indexOfObject:[teamA_PlayerSelectSegmentedControl titleForSegmentAtIndex:i]];
            if (pIndex != NSNotFound) {
                NSString *tossupString = [[[theGame tossupPlayersA] objectAtIndex:pIndex] stringByAppendingFormat:@"%i%@", currentTossupNumber, kPlayerTossupListSeparater];
                [[theGame tossupPlayersA] replaceObjectAtIndex:pIndex withObject:tossupString];
            }
        }
        for (int i = 1; i < [teamB_PlayerSelectSegmentedControl numberOfSegments]; i++) {
            int pIndex = [teamB_PlayerList indexOfObject:[teamB_PlayerSelectSegmentedControl titleForSegmentAtIndex:i]];
            if (pIndex != NSNotFound) {
                NSString *tossupString = [[[theGame tossupPlayersB] objectAtIndex:pIndex] stringByAppendingFormat:@"%i%@", currentTossupNumber, kPlayerTossupListSeparater];
                [[theGame tossupPlayersB] replaceObjectAtIndex:pIndex withObject:tossupString];
            }
        }
        
        [recordTossupButton setEnabled:NO];
    }
    
    currentTossupNumber--;
    if (currentTossupNumber < 1) {
        currentTossupNumber = 1;
        if (gameRoundNumber > 0) {
            // change tossup label to include round info
            [tossupLabel setText:[NSString stringWithFormat:kRoundAndTossupNumberLabelFormatString, gameRoundNumber, currentTossupNumber]];
        } else {
            [tossupLabel setText:[NSString stringWithFormat:kTossupNumberLabelFormatString, currentTossupNumber]];
        }
        [previousTossupButton setEnabled:NO];
        return;
    }
    if (gameRoundNumber > 0) {
        // change tossup label to include round info
        [tossupLabel setText:[NSString stringWithFormat:kRoundAndTossupNumberLabelFormatString, gameRoundNumber, currentTossupNumber]];
    } else {
        [tossupLabel setText:[NSString stringWithFormat:kTossupNumberLabelFormatString, currentTossupNumber]];
    }
    
    [self displayCurrentTossup];
}

- (IBAction)nextTossupAction:(id)sender {
    GameResult *theGame = [(AppDelegate *)[[UIApplication sharedApplication] delegate] currentGame];
    // add tossup entry
    if (unrecordedPoints) {
        [self recordPointsAction:recordTossupButton];
        // capture players for this toss up
        for (int i = 1; i < [teamA_PlayerSelectSegmentedControl numberOfSegments]; i++) {
            int pIndex = [teamA_PlayerList indexOfObject:[teamA_PlayerSelectSegmentedControl titleForSegmentAtIndex:i]];
            if (pIndex != NSNotFound) {
                NSString *tossupString = [[[theGame tossupPlayersA] objectAtIndex:pIndex] stringByAppendingFormat:@"%i%@", currentTossupNumber, kPlayerTossupListSeparater];
                [[theGame tossupPlayersA] replaceObjectAtIndex:pIndex withObject:tossupString];
            }
        }
        for (int i = 1; i < [teamB_PlayerSelectSegmentedControl numberOfSegments]; i++) {
            int pIndex = [teamB_PlayerList indexOfObject:[teamB_PlayerSelectSegmentedControl titleForSegmentAtIndex:i]];
            if (pIndex != NSNotFound) {
                NSString *tossupString = [[[theGame tossupPlayersB] objectAtIndex:pIndex] stringByAppendingFormat:@"%i%@", currentTossupNumber, kPlayerTossupListSeparater];
                [[theGame tossupPlayersB] replaceObjectAtIndex:pIndex withObject:tossupString];
            }
        }
        
        [recordTossupButton setEnabled:NO];
        [previousTossupButton setEnabled:YES];
    }
    
    [[theGame tossupResults] addObject:currentTossup];
    currentTossupNumber++;
    if (gameRoundNumber > 0) {
        // change tossup label to include round info
        [tossupLabel setText:[NSString stringWithFormat:kRoundAndTossupNumberLabelFormatString, gameRoundNumber, currentTossupNumber]];
    } else {
        [tossupLabel setText:[NSString stringWithFormat:kTossupNumberLabelFormatString, currentTossupNumber]];
    }
    
    if ([[theGame tossupResults] count] >= currentTossupNumber) {
        [self displayCurrentTossup];
    } else {
        // new toss up
        TossupResult *temp = [[TossupResult alloc] initWith:currentTossupNumber PointsResults:[NSMutableArray arrayWithCapacity:1]];
        [self setCurrentTossup:temp];
        [temp release];
        // reset selections
        [questionValueSegmentedControl setSelectedSegmentIndex:0];
        [teamA_PlayerSelectSegmentedControl setSelectedSegmentIndex:0];
        [teamB_PlayerSelectSegmentedControl setSelectedSegmentIndex:0];
    }
}

- (IBAction)configTeamValueChanged:(id)sender {
    // team selection changed, update picker to show name, or "Select Team, if not assigned
    NSString *teamName;
    if ([configTeamSegmentedControl selectedSegmentIndex] == 0) {
        teamName = teamA_Name;
    } else {
        teamName = teamB_Name;
    }
    // show team if selected
    if (teamName != nil) {
        [configTeamPickerView selectRow:([teamNameList indexOfObject:teamName] + 1) inComponent:0 animated:NO];
    } else {
        [configTeamPickerView selectRow:0 inComponent:0 animated:NO];
    }
    [configPlayerPickerView reloadComponent:0];
    // reset config player selector to seat 1
    [configPlayerSelectSegmentedControl setSelectedSegmentIndex:0];
    [self configPlayerValueChanged:configPlayerSelectSegmentedControl];
}

- (IBAction)configPlayerValueChanged:(id)sender {
    // player selection changed, update picker to show name, or "Select Player, if not assigned
    int seat = [configPlayerSelectSegmentedControl selectedSegmentIndex] + 1;
    NSString *name;
    int pickerRow = 0;
    if ([configTeamSegmentedControl selectedSegmentIndex] == 0) {
        // Team A
        name = [teamA_PlayerSelectSegmentedControl titleForSegmentAtIndex:seat];
        if (![name hasPrefix:@"Seat "]) {
            pickerRow = [teamA_PlayerList indexOfObject:name] + 1;
        }
    } else {
        // Team B
        name = [teamB_PlayerSelectSegmentedControl titleForSegmentAtIndex:seat];
        if (![name hasPrefix:@"Seat "]) {
            pickerRow = [teamB_PlayerList indexOfObject:name] + 1;
        }
    }
    [configPlayerPickerView selectRow:pickerRow inComponent:0 animated:NO];
}

-(void)saveCurrentGameAndCreateNew {
    if (currentGameFile == nil) {
        GameFileContents *theGameFile = [[GameFileContents alloc] init];
        [self setCurrentGameFile:theGameFile];
        [theGameFile release];
    } 
    GameResult *gameToSave = [(AppDelegate *)[[UIApplication sharedApplication] delegate] currentGame];
    [currentGameFile setTheGame:gameToSave];
    [currentGameFile updateLastSavedDate];
    NSString *archiveFileName = [currentGameFile archiveName];
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [[rootPath stringByAppendingPathComponent:kSavedGamesDirectoryName] stringByAppendingPathComponent:archiveFileName];
    UIAlertView *alert = nil;
    NSData *gameFileData = [NSKeyedArchiver archivedDataWithRootObject:currentGameFile];
    if (gameFileData != nil) {
        [gameFileData writeToFile:filePath atomically:YES];
        alert = [[UIAlertView alloc] initWithTitle:@"Game saved." message:[NSString stringWithFormat:@"Game file name: %@", archiveFileName] delegate:nil cancelButtonTitle:@"" otherButtonTitles:@"OK", nil];
    } else {
        alert = [[UIAlertView alloc] initWithTitle:@"Save failed!." message:[NSString stringWithFormat:@"Game with file name: %@, could not be saved", archiveFileName] delegate:nil cancelButtonTitle:@"" otherButtonTitles:@"OK", nil];
    }
    [alert show];
    [alert release];
    [self setupForNewGame];
}

- (IBAction)newGameAction:(id)sender {
    GameResult *theGame = [(AppDelegate *)[[UIApplication sharedApplication] delegate] currentGame];
    if (theGame != nil) {
        if (([[theGame tossupResults] count] > 0) || ([theGame forfeit])) {
            // prompt to save currentGame
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Save current game?" message:@"" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Save", nil];
            //[alert setAlertViewStyle:UIAlertViewStylePlainTextInput];  // iOS 5
            [alert show];
            [alert release];
        }
    }
    [self setupForNewGame];
}

#pragma mark -
#pragma mark UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // need to check for original alert if more than 1
    
    // New Game Alert
    if (buttonIndex == [alertView cancelButtonIndex]) {
        return;
    }
    [self saveCurrentGameAndCreateNew];
}

#pragma mark -
#pragma mark UIPickerViewDataSource methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == configTeamPickerView) {
        return [teamNameList count] + 1;
    }
    // player picker
    if ([configTeamSegmentedControl selectedSegmentIndex] == 0) {
        // team A
        if (teamA_Name != nil) {
            return [teamA_PlayerList count];
        } else {
            return 1;
        }
    } else {
        // team B
        if (teamB_Name != nil) {
            return [teamB_PlayerList count];
        } else {
            return 1;
        }
    }
    return 0;
}

#pragma mark -
#pragma mark UIPickerViewDelegate methods

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == configTeamPickerView) {
        if (row == 0) {
            return kSelectTeamTitle;
        } 
        return [teamNameList objectAtIndex:(row - 1)]; 
    }
    // player picker
    if ([configTeamSegmentedControl selectedSegmentIndex] == 0) {
        // team A
        if (teamA_Name != nil) {
            if (row == 0) {
                return kSelectPlayerTitle;
            }
            return [teamA_PlayerList objectAtIndex:(row - 1)];
        } else {
            return kNoTeamSelectPlayerTitle;
        }
    } else {
        // team B
        if (teamB_Name != nil) {
            if (row == 0) {
                return kSelectPlayerTitle;
            }
            return [teamB_PlayerList objectAtIndex:(row - 1)];
        } else {
            return kNoTeamSelectPlayerTitle;
        }
    }
    return @"--";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == configTeamPickerView) {
        // check if clearing
        if (row == 0) {
            [self clearTeamInfoForSide:0];
            return;
        }
        NSString *selectedTeamName = [teamNameList objectAtIndex:(row - 1)];
        // which side
        if ([configTeamSegmentedControl selectedSegmentIndex] == 0) {
            // side A
            // check that name is not same as side B
            if (teamB_Name != nil) {
                if ([selectedTeamName isEqualToString:teamB_Name]) {
                    // don't allow
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Duplicate teams"
                                                                    message:[NSString stringWithFormat:@"Team '%@' already selected for other side", selectedTeamName]
                                                                   delegate:nil
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:@"OK", nil];
                    [alert show];
                    [alert release];
                    [configTeamPickerView selectRow:0 inComponent:0 animated:NO];
                    return;
                }
            }
            [self selectTeamIndex:(row - 1) ForSide:0];
            return;
        } else {
            // side B
            // check that name is not same as side A
            if (teamA_Name != nil) {
                if ([selectedTeamName isEqualToString:teamA_Name]) {
                    // don't allow
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Duplicate teams"
                                                                    message:[NSString stringWithFormat:@"Team '%@' already selected for other side", selectedTeamName]
                                                                   delegate:nil
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:@"OK", nil];
                    [alert show];
                    [alert release];
                    [configTeamPickerView selectRow:0 inComponent:0 animated:NO];
                    return;
                }
            }
            [self selectTeamIndex:(row - 1) ForSide:1];
            return;
        }
    }
    // player picker
    int seat = [configPlayerSelectSegmentedControl selectedSegmentIndex] + 1;
    // check if clearing
    if (row == 0) {
        [self updatePlayerSegmentControlTitle:[NSString stringWithFormat:kTitleSeatFormatString, seat] ForSegment:seat ForSide:[configTeamSegmentedControl selectedSegmentIndex]];
        return;
    }
    // set title
    NSString *playerName;
    // get player name selected and make sure not in use. ?? check when "Done"
    if ([configTeamSegmentedControl selectedSegmentIndex] == 0) {
        playerName = [teamA_PlayerList objectAtIndex:(row - 1)];
    } else {
        playerName = [teamB_PlayerList objectAtIndex:(row - 1)];
    }
    [self updatePlayerSegmentControlTitle:playerName ForSegment:seat ForSide:[configTeamSegmentedControl selectedSegmentIndex]];
    // advance to next empty seat by default
    int nextConfigIndex = (seat - 1);
    if ([configTeamSegmentedControl selectedSegmentIndex] == 0) {
        // team A
        // find next empty seat
        for (int i = (seat + 1); i < [teamA_PlayerSelectSegmentedControl numberOfSegments]; i++) {
            if ([[teamA_PlayerSelectSegmentedControl titleForSegmentAtIndex:i] hasPrefix:kTitleSeatPrefix]) {
                nextConfigIndex = (i - 1); // player selector doesn't have "None" segment
                break;
            }
        }
    } else {
        // team B
        // find next empty seat
        for (int i = (seat + 1); i < [teamB_PlayerSelectSegmentedControl numberOfSegments]; i++) {
            if ([[teamB_PlayerSelectSegmentedControl titleForSegmentAtIndex:i] hasPrefix:kTitleSeatPrefix]) {
                nextConfigIndex = (i - 1); // player selector doesn't have "None" segment
                break;
            }
        }
    }
    if (nextConfigIndex < [configPlayerSelectSegmentedControl numberOfSegments]) {
        [configPlayerSelectSegmentedControl setSelectedSegmentIndex:nextConfigIndex];
    }
    
}

@end
