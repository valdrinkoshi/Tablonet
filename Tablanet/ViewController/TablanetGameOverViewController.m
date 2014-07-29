//
//  TablanetGameOverViewController.m
//  Tablanet
//
//  Created by Valdrin on 24/06/13.
//  Copyright (c) 2013 Valdrin. All rights reserved.
//

#import "TablanetGameOverViewController.h"
#import "TablanetCollectedCardsViewController.h"
#import "TablanetAllPointsViewController.h"

@interface TablanetGameOverViewController (){
    TablanetGame *_game;
    NSArray *_rank;
    id<TablanetGameOverViewControllerDelegate> _delegate;
}

@end

@implementation TablanetGameOverViewController

- (id)initWithGame:(TablanetGame *)game delegate:(id<TablanetGameOverViewControllerDelegate>)delegate
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
        _game = [game retain];
        _rank = [game.playersByPoints retain];
        _delegate = delegate;
        self.navigationItem.title = @"Game over";
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(showActions)] autorelease];
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"All points", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(allPoints)] autorelease];
    }
    return self;
}

-(void)allPoints {
    TablanetAllPointsViewController *allPts = [[[TablanetAllPointsViewController alloc] initWithGame:_game] autorelease];
    [self.navigationController pushViewController:allPts animated:YES];
}

-(void)showActions{
    [_delegate close];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    TablanetPlayer *first = [_rank objectAtIndex:0];
    return first.points>0 ? [NSString stringWithFormat:@"%@ %@!",first.name, NSLocalizedString(@"wins", nil)] : nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _rank.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil==cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    // Configure the cell...
    int i = indexPath.row;
    TablanetPlayer *player = [_rank objectAtIndex:i];
    cell.textLabel.text = [NSString stringWithFormat:@"%d) %@",i+1,player.name];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d %@ (%d %@)",player.collectedCards.count, NSLocalizedString(@"cards", nil) ,player.points, player.points!=1 ? NSLocalizedString(@"points", nil) : NSLocalizedString(@"point", nil)];
    cell.selectionStyle = player.collectedCards.count>0 ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone;
    cell.accessoryType = player.collectedCards.count>0 ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

//-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    int i = indexPath.row;
    TablanetPlayer *player = [_rank objectAtIndex:i];
    if (player.collectedCards.count>0) {
        TablanetCollectedCardsViewController *vc = [[TablanetCollectedCardsViewController alloc] initWithPlayer:player];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    }
}

-(void)dealloc{
    [_game release];
    [_rank release];
    _delegate = nil;
    [super dealloc];
}

@end
