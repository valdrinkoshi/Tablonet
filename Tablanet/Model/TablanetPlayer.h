//
//  Player.h
//  Tablanet
//
//  Created by Valdrin on 07/12/12.
//  Copyright (c) 2012 Valdrin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TablanetPlayer : NSObject{
    NSString *name;
    NSString *uid;
    NSMutableArray *cards;
    NSMutableArray *collectedCards;
    BOOL wantsToRematch;
}

@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *uid;
@property (nonatomic,retain) NSMutableArray *collectedCards;
@property (nonatomic,retain) NSMutableArray *cards;
@property (nonatomic) BOOL hasMoreCards;
@property (nonatomic,readonly) int points;
@property (nonatomic,readonly) int tablanets;
@property (nonatomic) BOOL wantsToRematch;

-(id)initWithName:(NSString*)playerName uid:(NSString*)playerId;
@end
