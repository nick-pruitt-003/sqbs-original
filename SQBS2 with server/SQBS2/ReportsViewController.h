//
//  ReportsViewController.h
//  SQBS
//
//  Created by Neil Smith on 11-10-27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "TournamentViewController.h"

@interface ReportsViewController : TournamentViewController
{
    //IBOutlet Tournament *documentDelegate;
    WebView *theWebView;
    NSButton *printButton;
    NSTextView *printOutputTextView;
    NSButton *singlePageCheckbox;
    NSComboBox *ReportSelectorComboBox;
}

#define kPrintTextViewWidthForGameReport 508
#define kPrintTextViewWidthForIndividualReport 796
#define kPrintTextViewWidthForTeamReport 796

//@property (nonatomic, assign) Tournament *documentDelegate;
@property (assign) IBOutlet WebView *theWebView;
@property (assign) IBOutlet NSButton *printButton;
@property (assign) IBOutlet NSTextView *printOutputTextView;
@property (assign) IBOutlet NSButton *singlePageCheckbox;
@property (assign) IBOutlet NSComboBox *ReportSelectorComboBox;

//- (BOOL)handleViewControllerClosing;

- (IBAction)reportSelectorAction:(id)sender;

- (IBAction)printReport:(id)sender;

@end
