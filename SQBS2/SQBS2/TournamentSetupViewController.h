//
//  TournamentSetupViewController.h
//  SQBS
//
//  Created by Neil Smith on 11-10-27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TournamentViewController.h"

@interface TournamentSetupViewController : TournamentViewController
< NSTextDelegate, NSTextFieldDelegate, NSComboBoxCellDataSource, NSTableViewDataSource >
{    
    // use divisions items
    //IBOutlet NSButton *useDivisionsCheckbox;
    IBOutlet NSBox *divisionEntryBox;
    
    IBOutlet NSTextField *maxDefaultPlayers;
    
    IBOutlet NSTextView *divisionsListTextView;
    IBOutlet NSMatrix *bonusConversionTrackingRadioMatrix;
    
    IBOutlet NSTableView *teamTableView;
    IBOutlet NSTableColumn *divisionColumn;
    
    IBOutlet NSButton *deleteTeamButton;
    
    IBOutlet NSTextField *tournamentNameTextField;
    
    NSMutableArray *comboDivsionList;
    NSButton *addTeamButton;
}

@property (retain) NSMutableArray *comboDivsionList;
@property (assign) IBOutlet NSButton *addTeamButton;
@property (retain) IBOutlet NSTextField *tournamentNameTextField;

- (IBAction)checkBoxCheckedAction:(id)sender;
- (IBAction)questionValueChangedAction:(id)sender;
- (IBAction)useDivisionsCheckboxCheckedAction:(id)sender;
- (IBAction)bonusRadioSetChangedAction:(id)sender;

- (void)handleFileLoadedNotification:(NSNotification *)userinfo;

//- (IBAction)tableViewSelected:(id)sender;

- (IBAction)addTeam:(id)sender;
- (IBAction)deleteTeam:(id)sender;

@end
