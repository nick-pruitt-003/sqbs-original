//
//  SortGameToolbarItem.h
//  SQBS
//
//  Created by Neil Smith on 12-01-07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tournament.h"

@interface SortGameToolbarItem : NSToolbarItem {
    IBOutlet Tournament *tournamentDelegate;
}

@property (nonatomic, assign) IBOutlet Tournament *tournamentDelegate;

@end
