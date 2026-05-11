//
//  Server.m
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

#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
//#include <CoreServices/CoreServices.h>

#import "Server.h"
#import "Connection.h"
#import "AppDelegate.h"
#import "Constants.h"

// Declare some private properties and methods
@interface Server () {

NSNetService *privNetService;
}

@property (nonatomic,assign) uint16_t port;
@property (nonatomic, retain) NSNetService *privNetService;

@end


// Implementation of the Server interface
@implementation Server

@synthesize delegate;
@synthesize port, privNetService;
@synthesize theConnection;
@synthesize publishedTournaments;
@synthesize theNetService;
@synthesize lastResponse;

// Initialize and connect to a net service
- (id)initWithNetService:(NSNetService *)netService {
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        // If an error occurs here, return nil.
        [self setPrivNetService:netService];
        [self setTheNetService:netService];
        [self setPublishedTournaments:[NSMutableArray arrayWithCapacity:3]];
        Connection *temp = [[Connection alloc] initWithNetService:netService];
        [self setTheConnection:temp];
        [temp release];
        DebugLog(@"initWithNetService - connection: %@", theConnection);
    }
    return self;
}

// Cleanup
- (void)dealloc {
    [self setPrivNetService:nil];
    [self setTheNetService:nil];
    [self setDelegate:nil];
    [self setPublishedTournaments:nil];
    [super dealloc];
}


// Connect up connection
- (BOOL)start {
    DebugLog(@"start - connection: %@", theConnection);
    if (theConnection == nil) {
        return NO;
    }
    
    // We are the delegate
    [theConnection setDelegate:self];
    [self setLastResponse:[NSDate date]];
    return [theConnection connect];
}

// Close connection
- (void)stop {
    if (theConnection == nil) {
        return;
    }
    
    [theConnection close];
    [self setTheConnection:nil];
}

// Send chat message to the server
- (void)sendPacket:(NSArray *)packet {
    DebugLog(@"sendPacket - %@", packet);
    // Send it out
    [theConnection sendNetworkPacket:packet];
}

#pragma mark -
#pragma mark ConnectionDelegate Method Implementations

- (void) connectionAttemptFailed:(Connection *)connection {
    [delegate serverFailed:self];
}

- (void) connectionTerminated:(Connection *)connection {
    // lost server, remove published and update delegate
    
}

- (void)connectionCompleted:(Connection *)connection {
    [self setLastResponse:[NSDate date]];
    [delegate serverConnectionComplete:self];
}


// Message received from server.
- (void) receivedNetworkPacket:(NSArray *)packet viaConnection:(Connection *)connection {
    //DebugLog(@"receivedNetworkPacket - packet: %@", packet);
    [self setLastResponse:[NSDate date]];
    NSString *protocolVersion = [packet objectAtIndex:kServerProtocolVersionElement];
    if ([protocolVersion isEqualToString:kServerProtocolVersion]) {
        NSNumber *messageType = [packet objectAtIndex:kServerMessageTypeElement];
        switch ([messageType intValue]) {
            case kServerResponsePublishedTournamentsMessage: {
                [self setPublishedTournaments:[packet objectAtIndex:kServerMessageContentElement]];
                [delegate handlePublishedTournamentsUpdate];
                break;
            }
            case kServerAcknowledgeGameUploadMessage: {
                [delegate handleGameUploadAck:[packet objectAtIndex:kServerMessageContentElement]];
                break;
            }
                
            default:
                break;
        }  
    } else {
        // wrong version of protcol - upgrade
        NSLog(@"Server - app protocol version mismatch: server: %@, app: %@", protocolVersion, kServerProtocolVersion);
    }
}

@end
