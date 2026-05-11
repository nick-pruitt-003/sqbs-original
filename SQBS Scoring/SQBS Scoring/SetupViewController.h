//
//  FirstViewController.h
//  SQBS Scoring
//
//  Created by Neil Smith on 12-02-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerBrowser.h"
#import "ServerBrowserDelegate.h"
#import "ServerDelegate.h"

@interface SetupViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, ServerBrowserDelegate, ServerDelegate>
{
    IBOutlet UITableView *importTournamentsTable;
    IBOutlet UITableView *localTournamentsSelectTable;
    IBOutlet UITableView *savedGamesTable;
    IBOutlet UIButton *tournamentSelectButton;
    
    IBOutlet UITableView *selectedTournamentViewTable;
    
    //NSMutableArray *tournamentsForImport;
    NSArray *tournamentsStored;
    
    NSArray *savedGames;
    
    NSArray *teamList;
    
    ServerBrowser *serverBrowser;
    NSMutableArray *serverList;
}
@property (retain, nonatomic) IBOutlet UITableView *importTournamentsTable;
@property (retain, nonatomic) IBOutlet UITableView *localTournamentsSelectTable;
@property (retain, nonatomic) IBOutlet UITableView *savedGamesTable;
@property (retain, nonatomic) IBOutlet UIButton *tournamentSelectButton;
@property (retain, nonatomic) IBOutlet UISegmentedControl *tableSelectSegmentedControl;
@property (retain, nonatomic) IBOutlet UIButton *editTableButton;

@property (retain, nonatomic) IBOutlet UITableView *selectedTournamentViewTable;

//@property (retain, nonatomic) NSMutableArray *tournamentsForImport;
@property (retain, nonatomic) NSArray *tournamentsStored;

@property (retain, nonatomic) NSArray *savedGames;

@property (retain, nonatomic) NSArray *teamList;

@property (retain, nonatomic) ServerBrowser *serverBrowser;
@property (retain, nonatomic) NSMutableArray *serverList;

- (IBAction)selectTournamentAction:(id)sender;
- (IBAction)tableSelectionValueChanged:(id)sender;
- (IBAction)editTableAction:(id)sender;

@end
