//
//  TablanetAllPointsViewController.m
//  Tablanet
//
//  Created by Valdrin on 11/11/13.
//  Copyright (c) 2013 Valdrin. All rights reserved.
//

#import "TablanetAllPointsViewController.h"

@interface TablanetAllPointsViewController (){
    TablanetGame *_game;
}

@end

@implementation TablanetAllPointsViewController

- (id)initWithGame:(TablanetGame *)game
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
        _game = [game retain];
        self.navigationItem.title = @"All points";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _game.previousPoints.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    int width = self.view.bounds.size.width;
    int height = 44;
    UIView *sv = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)] autorelease];
    sv.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    int playersCount = _game.players.count;
    for (int j=0;j<playersCount; j++) {
        UILabel *cardValue = [[[UILabel alloc] init] autorelease];
        cardValue.backgroundColor = [UIColor clearColor];
        cardValue.textAlignment = NSTextAlignmentCenter;
        cardValue.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:20];
        cardValue.frame = CGRectMake(j*width/playersCount + 10, 0, width/playersCount - 20, height);
        cardValue.text = [[_game.players objectAtIndex:j] name];
        [sv addSubview:cardValue];
    }
    return sv;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 44;
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    int width = self.view.bounds.size.width;
    int height = 44;
    UIView *sv = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)] autorelease];
    sv.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    int playersCount = _game.players.count;
    
    for (int j=0;j<playersCount; j++) {
        UILabel *cardValue = [[[UILabel alloc] init] autorelease];
        cardValue.backgroundColor = [UIColor clearColor];
        cardValue.textAlignment = NSTextAlignmentRight;
        cardValue.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:20];
        cardValue.frame = CGRectMake(j*width/playersCount + 10, 0, width/playersCount - 20, height);
        cardValue.text = [NSString stringWithFormat:@"%d",[[_game.totalPoints objectAtIndex:j] intValue]];
        [sv addSubview:cardValue];
    }
    return sv;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    NSMutableArray *pts = [_game.previousPoints objectAtIndex:indexPath.row];
    if (nil==cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        int width = self.view.bounds.size.width;
        int height = 44;
        UIView *sv = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)] autorelease];
        sv.tag = 1000;
        sv.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        for (int j=0;j<pts.count; j++) {
            UILabel *cardValue = [[[UILabel alloc] init] autorelease];
            cardValue.backgroundColor = [UIColor clearColor];
            cardValue.textAlignment = NSTextAlignmentRight;
            cardValue.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:20];
            cardValue.frame = CGRectMake(j*width/pts.count + 10, 0, width/pts.count - 20, height);
            [sv addSubview:cardValue];
        }
        [cell.contentView addSubview:sv];
    }
    // Configure the cell...
    for (int j=0;j<pts.count; j++) {
        UILabel *cardValue = [[[cell.contentView viewWithTag:1000] subviews] objectAtIndex:j];
        cardValue.text = [NSString stringWithFormat:@"%d",[[pts objectAtIndex:j] intValue]];
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

-(void)dealloc{
    [_game release];
    [super dealloc];
}

@end
