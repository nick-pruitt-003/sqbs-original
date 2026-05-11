//
//  FirstViewController.m
//  SQBS Scoring
//
//  Created by Neil Smith on 12-02-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SetupViewController.h"
#import "Constants.h"
#import "Server.h"
#import "AppDelegate.h"
#import "PublishedTournament.h"
#import "GameFileContents.h"

@implementation SetupViewController
@synthesize importTournamentsTable;
@synthesize localTournamentsSelectTable;
@synthesize savedGamesTable;
@synthesize tournamentSelectButton;
@synthesize tableSelectSegmentedControl;
@synthesize editTableButton;
@synthesize selectedTournamentViewTable;

//@synthesize tournamentsForImport;
@synthesize tournamentsStored;
@synthesize savedGames;
@synthesize teamList;

@synthesize serverBrowser;
@synthesize serverList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title =  @"Setup";
        self.tabBarItem.image = [UIImage imageNamed:@"setupTab"];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(void)findAvailableTournamentFiles {
    // get list of files in document folder
	NSError *error;
	NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    rootPath = [rootPath stringByAppendingPathComponent:kImportedTournamentsDirectoryName];
    NSArray *filesFound = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:rootPath error:&error];
    if (filesFound == nil) {
        DebugLog(@"findAvailableTournamentFiles - error: %@", [error localizedFailureReason]);
    } else {
        // check for okay files - most for simulator due to .DSStore files existing
        NSMutableArray *okayFiles = [NSMutableArray arrayWithCapacity:3];
        for (NSString *aFile in filesFound) {
            NSRange foundRange = [aFile rangeOfString:kFileServerSeparater];
            //DebugLog(@"aFile: %@, location: %i, length: %i", aFile, foundRange.location, foundRange.length);
            if (foundRange.location != NSNotFound) {
                [okayFiles addObject:aFile];
            }
        }
        //DebugLog(@"findAvailableTournamentFiles - okay: %@", okayFiles);
        [okayFiles sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        filesFound = [NSArray arrayWithArray:okayFiles];
    }
    DebugLog(@"findAvailableTournamentFiles - found: %@", filesFound);
    [self setTournamentsStored:filesFound];
}

-(void)findSavedGames {
    // get list of files in document folder
	NSError *error;
	NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    // games are in directory
    rootPath = [rootPath stringByAppendingPathComponent:kSavedGamesDirectoryName];
    NSArray *filesFound = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:rootPath error:&error];
    NSMutableArray *foundGames = [NSMutableArray arrayWithCapacity:1];
    if (filesFound == nil) {
        DebugLog(@"findSavedGames - error: %@", [error localizedFailureReason]);
    } else {
        // check for okay files - most for simulator due to .DSStore files existing
        NSMutableArray *okayFiles = [NSMutableArray arrayWithCapacity:3];
        for (NSString *aFile in filesFound) {
            NSRange foundRange = [aFile rangeOfString:@"Game_"];
            //DebugLog(@"aFile: %@, location: %i, length: %i", aFile, foundRange.location, foundRange.length);
            if (foundRange.location != NSNotFound) {
                [okayFiles addObject:aFile];
            }
        }
        // for each file, unarchive and add to array
        for (NSString *fileName in okayFiles) {
            DebugLog(@"findSavedGames - gamefile: %@", fileName);

            GameFileContents *aGame = nil;
            @try {
                aGame = [NSKeyedUnarchiver unarchiveObjectWithFile:[rootPath stringByAppendingPathComponent:fileName]];
            }
            @catch (NSException *exception) {
                aGame = nil;
            }
            if (aGame != nil) {
                [foundGames addObject:aGame];
            }
            aGame = nil;
        }
    }
    [self setSavedGames:foundGames];
    foundGames = nil;
}

#pragma mark - 
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //[self setTournamentsStored:[NSMutableArray arrayWithCapacity:3]];
    //[self setServerList:[NSMutableArray arrayWithCapacity:3]];
    //[self setTournamentsForImport:[NSMutableArray arrayWithCapacity:3]];
}

- (void)viewDidUnload
{
    [self setImportTournamentsTable:nil];
    [self setTournamentSelectButton:nil];
    [self setSelectedTournamentViewTable:nil];
    //[self setTournamentsForImport:nil];
    [self setTournamentsStored:nil];
    if (serverBrowser) {
        [serverBrowser setDelegate:nil];
    }
    [self setServerBrowser:nil];
    [self setServerList:nil];
    
    [self setTableSelectSegmentedControl:nil];
    [self setEditTableButton:nil];
    [self setLocalTournamentsSelectTable:nil];
    [self setSavedGamesTable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // start server browser
    ServerBrowser *temp = [[ServerBrowser alloc] init];
    [self setServerBrowser:temp];
    [temp release];
    [serverBrowser setDelegate:self];
    [self setServerList:[NSMutableArray arrayWithCapacity:2]];
    [serverBrowser start];
    
    //[self findAvailableTournamentFiles];
    [importTournamentsTable reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Stop browsing
    [serverBrowser stop];
    [serverBrowser setDelegate:nil];
    [self setServerBrowser:nil];
    
    // shutdown current servers
    while ([serverList count] > 0) {
        [[serverList objectAtIndex:0] stop];
        [serverList removeObjectAtIndex:0];
    }
    [self setServerList:nil];
    //[self setTournamentsForImport:nil];
    
    // clear file list
    [self setTournamentsStored:nil];
    
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
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
    [importTournamentsTable release];
    [tournamentSelectButton release];
    [selectedTournamentViewTable release];
    [tableSelectSegmentedControl release];
    [editTableButton release];
    [localTournamentsSelectTable release];
    [savedGamesTable release];
    [savedGames release];
    [tournamentsStored release];
    [super dealloc];
}

- (IBAction)selectTournamentAction:(id)sender {
    NSIndexPath *selection;
    PublishedTournament *selectedTournament = nil;  // for analyse check, should not be nil be use.
    NSString *localFileName = nil;
    if ([tableSelectSegmentedControl selectedSegmentIndex] == 0) {
        // import table
        selection = [importTournamentsTable indexPathForSelectedRow];
        if (selection != nil) {
            selectedTournament = [[(Server *)[serverList objectAtIndex:[selection section]] publishedTournaments] objectAtIndex:[selection row]];
            localFileName = [NSString stringWithFormat:@"%@%@%@", [selectedTournament tournamentName], kFileServerSeparater, [[(Server *)[serverList objectAtIndex:[selection section]] theNetService] name]];
        }
    } else {
        selection = [localTournamentsSelectTable indexPathForSelectedRow];
        if (selection != nil) {
            // open file
            localFileName = [tournamentsStored objectAtIndex:[selection row]];
             NSString *filePath = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:kImportedTournamentsDirectoryName] stringByAppendingPathComponent:localFileName];
            selectedTournament = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        }
    }
    if (selectedTournament != nil) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate setSelectedTournamentFileName:localFileName];
        [appDelegate setSelectedTeamList:[selectedTournament teamList]];
        [appDelegate setSelectedTournamentName:[selectedTournament tournamentName]];
        [appDelegate setSelectedTournamentQuestionValues:[selectedTournament questionValues]];
        [self setTeamList:[selectedTournament teamList]];
        [selectedTournamentViewTable setHidden:NO];
        [selectedTournamentViewTable reloadData];
    }
    
}

- (IBAction)tableSelectionValueChanged:(id)sender {
    switch ([tableSelectSegmentedControl selectedSegmentIndex]) {
        case 0: { // SQBS server table selected
            [editTableButton setEnabled:NO];
            [editTableButton setHidden:YES];
            [importTournamentsTable setHidden:NO];
            [localTournamentsSelectTable setHidden:YES];
            [savedGamesTable setHidden:YES];
            // in case editing was on
            if ([localTournamentsSelectTable isEditing]) {
                [self editTableAction:editTableButton];
            }
            if ([savedGamesTable isEditing]) {
                [self editTableAction:editTableButton];
            }
            [importTournamentsTable reloadData];
            break;
        }
        case 1: { // Stored tournaments table selected
            [editTableButton setEnabled:YES];
            [editTableButton setHidden:NO];
            [importTournamentsTable setHidden:YES];
            [localTournamentsSelectTable setHidden:NO];
            [savedGamesTable setHidden:YES];
            // in case editing was on
            if ([savedGamesTable isEditing]) {
                [self editTableAction:editTableButton];
            }
            // refresh list
            [self findAvailableTournamentFiles];
            DebugLog(@"tableSectionValueChanged - storedTournaments: %@", tournamentsStored);
            [localTournamentsSelectTable reloadData];
            break;
        }
        case 2: { // Scored games table selected
            [editTableButton setEnabled:YES];
            [editTableButton setHidden:NO];
            [importTournamentsTable setHidden:YES];
            [localTournamentsSelectTable setHidden:YES];
            [savedGamesTable setHidden:NO];
            // in case editing was on
            if ([localTournamentsSelectTable isEditing]) {
                [self editTableAction:editTableButton];
            }
            // refresh list
            [self findSavedGames];
            [savedGamesTable reloadData];
            break;
        }
            
        default:
            break;
    }
    
    // disable import button until selection
    [tournamentSelectButton setEnabled:NO];
}

- (IBAction)editTableAction:(id)sender {
    if ([[[(UIButton *)sender titleLabel] text] isEqualToString:@"Delete"]) {
        // start editting
        [(UIButton *)sender setTitle:@"Done" forState:UIControlStateNormal];
        [self setEditing:YES animated:YES];
    } else {
        // stop editting
        [(UIButton *)sender setTitle:@"Delete" forState:UIControlStateNormal];
        [self setEditing:NO animated:YES];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    switch ([tableSelectSegmentedControl selectedSegmentIndex]) {
        case 1: { // locally stored tournaments
            [localTournamentsSelectTable setEditing:editing animated:animated];
            break;
        }
        case 2: { // saved games
            [savedGamesTable setEditing:editing animated:animated];
            break;
        }
            
        default:
            break;
    }
    
}

#pragma mark -
#pragma mark ServerBrowserDelegate Method Implementations

- (void)updateServerAdded:(NSNetService *)netService {
    DebugLog(@"updateServerAdded - servers: %@", netService);
    // add server to list, when connection completes request for published tournaments sent
    Server *tempServer = [[Server alloc] initWithNetService:netService];
    [tempServer setDelegate:self];
    if ([tempServer start]) {
        [serverList addObject:tempServer];
    }
    [tempServer release];
}

- (void)updateServerRemoved:(NSNetService *)netService {
    DebugLog(@"updateServerRemoved - servers: %@", netService);
    // find server and delete
    for (int i = 0; i < [serverList count]; i++) {
        Server *aServer = [serverList objectAtIndex:i];
        DebugLog(@"updateServerRemoved - comparing to: %@", [aServer theNetService]);
        if ([[aServer theNetService] isEqual:netService]) {
            [aServer stop];
            [serverList removeObject:aServer];
            DebugLog(@"updateServerRemoved - server removed new server list: %@", serverList);
            break;
        }
    }
    // update table
    [self handlePublishedTournamentsUpdate]; 
}

#pragma mark -
#pragma mark ServerDelegate Method Implementations

- (void)handlePublishedTournamentsUpdate {
    if ([tableSelectSegmentedControl selectedSegmentIndex] == 0) {
        // if server table showing, update table
        DebugLog(@"handlePublishedTournamentUpdate - count: %i", [serverList count]);
        [importTournamentsTable reloadData];
    }
}

-(void)handleGameUploadAck:(NSString *)gameFileName {
    // update upload date
    // find game file
    NSString *filePath = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:kSavedGamesDirectoryName] stringByAppendingPathComponent:gameFileName];
    GameFileContents *uploadedGame = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    if (uploadedGame != nil) {
        // update last upload date and re-save
        [uploadedGame updateLastUploadedDate];
        [NSKeyedArchiver archiveRootObject:uploadedGame toFile:filePath];
        [self findSavedGames];
        [savedGamesTable reloadData];
    }
}

- (void)serverFailed:(Server *)server {
    NSNetService *netService = [server theNetService];
    [self updateServerRemoved:netService];
}

- (void)serverConnectionComplete:(Server *)server {
    DebugLog(@"serverConnectionComplete");
    // ready to send request for published tournaments
    NSArray *packet = [NSArray arrayWithObjects:kServerProtocolVersion, [NSNumber numberWithInt:kServerRequestPublishedTournamentsMessage], nil];
    [server sendPacket:packet];
    packet = nil;
}

#pragma mark -
#pragma mark UITableDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == importTournamentsTable) {
        if ([serverList count] < 1) {
            return 1;
        }
        return [serverList count];
    }
    // local tournaments and saved games tables use 1 section
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == importTournamentsTable) {
        // server list
        if ([serverList count] < 1) {
            // no servers found, put up message
            return 1;
        }
        if ([[[serverList objectAtIndex:section] publishedTournaments] count] < 1) {
            // no published tournaments, put up message
            return 1;
        }
        return [[[serverList objectAtIndex:section] publishedTournaments] count];
    }
    if (tableView == localTournamentsSelectTable) {
        // available list
        if ([tournamentsStored count] < 1) {
            return 1;
        }
        return [tournamentsStored count];
    }
    if (tableView == selectedTournamentViewTable) {
        if ((teamList == nil) || ([teamList count] < 1) ) {
            return 1;
        }
        return [teamList count];
    }
    if (tableView == savedGamesTable) {
        if ((savedGames == nil) || ([savedGames count] < 1) ) {
            return 1;
        }
        return [savedGames count];
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == importTournamentsTable) {
        if ([serverList count] == 0) {
            return @"No SQBS Tournament servers found.";
        }
        NSDate *timeStamp = [(Server *)[serverList objectAtIndex:section] lastResponse];
        NSString *title = [NSString stringWithFormat:@"%@ (%@)", 
                           [[(Server *)[serverList objectAtIndex:section] theNetService] name],
                           [NSDateFormatter localizedStringFromDate:timeStamp dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterMediumStyle]];
        return title;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == importTournamentsTable) {
        // server list
        static NSString *CellIdentifier = @"importSelectCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        if ([serverList count] < 1) {
            // no servers found, put up message
            [cell.textLabel setText:@"Check WiFi connectivity and status of SQBS Tournament Server"];
            return cell;
        }
        if ([[[serverList objectAtIndex:indexPath.section] publishedTournaments] count] < 1) {
            // no published tournaments, put up message
            [cell.textLabel setText:@"No SQBS Tournaments found. Check that files have been published."];
            return cell;
        }
        NSMutableArray *list = [[serverList objectAtIndex:indexPath.section] publishedTournaments];
        [cell.textLabel setText:[(PublishedTournament *)[list objectAtIndex:indexPath.row] tournamentName]];
        [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
        return cell;
    }
    if (tableView == localTournamentsSelectTable) {
        // local files
        static NSString *CellIdentifier = @"localSelectCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        }
        
        if ([tournamentsStored count] < 1) {
            [cell.textLabel setText:@"No Tournament Files found"];
            return cell;
        }
        NSArray *components = [[[tournamentsStored objectAtIndex:indexPath.row] lastPathComponent] componentsSeparatedByString:kFileServerSeparater];
        [cell.textLabel setText:[components objectAtIndex:0]];
        [cell.detailTextLabel setText:[NSString stringWithFormat:@"Downloaded from: %@", [components objectAtIndex:1]]];
        return cell;
    }
    if (tableView == selectedTournamentViewTable) {
        static NSString *CellIdentifier = @"displayTournamentCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        if ((teamList == nil) || ([teamList count] < 1) ) {
            [cell.textLabel setText:@""];
            return cell;
        }
        
        NSDictionary *theTeam = [teamList objectAtIndex:indexPath.row];
        [cell.textLabel setText:[theTeam objectForKey:kTeamNameKey]];
        return cell;
    }
    if (tableView == savedGamesTable) {
        static NSString *CellIdentifier = @"displayTournamentCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        }
        
        if ((savedGames == nil) || ([savedGames count] < 1) ) {
            [cell.textLabel setText:@"no saved games"];
            return cell;
        }
        
        GameFileContents *thisGame = [savedGames objectAtIndex:indexPath.row];
        int tossupCount = 0;
        if ([thisGame theGame] != nil) {
            tossupCount = [[[thisGame theGame] tossupResults] count];
        }
        NSString *teamA_Name = [[thisGame theGame] teamA];
        if (teamA_Name == nil) {
            teamA_Name = @"-";
        }
        NSString *teamB_Name = [[thisGame theGame] teamB];
        if (teamB_Name == nil) {
            teamB_Name = @"-";
        }
        
        [cell.textLabel setText:[NSString stringWithFormat:@"%@ vs. %@ - %i tossups recorded", teamA_Name, teamB_Name, tossupCount]];
        [cell.detailTextLabel setText:[NSString stringWithFormat:@"saved: %@, uploaded: %@", [thisGame lastSavedDate], [thisGame lastUploadDate]]];
        [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tournamentSelectButton setEnabled:YES];
}

PublishedTournament *selectedTournament;
NSString *selectedServerName;
NSString *selectedSavedGame;

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if (tableView == importTournamentsTable) {
        // copy to documents directory
        [selectedTournament release];
        [selectedServerName release];
        [selectedSavedGame release]; selectedSavedGame = nil; // only way alert delegate knows which table in action
        selectedTournament = [[[(Server *)[serverList objectAtIndex:indexPath.row] publishedTournaments] objectAtIndex:indexPath.section] retain];
        selectedServerName = [[[(Server *)[serverList objectAtIndex:indexPath.row] theNetService] name] copy];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Save tournament file?"
                                                        message:[NSString stringWithFormat:@"Save tournament '%@' from server '%@'?", [selectedTournament tournamentName], selectedServerName]
                                                       delegate:self 
                                              cancelButtonTitle:nil 
                                              otherButtonTitles:@"Save", nil];
        [alert show];
        [alert release];
    }
    if (tableView == savedGamesTable) {
        // upload game file
        UIAlertView *alert = nil;
        DebugLog(@"accessoryButton - serverList: %@", serverList);
        if ([serverList count] < 1) {
            // no servers
            alert = [[UIAlertView alloc] initWithTitle:@"Upload saved game"
                                               message:@"No servers found. Check WiFi or match sure SQBS server is enabled."
                                              delegate:nil 
                                     cancelButtonTitle:nil 
                                     otherButtonTitles:@"OK", nil];
            [alert show];
            [alert release];
            return;
        }
        // typically only 1 server
        [selectedTournament release]; selectedTournament = nil; // only way alert delegate knows which table in action
        [selectedServerName release]; selectedServerName = nil; // only way alert delegate knows which table in action
        [selectedSavedGame release];
        selectedSavedGame = [[(GameFileContents *)[savedGames objectAtIndex:indexPath.row] archiveName] retain];
        if ([serverList count] == 1) {
            alert = [[UIAlertView alloc] initWithTitle:@"Upload saved game?"
                                               message:[NSString stringWithFormat:@"Upload saved game '%@' to '%@'?", selectedSavedGame, [[(Server *)[serverList objectAtIndex:0] theNetService] name]]
                                              delegate:self 
                                     cancelButtonTitle:nil 
                                     otherButtonTitles:@"Upload", nil];
            [alert show];
            [alert release];
        } else {
            // add alert to select server from list
            alert = [[UIAlertView alloc] initWithTitle:@"Upload saved game"
                                                   message:@"Multiple servers. Don't know which server to use."
                                                  delegate:nil 
                                         cancelButtonTitle:nil 
                                         otherButtonTitles:@"OK", nil];
            [alert show];
            [alert release];
            [selectedSavedGame release];
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If row is deleted, remove file from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSError *error;
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *fileName = nil;
        if (tv == localTournamentsSelectTable) {
            rootPath = [rootPath stringByAppendingPathComponent:kImportedTournamentsDirectoryName];
            fileName = [tournamentsStored objectAtIndex:indexPath.row];
            DebugLog(@"commitEditingStyle - fileName: %@, rootPath: %@", fileName, rootPath);
        }
        if (tv == savedGamesTable) {
            rootPath = [rootPath stringByAppendingPathComponent:kSavedGamesDirectoryName];
            fileName = [(GameFileContents *)[savedGames objectAtIndex:indexPath.row] archiveName];
            DebugLog(@"commitEditingStyle - fileName: %@, rootPath: %@", fileName, rootPath);
        }
        rootPath = [rootPath stringByAppendingPathComponent:fileName];
        DebugLog(@"commitEditingStyle - Deleting: %@", rootPath);
        if ([[NSFileManager defaultManager] fileExistsAtPath:rootPath]) {
            // file exist, delete
            if (![[NSFileManager defaultManager] removeItemAtPath:rootPath error:&error]) {
                // put up alert
                DebugLog(@"commitEditingStyle - Delete failed: %@", [error description]);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete failed" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
                return;
            }
        } else {
            DebugLog(@"commitEditingStyle - file not found: %@", fileName);
            return;
        }
        
        // refresh list
        if (tv == importTournamentsTable) {
            [self findAvailableTournamentFiles];
            [importTournamentsTable reloadData];
        }
        if (tv == savedGamesTable) {
            [self findSavedGames];
            [savedGamesTable reloadData];
        }
        
        [tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark -
#pragma mark UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [alertView cancelButtonIndex]) {
        // cancelled
        [selectedTournament release]; selectedTournament = nil;
        [selectedServerName release]; selectedServerName = nil;
        [selectedSavedGame release]; selectedSavedGame = nil;
        return;
    }
    // go ahead with save / upload
    NSString *rootPath = nil;
    NSString *filePath = nil;
    if (selectedSavedGame == nil) {
        // save tournament file
        rootPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:kImportedTournamentsDirectoryName];
        filePath = [rootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@%@", [selectedTournament tournamentName], kFileServerSeparater, selectedServerName]];
        DebugLog(@"clickedButtonAtIndex - filePath: %@", filePath);
        //    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        //        // alert ??
        //    }
        if (![NSKeyedArchiver archiveRootObject:selectedTournament toFile:filePath]) {
            DebugLog(@"clickButtonAtIndex - failed to save tournament");
        }
        [selectedTournament release]; selectedTournament = nil;
        [selectedServerName release]; selectedServerName = nil;
    } else {
        // upload game
        filePath = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:kSavedGamesDirectoryName] stringByAppendingPathComponent:selectedSavedGame];
        DebugLog(@"clickedButtonAtIndex - filePath: %@", filePath);
        GameFileContents *gameForUpload = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        if ((gameForUpload != nil) && ([serverList count] > 0)) {
            NSArray *packet = [NSArray arrayWithObjects:kServerProtocolVersion, [NSNumber numberWithInt:kServerRequestGameUploadMessage], gameForUpload, nil];
            [(Server *)[serverList objectAtIndex:0] sendPacket:packet];
            packet = nil;
        } else {
            DebugLog(@"clickButtonAtIndex - failed to unarchive game");
        }
        [selectedSavedGame release]; selectedSavedGame = nil;
    }
	
    filePath = nil;
    rootPath = nil;
}

@end
