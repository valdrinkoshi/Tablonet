//
//  GCHelper.m
//  Tablanet
//
//  Created by Valdrin on 15/12/12.
//  Copyright (c) 2012 Valdrin. All rights reserved.
//

#import "GCHelper.h"

@implementation GCHelper
@synthesize delegate;
@synthesize acceptedInvite;
@synthesize playersToInvite;

@synthesize presentingViewController;
@synthesize playersDict;
@synthesize match;

#pragma mark Initialization

static GCHelper *sharedHelper = nil;

+ (GCHelper *) sharedInstance {
    if (!sharedHelper && [GCHelper gameCenterAvailable]) {
        sharedHelper = [[GCHelper alloc] init];
    }
    return sharedHelper;
}

- (BOOL)userAuthenticated{
    return [GKLocalPlayer localPlayer].isAuthenticated;
}

+ (BOOL)gameCenterAvailable {
    // check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer
                                           options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

#pragma mark Internal functions

- (void)lookupPlayers {
    
    NSLog(@"Looking up %d players...", match.playerIDs.count);
    [GKPlayer loadPlayersForIdentifiers:match.playerIDs withCompletionHandler:^(NSArray *players, NSError *error) {
        
        if (error != nil) {
            matchStarted = NO;
            [delegate matchEnded:[NSString stringWithFormat:@"Error retrieving player info: %@", error.localizedDescription]];
        } else {
            
            // Populate players dict
            self.playersDict = [NSMutableDictionary dictionaryWithCapacity:players.count];
            for (GKPlayer *player in players) {
                NSLog(@"Found player: %@", player.alias);
                [playersDict setObject:player forKey:player.playerID];
            }
            
            // Notify delegate match can begin
            matchStarted = YES;
            [presentingViewController dismissViewControllerAnimated:YES completion:^{
                [delegate matchStarted];
                [presentingViewController release];
                presentingViewController = nil;
            }];
            if (earlyPlayerID && earlyData) {
                [delegate match:match didReceiveData:earlyData fromPlayer:earlyPlayerID];
                [earlyPlayerID release];
                earlyPlayerID = nil;
                [earlyData release];
                earlyData = nil;
            }
        }
    }];
    
}


#pragma mark User functions
-(void)authenticateLocalPlayer{
    if (!self.userAuthenticated) {
        GKLocalPlayer.localPlayer.authenticateHandler = ^(UIViewController *vc, NSError *e) {
            if (vc != nil) {
                [(UIViewController*)delegate presentViewController:vc animated:YES completion:nil];
            }
            else if([[GKLocalPlayer localPlayer] isAuthenticated]){
                [GKMatchmaker sharedMatchmaker].inviteHandler = ^(GKInvite *ai, NSArray *pti) {
                    NSLog(@"Received invite");
                    self.acceptedInvite = ai;
                    self.playersToInvite = pti;
                    [delegate didAcceptInvite];
                    //this will use the playersToInvite
                    //[self findMatchWithPlayers:0 viewController:viewController delegate:theDelegate turnBased:NO];
                };
                [delegate didSucceedAuthentication];
            }
            else{
                //disable game center?
            }
        };
    }
    else{
        [delegate didSucceedAuthentication];
    }
}

-(void)findMatchWithPlayers:(int)players{
    
    matchStarted = NO;
    self.match = nil;
    self.playersDict = nil;
    UIViewController *viewController = (UIViewController*)delegate;
    self.presentingViewController = viewController;
    
    if ([GKLocalPlayer localPlayer].isAuthenticated) {
        
        GKMatchmakerViewController *mmvc = nil;
        if (acceptedInvite) {
            mmvc = [[[GKMatchmakerViewController alloc] initWithInvite:acceptedInvite] autorelease];
        }
        else{
            GKMatchRequest *request = [[[GKMatchRequest alloc] init] autorelease];
            request.minPlayers = players;
            request.maxPlayers = players;
            request.playersToInvite = self.playersToInvite;
            mmvc = [[[GKMatchmakerViewController alloc] initWithMatchRequest:request] autorelease];
        }
        mmvc.matchmakerDelegate = self;
        [viewController presentViewController:mmvc animated:YES completion:nil];
    }
    self.playersToInvite = nil;
    self.acceptedInvite = nil;
}

#pragma mark GKMatchmakerViewControllerDelegate

// The user has cancelled matchmaking
- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController {
    [presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

// Matchmaking has failed with an error
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
    [presentingViewController dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Error finding match: %@", error.localizedDescription);
}

// A peer-to-peer match has been found, the game should start
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)theMatch {
    self.match = theMatch;
    match.delegate = self;
    if (!matchStarted && match.expectedPlayerCount == 0) {
        NSLog(@"Ready to start match!");
        [self lookupPlayers];
    }
}

#pragma mark GKMatchDelegate

// The match received data sent from the player.
- (void)match:(GKMatch *)theMatch didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    
    if (match != theMatch) return;
    if (!self.playersDict){
        //keep data for later
        [earlyData release];
        earlyData = [data retain];
        [earlyPlayerID release];
        earlyPlayerID = [playerID retain];
        NSLog(@"data received before playerlookup by %@", playerID);
    }
    else{
        [delegate match:theMatch didReceiveData:data fromPlayer:playerID];
    }
}

// The player state changed (eg. connected or disconnected)
- (void)match:(GKMatch *)theMatch player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state {
    if (match != theMatch) return;
    
    switch (state) {
        case GKPlayerStateConnected:
            // handle a new player connection.
            NSLog(@"Player connected!");
            if (!matchStarted && theMatch.expectedPlayerCount == 0) {
                NSLog(@"Ready to start match!");
                [self lookupPlayers];
            }
            
            break;
        case GKPlayerStateDisconnected:
            // a player just disconnected.
            NSLog(@"%@ disconnected.", playerID);
            NSString *disconnectedPlayer = [[self.playersDict objectForKey:playerID] displayName];
            [delegate matchEnded: [NSString stringWithFormat:@"%@ %@.", disconnectedPlayer, NSLocalizedString(@"disconnected", nil)]];
            break;
    }
}

// The match was unable to connect with the player due to an error.
- (void)match:(GKMatch *)theMatch connectionWithPlayerFailed:(NSString *)playerID withError:(NSError *)error {
    
    if (match != theMatch) return;
    [delegate matchEnded:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Failed to connect with", nil) ,[[self.playersDict objectForKey:playerID] displayName]]];
}

// The match was unable to be established with any players due to an error.
- (void)match:(GKMatch *)theMatch didFailWithError:(NSError *)error {
    
    if (match != theMatch) return;
    [delegate matchEnded:[NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Match failed with error", nil) ,error.localizedDescription]];
}


-(void)dealloc{
    self.presentingViewController = nil;
    self.acceptedInvite = nil;
    self.playersDict = nil;
    self.playersToInvite = nil;
    self.match = nil;
    [earlyPlayerID release];
    earlyPlayerID = nil;
    [earlyData release];
    earlyData = nil;
    [super dealloc];
}

@end
