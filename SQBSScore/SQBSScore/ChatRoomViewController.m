//
//  ChatRoomViewController.m
//  Chatty
//
//  Copyright (c) 2009 Peter Bakhyryev <peter@byteclub.com>, ByteClub LLC
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//  
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.

#import "ChatRoomViewController.h"
#import "AppDelegate.h"
#import "AppConfig.h"

@implementation ChatRoomViewController

@synthesize chatRoom;

// After view shows up, start the room
- (void)activate {
    if ( chatRoom != nil ) {
        chatRoom.delegate = self;
        [chatRoom start];
    }
    
    [input becomeFirstResponder];
}


// Cleanup
- (void)dealloc {
    self.chatRoom = nil;
    [super dealloc];
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


// User decided to exit room
- (IBAction)exit:(id)sender {
    // Close the room
    [chatRoom stop];
    
    // Remove keyboard
    [input resignFirstResponder];
    
    // Erase chat
    chat.string = @"";
    
    // close window
    [[chat window] close];
    //[[AppDelegate getInstance] showRoomSelection];
}


#pragma mark -
#pragma mark UITextFieldDelegate Method Implementations

// This is called whenever "Return" is touched on iPhone's keyboard
- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
	if (control == input) {
		// processs input
        [chatRoom broadcastChatMessage:input.stringValue fromUser:[AppConfig getInstance].name];
        
		// clear input
		[input setStringValue:@""];
	}
	return YES;
}

@end
