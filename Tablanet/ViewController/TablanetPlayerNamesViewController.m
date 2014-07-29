//
//  TablanetPlayerNamesViewController.m
//  Tablanet
//
//  Created by Valdrin on 11/11/13.
//  Copyright (c) 2013 Valdrin. All rights reserved.
//

#import "TablanetPlayerNamesViewController.h"

@interface TablanetPlayerNamesViewController (){
    NSMutableArray *_players;
    id<TablanetPlayerNamesViewControllerDelegate>_delegate;
}

@end

@implementation TablanetPlayerNamesViewController

- (id)initWithPlayers:(NSMutableArray *)players delegate:(id<TablanetPlayerNamesViewControllerDelegate>)delegate
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
        _players = [players retain];
        _delegate = delegate;
        self.navigationItem.title = @"Player names";
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(playersReady)] autorelease];
    }
    return self;
}
-(void)playersReady{
    [_delegate playersReady:_players];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _players.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil==cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //Apple you are shit look at what you make me do.
        int topMargin = [[[UIDevice currentDevice] systemVersion] floatValue] < 7 ? 10 : 0;
        UITextField *tf = [[[UITextField alloc] initWithFrame:CGRectMake(10, topMargin, self.view.bounds.size.width - 20, 44)] autorelease];
        tf.tag = 1000;
        tf.delegate = self;
        [cell.contentView addSubview:tf];
    }
    // Configure the cell...
    UITextField *tf = (UITextField*)[cell.contentView viewWithTag:1000];
    int i = indexPath.row;
    TablanetPlayer *player = [_players objectAtIndex:i];
    tf.text = [NSString stringWithFormat:@"%@", player.name];
    return cell;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    NSString *txt = textField.text;
    NSArray *cells = [self.tableView visibleCells];
    for (int i=0; i<cells.count; i++) {
        UITableViewCell *cell = [cells objectAtIndex:i];
        if ([[cell.contentView viewWithTag:1000] isEqual:textField]) {
            [[_players objectAtIndex:i] setName:txt];
            [[_players objectAtIndex:i] setUid:txt];
            break;
        }
    }
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
    [_players release];
    _delegate = nil;
    [super dealloc];
}

@end
