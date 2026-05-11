//
//  ServerBrowser.m
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

#import "ServerBrowserDelegate.h"
#import "ServerBrowser.h"
#import "Constants.h"
//#import "Server.h"


@implementation ServerBrowser

@synthesize serviceProviders;
@synthesize delegate;
@synthesize netServiceBrowser;

// Initialize
- (id)init {
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        // If an error occurs here, return nil.
        
    }
    return self;
}


// Cleanup
- (void)dealloc {
    [self setServiceProviders:nil];
    [self setDelegate:nil];
    [super dealloc];
}


// Start browsing for servers
- (BOOL)start {
    // Restarting?
    //DebugLog(@"start - netServiceBrowser: %@", netServiceBrowser);
    if (netServiceBrowser != nil) {
        DebugLog(@"stopping");
        [self stop];
    }
    
    [self setServiceProviders:[NSMutableArray arrayWithCapacity:3]];
    
	NSNetServiceBrowser *temp = [[NSNetServiceBrowser alloc] init];
	if(!temp) {
        DebugLog(@"start failed");
		return NO;
	}
    [self setNetServiceBrowser:temp];
    [temp release];
    [netServiceBrowser setDelegate:self];
    
	[netServiceBrowser searchForServicesOfType:kBonjourServiceType inDomain:@""];
    
    //DebugLog(@"start - netServiceBrowser: %@", [self netServiceBrowser]);
    
    return YES;
}


// Terminate current service browser and clean up
- (void)stop {
    //DebugLog(@"stop - netServiceBrowser: %@", netServiceBrowser);
    if (netServiceBrowser == nil) {
        return;
    }
    
    [netServiceBrowser stop];
    [self setNetServiceBrowser:nil];
}


#pragma mark -
#pragma mark NSNetServiceBrowser Delegate Method Implementations

// New service was found
- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing {
    //DebugLog(@"didFindService service: %@", netService);
    // Make sure that we don't have such service already (why would this happen? not sure)
    if (![serviceProviders containsObject:netService]) {
        
        // Add it to our list
        [serviceProviders addObject:netService];
        
        [delegate updateServerAdded:netService];
    }
}


// Service was removed
- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didRemoveService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing {
    //DebugLog(@"didRemoveService delegate: %@", netService);
    // Remove from list
    [serviceProviders removeObject:netService];
    
    [delegate updateServerRemoved:netService];
}

//- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindDomain:(NSString *)domainName moreComing:(BOOL)moreDomainsComing {
//    DebugLog(@"didFindDomain");
//}
//
//- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didNotSearch:(NSDictionary *)errorInfo {
//    DebugLog(@"didNotSearch");
//}
//
//- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didRemoveDomain:(NSString *)domainName moreComing:(BOOL)moreDomainsComing {
//    DebugLog(@"didRemoveDomain");
//}
//
//- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)netServiceBrowser {
//    DebugLog(@"netServiceBrowserDidStopSearch");
//}
//
//- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)netServiceBrowser {
//    DebugLog(@"netServiceBrowserWillSearch");
//}

@end
