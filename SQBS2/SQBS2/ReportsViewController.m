//
//  ReportsViewController.m
//  SQBS
//
//  Created by Neil Smith on 11-10-27.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ReportsViewController.h"
#import "Constants.h"

@implementation ReportsViewController

//@synthesize documentDelegate;
@synthesize theWebView;
@synthesize printButton;
@synthesize printOutputTextView;
@synthesize singlePageCheckbox;
@synthesize ReportSelectorComboBox;



- (void)handleReportGeneratedNotification:(NSNotification *)notification {
    //DebugLog(@"handleReportGeneratedNotification - fileName %@", [notification object]);
    // check if for me
    if ([notification object] != documentDelegate) {
        return;
    }
    NSString *fileName = [[notification userInfo] objectForKey:@"fileName"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        // set width of print output view to minimum width needed otherwise extra width right side white space
        NSRect printFrame = [printOutputTextView frame];
        switch ([documentDelegate quickReportRequested]) {
            case kQuickReportGame: {
                printFrame.size.width = kPrintTextViewWidthForGameReport;
                break;
            }
            case kQuickReportIndividual: {
                printFrame.size.width = kPrintTextViewWidthForIndividualReport;
                break;
            }
            case kQuickReportTeam: {
                printFrame.size.width = kPrintTextViewWidthForTeamReport;
                break;
            }
                
            default:
                break;
        }
        [printOutputTextView setFrame:printFrame];
        // load html file into webview view
        [[theWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:fileName]]];
        // convert to attributedstring for print output view
        NSAttributedString *output = [[NSAttributedString alloc] initWithHTML:[NSData dataWithContentsOfFile:fileName] documentAttributes:nil];
        [printOutputTextView setString:@""];
        [printOutputTextView insertText:output];
        [output release];
        [printButton setEnabled:TRUE];
        //[[NSFileManager defaultManager] removeItemAtPath:fileName error:nil]; // need to do from delegate so it is done after webview has loaded
    } else {
        [printButton setEnabled:FALSE];
    }
    
    //DebugLog(@"handleReportGeneratedNotification - is editted %i", [documentDelegate isDocumentEdited]);
}


- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReportGeneratedNotification:) name:kTournamentReportGeneratedNotification object:nil];
    [ReportSelectorComboBox selectItemAtIndex:0];
}

- (void)handleViewControllerClosing {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // delete temp report files ??
}

-(BOOL)shouldViewClose {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    return TRUE;
    
    // delete temp report files ??
}
 
- (IBAction)printReport:(id)sender {
    NSPrintInfo *myPrintInfo = [NSPrintInfo sharedPrintInfo];
    [myPrintInfo setVerticallyCentered:FALSE];
    [myPrintInfo setHorizontallyCentered:FALSE];
    if ([singlePageCheckbox state]) {
        [myPrintInfo setVerticalPagination:NSFitPagination];
        [myPrintInfo setHorizontalPagination:NSFitPagination];
    } else {
        [myPrintInfo setVerticalPagination:NSAutoPagination];
        [myPrintInfo setHorizontalPagination:NSAutoPagination];
    }
    [myPrintInfo setHorizontalPagination:NSFitPagination];
    if ([documentDelegate quickReportRequested] == kQuickReportGame) {
        [myPrintInfo setOrientation:NSPortraitOrientation];
        [myPrintInfo setTopMargin:56];  // bottom margin when printed
        [myPrintInfo setBottomMargin:56];  // top margin when printed
        [myPrintInfo setLeftMargin:56];
        [myPrintInfo setRightMargin:56];
    } else {
        [myPrintInfo setOrientation:NSLandscapeOrientation];
        [myPrintInfo setTopMargin:56];  // bottom margin when printed
        [myPrintInfo setBottomMargin:56];  // top margin when printed
        [myPrintInfo setLeftMargin:56];
        [myPrintInfo setRightMargin:56];
    }
    //DebugLog(@"margins: {t, b, l, r}: {%.1f, %.1f, %.1f, %.1f}", [myPrintInfo topMargin], [myPrintInfo bottomMargin], [myPrintInfo leftMargin], [myPrintInfo rightMargin]);
    //DebugLog(@"view width: %.1f", printOutputTextView.frame.size.width);
    [[NSPrintOperation printOperationWithView:printOutputTextView printInfo:myPrintInfo] runOperation];
    myPrintInfo = nil;
}

- (IBAction)reportSelectorAction:(id)sender {
    long selectedReport = [(NSComboBox *)sender indexOfSelectedItem];
    switch (selectedReport) {
        case kQuickReportTeam: {
            [documentDelegate quickPrintTeamReport:sender];
            break;
        }
        case kQuickReportIndividual: {
            [documentDelegate quickPrintIndividualReport:sender];
            break;
        }
        case kQuickReportGame: {
            [documentDelegate quickPrintGameReport:sender];
            break;
        }
            
        default:
            break;
    }
}
@end
