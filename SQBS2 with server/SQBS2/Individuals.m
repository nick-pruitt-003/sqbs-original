//
//  Individuals.m
//  SQBS
//
//  Created by Neil Smith on 11-12-28.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Individuals.h"

@implementation Individuals

@synthesize playerName, teamName;
@synthesize teamIndex;
@synthesize gamesPlayed;
@synthesize q0, q1, q2, q3;
@synthesize points, tossUpsHeard;
@synthesize position;

- (Individuals *)init {
    self = [super init];
    
    if (self != nil)
    {
        [self setPlayerName:@""];
        [self setTeamName:@""];
        [self setTeamIndex:-1];
        [self setGamesPlayed:0];
        [self setQ0:0];
        [self setQ1:0]; 
        [self setQ2:0];
        [self setQ3:0];
        [self setPoints:0];
        [self setTossUpsHeard:0];
        [self setPosition:0];
    }
    return self;
}

- (NSString *)description {
    NSMutableString *record = [NSMutableString stringWithFormat:@"Player/Team: %@/%@, gp: %.2f, 0/1/2/3: {%i, %i, %i, %i}, pts/tuh: {%i, %i}, index: P%i_%i", playerName, teamName, gamesPlayed, q0, q1, q2, q3, points, tossUpsHeard, position, teamIndex];
    
    return record;
}

@end
