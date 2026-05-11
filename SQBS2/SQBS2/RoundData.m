//
//  RoundData.m
//  SQBS
//
//  Created by Neil Smith on 11-12-29.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RoundData.h"

@implementation RoundData

@synthesize gamesPlayed, points, tossUpsHeard, lightning;
@synthesize tossUpsPoints;
@synthesize bonusHeard, bonusPoints, bouncebacksHeard, bouncebacksPoints;


- (RoundData *)init {
    self = [super init];
    
    if (self != nil)
    {
        [self setGamesPlayed:0];
        [self setPoints:0];
        [self setTossUpsHeard:0];
        [self setTossUpsPoints:0];
        [self setLightning:0];
        [self setBonusHeard:0];
        [self setBonusPoints:0];
        [self setBouncebacksHeard:0];
        [self setBouncebacksPoints:0];
    }
    
    return self;
}

- (NSString *)description {
    NSMutableString *record = [NSMutableString stringWithFormat:@"gp: %li, pts: %li, TUH/TUPts: {%li, %li}, bh/bp: {%li, %li}, bbh/bbp: {%li, %li}", gamesPlayed, points, tossUpsHeard, tossUpsPoints, bonusHeard, bonusPoints, bouncebacksHeard, bouncebacksPoints];
    
    return record;
}

@end
