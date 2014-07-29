//
//  TablanetGameOverViewController.h
//  Tablanet
//
//  Created by Valdrin on 24/06/13.
//  Copyright (c) 2013 Valdrin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TablanetGame.h"

@protocol TablanetGameOverViewControllerDelegate <NSObject>
-(void)close;
@end

@interface TablanetGameOverViewController : UITableViewController
-(id)initWithGame:(TablanetGame*)game delegate:(id<TablanetGameOverViewControllerDelegate>)delegate;
@end
