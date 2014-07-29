//
//  ViewController.h
//  Tablanet
//
//  Created by Valdrin on 16/12/12.
//  Copyright (c) 2012 Valdrin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCHelper.h"
#import "TablanetGame.h"
#import "TablanetGameViewController.h"
#import "TablanetButton.h"
#import "TablanetGameOverViewController.h"
#import "TablanetPlayerNamesViewController.h"

typedef enum {
    kMessageTypeGameBegin = 0,
    kMessageTypeTakesCards,
    kMessageTypeDropCard,
    kMessageTypeContinueWithNewMatch,
    kMessageTypeUndefined
} GCTablanetMessageType;

typedef struct {
    GCTablanetMessageType messageType;
} GCTablanetMessage;

typedef struct {
    GCTablanetMessage message;
    int randomSeed;
} GCTablanetMessageGameBegin;

typedef struct {
    GCTablanetMessage message;
} GCTablanetMessageContinueWithNewMatch;

typedef struct {
    int type;
    int value;
} GCTablanetCard;

typedef struct {
    GCTablanetMessage message;
    GCTablanetCard card;
} GCTablanetMessageDidDropCard;

typedef struct {
    GCTablanetMessage message;
    GCTablanetCard card;
    int cardsCount;
    GCTablanetCard takenCards[kCardsInDeck-1];
} GCTablanetMessageDidTakeCards;


typedef enum{
    TablanetConnectionTypeOffline = 0,
    TablanetConnectionTypeGameCenter,
    TablanetConnectionTypeBluetooth
}TablanetConnectionType;


@interface TablanetViewController : UIViewController<GCHelperDelegate, TablanetGameDelegate, GKSessionDelegate, GKPeerPickerControllerDelegate, TablanetGameViewControllerDelegate, TablanetGameOverViewControllerDelegate, TablanetPlayerNamesViewControllerDelegate,UIActionSheetDelegate>{
    TablanetButton *onlineBtn;
    TablanetButton *bluetoothBtn;
    TablanetButton *goProBtn;
    UISegmentedControl *numPlayersCtrl;
}

@property(nonatomic, retain) TablanetButton *onlineBtn;
@property(nonatomic, retain) TablanetButton *bluetoothBtn;
@property(nonatomic, retain) TablanetButton *goProBtn;
@property(nonatomic, retain) TablanetButton *twoPlayersBtn;
@property(nonatomic, retain) TablanetButton *fourPlayersBtn;

-(void)selectNumPlayers:(TablanetButton*)sender;
-(void)offlineGame;
-(void)onlineGame;
-(void)bluetoothWifi;
-(void)showHelp;
-(void)getProVersion;
@end
