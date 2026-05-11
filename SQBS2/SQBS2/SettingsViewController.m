//
//  SettingsViewController.m
//  SQBS
//
//  Created by Neil Smith on 11-12-19.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"

@implementation SettingsViewController

//#define kPlaceHolderPacketName @"        "

#pragma mark local methods

long currentClickedRow;  // for packet name setting

- (void)loadSettingsFromDelegate {
    // general
    if ([documentDelegate allRoundsIncludedInReport]) {
        [roundsInReportRadioMatrix selectCellWithTag:kSettingsRoundsInReportAllRadioTag];
    } else {
        [roundsInReportRadioMatrix selectCellWithTag:kSettingsRoundsInReportSomeRadioTag];
    }
    // minRoundsIncluded TextField is greater of minRoundsAssigned & minRoundsIncludedInReport
    // minRoundsIncludedInReport is not saved to file so defaults to minRoundsAssigned when file loaded
    long value = fmax([documentDelegate minRoundsAssigned], [documentDelegate minRoundIncludedInReport]);
    [minRoundIncludedTextField setIntegerValue:value];
    // formatters for max round field set to range of min & max rounds assigned
    [[maxRoundIncludedTextField formatter] setMinimum:[NSNumber numberWithDouble:[documentDelegate minRoundsAssigned]]];
    [[maxRoundIncludedTextField formatter] setMaximum:[NSNumber numberWithDouble:[documentDelegate maxRoundsAssigned]]];
    // maxRoundsIncluded TextField is lesser of maxRoundsAssigned & maxRoundsIncludedInReport
    // maxRoundsIncludedInReport is not saved to file so defaults to maxRoundsAssigned when file loaded
    value = fmin([documentDelegate maxRoundsAssigned], [documentDelegate maxRoundIncludedInReport]);
    [maxRoundIncludedTextField setIntegerValue:value];
    
    NSTimeInterval autosaveFreq = [[NSDocumentController sharedDocumentController] autosavingDelay];
    [autosaveCheckBox setState:(autosaveFreq > 0)];
    if (autosaveFreq > 0) {
        long updateFreq = (long)fmax(60, autosaveFreq / 60);
        [autosaveTimeValueTextField setIntegerValue:updateFreq];
        [autosaveStepper setIntegerValue:updateFreq];
    }
    
    // report
    [reportTeamStandCheckbox setState:[documentDelegate teamStandingsReportSetting]];
    [reportTeamStandFileNameTextBox setStringValue:[documentDelegate teamStandingsReportName]];
    [reportIndividualStandCheckbox setState:[documentDelegate individualStandingsReportSetting]];
    [reportIndividualStandFileNameTextField setStringValue:[documentDelegate individualStandingsReportName]];
    [reportScoreboardCheckbox setState:[documentDelegate scoreboardReportSetting]];
    [reportScoreboardFileNameTextField setStringValue:[documentDelegate scoreboardReportName]];
    [reportTeamDetailsCheckbox setState:[documentDelegate teamDetailsReportSetting]];
    [reportTeamDetailsFileNameTextField setStringValue:[documentDelegate teamDetailsReportName]];
    [reportIndividualDetailsCheckbox setState:[documentDelegate individualDetailsReportSetting]];
    [reportIndividualDetailsFileNameTextField setStringValue:[documentDelegate individualDetailsReportName]];
    [reportRoundCheckbox setState:[documentDelegate roundReportSetting]];
    [reportRoundFileNameTextField setStringValue:[documentDelegate roundReportName]];
    [reportStatKeyCheckbox setState:[documentDelegate statKeyReportSetting]];
    [reportStatKeyFileNameTextField setStringValue:[documentDelegate statKeyReportName]];
    [reportStyleCheckbox setState:[documentDelegate styleReportSetting]];
    [reportStyleFileNameTextField setStringValue:[documentDelegate styleReportName]];
    [reportBritishStyleCheckbox setState:[documentDelegate britishStyleReportSetting]];
    
    // sort
    [sortingMethodRadioMatrix selectCellWithTag:([documentDelegate sortMethodSetting] + kSettingSortRadioTagBase)];
    [sortTUHButton setState:[documentDelegate tossUpHeardSortSetting]];

    // warnings
    //[warnings1Checkbox setState:[controllerDelegate warning_1_Setting]];  // defaults to true & disabled
    [warnings2Checkbox setState:[documentDelegate warning_2_Setting]];
    [warnings3Checkbox setState:[documentDelegate warning_3_Setting]];
    [warnings4Checkbox setState:[documentDelegate warning_4_Setting]];
    [warnings5Checkbox setState:[documentDelegate warning_5_Setting]];
    [warnings6Checkbox setState:[documentDelegate warning_6_Setting]];
    [warnings7Checkbox setState:[documentDelegate warning_7_Setting]];
    
    // change label for max games (W-4)
    [warnings4Checkbox setTitle:[NSString stringWithFormat:kWarning4TitleFormat, [documentDelegate defaultPlayersPerTeam]]];
    
    // packets
    [packetNameArray release];
    packetNameArray = [[NSMutableArray alloc] initWithCapacity:10];
    // skip if rounds not used
    long minRoundNumber = [documentDelegate minRoundsAssigned];
    long maxRoundNumber = [documentDelegate maxRoundsAssigned];
    if ((minRoundNumber == maxRoundNumber) && (minRoundNumber == 0)) {
        return;
    }
    for (long roundNumber = minRoundNumber; roundNumber <= maxRoundNumber; roundNumber++) {
        NSString *theKey = [NSString stringWithFormat:kPacketRoundBaseKeyFormat, roundNumber];
        NSString *thePacketName = [[documentDelegate packetNames] objectForKey:theKey];
        if (thePacketName == nil) {
            thePacketName = kPacketMissingPacketNameValue;
        }
        NSMutableDictionary *aRound = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%li", roundNumber], kPacketSettingsRoundKey, thePacketName, kPacketSettingsPacketNameKey, nil];
        //DebugLog(@"loadSettingsFromDelegate packets - index: %li, dictionary: %@", roundNumber, aRound);
        [packetNameArray addObject:aRound];
    }
//    if ([settingsSelectorSegmentedControl selectedSegment] == kPacketsSettings) {
//        // this tab is visible, reload table
//        [packetNameTable reloadData];
//    }
}

-(void)savePacketNames {
    double minRoundNumber = [documentDelegate minRoundsAssigned];
    double maxRoundNumber = [documentDelegate maxRoundsAssigned];
    if ((minRoundNumber == maxRoundNumber) && (minRoundNumber == 0)) {
        return;
    }
    long packetsNamed = 0;
    NSMutableDictionary *newPacketNameDictionary = [NSMutableDictionary dictionaryWithCapacity:10];
    for (NSMutableDictionary *theRoundDict in packetNameArray) {
        NSString *packetName = [theRoundDict objectForKey:kPacketSettingsPacketNameKey];
        if (![packetName isEqualToString:kPacketMissingPacketNameValue]) {
            packetsNamed++;
        }
        [newPacketNameDictionary setObject:packetName forKey:[NSString stringWithFormat:kPacketRoundBaseKeyFormat, (long)[(NSString *)[theRoundDict objectForKey:kPacketSettingsRoundKey] integerValue]]];
        packetName = nil;
    }
    // update master packet name dictionary
    //DebugLog(@"savePacketNames old: %@\nnew: %@", [documentDelegate packetNames], newPacketNameDictionary);
    if (![[documentDelegate packetNames] isEqualToDictionary:newPacketNameDictionary]) {
        [documentDelegate setPacketNames:newPacketNameDictionary];
        [documentDelegate setPacketNamesUsed:packetsNamed];
        [documentDelegate updateChangeCount:NSChangeDone];
    }
    newPacketNameDictionary = nil;
}

#pragma mark Life cycle

- (void)awakeFromNib
{ 
    // assign settings values
    [self loadSettingsFromDelegate];  
    currentClickedRow = -99;
}

- (void)handleViewControllerClosing {
    // save packet names
    [self savePacketNames];
}

- (BOOL)shouldViewClose {
    // save packet names
    [self savePacketNames];
    return TRUE;
}

- (void)dealloc {
    [packetNameArray release];
    packetNameArray = nil;
    [super dealloc];
}

#pragma mark Action methods

- (IBAction)settingsSelectorChangedAction:(id)sender {
    long currentSetting = [(NSSegmentedControl *)sender selectedSegment];
    // hide all and reveal current setting
    [generalSettingsBox setHidden:TRUE];
    [reportsSettingsBox setHidden:TRUE];
    [sortingSettingsBox setHidden:TRUE];
    [warningsSettingsBox setHidden:TRUE];
    [packetsSettingsBox setHidden:TRUE];
    
    switch (currentSetting) {
        case kGeneralSettings:
        {
            [generalSettingsBox setHidden:FALSE];
            break;
        }
        case kReportsSettings:
        {
            [reportsSettingsBox setHidden:FALSE];
            break;
        }
        case kSortSettings:
        {
            [sortingSettingsBox setHidden:FALSE];
            break;
        }
        case kWarningsSettings:
        {
            [warningsSettingsBox setHidden:FALSE];
            break;
        }
        case kPacketsSettings:
        {
            [packetsSettingsBox setHidden:FALSE];
            [packetNameTable reloadData];
            break;
        }
            
        default:
            break;
    }
}

- (IBAction)roundsRadioButtonAction:(id)sender {
    if ([roundsInReportRadioMatrix selectedTag] == kSettingsRoundsInReportAllRadioTag) {
        [documentDelegate setAllRoundsIncludedInReport:TRUE];
    } else {
        [documentDelegate setAllRoundsIncludedInReport:FALSE];
        [documentDelegate setMinRoundIncludedInReport:[minRoundIncludedTextField integerValue]];
        [documentDelegate setMaxRoundIncludedInReport:[maxRoundIncludedTextField integerValue]];
    }
    // not save to file don't flag update
    //[documentDelegate updateChangeCount:NSChangeDone];
}

- (IBAction)roundsMinMaxChangedAction:(id)sender {
    long value = [(NSTextField *)sender integerValue];
    if (sender == minRoundIncludedTextField) {
        if (value == [documentDelegate minRoundIncludedInReport]) {
            return;
        }
        [documentDelegate setMinRoundIncludedInReport:value];
        // check if max value needs adjusting
        if (value < [maxRoundIncludedTextField integerValue]) {
            // adjust
            [maxRoundIncludedTextField setIntegerValue:value];
            [documentDelegate setMaxRoundIncludedInReport:value];
        }
        [[maxRoundIncludedTextField formatter] setMinValue:value];
    } else {
        if (value == [documentDelegate maxRoundIncludedInReport]) {
            return;
        }
        [documentDelegate setMaxRoundIncludedInReport:value];
    }
    [documentDelegate updateChangeCount:NSChangeDone];
}

- (IBAction)sortTUHCheckBoxAction:(id)sender {
    [documentDelegate setTossUpHeardSortSetting:[sortTUHButton state]];
    [documentDelegate updateChangeCount:NSChangeDone];
}

- (IBAction)autosaveCheckBoxAction:(id)sender {
    if ([sender state] == NO) {
        // turn off auto saves
        [[NSDocumentController sharedDocumentController] setAutosavingDelay:0];
    } else {
        long updateFreq = [autosaveTimeValueTextField integerValue];
        if ((updateFreq <= 0) || (updateFreq > 60)) {
            updateFreq = 10;
            [autosaveTimeValueTextField setIntegerValue:updateFreq];
        }
        [autosaveStepper setIntegerValue:updateFreq];
        [[NSDocumentController sharedDocumentController] setAutosavingDelay:(updateFreq * 60)];
    }
    // not saved to file, don't flag doucment update
}

- (IBAction)autosaveValueChangedAction:(id)sender {
    long updateFreq = [autosaveTimeValueTextField integerValue];
    // update stepper
    [autosaveStepper setIntegerValue:updateFreq];
    // update documentController if on
    if ([autosaveCheckBox state]) {
        [[NSDocumentController sharedDocumentController] setAutosavingDelay:(updateFreq * 60)];
    }
    // not saved to file, don't flag doucment update
}

- (IBAction)autosaveStepperAction:(id)sender {
    long updateFreq = [sender integerValue];
    long previousFreq = [autosaveTimeValueTextField integerValue];
    if (updateFreq == previousFreq) {
        // at limit, do nothing more
        return;
    }
    [autosaveTimeValueTextField setIntegerValue:updateFreq];
    [[NSDocumentController sharedDocumentController] setAutosavingDelay:(updateFreq * 60)];
    // not saved to file, don't flag doucment update
}

- (IBAction)sortingMethodRadioButtonAction:(id)sender {
    [documentDelegate setSortMethodSetting:([sortingMethodRadioMatrix selectedTag] - kSettingSortRadioTagBase)];
    [documentDelegate updateChangeCount:NSChangeDone];
}

- (IBAction)warningsCheckboxChangeAction:(id)sender {
    switch ([(NSButton *)sender tag]) {
        case kSettingsWarnings1Tag: {
            [documentDelegate setWarning_1_Setting:[(NSButton *)sender state]];
            break;
        }
        case kSettingsWarnings2Tag: {
            [documentDelegate setWarning_2_Setting:[(NSButton *)sender state]];
            break;
        }
        case kSettingsWarnings3Tag: {
            [documentDelegate setWarning_3_Setting:[(NSButton *)sender state]];
            break;
        }
        case kSettingsWarnings4Tag: {
            [documentDelegate setWarning_4_Setting:[(NSButton *)sender state]];
            break;
        }
        case kSettingsWarnings5Tag: {
            [documentDelegate setWarning_5_Setting:[(NSButton *)sender state]];
            break;
        }
        case kSettingsWarnings6Tag: {
            [documentDelegate setWarning_6_Setting:[(NSButton *)sender state]];
            break;
        }
        case kSettingsWarnings7Tag: {
            [documentDelegate setWarning_7_Setting:[(NSButton *)sender state]];
            break;
        }
        default:
            break;
    }
    [documentDelegate updateChangeCount:NSChangeDone];
}

- (IBAction)reportCheckboxChangeAction:(id)sender {
    //DebugLog(@"style report changed - tag: %i", [(NSButton *)sender tag]);
    switch ([(NSButton *)sender tag]) {
        case kSettingsReportTeamStandingCheckBoxTag: {
            [documentDelegate setTeamStandingsReportSetting:[(NSButton *)sender state]];
            break;
        }
        case kSettingsReportIndividualStandingCheckBoxTag: {
            [documentDelegate setIndividualStandingsReportSetting:[(NSButton *)sender state]];
            break;
        }
        case kSettingsReportScoreboardCheckBoxTag: {
            [documentDelegate setScoreboardReportSetting:[(NSButton *)sender state]];
            break;
        }
        case kSettingsReportTeamDetailsCheckBoxTag: {
            [documentDelegate setTeamDetailsReportSetting:[(NSButton *)sender state]];
            break;
        }
        case kSettingsReportIndividualDetailsCheckBoxTag: {
            [documentDelegate setIndividualDetailsReportSetting:[(NSButton *)sender state]];
            break;
        }
        case kSettingsReportRoundsCheckBoxTag: {
            [documentDelegate setRoundReportSetting:[(NSButton *)sender state]];
            break;
        }
        case kSettingsReportStatKeyCheckBoxTag: {
            [documentDelegate setStatKeyReportSetting:[(NSButton *)sender state]];
            break;
        }
        case kSettingsReportStyleCheckBoxTag: {
            [documentDelegate setStyleReportSetting:[(NSButton *)sender state]];
            //DebugLog(@"style report changed to: %@", [documentDelegate styleReportSetting]? @"true" : @"false");
            break;
        }
        case kSettingsReportBritishStyleCheckBoxTag: {
            [documentDelegate setBritishStyleReportSetting:[(NSButton *)sender state]];
            break;
        }
            
        default:
            break;
    }
    [documentDelegate updateChangeCount:NSChangeDone];
}

- (IBAction)reportNameChangedAction:(id)sender {
    NSString *value = [(NSTextField *)sender stringValue];
    switch ([(NSTextField *)sender tag]) {
        case kSettingsReportTeamStandingFileNameTag: {
            if ([value isEqualToString:[documentDelegate teamStandingsReportName]]) {
                return;
            }
            [documentDelegate setTeamStandingsReportName:value];
            break;
        }
        case kSettingsReportIndividualStandingFileNameTag: {
            if ([value isEqualToString:[documentDelegate individualStandingsReportName]]) {
                return;
            }
            [documentDelegate setIndividualStandingsReportName:value];
            break;
        }
        case kSettingsReportScoreboardFileNameTag: {
            if ([value isEqualToString:[documentDelegate scoreboardReportName]]) {
                return;
            }
            [documentDelegate setScoreboardReportName:value];
            break;
        }
        case kSettingsReportTeamDetailsFileNameTag: {
            if ([value isEqualToString:[documentDelegate teamDetailsReportName]]) {
                return;
            }
            [documentDelegate setTeamDetailsReportName:value];
            break;
        }
        case kSettingsReportIndividualDetailsFileNameTag: {
            if ([value isEqualToString:[documentDelegate individualDetailsReportName]]) {
                return;
            }
            [documentDelegate setIndividualDetailsReportName:value];
            break;
        }
        case kSettingsReportRoundsFileNameTag: {
            if ([value isEqualToString:[documentDelegate roundReportName]]) {
                return;
            }
            [documentDelegate setRoundReportName:value];
            break;
        }
        case kSettingsReportStatKeyFileNameTag: {
            if ([value isEqualToString:[documentDelegate statKeyReportName]]) {
                return;
            }
            [documentDelegate setStatKeyReportName:value];
            break;
        }
        case kSettingsReportStyleCheckBoxTag: {
            if ([value isEqualToString:[documentDelegate styleReportName]]) {
                return;
            }
            [documentDelegate setStyleReportName:value];
            break;
        }
            
        default:
            break;
    }
    [documentDelegate updateChangeCount:NSChangeDone];
    
}

- (IBAction)tableViewSelected:(id)sender {
    long row = [sender selectedRow];
    if (row < 0) {
        return;
    }
    if (currentClickedRow == [sender selectedRow]) {
        // if clicked on row 2x, go to edit mode
        [packetNameTable editColumn:1 row:currentClickedRow withEvent:nil select:YES];
        return;
    }
    currentClickedRow = row;
    //DebugLog(@"clicked on row %i", row);
    
}

#pragma mark NSTableViewDataSource Protocol

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [packetNameArray count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    if (rowIndex < [packetNameArray count] && rowIndex >= 0) {
//        NSString *value;
//        if ([[aTableColumn identifier] isEqualToString:kPacketSettingsRoundKey]) {
//            value = [NSString stringWithFormat:@"%i", (rowIndex + 1)];
//        } else {
//            // packet name column
//            value = [[packetNameArray objectAtIndex:rowIndex] objectForKey:[aTableColumn identifier]];
//        }
//        //DebugLog(@"object for column: %@, row: %i, value: %@", [aTableColumn identifier], rowIndex, value);
//        return value;
//DebugLog(@"object for column: %@, row: %i, value: %@", [aTableColumn identifier], rowIndex, [[packetNameArray objectAtIndex:rowIndex] objectForKey:[aTableColumn identifier]]);
        return [[packetNameArray objectAtIndex:rowIndex] objectForKey:[aTableColumn identifier]];
    }
    return nil;
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    //DebugLog(@"setObject start - column: %@, row: %i, value: [%@]", [aTableColumn identifier], rowIndex, anObject);
    if ((rowIndex < 0) || (rowIndex > [packetNameArray count])) {
        return;
    }
    NSMutableDictionary *theRound = [packetNameArray objectAtIndex:rowIndex];
    // packet name column
    NSString *name = (NSString *)anObject;
    if ([[aTableColumn identifier] isEqualToString:kPacketSettingsPacketNameKey]) {
        if ([name length] < 1) {
            // zero length name, replace with " ".
            name = kPacketMissingPacketNameValue;
        }
    }
    //DebugLog(@"setObject end - value: [%@]", name);
    [theRound setObject:name forKey:[aTableColumn identifier]];
    [packetNameArray replaceObjectAtIndex:rowIndex withObject:theRound];
    //DebugLog(@"packetNameArray %@", packetNameArray);
    theRound = nil;
    name = nil;
}

@end
