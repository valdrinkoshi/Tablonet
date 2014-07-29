//
//  TablanetMove.m
//  Tablanet
//
//  Created by Valdrin on 15/12/13.
//  Copyright (c) 2013 Valdrin. All rights reserved.
//

#import "TablanetMove.h"

@implementation TablanetMove
@synthesize player;
@synthesize playerCard;
@synthesize takenCards;

-(void)dealloc{
    [player release];
    [playerCard release];
    [takenCards release];
    [super dealloc];
}
@end
