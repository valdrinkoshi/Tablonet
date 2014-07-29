//
//  OfflineGameViewController.h
//  Tablanet
//
//  Created by Valdrin on 16/12/12.
//  Copyright (c) 2012 Valdrin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TablanetGame.h"

@protocol TablanetGameViewControllerDelegate <NSObject>

-(void)endGame;

@end

@interface TablanetGameViewController : UIViewController<UIGestureRecognizerDelegate>{
    id<TablanetGameViewControllerDelegate> delegate;
}
@property (nonatomic,assign) id<TablanetGameViewControllerDelegate> delegate;
-(id)initWithGame:(TablanetGame*)newGame lockPlayer:(TablanetPlayer*)player;
-(void)dropCard:(TablanetCard*)card;
-(void)takeCards:(NSArray*)cardsToTake withCard:(TablanetCard*)card forPlayer:(TablanetPlayer*)player;

@end
