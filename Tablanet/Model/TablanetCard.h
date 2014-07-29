//
//  Card.h
//  Tablanet
//
//  Created by Valdrin on 07/12/12.
//  Copyright (c) 2012 Valdrin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    TablanetCardTypeHearts = 0,
    TablanetCardTypePainting = 1,
    TablanetCardTypeSpade = 2,
    TablanetCardTypeFlower = 3
} TablanetCardType;

@interface TablanetCard : NSObject{
    int value; // from 2 to 14
    TablanetCardType type;
    BOOL tablanet;
}
@property (nonatomic) int value;
@property (nonatomic) TablanetCardType type;
@property (nonatomic) BOOL tablanet;
@property (nonatomic,readonly) int points;
@property (nonatomic,readonly) NSString *formattedValue;
@property (nonatomic,readonly) NSString *formattedSymbol;

@end
