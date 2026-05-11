//
//  AppDelegate.h
//  SQBSScore
//
//  Created by Neil Smith on 12-02-01.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Room.h"
#import "ServerBrowser.h"
#import "ServerBrowserDelegate.h"
#import "RoomDelegate.h"

#define kUserNameKey @"userName"

@interface AppDelegate : NSObject
<NSApplicationDelegate, NSTextFieldDelegate, NSTableViewDataSource, ServerBrowserDelegate, RoomDelegate>
{
    
    IBOutlet NSView *welcomeView;
    IBOutlet NSTextField *nameEntry;
    
    IBOutlet NSView *serverListView;
    ServerBrowser *serverBrowser;
    IBOutlet NSTableView *serverList;
    
    IBOutlet NSView *chatView;
    Room *chatRoom;
    IBOutlet NSTextView *chat;
    IBOutlet NSTextField *input;
}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, retain) ServerBrowser *serverBrowser;
@property (nonatomic, retain) Room *chatRoom;


- (IBAction)createNewChatRoom:(id)sender;
- (IBAction)joinChatRoom:(id)sender;

// Exit back to the welcome screen
- (IBAction)exit:(id)sender;

@end

