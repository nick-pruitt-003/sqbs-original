//
//  GameEntryViewController.h
//  SQBS
//
//  Created by Neil Smith on 11-10-27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TournamentViewController.h"

#define kTeamATagValue 100  // used for accessing textfields
#define kTeamBTagValue 200
#define kPlayerRowMultiplier 10  // used for accessing textfields
#define kQuestion0TagValue 0
#define kQuestion1TagValue 1
#define kQuestion2TagValue 2
#define kQuestion3TagValue 3
#define kPointsTagValue 4
#define kGamesPlayedTagValue 5
#define kPlayerTagValue 6

#define kBonusHeardTagValue 1
#define kBonusPointsTagValue 2
#define kOvertimeGetsTagValue 3
#define kLighteningPointsTagValue 4
#define kBounceBacksHeardTagValue 5
#define kBounceBacksPointsTagValue 6

#define kRoundTagValue 1000
#define kGameIDTagValue 1001

#define kGotoGameTagValue 1003

#define kTossUpsHeardLabelTagValue 1004
#define kTossUpsHeardTagValue 1005

@interface GameEntryViewController : TournamentViewController
< NSTextFieldDelegate>
{   
    //IBOutlet Tournament *documentDelegate; 
    
    IBOutlet NSTextField *currentlyViewedGameID;
    IBOutlet NSButton *forfeitCheckBox;
    
    IBOutlet NSTextField *team_A_Score;
    IBOutlet NSTextField *team_B_Score;
    IBOutlet NSBox *team_A_BonusBox;
    IBOutlet NSBox *team_B_BonusBox;
    IBOutlet NSBox *team_A_BounceBacksBox;
    IBOutlet NSBox *team_B_BounceBacksBox;
    IBOutlet NSBox *team_A_LightningBox;
    IBOutlet NSBox *team_B_LightningBox;
    // team selectors
    IBOutlet NSPopUpButton *teamSelectorPopUpTeamA;
    IBOutlet NSPopUpButton *teamSelectorPopUpTeamB;
    
    // question labels - Team A & B
    IBOutlet NSTextField *question_0_labelTeamA;
    IBOutlet NSTextField *question_1_labelTeamA;
    IBOutlet NSTextField *question_2_labelTeamA;
    IBOutlet NSTextField *question_3_labelTeamA;
    
    IBOutlet NSTextField *question_0_labelTeamB;
    IBOutlet NSTextField *question_1_labelTeamB;
    IBOutlet NSTextField *question_2_labelTeamB;
    IBOutlet NSTextField *question_3_labelTeamB;
    
    // overtime check box and Team A & B boxes
    IBOutlet NSButton *overTimeCheckBox;
    IBOutlet NSBox *team_A_OvertimeBox;
    IBOutlet NSBox *team_B_OvertimeBox;
    
    IBOutlet NSStepper *currentViewedGameStepper;
    IBOutlet NSTextField *currentStepperValueLabel;
    IBOutlet NSTextField *totalGameCount;
    IBOutlet NSButton *swapTeamSidesButton;
    
    IBOutlet NSButton *recordGameButton;
}

//@property (nonatomic, assign) Tournament *documentDelegate;

//@property (assign) IBOutlet NSButton *swapSidesButton;

// check box actions
- (IBAction)overTimeCheckBoxChecked:(id)sender;
- (IBAction)forfeitCheckBoxAction:(id)sender;

// next-previous game stepper action
- (IBAction)viewStepperAction:(id)sender;

// team selector popup action selector
- (IBAction)teamSelectorActionTeamA:(id)sender;
- (IBAction)teamSelectorActionTeamB:(id)sender;

// player selector popup action selector
- (IBAction)playerSelectorAction:(id)sender;

// swap team sides action
- (IBAction)swapSidesAction:(id)sender;

// Save / Delete button actions
- (IBAction)saveGameAction:(id)sender;
- (IBAction)deleteGameAction:(id)sender;

//- (BOOL)handleViewControllerClosing;
- (void)prepareForGameSort;

@end
