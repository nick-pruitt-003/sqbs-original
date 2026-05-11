//
//  SecondViewController.h
//  SQBS Scoring
//
//  Created by Neil Smith on 12-02-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScoringViewController : UIViewController
<UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate>
{
    
}
@property (retain, nonatomic) IBOutlet UILabel *tossupLabel;
@property (retain, nonatomic) IBOutlet UIButton *forfeitButton;
@property (retain, nonatomic) IBOutlet UISegmentedControl *questionValueSegmentedControl;
@property (retain, nonatomic) IBOutlet UILabel *teamA_Label;
@property (retain, nonatomic) IBOutlet UISegmentedControl *teamA_PlayerSelectSegmentedControl;
@property (retain, nonatomic) IBOutlet UILabel *teamB_Label;
@property (retain, nonatomic) IBOutlet UISegmentedControl *teamB_PlayerSelectSegmentedControl;
@property (retain, nonatomic) IBOutlet UIButton *recordTossupButton;
@property (retain, nonatomic) IBOutlet UIButton *previousTossupButton;
@property (retain, nonatomic) IBOutlet UIButton *nextTossupButton;
@property (retain, nonatomic) IBOutlet UIButton *configButton;
@property (retain, nonatomic) IBOutlet UIView *configView;
@property (retain, nonatomic) IBOutlet UISegmentedControl *configTeamSegmentedControl;
@property (retain, nonatomic) IBOutlet UISegmentedControl *configPlayerSelectSegmentedControl;
@property (retain, nonatomic) IBOutlet UIPickerView *configTeamPickerView;
@property (retain, nonatomic) IBOutlet UIPickerView *configPlayerPickerView;
@property (retain, nonatomic) IBOutlet UITextField *roundNumberTextField;

- (IBAction)questionValueChanged:(id)sender;
- (IBAction)forfeitAction:(id)sender;
- (IBAction)configAction:(id)sender;
- (IBAction)teamA_PlayerSelectValueChanged:(id)sender;
- (IBAction)teamB_PlayerSelectValueChanged:(id)sender;
- (IBAction)recordPointsAction:(id)sender;
- (IBAction)previousTossupAction:(id)sender;
- (IBAction)nextTossupAction:(id)sender;
- (IBAction)configTeamValueChanged:(id)sender;
- (IBAction)configPlayerValueChanged:(id)sender;
- (IBAction)newGameAction:(id)sender;

@end
