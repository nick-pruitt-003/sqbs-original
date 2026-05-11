//
//  GameEntryViewController.m
//  SQBS
//
//  Created by Neil Smith on 11-10-27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GameEntryViewController.h"
#import "Constants.h"
#import "Game.h"
#import "Player.h"
#import "Tournament.h"

@implementation GameEntryViewController

//@synthesize documentDelegate;

long questionValue[4];
bool questionSelectedState[4];

NSMutableArray *teamNameList;  // unsorted, used to get team index of selected team
NSMutableArray *teamNameListSorted;
NSArray *teamDictionaryList; // team info such as player names
NSMutableArray *teamA_PlayerNameList; // unsorted, used to get player index of selected player
//NSMutableArray *teamA_PlayerNameListSorted;
NSMutableArray *teamB_PlayerNameList; // unsorted, used to get player index of selected player
//NSMutableArray *teamB_PlayerNameListSorted;

NSString *titleOfPlayerPopupBeforeSelection;

long teamA_index; // will be different from selector selected index due to title and missing team names
long teamB_index; // will be different from selector selected index due to title and missing team names

long selectedGameIndex; // -1 if new game and not saved

- (void)displayAlertMessage:(NSString *)messageText InformationText:(NSString *)infoText {
    // put up warning
    NSString *displayedInfoText = infoText;
    if (infoText == nil) {
        displayedInfoText = @"";
    }
    NSAlert *alert = [NSAlert alertWithMessageText:messageText defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:displayedInfoText];
    [alert runModal];
}

- (void)setQuestionLabelTitles {
    //NSString *labelString = [NSString stringWithFormat:@"%i", question0Value];
    [question_0_labelTeamA setIntegerValue:questionValue[0]];
    [question_0_labelTeamB setIntegerValue:questionValue[0]];
    
    //labelString = [NSString stringWithFormat:@"%i", question1Value];
    [question_1_labelTeamA setIntegerValue:questionValue[1]];
    [question_1_labelTeamB setIntegerValue:questionValue[1]];
    
    //labelString = [NSString stringWithFormat:@"%i", question2Value];
    [question_2_labelTeamA setIntegerValue:questionValue[2]];
    [question_2_labelTeamB setIntegerValue:questionValue[2]];
    
    //labelString = [NSString stringWithFormat:@"%i", question3Value];
    [question_3_labelTeamA setIntegerValue:questionValue[3]];
    [question_3_labelTeamB setIntegerValue:questionValue[3]];
}

- (void)setQuestionColumnVisibility {
    // Question 0
    BOOL hiddenState = !questionSelectedState[0];
    // if question is not used make 0
    if (hiddenState) {
        questionValue[0] = 0;
    }
    [question_0_labelTeamA setHidden:hiddenState];
    [question_0_labelTeamB setHidden:hiddenState];
    
    // Question 1
    hiddenState = !questionSelectedState[1];
    // if question is not used make 0
    if (hiddenState) {
        questionValue[1] = 0;
    }
    [question_1_labelTeamA setHidden:hiddenState];
    [question_1_labelTeamB setHidden:hiddenState];
    
    // Question 2
    hiddenState = !questionSelectedState[2];
    // if question is not used make 0
    if (hiddenState) {
        questionValue[2] = 0;
    }
    [question_2_labelTeamA setHidden:hiddenState];
    [question_2_labelTeamB setHidden:hiddenState];
    
    // Question 3
    hiddenState = !questionSelectedState[3];
    // if question is not used make 0
    if (hiddenState) {
        questionValue[3] = 0;
    }
    [question_3_labelTeamA setHidden:hiddenState];
    [question_3_labelTeamB setHidden:hiddenState];
}

- (void)createTeamNameList {
    teamDictionaryList = [[documentDelegate teamList] retain];
    //DebugLog(@"teamDictionaryList %@", teamDictionaryList);
    teamA_index = -1;
    teamB_index = -1;
    
    [teamNameList release]; teamNameList = nil;
    [teamNameListSorted release]; teamNameListSorted = nil;
    
    teamNameList = [[NSMutableArray alloc] initWithCapacity:10];
    teamNameListSorted = [[NSMutableArray alloc] initWithCapacity:10];
    //[teamNameListSorted addObject:kGameEntryTeamSelectorTitle];
    
    if ((teamDictionaryList == nil) || ([teamDictionaryList count] == 0)) {
        [teamNameListSorted addObject:kGameEntryTeamSelectorTitle];
        return;
    }
    
    for (NSDictionary *aTeam in teamDictionaryList) {
        NSString *teamName = [aTeam objectForKey:kTeamNameKey];
        if ((teamName != nil) && ([teamName length] > 0)){
            [teamNameListSorted addObject:teamName];
            [teamNameList addObject:teamName];
        }
    }
    [teamNameListSorted sortUsingSelector:@selector(caseInsensitiveCompare:)];
    // add title entry
    [teamNameListSorted insertObject:kGameEntryTeamSelectorTitle atIndex:0];
}

- (void)createPlayerNameListForTeam_A_UsingIndex:(long) teamIndex {
    //DebugLog(@"createPlayerNameListForTeam_A");
    [teamA_PlayerNameList release]; teamA_PlayerNameList = nil;
    //[teamA_PlayerNameListSorted release]; teamA_PlayerNameListSorted = nil;
    
    teamA_PlayerNameList = [[NSMutableArray alloc] initWithCapacity:10];
    [teamA_PlayerNameList addObject:kGameEntryPlayerSelectorTitle];
    //teamA_PlayerNameListSorted = [[NSMutableArray alloc] initWithCapacity:10];
    
    if ((teamDictionaryList == nil) || ([teamDictionaryList count] == 0)) {
        return;
    }
    if ((teamIndex < 0) || (teamIndex >= [teamDictionaryList count])) {
        return;
    }
    NSDictionary *theTeam = [teamDictionaryList objectAtIndex:teamIndex];
    for (int playerNumber = 1; playerNumber < 10; playerNumber++) {
        NSString *playerName = [theTeam objectForKey:[NSString stringWithFormat:kPlayerBaseKeyFormat, playerNumber]];
        if (playerName != nil) {
            // add name
            [teamA_PlayerNameList addObject:playerName];
            //[teamA_PlayerNameListSorted addObject:playerName];
        }
    }
    
    //[teamA_PlayerNameListSorted sortUsingSelector:@selector(caseInsensitiveCompare:)];
    // add title entry
    //[teamA_PlayerNameListSorted insertObject:kGameEntryPlayerSelectorTitle atIndex:0];
    // since list is being created, reset all player popup
    for (int playerNumber = 1; playerNumber <= kMaxPlayersDisplayedPerTeam; playerNumber++) {
        NSPopUpButton *thePlayerPopup = [[self view] viewWithTag:(kTeamATagValue + (playerNumber * kPlayerRowMultiplier) + kPlayerTagValue)];
        [thePlayerPopup removeAllItems];
        [thePlayerPopup addItemsWithTitles:teamA_PlayerNameList];
        [thePlayerPopup selectItemAtIndex:0];
        //DebugLog(@"createPlayerNameListForTeam_A - player: %i, popup items: %@", playerNumber, [thePlayerPopup itemArray]);
    }
    //DebugLog(@"Team A player name list: %@", teamA_PlayerNameList);
}


- (void)createPlayerNameListForTeam_B_UsingIndex:(long) teamIndex {
    //DebugLog(@"createPlayerNameListForTeam_B");
    [teamB_PlayerNameList release]; teamB_PlayerNameList = nil;
    //[teamB_PlayerNameListSorted release]; teamB_PlayerNameListSorted = nil;
    
    teamB_PlayerNameList = [[NSMutableArray alloc] initWithCapacity:10];
    [teamB_PlayerNameList addObject:kGameEntryPlayerSelectorTitle];
    //teamB_PlayerNameListSorted = [[NSMutableArray alloc] initWithCapacity:10];
    
    if ((teamDictionaryList == nil) || ([teamDictionaryList count] == 0)) {
        return;
    }
    if ((teamIndex < 0) || (teamIndex >= [teamDictionaryList count])) {
        return;
    }
    NSDictionary *theTeam = [teamDictionaryList objectAtIndex:teamIndex];
    for (int playerNumber = 1; playerNumber < 10; playerNumber++) {
        NSString *playerName = [theTeam objectForKey:[NSString stringWithFormat:kPlayerBaseKeyFormat, playerNumber]];
        if (playerName != nil) {
            // add name
            [teamB_PlayerNameList addObject:playerName];
            //[teamB_PlayerNameListSorted addObject:playerName];
        }
    }
    
    //[teamB_PlayerNameListSorted sortUsingSelector:@selector(caseInsensitiveCompare:)];
    // add title entry
    //[teamB_PlayerNameListSorted insertObject:kGameEntryPlayerSelectorTitle atIndex:0];
    // since list is being created, reset all player popup
    for (int playerNumber = 1; playerNumber <= kMaxPlayersDisplayedPerTeam; playerNumber++) {
        NSPopUpButton *thePlayerPopup = [[self view] viewWithTag:(kTeamBTagValue + (playerNumber * kPlayerRowMultiplier) + kPlayerTagValue)];
        [thePlayerPopup removeAllItems];
        [thePlayerPopup addItemsWithTitles:teamB_PlayerNameList];
        [thePlayerPopup selectItemAtIndex:0];
        //DebugLog(@"createPlayerNameListForTeam_B - player: %i, popup items: %@", playerNumber, [thePlayerPopup itemArray]);
    }
    //DebugLog(@"Team B player name list: %@", teamB_PlayerNameList);
}

- (void)setTeam:(long) teamTagValue Player:(long) playerPosition HiddenState:(BOOL) state {
    // question fields don't become visible if not being used
    for (int theQuestion = 0; theQuestion < kPointsTagValue; theQuestion++) {
        BOOL finalState = state;
        // if reveal question values, only reveal if question is selected
        if (!state) {
            finalState = !questionSelectedState[theQuestion];
        }
        long tag = teamTagValue + (playerPosition * kPlayerRowMultiplier) + theQuestion;
        //DebugLog(@"setTeam: %i, player: %i, view: %i, tag: %i, state: %@, final state: %@", teamTagValue, playerIndex, theView, tag, state ? @"hide" : @"reveal", finalState ? @"hide" : @"reveal");
        [[[self view] viewWithTag:tag] setHidden:finalState];
        // if revealing, make sure it is clear (init); if hiding clear so not counted
        [[[self view] viewWithTag:tag] setStringValue:@""];
    }
    // handle remaining fields
    for (int theView = kPointsTagValue; theView <= kPlayerTagValue; theView++) {
        long tag = teamTagValue + (playerPosition * kPlayerRowMultiplier) + theView;
        //DebugLog(@"setTeam: %i, player: %i, view: %i, tag: %i, state: %@", teamTagValue, playerIndex, theView, tag, state ? @"hide" : @"reveal");
        [[[self view] viewWithTag:tag] setHidden:state];
        // if revealing, make sure it is clear (init); if hiding clear so not counted
        if (theView != kPlayerTagValue) {
            [[[self view] viewWithTag:tag] setStringValue:@""];
        } else {
            // if hiding clear
            if (state) {
                NSPopUpButton *playerPop = [[self view] viewWithTag:tag];
                [playerPop removeAllItems];
                // leave title
                [playerPop addItemWithTitle:kGameEntryPlayerSelectorTitle];
                [playerPop selectItemAtIndex:0];
            }
        }
    }
}

- (void)setTeam:(long) teamTagValue Player:(long) playerPosition QuestionsEnabled:(BOOL) state {
    // question fields enabled only if games played > 0
    for (int theView = 0; theView < kPointsTagValue; theView++) {
        long tag = teamTagValue + (playerPosition * kPlayerRowMultiplier) + theView;
        //DebugLog(@"setTeam: %i, player: %i, view: %i, tag: %i, enable: %@", teamTagValue, playerPosition, theView, tag, state ? @"True" : @"False");
        [[[self view] viewWithTag:tag] setEnabled:state];
        // if disabling, make sure it is clear so not counted (done already by revealing / hiding player row)
//        if (!state) {
//            [[[self view] viewWithTag:tag] setStringValue:@""];
//        }
    }
}

- (void)bonusCalculation {
    long setting = [documentDelegate autoTrackSetting];
    if ((setting == kSQBS_Manual) || (setting == kSQBS_Bounceback)) {
        return;
    }
    
    long bonusHeard = 0;
    // Team A
    if ((setting == kSQBS_Automatic) || (setting == kSQBS_AutoBounceback)) {
        // determine bonus heard ( sum of all +tive questions - overtime )
        for (int playerPosition = 1; playerPosition <= kMaxPlayersDisplayedPerTeam; playerPosition++) {
            for (int question = kQuestion0TagValue; question <= kQuestion3TagValue; question++) {
                if (questionValue[question] > 0) {
                    bonusHeard += [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + (playerPosition * kPlayerRowMultiplier) + question)] integerValue];
                }
            }
        }
        if ([overTimeCheckBox state]) {
            bonusHeard -= [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + kOvertimeGetsTagValue)] integerValue];
        }
        [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + kBonusHeardTagValue)] setIntegerValue:bonusHeard];
    }
    if (setting != kSQBS_AutoBounceback) {
        // auto bounce back requires bonus points to be manually entered
        // determine bonus points ( score - lightening - sum of all players points )
        long bonusPoints = [(NSTextField *)[[self view] viewWithTag:kTeamATagValue] integerValue];  // init to score
        if ([documentDelegate trackLightRoundSetting]) {
            bonusPoints -= [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + kLighteningPointsTagValue)] integerValue];
        }
        for (int playerPosition = 1; playerPosition <= kMaxPlayersDisplayedPerTeam; playerPosition++) {
            bonusPoints -= [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + (playerPosition * kPlayerRowMultiplier) + kPointsTagValue)] integerValue];
        }
        [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + kBonusPointsTagValue)] setIntegerValue:bonusPoints];
    }
    
    bonusHeard = 0;
    // Team B
    if ((setting == kSQBS_Automatic) || (setting == kSQBS_AutoBounceback)) {
        // determine bonus heard ( sum of all +tive questions - overtime )
        for (int playerPosition = 1; playerPosition <= kMaxPlayersDisplayedPerTeam; playerPosition++) {
            for (int question = kQuestion0TagValue; question <= kQuestion3TagValue; question++) {
                if (questionValue[question] > 0) {
                    bonusHeard += [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + (playerPosition * kPlayerRowMultiplier) + question)] integerValue];
                }
            }
        }
        if ([overTimeCheckBox state]) {
            bonusHeard -= [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + kOvertimeGetsTagValue)] integerValue];
        }
        [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + kBonusHeardTagValue)] setIntegerValue:bonusHeard];
    }
    if (setting != kSQBS_AutoBounceback) {
        // auto bounce back requires bonus points to be manually entered
        // determine bonus points ( score - lightening - sum of all players points )
        long bonusPoints = [(NSTextField *)[[self view] viewWithTag:kTeamBTagValue] integerValue];  // init to score
        if ([documentDelegate trackLightRoundSetting]) {
            bonusPoints -= [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + kLighteningPointsTagValue)] integerValue];
        }
        for (int playerPosition = 1; playerPosition <= kMaxPlayersDisplayedPerTeam; playerPosition++) {
            bonusPoints -= [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + (playerPosition * kPlayerRowMultiplier) + kPointsTagValue)] integerValue];
        }
        [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + kBonusPointsTagValue)] setIntegerValue:bonusPoints];
    }
    
    if (setting == kSQBS_AutoBounceback) {
        // calculate bounceback points and heard
        // points = ( score - sum of all player points - bonus points )
        // team A
        long bouncebackPoints = [(NSTextField *)[[self view] viewWithTag:kTeamATagValue] integerValue];  // init to score
        bouncebackPoints -= [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + kBonusPointsTagValue)] integerValue];
        for (int playerPosition = 1; playerPosition <= kMaxPlayersDisplayedPerTeam; playerPosition++) {
            bouncebackPoints -= [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + (playerPosition * kPlayerRowMultiplier) + kPointsTagValue)] integerValue];
        }
        [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + kBounceBacksPointsTagValue)] setIntegerValue:bouncebackPoints];
        
        // team B
        bouncebackPoints = [(NSTextField *)[[self view] viewWithTag:kTeamBTagValue] integerValue];  // init to score
        bouncebackPoints -= [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + kBonusPointsTagValue)] integerValue];
        for (int playerPosition = 1; playerPosition <= kMaxPlayersDisplayedPerTeam; playerPosition++) {
            bouncebackPoints -= [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + (playerPosition * kPlayerRowMultiplier) + kPointsTagValue)] integerValue];
        }
        [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + kBounceBacksPointsTagValue)] setIntegerValue:bouncebackPoints];
        
        // calculate bouncebacks heard
        // bouncebacks heard = ( 30 * opposing bonus heard - opposing bonus )
        // team A
        long bouncebackHeard = 30 * [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + kBonusHeardTagValue)] integerValue];
        bouncebackHeard -= [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + kBonusPointsTagValue)] integerValue];
        [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + kBounceBacksHeardTagValue)] setIntegerValue:bouncebackHeard];
        // team A
        bouncebackHeard = 30 * [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + kBonusHeardTagValue)] integerValue];
        bouncebackHeard -= [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + kBonusPointsTagValue)] integerValue];
        [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + kBounceBacksHeardTagValue)] setIntegerValue:bouncebackHeard];
    }
}

- (void)updateTeamSelectorItemsForTeam:(long) teamTagValue itemToExclude:(NSString *)excludeItem {
    NSString *currentlySelectedTitle;
    //DebugLog(@"updateSelector - list: %@, excludeItem: %@", (AorB == 0)? @"A" : @"B", excludeItem);
    if (teamTagValue == kTeamATagValue) {
        // work on selector A
        // remember selected item
        currentlySelectedTitle = [teamSelectorPopUpTeamA titleOfSelectedItem];
        [teamSelectorPopUpTeamA removeAllItems];
        [teamSelectorPopUpTeamA addItemsWithTitles:teamNameListSorted];
        if (![excludeItem isEqualToString:kGameEntryTeamSelectorTitle]) {
            [teamSelectorPopUpTeamA removeItemWithTitle:excludeItem];
        }
        // reselect item
        [teamSelectorPopUpTeamA selectItemWithTitle:currentlySelectedTitle];
    } else {
        // work on selector B
        // remember selected item
        currentlySelectedTitle = [teamSelectorPopUpTeamB titleOfSelectedItem];
        [teamSelectorPopUpTeamB removeAllItems];
        [teamSelectorPopUpTeamB addItemsWithTitles:teamNameListSorted];
        if (![excludeItem isEqualToString:kGameEntryTeamSelectorTitle]) {
            [teamSelectorPopUpTeamB removeItemWithTitle:excludeItem];
        }
        // reselect item
        [teamSelectorPopUpTeamB selectItemWithTitle:currentlySelectedTitle];
    }
}

- (void)updatePlayerSelectorsForTeam:(long)teamTagValue DefaultInit:(BOOL)initGP {
    NSString *teamName = nil;
    long teamIndex = -1;
    if (teamTagValue == kTeamATagValue) {
        // check for no team selected
        if ([teamSelectorPopUpTeamA indexOfSelectedItem] == 0) {
            teamA_index = -1;
            // nothing to do
            return;
        }
        teamName = [teamSelectorPopUpTeamA titleOfSelectedItem];
        teamA_index = [teamNameList indexOfObject:teamName];
        teamIndex = teamA_index;
        // remove team from other selector list
        [self updateTeamSelectorItemsForTeam:kTeamBTagValue itemToExclude:teamName];
    } else {
        // check for no team selected
        if ([teamSelectorPopUpTeamB indexOfSelectedItem] == 0) {
            teamB_index = -1;
            // nothing to do
            return;
        }
        teamName = [teamSelectorPopUpTeamB titleOfSelectedItem];
        teamB_index = [teamNameList indexOfObject:teamName];
        teamIndex = teamB_index;
        // remove team from other selector list
        [self updateTeamSelectorItemsForTeam:kTeamATagValue itemToExclude:teamName];
    }
    
    // populate player info
    if ((teamIndex >= 0) && (teamIndex < [teamDictionaryList count])) {
        // create appropriate team list
        if (teamTagValue == kTeamATagValue) {
            [self createPlayerNameListForTeam_A_UsingIndex:teamIndex];
        } else {
            [self createPlayerNameListForTeam_B_UsingIndex:teamIndex];
        }
        
        NSDictionary *teamInfo = [teamDictionaryList objectAtIndex:teamIndex];
        int playersAdded = 0;
        for (int playerPosition = 1; playerPosition <= 8; playerPosition++) {
            NSString *playerKey = [NSString stringWithFormat:kPlayerBaseKeyFormat, playerPosition];
            NSString *playerName = [teamInfo objectForKey:playerKey];
            //DebugLog(@"updatePlayerSelectorsForTeam - teamTag: %i - playerIndex: %i, playerName: %@", teamTagValue, playerPosition, playerName);
            if (playerName == nil) {
                // clear line
                [self setTeam:teamTagValue Player:playerPosition HiddenState:TRUE];
            } else {
                // expose line
                [self setTeam:teamTagValue Player:playerPosition HiddenState:FALSE];
                // set name
                //[[[self view] viewWithTag:(kTeamATagValue + (playerIndex * kPlayerRowMultiplier) + kPlayerTagValue)] setStringValue:playerName];
                // select name
                [(NSPopUpButton *)[[self view] viewWithTag:(teamTagValue + (playerPosition * kPlayerRowMultiplier) + kPlayerTagValue)] selectItemWithTitle:playerName];
                //[self removePlayerSelectorItemForTeam:kTeamATagValue itemToExclude:playerName];
                // zero other fields
                for (int i = 0; i < kPlayerTagValue; i++) {
                    [[[self view] viewWithTag:(teamTagValue + (playerPosition * kPlayerRowMultiplier) + i)] setStringValue:@""];
                }
                // initialize game played for 1st 4 players (only if new game display)
                if (initGP) {
                    if (playersAdded < [documentDelegate defaultPlayersPerTeam]) {
                        // set games played to 1 and enable questions
                        [[[self view] viewWithTag:(teamTagValue + playerPosition * kPlayerRowMultiplier + kGamesPlayedTagValue)] setIntegerValue:1];
                        [self setTeam:teamTagValue Player:playerPosition QuestionsEnabled:TRUE];
                        playersAdded++;
                    } else {
                        // else disable questions
                        [self setTeam:teamTagValue Player:playerPosition QuestionsEnabled:FALSE];
                    }
                } else {
                    // else disable questions
                    [self setTeam:teamTagValue Player:playerPosition QuestionsEnabled:FALSE];
                }
            }
        }
    } else {
        for (int playerPosition = 1; playerPosition <= 8; playerPosition++) {
            // hide line
            [self setTeam:teamTagValue Player:playerPosition HiddenState:TRUE];
        }
        // clear player name list from each player popup
    }
}

//- (void)removePlayerSelectorItemForTeam:(long) teamTagValue itemToExclude:(NSString *)removedItem {
//    if ([removedItem isEqualToString:kGameEntryTeamSelectorTitle]) {
//        // can't remove title
//        return;
//    }
//    NSString *currentlySelectedTitle;
//    for (int p = 1; p <= kMaxPlayersDisplayedPerTeam; p++) {
//        NSPopUpButton *thisPlayerPopup = [[self view] viewWithTag:(teamTagValue + (p * kPlayerRowMultiplier) + kPlayerTagValue)];
//        // check if any items
//        if ([[thisPlayerPopup itemArray] count] <= 1) {
//            continue;
//        }
//        currentlySelectedTitle = [thisPlayerPopup titleOfSelectedItem];
//        if ([currentlySelectedTitle isEqualToString:removedItem]) {
//            // found player currently being selected, don't remove item from list
//            continue;
//        }
//        [thisPlayerPopup removeItemWithTitle:removedItem];
//        //DebugLog(@"removeSelectorItemForTeam - removed item: %@", removedItem);
//        // just to be sure
//        [thisPlayerPopup selectItemWithTitle:currentlySelectedTitle];
//    }
//}
//
//- (void)addPlayerSelectorItemForTeam:(long) teamTagValue itemToAdd:(NSString *)addItem {
//    if ([addItem isEqualToString:kGameEntryTeamSelectorTitle]) {
//        // can't add title
//        return;
//    }
//    NSString *currentlySelectedTitle;
//    for (int p = 1; p <= kMaxPlayersDisplayedPerTeam; p++) {
//        NSPopUpButton *thisPlayerPopup = [[self view] viewWithTag:(teamTagValue + (p * kPlayerRowMultiplier) + kPlayerTagValue)];
//        // check if any items
//        if ([thisPlayerPopup isHidden]) {
//            continue;
//        }
//        currentlySelectedTitle = [thisPlayerPopup titleOfSelectedItem];
//        if ([currentlySelectedTitle isEqualToString:addItem]) {
//            // shouldn't happen, but don't want to add again
//            continue;
//        }
//        NSMutableArray *tempTitles = [NSMutableArray arrayWithArray:[thisPlayerPopup itemTitles]];
//        // add and sort again
//        [tempTitles addObject:addItem];
//        [tempTitles sortUsingSelector:@selector(caseInsensitiveCompare:)];
//        [thisPlayerPopup addItemsWithTitles:tempTitles];
//        tempTitles = nil;
//        // re-select item
//        [thisPlayerPopup selectItemWithTitle:currentlySelectedTitle];
//    }
//}

- (void)clearScoringInfo {
    // clear team scores
    [(NSTextField *)[[self view] viewWithTag:kTeamATagValue] setStringValue:@""];
    [(NSTextField *)[[self view] viewWithTag:kTeamBTagValue] setStringValue:@""];
    
    // clear bonus heard, bonus points, overtime, lightening & tossUps heard
    for (int i = kBonusHeardTagValue; i <= kBounceBacksPointsTagValue; i++) {
        [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + i)] setStringValue:@""];
        [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + i)] setStringValue:@""];
    }
    
    // toss ups heard
    [[[self view] viewWithTag:kTossUpsHeardTagValue] setStringValue:@""];
}

- (void)clearGameDisplay {
    // hide all player entries
    for (int playerIndex = 1; playerIndex <= 8; playerIndex++) {
        [self setTeam:kTeamATagValue Player:playerIndex HiddenState:TRUE];
        [self setTeam:kTeamBTagValue Player:playerIndex HiddenState:TRUE];
    }
    
    // team selectors
    teamA_index = -1;
    [teamSelectorPopUpTeamA removeAllItems];
    [teamSelectorPopUpTeamA addItemsWithTitles:teamNameListSorted];
    [teamSelectorPopUpTeamA selectItemAtIndex:0];
    teamB_index = -1;
    [teamSelectorPopUpTeamB removeAllItems];
    [teamSelectorPopUpTeamB addItemsWithTitles:teamNameListSorted];
    [teamSelectorPopUpTeamB selectItemAtIndex:0];
    
    [self clearScoringInfo];
    
    // game admin info
    [[[self view] viewWithTag:kRoundTagValue] setStringValue:@""];
    // default game id is next number
    [[[self view] viewWithTag:kGameIDTagValue] setIntegerValue:[[documentDelegate gameList] count]];        
    [overTimeCheckBox setState:FALSE];
    [team_A_OvertimeBox setHidden:TRUE];
    [team_B_OvertimeBox setHidden:TRUE];
    [forfeitCheckBox setState:FALSE];
    [currentlyViewedGameID setStringValue:@""];
    
    [recordGameButton setEnabled:FALSE];
    
    // set Team A score as first entry field
    [[[self view] window] makeFirstResponder:[[self view] viewWithTag:kTeamATagValue]];
}

- (void)displayCurrentGame {
    selectedGameIndex = [currentViewedGameStepper intValue];
    //DebugLog(@"displayCurrentGame: game: %i, count: %i", currentGameIndex, [gameList count]);
    // start with clean display
    [self clearGameDisplay];
    if ((selectedGameIndex < 0) || (selectedGameIndex >= [[documentDelegate gameList] count])) {
        // sync stepper value
        [currentViewedGameStepper setIntegerValue:[[documentDelegate gameList] count]];
        // nothing more to do
        return;
    } else {
        Game *selectedGame = [[documentDelegate gameList] objectAtIndex:selectedGameIndex];
        //DebugLog(@"game to display: %@", [selectedGame description]);
        
        // game admin info
        [(NSTextField *)[[self view] viewWithTag:kRoundTagValue] setIntegerValue:[selectedGame round]];
        [(NSTextField *)[[self view] viewWithTag:kGameIDTagValue] setStringValue:[selectedGame gameIndex]];
        BOOL overTimeHidden = ([selectedGame overtime] > 0) ? FALSE : TRUE; // hidden state -tive of overtime indication
        [overTimeCheckBox setState:[selectedGame overtime]];
        [team_A_OvertimeBox setHidden:overTimeHidden];
        [team_B_OvertimeBox setHidden:overTimeHidden];
        
        if ([documentDelegate trackTossUpsHeardSetting]) {
            [[[self view] viewWithTag:kTossUpsHeardLabelTagValue] setHidden:FALSE];
            [[[self view] viewWithTag:kTossUpsHeardTagValue] setHidden:FALSE];
            [(NSTextField *)[[self view] viewWithTag:kTossUpsHeardTagValue] setIntegerValue:[selectedGame tossUpsHeard]];
        }
        
        [forfeitCheckBox setState:[selectedGame forfeit]];
        //[currentlyViewedGameID setStringValue:[selectedGame gameIndex]];
        
        // team selectors
        teamA_index = [selectedGame team_A_index];
        BOOL teamA_valid = TRUE;
        if ((teamA_index < 0) || (teamA_index > [teamDictionaryList count])) {
            // put up warning
            [self displayAlertMessage:@"File inconsistancy: Team A is not valid." InformationText:[NSString stringWithFormat:@"Team Index: %i out of range {0 - i%}.", teamA_index, ([teamDictionaryList count] - 1)]];
            teamA_index = -1;
            teamA_valid = FALSE;
        } else {
            // select team - will set up rows
            [teamSelectorPopUpTeamA selectItemWithTitle:[teamNameList objectAtIndex:teamA_index]];
            // create player list but don't init games played - read from Game
            [self updatePlayerSelectorsForTeam:kTeamATagValue DefaultInit:FALSE];
        }
        
        teamB_index = [selectedGame team_B_index];
        BOOL teamB_valid = TRUE;
        if ((teamB_index < 0) || (teamB_index > [teamDictionaryList count])) {
            // put up warning
            [self displayAlertMessage:@"File inconsistancy: Team B is not valid." InformationText:[NSString stringWithFormat:@"Team Index: %i out of range {0 - i%}.", teamB_index, ([teamDictionaryList count] - 1)]];
            teamB_index = -1;
            teamB_valid = FALSE;
        } else {
            if (teamA_index == teamB_index) {
                // can't have same team for both sides, put up warning
                [self displayAlertMessage:@"File inconsistancy: Team B same as Team A." InformationText:@"Team B stats will not be shown"];
                teamB_index = -1;
                teamB_valid = FALSE;
            } else {
                // select team - will set up rows
                [teamSelectorPopUpTeamB selectItemWithTitle:[teamNameList objectAtIndex:teamB_index]];
                // create player list but don't init games played - read from Game
                [self updatePlayerSelectorsForTeam:kTeamBTagValue DefaultInit:FALSE];
            }
        }
        //DebugLog(@"team indices: {%i, %i}, names: {%@, %@}", teamA_index, teamB_index, [teamNameList objectAtIndex:teamA_index], [teamNameList objectAtIndex:teamB_index]);
        
        if ([selectedGame forfeit]) {
            // just need to display scores
            [(NSTextField *)[[self view] viewWithTag:kTeamATagValue] setEnabled:FALSE];
            [(NSTextField *)[[self view] viewWithTag:kTeamBTagValue] setEnabled:FALSE];
            
            [(NSTextField *)[[self view] viewWithTag:kTeamATagValue] setStringValue:kForfeitWinScore];
            [(NSTextField *)[[self view] viewWithTag:kTeamBTagValue] setStringValue:kForfeitLossScore];
            return;
        }
        
        // scores
        [(NSTextField *)[[self view] viewWithTag:kTeamATagValue] setEnabled:TRUE];
        [(NSTextField *)[[self view] viewWithTag:kTeamBTagValue] setEnabled:TRUE];
        
        if (teamA_valid) {
            // score
            [(NSTextField *)[[self view] viewWithTag:kTeamATagValue] setStringValue:[selectedGame team_A_score]];
            
            // bonus info
            if ([documentDelegate trackBonusSetting]) {
                [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + kBonusHeardTagValue)] setIntegerValue:[selectedGame team_A_BonusHeard]];
                [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + kBonusPointsTagValue)] setIntegerValue:[selectedGame team_A_BonusPoints]];
                if (([documentDelegate autoTrackSetting] == kSQBS_Bounceback) || ([documentDelegate autoTrackSetting] == kSQBS_AutoBounceback)) {
                    [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + kBounceBacksHeardTagValue)] setIntegerValue:[selectedGame team_A_BounceBacksHeard]];
                    [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + kBounceBacksPointsTagValue)] setIntegerValue:[selectedGame team_A_BounceBacksPoints]];
                }
            }
            
            // overtime
            if ([selectedGame overtime]) {
                [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + kOvertimeGetsTagValue)] setIntegerValue:[selectedGame team_A_OvertimeGets]];
            }
            // lightning rounds
            if ([documentDelegate trackLightRoundSetting]) {
                [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + kLighteningPointsTagValue)] setIntegerValue:[selectedGame team_A_LighteningPoints]];
            }
        }
        if (teamB_valid) {
            // score
            [(NSTextField *)[[self view] viewWithTag:kTeamBTagValue] setStringValue:[selectedGame team_B_score]];
            
            // bonus info
            if ([documentDelegate trackBonusSetting]) {
                [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + kBonusHeardTagValue)] setIntegerValue:[selectedGame team_B_BonusHeard]];
                [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + kBonusPointsTagValue)] setIntegerValue:[selectedGame team_B_BonusPoints]];
                if (([documentDelegate autoTrackSetting] == kSQBS_Bounceback) || ([documentDelegate autoTrackSetting] == kSQBS_AutoBounceback)) {
                    [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + kBounceBacksHeardTagValue)] setIntegerValue:[selectedGame team_B_BounceBacksHeard]];
                    [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + kBounceBacksPointsTagValue)] setIntegerValue:[selectedGame team_B_BounceBacksPoints]];
                }
            }
            // overtime
            if ([selectedGame overtime]) {
                [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + kOvertimeGetsTagValue)] setIntegerValue:[selectedGame team_B_OvertimeGets]];
            }
            // lightning rounds
            if ([documentDelegate trackLightRoundSetting]) {
                [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + kLighteningPointsTagValue)] setIntegerValue:[selectedGame team_B_LighteningPoints]];
            }
        }
        
        // fill in points info
        // make list of players on team, if not added, set as 0 gp
        NSMutableArray *team_A_PlayersNotDisplayed = [NSMutableArray arrayWithArray:teamA_PlayerNameList];
        [team_A_PlayersNotDisplayed removeObject:kGameEntryPlayerSelectorTitle];
        NSMutableArray *team_B_PlayersNotDisplayed = [NSMutableArray arrayWithArray:teamB_PlayerNameList];
        [team_B_PlayersNotDisplayed removeObject:kGameEntryPlayerSelectorTitle];
        int team_A_PlayersDisplayed = 0;
        int team_B_PlayersDisplayed = 0;
        long baseTag = 0;
        NSString *playerName = nil;
        NSPopUpButton *thePopup = nil;
        for (int playerPosition = 1; playerPosition <= kMaxPlayersDisplayedPerTeam; playerPosition++) {
            Player *thePlayer = nil;
            float gamesPlayed = 0;
            // do team A
            if (teamA_valid) {
                thePlayer = [selectedGame getTeam_A_Player:(playerPosition - 1)];  // indexing in 0 - n range
                baseTag = kTeamATagValue + (playerPosition * kPlayerRowMultiplier);
                //DebugLog(@"Team A player %i: %@, base tag: %i", playerPosition, [thePlayer description], baseTag);
                // check if player index is beyond bounds of names (some files appear to have invalid entries for player indexes)
                if (([thePlayer playerIndex] + 1) < [teamA_PlayerNameList count]) {
                    if (thePlayer) {
                        // reveal fields
                        team_A_PlayersDisplayed++;
                        [self setTeam:kTeamATagValue Player:playerPosition HiddenState:FALSE];
                        // update fields
                        playerName = [teamA_PlayerNameList objectAtIndex:([thePlayer playerIndex] + 1)];  // add 1 to account for title
                        [team_A_PlayersNotDisplayed removeObject:playerName];
                        thePopup = [[self view] viewWithTag:(baseTag + kPlayerTagValue)];
                        [thePopup selectItemWithTitle:playerName];
                        [(NSTextField *)[[self view] viewWithTag:(baseTag + kGamesPlayedTagValue)] setStringValue:[thePlayer gamesPlayed]];
                        [(NSTextField *)[[self view] viewWithTag:(baseTag + kQuestion0TagValue)] setIntegerValue:[thePlayer question0Count]];
                        [(NSTextField *)[[self view] viewWithTag:(baseTag + kQuestion1TagValue)] setIntegerValue:[thePlayer question1Count]];
                        [(NSTextField *)[[self view] viewWithTag:(baseTag + kQuestion2TagValue)] setIntegerValue:[thePlayer question2Count]];
                        [(NSTextField *)[[self view] viewWithTag:(baseTag + kQuestion3TagValue)] setIntegerValue:[thePlayer question3Count]];
                        [(NSTextField *)[[self view] viewWithTag:(baseTag + kPointsTagValue)] setIntegerValue:[thePlayer points]];
                        // enable questions
                        gamesPlayed = [[thePlayer gamesPlayed] floatValue];
                        [self setTeam:kTeamATagValue Player:playerPosition QuestionsEnabled:(gamesPlayed > 0)];
                    }
                } else {
                    //DebugLog(@"displayCurrentGame bad Team A player index: %i, team: %i, max players: %i", [thePlayer playerIndex], teamA_index, ([teamA_PlayerNameList count] - 1));
                }
            }
            // do team B
            if (teamB_valid) {
                thePlayer = [selectedGame getTeam_B_Player:(playerPosition - 1)];  // indexing in 0 - n range
                baseTag = kTeamBTagValue + (playerPosition * kPlayerRowMultiplier);
                //DebugLog(@"Team B player %i: %@, base tag: %i", playerPosition, [thePlayer description], baseTag);
                // check if player index is beyond bounds of names (some files appear to have invalid entries for player indexes)
                if (([thePlayer playerIndex] + 1) < [teamB_PlayerNameList count]) {
                    if (thePlayer) {
                        // reveal fields
                        team_B_PlayersDisplayed++;
                        [self setTeam:kTeamBTagValue Player:playerPosition HiddenState:FALSE];
                        // update fields
                        playerName = [teamB_PlayerNameList objectAtIndex:([thePlayer playerIndex] + 1)];  // add 1 to account for title
                        [team_B_PlayersNotDisplayed removeObject:playerName];
                        thePopup = [[self view] viewWithTag:(baseTag + kPlayerTagValue)];
                        [thePopup selectItemWithTitle:playerName];
                        [(NSTextField *)[[self view] viewWithTag:(baseTag + kGamesPlayedTagValue)] setStringValue:[thePlayer gamesPlayed]];
                        [(NSTextField *)[[self view] viewWithTag:(baseTag + kQuestion0TagValue)] setIntegerValue:[thePlayer question0Count]];
                        [(NSTextField *)[[self view] viewWithTag:(baseTag + kQuestion1TagValue)] setIntegerValue:[thePlayer question1Count]];
                        [(NSTextField *)[[self view] viewWithTag:(baseTag + kQuestion2TagValue)] setIntegerValue:[thePlayer question2Count]];
                        [(NSTextField *)[[self view] viewWithTag:(baseTag + kQuestion3TagValue)] setIntegerValue:[thePlayer question3Count]];
                        [(NSTextField *)[[self view] viewWithTag:(baseTag + kPointsTagValue)] setIntegerValue:[thePlayer points]];
                        // enable questions
                        gamesPlayed = [[thePlayer gamesPlayed] floatValue];
                        [self setTeam:kTeamBTagValue Player:playerPosition QuestionsEnabled:(gamesPlayed > 0)];
                    }
                }else {
                    //DebugLog(@"displayCurrentGame bad Team B player index: %i, team: %i, max players: %i", [thePlayer playerIndex], teamB_index, ([teamB_PlayerNameList count] - 1));
                }
            }
        }
        
        // if any players not displayed set them up and '0' games played, no points
        int firstPossiblePosition = 1;
        // team A
        if (teamA_valid) {
            //DebugLog(@"team A: players displayed: %i, players not displayed: %@", team_A_PlayersDisplayed, team_A_PlayersNotDisplayed);
            while (([team_A_PlayersNotDisplayed count] > 0) && (team_A_PlayersDisplayed <= kMaxPlayersDisplayedPerTeam)) {
                // find slots to assign these players
                team_A_PlayersDisplayed++;
                playerName = [team_A_PlayersNotDisplayed objectAtIndex:0];
                [team_A_PlayersNotDisplayed removeObjectAtIndex:0];
                for (int playerPosition = firstPossiblePosition; playerPosition <= kMaxPlayersDisplayedPerTeam; playerPosition++) {
                    baseTag = kTeamATagValue + (playerPosition * kPlayerRowMultiplier);
                    thePopup = [[self view] viewWithTag:(baseTag + kPlayerTagValue)];
                    if ([thePopup indexOfSelectedItem] > 0) {
                        // position in use, skip
                        continue;
                    }
                    // assign this player and make games played 0
                    [thePopup selectItemWithTitle:playerName];
                    [[[self view] viewWithTag:(baseTag + kGamesPlayedTagValue)] setIntegerValue:0];
                    // disable questions
                    [self setTeam:kTeamATagValue Player:playerPosition QuestionsEnabled:FALSE];
                    firstPossiblePosition = playerPosition + 1;
                }
            }
        }
        
        // team B
        if (teamB_valid) {
            //DebugLog(@"team B: players displayed: %i, players not displayed: %@", team_B_PlayersDisplayed, team_B_PlayersNotDisplayed);
            firstPossiblePosition = 1;
            while (([team_B_PlayersNotDisplayed count] > 0) && (team_B_PlayersDisplayed <= kMaxPlayersDisplayedPerTeam)) {
                // find slots to assign these players
                team_B_PlayersDisplayed++;
                playerName = [team_B_PlayersNotDisplayed objectAtIndex:0];
                [team_B_PlayersNotDisplayed removeObjectAtIndex:0];
                for (int playerPosition = firstPossiblePosition; playerPosition <= kMaxPlayersDisplayedPerTeam; playerPosition++) {
                    baseTag = kTeamBTagValue + (playerPosition * kPlayerRowMultiplier);
                    thePopup = [[self view] viewWithTag:(baseTag + kPlayerTagValue)];
                    if ([thePopup indexOfSelectedItem] > 0) {
                        // position in use, skip
                        continue;
                    }
                    // assign this player and make games played 0
                    [thePopup selectItemWithTitle:playerName];
                    [[[self view] viewWithTag:(baseTag + kGamesPlayedTagValue)] setIntegerValue:0];
                    // disable questions
                    [self setTeam:kTeamBTagValue Player:playerPosition QuestionsEnabled:FALSE];
                    firstPossiblePosition = playerPosition + 1;
                }
            }
        }
        
        team_A_PlayersNotDisplayed = nil;
        team_B_PlayersNotDisplayed = nil;
    }
}

- (void)setBonusAndLighteningVisibility {
    // setup views based on selected options
    if ([documentDelegate trackLightRoundSetting]) {
        [team_A_LightningBox setHidden:FALSE];
        [team_B_LightningBox setHidden:FALSE];
    }
    if ([documentDelegate trackBonusSetting]) {
        [team_A_BonusBox setHidden:FALSE];
        [team_B_BonusBox setHidden:FALSE];
        switch ([documentDelegate autoTrackSetting]) {
            case kSQBS_Automatic: {
                // automatic tracking, disable points and heard boxes
                [[[self view] viewWithTag:(kTeamATagValue + kBonusHeardTagValue)] setEnabled:FALSE];
                [[[self view] viewWithTag:(kTeamATagValue + kBonusPointsTagValue)] setEnabled:FALSE];
                [[[self view] viewWithTag:(kTeamBTagValue + kBonusHeardTagValue)] setEnabled:FALSE];
                [[[self view] viewWithTag:(kTeamBTagValue + kBonusPointsTagValue)] setEnabled:FALSE];
                break;
            }
            case kSQBS_Manual: {
                // manual tracking, nothing needed, already enabled
                break;
            }
            case kSQBS_Combo: {
                // automatic points calculation but heard can be adjusted
                [[[self view] viewWithTag:(kTeamATagValue + kBonusPointsTagValue)] setEnabled:FALSE];
                [[[self view] viewWithTag:(kTeamBTagValue + kBonusPointsTagValue)] setEnabled:FALSE];
                break;
            }
            case kSQBS_Bounceback:
            case kSQBS_AutoBounceback: {
                // reveal bounce backs
                [team_A_BounceBacksBox setHidden:FALSE];
                [team_B_BounceBacksBox setHidden:FALSE];
//                [[[self view] viewWithTag:(kTeamATagValue + kBonusPointsTagValue)] setEnabled:FALSE];
//                [[[self view] viewWithTag:(kTeamBTagValue + kBonusPointsTagValue)] setEnabled:FALSE];
                break;
            }
                
            default:
                break;
        }
    }
}

- (void)handleTeamImportedNotification:(NSNotification *)notification {
    [self createTeamNameList];
    [teamSelectorPopUpTeamA removeAllItems];
    [teamSelectorPopUpTeamA addItemsWithTitles:teamNameListSorted];
    [teamSelectorPopUpTeamB removeAllItems];
    [teamSelectorPopUpTeamB addItemsWithTitles:teamNameListSorted];
}

- (void)handleFileLoadedNotification:(NSNotification *)notification {
    // assign question values - if not selected value is 0
    // should already be correct from tournament setup
    questionSelectedState[0] = [documentDelegate question_0_selected];
    long qValue = [documentDelegate question_0_value];
    if (!questionSelectedState[0]) {
        qValue = 0;
    }
    questionValue[0] = qValue;
    questionSelectedState[1] = [documentDelegate question_1_selected];
    qValue = [documentDelegate question_1_value];
    if (!questionSelectedState[1]) {
        qValue = 0;
    }
    questionValue[1] = qValue;
    questionSelectedState[2] = [documentDelegate question_2_selected];
    qValue = [documentDelegate question_2_value];
    if (!questionSelectedState[2]) {
        qValue = 0;
    }
    questionValue[2] = qValue;
    questionSelectedState[3] = [documentDelegate question_3_selected];
    qValue = [documentDelegate question_3_value];
    if (!questionSelectedState[3]) {
        qValue = 0;
    }
    questionValue[3] = qValue;
    
    // set titles and visibility for questions
    [self setQuestionLabelTitles];
    [self setQuestionColumnVisibility];
    
    [self setBonusAndLighteningVisibility];

    [[[self view] viewWithTag:kTossUpsHeardLabelTagValue] setHidden:![documentDelegate trackTossUpsHeardSetting]];
    [[[self view] viewWithTag:kTossUpsHeardTagValue] setHidden:![documentDelegate trackTossUpsHeardSetting]];
	
    // team lists
    [self handleTeamImportedNotification:nil];
    
    long gameToView = 0;
    if (([documentDelegate gameList] != nil) && ([[documentDelegate gameList] count] > 0)) {
        gameToView = [[documentDelegate gameList] count] - 1;
    }
    [currentViewedGameStepper setMaxValue:(gameToView + 1)]; // allows for new game blank game
    [currentViewedGameStepper setIntegerValue:gameToView];
    [currentStepperValueLabel setIntegerValue:gameToView];
    [totalGameCount setIntegerValue:gameToView];
    [self displayCurrentGame];
    // cancel notification if data has been loaded
    if (([documentDelegate teamList] != nil) && ([[documentDelegate teamList] count] > 0)) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kTeamFileImportedNotification object:nil];
    }
}

- (void)handlePopupWillPopupNotification:(NSNotification *)notification {
    //DebugLog(@"handlePopupWillPopupNotification - notification %@", [notification description]);
    NSPopUpButtonCell *thePopup = [notification object];
    if (([thePopup itemTitles] == nil) || ![[[thePopup itemTitles] objectAtIndex:0] isEqualToString:kGameEntryPlayerSelectorTitle]) {
        // not a player popup
        return;
    }
    [titleOfPlayerPopupBeforeSelection release];
    titleOfPlayerPopupBeforeSelection = [thePopup titleOfSelectedItem];
    [titleOfPlayerPopupBeforeSelection retain];
}

- (void)handleGamesSortedNotification:(NSNotification *)notification {
    //DebugLog(@"handleGamesSortedNotification);
    // after sorting show 1st game ??
    selectedGameIndex = 0;
    [currentViewedGameStepper setIntegerValue:0];
    [self displayCurrentGame];
}

-(NSString *)areThereWarnings:(Game *)checkGame ExistingWarnings:(NSString *)existingWarnings {
    // assumes test that both teams selected and valid has passed
    if (checkGame.forfeit) {
        // nothing to cause warning if forfeit
        return existingWarnings;
    }
    
    long teamA_IndividualPointsSum = 0;
    long teamB_IndividualPointsSum = 0;
    float teamA_gamesPlayed = 0;
    float teamB_gamesPlayed = 0;
    long teamA_BonusHeard = 0;
    long teamB_BonusHeard = 0;
    for (int p = 0; p < kMaxPlayersPerTeam; p++) {
        Player *thePlayer = [checkGame getTeam_A_Player:p];
        if (thePlayer && ([[thePlayer gamesPlayed] floatValue] > 0)) {
            teamA_IndividualPointsSum += [thePlayer points];
            teamA_gamesPlayed += [[thePlayer gamesPlayed] floatValue];
            if (questionValue[0] > 0) {
                teamA_BonusHeard += [thePlayer question0Count];
            }
            if (questionValue[1] > 0) {
                teamA_BonusHeard += [thePlayer question1Count];
            }
            if (questionValue[2] > 0) {
                teamA_BonusHeard += [thePlayer question2Count];
            }
            if (questionValue[3] > 0) {
                teamA_BonusHeard += [thePlayer question3Count];
            }
        }
        thePlayer = [checkGame getTeam_B_Player:p];
        if (thePlayer && ([[thePlayer gamesPlayed] floatValue] > 0)) {
            teamB_IndividualPointsSum += [thePlayer points];
            teamB_gamesPlayed += [[thePlayer gamesPlayed] floatValue];
            if (questionValue[0] > 0) {
                teamB_BonusHeard += [thePlayer question0Count];
            }
            if (questionValue[1] > 0) {
                teamB_BonusHeard += [thePlayer question1Count];
            }
            if (questionValue[2] > 0) {
                teamB_BonusHeard += [thePlayer question2Count];
            }
            if (questionValue[3] > 0) {
                teamB_BonusHeard += [thePlayer question3Count];
            }
        }
    }
    long teamA_PointsSum = teamA_IndividualPointsSum;
    long teamB_PointsSum = teamB_IndividualPointsSum;
    if ([documentDelegate trackLightRoundSetting]) {
        teamA_PointsSum += [checkGame team_A_LighteningPoints];
        teamB_PointsSum += [checkGame team_B_LighteningPoints];
    }
    if ([documentDelegate trackBonusSetting]) {
        teamA_PointsSum += [checkGame team_A_BonusPoints];
        teamB_PointsSum += [checkGame team_B_BonusPoints];
        if (([documentDelegate autoTrackSetting] == kSQBS_Bounceback) || ([documentDelegate autoTrackSetting] == kSQBS_AutoBounceback)) {
            teamA_PointsSum += [checkGame team_A_BounceBacksPoints];
            teamB_PointsSum += [checkGame team_B_BounceBacksPoints];
        }
    }
    if ([checkGame overtime]) {
        teamA_BonusHeard -= [checkGame team_A_OvertimeGets];
        teamB_BonusHeard -= [checkGame team_B_OvertimeGets];
    }
    long teamA_BonusPoints = [[checkGame team_A_score] intValue] - teamA_IndividualPointsSum - [checkGame team_A_LighteningPoints];
    long teamB_BonusPoints = [[checkGame team_B_score] intValue] - teamB_IndividualPointsSum - [checkGame team_B_LighteningPoints];
    
    // check that bonus and individual points = total score
    NSMutableString *warningsFound = [NSMutableString stringWithString:existingWarnings];
    if ([documentDelegate warning_3_Setting]) {
        if ([[checkGame team_A_score] intValue] != teamA_PointsSum) {
            [warningsFound appendFormat:@"- Individual and Bonus Scores do not add to Total score for team %@ (W-3)\n", [teamSelectorPopUpTeamA titleOfSelectedItem]];
        }
        if ([[checkGame team_B_score] intValue] != teamB_PointsSum) {
            [warningsFound appendFormat:@"- Individual and Bonus Scores do not add to Total score for team %@ (W-3)\n", [teamSelectorPopUpTeamB titleOfSelectedItem]];
        }
    }
    // check for games played <= allowed
    if ([documentDelegate warning_4_Setting]) {
        double maxGames = [documentDelegate defaultPlayersPerTeam] * 1.0 + 0.001;
        if (teamA_gamesPlayed > maxGames) {
            [warningsFound appendFormat:@"- Total games played > 4 for team %@\n", [teamSelectorPopUpTeamA titleOfSelectedItem]];
        }
        if (teamB_gamesPlayed > maxGames) {
            [warningsFound appendFormat:@"- Total games played > 4 for team %@\n", [teamSelectorPopUpTeamB titleOfSelectedItem]];
        }
    }
    if ([documentDelegate autoTrackSetting] == kSQBS_Automatic) {
        if ([documentDelegate warning_5_Setting]) {
            if (((teamA_BonusHeard > 0) && ((teamA_BonusPoints / teamA_BonusHeard) > 30.001)) || (teamA_BonusPoints < 0)) {
                [warningsFound appendFormat:@"- Bonus points not between 0 and 30 for team %@ (W-5)\n", [teamSelectorPopUpTeamA titleOfSelectedItem]];
            }
            if (((teamB_BonusHeard > 0) && ((teamB_BonusPoints / teamB_BonusHeard) > 30.001)) || (teamB_BonusPoints < 0)) {
                [warningsFound appendFormat:@"- Bonus points not between 0 and 30 for team %@ (W-5)\n", [teamSelectorPopUpTeamB titleOfSelectedItem]];
            }
        }
        if ([documentDelegate warning_6_Setting]) {
            if ((teamA_BonusHeard < 1) && (teamA_BonusPoints > 0)) {
                [warningsFound appendFormat:@"- Bonus points earned without being heard for team %@ (W-6)\n", [teamSelectorPopUpTeamA titleOfSelectedItem]];
            }
            if ((teamB_BonusHeard < 1) && (teamB_BonusPoints > 0)) {
                [warningsFound appendFormat:@"- Bonus points earned without being heard for team %@ (W-6)\n", [teamSelectorPopUpTeamB titleOfSelectedItem]];
            }
        }
    }
    if ([documentDelegate warning_7_Setting]) {
        if ([checkGame tossUpsHeard] < 0) {
            [warningsFound appendString:@"- Negative toss-ups heard. (W-7)"];
        }
    }
    // check if any warnings
    
    
    return warningsFound;
}

- (void) warningsAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(Game *)currentGame {
    if (currentGame == nil) {
        // nothing to save - case of simple alert
        return;
    }
    
    if (returnCode == NSAlertDefaultReturn) {
        // don't save game
        [currentGame release];
        return;
    }
    // go ahead and save game
    
    //DebugLog(@"saveCurrentGame game: %@", currentGame);
    if ((selectedGameIndex < 0) || (selectedGameIndex >= [[documentDelegate gameList] count])) {
        // new game - add to list
        [[documentDelegate gameList] addObject:currentGame];
    } else {
        // existing game - replace
        [[documentDelegate gameList] replaceObjectAtIndex:selectedGameIndex withObject:currentGame];
    }
    
    [currentGame release];
    
    [recordGameButton setEnabled:FALSE];;
    [documentDelegate updateChangeCount:NSChangeDone];
}

-(void)recordCurrentGame {
    // **********
    // similar code in swapSidesAction
    // **********
    
    // create Game base on displayed content
    if ((teamA_index < 0) || (teamB_index < 0)) {
        // missing team info, can't save
        // if both teams not selected don't bother with warning
        if (teamA_index == teamB_index) {
            return;
        }
        NSAlert *alert = [NSAlert alertWithMessageText:@"Both teams must be selected. Game not saved." defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
        [alert beginSheetModalForWindow:[recordGameButton window] modalDelegate:self didEndSelector:@selector(warningsAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
        alert = nil;
        return;
    }
    
    // force pending changes to be recorded
    [[[self view] window] makeFirstResponder:nil];
    
    NSMutableString *warnings = [NSMutableString stringWithString:@""];
    
    Game *currentGame = [[Game alloc] init];
    
    // minimum game info
    [currentGame setGameIndex:[(NSTextField *)[[self view] viewWithTag:kGameIDTagValue] stringValue]];
    long round = [(NSTextField *)[[self view] viewWithTag:kRoundTagValue] integerValue];
    [currentGame setRound:round];
    if (round < [documentDelegate minRoundsAssigned]) {
        [documentDelegate setMinRoundsAssigned:round];
    }
    if (round > [documentDelegate maxRoundsAssigned]) {
        [documentDelegate setMaxRoundsAssigned:round];
    }
    [currentGame setTeam_A_index:teamA_index];
    [currentGame setTeam_B_index:teamB_index];
    [currentGame setForfeit:[forfeitCheckBox state]];
    
    // first check if forfeit
    if (![forfeitCheckBox state]) {
        // capture scores
        // if no score entered store value -1
        NSString *score = [(NSTextField *)[[self view] viewWithTag:kTeamATagValue] stringValue];
        if ([score length] <= 0) {
            [currentGame setTeam_A_score:@"-1"];
        } else {
            [currentGame setTeam_A_score:score];
        }
        score = [(NSTextField *)[[self view] viewWithTag:kTeamBTagValue] stringValue];
        if ([score length] <= 0) {
            [currentGame setTeam_B_score:@"-1"];
        } else {
            [currentGame setTeam_B_score:score];
        }
        
        // overtime
        [currentGame setOvertime:[overTimeCheckBox state]];
        if ([overTimeCheckBox state]) {
            [currentGame setTeam_A_OvertimeGets:[(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + kOvertimeGetsTagValue)] integerValue]];
            [currentGame setTeam_B_OvertimeGets:[(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + kOvertimeGetsTagValue)] integerValue]];
        }
        
        // track lightening round
        if ([documentDelegate trackLightRoundSetting]) {
            [currentGame setTeam_A_LighteningPoints:[(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + kLighteningPointsTagValue)] integerValue]];
            [currentGame setTeam_B_LighteningPoints:[(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + kLighteningPointsTagValue)] integerValue]];
        } 
        
        // track toss ups heard
        if ([documentDelegate trackTossUpsHeardSetting]) {
            [currentGame setTossUpsHeard:[(NSTextField *)[[self view] viewWithTag:(kTossUpsHeardTagValue)] integerValue]];
        }
        
        // bonus heard and points
        if ([documentDelegate trackBonusSetting]) {
            [currentGame setTeam_A_BonusHeard:[(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + kBonusHeardTagValue)] integerValue]];
            [currentGame setTeam_A_BonusPoints:[(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + kBonusPointsTagValue)] integerValue]];
            [currentGame setTeam_B_BonusHeard:[(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + kBonusHeardTagValue)] integerValue]];
            [currentGame setTeam_B_BonusPoints:[(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + kBonusPointsTagValue)] integerValue]];
            if (([documentDelegate autoTrackSetting] == kSQBS_Bounceback) || ([documentDelegate autoTrackSetting] == kSQBS_AutoBounceback)) {
                [currentGame setTeam_A_BounceBacksHeard:[(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + kBounceBacksHeardTagValue)] integerValue]];
                [currentGame setTeam_A_BounceBacksPoints:[(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + kBounceBacksPointsTagValue)] integerValue]];
                [currentGame setTeam_B_BounceBacksHeard:[(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + kBounceBacksHeardTagValue)] integerValue]];
                [currentGame setTeam_B_BounceBacksPoints:[(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + kBounceBacksPointsTagValue)] integerValue]];
            }
        }
        
        // player details
        // test for repeated players
        NSMutableArray *playersSelectedTeamA = [NSMutableArray arrayWithCapacity:10];
        NSMutableArray *repeatedPlayersTeamA = [NSMutableArray arrayWithCapacity:10];
        NSMutableArray *playersSelectedTeamB = [NSMutableArray arrayWithCapacity:10];
        NSMutableArray *repeatedPlayersTeamB = [NSMutableArray arrayWithCapacity:10];
        for (int playerPosition = 0; playerPosition < kMaxPlayersDisplayedPerTeam; playerPosition++) {
            // team A
            long playerTagIncr = (playerPosition + 1) * kPlayerRowMultiplier;
            NSString *gamesPlayed = [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + playerTagIncr + kGamesPlayedTagValue)] stringValue];
            long playerIndex, q0Value, q1Value, q2Value, q3Value, pts;
            if ([gamesPlayed floatValue] > 0) {
                playerIndex = [(NSPopUpButton *)[[self view] viewWithTag:(kTeamATagValue + playerTagIncr + kPlayerTagValue)] indexOfSelectedItem] - 1;  // account for title
                NSNumber *indexAsObject = [NSNumber numberWithLong:playerIndex];
                if ([playersSelectedTeamA indexOfObject:indexAsObject] != NSNotFound) {
                    [repeatedPlayersTeamA addObject:indexAsObject];
                }
                [playersSelectedTeamA addObject:indexAsObject];
                if (playerIndex >= 0) {
                    q0Value = [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + playerTagIncr + kQuestion0TagValue)] integerValue];
                    q1Value = [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + playerTagIncr + kQuestion1TagValue)] integerValue];
                    q2Value = [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + playerTagIncr + kQuestion2TagValue)] integerValue];
                    q3Value = [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + playerTagIncr + kQuestion3TagValue)] integerValue];
                    pts = [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + playerTagIncr + kPointsTagValue)] integerValue]; 
                    [currentGame addTeam_A_player:playerPosition playerIndex:playerIndex gp:gamesPlayed q0:q0Value q1:q1Value q2:q2Value q3:q3Value points:pts];
                }
            }
            // team B
            gamesPlayed = [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + playerTagIncr + kGamesPlayedTagValue)] stringValue];
            if ([gamesPlayed floatValue] > 0) {
                playerIndex = [(NSPopUpButton *)[[self view] viewWithTag:(kTeamBTagValue + playerTagIncr + kPlayerTagValue)] indexOfSelectedItem] - 1;  // account for title
                NSNumber *indexAsObject = [NSNumber numberWithLong:playerIndex];
                if ([playersSelectedTeamB indexOfObject:indexAsObject] != NSNotFound) {
                    [repeatedPlayersTeamB addObject:indexAsObject];
                }
                [playersSelectedTeamB addObject:indexAsObject];
                if (playerIndex >= 0) {
                    q0Value = [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + playerTagIncr + kQuestion0TagValue)] integerValue];
                    q1Value = [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + playerTagIncr + kQuestion1TagValue)] integerValue];
                    q2Value = [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + playerTagIncr + kQuestion2TagValue)] integerValue];
                    q3Value = [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + playerTagIncr + kQuestion3TagValue)] integerValue];
                    pts = [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + playerTagIncr + kPointsTagValue)] integerValue]; 
                    [currentGame addTeam_B_player:playerPosition playerIndex:playerIndex gp:gamesPlayed q0:q0Value q1:q1Value q2:q2Value q3:q3Value points:pts];
                }
            }
        }
        // if check for repeated players do now
        if ([documentDelegate warning_2_Setting]) {
            if ([repeatedPlayersTeamA count] > 0) {
                // repeated players on team A, issue warning
                int playerNumber = [(NSNumber *)[repeatedPlayersTeamA objectAtIndex:0] intValue] + 1;
                [warnings appendFormat:@"- Team \"A\" player %@, entered more than once. (W-2)\n", [teamA_PlayerNameList objectAtIndex:playerNumber]];
            }
            if ([repeatedPlayersTeamB count] > 0) {
                // repeated players on team A, issue warning
                int playerNumber = [(NSNumber *)[repeatedPlayersTeamB objectAtIndex:0] intValue] + 1;
                [warnings appendFormat:@"- Team \"B\" player %@, entered more than once. (W-2)\n", [teamB_PlayerNameList objectAtIndex:playerNumber]];
            }
        }
        
        
    } else {
        // game is forfeit, mark special score values
        [currentGame setTeam_A_score:kForfeitWinScore];
        [currentGame setTeam_B_score:kForfeitLossScore];
    }
    
    warnings = [NSMutableString stringWithString:[self areThereWarnings:currentGame ExistingWarnings:warnings]];
    if ([warnings length] > 0) {
        // warnings put up alert
        NSAlert *alert = [NSAlert alertWithMessageText:@"Current game has the following warnings:" defaultButton:@"Review" alternateButton:@"Ignore" otherButton:nil informativeTextWithFormat:warnings];
        [alert beginSheetModalForWindow:[recordGameButton window] modalDelegate:self didEndSelector:@selector(warningsAlertDidEnd:returnCode:contextInfo:) contextInfo:currentGame];
        alert = nil;
        // don't save gave
        //[currentGame release];
        return;
    }
    
    //DebugLog(@"saveCurrentGame game: %@", currentGame);
    if ((selectedGameIndex < 0) || (selectedGameIndex >= [[documentDelegate gameList] count])) {
        // new game - add to list
        [[documentDelegate gameList] addObject:currentGame];
        // adjust max value for game stepper control
        [currentViewedGameStepper setMaxValue:[[documentDelegate gameList] count]]; // allows for new game blank game
        [totalGameCount setIntegerValue:([[documentDelegate gameList] count] - 1)];
    } else {
        // existing game - replace
        [[documentDelegate gameList] replaceObjectAtIndex:selectedGameIndex withObject:currentGame];
    }
    
    [currentGame release];
    
    [recordGameButton setEnabled:FALSE];;
    [documentDelegate updateChangeCount:NSChangeDone];
}

#pragma mark Life cycle

- (void)awakeFromNib
{    
    // only get notification if data hasn't been loaded
    if (([documentDelegate teamList] != nil) && ([[documentDelegate teamList] count] > 0)) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFileLoadedNotification:) name:kTeamFileImportedNotification object:nil];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePopupWillPopupNotification:) name:NSPopUpButtonCellWillPopUpNotification object:nil];
    
    // load team info - case of switching back and forth between views
    [self handleFileLoadedNotification:nil];
}

- (void)handleViewControllerClosing {
    // force update of any text fields
//    [[[self view] window] makeFirstResponder:nil];
//    // check if unrecorded game
//    // new unrecorded games lost
//    if ((selectedGameIndex >= 0) && (selectedGameIndex < [[documentDelegate gameList] count])) {
//        [self recordCurrentGame];
//    }
//    if ([saveGameButton isEnabled]) {
//        // if boths teams not selected ignore
//        if ((teamA_index > 0) && (teamB_index > 0)) {
//            [self saveCurrentGame];
//        }
//    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldViewClose {
//    [[[self view] window] makeFirstResponder:nil];
//    // check if unrecorded game
//    // new unrecorded games lost
//    if ((selectedGameIndex >= 0) && (selectedGameIndex < [[documentDelegate gameList] count])) {
//        [self recordCurrentGame];
//    }
//    if ([saveGameButton isEnabled]) {
//        // if boths teams not selected ignore
//        if ((teamA_index > 0) && (teamB_index > 0)) {
//            [self saveCurrentGame];
//        }
//    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    return TRUE;
}

-(void)prepareForGameSort {
    // if any unsaved changes save
    [[[self view] window] makeFirstResponder:nil];
    if ([recordGameButton isEnabled]) {
        [self recordCurrentGame];
    }
}

- (void)dealloc {
    //DebugLog(@"dealloc");
    [teamA_PlayerNameList release]; teamA_PlayerNameList = nil;
    //[teamA_PlayerNameListSorted release]; teamA_PlayerNameListSorted = nil;
    [teamB_PlayerNameList release]; teamB_PlayerNameList = nil;
    //[teamB_PlayerNameListSorted release]; teamB_PlayerNameListSorted = nil;
    [teamNameList release]; teamNameList = nil;
    [teamNameListSorted release]; teamNameListSorted = nil;
    [teamDictionaryList release]; teamDictionaryList = nil;
    [titleOfPlayerPopupBeforeSelection release]; titleOfPlayerPopupBeforeSelection = nil;
    [super dealloc];
}

#pragma mark Action methods

- (void)overTimeAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)context {
    if (returnCode == NSAlertDefaultReturn) {
        // default is to cancel, nothing more needed
        return;
    }
    
    // delete info and clear fields
    [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + kOvertimeGetsTagValue)] setStringValue:@""];
    [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + kOvertimeGetsTagValue)] setStringValue:@""];
    
    [team_A_OvertimeBox setHidden:TRUE];
    [team_B_OvertimeBox setHidden:TRUE];
    
    [recordGameButton setEnabled:TRUE];
}

- (IBAction)overTimeCheckBoxChecked:(id)sender {
    // hide / reveal overtime entry area based on checkbox setting
    BOOL visibilityState = ![sender state];
    //DebugLog(@"overTimeCheckBoxChecked - visibility state: %@", visibilityState ? @"hide" : @"show");
    if (visibilityState) {
        // about to not use overtime, check as this will delete any existing overtime info
        NSString *teamA = [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + kOvertimeGetsTagValue)] stringValue];
        NSString *teamB = [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + kOvertimeGetsTagValue)] stringValue];
        if (((teamA != nil) && [teamA length] > 0) 
            || ((teamB != nil) && [teamB length] > 0)) {
            if (([(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + kOvertimeGetsTagValue)] intValue] > 0) || ([(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + kOvertimeGetsTagValue)] intValue] > 0)) {
                NSAlert *alert = [NSAlert alertWithMessageText:@"Clearing 'overtime' will delete any existing overtime information. Continue?"
                                                 defaultButton:@"Cancel"
                                               alternateButton:@"Clear Overtime"
                                                   otherButton:nil
                                     informativeTextWithFormat:@" "];
                [alert beginSheetModalForWindow:[overTimeCheckBox window] modalDelegate:self didEndSelector:@selector(overTimeAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
                alert = nil;
                return;
            }
        }
    }
    
    [team_A_OvertimeBox setHidden:visibilityState];
    [team_B_OvertimeBox setHidden:visibilityState];
    
    [recordGameButton setEnabled:TRUE];
}

- (IBAction)viewStepperAction:(id)sender {
    //DebugLog(@"viewStepperAction: - value: %i, min: %i, max: %i", [(NSStepper *)sender intValue], [(NSStepper *)sender minValue], [(NSStepper *)sender maxValue]);
    if ([recordGameButton isEnabled]) {
        [self recordCurrentGame];
    }
    [currentStepperValueLabel setIntValue:[currentViewedGameStepper intValue]];
    [self displayCurrentGame];
}

- (IBAction)forfeitCheckBoxAction:(id)sender {
    // DebugLog(@"forfeitCheckBoxAction - state: %@", [(NSButton *)sender state]? @"On" : @"Off");
    if ([(NSButton *)sender state]) {
        // marking as forfeit
        // zero any scores
        [self clearScoringInfo];
        [[[self view] window] makeFirstResponder:nil];
        
        [(NSTextField *)[[self view] viewWithTag:kTeamATagValue] setEnabled:FALSE];
        [(NSTextField *)[[self view] viewWithTag:kTeamBTagValue] setEnabled:FALSE];
        // mark "W" / "L" in score box
        [(NSTextField *)[[self view] viewWithTag:kTeamATagValue] setStringValue:kForfeitWinScore];
        [(NSTextField *)[[self view] viewWithTag:kTeamBTagValue] setStringValue:kForfeitLossScore];
        
        [[[self view] window] makeFirstResponder:[[self view] viewWithTag:kRoundTagValue]];
    } else {
        [(NSTextField *)[[self view] viewWithTag:kTeamATagValue] setEnabled:TRUE];
        [(NSTextField *)[[self view] viewWithTag:kTeamBTagValue] setEnabled:TRUE];
        // clearing forfeit, remove "W" / "L" in score box
        [(NSTextField *)[[self view] viewWithTag:kTeamATagValue] setStringValue:@""];
        [(NSTextField *)[[self view] viewWithTag:kTeamBTagValue] setStringValue:@""];
        // add team info, teams already selected
        [self updatePlayerSelectorsForTeam:kTeamATagValue DefaultInit:TRUE];
        [self updatePlayerSelectorsForTeam:kTeamBTagValue DefaultInit:TRUE];
        [[[self view] window] makeFirstResponder:[[self view] viewWithTag:kTeamATagValue]];
    }
    [recordGameButton setEnabled:TRUE];
}

- (IBAction)teamSelectorActionTeamA:(id)sender {
    [self updatePlayerSelectorsForTeam:kTeamATagValue DefaultInit:TRUE];
    // set Team A score as first entry field
    [[[self view] window] makeFirstResponder:[[self view] viewWithTag:kTeamATagValue]];
}

- (IBAction)teamSelectorActionTeamB:(id)sender {
    [self updatePlayerSelectorsForTeam:kTeamBTagValue DefaultInit:TRUE];
    // set Team A score as first entry field
    [[[self view] window] makeFirstResponder:[[self view] viewWithTag:kTeamATagValue]];
    
}

- (IBAction)playerSelectorAction:(id)sender {
    NSPopUpButton *thisPlayer = (NSPopUpButton *)sender;
    if (![[thisPlayer titleOfSelectedItem] isEqualToString:titleOfPlayerPopupBeforeSelection]) {
        [recordGameButton setEnabled:TRUE];
    }
    [titleOfPlayerPopupBeforeSelection release];
    titleOfPlayerPopupBeforeSelection = nil;
}

- (IBAction)swapSidesAction:(id)sender {
    //DebugLog(@"swapTeam before - index: {%i, %i}, selected index: {%i, %i}", teamA_index, teamB_index, [teamSelectorPopUpTeamA indexOfSelectedItem], [teamSelectorPopUpTeamB indexOfSelectedItem]);
    // save team A info
    long currentTeamAIndex = teamA_index;
    long selectedTeamAIndex = [teamSelectorPopUpTeamA indexOfSelectedItem];
    NSArray *teamATitles = [NSArray arrayWithArray:[teamSelectorPopUpTeamA itemTitles]];
    // swap current Team B info into Team A
    [teamSelectorPopUpTeamA removeAllItems];
    [teamSelectorPopUpTeamA addItemsWithTitles:[teamSelectorPopUpTeamB itemTitles]];
    [teamSelectorPopUpTeamA selectItemAtIndex:[teamSelectorPopUpTeamB indexOfSelectedItem]];
    teamA_index = teamB_index;
    // set Team B info from saved
    [teamSelectorPopUpTeamB removeAllItems];
    [teamSelectorPopUpTeamB addItemsWithTitles:teamATitles];
    [teamSelectorPopUpTeamB selectItemAtIndex:selectedTeamAIndex];
    teamB_index = currentTeamAIndex;
    teamATitles = nil;
    
    [recordGameButton setEnabled:TRUE];
    
    if ([forfeitCheckBox state]) {
        // forfeit case - swap player info only, win always on left side
        [self updatePlayerSelectorsForTeam:kTeamATagValue DefaultInit:FALSE];
        [self updatePlayerSelectorsForTeam:kTeamBTagValue DefaultInit:FALSE];
        //DebugLog(@"swapTeam after - index: {%i, %i}, selected index: {%i, %i}", teamA_index, teamB_index, [teamSelectorPopUpTeamA indexOfSelectedItem], [teamSelectorPopUpTeamB indexOfSelectedItem]);
    } else {
        // **********
        // code taken from saveCurrentGame
        // **********
        
        // create Game base on displayed content
        if ((teamA_index < 0) && (teamB_index < 0)) {
            // no teams selected, nothing more to do
            return;
        }
        NSString *tempStringValue; // temp storage for string fields
        long tempIntValue; // temp storage for integer fields
        
        // capture scores
        tempStringValue = [(NSTextField *)[[self view] viewWithTag:kTeamATagValue] stringValue];
        [(NSTextField *)[[self view] viewWithTag:kTeamATagValue] setStringValue:[(NSTextField *)[[self view] viewWithTag:kTeamBTagValue] stringValue]];
        [(NSTextField *)[[self view] viewWithTag:kTeamBTagValue] setStringValue:tempStringValue];
        
        // overtime
        if ([overTimeCheckBox state]) {
            tempIntValue = [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + kOvertimeGetsTagValue)] integerValue];
            [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + kOvertimeGetsTagValue)] setIntegerValue:[(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + kOvertimeGetsTagValue)] integerValue]];
            [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + kOvertimeGetsTagValue)] setIntegerValue:tempIntValue];
        }
        
        // track lightening round
        if ([documentDelegate trackLightRoundSetting]) {
            tempIntValue = [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + kLighteningPointsTagValue)] integerValue];
            [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + kLighteningPointsTagValue)] setIntegerValue:[(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + kLighteningPointsTagValue)] integerValue]];
            [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + kLighteningPointsTagValue)] setIntegerValue:tempIntValue];
        }
        
        // bonus heard and points
        if ([documentDelegate trackBonusSetting]) {
            tempIntValue = [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + kBonusHeardTagValue)] integerValue];
            [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + kBonusHeardTagValue)] setIntegerValue:[(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + kBonusHeardTagValue)] integerValue]];
            [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + kBonusHeardTagValue)] setIntegerValue:tempIntValue];
            tempIntValue = [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + kBonusPointsTagValue)] integerValue];
            [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + kBonusPointsTagValue)] setIntegerValue:[(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + kBonusPointsTagValue)] integerValue]];
            [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + kBonusPointsTagValue)] setIntegerValue:tempIntValue];
            if (([documentDelegate autoTrackSetting] == kSQBS_Bounceback) || ([documentDelegate autoTrackSetting] == kSQBS_AutoBounceback)) {
                tempIntValue = [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + kBounceBacksHeardTagValue)] integerValue];
                [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + kBounceBacksHeardTagValue)] setIntegerValue:[(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + kBounceBacksHeardTagValue)] integerValue]];
                [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + kBounceBacksHeardTagValue)] setIntegerValue:tempIntValue];
                tempIntValue = [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + kBounceBacksPointsTagValue)] integerValue];
                [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + kBounceBacksPointsTagValue)] setIntegerValue:[(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + kBounceBacksPointsTagValue)] integerValue]];
                [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + kBounceBacksPointsTagValue)] setIntegerValue:tempIntValue];
            }
        }
        
        // player details
        BOOL tempHiddenState;
        BOOL tempEnabledState;
        for (int playerPosition = 1; playerPosition <= kMaxPlayersDisplayedPerTeam; playerPosition++) {
            long playerTagIncr = playerPosition * kPlayerRowMultiplier;
            tempHiddenState = [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + playerTagIncr + kGamesPlayedTagValue)] isHidden];
            tempStringValue = [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + playerTagIncr + kGamesPlayedTagValue)] stringValue];
            [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + playerTagIncr + kGamesPlayedTagValue)] setStringValue:[(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + playerTagIncr + kGamesPlayedTagValue)] stringValue]];
            [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + playerTagIncr + kGamesPlayedTagValue)] setHidden:[(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + playerTagIncr + kGamesPlayedTagValue)] isHidden]];
            [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + playerTagIncr + kGamesPlayedTagValue)] setStringValue:tempStringValue];
            [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + playerTagIncr + kGamesPlayedTagValue)] setHidden:tempHiddenState];
            // swap player popup combo settings
            NSArray *playerNames = [NSArray arrayWithArray:[(NSPopUpButton *)[[self view] viewWithTag:(kTeamATagValue + playerTagIncr + kPlayerTagValue)] itemTitles]];
            tempIntValue = [(NSPopUpButton *)[[self view] viewWithTag:(kTeamATagValue + playerTagIncr + kPlayerTagValue)] indexOfSelectedItem];
            tempHiddenState = [(NSPopUpButton *)[[self view] viewWithTag:(kTeamATagValue + playerTagIncr + kPlayerTagValue)] isHidden];
            [(NSPopUpButton *)[[self view] viewWithTag:(kTeamATagValue + playerTagIncr + kPlayerTagValue)] removeAllItems];
            [(NSPopUpButton *)[[self view] viewWithTag:(kTeamATagValue + playerTagIncr + kPlayerTagValue)] addItemsWithTitles:[(NSPopUpButton *)[[self view] viewWithTag:(kTeamBTagValue + playerTagIncr + kPlayerTagValue)] itemTitles]];
            [(NSPopUpButton *)[[self view] viewWithTag:(kTeamATagValue + playerTagIncr + kPlayerTagValue)] selectItemAtIndex:[(NSPopUpButton *)[[self view] viewWithTag:(kTeamBTagValue + playerTagIncr + kPlayerTagValue)] indexOfSelectedItem]];
            [(NSPopUpButton *)[[self view] viewWithTag:(kTeamATagValue + playerTagIncr + kPlayerTagValue)] setHidden:[(NSPopUpButton *)[[self view] viewWithTag:(kTeamBTagValue + playerTagIncr + kPlayerTagValue)] isHidden]];
            [(NSPopUpButton *)[[self view] viewWithTag:(kTeamBTagValue + playerTagIncr + kPlayerTagValue)] removeAllItems];
            [(NSPopUpButton *)[[self view] viewWithTag:(kTeamBTagValue + playerTagIncr + kPlayerTagValue)] addItemsWithTitles:playerNames];
            [(NSPopUpButton *)[[self view] viewWithTag:(kTeamBTagValue + playerTagIncr + kPlayerTagValue)] selectItemAtIndex:tempIntValue];
            [(NSPopUpButton *)[[self view] viewWithTag:(kTeamBTagValue + playerTagIncr + kPlayerTagValue)] setHidden:tempHiddenState];
            // swap player question and points
            for (int questionIndex = kQuestion0TagValue; questionIndex <= kPointsTagValue; questionIndex++) {
                tempIntValue = [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + playerTagIncr + questionIndex)] integerValue];
                tempHiddenState = [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + playerTagIncr + questionIndex)] isHidden];
                tempEnabledState = [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + playerTagIncr + questionIndex)] isEnabled];
                [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + playerTagIncr + questionIndex)] setIntegerValue:[(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + playerTagIncr + questionIndex)] integerValue]];
                [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + playerTagIncr + questionIndex)] setHidden:[(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + playerTagIncr + questionIndex)] isHidden]];
                [(NSTextField *)[[self view] viewWithTag:(kTeamATagValue + playerTagIncr + questionIndex)] setEnabled:[(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + playerTagIncr + questionIndex)] isEnabled]];
                [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + playerTagIncr + questionIndex)] setIntegerValue:tempIntValue];
                [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + playerTagIncr + questionIndex)] setHidden:tempHiddenState];
                [(NSTextField *)[[self view] viewWithTag:(kTeamBTagValue + playerTagIncr + questionIndex)] setEnabled:tempEnabledState];
            }
        }
        NSMutableArray *tempPlayerNames = [NSMutableArray arrayWithArray:teamA_PlayerNameList];
        [teamA_PlayerNameList release];
        teamA_PlayerNameList = [[NSMutableArray alloc] initWithArray:teamB_PlayerNameList];
        [teamB_PlayerNameList release];
        teamB_PlayerNameList = [[NSMutableArray alloc] initWithArray:tempPlayerNames];
    }
}

- (IBAction)saveGameAction:(id)sender {
    [self recordCurrentGame];
}

- (IBAction)deleteGameAction:(id)sender {
    if ((selectedGameIndex < 0) || (selectedGameIndex >= [[documentDelegate gameList] count])) {
        // new unsaved game, just clear display
        [self clearGameDisplay];
    } else {
        // warning ??
        [[documentDelegate gameList] removeObjectAtIndex:selectedGameIndex];
        // adjust max value for game stepper control
        long newMax = [[documentDelegate gameList] count] - 1;
        if (newMax < 0) {
            newMax = 0;
        }
        [currentViewedGameStepper setMaxValue:(newMax + 1)]; // allows for new game blank game
        [totalGameCount setIntegerValue:newMax];

        if ((selectedGameIndex < 0) || (selectedGameIndex >= [[documentDelegate gameList] count])) {
            // adjust index
            if ([[documentDelegate gameList] count] > 0) {
                selectedGameIndex = [[documentDelegate gameList] count] - 1;
            } else {
                selectedGameIndex = 0;
            }
            [currentViewedGameStepper setIntegerValue:selectedGameIndex];
        }
        [self displayCurrentGame];
        [documentDelegate updateChangeCount:NSChangeDone];
    }
}

#pragma mark NSTextFieldDelegate

- (void) textShouldEndEditingAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)context {
    // do nothing
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
    // most textfield use this method - determine which textfield based on tag value
    switch ([control tag]) {
        case (kRoundTagValue):
        case (kTossUpsHeardTagValue):
        case (kTeamATagValue + kBonusHeardTagValue):
        case (kTeamBTagValue + kBonusHeardTagValue):
        case (kTeamATagValue + kBonusPointsTagValue):
        case (kTeamBTagValue + kBonusPointsTagValue):
        case (kTeamATagValue + kBounceBacksHeardTagValue):
        case (kTeamBTagValue + kBounceBacksHeardTagValue):
        case (kTeamATagValue + kBounceBacksPointsTagValue):
        case (kTeamBTagValue + kBounceBacksPointsTagValue):
        {
            // just enable save game button
            [recordGameButton setEnabled:TRUE];
            return TRUE;
        }
        case kTeamATagValue:  // team A score
        case kTeamBTagValue:  // team B score
        case (kTeamATagValue + kOvertimeGetsTagValue):
        case (kTeamBTagValue + kOvertimeGetsTagValue):
        case (kTeamATagValue + kLighteningPointsTagValue):
        case (kTeamBTagValue + kLighteningPointsTagValue):
        {
            // just update bonus
            [self bonusCalculation];
            [recordGameButton setEnabled:TRUE];
            return TRUE;
        }
        case kGotoGameTagValue:
        {
            // goto game textfield
            NSString *gotoGame = [fieldEditor string];
            //DebugLog(@"find game: %@", gotoGame);
            // find game
            for (int gameRecord = 0; gameRecord < [[documentDelegate gameList] count]; gameRecord++) {
                Game *theGame = [[documentDelegate gameList] objectAtIndex:gameRecord];
                //DebugLog(@"checking game entry: %i - ID: %@", gameRecord, [theGame gameIndex]);
                if ([[theGame gameIndex] isEqualToString:gotoGame]) {
                    if ([recordGameButton isEnabled]) {
                        [self recordCurrentGame];
                    }
                    [currentViewedGameStepper setIntValue:gameRecord];
                    [currentStepperValueLabel setIntValue:gameRecord];
                    [self performSelectorOnMainThread:@selector(displayCurrentGame) withObject:nil waitUntilDone:NO];
                    return TRUE;
                }
                theGame = nil;
            }
            // game not found put up message
            NSAlert *alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:@"Game '%@' not found.", gotoGame] defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:nil];
            [alert beginSheetModalForWindow:[recordGameButton window] modalDelegate:self didEndSelector:@selector(textShouldEndEditingAlertDidEnd:returnCode:contextInfo:) contextInfo:nil];
            alert = nil;
            return TRUE;
        }
            case kGameIDTagValue:
        {
            [recordGameButton setEnabled:TRUE];
            return TRUE;
            break;
        }
            
        default:
            break;
    }
    // whats left should be question fields and games played
    long questionNumber = [control tag] % 10;
    long basePlayerTagValue = [control tag] - questionNumber;
    
    [recordGameButton setEnabled:TRUE];
    
    // check if questions textfields 
    if (questionNumber <= kQuestion3TagValue) {
        long pointsTagValue = [control tag] - questionNumber + kPointsTagValue;
        
        // calculate total points
        long points = ([[[self view] viewWithTag:(basePlayerTagValue + kQuestion0TagValue)] intValue] * questionValue[kQuestion0TagValue]) 
        + ([(NSTextField *)[[self view] viewWithTag:(basePlayerTagValue + kQuestion1TagValue)] intValue] * questionValue[kQuestion1TagValue]) 
        + ([(NSTextField *)[[self view] viewWithTag:(basePlayerTagValue + kQuestion2TagValue)] intValue] * questionValue[kQuestion2TagValue]) 
        + ([(NSTextField *)[[self view] viewWithTag:(basePlayerTagValue + kQuestion3TagValue)] intValue] * questionValue[kQuestion3TagValue]);
        // update field
        [(NSTextField *)[[self view] viewWithTag:pointsTagValue] setIntegerValue:points];
        //DebugLog(@"textShouldEndEditing - question: %i, text: %@, base tag: %i, points tag: %i, points: %i", questionNumber, [fieldEditor string], basePlayerTagValue, pointsTagValue, points);
        
        // update bonus
        [self bonusCalculation];
        return TRUE;
    } 
    
    if (questionNumber == kGamesPlayedTagValue) {
        // games played field
        // check if non number entered n/m, if so convert to decimal
        NSString *enteredValue = [fieldEditor string];
        NSArray *values = [enteredValue componentsSeparatedByString:@"/"];
        BOOL enableQuestions = FALSE;
        if ([values count] > 1) {
            if ([[values objectAtIndex:1] floatValue] > 0) {
                float num = [[values objectAtIndex:0] floatValue];
                float denom = [[values objectAtIndex:1] floatValue];
                float result = num / denom;
                if (result > (float)kMaxGamesPlayedPerPlayer) {
                    result = kMaxGamesPlayedPerPlayer;
                }
                if (result == floor(result)) {
                    // whole number
                    [(NSTextField *)control setIntValue:result];
                } else {
                    [fieldEditor setString:[NSString stringWithFormat:@"%.2f", result]];
                }
                enableQuestions = (result != 0);
            } else {
                // divide by 0, enter 0
                [fieldEditor setString:@"0"];
            }
        } else {
            // no "/" entered, make sure it is number
            float floatNum = [enteredValue floatValue];
            int intNum = [enteredValue intValue];
            if (floatNum < 0) {
                floatNum = -floatNum;
                intNum = -intNum;
            }
            if (floatNum == intNum) {
                // integer value
                if (intNum > kMaxGamesPlayedPerPlayer) {
                    intNum = kMaxGamesPlayedPerPlayer;
                }
                //DebugLog(@"games played: value: %i, max: %i", intNum, kMaxGamesPlayedPerPlayer);
                [(NSTextField *)control setIntValue:intNum];
                enableQuestions = (intNum != 0);
            } else {
                if (floatNum > (float)kMaxGamesPlayedPerPlayer) {
                    floatNum = kMaxGamesPlayedPerPlayer;
                }
                [fieldEditor setString:[NSString stringWithFormat:@"%.2f", floatNum]];
                enableQuestions = (floatNum != 0);
            }
        }
        values = nil;
        // enable questions if non-zero games played value
        // determine player number
        long playerIndex = (basePlayerTagValue / 10) % 10;
        long teamIndex = (basePlayerTagValue < kTeamBTagValue) ? kTeamATagValue : kTeamBTagValue;
        [self setTeam:teamIndex Player:playerIndex QuestionsEnabled:enableQuestions];
        
        // update bonus
        [self bonusCalculation];
        return  TRUE;
    }
    
    return TRUE;
}

@end
