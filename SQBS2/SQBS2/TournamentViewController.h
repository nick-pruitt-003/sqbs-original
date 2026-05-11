//
//  TournamentViewController.h
//  SQBS2
//
//  Created by Neil Smith on 12-01-14.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Tournament.h"

@interface TournamentViewController : NSViewController
{
    
IBOutlet Tournament *documentDelegate;
    
}

@property (nonatomic, assign) Tournament *documentDelegate;

//- (void)prepareToActivateView;
- (void)handleViewControllerClosing;
- (void)viewWillAppear;
- (BOOL)shouldViewClose;

@end
