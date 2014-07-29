//
//  MCHelper.m
//  Tablanet
//
//  Created by Valdrin on 17/12/13.
//  Copyright (c) 2013 Valdrin. All rights reserved.
//

#import "MCHelper.h"

@interface MCHelper (){
    MCNearbyServiceAdvertiser *advertiser;
    MCNearbyServiceBrowser *browser;
    NSInteger playersCount;
    id<MCHelperDelegate> delegate;
    NSString *earlyPeer;
    NSData *earlyData;
    BOOL dismissed;
}
@end

@implementation MCHelper
@synthesize localPeer;
@synthesize session;
@synthesize players;

static MCHelper *sharedHelper = nil;

+ (MCHelper *) sharedInstance {
    if (!sharedHelper) {
        sharedHelper = [[MCHelper alloc] init];
    }
    return sharedHelper;
}

static NSString * const XXServiceType = @"Tablanet-srvc";

-(id)init{
    self = [super init];
    if (self) {
        localPeer = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];

        browser = [[MCNearbyServiceBrowser alloc] initWithPeer:localPeer serviceType:XXServiceType];
        
        session = [[MCSession alloc] initWithPeer:localPeer securityIdentity:nil encryptionPreference:MCEncryptionNone];
        session.delegate = self;
        
        advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:localPeer discoveryInfo:nil serviceType:XXServiceType];
        advertiser.delegate = self;
        
        players = [[NSMutableArray alloc] init];
    }
  
    return self;
}
-(void)makeMeAvailable{
    [advertiser startAdvertisingPeer];
}

-(void)findPlayers:(NSInteger)pCount delegate:(UIViewController<MCHelperDelegate> *)theDelegate{
    delegate = theDelegate;
    playersCount = pCount;
    [players removeAllObjects];
    dismissed = NO;
    MCBrowserViewController *browserViewController = [[[MCBrowserViewController alloc] initWithBrowser:browser session:session] autorelease];
    browserViewController.delegate = self;
    [(UIViewController*)delegate presentViewController:browserViewController animated:YES completion:^{
        [browser startBrowsingForPeers];
    }];
}

#pragma mark - MCNearbyServiceAdvertiserDelegate
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler {
    // shouldn't accept if is already playing
    BOOL accept = playersCount != players.count + 1;
    invitationHandler(accept, session);
}

-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error{
    [(UIViewController*)delegate dismissViewControllerAnimated:YES completion:^{
        dismissed = YES;
    }];
    NSLog(@"Error advertising: %@", error.localizedDescription);
}

#pragma mark - MCBrowserViewControllerDelegate
- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController{
    [browser stopBrowsingForPeers];
    [delegate MCMatchStarted];
    [(UIViewController*)delegate dismissViewControllerAnimated:YES completion:^{
        dismissed = YES;
        if (earlyPeer) {
            [delegate session:session didReceiveData:earlyData fromPeer:earlyPeer];
            [earlyPeer release];
            earlyPeer = nil;
            [earlyData release];
            earlyData = nil;
        }
        
    }];
}

-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{
    [browser stopBrowsingForPeers];
    [advertiser stopAdvertisingPeer];
    [session disconnect];
    [(UIViewController*)delegate dismissViewControllerAnimated:YES completion:nil];
}



// Remote peer changed state
- (void)session:(MCSession *)theSession peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    if (state == MCSessionStateNotConnected) {
        [players removeObject:peerID];
        [delegate matchEnded: [NSString stringWithFormat:@"%@ %@.", peerID.displayName, NSLocalizedString(@"disconnected", nil)]];
    }
    else if(state == MCSessionStateConnected){
        if (![players containsObject:peerID]) {
            [players addObject:peerID];
        }
    }
}

// Received data from remote peer
- (void)session:(MCSession *)theSession didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    if (players.count + 1 == playersCount) {
        if (dismissed) {
            [delegate session:session didReceiveData:data fromPeer:peerID.displayName];
        }
        else{
            [earlyPeer release];
            earlyPeer = [peerID.displayName retain];
            [earlyData release];
            earlyData = [data retain];
        }
        
    }
}

// Received a byte stream from remote peer
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID{
    
}

// Start receiving a resource from remote peer
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress{
    
}

// Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error{
    
}


-(void)dealloc{
    [localPeer release];
    [players release];
    [advertiser release];
    [browser release];
    [session release];
    delegate = nil;
    [super dealloc];
}
@end
