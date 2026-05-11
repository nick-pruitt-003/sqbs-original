//
//  Standing.m
//  SQBS
//
//  Created by Neil Smith on 11-12-28.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Standing.h"

@implementation Standing

@synthesize teamName;
@synthesize teamIndex, index2, win, loss, tie, forfeitWin, forfeitLoss;
@synthesize pct, ptsPerGame;
@synthesize gamesPlayed, pointsFor, pointsAgainst, tossUpsHeard, lightning;
@synthesize bonusHeard, bonusPoints, bouncebacksHeard, bouncebacksPoints;
@synthesize q0, q1, q2, q3;
@synthesize position;
@synthesize strengthStanding;


- (Standing *)init {
    self = [super init];
    
    if (self != nil)
    {
        [self setTeamName:@""];
        [self setTeamIndex:-1];
        [self setIndex2:-1];
        [self setWin:0];
        [self setLoss:0];
        [self setTie:0];
        [self setForfeitWin:0];
        [self setForfeitLoss:0];
        [self setPct:0];
        [self setPtsPerGame:0];
        [self setGamesPlayed:0];
        [self setPointsFor:0];
        [self setPointsAgainst:0];
        [self setTossUpsHeard:0];
        [self setLightning:0];
        [self setBonusHeard:0];
        [self setBonusPoints:0];
        [self setBouncebacksHeard:0];
        [self setBouncebacksPoints:0];
        [self setQ0:0];
        [self setQ1:0]; 
        [self setQ2:0];
        [self setQ3:0];
        [self setPosition:0];
        [self setStrengthStanding:0];
    }
    
    return self;
}


- (NSString *)description {
    NSMutableString *record = [NSMutableString stringWithFormat:@"Team: %@, W/L/T: {%li, %li, %li}, pf/pa: {%li, %li}, pos: %li, strength: %0.2f", teamName, win, loss, tie, pointsFor, pointsAgainst, position, strengthStanding];
    
    return record;
}

@end
