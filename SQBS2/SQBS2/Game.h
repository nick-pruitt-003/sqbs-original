//
//  Game.h
//  SQBS
//
//  Created by Neil Smith on 11-12-07.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Player.h"

@interface Game : NSObject {
    
    NSString *gameIndex;
    long team_A_index;
    long team_B_index;
    NSString *team_A_score;  // to allow for "W" / "L" settings in case of forfeit
    NSString *team_B_score;
    long tossUpsHeard;
    long round;
    long team_A_BonusHeard;
    long team_A_BonusPoints;
    long team_B_BonusHeard;
    long team_B_BonusPoints;
    long team_A_BounceBacksHeard;
    long team_A_BounceBacksPoints;
    long team_B_BounceBacksHeard;
    long team_B_BounceBacksPoints;
    long overtime;
    long team_A_OvertimeGets;
    long team_B_OvertimeGets;
    long forfeit;
    long team_A_LighteningPoints;
    long team_B_LighteningPoints;
    
    NSMutableArray *team_A_playerDetails;
    NSMutableArray *team_B_playerDetails;
    
}


@property (copy) NSString *gameIndex;
@property (assign) long team_A_index;
@property (assign) long team_B_index;
@property (copy) NSString *team_A_score;  // to allow for "W" / "L" settings in case of forfeit
@property (copy) NSString *team_B_score;
@property (assign) long tossUpsHeard;
@property (assign) long round;
@property (assign) long team_A_BonusHeard;
@property (assign) long team_A_BonusPoints;
@property (assign) long team_B_BonusHeard;
@property (assign) long team_B_BonusPoints;
@property (assign) long team_A_BounceBacksHeard;
@property (assign) long team_A_BounceBacksPoints;
@property (assign) long team_B_BounceBacksHeard;
@property (assign) long team_B_BounceBacksPoints;
@property (assign) long overtime;
@property (assign) long team_A_OvertimeGets;
@property (assign) long team_B_OvertimeGets;
@property (assign) long forfeit;
@property (assign) long team_A_LighteningPoints;
@property (assign) long team_B_LighteningPoints;

-(void) addTeam_A_player:(long) playerNumber playerIndex:(long) playerIndex gp:(NSString *)gp q0:(long)q0 q1:(long)q1 q2:(long)q2 q3:(long)q3 points:(long)points;
-(void) addTeam_B_player:(long) playerNumber playerIndex:(long) playerIndex gp:(NSString *)gp q0:(long)q0 q1:(long)q1 q2:(long)q2 q3:(long)q3 points:(long)points;
-(Player *)getTeam_A_Player:(long) playerNumber;
-(Player *)getTeam_B_Player:(long) playerNumber;

-(NSString *)getTeamAQuestionPoints;
-(NSString *)getTeamBQuestionPoints;

-(NSString *)getTeamAResultsForPlayerWithNumber:(long)thePlayerNumber;
-(NSString *)getTeamBResultsForPlayerWithNumber:(long)thePlayerNumber;

-(NSString *)getTeamAResultsForPlayerAtIndex:(long)arrayIndex;
-(NSString *)getTeamBResultsForPlayerAtIndex:(long)arrayIndex;

-(long)getTeamATotalPlayerPoints;
-(long)getTeamBTotalPlayerPoints;

-(NSString *)createGameRecord;

-(NSComparisonResult)sortGameByGameID:(Game *)aGame;
-(NSComparisonResult)sortGameByRound:(Game *)aGame;
-(NSComparisonResult)sortGameByRoundThenGame:(Game *)aGame;

-(BOOL)countsExistForQuestion:(long)questionNumber;

-(NSString *)description;



@end
