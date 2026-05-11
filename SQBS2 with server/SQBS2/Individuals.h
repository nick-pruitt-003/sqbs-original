//
//  Individuals.h
//  SQBS
//
//  Created by Neil Smith on 11-12-28.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Individuals : NSObject
{
    NSString *playerName;
    NSString *teamName;
    long teamIndex;
    float gamesPlayed;
    long q0;
    long q1;
    long q2;
    long q3;
    long points;
    long tossUpsHeard;
    long position;
}

@property (retain) NSString *playerName;
@property (retain) NSString *teamName;
@property (assign) long teamIndex;
@property (assign) float gamesPlayed;
@property (assign) long q0;
@property (assign) long q1;
@property (assign) long q2;
@property (assign) long q3;
@property (assign) long points;
@property (assign) long tossUpsHeard;
@property (assign) long position;

-(NSString *)description;

@end
