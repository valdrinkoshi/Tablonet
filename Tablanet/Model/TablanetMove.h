//
//  TablanetMove.h
//  Tablanet
//
//  Created by Valdrin on 15/12/13.
//  Copyright (c) 2013 Valdrin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TablanetCard.h"
#import "TablanetPlayer.h"
@interface TablanetMove : NSObject{
    TablanetPlayer *player;
    TablanetCard *playerCard;
    NSArray *takenCards;
}
@property (nonatomic, retain) TablanetPlayer *player;
@property (nonatomic, retain) TablanetCard *playerCard;
@property (nonatomic, retain) NSArray *takenCards;

@end
