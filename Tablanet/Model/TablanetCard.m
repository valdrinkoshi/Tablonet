//
//  Card.m
//  Tablanet
//
//  Created by Valdrin on 07/12/12.
//  Copyright (c) 2012 Valdrin. All rights reserved.
//

#import "TablanetCard.h"

@implementation TablanetCard
@synthesize type;
@synthesize value;
@synthesize tablanet;

-(int)points{
    int points = 0;
    if (value>9) {
        points++;
    }
    //2 of flowers is 1 point
    if(type == TablanetCardTypeFlower && value==2){
        points++;
    }
    //10 of paintings is 2 points
    if (type == TablanetCardTypePainting && value == 10) {
        points++;
    }
    //tablanet is +1
    if (tablanet) {
        points++;
    }
    return points;
}

-(NSString*)description{
    return [NSString stringWithFormat:@"%@ %@", self.formattedValue, tablanet ? @"tablanet":@""];
};

-(NSString*)formattedValue{
    NSString *val = @"";
    switch (value) {
        case 11:
            val = NSLocalizedString(@"ACE", nil);
            break;
        case 12:
            val = NSLocalizedString(@"JACK", nil);
            break;
        case 13:
            val = NSLocalizedString(@"QUEEN", nil);
            break;
        case 14:
            val = NSLocalizedString(@"KING", nil);
            break;
        default:
            val = [NSString stringWithFormat:@"%d", value];
            break;
    }    
    return [NSString stringWithFormat:@"%@ %@", val, self.formattedSymbol];
}

-(NSString*)formattedSymbol{
    NSString *symbol = @"";
    switch (type) {
        case TablanetCardTypeHearts:
            symbol = @"♥";
            break;
        case TablanetCardTypePainting:
            symbol = @"♦";
            break;
        case TablanetCardTypeSpade:
            symbol = @"♠";
            break;
        case TablanetCardTypeFlower:
            symbol = @"♣";
            break;
        default:
            break;
    }
    return symbol;
}

@end
