//
//  AppDelegate.m
//  SQBSScore
//
//  Created by Neil Smith on 12-02-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "AppConfig.h"
#import "ChatRoomViewController.h"
#import "LocalRoom.h"
#import "RemoteRoom.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize chatRoom;
@synthesize serverBrowser;


- (void)dealloc {
    [_window release];
    [self setChatRoom:nil];
    [self setServerBrowser:nil];
    [super dealloc];
}


// Show chat room
- (void)showChatRoom {
    
    if (chatRoom != nil) {
        [chatRoom setDelegate:self];
        [chatView setHidden:NO];
        [serverListView setHidden:YES];
        [chatRoom start];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // clear userdefault
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserNameKey];
}


// We are being asked to display a chat message
- (void)displayChatMessage:(NSString *)message fromUser:(NSString *)userName {
    NSString *newText = [chat string];
    [chat setString:[newText stringByAppendingFormat:@"\n%@: %@", userName, message]];
    NSRange scrollPoint = NSMakeRange([newText length], [message length]);
    [chat scrollRangeToVisible:scrollPoint];
}


// Room closed from outside
- (void)roomTerminated:(id)room reason:(NSString *)reason {
    // Explain what happened
    NSAlert *alert = [NSAlert alertWithMessageText:@"Room terminated" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:reason];
    [alert runModal];
    alert = nil;
    [self exit:nil];
}

// This is called whenever "Return" is touched on iPhone's keyboard
- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
    if (control == nameEntry) {
        if ( fieldEditor.string == nil || [fieldEditor.string length] < 1 ) {
            return NO;
        }
        
        // if name exists, exit
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserNameKey]) {
            return YES;
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:fieldEditor.string forKey:kUserNameKey];
        
        DebugLog(@"textShouldEndEditing - name: %@", [[NSUserDefaults standardUserDefaults] objectForKey:kUserNameKey]);
        
        // Move on to the next screen
        [welcomeView setHidden:YES];
        // enlarge
        NSRect initialFrame = [[self window] frame];
        //initialFrame.size.width = 377;
        initialFrame.size.height = 600;
        [[self window] setFrame:initialFrame display:YES];
        [serverListView setHidden:NO];
        
        ServerBrowser *temp = [[ServerBrowser alloc] init];
        [self setServerBrowser:temp];
        [temp release];
        [serverBrowser setDelegate:self];
        [serverBrowser start];
        
        return YES;
    }
    
    if (control == input) {
		// processs input
        [chatRoom broadcastChatMessage:input.stringValue fromUser:[[NSUserDefaults standardUserDefaults] objectForKey:kUserNameKey]];
        
		// clear input
		[input setStringValue:@""];
	}
	return YES;
}

// User is asking to create new chat room
- (IBAction)createNewChatRoom:(id)sender {
    
    // Create local chat room and go
    LocalRoom *room = [[LocalRoom alloc] init];
    [self setChatRoom:room];
    [room release];
    
    // Stop browsing for servers
    [serverBrowser stop];
    [serverBrowser setDelegate:nil];
    [self setServerBrowser:nil];
    
    [self showChatRoom];
}


// User is asking to join an existing chat room
- (IBAction)joinChatRoom:(id)sender {
    // Figure out which server is selected
    if ([serverList selectedRow] < 0 ) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Which chat room?" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"Please select which chat room you want to join from the list above"];
        [alert runModal];
        alert = nil;
        return;
    }
    
    if ([serverList selectedRow] > [[[self serverBrowser] servers] count]) {
        DebugLog(@"joinChatRoom - index: %i, servers: %@", [serverList selectedRow], [[self serverBrowser] servers]);
        return;
    }
    
    NSNetService* selectedServer = [[serverBrowser servers] objectAtIndex:[serverList selectedRow]];
    
    // Create chat room that will connect to that chat server
    RemoteRoom *room = [[RemoteRoom alloc] initWithNetService:selectedServer];
    [self setChatRoom:room];
    [room release];
    
    // Stop browsing and switch over to chat room
    [serverBrowser stop];
    [serverBrowser setDelegate:nil];
    [self setServerBrowser:nil];
    
    [self showChatRoom];
}

// User decided to exit room
- (IBAction)exit:(id)sender {
    DebugLog(@"exit");
    // Close the room
    [chatRoom stop];
    
    // Remove keyboard
    [input resignFirstResponder];
    
    // Erase chat
    [chat setString:@""];
    
    // go back to server list
    [chatView setHidden:YES];
    [serverListView setHidden:NO];
    
    ServerBrowser *temp = [[ServerBrowser alloc] init];
    [self setServerBrowser:temp];
    [serverBrowser setDelegate:self];
    [temp release];
    [serverBrowser start];
    
}

#pragma mark -
#pragma mark ServerBrowserDelegate Method Implementations

- (void)updateServerList {
    DebugLog(@"updateServerList - servers: %@", [[self serverBrowser] servers]);
    [serverList reloadData];
}

#pragma mark -
#pragma mark UITableViewDataSource Method Implementations

// Number of rows in each section. One section by default.
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [[serverBrowser servers] count];
}


// Table view is requesting a cell
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    // Set cell's text to server's name
    if ((rowIndex >= 0) && (rowIndex < [[serverBrowser servers] count])) {
        return [[[serverBrowser servers] objectAtIndex:rowIndex] name];
    }
    
    return nil;
}

@end
