//
//  ViewController.m
//  Tablanet
//
//  Created by Valdrin on 16/12/12.
//  Copyright (c) 2012 Valdrin. All rights reserved.
//

#import "TablanetViewController.h"

#import "TablanetGameViewController.h"
#import "TablanetHelpViewController.h"
#import "TablanetInAppPurchaseManager.h"
#import "TablanetAllPointsViewController.h"

#define kFontName @"HiraKakuProN-W3"

@interface TablanetViewController (){
    TablanetGame *game;
    uint numPlayers;
    GKSession *session;
    GKMatch *match;
    TablanetPlayer *localPlayer;
    TablanetConnectionType connectionType;
    UIAlertView *waitForOthersAlert;
    BOOL wantsToRematch;
}
@end

@implementation TablanetViewController

@synthesize onlineBtn;
@synthesize bluetoothBtn;
@synthesize goProBtn;
@synthesize twoPlayersBtn;
@synthesize fourPlayersBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = @"Tablanet";
    
        waitForOthersAlert = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"End game" otherButtonTitles:@"Let's play!", nil];
        wantsToRematch = NO;
    }
    return self;
}

-(void)loadView{
    UIView *mainView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 480, 320)] autorelease];
    mainView.backgroundColor = [UIColor whiteColor];
    mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    int topmargin = 60;
    int tablanetFontSize = 68;
    UILabel *tablanet = [[[UILabel alloc] init] autorelease];
    tablanet.font = [UIFont fontWithName:kFontName size:tablanetFontSize];
    tablanet.tag = 999;
    tablanet.text = @"TABLANET";
    tablanet.textAlignment = NSTextAlignmentCenter;
    tablanet.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [tablanet sizeToFit];
    tablanet.frame = CGRectMake(0, topmargin, mainView.bounds.size.width, tablanet.bounds.size.height);
    [mainView addSubview:tablanet];
    
    UILabel *onetwo = [[[UILabel alloc] init] autorelease];
    onetwo.font = [UIFont fontWithName:kFontName size:50];
    onetwo.text = @"♥♦";
    onetwo.textColor = [UIColor colorWithRed:180/255.0 green:50/255.0 blue:40/255.0 alpha:1];
    onetwo.textAlignment = NSTextAlignmentRight;
    onetwo.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [onetwo sizeToFit];
    onetwo.frame = CGRectMake(0, tablanetFontSize + topmargin + 10, mainView.bounds.size.width * .5, onetwo.bounds.size.height);
    [mainView addSubview:onetwo];
    
    
    UILabel *onetwo1 = [[[UILabel alloc] init] autorelease];
    onetwo1.font = [UIFont fontWithName:kFontName size:50];
    onetwo1.text = @"♠♣";//@"♡ ♢ ♤ ♧";
    onetwo1.textAlignment = NSTextAlignmentLeft;
    onetwo1.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [onetwo1 sizeToFit];
    onetwo1.frame = CGRectMake(mainView.bounds.size.width * .5, tablanetFontSize + topmargin + 10, mainView.bounds.size.width * .5, onetwo.bounds.size.height);
    [mainView addSubview:onetwo1];
    
    
    TablanetButton *twoPlayers = [self buttonWithFrame:CGRectMake(370, 210, 50, 40) title:@"2P"];
    twoPlayers.selected = YES;
    numPlayers = 2;
    [twoPlayers addTarget:self action:@selector(selectNumPlayers:) forControlEvents:UIControlEventTouchUpInside];
    [mainView addSubview:twoPlayers];
    self.twoPlayersBtn = twoPlayers;
    
    TablanetButton *fourPlayers = [self buttonWithFrame:CGRectMake(420, 210, 50, 40) title:@"4P"];
    [fourPlayers addTarget:self action:@selector(selectNumPlayers:) forControlEvents:UIControlEventTouchUpInside];
    [mainView addSubview:fourPlayers];
    self.fourPlayersBtn = fourPlayers;
    
    TablanetButton *online = [self buttonWithFrame:CGRectMake(150, 270, 100, 40) title:@"GameCenter"];
    [online addTarget:self action:@selector(onlineGame) forControlEvents:UIControlEventTouchUpInside];
    [mainView addSubview:online];
    self.onlineBtn = online;
    
    TablanetButton *bluetooth = [self buttonWithFrame:CGRectMake(260, 270, 100, 40) title:@"Bluetooth"];
    [bluetooth addTarget:self action:@selector(bluetoothWifi) forControlEvents:UIControlEventTouchUpInside];
    [mainView addSubview:bluetooth];
    self.bluetoothBtn = bluetooth;
    
    TablanetButton *goPro = [self buttonWithFrame:CGRectMake(260, 270, 100, 40) title:@"Go Pro!"];
    [goPro addTarget:self action:@selector(getProVersion) forControlEvents:UIControlEventTouchUpInside];
    [mainView addSubview:goPro];
    self.goProBtn = goPro;
    
    TablanetButton *offline = [self buttonWithFrame:CGRectMake(370, 270, 100, 40) title:@"Offline"];
    [offline addTarget:self action:@selector(offlineGame) forControlEvents:UIControlEventTouchUpInside];
    [mainView addSubview:offline];
    
    UIButton *help = [UIButton buttonWithType:UIButtonTypeInfoDark];
    help.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    help.frame = CGRectMake(0, 270, 50, 40);
    [help addTarget:self action:@selector(showHelp) forControlEvents:UIControlEventTouchUpInside];
    [mainView addSubview:help];
    
    self.view = mainView;
}

-(void)freePro:(UITapGestureRecognizer*)sender{
    BOOL isPro = [[NSUserDefaults standardUserDefaults] boolForKey:@"isProUpgradePurchased"];
    if (!isPro) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isProUpgradePurchased" ];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionSucceededNotification object:self userInfo:nil];
        
    }
}

-(void)getProVersion{
    TablanetInAppPurchaseManager *pm = [TablanetInAppPurchaseManager singleton];
    if(pm.canMakePurchases){
        [pm purchaseProUpgrade];
    }
}

-(TablanetButton*)buttonWithFrame:(CGRect)frame title:(NSString*)title{
    TablanetButton *btn = [[[TablanetButton alloc] initWithFrame:frame] autorelease];
    btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont fontWithName:kFontName size:14];
    return btn;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    game = [[TablanetGame alloc] init];
    game.delegate = self;
    
    [self setProFeatures];
    
    BOOL isPro = [[NSUserDefaults standardUserDefaults] boolForKey:@"isProUpgradePurchased"];
    isPro = YES;
    if (!isPro) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inAppPurchaseHandler:) name:kInAppPurchaseManagerTransactionFailedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inAppPurchaseHandler:) name:kInAppPurchaseManagerTransactionSucceededNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inAppPurchaseHandler:) name:kInAppPurchaseManagerTransactionCancelledNotification object:nil];
        
        //free app gift!
//        UITapGestureRecognizer *proTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(freePro:)] autorelease];
//        proTap.numberOfTapsRequired = 10;
//        [self.view addGestureRecognizer:proTap];
//        [self.view performSelector:@selector(removeGestureRecognizer:) withObject:proTap afterDelay:5];

    }
    else{
        [self connectToGC];
    }
}

-(void)setProFeatures{
    BOOL isPro = [[NSUserDefaults standardUserDefaults] boolForKey:@"isProUpgradePurchased"];
    isPro = YES;
    self.onlineBtn.enabled = isPro;
    self.onlineBtn.alpha = isPro;
    self.bluetoothBtn.enabled = isPro;
    self.bluetoothBtn.alpha = isPro;
    self.goProBtn.enabled = !isPro;
    self.goProBtn.alpha = !isPro;
}


-(void)inAppPurchaseHandler:(NSNotification*)notification{
    [self setProFeatures];
    
    NSLog(@"%@",notification.name);
    if([notification.name isEqualToString:kInAppPurchaseManagerTransactionSucceededNotification]){
        [self connectToGC];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You're awesome!" message:@"Thank you :)\nEnjoy Tablanet Pro!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    else if([notification.name isEqualToString:kInAppPurchaseManagerTransactionFailedNotification]){
        NSError *error = [[notification.userInfo objectForKey:@"transaction"] error];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error.localizedDescription
                                                        message:error.localizedRecoverySuggestion delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}


-(void)connectToGC{
    [self.onlineBtn setTitle:NSLocalizedString(@"Connecting",nil) forState:UIControlStateNormal];
    self.onlineBtn.enabled = false;
    [[GCHelper sharedInstance] setDelegate:self];
    [[GCHelper sharedInstance] authenticateLocalPlayer];
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

-(void)selectNumPlayers:(TablanetButton *)sender{
    BOOL isTwo = sender == self.twoPlayersBtn;
    numPlayers = isTwo ? 2 : 4;
    self.twoPlayersBtn.selected = isTwo;
    self.fourPlayersBtn.selected = !isTwo;
}

#pragma HELP
-(void)showHelp{
    TablanetHelpViewController *vc = [[TablanetHelpViewController alloc] init];
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    vc.modalPresentationStyle = UIModalPresentationPageSheet;
    UINavigationController *nc = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7) {
        nc.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    }
    [self presentViewController:nc animated:YES completion:nil];
    [vc release];
}

#pragma OFFLINE Game

-(void)offlineGame{
    
    NSMutableArray *players = [NSMutableArray array];
    for (int i=0; i<numPlayers; i++) {
        TablanetPlayer *player = [[TablanetPlayer alloc] init];
        NSString *name =[NSString stringWithFormat:@"%@ %d",NSLocalizedString(@"Player",nil), i+1];
        player.name = name;
        player.uid = name;
        [players addObject:player];
        [player release];
    }
    [localPlayer release];
    localPlayer = nil;
    TablanetPlayerNamesViewController *vc= [[[TablanetPlayerNamesViewController alloc] initWithPlayers:players delegate:self] autorelease];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)playersReady:(NSMutableArray*)players{
    [self startMatchWithPlayers:players connectionType:TablanetConnectionTypeOffline];
}

#pragma mark WIFI & BLUETOOTH Game

-(void)bluetoothWifi{
    GKPeerPickerController *peerPicker = [[[GKPeerPickerController alloc] init] autorelease];
    peerPicker.delegate = self;
    peerPicker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    [peerPicker show];
    session.delegate = nil;
    [session release];
    session = nil;
    
//    [localPlayer release];
//    localPlayer = nil;
//    [session release];
//    session = nil;
//    [[MCHelper sharedInstance] findPlayers:numPlayers delegate:self];
}

//-(void)MCMatchStarted{
//    NSString *sName = [[UIDevice currentDevice] name];
//    localPlayer = [[TablanetPlayer alloc] initWithName:sName uid:sName];
//    session = [[MCHelper sharedInstance].session retain];
//    NSMutableArray *players = [NSMutableArray arrayWithObject:localPlayer];
//    NSArray *peers = [[MCHelper sharedInstance] players];
//    for (MCPeerID *peerId in peers) {
//        NSString *sName = peerId.displayName;
//        TablanetPlayer *player = [[[TablanetPlayer alloc] initWithName:sName uid:sName] autorelease];
//        [players addObject:player];
//        
//    }
//    [self startMatchWithPlayers:players connectionType:TablanetConnectionTypeBluetooth];
//}
//
//-(void)session:(MCSession *)match didReceiveData:(NSData *)data fromPeer:(NSString *)peerID{
//    [self handleData:data receivedFromPlayer:[self playerForId:peerID]];
//}

- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type
{
    //create ID for session
    NSString *sessionIDString = @"MTBluetoothSessionID";
    //create GKSession object
    GKSession *aSession = [[[GKSession alloc] initWithSessionID:sessionIDString displayName:nil sessionMode:GKSessionModePeer] autorelease];
    return aSession;
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)asession
{
    //set session delegate and dismiss the picker
    session = [asession retain];
    session.delegate = self;
    [session setDataReceiveHandler:self withContext:nil];
    
    picker.delegate = nil;
    [picker dismiss];
    // should wait for all players, but we are already 2
    [localPlayer release];
    localPlayer = [[TablanetPlayer alloc] initWithName:session.displayName uid:session.displayName];
    NSString *displayNamePeer = [session displayNameForPeer:peerID];
    TablanetPlayer *peerPlayer = [[[TablanetPlayer alloc] initWithName:displayNamePeer uid:displayNamePeer] autorelease];
    [self startMatchWithPlayers:[NSMutableArray arrayWithObjects:localPlayer, peerPlayer, nil] connectionType:TablanetConnectionTypeBluetooth];
}

- (void)session:(GKSession *)asession peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    if (![session isEqual:asession]) {
        return;
    }
    if (state == GKPeerStateDisconnected || state == GKPeerStateUnavailable){
        NSString *msg = [NSString stringWithFormat:@"%@ %@", [asession displayNameForPeer:peerID], NSLocalizedString(@"disconnected",nil)];
        [self matchEnded:msg];
    }
}
- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)asession context:(void *)context
{
    if (session != asession) {
        NSLog(@"diff session? %@ %@",asession.description, session.description);
    }
    
    [self handleData:data receivedFromPlayer:[self playerForId:[asession displayNameForPeer:peer]]];
}







#pragma mark GAME CENTER Game


-(void)onlineGame{
    [localPlayer release];
    localPlayer = nil;
    if ([[GCHelper sharedInstance] userAuthenticated]) {
        GKPlayer *gkLocalPlayer = [GKLocalPlayer localPlayer];
        localPlayer = [[TablanetPlayer alloc] initWithName:gkLocalPlayer.alias uid:gkLocalPlayer.playerID];
        [[GCHelper sharedInstance] findMatchWithPlayers:numPlayers];
    }
}

-(void)didSucceedAuthentication{
    BOOL b = [[GCHelper sharedInstance] userAuthenticated];
    self.onlineBtn.enabled = YES;
    if (b) {
        [self.onlineBtn setTitle:@"GameCenter" forState:UIControlStateNormal];
        [self.onlineBtn removeTarget:self action:@selector(connectToGC) forControlEvents:UIControlEventTouchUpInside];
        [self.onlineBtn addTarget:self action:@selector(onlineGame) forControlEvents:UIControlEventTouchUpInside];
    }
    else{
        [self.onlineBtn setTitle:NSLocalizedString(@"Connect again",nil) forState:UIControlStateNormal];
        [self.onlineBtn addTarget:self action:@selector(connectToGC) forControlEvents:UIControlEventTouchUpInside];
        [self.onlineBtn removeTarget:self action:@selector(onlineGame) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)didAcceptInvite{
    BOOL isPro = [[NSUserDefaults standardUserDefaults] boolForKey:@"isProUpgradePurchased"];
    isPro = YES;
    if (!isPro) {
        [self getProVersion];
    }
    else{
        [self.navigationController popToRootViewControllerAnimated:YES];
        [self onlineGame];
    }
}

-(void)matchStarted{
    [match release];
    match = nil;
    if (localPlayer) {
        NSMutableArray *players = [NSMutableArray arrayWithObject:localPlayer];
        NSArray *otherPlayers = [[[GCHelper sharedInstance] playersDict] allValues];
        for (GKPlayer *gkPlayer in otherPlayers) {
            TablanetPlayer *player = [[[TablanetPlayer alloc] initWithName:gkPlayer.alias uid:gkPlayer.playerID] autorelease];
            [players addObject:player];
            
        }
        match = [[GCHelper sharedInstance].match retain];
        [self startMatchWithPlayers:players connectionType:TablanetConnectionTypeGameCenter];
    }
    else{
        NSLog(@"localplayer is null!");
    }
}


-(void)matchEnded:(NSString *)message{
    NSLog(@"ending game");
    [match disconnect];
    match.delegate = nil;
    [match release];
    match = nil;
    
//    [session disconnect];
    
    [session disconnectFromAllPeers];
    session.delegate = nil;
    [session release];
    session = nil;
    
    [localPlayer release];
    localPlayer = nil;
    
    wantsToRematch = NO;
    
    [waitForOthersAlert dismissWithClickedButtonIndex:-1 animated:YES];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    //if message is null it means localplayer is the one to disconnect
    if (message) {
        [self.navigationController.topViewController dismissViewControllerAnimated:NO completion:nil];
        UIAlertView *alert = nil;
        if (game.previousPoints.count>0) {
            alert = [[[UIAlertView alloc] initWithTitle:@"Game over" message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Close", nil) otherButtonTitles:NSLocalizedString(@"Points", nil), nil] autorelease];
        }
        else{
            alert = [[[UIAlertView alloc] initWithTitle:@"Game over" message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"Close", nil) otherButtonTitles:nil] autorelease];
        }
        [alert show];
    }
    
}

-(void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID{
    [self handleData:data receivedFromPlayer:[self playerForId:playerID]];
}


//TODO

-(void)enterNewGame:(GKTurnBasedMatch *)match{
    
}
-(void)layoutMatch:(GKTurnBasedMatch *)match{
    
}

-(void)takeTurn:(GKTurnBasedMatch *)match{
    
}

-(void)receiveEndGame:(GKTurnBasedMatch *)match{
    
}
-(void)sendNotice:(NSString *)notice forMatch:(GKTurnBasedMatch *)match{
    
}


-(TablanetPlayer*)playerForId:(NSString*)pid{
    TablanetPlayer *p = nil;
    for (TablanetPlayer *player in game.players) {
        if ([player.uid isEqualToString:pid]) {
            p = player;
            break;
        }
    }
    return p;
};

#pragma mark Message utils
-(TablanetCard*)cardForGCCard:(GCTablanetCard)gcCard fromCards:(NSArray*)cards{
    if (gcCard.type>3 || gcCard.value>14) {
        return nil;
    }
    int value = gcCard.value;
    TablanetCardType type = (TablanetCardType)gcCard.type;
    
    for (TablanetCard *card in cards) {
        if (card.value==value && card.type==type) {
            return card;
        }
    }
    return nil;
}


#pragma mark TablanetGameDelegate methods

-(void)gameOver:(NSArray *)ranking lastPlayerToTake:(TablanetPlayer *)lastPlayerToTake{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(gotoGameover:) withObject:ranking afterDelay:1];
}

-(void)gotoGameover:(NSArray*)ranking{
    TablanetGameOverViewController *gameOverVC = [[TablanetGameOverViewController alloc] initWithGame:game delegate:self];
    [self.navigationController pushViewController:gameOverVC animated:YES];
    [gameOverVC release];
}

-(void)player:(TablanetPlayer *)player didTakeCards:(NSArray *)tableCards withCard:(TablanetCard *)card{
    if (card.tablanet) {
        NSString *prompt = [NSString stringWithFormat:@"%@ %@ Tablanet!", player.name, NSLocalizedString(@"did",nil)];
        [self setPromptAndNavHidden:prompt];
    }
    
    if ([player.uid isEqualToString:localPlayer.uid]) {        
        GCTablanetMessageDidTakeCards message;
        message.message.messageType = kMessageTypeTakesCards;
        GCTablanetCard gcCard;
        gcCard.type = card.type;
        gcCard.value = card.value;
        message.card = gcCard;
        int cardsCount = tableCards.count;
        message.cardsCount = cardsCount;
        for (int i=0; i<cardsCount; i++) {
            TablanetCard *tc = [tableCards objectAtIndex:i];
            int type = tc.type;
            int value = tc.value;
            message.takenCards[i].type = type;
            message.takenCards[i].value = value;
        }
        //this will truncate exceeding bytes
        int dataLength = sizeof(GCTablanetMessageDidTakeCards) - sizeof(GCTablanetCard) * (kCardsInDeck - 1 - cardsCount);
        NSData *data = [NSData dataWithBytes:&message length:dataLength];
        [self sendData:data connectionType:connectionType];
    }
}

-(void)player:(TablanetPlayer *)player didDropCard:(TablanetCard *)card{
    if ([player.uid isEqualToString:localPlayer.uid]) {
        GCTablanetMessageDidDropCard message;
        message.message.messageType = kMessageTypeDropCard;
        GCTablanetCard gcCard;
        gcCard.type = card.type;
        gcCard.value = card.value;
        message.card = gcCard;
        NSData *data = [NSData dataWithBytes:&message length:sizeof(GCTablanetMessageDidDropCard)];
        [self sendData:data connectionType:connectionType];
    }
}

-(void)nextRound:(NSArray *)ranking{
    NSString *prompt = NSLocalizedString(@"new round",nil);
    [self setPromptAndNavHidden:prompt];
    NSLog(@"%@", ranking.description);
}




-(void)startMatchWithPlayers:(NSMutableArray*)players connectionType:(TablanetConnectionType)cType{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedPlayers = [players sortedArrayUsingDescriptors:sortDescriptors];
    game.players = [NSMutableArray arrayWithArray:sortedPlayers];
    connectionType = cType;
    //close the alert if any
    [waitForOthersAlert dismissWithClickedButtonIndex:-1 animated:YES];
    
    //reset the wantstorematch;
    for (TablanetPlayer *player in game.players) {
        player.wantsToRematch = NO;
    }
    [self updateAlertMessage];
    // be sure to be on the root controller
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    if (connectionType == TablanetConnectionTypeOffline) {
        [game game:!wantsToRematch];
        TablanetGameViewController *gameVC = [[[TablanetGameViewController alloc] initWithGame:game lockPlayer:nil] autorelease];
        gameVC.delegate = self;
        [self.navigationController pushViewController:gameVC animated:YES];
    }
    else if ([[game.players objectAtIndex:0] isEqual:localPlayer]) {
        NSLog(@"%@ starts the game", localPlayer.uid);
        
        GCTablanetMessageGameBegin message;
        message.message.messageType = kMessageTypeGameBegin;
        int randomSeed = abs((int)arc4random());
        NSLog(@"sending seed %d",randomSeed);
        message.randomSeed = randomSeed;
        NSData *data = [NSData dataWithBytes:&message length:sizeof(GCTablanetMessageGameBegin)];
        BOOL success = [self sendData:data connectionType:cType];
        if (!success) {
            game.players = nil;
        }
        else{
            NSMutableArray *cards = [game newDeckWithRandomSeed:randomSeed];
            [game gameWithCards:cards resetPreviousPoints:!wantsToRematch];
            TablanetGameViewController *gameVC = [[[TablanetGameViewController alloc] initWithGame:game lockPlayer:localPlayer] autorelease];
            gameVC.delegate = self;
            [self.navigationController pushViewController:gameVC animated:YES];
        }
    }
}

-(void)handleData:(NSData*)data receivedFromPlayer:(TablanetPlayer*)player{
    NSString *playerName = player.name;
    GCTablanetMessage *message = (GCTablanetMessage *) [data bytes];
    if (message->messageType == kMessageTypeGameBegin) {
        //close the alert if any
        [waitForOthersAlert dismissWithClickedButtonIndex:-1 animated:YES];
        
        //reset the wantstorematch;
        for (TablanetPlayer *player in game.players) {
            player.wantsToRematch = NO;
        }
        [self updateAlertMessage];
        
        // be sure to be on the root controller
        [self.navigationController popToRootViewControllerAnimated:NO];
        
        GCTablanetMessageGameBegin * gameBeginMessage = (GCTablanetMessageGameBegin *) [data bytes];
        int randomSeed = gameBeginMessage->randomSeed;
        NSLog(@"%@ started new game passing randomSeed %d", playerName, randomSeed);
        NSMutableArray *cards = [game newDeckWithRandomSeed:randomSeed];
        [game gameWithCards:cards resetPreviousPoints:!wantsToRematch];
        TablanetGameViewController *gameVC = [[[TablanetGameViewController alloc] initWithGame:game lockPlayer:localPlayer] autorelease];
        gameVC.delegate = self;
        [self.navigationController pushViewController:gameVC animated:YES];
    }
    else if(message->messageType == kMessageTypeDropCard){
        GCTablanetMessageDidDropCard * dropCardMessage = (GCTablanetMessageDidDropCard *) [data bytes];
        NSLog(@"%@ dropped card", playerName);
        
        TablanetCard *card = [self cardForGCCard:dropCardMessage->card fromCards:player.cards];
        TablanetGameViewController *gameVC = (TablanetGameViewController *)self.navigationController.topViewController;
        if (gameVC.presentedViewController) {
            [gameVC.presentedViewController dismissViewControllerAnimated:YES completion:^{
                [gameVC dropCard:card];
            }];
        }
        else{
            [gameVC dropCard:card];
        }
    }
    else if(message->messageType == kMessageTypeTakesCards){
        GCTablanetMessageDidTakeCards * takeCardsMessage = (GCTablanetMessageDidTakeCards *) [data bytes];
        NSLog(@"%@ took cards", playerName);
        
        TablanetCard *card = [self cardForGCCard:takeCardsMessage->card fromCards:player.cards];
        NSMutableArray *cardsToTake = [NSMutableArray array];
        int cardsCount = takeCardsMessage->cardsCount;
        for (int i=0; i<cardsCount; i++) {
            GCTablanetCard c = takeCardsMessage->takenCards[i];
            TablanetCard *tc = [self cardForGCCard:c fromCards:game.cardsOnTable];
            [cardsToTake addObject:tc];
        }
        TablanetGameViewController *gameVC = (TablanetGameViewController *)self.navigationController.topViewController;
        if (gameVC.presentedViewController) {
            [gameVC.presentedViewController dismissViewControllerAnimated:YES completion:^{
                [gameVC takeCards:cardsToTake withCard:card forPlayer:player];
            }];
        }
        else{
            [gameVC takeCards:cardsToTake withCard:card forPlayer:player];
        }
    }
    else if(message->messageType == kMessageTypeContinueWithNewMatch){
        player.wantsToRematch = YES;
        NSLog(@"%@ wants to continue", playerName);
        //update alert message
        [self updateAlertMessage];
        BOOL allReady = [game arePlayersReadyToRematchExcept:localPlayer];
        //if everyone is ready except me
        if(allReady && localPlayer.wantsToRematch == NO){
            [waitForOthersAlert show];
        }
        else if(allReady && [[game.players objectAtIndex:0] isEqual:localPlayer]){
            [self startMatchWithPlayers:game.players connectionType:connectionType];
        }
    }
}

-(void)updateAlertMessage{
    BOOL allOthersReady = [game arePlayersReadyToRematchExcept:localPlayer];
    waitForOthersAlert.title = allOthersReady ? @"Everyone is waiting for you!" : @"Waiting for other players";
    NSMutableString *msg = [NSMutableString string];
    for (TablanetPlayer *player in game.players) {
        [msg appendString:player.name];
        [msg appendString:player.wantsToRematch ? @" ✅" : @" 🕐"];
        [msg appendString:@"\n"];
    }
    waitForOthersAlert.message = msg;
}

-(BOOL)sendData:(NSData*)data connectionType:(TablanetConnectionType)cType{
    BOOL success = false;
    NSError *err;
    if (cType==TablanetConnectionTypeGameCenter) {
        success = [match sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:&err];
    }
    else if(cType==TablanetConnectionTypeBluetooth){
//        success = [session sendData:data toPeers:[[MCHelper sharedInstance] players] withMode:MCSessionSendDataReliable error:&err];
        success = [session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:&err];
    }
    if (!success) {
        [self matchEnded:[NSString stringWithFormat:@"%@; %@",NSLocalizedString(@"Error sending packet", nil), err.description]];
    }
    return success;
}

#pragma mark utils

-(void)setPromptAndNavHidden:(NSString*)prompt{
    self.navigationController.visibleViewController.navigationItem.prompt = prompt;
//    [self.navigationController setNavigationBarHidden:prompt==nil animated:YES];
    if (prompt) {
        [self performSelector:@selector(setPromptAndNavHidden:) withObject:nil afterDelay:2];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark TablanetGameOverViewControllerDelegate

-(void)close{
    if (localPlayer.wantsToRematch) {
        [waitForOthersAlert show];
    }
    else{
        UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"New match", nil), NSLocalizedString(@"End match", nil), nil];
        [action showFromBarButtonItem:self.navigationController.topViewController.navigationItem.leftBarButtonItem animated:YES];
        [action release];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    [self rematch:buttonIndex==0];
}

-(void)rematch:(BOOL)rematch{
    wantsToRematch = rematch;
    localPlayer.wantsToRematch = wantsToRematch;
    if (!wantsToRematch) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        [self endGame];
    }
    else {
        BOOL canStartMatch = [[game.players objectAtIndex:0] isEqual:localPlayer] && [game arePlayersReadyToRematchExcept:localPlayer];
        if (connectionType == TablanetConnectionTypeOffline || canStartMatch) {
            [self startMatchWithPlayers:game.players connectionType:connectionType];
        }
        else{
            //show busy indicator
            [self updateAlertMessage];
            
            //notify that player wants to rematch
            GCTablanetMessageContinueWithNewMatch message;
            message.message.messageType = kMessageTypeContinueWithNewMatch;
            NSData *data = [NSData dataWithBytes:&message length:sizeof(GCTablanetMessageContinueWithNewMatch)];
            [self sendData:data connectionType:connectionType];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *btnTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if (alertView == waitForOthersAlert) {
        if ([btnTitle isEqualToString:@"End game"]) {
            [self endGame];
        }
        else if([game arePlayersReadyToRematchExcept:localPlayer]){
            [self rematch:YES];
        }
    }
    else if([btnTitle isEqualToString:NSLocalizedString(@"Points", nil)]){
        TablanetAllPointsViewController *allPts = [[[TablanetAllPointsViewController alloc] initWithGame:game] autorelease];
        [self.navigationController pushViewController:allPts animated:YES];
    }
}
#pragma mark TablanetViewControllerDelegate

-(void)endGame{
    [self matchEnded:nil];
}

-(void)dealloc{
    self.onlineBtn = nil;
    self.bluetoothBtn = nil;
    self.goProBtn = nil;
    self.twoPlayersBtn = nil;
    self.fourPlayersBtn = nil;
    [session release];
    [match release];
    [waitForOthersAlert release];
    [super dealloc];
}
@end
