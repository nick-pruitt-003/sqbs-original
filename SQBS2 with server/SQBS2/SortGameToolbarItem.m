//
//  SortGameToolbarItem.m
//  SQBS
//
//  Created by Neil Smith on 12-01-07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SortGameToolbarItem.h"

@implementation SortGameToolbarItem

@synthesize tournamentDelegate;

- (void)validate {
    BOOL enableState = FALSE;
    if (tournamentDelegate != nil) {
        enableState = (([tournamentDelegate gameList] != nil) && ([[tournamentDelegate gameList] count] > 1));
    }
    [self setEnabled:enableState];
}

@end
