//
//  AppDelegate.h
//  SQBS Scoring
//
//  Created by Neil Smith on 12-02-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameResult.h"

@interface AppDelegate : UIResponder
<UIApplicationDelegate, UITabBarControllerDelegate>
{
    NSArray *selectedTeamList;
    NSString *selectedTournamentName;
    NSString *selectedTournamentFileName;
    NSArray *selectedTournamentQuestionValues;
    
    GameResult *currentGame;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (retain, nonatomic) NSArray *selectedTeamList;
@property (retain, nonatomic) NSString *selectedTournamentName;
@property (retain, nonatomic) NSString *selectedTournamentFileName;
@property (retain, nonatomic) NSArray *selectedTournamentQuestionValues;

@property (retain, nonatomic) GameResult *currentGame;


@end
