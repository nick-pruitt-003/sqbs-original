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
#import "TournamentAppDelegate.h"
#import "GameFileContents.h"

// Declare some private properties and methods
@interface Server ()
@property (nonatomic,assign) uint16_t port;
@property (nonatomic,retain) NSNetService *netService;
@property (nonatomic,retain) NSMutableSet *clients;

- (BOOL)createServer;
- (void)terminateServer;

- (BOOL)publishService;
- (void)unpublishService;

@end


// Implementation of the Server interface
@implementation Server

@synthesize delegate;
@synthesize port, netService;
@synthesize clients;

// Cleanup
- (void)dealloc {
    [self setNetService:nil];
    [self setDelegate:nil];
    [super dealloc];
}


// Create server and announce it
- (BOOL)start {
    // Start the socket server
    if (![self createServer]) {
        return NO;
    }
    
    // Announce the server via Bonjour
    if (![self publishService]) {
        [self terminateServer];
        return NO;
    }
    
    [self setClients:[NSMutableSet setWithCapacity:10]];
    
    return YES;
}


// Close everything
- (void)stop {
    // Close all connections
    [clients makeObjectsPerformSelector:@selector(close)];
    
    [self terminateServer];
    [self unpublishService];
}

- (void)publishedTournamentsChanged {
    // update all clients tournaments
    DebugLog(@"publishedTournamentsChanged - count: %@, clients: %@", [(TournamentAppDelegate *)[NSApp delegate] publishedTournaments], clients);
    NSMutableArray *packet = [NSMutableArray arrayWithCapacity:3];
    [packet addObject:kServerProtocolVersion];
    [packet addObject:[NSNumber numberWithInt:kServerResponsePublishedTournamentsMessage]];
    [packet addObject:[(TournamentAppDelegate *)[NSApp delegate] publishedTournaments]];
    [clients makeObjectsPerformSelector:@selector(sendNetworkPacket:) withObject:packet];
}

#pragma mark Callbacks

// Handle new connections
- (void)handleNewNativeSocket:(CFSocketNativeHandle)nativeSocketHandle {
    Connection* connection = [[[Connection alloc] initWithNativeSocketHandle:nativeSocketHandle] autorelease];
    
    DebugLog(@"handleNewNativeSocket - %@", connection);
    
    // In case of errors, close native socket handle
    if (connection == nil) {
        close(nativeSocketHandle);
        return;
    }
    
    // finish connecting
    if (![connection connect]) {
        [connection close];
        return;
    }
    
    // Delegate everything to us
    [connection setDelegate:self];
    
    // Add to our list of clients
    [clients addObject:connection];
    
    DebugLog(@"handleNewNativeSocket - %@", (connection != nil)?[[connection netService] hostName] : @"--");
}


// This function will be used as a callback while creating our listening socket via 'CFSocketCreate'
static void serverAcceptCallback(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
    Server *server = (Server*)info;
    
    // We can only process "connection accepted" calls here
    if ( type != kCFSocketAcceptCallBack ) {
        return;
    }
    
    // for an AcceptCallBack, the data parameter is a pointer to a CFSocketNativeHandle
    CFSocketNativeHandle nativeSocketHandle = *(CFSocketNativeHandle*)data;
    
    [server handleNewNativeSocket:nativeSocketHandle];
}


#pragma mark Sockets and streams

- (BOOL)createServer {
    
    //// PART 1: Create a socket that can accept connections
    
    // Socket context
    //  struct CFSocketContext {
    //   CFIndex version;
    //   void *info;
    //   CFAllocatorRetainCallBack retain;
    //   CFAllocatorReleaseCallBack release;
    //   CFAllocatorCopyDescriptionCallBack copyDescription;
    //  };
    CFSocketContext socketCtxt = {0, self, NULL, NULL, NULL};
    
    listeningSocket = CFSocketCreate(
                                     kCFAllocatorDefault,
                                     PF_INET,        // The protocol family for the socket
                                     SOCK_STREAM,    // The socket type to create
                                     IPPROTO_TCP,    // The protocol for the socket. TCP vs UDP.
                                     kCFSocketAcceptCallBack,  // New connections will be automatically accepted and the callback is called with the data argument being a pointer to a CFSocketNativeHandle of the child socket.
                                     (CFSocketCallBack)&serverAcceptCallback,
                                     &socketCtxt );
    
    // Previous call might have failed
    if ( listeningSocket == NULL ) {
        return NO;
    }
    
    // getsockopt will return existing socket option value via this variable
    int existingValue = 1;
    
    // Make sure that same listening socket address gets reused after every connection
    setsockopt( CFSocketGetNative(listeningSocket),
               SOL_SOCKET, SO_REUSEADDR, (void *)&existingValue,
               sizeof(existingValue));
    
    
    //// PART 2: Bind our socket to an endpoint.
    // We will be listening on all available interfaces/addresses.
    // Port will be assigned automatically by kernel.
    struct sockaddr_in socketAddress;
    memset(&socketAddress, 0, sizeof(socketAddress));
    socketAddress.sin_len = sizeof(socketAddress);
    socketAddress.sin_family = AF_INET;   // Address family (IPv4 vs IPv6)
    socketAddress.sin_port = 0;           // Actual port will get assigned automatically by kernel
    socketAddress.sin_addr.s_addr = htonl(INADDR_ANY);    // We must use "network byte order" format (big-endian) for the value here
    
    // Convert the endpoint data structure into something that CFSocket can use
    NSData *socketAddressData =
    [NSData dataWithBytes:&socketAddress length:sizeof(socketAddress)];
    
    // Bind our socket to the endpoint. Check if successful.
    if ( CFSocketSetAddress(listeningSocket, (CFDataRef)socketAddressData) != kCFSocketSuccess ) {
        // Cleanup
        if ( listeningSocket != NULL ) {
            CFRelease(listeningSocket);
            listeningSocket = NULL;
        }
        
        return NO;
    }
    
    
    //// PART 3: Find out what port kernel assigned to our socket
    // We need it to advertise our service via Bonjour
    NSData *socketAddressActualData = 
    [(NSData *)CFSocketCopyAddress(listeningSocket) autorelease];
    
    // Convert socket data into a usable structure
    struct sockaddr_in socketAddressActual;
    memcpy(&socketAddressActual, [socketAddressActualData bytes], [socketAddressActualData length]);
    
    [self setPort:ntohs(socketAddressActual.sin_port)];
    
    //// PART 4: Hook up our socket to the current run loop
    CFRunLoopRef currentRunLoop = CFRunLoopGetCurrent();
    CFRunLoopSourceRef runLoopSource = CFSocketCreateRunLoopSource(kCFAllocatorDefault, listeningSocket, 0);
    CFRunLoopAddSource(currentRunLoop, runLoopSource, kCFRunLoopCommonModes);
    CFRelease(runLoopSource);
    
    return YES;
}


- (void) terminateServer {
    if ( listeningSocket != nil ) {
        CFSocketInvalidate(listeningSocket);
		CFRelease(listeningSocket);
		listeningSocket = nil;
    }
}


#pragma mark Bonjour

- (BOOL) publishService {
    // get name for this server
    NSString *serverName = [[NSUserDefaults standardUserDefaults] stringForKey:kServerIdentityKey];
    DebugLog(@"publishService - name: %@", serverName);
    // create new instance of netService
 	NSNetService *temp = [[NSNetService alloc] initWithDomain:@"" type:kBonjourServiceType name:serverName port:[self port]];
    [self setNetService:temp];
    [temp release];
	if (netService == nil)
		return NO;
    
    // Add service to current run loop
	[netService scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    // NetService will let us know about what's happening via delegate methods
	[netService setDelegate:self];
    
    // Publish the service
	[netService publish];
    
    return YES;
}


- (void) unpublishService {
    if (netService) {
		[netService stop];
		[netService removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [self setNetService:nil];
	}
}


#pragma mark -
#pragma mark NSNetService Delegate Method Implementations

// Delegate method, called by NSNetService in case service publishing fails for whatever reason
- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict {
    if ( sender != netService ) {
        return;
    }
    
    // Stop socket server
    [self terminateServer];
    
    // Stop Bonjour
    [self unpublishService];
    
    // Let delegate know about failure
    [delegate serverFailed:self reason:@"Failed to publish service via Bonjour (duplicate server name?)"];
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    DebugLog(@"didNotResolve");
}

- (void)netService:(NSNetService *)sender didUpdateTXTRecordData:(NSData *)data {
    DebugLog(@"didUpdateTXTRecordData");
}

- (void)netServiceDidPublish:(NSNetService *)sender {
    DebugLog(@"netServiceDidPublish");
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    DebugLog(@"netServiceDidResolveAddress");
}

- (void)netServiceDidStop:(NSNetService *)sender {
    DebugLog(@"netServiceDidStop");
}

- (void)netServiceWillPublish:(NSNetService *)sender {
    DebugLog(@"netServiceWillPublish");
}

- (void)netServiceWillResolve:(NSNetService *)sender {
    DebugLog(@"netServiceWillResolve");
}

#pragma mark -
#pragma mark ConnectionDelegate Method Implementations

// We won't be initiating connections, so this is not important
- (void) connectionAttemptFailed:(Connection*)connection {
}

// One of the clients disconnected, remove it from our list
- (void) connectionTerminated:(Connection*)connection {
    [clients removeObject:connection];
}

// One of connected clients sent a chat message. Propagate it further.
- (void) receivedNetworkPacket:(NSArray *)packet viaConnection:(Connection *)connection {
    DebugLog(@"receivedNetworkPacket - packet %@", packet);
    NSString *protocolVersion = [packet objectAtIndex:kServerProtocolVersionElement];
    if ([protocolVersion isEqualToString:kServerProtocolVersion]) {
        NSNumber *messageType = [packet objectAtIndex:kServerMessageTypeElement];
        
        switch ([messageType intValue]) {
            case kServerRequestPublishedTournamentsMessage: {
                // requesting tournaments
                NSMutableArray *response = [NSMutableArray arrayWithCapacity:3];
                [response addObject:kServerProtocolVersion];
                [response addObject:[NSNumber numberWithInt:kServerResponsePublishedTournamentsMessage]];
                NSMutableArray *availableTournaments = [(TournamentAppDelegate *)[NSApp delegate] publishedTournaments];
                if (availableTournaments == nil) {
                    availableTournaments = [NSMutableArray arrayWithCapacity:1];
                }
                [response addObject:availableTournaments];
                [connection sendNetworkPacket:response];
                break;
            }
            case kServerRequestGameUploadMessage: {
                // uploading a game
                GameFileContents *theGameFile = [packet objectAtIndex:kServerMessageContentElement];
                NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                rootPath = [rootPath stringByAppendingPathComponent:[theGameFile archiveName]];
                rootPath = [rootPath stringByAppendingPathExtension:kScoringAppFileExtension];
                BOOL archiverSuccess = NO;
                
                @try {
                    archiverSuccess = [NSKeyedArchiver archiveRootObject:theGameFile toFile:rootPath];
                }
                @catch (NSException *exception) {
                    archiverSuccess = NO;
                }
                if (archiverSuccess) {
                    // send back upload acknowledge
                    NSArray *response = [NSArray arrayWithObjects:kServerProtocolVersion, [NSNumber numberWithInt:kServerAcknowledgeGameUploadMessage], [theGameFile archiveName], nil];
                    [connection sendNetworkPacket:response];
                    
                    // add to list
                    [(TournamentAppDelegate *)[NSApp delegate] addGameForImport:[theGameFile archiveName]];
                }
                break;
            }
                
            default:
                break;
        }
    } else {
        NSLog(@"Server - app protocol mismatch - Server: %@, app: %@", kServerProtocolVersion, protocolVersion);
    }
}

@end
