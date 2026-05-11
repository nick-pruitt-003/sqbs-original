//
//  TournamentSetupViewController.m
//  SQBS
//
//  Created by Neil Smith on 11-10-27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TournamentSetupViewController.h"
#import "Constants.h"
#import "Tournament.h"
#import "Game.h"

@implementation TournamentSetupViewController

@synthesize addTeamButton;
@synthesize comboDivsionList;
@synthesize tournamentNameTextField;

//long currentClickedRow; // team table - used for selection and double click detection
//long currentClickedColumn;

#pragma mark internal methods

- (void) divisionsDeletedAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(NSMutableArray *)deletedNames {
    if (returnCode == NSAlertDefaultReturn) {
        // default is to cancel
        // restore original division names
        [divisionsListTextView setString:[[documentDelegate divisionList] componentsJoinedByString:@"\n"]];
        [deletedNames release];
        return;
    }
    
    
    for (NSString *deleteThisDivision in deletedNames) {
        for (int i = 0; i < [[documentDelegate teamList] count]; i++) {
            NSMutableDictionary *theTeam = [[documentDelegate teamList] objectAtIndex:i];
            NSString *thisTeamsDivision = [theTeam objectForKey:kDivisionKey];
            if ((thisTeamsDivision != nil) && [thisTeamsDivision isEqualToString:deleteThisDivision]) {
                [theTeam removeObjectForKey:kDivisionKey];
                [[documentDelegate teamList] replaceObjectAtIndex:i withObject:theTeam];
            }
            theTeam = nil;
        }
    }
    
    // finish up updating displayed fields
    NSMutableArray *tempDivisionList = [NSMutableArray arrayWithArray:[[divisionsListTextView string] componentsSeparatedByString:@"\n"]];
    [self setComboDivsionList:nil];
    [divisionsListTextView setString:@""];
    if ((tempDivisionList != nil) && ([tempDivisionList count] > 0)) {
        [divisionsListTextView setString:[tempDivisionList componentsJoinedByString:@"\n"]];
        [self setComboDivsionList:[NSMutableArray arrayWithArray:tempDivisionList]];
        [comboDivsionList insertObject:kSetupDivisionSelectorTitle atIndex:0];
    } else {
        [self setComboDivsionList:[NSMutableArray arrayWithObjects:kSetupDivisionSelectorTitle, nil]];
    }
    [documentDelegate setDivisionList:tempDivisionList];
    [documentDelegate updateChangeCount:NSChangeDone];
    [teamTableView reloadData];
    tempDivisionList = nil;
    [deletedNames release];
}

- (BOOL)saveDivisionsEntryList {
    NSMutableArray *tempDivisionList = [NSMutableArray arrayWithArray:[[divisionsListTextView string] componentsSeparatedByString:@"\n"]];
    
    // check in case no changes
    if ([tempDivisionList isEqual:[documentDelegate divisionList]]) {
        //DebugLog(@"saveDivisionsEntryList no update");
        // no updating necessary
        tempDivisionList = nil;
        return FALSE;
    }
    // check for empty entries
    int currentIndex = 0;
    while ([tempDivisionList count] > currentIndex) {
        NSString *currentEntry = [tempDivisionList objectAtIndex:currentIndex];
        if (currentEntry != nil) {
            currentEntry = [currentEntry stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([currentEntry length] < 1) {
                [tempDivisionList removeObjectAtIndex:currentIndex];
            } else {
                currentIndex++;
            }
        } else {
            [tempDivisionList removeObjectAtIndex:currentIndex]; 
        }
    }
    // need to check if any existing divsion names have been removed
    NSMutableArray *deletedNames = [NSMutableArray arrayWithCapacity:10];
    for (NSString *existingName in [documentDelegate divisionList]) {
        if ([tempDivisionList indexOfObject:existingName] == NSNotFound) {
            [deletedNames addObject:existingName];
        }
    }
    if ([deletedNames count] > 0) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Existing Divisions deleted. Remove deleted division names from teams?" defaultButton:@"Cancel" alternateButton:@"Clear" otherButton:nil informativeTextWithFormat:@" "];
        [deletedNames retain];
        [alert beginSheetModalForWindow:[divisionsListTextView window] modalDelegate:self didEndSelector:@selector(divisionsDeletedAlertDidEnd:returnCode:contextInfo:) contextInfo:deletedNames];
        alert = nil;
        // rest done in didEndSelector
        return FALSE;
    }
    [self setComboDivsionList:nil];
    [divisionsListTextView setString:@""];
    if ((tempDivisionList != nil) && ([tempDivisionList count] > 0)) {
        [divisionsListTextView setString:[tempDivisionList componentsJoinedByString:@"\n"]];
        [self setComboDivsionList:[NSMutableArray arrayWithArray:tempDivisionList]];
        [comboDivsionList insertObject:kSetupDivisionSelectorTitle atIndex:0];
    } else {
        [self setComboDivsionList:[NSMutableArray arrayWithObjects:kSetupDivisionSelectorTitle, nil]];
    }
    [documentDelegate setDivisionList:tempDivisionList];
    [documentDelegate updateChangeCount:NSChangeDone];
    [teamTableView reloadData];
    return TRUE;
}

- (void)loadDivisionsEntryListFromControllerDelegate {
    // restore list to last saved entries and update display
    //DebugLog(@"use divisions stored value: %i", [documentDelegate useDivisionsSetting]);
    BOOL usingDivisions = [documentDelegate useDivisionsSetting];
    //[useDivisionsCheckbox setState:usingDivisions];
    [[[self view] viewWithTag:kTournamentOptionUseDivisionCheckboxTag] setState:usingDivisions];
    
    // sync use divisions state
    [divisionEntryBox setHidden:!usingDivisions];
    [divisionColumn setHidden:!usingDivisions];
    [divisionsListTextView setString:@""];
    [self setComboDivsionList:[NSMutableArray arrayWithObjects:kSetupDivisionSelectorTitle, nil]];
    if (usingDivisions) {
        if ([[documentDelegate divisionList] count] > 0) {
            [divisionsListTextView setString:[[documentDelegate divisionList] componentsJoinedByString:@"\n"]];
            for (NSString *divisionName in [documentDelegate divisionList]) {
                [comboDivsionList addObject:divisionName];
            }
        }
    }
}

-(void)loadBonusConversionSettingFromDocument {
    // convert SQBS values
    long button = kTournamentOptionAutomaticRadioButtonTag;
    switch ([documentDelegate autoTrackSetting]) {
        case kSQBS_Manual: {
            button = kTournamentOptionManualRadioButtonTag;
            break;
        }
        case kSQBS_Combo: {
            button = kTournamentOptionManualAHRadioButtonTag;
            break;
        }
        case kSQBS_Bounceback: {
            button = kTournamentOptionManualBounceBackRadioButtonTag;
            break;
        }
        case kSQBS_AutoBounceback: {
            button = kTournamentOptionAutoBounceBackRadioButtonTag;
            break;
        }
            
        default:  // automatic setting
            break;
    }
    [bonusConversionTrackingRadioMatrix selectCellWithTag:button];
}

- (void)loadTournamentOptionsFromControllerDelegate {
    // set options based on current values
    // question values
    [(NSTextField *)[[self view] viewWithTag:kTournamentOptionQuestionValue_0_tag] setIntegerValue:[documentDelegate question_0_value]];
    [[[self view] viewWithTag:kTournamentOptionQuestionCheckbox_0_tag] setState:[documentDelegate question_0_selected]];
 
    [(NSTextField *)[[self view] viewWithTag:kTournamentOptionQuestionValue_1_tag] setIntegerValue:[documentDelegate question_1_value]];
    [[[self view] viewWithTag:kTournamentOptionQuestionCheckbox_1_tag] setState:[documentDelegate question_1_selected]];
 
    [(NSTextField *)[[self view] viewWithTag:kTournamentOptionQuestionValue_2_tag] setIntegerValue:[documentDelegate question_2_value]];
    [[[self view] viewWithTag:kTournamentOptionQuestionCheckbox_2_tag] setState:[documentDelegate question_2_selected]];
 
    [(NSTextField *)[[self view] viewWithTag:kTournamentOptionQuestionValue_3_tag] setIntegerValue:[documentDelegate question_3_value]];
    [[[self view] viewWithTag:kTournamentOptionQuestionCheckbox_3_tag] setState:[documentDelegate question_3_selected]];
    
    // statistics tracking settings
    [[[self view] viewWithTag:kTournamentOptionTrackTUHCheckboxTag] setState:[documentDelegate trackTossUpsHeardSetting]];
    [[[self view] viewWithTag:kTournamentOptionTrackPowerCheckboxTag] setState:[documentDelegate trackPowerNegStatsSetting]];
    [[[self view] viewWithTag:kTournamentOptionTrackLightRndCheckboxTag] setState:[documentDelegate trackLightRoundSetting]];
    
    // bonus conversion
    if (![documentDelegate trackBonusSetting]) {
        [bonusConversionTrackingRadioMatrix selectCellWithTag:kTournamentOptionNoneRadioButtonTag];  // no tracking
    } else {
        [self loadBonusConversionSettingFromDocument];
    }
    [maxDefaultPlayers setIntegerValue:[documentDelegate defaultPlayersPerTeam]];
    //DebugLog(@"loadTournamentOptions maxDefaultPlayers %i", [documentDelegate defaultPlayersPerTeam]);
}

- (void)handleFileLoadedNotification:(NSNotification *)userinfo {
    // check if for me
    if ([userinfo object] != documentDelegate) {
        return;
    }
    if (([documentDelegate teamList] != nil) && ([[documentDelegate teamList] count] > 0)) {
        //DebugLog(@"teamInfoArray count: %i", [[documentDelegate teamList] count]);
        // no need for any notification
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kTeamFileImportedNotification object:nil];
        //[[NSNotificationCenter defaultCenter] removeObserver:self name:kTournamentFileLoadedNotification object:nil];
    }
    // add division names
    [self loadDivisionsEntryListFromControllerDelegate];
    // add options
    [self loadTournamentOptionsFromControllerDelegate];
    
    [tournamentNameTextField setStringValue:[documentDelegate tournamentName]];
    [[[self view] window] makeFirstResponder:tournamentNameTextField];
    
    [teamTableView reloadData];
}

#pragma mark lifecycle

- (void)awakeFromNib
{    
    //DebugLog(@"awakeFromNib - delegate: %@", documentDelegate);
//    currentClickedRow = -99;
//    currentClickedColumn = -99;
}

- (void)handleViewControllerClosing {
    //DebugLog(@"handleViewControllerClosing");
    // force update of any textfields
    [[[self view] window] makeFirstResponder:nil];
    
    // remove any teams without name or players should only be case of added team, but didn't add names
    int i = 0;
    while (i < [[documentDelegate teamList] count]) {
        NSMutableDictionary *aTeam = [[documentDelegate teamList] objectAtIndex:i];
        //DebugLog(@"updateTournamentDataAction: %@", aTeam);
        if ([aTeam count] <= kDefaultNonSavedKeyCount) {
            // nothing entered, remove
            [[documentDelegate teamList] removeObjectAtIndex:i];
            [documentDelegate updateChangeCount:NSChangeDone];
            continue;
        }
        i++;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear {
    //DebugLog(@"viewWillAppear - documentDelegate: %@", documentDelegate);
    // only get notification if data hasn't been loaded
    if (([documentDelegate teamList] == nil) || ([[documentDelegate teamList] count] == 0)) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFileLoadedNotification:) name:kTeamFileImportedNotification object:nil];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFileLoadedNotification:) name:kTournamentFileLoadedNotification object:nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidEndEditing:) name:NSTextDidEndEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidBeginEditing:) name:NSTextDidBeginEditingNotification object:nil]; 
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSelectionDidChangeNotification:) name:NSTableViewSelectionDidChangeNotification object:nil];
    
    // load team info - case of switching back and forth between views
    [self handleFileLoadedNotification:[NSNotification notificationWithName:kTeamFileImportedNotification object:documentDelegate]];
}

- (BOOL)shouldViewClose {
    //DebugLog(@"shouldViewClose");
    // force update of any text fields
    [[[self view] window] makeFirstResponder:nil];
    // remove any teams without name or players should only be case of added team, but didn't add names
    int i = 0;
    BOOL noChanges = ![documentDelegate isDocumentEdited];
    while (i < [[documentDelegate teamList] count]) {
        NSMutableDictionary *aTeam = [[documentDelegate teamList] objectAtIndex:i];
        //DebugLog(@"updateTournamentDataAction: %@", aTeam);
        if ([aTeam count] <= kDefaultNonSavedKeyCount) {
            // nothing entered, remove
            [[documentDelegate teamList] removeObjectAtIndex:i];
            noChanges = FALSE;
            [documentDelegate updateChangeCount:NSChangeDone];
            continue;
        }
        i++;
    }
    // if any updates, reflect in return value
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //DebugLog(@"shouldViewClose noChanges: %i", noChanges);
    return noChanges;
}

#pragma mark action methods

- (void)setupChangeAttemptNoActionAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)context {
    // do nothing since these alerts don't have user choices
}

- (IBAction)checkBoxCheckedAction:(id)sender {
    switch ([sender tag]) {
        case kTournamentOptionTrackTUHCheckboxTag: {
            [documentDelegate setTrackTossUpsHeardSetting:[sender state]];
            if ([sender state]) {
                // put up suggestion that they review existing game
                NSAlert *alert = [NSAlert alertWithMessageText:@"TUH value for existing games not changed." defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"Suggest existing games be reviewed to ensure tournament statistics are consistent and valid."];
                [alert beginSheetModalForWindow:[sender window] modalDelegate:self didEndSelector:@selector(setupChangeAttemptNoActionAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
                alert = nil;
            }
            break;
        }
        case kTournamentOptionTrackPowerCheckboxTag: {
            // this can change regardless of whether games exist - only impacts reports
            // check that question 0 & 2 selected and correct values
            if ([sender state]) {
                if (![documentDelegate question_0_selected] || ([documentDelegate question_0_value] <= 0)
                    || ![documentDelegate question_2_selected] || ([documentDelegate question_2_value] >= 0)) {
                    // questions not correct for power/neg assumptions
                    NSAlert *alert = [NSAlert alertWithMessageText:@"Question settings not correct for power / negative tracking." defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"P/N tracking assumes:\nQuestion 0 selected and value greater than 0, and\nQuestion 2 selected and value less than 0."];
                    [alert beginSheetModalForWindow:[sender window] modalDelegate:self didEndSelector:@selector(setupChangeAttemptNoActionAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
                    alert = nil;
                }
            }
            
            [documentDelegate setTrackPowerNegStatsSetting:[sender state]];
            break;
        }
        case kTournamentOptionTrackLightRndCheckboxTag: {
            if (![sender state]) {
                // only allow unselect if no points exist
                if (([documentDelegate gameList] != nil) && ([[documentDelegate gameList] count] > 0)) {
                    // find points assigned to lightning rounds
                    for (Game *aGame in [documentDelegate gameList]) {
                        if (([aGame team_A_LighteningPoints] > 0) || ([aGame team_B_LighteningPoints] > 0)) {
                            // can't do change
                            // re-check and put up warning
                            [(NSButton *)sender setState:TRUE];
                            NSAlert *alert = [NSAlert alertWithMessageText:@"Unselecting Lightning Round tracking not allowed because lightning points assigned in games." defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"Action allowed once all Lightning round points are zeroed."];
                            [alert beginSheetModalForWindow:[sender window] modalDelegate:self didEndSelector:@selector(setupChangeAttemptNoActionAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
                            alert = nil;
                            return;
                        }
                    }
                }
            }
            
            [documentDelegate setTrackLightRoundSetting:[sender state]];
            break;
        }
            
        default: {
            // unknown sender
            return;
            break;
        }
    }
    
    [documentDelegate updateChangeCount:NSChangeDone];
}

- (IBAction)questionCheckBoxCheckedAction:(id)sender {
    BOOL setting = [(NSButton *)sender state];
    // adding the question - allow anytime
    // removing question - if games exist, only if no points
    if (!setting) {
        // check if points assigned to that question
        if (([documentDelegate gameList] != nil) && ([[documentDelegate gameList] count] > 0)) {
            // find points assigned to questions
            long questionNumber = [(NSControl *)sender tag] - kTournamentOptionQuestionCheckboxBaseTag;
            for (Game *aGame in [documentDelegate gameList]) {
                if ([aGame countsExistForQuestion:questionNumber]) {
                    // can't do change
                    // re-check and put up warning
                    [(NSButton *)sender setState:TRUE];
                    NSAlert *alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:@"Games exist with counts against Question %li. Unselecting not allowed.", questionNumber] defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"Action allowed once all counts for that question are zeroed."];
                    [alert beginSheetModalForWindow:[sender window] modalDelegate:self didEndSelector:@selector(setupChangeAttemptNoActionAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
                    alert = nil;
                    return;
                }
            }
        }
    }
    // set question selected state
    switch ([sender tag]) {
        case kTournamentOptionQuestionCheckbox_0_tag: {
            [documentDelegate setQuestion_0_selected:[sender state]];
            break;
        }
        case kTournamentOptionQuestionCheckbox_1_tag: {
            [documentDelegate setQuestion_1_selected:[sender state]];
            break;
        }
        case kTournamentOptionQuestionCheckbox_2_tag: {
            [documentDelegate setQuestion_2_selected:[sender state]];
            break;
        }
        case kTournamentOptionQuestionCheckbox_3_tag: {
            [documentDelegate setQuestion_3_selected:[sender state]];
            break;
        }
            
        default: {
            // unknown sender
            return;
            break;
        }
    }
    
    [documentDelegate updateChangeCount:NSChangeDone];
}

- (IBAction)questionValueChangedAction:(id)sender { 
    long questionValue = [(NSTextField *)sender integerValue];
    // check if games exist, value can't be changed
    if (([documentDelegate gameList] != nil) && ([[documentDelegate gameList] count] > 0)) {
        long originalValue = 0;
        switch ([sender tag]) {
            case kTournamentOptionQuestionValue_0_tag: {
                originalValue = [documentDelegate question_0_value];
                break;
            }
            case kTournamentOptionQuestionValue_1_tag: {
                originalValue = [documentDelegate question_1_value];
                break;
            }
            case kTournamentOptionQuestionValue_2_tag: {
                originalValue = [documentDelegate question_2_value];
                break;
            }
            case kTournamentOptionQuestionValue_3_tag: {
                originalValue = [documentDelegate question_3_value];
                break;
            }
                
            default: {
                // unknown sender
                return;
                break;
            }
        }
        if (originalValue != questionValue) {
            // not allowed
            // restore original value
            [(NSTextField *)sender setIntegerValue:originalValue];
            NSAlert *alert = [NSAlert alertWithMessageText:@"Question values can't be changed once game data entered." defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"Changing question point value could make game results inconsistent."];
            [alert beginSheetModalForWindow:[sender window] modalDelegate:self didEndSelector:@selector(setupChangeAttemptNoActionAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
            alert = nil;
            return;
        }
    }
    switch ([sender tag]) {
        case kTournamentOptionQuestionValue_0_tag: {
            [documentDelegate setQuestion_0_value:questionValue];
            break;
        }
        case kTournamentOptionQuestionValue_1_tag: {
            [documentDelegate setQuestion_1_value:questionValue];
            break;
        }
        case kTournamentOptionQuestionValue_2_tag: {
            [documentDelegate setQuestion_2_value:questionValue];
            break;
        }
        case kTournamentOptionQuestionValue_3_tag: {
            [documentDelegate setQuestion_3_value:questionValue];
            break;
        }
            
        default: {
            // unknown sender
            return;
            break;
        }
    }
    // write back int value, if entered text is not an integer will write back 0 or int value
    [(NSTextField *)sender setStringValue:[NSString stringWithFormat:@"%li", questionValue]];
    
    [documentDelegate updateChangeCount:NSChangeDone];
}

- (void)bonusChangedAttemptRevertAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)context {
    // restore original button
    // changing selected cell within action method doesn't update graphic so do here
    [self loadBonusConversionSettingFromDocument];
}

- (IBAction)bonusRadioSetChangedAction:(id)sender {
    NSButtonCell *selCell = [sender selectedCell];
    long selectedCellTag = [selCell tag];
    // allowed to select None once games are entered, if no bonus points assigned
    if (([documentDelegate gameList] != nil) && ([[documentDelegate gameList] count] > 0)) {
        // if not selecting None don't allow
        if (selectedCellTag != kTournamentOptionNoneRadioButtonTag) {
            // restore original button
            //[self loadBonusConversionSettingFromDocument];
            NSAlert *alert = [NSAlert alertWithMessageText:@"Bonus conversion method can't be changed once game data entered." defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"Changing Bonus conversion method could make game results inconsistent."];
            [alert beginSheetModalForWindow:[sender window] modalDelegate:self didEndSelector:@selector(bonusChangedAttemptRevertAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
            alert = nil;
            return;
        } else {
            // find points assigned to bonuses
            for (Game *aGame in [documentDelegate gameList]) {
                if (([aGame team_A_BonusPoints] > 0) || ([aGame team_B_BonusPoints] > 0) || ([aGame team_A_BounceBacksPoints] > 0) || ([aGame team_B_BounceBacksPoints] > 0)) {
                    // can't do change
                    // restore original button
                    //[self loadBonusConversionSettingFromDocument];
                    NSAlert *alert = [NSAlert alertWithMessageText:@"Games exist with Bonus values assigned. Change not allowed." defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"Changing Bonus conversion method could make game results inconsistent."];
                    [alert beginSheetModalForWindow:[sender window] modalDelegate:self didEndSelector:@selector(bonusChangedAttemptRevertAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
                    alert = nil;
                    return;
                }
            }
        }
    }
    long doTracking = TRUE;
    BOOL autoTrackingValue = kSQBS_Automatic;
    //DebugLog(@"bonusRadioSetChangedAction - tag: %i", selectedCellTag);
    // "None" is stuck in middle so need to handle each button individually vs. mapping tag to setting
    switch (selectedCellTag) {
        case kTournamentOptionManualRadioButtonTag: {
            autoTrackingValue = kSQBS_Manual;
            break;
        }
        case kTournamentOptionNoneRadioButtonTag: {
            // turn off bonus tracking, value doesn't matter
            doTracking = FALSE;
            autoTrackingValue = kSQBS_Manual;
            break;
        }
        case kTournamentOptionManualAHRadioButtonTag: {
            autoTrackingValue = kSQBS_Combo;
            break;
        }
        case kTournamentOptionManualBounceBackRadioButtonTag: {
            autoTrackingValue = kSQBS_Bounceback;
            break;
        }
        case kTournamentOptionAutoBounceBackRadioButtonTag: {
            autoTrackingValue = kSQBS_AutoBounceback;
            break;
        }
            
        default: // Automatic
            break;
    }
    
    // convert to SQBS values
    [documentDelegate setTrackBonusSetting:doTracking];
    [documentDelegate setAutoTrackSetting:autoTrackingValue];
    
    [documentDelegate updateChangeCount:NSChangeDone];
}

- (IBAction)maxDefaultPlayersPerTeamChangedAction:(id)sender {
    [documentDelegate setDefaultPlayersPerTeam:[(NSTextField *)sender integerValue]];
    // not saved to file
    //[documentDelegate updateChangeCount:NSChangeDone];
}

- (IBAction)tournamentNameChangedAction:(id)sender {
    //DebugLog(@"tournamentNameChangedAction tournament name: %@", [tournamentNameTextField stringValue]);
    [documentDelegate setTournamentName:[tournamentNameTextField stringValue]];
    [documentDelegate updateChangeCount:NSChangeDone];
}

- (void) divisionCheckBoxDeleteAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == NSAlertDefaultReturn) {
        // default is to cancel
        // put use divisons checkbox back
        //[useDivisionsCheckbox setState:TRUE];
        [[[self view] viewWithTag:kTournamentOptionUseDivisionCheckboxTag] setState:TRUE];
        return;
    }
    
    [divisionsListTextView setString:@""];
    // shouldn't need to, but to be consistant
    [self setComboDivsionList:[NSMutableArray arrayWithObjects:kSetupDivisionSelectorTitle, nil]];
    for (int i = 0; i < [[documentDelegate teamList] count]; i++) {
        NSMutableDictionary *theTeam = [[documentDelegate teamList] objectAtIndex:i];
        if ([theTeam objectForKey:kDivisionKey]) {
            [theTeam removeObjectForKey:kDivisionKey];
            [[documentDelegate teamList] replaceObjectAtIndex:i withObject:theTeam];
        }
        theTeam = nil;
    }
    
    [documentDelegate setUseDivisionsSetting:FALSE];
    [divisionEntryBox setHidden:TRUE];
    [divisionColumn setHidden:TRUE];
    
    [documentDelegate updateChangeCount:NSChangeDone];
}

- (IBAction)useDivisionsCheckboxCheckedAction:(id)sender {
    // hide / reveal Divsion entry area based on checkbox setting
    BOOL visibilityState = ![sender state];
    if (visibilityState && ([[documentDelegate teamList] count] > 0)) {
        // about to not use divisions, check as this will delete any existing division info
        NSAlert *alert = [NSAlert alertWithMessageText:@"Clearing 'Using Divisions' will delete any existing division information." defaultButton:@"Cancel" alternateButton:@"Clear" otherButton:nil informativeTextWithFormat:@" "];
        [alert beginSheetModalForWindow:[sender window] modalDelegate:self didEndSelector:@selector(divisionCheckBoxDeleteAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
        alert = nil;
        // rest done in didEndSelector
        return;
    }
    
    [documentDelegate setUseDivisionsSetting:[sender state]];
    [divisionEntryBox setHidden:visibilityState];
    [divisionColumn setHidden:visibilityState];
    
    [documentDelegate updateChangeCount:NSChangeDone];
}

//- (IBAction)tableViewSelected:(id)sender {
//    long row = [sender selectedRow];
//    long column = [sender selectedColumn];
//    column always -1 ???
//    if ((row < 0) || (column < 0)) {
//        return;
//    }
//    DebugLog(@"clicked on row %i, column %i", row, column);
//    if ((currentClickedRow == [sender selectedRow]) && (currentClickedColumn == [sender selectedColumn])) {
//        // if division or exhibition columns ignore
//        
//        // 2x click go into edit mode
//        [teamTableView editColumn:currentClickedColumn row:currentClickedRow withEvent:nil select:YES];
//        return;
//    }
//    currentClickedRow = row;
//    currentClickedColumn = column;
//    [deleteTeamButton setEnabled:TRUE];
//    DebugLog(@"clicked on row %i, column %i", row, column);
//    
//}

- (IBAction)addTeam:(id)sender
{
    // create empty team dictionary
    NSMutableDictionary *aTeam = [NSMutableDictionary dictionaryWithCapacity:10];
    // add sort index values
    NSString *sortIndexValue = [NSString stringWithFormat:@"%i", [[documentDelegate teamList] count]];
    [aTeam setObject:sortIndexValue forKey:kOriginalTeamIndexKey];
    [aTeam setObject:sortIndexValue forKey:kSortedTeamIndexKey];
    [[documentDelegate teamList] addObject:aTeam];
    [teamTableView reloadData];
    [teamTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:([[documentDelegate teamList] count] - 1)] byExtendingSelection:NO];
    //[teamTableView selectRow:([teamInfoArray count] - 1) byExtendingSelection:NO];
    [teamTableView editColumn:0 row:([[documentDelegate teamList] count] - 1) withEvent:nil select:YES];
    [documentDelegate updateChangeCount:NSChangeDone];
}

- (void) deleteTeamAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(NSMutableArray *)deletedNames {
    return;
}

- (IBAction)deleteTeam:(id)sender {
    if ([teamTableView selectedRow] < 0 || [teamTableView selectedRow] >= [[documentDelegate teamList] count]) {
        return;
    }
    if (([documentDelegate gameList] != nil) && ([[documentDelegate gameList] count] > 0)){
        // can't delete teams, once matches entered
        NSAlert *alert = [NSAlert alertWithMessageText:@"You cannot delete a team once games have been entered" 
                                         defaultButton:nil 
                                       alternateButton:nil 
                                           otherButton:nil 
                             informativeTextWithFormat:@""];
        [alert beginSheetModalForWindow:[deleteTeamButton window] modalDelegate:self didEndSelector:@selector(deleteTeamAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
        alert = nil;
        return;
    }
    [[documentDelegate teamList] removeObjectAtIndex:[teamTableView selectedRow]];
    [teamTableView reloadData];
    [documentDelegate updateChangeCount:NSChangeDone];
}

#pragma mark NSTextViewDelegate

NSString *initialDivisionListText;

- (void)textDidBeginEditing:(NSNotification *)aNotification {
    if ([aNotification object] == divisionsListTextView) {
        //DebugLog(@"textDidBeginEditing contents: %@", [divisionsListTextView string]);
        // save copy of current division list for comparison when editing done
        initialDivisionListText = [[divisionsListTextView string] copy];
    }
}

//- (void)textDidChange:(NSNotification *)aNotification {
//    // handles case of save / cancel button clicked and then more editing
//    // only care about enabling buttons
//    ///DebugLog(@"textDidChange notification");
//}

- (void)textDidEndEditing:(NSNotification *)aNotification {
    if ([aNotification object] == divisionsListTextView) {
        // save entires
        //DebugLog(@"textDidEndEditing initial: %@, current: %@", initialDivisionListText, [divisionsListTextView string]);
        if (![[divisionsListTextView string] isEqualToString:initialDivisionListText]) {
            if ([self saveDivisionsEntryList]) {
                //DebugLog(@"updated");
                [documentDelegate updateChangeCount:NSChangeDone];
            }
        }
        [initialDivisionListText release];
        initialDivisionListText = nil;
    } else {
        //DebugLog(@"textDidEndEditing");
    }
}

#pragma mark NSComboBoxCellDataSource Protocol

- (NSInteger)numberOfItemsInComboBoxCell:(NSComboBoxCell *)aComboBoxCell {
    if (comboDivsionList == nil) { 
        return 0;
    } else {
        //DebugLog(@"numberOfItemsInComboBoxCell: %i", [currentDivisionList count]);
        return [comboDivsionList count];
    }
}

- (id)comboBoxCell:(NSComboBoxCell *)aComboBoxCell objectValueForItemAtIndex:(NSInteger)index {
    //DebugLog(@"objectValueForItemAtIndex: %i, %@", index, currentDivisionList);
    if (comboDivsionList == nil) {
        return nil;
    } else {
        return [comboDivsionList objectAtIndex:index];
    }
}

#pragma mark -
#pragma mark NSTableViewDataSource Protocol

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    //DebugLog(@"numberOfRows - rows: %i", [teamInfoArray count]);
    return [[documentDelegate teamList] count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    if (rowIndex < [[documentDelegate teamList] count] && rowIndex >= 0) {
        NSString *value = [[[documentDelegate teamList] objectAtIndex:rowIndex] objectForKey:[aTableColumn identifier]];
        //DebugLog(@"object for column: %@, row: %i, value: %@", [aTableColumn identifier], rowIndex, value);
        if ([[aTableColumn identifier] isEqualToString:kDivisionKey]) {
            if (value == nil) {
                return kSetupDivisionSelectorTitle;
            }
        }
        return value;
    }
    return nil;
}

- (void) tableViewSetObjectAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(NSMutableArray *)deletedNames {
    return;
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    //DebugLog(@"setObject - column: %@, row: %i, value: [%@]", [aTableColumn identifier], rowIndex, anObject);
    NSMutableDictionary *theTeam = [[documentDelegate teamList] objectAtIndex:rowIndex];
    // some columns are not string values, if string value remove leading and trailing spaces
    NSString *objectAsString = nil;
    if ([anObject isKindOfClass:[NSString class]]) {
        objectAsString = [anObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        // can't delete team name or player names if games exist
        if ([objectAsString length] == 0) {
            if (![[aTableColumn identifier] isEqualToString:kDivisionKey]) {
                if (([documentDelegate gameList] != nil) && ([[documentDelegate gameList] count] > 0)) {
                    // not allowed if games exists
                    if ([theTeam objectForKey:[aTableColumn identifier]]) {
                        // put up warning
                        NSAlert *alert = [NSAlert alertWithMessageText:@"Games have been entered. Deletion not allowed." 
                                                         defaultButton:nil 
                                                       alternateButton:nil
                                                           otherButton:nil 
                                             informativeTextWithFormat:@"Action is deleting %@ name", [aTableColumn identifier]];
                        [alert beginSheetModalForWindow:[teamTableView window] modalDelegate:self didEndSelector:@selector(tableViewSetObjectAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
                        alert = nil;
                        return;
                    }
                }
            }
        }
    }
    // check that same player name not entered twice
    if ([[aTableColumn identifier] hasPrefix:kPlayerBaseKey]) {
        NSMutableArray *values = [NSMutableArray arrayWithArray:[theTeam allValues]];
        // remove team name and division
        if ([theTeam objectForKey:kTeamNameKey]) {
            [values removeObject:[theTeam objectForKey:kTeamNameKey]];
        }
        if ([theTeam objectForKey:kDivisionKey]) {
            [values removeObject:[theTeam objectForKey:kDivisionKey]];
        }
        // any entries left?
        if ([values count] > 0) {
            if ([values indexOfObject:objectAsString] != NSNotFound) {
                // oops same player name exists
                // put up warning
                NSAlert *alert = [NSAlert alertWithMessageText:@"Player name already exists" 
                                                 defaultButton:nil 
                                               alternateButton:nil
                                                   otherButton:nil 
                                     informativeTextWithFormat:@"Entered name same as %@", [[theTeam allKeysForObject:objectAsString] objectAtIndex:0]];
                [alert beginSheetModalForWindow:[teamTableView window] modalDelegate:self didEndSelector:@selector(tableViewSetObjectAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
                alert = nil;
                return;
            }
        }
    }
    if (objectAsString != nil) {
        // if deleting the value, remove the key
        if ([objectAsString length] < 1) {
            [theTeam removeObjectForKey:[aTableColumn identifier]];
        } else {
            [theTeam setObject:objectAsString forKey:[aTableColumn identifier]];
        }
    } else {
        // if clearing exhibition flag, remove key
        if ([[aTableColumn identifier] hasPrefix:kExhibitionTeamKey] && ![anObject boolValue]) {
            // unsetting exhibtion flag, remove key
            [theTeam removeObjectForKey:kExhibitionTeamKey];
        } else {
            [theTeam setObject:anObject forKey:[aTableColumn identifier]];
        }
    }
    //DebugLog(@"updated team: %@", theTeam);
    [[documentDelegate teamList] replaceObjectAtIndex:rowIndex withObject:theTeam];
    theTeam = nil;
    [documentDelegate updateChangeCount:NSChangeDone];
}

-(void)tableView:(NSTableView *)tableView sortDescriptorsDidChange: (NSArray *)oldDescriptors { 
    if (([documentDelegate teamList] != nil) && ([[documentDelegate teamList] count] > 1)) {
        // sort using new descriptors
        [[documentDelegate teamList] sortUsingDescriptors:[tableView sortDescriptors]];
        // need to update team indexes in games
        for (int i = 0; i < [[documentDelegate teamList] count]; i++) {
            NSMutableDictionary *theTeam = [[documentDelegate teamList] objectAtIndex:i];
            [theTeam setObject:[NSString stringWithFormat:@"%i", i] forKey:kSortedTeamIndexKey];
        }
        [tableView reloadData];
        // if there are games, sort team indexes in games
        if (([documentDelegate gameList] != nil) && ([[documentDelegate gameList] count] > 0)) {
            [documentDelegate adjustTeamIndexesInGames];
        }
        [documentDelegate updateChangeCount:NSChangeDone];
    }
}

@end