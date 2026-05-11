//
//  Standing.h
//  SQBS
//
//  Created by Neil Smith on 11-12-28.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Standing : NSObject
{
    NSString *teamName;
    long teamIndex;
    long index2;
    long win;
    long loss;
    long tie;
    long forfeitWin;
    long forfeitLoss;
    float pct;
    float ptsPerGame;
    long gamesPlayed;
    long pointsAgainst;
    long pointsFor;
    long tossUpsHeard;
    long lightning;
    long bonusHeard;
    long bonusPoints;
    long bouncebacksHeard;
    long bouncebacksPoints;
    long q0;
    long q1;
    long q2;
    long q3;
    long position;
    float strengthStanding;
}

@property (retain) NSString *teamName;
@property (assign) long teamIndex;
@property (assign) long index2;
@property (assign) long win;
@property (assign) long loss;
@property (assign) long tie;
@property (assign) long forfeitWin;
@property (assign) long forfeitLoss;
@property (assign) float pct;
@property (assign) float ptsPerGame;
@property (assign) long gamesPlayed;
@property (assign) long pointsAgainst;
@property (assign) long pointsFor;
@property (assign) long tossUpsHeard;
@property (assign) long lightning;
@property (assign) long bonusHeard;
@property (assign) long bonusPoints;
@property (assign) long bouncebacksHeard;
@property (assign) long bouncebacksPoints;
@property (assign) long q0;
@property (assign) long q1;
@property (assign) long q2;
@property (assign) long q3;
@property (assign) long position;
@property (assign) float strengthStanding;


-(NSString *)description;

@end
