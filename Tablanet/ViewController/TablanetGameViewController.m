//
//  TablanetGameViewController.m
//  Tablanet
//
//  Created by Valdrin on 16/12/12.
//  Copyright (c) 2012 Valdrin. All rights reserved.
//

#import "TablanetGameViewController.h"
#import "TablanetCardView.h"
#import "TablanetCollectedCardsViewController.h"

@interface TablanetGameViewController (){
    TablanetPlayer *currentPlayer;
    TablanetPlayer *lockPlayer;
    TablanetCardView *currentCard;
    NSMutableArray *playerCards;
    NSMutableArray *tableCards;
    NSMutableArray *selectedTableCards;
    TablanetGame *game;
    TablanetCardView *touchedCardView;
    CGFloat curAngle;
    UIBarButtonItem *collectedCardsBtn;
    UIBarButtonItem *lastMoveBtn;
    BOOL didStartGame;
    BOOL shouldWaitForTap;
}
@end

@implementation TablanetGameViewController
@synthesize delegate;

-(id)initWithGame:(TablanetGame *)newGame lockPlayer:(TablanetPlayer *)player{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        didStartGame = YES;
        shouldWaitForTap = (player == nil);
        game = [newGame retain];
        lockPlayer = [player retain];
        
        playerCards = [[NSMutableArray alloc] init];
        
        tableCards = [[NSMutableArray alloc] init];
        selectedTableCards = [[NSMutableArray alloc] init];
        

        collectedCardsBtn = [[UIBarButtonItem alloc] initWithTitle:@"0 (0)" style:UIBarButtonItemStyleBordered target:self action:@selector(showPlayerCards)];
        collectedCardsBtn.enabled = false;
        lastMoveBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showLastMove)];
        lastMoveBtn.enabled = false;
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:lastMoveBtn, collectedCardsBtn, nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"End match", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(matchEnded)] autorelease];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectCardHandler:)] autorelease];
    [self.view addGestureRecognizer:tap];
    UIPanGestureRecognizer *longPress = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveCardHandler:)] autorelease];
    longPress.delegate = self;
    [self.view addGestureRecognizer:longPress];
    
    [game distributeCards];
    currentPlayer = [game.players objectAtIndex:0];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(didStartGame){
        didStartGame = NO;
        [self setupTable];
        [self setupCardsForPlayer:currentPlayer];        
    }
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

-(void)matchEnded{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@?", NSLocalizedString(@"End match", nil)] message:NSLocalizedString(@"End message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"End match",nil), nil];
    [alert show];
    [alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        [delegate endGame];        
    }
}

-(void)setupTable{
    [tableCards makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [tableCards removeAllObjects];
    CGFloat x = self.view.bounds.size.width * .5 - kCardWidth * .5;
    for (int i=0; i<game.cardsOnTable.count; i++) {
        TablanetCard *card = [game.cardsOnTable objectAtIndex:i];
        TablanetCardView *tableCard = [[[TablanetCardView alloc] init] autorelease];
        tableCard.card = card;
        [tableCards addObject:tableCard];
        tableCard.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        tableCard.frame = CGRectMake(x, -kCardHeight, kCardWidth, kCardHeight);
        [self.view addSubview:tableCard];
    }
}

-(void)setupCardsForPlayer:(TablanetPlayer*)player{
    [playerCards makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [playerCards removeAllObjects];
    currentCard = nil;
    
    [selectedTableCards removeAllObjects];
    [self layoutTableCards];
    
    currentPlayer = player;
    
    self.navigationItem.title = player.name;
    CGFloat x = self.view.bounds.size.width * .5 - kCardWidth * .5;
    for (int i=0; i<player.cards.count; i++) {
        TablanetCard *card = [player.cards objectAtIndex:i];
        TablanetCardView *playerCard = [[[TablanetCardView alloc] init] autorelease];
        playerCard.card = card;
        [playerCards addObject:playerCard];
        playerCard.frame = CGRectMake(x, self.view.bounds.size.height + 10, kCardWidth, kCardHeight);
        playerCard.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.view addSubview:playerCard];
    }
    TablanetPlayer *btnPlayer = lockPlayer ? lockPlayer : player;
    collectedCardsBtn.enabled = btnPlayer.collectedCards.count>0;
    collectedCardsBtn.title = [NSString stringWithFormat:@"%d (%d)",btnPlayer.collectedCards.count, btnPlayer.points];
    shouldWaitForTap = (lockPlayer == nil);
    [self performSelector:@selector(playCard:) withObject:nil afterDelay:.3];
}

//-(void)checkCardsAndPlay{
//    //if one card only and we are the player that should play
//    if (playerCards.count==1 && tableCards.count == 0 && (!lockPlayer || lockPlayer == currentPlayer )) {
//        shouldWaitForTap = NO;
//        [self playCard:[playerCards objectAtIndex:0]];
//        [self performSelector:@selector(dropCard) withObject:nil afterDelay:1];
//    }
//    else{
//        [self playCard:nil];
//    }
//}

//-(void)checkCardsAndPlay{
//    if (lockPlayer && lockPlayer != currentPlayer) {
//        [self playCard:nil];
//    }
//    else if(playerCards.count>1){
//        [self playCard:nil];
//    }
//    else if(tableCards.count==0){
//        shouldWaitForTap = NO;
//        [self playCard:[playerCards objectAtIndex:0]];
//        [self performSelector:@selector(dropCard) withObject:nil afterDelay:1];
//    }
//    else{
//        NSMutableArray *ar = [game cardsThatCouldBeTakenWithCard:currentCard.card];
//        shouldWaitForTap = ar.count == 0;
//        [self playCard:[playerCards objectAtIndex:0]];
//        if (ar.count>0) {
//            for (TablanetCardView *cv in tableCards) {
//                if ([ar containsObject:cv.card]) {
//                    [selectedTableCards addObject:cv];
//                }
//            }
//            [self performSelector:@selector(takeCards) withObject:nil afterDelay:1];
//        }
//    }
//}

-(TablanetCardView*)cardViewForGesture:(UIGestureRecognizer*)gesture{
    TablanetCardView *cardView = nil;
    if (!shouldWaitForTap && (!lockPlayer || lockPlayer == currentPlayer)) {
        for (int i=gesture.view.subviews.count-1; i>=0; i--) {
            TablanetCardView *v = [gesture.view.subviews objectAtIndex:i];
            CGPoint p = [gesture locationInView:v];
            if (CGRectContainsPoint(v.bounds, p)) {
                cardView = v;
                break;
            }
        }
    }
    return cardView;
}

-(void)selectCardHandler:(UITapGestureRecognizer*)sender{
    if (shouldWaitForTap) {
        shouldWaitForTap = NO;
        [self playCard:currentCard];
        return;
    }
    TablanetCardView *cardView = [self cardViewForGesture:sender];
    if (cardView==nil) {
        if (selectedTableCards.count>0) {
            [self deselectAllTableCards];
        }
        if (currentCard) {
            [self playCard:nil];
        }
    }
    else if([selectedTableCards containsObject:cardView]) {
        [self deselectTableCard:cardView];
    }
    else if ([tableCards containsObject:cardView]){
        [self selectTableCard:cardView];
    }
    else if(currentCard == cardView){
        if (selectedTableCards.count>0) {
            [self takeCards];
        }
        else{
            NSMutableArray *cardsToTake = [game cardsThatCouldBeTakenWithCard:currentCard.card];
            if (cardsToTake.count==0) {
                [self dropCard];
            }
            else{
                for (TablanetCardView *cv in tableCards) {
                    if ([cardsToTake containsObject:cv.card]) {
                        [selectedTableCards addObject:cv];
                    }
                }
                [self takeCards];
            }
        }
    }
    else {
        [self playCard:cardView];
    }
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    touchedCardView = [self cardViewForGesture:gestureRecognizer];
    if ([tableCards containsObject:touchedCardView]) {
        touchedCardView = nil;
    }
    return touchedCardView != nil;
}

-(void)selectTableCardCallback{
    CGPoint curCardCenter = currentCard.center;
    for (int i=tableCards.count-1; i>=0; i--) {
        TablanetCardView *cv = [tableCards objectAtIndex:i];
        if (CGRectContainsPoint(cv.frame, curCardCenter)) {
            [self selectTableCard:cv];
            break;
        }
    }
}

-(void)moveCardHandler:(UIPanGestureRecognizer*)sender{
    if (sender.state==UIGestureRecognizerStateBegan) {
        CGPoint touchInCard = [sender locationInView:touchedCardView];
        touchedCardView.layer.anchorPoint = CGPointMake(touchInCard.x/kCardWidth, touchInCard.y/kCardHeight);
        touchedCardView.center = [sender locationInView:sender.view];
        
        if ([playerCards containsObject:touchedCardView]) {
            [self playCard:touchedCardView];
        }
        else{
            [self selectTableCard:touchedCardView];
        }
        [self.view bringSubviewToFront:touchedCardView];
        curAngle = 0;
    }
    else if(sender.state==UIGestureRecognizerStateChanged){
        BOOL isPlayerCard = touchedCardView == currentCard;
        
        touchedCardView.center = [sender locationInView:sender.view];
        
        CGPoint anchor = CGPointMake(2*touchedCardView.layer.anchorPoint.x - 1 , 1 - 2*touchedCardView.layer.anchorPoint.y);
        CGFloat rotAngle = M_PI_2/3;
        CGPoint velocity = [sender velocityInView:sender.view];
        
        CGFloat xPerc = MIN(kCardWidth,ABS(velocity.x))/kCardWidth;
        if (velocity.x<0) {
            xPerc = -xPerc;
        }
        CGFloat yPerc = MIN(kCardHeight,ABS(velocity.y))/kCardHeight;
        if (velocity.y<0) {
            yPerc = -yPerc;
        }
        CGFloat angle = (rotAngle * yPerc * anchor.x + rotAngle * xPerc * anchor.y)/2;
        curAngle = .2 * angle + .8 * curAngle;
        touchedCardView.layer.transform = CATransform3DRotate(touchedCardView.identity, curAngle, 0, 0, 1);
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(selectTableCardCallback) object:nil];
        if (isPlayerCard) {
            [self performSelector:@selector(selectTableCardCallback) withObject:nil afterDelay:.2];
        }
    }
    else if(sender.state==UIGestureRecognizerStateEnded){
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(selectTableCardCallback) object:nil];
        CGFloat yParentCenter = self.view.bounds.size.height/2;
        CGPoint curCardOrigin = touchedCardView.frame.origin;
        CGPoint curCardCenter = CGPointMake(curCardOrigin.x+kCardWidth/2, curCardOrigin.y+kCardHeight/2);
        
        touchedCardView.layer.anchorPoint = CGPointMake(.5,.5);
        touchedCardView.center = curCardCenter;
        if (touchedCardView == currentCard && curCardOrigin.y<=yParentCenter) {
            if(selectedTableCards.count>0){
                [self takeCards];
            }
            else{
                NSMutableArray *cardsToTake = nil;
                //we first check if card was dropped in any other card
                //if player doesn't drop on top of other cards it means he doesn't want to take
                for (int i=tableCards.count-1; i>=0; i--) {
                    TablanetCardView *v = [tableCards objectAtIndex:i];
                    if (CGRectContainsPoint(v.frame, curCardCenter)) {
                        cardsToTake = [game cardsThatCouldBeTakenWithCard:currentCard.card];
                        break;
                    }
                }
                if (!cardsToTake || cardsToTake.count==0) {
                    [self dropCard];
                }
                else{
                    for (TablanetCardView *cv in tableCards) {
                        if ([cardsToTake containsObject:cv.card]) {
                            [selectedTableCards addObject:cv];
                        }
                    }
                    [self takeCards];
                }
            }
        }
        else if (touchedCardView == currentCard && curCardOrigin.y>yParentCenter) {
            //sort player cards
            NSMutableArray *cards = playerCards;
            [cards removeObject:touchedCardView];
            for (int i=0; i<cards.count; i++) {
                TablanetCardView *cv = [cards objectAtIndex:i];
                if(curCardCenter.x<cv.center.x && (i == 0 || curCardCenter.x >= [[cards objectAtIndex:i-1] center].x)){
                    [cards insertObject:touchedCardView atIndex:i];
                    break;
                }
            }
            if (![cards containsObject:touchedCardView]) {
                [cards addObject:touchedCardView];
            }
            
            [self playCard:currentCard];
        }
        else if(touchedCardView != currentCard && curCardCenter.y>yParentCenter){
            [self deselectTableCard:touchedCardView];
        }
        else if(touchedCardView != currentCard && curCardCenter.y<=yParentCenter){
            [self selectTableCard:touchedCardView];
        }
        touchedCardView = nil;
    }    
}

-(void)takeCards:(NSArray*)cardsToTake withCard:(TablanetCard*)card forPlayer:(TablanetPlayer*)player{
    TablanetCardView *newCurrentCard = [self cardViewForCard:card];
    if (currentCard != newCurrentCard) {
        [self playCard:newCurrentCard];
    }
    for (TablanetCardView *cv in tableCards) {
        if ([cardsToTake containsObject:cv.card]) {
            [self selectTableCard:cv];
        }
    }
    [self takeCardsForPlayer:player];
}

-(BOOL)takeCards{
    return [self takeCardsForPlayer:currentPlayer];
}

-(BOOL)takeCardsForPlayer:(TablanetPlayer*)player{
    NSMutableArray *cardsToTake = [NSMutableArray array];
    for (TablanetCardView *cardView in selectedTableCards) {
        [cardsToTake addObject:cardView.card];
    }
    BOOL canTake = currentCard && [game canTakeCards:cardsToTake withCard:currentCard.card];
    if (canTake) {
        
        lastMoveBtn.enabled = false;
        
        for (TablanetCardView *cardView in selectedTableCards) {
            [self.view bringSubviewToFront:cardView];
        }
        [self.view bringSubviewToFront:currentCard];
        [game player:player takesCards:cardsToTake withCard:currentCard.card];
        
        [tableCards removeObjectsInArray:selectedTableCards];
        
        TablanetCardView *pCard = currentCard;
        NSArray *tCards = [NSArray arrayWithArray:selectedTableCards];
        [selectedTableCards removeAllObjects];
        NSArray *pCards = [NSArray arrayWithArray:playerCards];
        [playerCards removeAllObjects];
        
        
        int i = ([game.players indexOfObject:player]+1)%game.players.count;
        TablanetPlayer *nextPlayer = [game.players objectAtIndex:i];
        [self setupCardsForPlayer:nextPlayer];
        
        //animation to show which cards are taken
        CGFloat overlap = 4;
        CGFloat cardSpace = MIN(kCardWidth-overlap, self.view.bounds.size.width/tCards.count);
        CGFloat offsetX = cardSpace/2 + MAX(0, (self.view.bounds.size.width - cardSpace * tCards.count)/2);
        CGFloat y = self.view.bounds.size.height * .5 - kCardHeight* .5 + 50;
        CGPoint center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height + kCardHeight/2);
        [UIView animateWithDuration:.3 animations:^{
            for (int i=0; i<tCards.count; i++) {
                TablanetCardView *tableCard = [tCards objectAtIndex:i];
                CGFloat x =offsetX + i*cardSpace;
                tableCard.center = CGPointMake(x, y - kCardHeight/6);
            }
            
            for (TablanetCardView *cardView in pCards) {
                if (pCard==cardView) {
                    cardView.center = CGPointMake(center.x, y + 50);
                }
                else{
                    cardView.center = CGPointMake(cardView.center.x, center.y);
                }
            }
        } completion:^(BOOL finished) {
            //animation to get the cards
            [UIView animateWithDuration:.3 delay:1 options:UIViewAnimationOptionCurveLinear animations:^{
                for (TablanetCardView *cardView in tCards) {
                    cardView.center = center;
                    [self.view bringSubviewToFront:cardView];
                }
                pCard.center = center;
                [self.view bringSubviewToFront:pCard];
            } completion:^(BOOL finished) {
                [tCards makeObjectsPerformSelector:@selector(removeFromSuperview)];
                [pCards makeObjectsPerformSelector:@selector(removeFromSuperview)];
                lastMoveBtn.enabled = true;
            }];
        }];
    }
    else{
        [self playCard:currentCard];
        [self deselectAllTableCards];
    }
    return canTake;
}
-(TablanetCardView*)cardViewForCard:(TablanetCard*)card{
    TablanetCardView *newCurrentCard = nil;
    for (TablanetCardView *cv in playerCards) {
        if (cv.card == card) {
            newCurrentCard = cv;
            break;
        }
    }
    return newCurrentCard;
}
-(void)dropCard:(TablanetCard*)card{
    TablanetCardView *newCurrentCard = [self cardViewForCard:card];
    if (currentCard != newCurrentCard) {
        [self playCard:newCurrentCard];
    }
    [self dropCard];
}

-(void)dropCard{
    if (currentCard) {
        lastMoveBtn.enabled = false;
        self.navigationItem.prompt = nil;
        
        [game player:currentPlayer playCard:currentCard.card];
        [selectedTableCards removeAllObjects];
        
        [playerCards removeObject:currentCard];
        if (tableCards.count==0) {
            [self.view addSubview:currentCard];
            [tableCards addObject:currentCard];
        }
        else{
            int iTableCard = [game.cardsOnTable indexOfObject:currentCard.card];
            int iView;
            if (iTableCard<tableCards.count) {
                iView = [self.view.subviews indexOfObject:[tableCards objectAtIndex:iTableCard]];
            }
            else{
                iView = [self.view.subviews indexOfObject:[tableCards lastObject]]+1;
            }
            [self.view insertSubview:currentCard atIndex:iView];
            [tableCards insertObject:currentCard atIndex:iTableCard];
        }
        
        currentCard = nil;
        [self deselectAllTableCards];
        
        [game checkTableAndDistribute];
        
        CGFloat y = self.view.bounds.size.height + kCardHeight/2;
        [UIView animateWithDuration:.3 animations:^{
            for (TablanetCardView *cardView in playerCards) {
                CGFloat x = cardView.center.x;
                cardView.center = CGPointMake(x, y);
            }
        } completion:^(BOOL finished) {
            if (finished) {
                int playerIndex = [game.players indexOfObject:currentPlayer];
                currentPlayer = (playerIndex+1)==game.players.count ? [game.players objectAtIndex:0] : [game.players objectAtIndex:playerIndex+1];
                [self setupCardsForPlayer:currentPlayer];
                lastMoveBtn.enabled = true;
            }            
        }];
    }
}

-(void)playCard:(TablanetCardView*)cardView{
    if ([playerCards containsObject:cardView]) {
        currentCard = cardView;
    }
    else{
        currentCard = nil;
    }
   
    
    CGFloat centerY = self.view.bounds.size.height - kCardHeight * .5 + 10;
    
    CGFloat totSpace = MIN(kCardWidth, self.view.bounds.size.width/playerCards.count);
    CGFloat offsetX = kCardWidth/2 + MAX(0, (self.view.bounds.size.width - totSpace * playerCards.count)/2);
    CGFloat hideRotation = (shouldWaitForTap || (lockPlayer && lockPlayer != currentPlayer)) * M_PI;
    [UIView animateWithDuration:.3 animations:^{
        for (int i=0; i<playerCards.count; i++) {
            TablanetCardView *playerCard = [playerCards objectAtIndex:i];
            CGFloat x = offsetX + i*totSpace;
            BOOL isSelected = playerCard==currentCard;
            playerCard.center = CGPointMake(x, centerY - isSelected * kCardHeight/6);
            playerCard.layer.transform = CATransform3DRotate(playerCard.identity, isSelected ? 0 : playerCard.rotation, 0, 0, 1);
            CATransform3D tr = isSelected ? playerCard.identity : CATransform3DRotate(playerCard.identity, hideRotation, 0, 1, 0);
            [playerCard animateLayerProperty:@"sublayerTransform" toValue:[NSNumber valueWithCATransform3D:tr] withDuration:.3];
            
            CGSize so = isSelected ? CGSizeMake(0, 3) : CGSizeZero;
            [playerCard animateLayerProperty:@"shadowOffset" toValue:[NSNumber valueWithCGSize:so] withDuration:.3];
            
            CGFloat sr = isSelected ? 8 : 2;
            [playerCard animateLayerProperty:@"shadowRadius" toValue:[NSNumber numberWithFloat:sr] withDuration:.3];
        }
    }];
}

-(void)selectTableCard:(TablanetCardView*)cardView{
    if ([tableCards containsObject:cardView] && ![selectedTableCards containsObject: cardView]) {
        [selectedTableCards addObject:cardView];
    }
    [self layoutTableCards];
}

-(void)deselectTableCard:(TablanetCardView*)cardView{
    if([selectedTableCards containsObject:cardView]){
        int i = [tableCards indexOfObject:cardView];
        [cardView removeFromSuperview];
        [self.view insertSubview:cardView atIndex:i];
        [selectedTableCards removeObject:cardView];
    }
    [self layoutTableCards];
}

-(void)deselectAllTableCards{
    [selectedTableCards removeAllObjects];
    [self layoutTableCards];
}


-(void)layoutTableCards{
    CGFloat overlap = 4;
    CGFloat cardSpace = MIN(kCardWidth-overlap, self.view.bounds.size.width/tableCards.count);
    CGFloat offsetX = cardSpace/2 + MAX(0, (self.view.bounds.size.width - cardSpace * tableCards.count)/2);
    CGFloat y = self.view.bounds.size.height * .5 - kCardHeight* .5 + 20;
    [UIView animateWithDuration:.3 animations:^{
        for (int i=0; i<tableCards.count; i++) {
            TablanetCardView *tableCard = [tableCards objectAtIndex:i];
            CGFloat x =offsetX + i*cardSpace;
            BOOL isSelected = [selectedTableCards containsObject: tableCard];
            tableCard.center = CGPointMake(x, y - isSelected * kCardHeight/6);
            tableCard.layer.transform = CATransform3DRotate(tableCard.identity, isSelected ? 0 : tableCard.rotation, 0, 0, 1);
            
            
            CGSize so = isSelected ? CGSizeMake(0, 3) : CGSizeZero;
            [tableCard animateLayerProperty:@"shadowOffset" toValue:[NSNumber valueWithCGSize:so] withDuration:.3];
            
            CGFloat sr = isSelected ? 8 : 2;
            [tableCard animateLayerProperty:@"shadowRadius" toValue:[NSNumber numberWithFloat:sr] withDuration:.3];
        }
    }];
}

-(void)showPlayerCards{
    TablanetPlayer *btnPlayer = lockPlayer ? lockPlayer : currentPlayer;
    TablanetCollectedCardsViewController *vc = [[TablanetCollectedCardsViewController alloc] initWithPlayer:btnPlayer];
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    vc.modalPresentationStyle = UIModalPresentationPageSheet;
    UINavigationController *nc = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7) {
        nc.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    }
    [self presentViewController:nc animated:YES completion:nil];
    [vc release];
}


-(void)showLastMove{
    lastMoveBtn.enabled = false;
    
    TablanetMove *move = [game.moves objectAtIndex:game.moves.count-1];
    CGPoint center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height + kCardHeight/2);
    CGFloat y = self.view.bounds.size.height * .5 - kCardHeight* .5 + 50;
    if (move.takenCards) {
        NSMutableArray *tCards = [NSMutableArray array];
        for (int i=0; i<move.takenCards.count; i++) {
            TablanetCard *card = [move.takenCards objectAtIndex:i];
            TablanetCardView *tableCard = [[[TablanetCardView alloc] init] autorelease];
            tableCard.card = card;
            tableCard.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            tableCard.bounds = CGRectMake(0, 0, kCardWidth, kCardHeight);
            tableCard.center = center;
            [self.view addSubview:tableCard];
            [tCards addObject:tableCard];
        }
        TablanetCardView *pCard = [[[TablanetCardView alloc] init] autorelease];
        pCard.card = move.playerCard;
        pCard.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        pCard.bounds = CGRectMake(0, 0, kCardWidth, kCardHeight);
        pCard.center = center;
        [self.view addSubview:pCard];
        
        
        //animation to show which cards are taken
        CGFloat overlap = 4;
        CGFloat cardSpace = MIN(kCardWidth-overlap, self.view.bounds.size.width/tCards.count);
        CGFloat offsetX = cardSpace/2 + MAX(0, (self.view.bounds.size.width - cardSpace * tCards.count)/2);
        [UIView animateWithDuration:.3 animations:^{
            for (int i=0; i<tCards.count; i++) {
                TablanetCardView *tableCard = [tCards objectAtIndex:i];
                CGFloat x =offsetX + i*cardSpace;
                tableCard.center = CGPointMake(x, y - kCardHeight/6);
            }
            pCard.center = CGPointMake(center.x, y + 50);
        } completion:^(BOOL finished) {
            //animation to get the cards
            [UIView animateWithDuration:.3 delay:1 options:UIViewAnimationOptionCurveLinear animations:^{
                for (TablanetCardView *cardView in tCards) {
                    cardView.center = center;
                }
                pCard.center = center;
            } completion:^(BOOL finished) {
                [tCards makeObjectsPerformSelector:@selector(removeFromSuperview)];
                [pCard removeFromSuperview];
                lastMoveBtn.enabled = true;
            }];
        }];
    }
    else{
        for (TablanetCardView *pCard in tableCards) {
            if ([pCard.card isEqual:move.playerCard]) {
                CGPoint pCenter = pCard.center;
                NSInteger i = [self.view.subviews indexOfObject:pCard];
                [self.view bringSubviewToFront:pCard];
                [UIView animateWithDuration:.3 animations:^{
                    pCard.center = CGPointMake(center.x, y + 50);
                } completion:^(BOOL finished) {
                    //animation to get the cards
                    [UIView animateWithDuration:.3 delay:1 options:UIViewAnimationOptionCurveLinear animations:^{
                        pCard.center = pCenter;
                    } completion:^(BOOL finished) {
                        [pCard removeFromSuperview];
                        [self.view insertSubview:pCard atIndex:i];
                        lastMoveBtn.enabled = true;
                    }];
                }];
                break;
            }
        }
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    [tableCards release];
    [selectedTableCards release];
    [game release];
    [playerCards release];
    [collectedCardsBtn release];
    [lastMoveBtn release];
    [lockPlayer release];
    delegate = nil;
    [super dealloc];
}
@end
