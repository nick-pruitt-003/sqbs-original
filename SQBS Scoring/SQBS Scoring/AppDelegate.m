//
//  AppDelegate.m
//  SQBS Scoring
//
//  Created by Neil Smith on 12-02-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"
#import "SetupViewController.h"
#import "ScoringViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

@synthesize selectedTeamList;
@synthesize selectedTournamentName;
@synthesize selectedTournamentFileName;
@synthesize selectedTournamentQuestionValues;

@synthesize currentGame;

- (void)dealloc
{
    [_window release];
    [_tabBarController release];
    [self setSelectedTeamList:nil];
    [self setSelectedTournamentName:nil];
    [self setSelectedTournamentFileName:nil];
    [self setSelectedTournamentQuestionValues:nil];
    [self setCurrentGame:nil];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setSelectedTeamList:[NSArray array]];
    [self setSelectedTournamentQuestionValues:[NSArray array]];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    UIViewController *viewController1, *viewController2;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        viewController1 = [[[SetupViewController alloc] initWithNibName:@"SetupViewController_iPhone" bundle:nil] autorelease];
        viewController2 = [[[ScoringViewController alloc] initWithNibName:@"ScoreViewController_iPhone" bundle:nil] autorelease];
    } else {
        viewController1 = [[[SetupViewController alloc] initWithNibName:@"SetupViewController_iPad" bundle:nil] autorelease];
        viewController2 = [[[ScoringViewController alloc] initWithNibName:@"ScoreViewController_iPad" bundle:nil] autorelease];
    }
    self.tabBarController = [[[UITabBarController alloc] init] autorelease];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:viewController1, viewController2, nil];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    // create directories in Documents directory if not there
    NSString *dirPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:kSavedGamesDirectoryName];
    BOOL isDirectoryBool;
    BOOL fileExistResult = [[NSFileManager defaultManager] fileExistsAtPath:dirPath isDirectory:&isDirectoryBool];
    if (!fileExistResult || !isDirectoryBool) {
        if (!isDirectoryBool) {
            DebugLog(@"deleting: %@", dirPath);
            [[NSFileManager defaultManager] removeItemAtPath:dirPath error:nil];
        }
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    dirPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:kImportedTournamentsDirectoryName];
    fileExistResult = [[NSFileManager defaultManager] fileExistsAtPath:dirPath isDirectory:&isDirectoryBool];
    if (!fileExistResult || !isDirectoryBool) {
        if (!isDirectoryBool) {
            DebugLog(@"deleting: %@", dirPath);
            [[NSFileManager defaultManager] removeItemAtPath:dirPath error:nil];
        }
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // remove Scoring user prefs - valid only for moving between views
    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];
    [userPrefs removeObjectForKey:kPrefsTeamA_PlayerDisplayListKey];
    [userPrefs removeObjectForKey:kPrefsTeamB_PlayerDisplayListKey];
    [userPrefs removeObjectForKey:kLastSavedGame];
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
