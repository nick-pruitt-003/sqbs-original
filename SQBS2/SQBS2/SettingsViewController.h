//
//  SettingsViewController.h
//  SQBS
//
//  Created by Neil Smith on 11-12-19.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Constants.h"
#import "TournamentViewController.h"

@interface SettingsViewController : TournamentViewController
< NSTextFieldDelegate, NSTableViewDataSource >
{
    //IBOutlet Tournament *documentDelegate;
    IBOutlet NSSegmentedControl *settingsSelectorSegmentedControl;
    IBOutlet NSBox *generalSettingsBox;
    IBOutlet NSMatrix *roundsInReportRadioMatrix;
    IBOutlet NSTextField *minRoundIncludedTextField;
    IBOutlet NSTextField *maxRoundIncludedTextField;
    IBOutlet NSButton *autosaveCheckBox;
    IBOutlet NSTextField *autosaveTimeValueTextField;
    IBOutlet NSStepper *autosaveStepper;
    
    IBOutlet NSBox *reportsSettingsBox;
    IBOutlet NSButton *reportTeamStandCheckbox;
    IBOutlet NSTextField *reportTeamStandFileNameTextBox;
    IBOutlet NSButton *reportIndividualStandCheckbox;
    IBOutlet NSTextField *reportIndividualStandFileNameTextField;
    IBOutlet NSButton *reportScoreboardCheckbox;
    IBOutlet NSTextField *reportScoreboardFileNameTextField;
    IBOutlet NSButton *reportTeamDetailsCheckbox;
    IBOutlet NSTextField *reportTeamDetailsFileNameTextField;
    IBOutlet NSButton *reportIndividualDetailsCheckbox;
    IBOutlet NSTextField *reportIndividualDetailsFileNameTextField;
    IBOutlet NSButton *reportRoundCheckbox;
    IBOutlet NSTextField *reportRoundFileNameTextField;
    IBOutlet NSButton *reportStatKeyCheckbox;
    IBOutlet NSTextField *reportStatKeyFileNameTextField;
    IBOutlet NSButton *reportStyleCheckbox;
    IBOutlet NSTextField *reportStyleFileNameTextField;
    IBOutlet NSButton *reportBritishStyleCheckbox;
    
    IBOutlet NSBox *sortingSettingsBox;
    IBOutlet NSMatrix *sortingMethodRadioMatrix;
    IBOutlet NSButton *sortTUHButton;
    
    IBOutlet NSBox *warningsSettingsBox;
    IBOutlet NSButton *warnings1Checkbox;
    IBOutlet NSButton *warnings2Checkbox;
    IBOutlet NSButton *warnings3Checkbox;
    IBOutlet NSButton *warnings4Checkbox;
    IBOutlet NSButton *warnings5Checkbox;
    IBOutlet NSButton *warnings6Checkbox;
    IBOutlet NSButton *warnings7Checkbox;
    
    IBOutlet NSBox *packetsSettingsBox;
    IBOutlet NSTableView *packetNameTable;
    
    NSMutableArray *packetNameArray;
}

- (IBAction)settingsSelectorChangedAction:(id)sender;

- (IBAction)roundsRadioButtonAction:(id)sender;
- (IBAction)roundsMinMaxChangedAction:(id)sender;
- (IBAction)autosaveCheckBoxAction:(id)sender;
- (IBAction)autosaveValueChangedAction:(id)sender;
- (IBAction)autosaveStepperAction:(id)sender;

- (IBAction)sortingMethodRadioButtonAction:(id)sender;
- (IBAction)sortTUHCheckBoxAction:(id)sender;

- (IBAction)reportCheckboxChangeAction:(id)sender;
- (IBAction)reportNameChangedAction:(id)sender;

- (IBAction)warningsCheckboxChangeAction:(id)sender;

- (IBAction)tableViewSelected:(id)sender;

@end
