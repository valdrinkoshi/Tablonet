//
//  TablanetPlayerNamesViewController.h
//  Tablanet
//
//  Created by Valdrin on 11/11/13.
//  Copyright (c) 2013 Valdrin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TablanetPlayer.h"

@protocol TablanetPlayerNamesViewControllerDelegate <NSObject>
-(void)playersReady:(NSMutableArray*)players;
@end

@interface TablanetPlayerNamesViewController : UITableViewController<UITextFieldDelegate>
-(id)initWithPlayers:(NSMutableArray*)players delegate:(id<TablanetPlayerNamesViewControllerDelegate>)delegate;
@end
