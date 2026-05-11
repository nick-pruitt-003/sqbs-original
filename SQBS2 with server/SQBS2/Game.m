//
//  Game.m
//  SQBS
//
//  Created by Neil Smith on 11-12-07.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Game.h"
#import "Constants.h"
#import "Player.h"

@implementation Game

@synthesize gameIndex;
@synthesize team_A_index, team_B_index, team_A_score, team_B_score;
@synthesize tossUpsHeard;
@synthesize round;
@synthesize team_A_BonusHeard, team_A_BonusPoints, team_B_BonusHeard, team_B_BonusPoints;
@synthesize team_A_BounceBacksHeard, team_A_BounceBacksPoints, team_B_BounceBacksHeard, team_B_BounceBacksPoints;
@synthesize overtime;
@synthesize team_A_OvertimeGets, team_B_OvertimeGets;
@synthesize forfeit;
@synthesize team_A_LighteningPoints, team_B_LighteningPoints;

#define nullPlayer @"-"

-(void) addTeam_A_player:(long) playerNumber playerIndex:(long) playerIndex gp:(NSString *)gp q0:(long)q0 q1:(long)q1 q2:(long)q2 q3:(long)q3 points:(long)points
{
    if ((playerNumber < 0) || (playerNumber >= kMaxPlayersDisplayedPerTeam)) {
        return;
    }
    if (team_A_playerDetails == nil) {
        team_A_playerDetails = [[[NSMutableArray alloc] initWithCapacity:8] retain];
        // put objects in array so replace will work
        for (int i = 0; i < kMaxPlayersDisplayedPerTeam; i++) {
            [team_A_playerDetails addObject:nullPlayer];
        }
    }
    Player *thePlayer = [[Player alloc] init];
    [thePlayer setPlayerIndex:playerIndex];
    [thePlayer setGamesPlayed:gp];
    [thePlayer setQuestion0Count:q0];
    [thePlayer setQuestion1Count:q1];
    [thePlayer setQuestion2Count:q2];
    [thePlayer setQuestion3Count:q3];
    [thePlayer setPoints:points];
    [team_A_playerDetails replaceObjectAtIndex:playerNumber withObject:thePlayer];
    //DebugLog(@"add Team A - game: %@, player #: %i, player: %@", gameIndex, playerNumber, [thePlayer description]);
    [thePlayer release];
}

-(Player *)getTeam_A_Player:(long) playerNumber
{
    if ((playerNumber < 0) || (playerNumber >= kMaxPlayersDisplayedPerTeam) || (team_A_playerDetails == nil)) {
        return nil;
    }
    if (![[team_A_playerDetails objectAtIndex:playerNumber] isKindOfClass:[Player class]]) {
        return nil;
    }
    return [team_A_playerDetails objectAtIndex:playerNumber];
}

-(void) addTeam_B_player:(long) playerNumber playerIndex:(long) playerIndex gp:(NSString *)gp q0:(long)q0 q1:(long)q1 q2:(long)q2 q3:(long)q3 points:(long)points
{
    if ((playerNumber < 0) || (playerNumber >= kMaxPlayersDisplayedPerTeam)) {
        return;
    }
    if (team_B_playerDetails == nil) {
        team_B_playerDetails = [[[NSMutableArray alloc] initWithCapacity:8] retain];
        // put objects in array so replace will work
        for (int i = 0; i < kMaxPlayersDisplayedPerTeam; i++) {
            [team_B_playerDetails addObject:nullPlayer];
        }
    }
    Player *thePlayer = [[Player alloc] init];
    [thePlayer setPlayerIndex:playerIndex];
    [thePlayer setGamesPlayed:gp];
    [thePlayer setQuestion0Count:q0];
    [thePlayer setQuestion1Count:q1];
    [thePlayer setQuestion2Count:q2];
    [thePlayer setQuestion3Count:q3];
    [thePlayer setPoints:points];
    [team_B_playerDetails replaceObjectAtIndex:playerNumber withObject:thePlayer];
    //DebugLog(@"add Team B - game: %@, player #: %i, player: %@", gameIndex, playerNumber, [thePlayer description]);
    [thePlayer release];
}

-(Player *)getTeam_B_Player:(long) playerNumber
{
    if ((playerNumber < 0) || (playerNumber >= kMaxPlayersDisplayedPerTeam) || (team_B_playerDetails == nil)) {
        return nil;
    }
    if (![[team_B_playerDetails objectAtIndex:playerNumber] isKindOfClass:[Player class]]) {
        return nil;
    }
    return [team_B_playerDetails objectAtIndex:playerNumber];
}

-(NSString *)getTeamAQuestionPoints {
    long q0Total = 0;
    long q1Total = 0;
    long q2Total = 0;
    long q3Total = 0;
    if (team_A_playerDetails == nil) {
        return @"0/0/0/0";
    }
    for (int pIndex = 0; pIndex < [team_A_playerDetails count]; pIndex++) {
        if ([[team_A_playerDetails objectAtIndex:pIndex] isKindOfClass:[Player class]]) {
            Player *aPlayer = [team_A_playerDetails objectAtIndex:pIndex];
            q0Total += [aPlayer question0Count];
            q1Total += [aPlayer question1Count];
            q2Total += [aPlayer question2Count];
            q3Total += [aPlayer question3Count];
        }
        
    }
    return [NSString stringWithFormat:@"%i/%i/%i/%i", q0Total, q1Total, q2Total, q3Total];
}

-(NSString *)getTeamBQuestionPoints {
    long q0Total = 0;
    long q1Total = 0;
    long q2Total = 0;
    long q3Total = 0;
    if (team_B_playerDetails == nil) {
        return @"0/0/0/0";
    }
    for (int pIndex = 0; pIndex < [team_B_playerDetails count]; pIndex++) {
        if ([[team_B_playerDetails objectAtIndex:pIndex] isKindOfClass:[Player class]]) {
            Player *aPlayer = [team_B_playerDetails objectAtIndex:pIndex];
            q0Total += [aPlayer question0Count];
            q1Total += [aPlayer question1Count];
            q2Total += [aPlayer question2Count];
            q3Total += [aPlayer question3Count];
        }
        
    }
    return [NSString stringWithFormat:@"%i/%i/%i/%i", q0Total, q1Total, q2Total, q3Total];
}

-(NSString *)getTeamAResultsForPlayerWithNumber:(long)thePlayerNumber {
    if (team_A_playerDetails == nil) {
        return @"0/0/0/0/0/0";
    }
    for (int pIndex = 0; pIndex < [team_A_playerDetails count]; pIndex++) {
        if ([[team_A_playerDetails objectAtIndex:pIndex] isKindOfClass:[Player class]]) {
            Player *aPlayer = [team_A_playerDetails objectAtIndex:pIndex];
            if ([aPlayer playerIndex] == thePlayerNumber) {
                float gamesPlayed = [[aPlayer gamesPlayed] floatValue];
                if (gamesPlayed <= 0) {
                    return @"0/0/0/0/0/0";
                }
                return [NSString stringWithFormat:@"%.2f/%i/%i/%i/%i/%i", gamesPlayed, [aPlayer question0Count], [aPlayer question1Count], [aPlayer question2Count], [aPlayer question3Count], [aPlayer points]];
            }
        }
        
    }
    return @"0/0/0/0/0/0";
}

-(NSString *)getTeamBResultsForPlayerWithNumber:(long)thePlayerNumber {
    if (team_B_playerDetails == nil) {
        return @"0/0/0/0/0/0";
    }
    for (int pIndex = 0; pIndex < [team_B_playerDetails count]; pIndex++) {
        if ([[team_B_playerDetails objectAtIndex:pIndex] isKindOfClass:[Player class]]) {
            Player *aPlayer = [team_B_playerDetails objectAtIndex:pIndex];
            if ([aPlayer playerIndex] == thePlayerNumber) {
                float gamesPlayed = [[aPlayer gamesPlayed] floatValue];
                if (gamesPlayed <= 0) {
                    return @"0/0/0/0/0/0";
                }
                return [NSString stringWithFormat:@"%.2f/%i/%i/%i/%i/%i", gamesPlayed, [aPlayer question0Count], [aPlayer question1Count], [aPlayer question2Count], [aPlayer question3Count], [aPlayer points]];
            }
        }
        
    }
    return @"0/0/0/0/0/0";
}

-(NSString *)getTeamAResultsForPlayerAtIndex:(long)arrayIndex {
    if ((team_A_playerDetails == nil) || (arrayIndex < 0) || (arrayIndex >= [team_A_playerDetails count])) {
        return @"0/0/0/0/0/0/-1";
    }
    if ([[team_A_playerDetails objectAtIndex:arrayIndex] isKindOfClass:[Player class]]) {
        Player *aPlayer = [team_A_playerDetails objectAtIndex:arrayIndex];
        float gamesPlayed = [[aPlayer gamesPlayed] floatValue];
        if (gamesPlayed <= 0) {
            return @"0/0/0/0/0/0/0";
        }
        return [NSString stringWithFormat:@"%.2f/%i/%i/%i/%i/%i/%i", gamesPlayed, [aPlayer question0Count], [aPlayer question1Count], [aPlayer question2Count], [aPlayer question3Count], [aPlayer points],[aPlayer playerIndex]];
    }
    return @"0/0/0/0/0/0/-1";
}

-(NSString *)getTeamBResultsForPlayerAtIndex:(long)arrayIndex {
    if ((team_B_playerDetails == nil) || (arrayIndex < 0) || (arrayIndex >= [team_A_playerDetails count])) {
        return @"0/0/0/0/0/0/-1";
    }
    if ([[team_B_playerDetails objectAtIndex:arrayIndex] isKindOfClass:[Player class]]) {
        Player *aPlayer = [team_B_playerDetails objectAtIndex:arrayIndex];
        float gamesPlayed = [[aPlayer gamesPlayed] floatValue];
        if (gamesPlayed <= 0) {
            return @"0/0/0/0/0/0/0";
        }
        return [NSString stringWithFormat:@"%.2f/%i/%i/%i/%i/%i/%i", gamesPlayed, [aPlayer question0Count], [aPlayer question1Count], [aPlayer question2Count], [aPlayer question3Count], [aPlayer points],[aPlayer playerIndex]];
    }
    return @"0/0/0/0/0/0/-1";
}

-(long)getTeamATotalPlayerPoints {
    long total = 0;
    if (team_A_playerDetails != nil) {
        for (int pIndex = 0; pIndex < [team_A_playerDetails count]; pIndex++) {
            if ([[team_A_playerDetails objectAtIndex:pIndex] isKindOfClass:[Player class]]) {
                total += [(Player *)[team_A_playerDetails objectAtIndex:pIndex] points];
            }
        }
    }
    return total;
}

-(long)getTeamBTotalPlayerPoints {
    long total = 0;
    if (team_B_playerDetails != nil) {
        for (int pIndex = 0; pIndex < [team_B_playerDetails count]; pIndex++) {
            if ([[team_B_playerDetails objectAtIndex:pIndex] isKindOfClass:[Player class]]) {
                total += [(Player *)[team_B_playerDetails objectAtIndex:pIndex] points];
            }
        }
    }
    return total;
}

-(BOOL)countsExistForQuestion:(long)questionNumber {
    // check if any player has counts for the specfied question
    // return if once specified question non-zero count is found
    // Team A
    if (team_A_playerDetails != nil) {
        for (int p = 0; p < [team_A_playerDetails count]; p++) {
            if ([[team_A_playerDetails objectAtIndex:p] isKindOfClass:[Player class]]) {
                switch (questionNumber) {
                    case 0: {
                        if ([(Player *)[team_A_playerDetails objectAtIndex:p] question0Count] > 0) {
                            return TRUE;
                        }
                        break;
                    }
                    case 1: {
                        if ([(Player *)[team_A_playerDetails objectAtIndex:p] question1Count] > 0) {
                            return TRUE;
                        }
                        break;
                    }
                    case 2: {
                        if ([(Player *)[team_A_playerDetails objectAtIndex:p] question2Count] > 0) {
                            return TRUE;
                        }
                        break;
                    }
                    case 3: {
                        if ([(Player *)[team_A_playerDetails objectAtIndex:p] question3Count] > 0) {
                            return TRUE;
                        }
                        break;
                    }
                        
                    default:
                        break;
                }
            }
        }
    }
    // do Team B
    if (team_B_playerDetails != nil) {
        for (int p = 0; p < [team_B_playerDetails count]; p++) {
            if ([[team_B_playerDetails objectAtIndex:p] isKindOfClass:[Player class]]) {
                switch (questionNumber) {
                    case 0: {
                        if ([(Player *)[team_B_playerDetails objectAtIndex:p] question0Count] > 0) {
                            return TRUE;
                        }
                        break;
                    }
                    case 1: {
                        if ([(Player *)[team_B_playerDetails objectAtIndex:p] question1Count] > 0) {
                            return TRUE;
                        }
                        break;
                    }
                    case 2: {
                        if ([(Player *)[team_B_playerDetails objectAtIndex:p] question2Count] > 0) {
                            return TRUE;
                        }
                        break;
                    }
                    case 3: {
                        if ([(Player *)[team_B_playerDetails objectAtIndex:p] question3Count] > 0) {
                            return TRUE;
                        }
                        break;
                    }
                        
                    default:
                        break;
                }
            }
        }
    }
    return FALSE;
}

- (NSComparisonResult)sortGameByGameID:(Game *)aGame {
    NSString *aGameID = [aGame gameIndex];
    NSString *thisGameID = [self gameIndex];
    if (([aGameID rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]].location == NSNotFound) && ([thisGameID rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]].location == NSNotFound)) {
        // do a numeric sort
        float aGameAsNumber = [aGameID floatValue];
        float thisGameAsNumber = [thisGameID floatValue];
        if (thisGameAsNumber < aGameAsNumber) {
            return NSOrderedAscending;
        } else {
            if (thisGameAsNumber > aGameAsNumber) {
                return NSOrderedDescending;
            } else {
                return NSOrderedSame;
            }
        }
    }
    // do alpha sort
    return [[self gameIndex] localizedCaseInsensitiveCompare:[aGame gameIndex]];
}

- (NSComparisonResult)sortGameByRound:(Game *)aGame {
    if ([self round] == [aGame round]) {
        return NSOrderedSame;
    } else {
        if ([self round] < [aGame round]) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }
}

- (NSComparisonResult)sortGameByRoundThenGame:(Game *)aGame {
    if ([self round] == [aGame round]) {
        return [self sortGameByGameID:aGame];
    } else {
        if ([self round] < [aGame round]) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }
}

-(NSString *)createGameRecord {
    NSMutableString *record = [NSMutableString stringWithFormat:@"%@%@%@%i%@%i%@%@%@%@", kLineEndCharacter, gameIndex,
                               kLineEndCharacter, team_A_index,
                               kLineEndCharacter, team_B_index,
                               kLineEndCharacter, team_A_score,
                               kLineEndCharacter, team_B_score];
    
    [record appendFormat:@"%@%i%@%i%@%i%@%i%@%i%@%i", kLineEndCharacter, tossUpsHeard,
     kLineEndCharacter, round,
     // bounce back info stored with bonus info : aaaaabbbbb  aaaaa = bounce back, bbbbb = bonus
     kLineEndCharacter, (team_A_BonusHeard + (team_A_BounceBacksHeard * kBounceBackCodingMultiplier)),
     kLineEndCharacter, (team_A_BonusPoints + (team_A_BounceBacksPoints * kBounceBackCodingMultiplier)),
     kLineEndCharacter, (team_B_BonusHeard + (team_B_BounceBacksHeard * kBounceBackCodingMultiplier)),
     kLineEndCharacter, (team_B_BonusPoints + (team_B_BounceBacksPoints * kBounceBackCodingMultiplier))];
    
    [record appendFormat:@"%@%i%@%i%@%i%@%i%@%i%@%i", kLineEndCharacter, overtime,
     kLineEndCharacter, team_A_OvertimeGets,
     kLineEndCharacter, team_B_OvertimeGets,
     kLineEndCharacter, forfeit,
     kLineEndCharacter, team_A_LighteningPoints,
     kLineEndCharacter, team_B_LighteningPoints];
    
    for (int p = 0; p < 8; p++) {
        // add Team A player p info
        Player *thePlayer = [self getTeam_A_Player:p];
        if (thePlayer != nil) {
            [record appendString:[thePlayer createPlayerRecord]];
        } else {
            [record appendString:[Player nullPlayerRecord]];
        }
        // add Team B player p info
        thePlayer = [self getTeam_B_Player:p];
        if (thePlayer != nil) {
            [record appendString:[thePlayer createPlayerRecord]];
        } else {
            [record appendString:[Player nullPlayerRecord]];
        }
    }
    
    return record;
}

-(NSString *)description {
    NSMutableString *record = [NSMutableString stringWithFormat:@"Game: %@, Teams: {%i, %i}, Scores: {%@, %@}", gameIndex, team_A_index, team_B_index, team_A_score, team_B_score];
    if (team_A_playerDetails != nil) {
        [record appendString:@"\nTeam A players:\n"];
        for (int p = 0; p < 8; p++) {
            // add Team A player p info
            Player *thePlayer = [self getTeam_A_Player:p];
            if (thePlayer != nil) {
                [record appendFormat:@"%i: %@\n", p, thePlayer];
            }
        }
    }
    if (team_B_playerDetails != nil) {
        [record appendString:@"\nTeam B players:\n"];
        for (int p = 0; p < 8; p++) {
            // add Team A player p info
            Player *thePlayer = [self getTeam_B_Player:p];
            if (thePlayer != nil) {
                [record appendFormat:@"%i: %@\n", p, thePlayer];
            }
        }
    }
    return record;
}

- (void)dealloc {
    [gameIndex release];
    [team_A_score release];
    [team_B_score release];
    [team_A_playerDetails release];
    [team_B_playerDetails release];
    [super dealloc];
}

- (Game *)init {
    self = [super init];
    
    if (self != nil)
    {
        [self setGameIndex:@""];
        [self setTeam_A_index:-1];
        [self setTeam_B_index:-1];
        [self setTeam_A_score:@""];
        [self setTeam_B_score:@""];
        [self setTossUpsHeard:0];
        [self setRound:0];
        [self setTeam_A_BonusHeard:0];
        [self setTeam_A_BonusPoints:0];
        [self setTeam_B_BonusHeard:0];
        [self setTeam_B_BonusPoints:0];
        [self setTeam_A_BounceBacksHeard:0];
        [self setTeam_A_BounceBacksPoints:0];
        [self setTeam_B_BounceBacksHeard:0];
        [self setTeam_B_BounceBacksPoints:0];
        [self setOvertime:0];
        [self setTeam_A_OvertimeGets:0];
        [self setTeam_B_OvertimeGets:0];
        [self setForfeit:0];
        [self setTeam_A_LighteningPoints:0];
        [self setTeam_B_LighteningPoints:0];
        team_A_playerDetails = nil;
        team_B_playerDetails = nil;
    }
    
    return self;
}

@end
