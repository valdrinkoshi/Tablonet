//
//  Deck.h
//  Tablanet
//
//  Created by Valdrin on 07/12/12.
//  Copyright (c) 2012 Valdrin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TablanetCard.h"
#import "TablanetPlayer.h"
#import "TablanetMove.h"

#define kCardsInDeck 52
#define kCardsOnTable 4
#define kCardsPerHand 6

@protocol TablanetGameDelegate <NSObject>

-(void)nextRound:(NSArray*)ranking;
-(void)gameOver:(NSArray*)ranking lastPlayerToTake:(TablanetPlayer*)lastPlayerToTake;
@optional
-(void)player:(TablanetPlayer*)player didDropCard:(TablanetCard*)card;
-(void)player:(TablanetPlayer*)player didTakeCards:(NSArray*)tableCards withCard:(TablanetCard*)card;
@end

@interface TablanetGame : NSObject{
    NSMutableArray *cardsOnTable;
    NSMutableArray *cardsToDistribute;
    NSMutableArray *players;
    NSMutableArray *moves;
    TablanetPlayer *lastPlayerToTake;
    id<TablanetGameDelegate> delegate;
    NSMutableArray *previousPoints;
    NSMutableArray *totalPoints;
}
@property(nonatomic,readonly) NSMutableArray *cardsOnTable;
@property(nonatomic, retain) NSMutableArray *players;
@property(nonatomic, readonly) NSMutableArray *moves;
@property(nonatomic, assign) id<TablanetGameDelegate> delegate;
@property(nonatomic,readonly) NSMutableArray *previousPoints;
@property(nonatomic,readonly) NSMutableArray *totalPoints;

-(NSMutableArray*)newDeckWithRandomSeed:(int)seed;
-(void)game:(BOOL)resetPreviousPoints;
-(void)gameWithCards:(NSMutableArray*)cards resetPreviousPoints:(BOOL)reset;
-(void)distributeCards;
-(void)checkTableAndDistribute;

-(BOOL)canTakeCards:(NSArray*)tableCards withCard:(TablanetCard*)card;
-(void)player:(TablanetPlayer*)player takesCards:(NSArray*)tableCards withCard:(TablanetCard*)card;
-(void)player:(TablanetPlayer*)player playCard:(TablanetCard*)card;
-(NSMutableArray*)cardsThatCouldBeTakenWithCard:(TablanetCard*)playerCard;

-(NSArray*)playersByPoints;
-(BOOL)shouldDistribute;

-(BOOL)arePlayersReadyToRematchExcept:(TablanetPlayer*)player;
@end
