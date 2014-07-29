//
//  GCHelper.h
//  Tablanet
//
//  Created by Valdrin on 15/12/12.
//  Copyright (c) 2012 Valdrin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@protocol GCHelperDelegate
- (void)matchStarted;
- (void)matchEnded:(NSString*)message;
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID;
- (void)didSucceedAuthentication;
- (void)didAcceptInvite;
@end

@interface GCHelper : NSObject <GKMatchmakerViewControllerDelegate, GKMatchDelegate> {
    UIViewController<GCHelperDelegate> *delegate;
    GKInvite *acceptedInvite;
    NSArray *playersToInvite;
    
    UIViewController *presentingViewController;
    GKMatch *match;
    BOOL matchStarted;
    NSMutableDictionary *playersDict;
    
    NSData *earlyData;
    NSString *earlyPlayerID;
}

@property (nonatomic,retain) GKInvite *acceptedInvite;
@property (nonatomic,retain) NSArray *playersToInvite;
@property (nonatomic,assign, readonly) BOOL userAuthenticated;
@property (nonatomic,assign) UIViewController<GCHelperDelegate> *delegate;

@property (nonatomic,retain) UIViewController *presentingViewController;
@property (nonatomic,retain) GKMatch *match;
@property (nonatomic,retain) NSMutableDictionary *playersDict;

+ (GCHelper *)sharedInstance;
+ (BOOL)gameCenterAvailable;
- (void)authenticateLocalPlayer;
- (void)findMatchWithPlayers:(int)players;
@end