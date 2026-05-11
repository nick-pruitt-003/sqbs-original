//
//  TournamentViewController.m
//  SQBS2
//
//  Created by Neil Smith on 12-01-14.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TournamentViewController.h"

@implementation TournamentViewController

@synthesize documentDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        documentDelegate = nil;
    }
    
    return self;
}

// override these methods

//- (void)prepareToActivateView {
//    
//}

- (void)handleViewControllerClosing {
    //DebugLog(@"handleViewControllerClosing");
}

- (void)viewWillAppear {
    
}

- (BOOL)shouldViewClose {
    //DebugLog(@"shouldViewClose");
    return TRUE;
}

@end
