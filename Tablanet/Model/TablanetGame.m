//
//  Deck.m
//  Tablanet
//
//  Created by Valdrin on 07/12/12.
//  Copyright (c) 2012 Valdrin. All rights reserved.
//

#import "TablanetGame.h"

@implementation TablanetGame
@synthesize delegate;
@synthesize players;
@synthesize moves;
@synthesize cardsOnTable;
@synthesize previousPoints;
@synthesize totalPoints;

-(id)init{
    self = [super init];
    if (self) {
        previousPoints = [[NSMutableArray alloc] init];
        totalPoints = [[NSMutableArray alloc] init];
        moves = [[NSMutableArray alloc] init];
    }
    return self;
}

-(NSMutableArray*)newDeckWithRandomSeed:(int)seed{
    NSMutableArray *cards = [NSMutableArray array];
    for (int i=0; i<kCardsInDeck; i++) {
        TablanetCard *card = [[TablanetCard alloc] init];
        card.type = floor(i/13.0);
        card.value = 2 + i%13;
        [cards addObject:card];
        [card release];
    }
    NSMutableArray *randomCards = [NSMutableArray array];
    int sign = 1;
    uint half = (uint)ceil(seed/2.0);
    while (cards.count>0) {
        int i = (seed + sign * half)%cards.count;
        TablanetCard *card = [cards objectAtIndex:i];
        [randomCards addObject:card];
        [cards removeObjectAtIndex:i];
        sign *= -1;
    }
    return randomCards;
}

-(void)game:(BOOL)resetPreviousPoints{
    [self gameWithCards:[self newDeckWithRandomSeed:arc4random()] resetPreviousPoints:resetPreviousPoints];
}

-(void)gameWithCards:(NSMutableArray*)cards resetPreviousPoints:(BOOL)reset{
    
    lastPlayerToTake = nil;
    
    [cardsToDistribute release];
    cardsToDistribute = [[NSMutableArray alloc] initWithArray:cards];
    
    [moves removeAllObjects];
    if (reset) {
        [previousPoints removeAllObjects];
        [totalPoints removeAllObjects];
    }
    //put cards on the table
    [cardsOnTable release];
    cardsOnTable = [[NSMutableArray alloc] initWithArray:[cardsToDistribute subarrayWithRange:NSMakeRange(0, kCardsOnTable)]];
    [cardsOnTable sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"value" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"type" ascending:YES], nil]];
    //remove them from the deck
    [cardsToDistribute removeObjectsInRange:NSMakeRange(0, kCardsOnTable)];
    for (TablanetPlayer *player in players) {
        player.hasMoreCards = NO;
        [player.cards removeAllObjects];
        [player.collectedCards removeAllObjects];
    }
}

-(void)player:(TablanetPlayer *)player playCard:(TablanetCard *)card{
    //save the move
    TablanetMove *tm = [[TablanetMove alloc] init];
    tm.playerCard = card;
    tm.player = player;
    [moves addObject:tm];
    [tm release];
    
    [cardsOnTable addObject:card];
    [cardsOnTable sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"value" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"type" ascending:YES], nil]];
    [player.cards removeObject:card];
    
    
    if ([delegate respondsToSelector:@selector(player:didDropCard:)]) {
        [delegate player:player didDropCard:card];
    }
}

-(BOOL)shouldDistribute{
    for (TablanetPlayer *p in players) {
        if (p.cards.count>0) {
            return false;
        }
    }
    return true;
}

-(void)checkTableAndDistribute{
    if (self.shouldDistribute) {
        if (cardsToDistribute.count==0) {
            [lastPlayerToTake.collectedCards addObjectsFromArray:cardsOnTable];
            [lastPlayerToTake.collectedCards sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"value" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"type" ascending:YES], nil]];
            [cardsOnTable removeAllObjects];
            //need to call playerByPoints to setup who has more cards
            [self playersByPoints];
            
            NSMutableArray *points = [NSMutableArray array];
            for (int i=0; i<players.count; i++) {
                TablanetPlayer *player = [players objectAtIndex:i];
                int pts = player.points;
                [points addObject:[NSNumber numberWithInt:pts]];
                if (totalPoints.count==i) {
                    [totalPoints addObject:[NSNumber numberWithInt:pts]];
                }
                else{
                    int tot = [[totalPoints objectAtIndex:i] intValue] + pts;
                    [totalPoints replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:tot]];
                }
            }
            [previousPoints addObject:points];
            [delegate gameOver:self.playersByPoints lastPlayerToTake:lastPlayerToTake];
        }
        else{
            [self distributeCards];
        }
    }
}

-(void)removeCardsFromArray:(NSMutableArray*)arr thatSumTo:(NSInteger)sum fromIndex:(NSInteger)k temp:(NSMutableArray*)_temp{
    if(sum <= 0 || k < 0 || k >= arr.count) {
        return;
    }
    TablanetCard *card = [arr objectAtIndex:k];
    int value = card.value;
    for (NSNumber *n in _temp) {
        int idx = [n intValue];
        TablanetCard *card = [arr objectAtIndex:idx];
        value += card.value;
    }
    if(sum == value) {
        //remove values from array & empty _temp
        for (NSNumber *n in _temp) {
            int idx = [n intValue];
            [arr removeObjectAtIndex:idx];
        }
        [arr removeObjectAtIndex:k];
        [_temp removeAllObjects];
        [self removeCardsFromArray:arr thatSumTo:sum fromIndex:arr.count-1 temp:_temp];
    }
    else{
        [_temp addObject:[NSNumber numberWithInt:k]];
        [self removeCardsFromArray:arr thatSumTo:sum fromIndex:k-1 temp:_temp];
        [_temp removeLastObject];
        [self removeCardsFromArray:arr thatSumTo:sum fromIndex:k-1 temp:_temp];
    }
}

-(BOOL)canTakeCards:(NSArray*)tableCards withCard:(TablanetCard*)card{
    
    NSMutableArray *sortedCards = [NSMutableArray arrayWithArray:tableCards];
    [sortedCards sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"value" ascending:NO], nil]];
    
    NSMutableArray *aces = [NSMutableArray array];
    for (TablanetCard *tableCard in sortedCards) {
        if (tableCard.value == 11) {
            //is ace
            [aces addObject:tableCard];
        }
        else if(tableCard.value > card.value){
            //bigger cards can't be taken
            return false;
        }
    }
    [self removeCardsFromArray:sortedCards thatSumTo:card.value fromIndex:sortedCards.count-1 temp:[NSMutableArray array]];
    //special case if we have aces and there are cards still remaining
    for (int i=0; i<aces.count && sortedCards.count>0; i++) {
        TablanetCard *ace = [aces objectAtIndex:i];
        //ace as 1 temporarly
        ace.value = 1;
        //sort the cards with aces = 1
        sortedCards = [NSMutableArray arrayWithArray:tableCards];
        [sortedCards sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"value" ascending:NO], nil]];
        [self removeCardsFromArray:sortedCards thatSumTo:card.value fromIndex:sortedCards.count-1 temp:[NSMutableArray array]];
    }
    //reset aces value to 11 again
    for (TablanetCard *ace in aces) {
        ace.value = 11;
    }
    return sortedCards.count == 0;
};

-(NSMutableArray*)cardsThatCouldBeTakenWithCard:(TablanetCard*)playerCard{
    NSMutableArray *suggestions = [NSMutableArray array];
    if ([self canTakeCards:cardsOnTable withCard:playerCard]) {
        suggestions = cardsOnTable;
    }
    else{
        int value = playerCard.value;
        for (TablanetCard *card in cardsOnTable) {
            if (card.value == value) {
                [suggestions addObject:card];
            }
        }
    }
    return suggestions;
};

-(void)player:(TablanetPlayer*)player takesCards:(NSArray*)tableCards withCard:(TablanetCard*)card{
    //save the move
    TablanetMove *tm = [[TablanetMove alloc] init];
    tm.playerCard = card;
    tm.takenCards = tableCards;
    tm.player = player;
    [moves addObject:tm];
    [tm release];
    
    [player.collectedCards addObjectsFromArray:tableCards];
    [cardsOnTable removeObjectsInArray:tableCards];
    [player.collectedCards addObject:card];
    
    [player.collectedCards sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"value" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"type" ascending:YES], nil]];
    
    [player.cards removeObject:card];
    card.tablanet = (cardsOnTable.count==0);
    lastPlayerToTake = player;
    if ([delegate respondsToSelector:@selector(player:didTakeCards:withCard:)]) {
        [delegate player:player didTakeCards:tableCards withCard:card];
    }
    [self checkTableAndDistribute];
}


-(void)distributeCards{
    //distribute 6 cards per player
    for (int i=0; i<players.count; i++) {
        TablanetPlayer *player = [players objectAtIndex:i];
        NSArray *cards = [cardsToDistribute subarrayWithRange:NSMakeRange(kCardsPerHand*i, kCardsPerHand)];
        player.cards = [NSMutableArray arrayWithArray:cards];
        [player.cards sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"value" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"type" ascending:YES], nil]];
    }
    
    //remove them from the deck
    [cardsToDistribute removeObjectsInRange:NSMakeRange(0, kCardsPerHand*players.count)];
    if ([delegate respondsToSelector:@selector(nextRound:)]) {
        [delegate nextRound:self.playersByPoints];
    }
}

-(void)shuffleDeck:(NSMutableArray*)aDeck{
    NSUInteger count = [aDeck count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = count - i;
        NSInteger n = (arc4random() % nElements) + i;
        [aDeck exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

-(NSArray *)playersByPoints{
    TablanetPlayer *firstWithMoreCards = nil;    
    if (cardsToDistribute.count==0 && cardsOnTable.count==0) {
        NSArray *playersByCardCount = [players sortedArrayUsingComparator:^NSComparisonResult(TablanetPlayer *p1, TablanetPlayer *p2) {
            int c1 = p1.collectedCards.count;
            int c2 = p2.collectedCards.count;
            if (c1 < c2) {
                return NSOrderedDescending;
            }
            if (c1 > c2) {
                return NSOrderedAscending;
            }
            return NSOrderedSame;
        }];
        firstWithMoreCards = [playersByCardCount objectAtIndex:0];
        TablanetPlayer *secondWithMoreCards = [playersByCardCount objectAtIndex:1];
        if (firstWithMoreCards.collectedCards.count == secondWithMoreCards.collectedCards.count) {
            firstWithMoreCards = nil;
            secondWithMoreCards = nil;
        }
    }
    for (TablanetPlayer *p in players) {
        p.hasMoreCards = p == firstWithMoreCards;
    }
    
    NSArray *playersByPoints = [players sortedArrayUsingComparator:^NSComparisonResult(TablanetPlayer *p1, TablanetPlayer *p2) {
        int c1 = p1.points;
        int c2 = p2.points;
        if (c1 < c2) {
            return NSOrderedDescending;
        }
        if (c1 > c2) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
    return playersByPoints;
}

-(BOOL)arePlayersReadyToRematchExcept:(TablanetPlayer *)player{
    BOOL allReady = YES;
    for (TablanetPlayer *p in players) {
        if (p != player && !p.wantsToRematch) {
            allReady = NO;
            break;
        }
    }
    return allReady;
}

-(void)dealloc{
    lastPlayerToTake = nil;
    delegate = nil;
    [players release];
    [moves release];
    [cardsToDistribute release];
    [cardsOnTable release];
    [previousPoints release];
    [totalPoints release];
    [super dealloc];
}

@end
