//
//  MCHelper.h
//  Tablanet
//
//  Created by Valdrin on 17/12/13.
//  Copyright (c) 2013 Valdrin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <UIKit/UIKit.h>

@protocol MCHelperDelegate
- (void)MCMatchStarted;
- (void)matchEnded:(NSString*)message;
- (void)session:(MCSession *)match didReceiveData:(NSData *)data fromPeer:(NSString *)peerID;
@end


@interface MCHelper : NSObject<MCNearbyServiceAdvertiserDelegate, MCBrowserViewControllerDelegate, MCSessionDelegate>{
    MCPeerID *localPeer;
    MCSession *session;
    NSMutableArray *players;
}
@property (nonatomic,readonly) MCPeerID *localPeer;
@property (nonatomic,readonly) MCSession *session;
@property (nonatomic,readonly) NSMutableArray *players;
+ (MCHelper *)sharedInstance;

-(void)makeMeAvailable;
-(void)findPlayers:(NSInteger)playerCount delegate:(UIViewController<MCHelperDelegate>*)theDelegate;
@end
