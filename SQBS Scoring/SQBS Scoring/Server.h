//
//  Server.h
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

#import <Foundation/Foundation.h>
#import "ServerDelegate.h"
#import "Connection.h"
#import "ConnectionDelegate.h"
#import "PublishedTournament.h"

@interface Server : NSObject 
<ConnectionDelegate>
{
    uint16_t port;
    CFSocketRef listeningSocket;
    id<ServerDelegate> delegate;
    NSNetService *theNetService; // kept for life of server - for identification
    Connection *theConnection;
    NSMutableArray *publishedTournaments;
    NSDate *lastResponse;
}

// Initialize and start listening for connections
- (id)initWithNetService:(NSNetService *)netService;
- (BOOL)start;
- (void)stop;
- (void)sendPacket:(NSArray *)packet;

// Delegate receives various notifications about the state of our server
@property (assign) id<ServerDelegate> delegate;
@property (nonatomic, retain) NSNetService *theNetService;
@property (nonatomic, retain) Connection *theConnection;
@property (nonatomic, retain) NSMutableArray *publishedTournaments;
@property (nonatomic, retain) NSDate *lastResponse;

@end
