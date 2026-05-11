//
//  Player.m
//  SQBS
//
//  Created by Neil Smith on 11-12-07.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Player.h"
#import "Constants.h"

@implementation Player

@synthesize playerIndex;
@synthesize gamesPlayed;
@synthesize question0Count;
@synthesize question1Count;
@synthesize question2Count;
@synthesize question3Count;
@synthesize points;


+(NSString *)nullPlayerRecord {
    return [NSString stringWithFormat:@"%@-1%@0%@0%@0%@0%@0%@0", kLineEndCharacter, kLineEndCharacter, kLineEndCharacter, kLineEndCharacter, kLineEndCharacter, kLineEndCharacter, kLineEndCharacter];
}

-(NSString *)createPlayerRecord {
    return [NSString stringWithFormat:@"%@%i%@%@%@%i%@%i%@%i%@%i%@%i", kLineEndCharacter, playerIndex,
            kLineEndCharacter, gamesPlayed,
            kLineEndCharacter, question0Count,
            kLineEndCharacter, question1Count,
            kLineEndCharacter, question2Count,
            kLineEndCharacter, question3Count,
            kLineEndCharacter, points];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"Player: %i%, {%@, %i, %i, %i, %i, %i}", playerIndex, gamesPlayed, question0Count, question1Count, question2Count, question3Count, points];
}

- (void)dealloc {
    [gamesPlayed release];
    [super dealloc];
}

- (Player *)init {
    self = [super init];
    
    if (self != nil)
    {
        [self setPlayerIndex:-1];
        [self setGamesPlayed:@""];
        [self setQuestion0Count:0];
        [self setQuestion1Count:0];
        [self setQuestion2Count:0];
        [self setQuestion3Count:0];
        [self setPoints:0];
    }
    
    return self;
}

@end
