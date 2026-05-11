//
//  RoundData.h
//  SQBS
//
//  Created by Neil Smith on 11-12-29.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RoundData : NSObject
{
    long gamesPlayed;
    long points;
    long tossUpsHeard;
    long lightning;
    long bonusHeard;
    long bonusPoints;
    long bouncebacksHeard;
    long bouncebacksPoints;
    long tossUpsPoints;
}

@property (assign) long gamesPlayed;
@property (assign) long points;
@property (assign) long tossUpsHeard;
@property (assign) long lightning;
@property (assign) long bonusHeard;
@property (assign) long bonusPoints;
@property (assign) long bouncebacksHeard;
@property (assign) long bouncebacksPoints;
@property (assign) long tossUpsPoints;

-(NSString *)description;

@end
