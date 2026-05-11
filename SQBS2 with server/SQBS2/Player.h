//
//  Player.h
//  SQBS
//
//  Created by Neil Smith on 11-12-07.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Player : NSObject
{
    long playerIndex;
    NSString *gamesPlayed;
    long question0Count;
    long question1Count;
    long question2Count;
    long question3Count;
    long points;
}

@property (assign) long playerIndex;
@property (retain) NSString *gamesPlayed;
@property (assign) long question0Count;
@property (assign) long question1Count;
@property (assign) long question2Count;
@property (assign) long question3Count;
@property (assign) long points;

+(NSString *)nullPlayerRecord;

-(NSString *)createPlayerRecord;

-(NSString *)description;

@end
