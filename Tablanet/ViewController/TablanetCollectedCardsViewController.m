//
//  TablanetCollectedCardsViewController.m
//  Tablanet
//
//  Created by Valdrin on 25/05/13.
//  Copyright (c) 2013 Valdrin. All rights reserved.
//

#import "TablanetCollectedCardsViewController.h"
#import "TablanetCardView.h"
#import "TablanetGame.h"

@interface TablanetCollectedCardsViewController (){
    TablanetPlayer *currentPlayer;
    BOOL isShowingPoints;
    UIView *plusThree;
}

@end

@implementation TablanetCollectedCardsViewController

- (id)initWithPlayer:(TablanetPlayer *)player
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        isShowingPoints = NO;
        currentPlayer = [player retain];
        // Custom initialization
        self.navigationItem.title = [NSString stringWithFormat:@"%d %@",player.collectedCards.count, NSLocalizedString(@"cards", nil)];
        
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle: [NSString stringWithFormat:@"%d %@",player.points, player.points != 1 ? NSLocalizedString(@"points", nil) : NSLocalizedString(@"point", nil)] style:UIBarButtonItemStyleBordered target:self action:@selector(showPoints)] autorelease];
    }
    return self;
}

-(void)loadView{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 480, 320)];
    //scrollView.pagingEnabled = YES;
    scrollView.alwaysBounceHorizontal = YES;
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    CGFloat margin = 10;
    
    CGFloat y = (scrollView.bounds.size.height - kCardHeight) * .4;
    for (int i=0; i<currentPlayer.collectedCards.count; i++) {
        TablanetCard *card = [currentPlayer.collectedCards objectAtIndex:i];
        TablanetCardView *playerCard = [[[TablanetCardView alloc] init] autorelease];
        playerCard.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        playerCard.card = card;
        playerCard.frame = CGRectMake(margin + kCardWidth * i, y, kCardWidth, kCardHeight);
        playerCard.layer.transform = CATransform3DRotate(playerCard.identity, playerCard.rotation, 0, 0, 1);
        [scrollView addSubview:playerCard];
        if(card.tablanet){
            UILabel *tablanet = [[[UILabel alloc] init] autorelease];
            tablanet.backgroundColor = [UIColor clearColor];
            tablanet.textColor = [UIColor redColor];
            tablanet.textAlignment = NSTextAlignmentCenter;
            tablanet.text = @"Tablanet!";
            tablanet.font = [UIFont systemFontOfSize:14];
            tablanet.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            [tablanet sizeToFit];
            tablanet.frame = CGRectMake(0, -margin-tablanet.bounds.size.height, kCardWidth, tablanet.bounds.size.height);
            [playerCard addSubview:tablanet];
        }
        if(card.points>0){
            UILabel *points = [[[UILabel alloc] init] autorelease];
            points.backgroundColor = [UIColor clearColor];
            points.textColor = [UIColor darkGrayColor];
            points.textAlignment = NSTextAlignmentCenter;
            points.font = [UIFont italicSystemFontOfSize:12];
            points.text = [NSString stringWithFormat:@"+%d %@",card.points, card.points==1 ? NSLocalizedString(@"point", nil) : NSLocalizedString(@"points", nil)];
            points.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            [points sizeToFit];
            points.frame = CGRectMake(0, kCardHeight + margin, kCardWidth, points.bounds.size.height);
            [playerCard addSubview:points];
        }
    }
    if (currentPlayer.hasMoreCards) {
        plusThree = [[[UIView alloc] init] autorelease];
        plusThree.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        plusThree.frame = CGRectMake(margin + kCardWidth * currentPlayer.collectedCards.count, y, kCardWidth, kCardHeight);
        [scrollView addSubview:plusThree];
        
        UILabel *tablanet = [[[UILabel alloc] init] autorelease];
        tablanet.backgroundColor = [UIColor clearColor];
        tablanet.font = [UIFont boldSystemFontOfSize:16];
        tablanet.textColor = [UIColor darkGrayColor];
        tablanet.textAlignment = NSTextAlignmentCenter;
        tablanet.lineBreakMode = NSLineBreakByWordWrapping;
        tablanet.numberOfLines = 0;
        tablanet.text =  NSLocalizedString(@"More cards", nil);
        tablanet.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        tablanet.frame = CGRectMake(margin, margin, kCardWidth - margin*2, kCardHeight - margin*2);
        [plusThree addSubview:tablanet];
        
        UILabel *points = [[[UILabel alloc] init] autorelease];
        points.backgroundColor = [UIColor clearColor];
        points.textColor = [UIColor darkGrayColor];
        points.textAlignment = NSTextAlignmentCenter;
        points.font = [UIFont italicSystemFontOfSize:12];
        points.text = [NSString stringWithFormat:@"+3 %@", NSLocalizedString(@"points", nil)];
        points.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [points sizeToFit];
        points.frame = CGRectMake(0, kCardHeight + margin, kCardWidth, points.bounds.size.height);
        [plusThree addSubview:points];
    }
    
    scrollView.contentSize = CGSizeMake(margin*2 + kCardWidth * currentPlayer.collectedCards.count + 1 * currentPlayer.hasMoreCards, kCardHeight *2);
    self.view = scrollView;
    [scrollView release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if (self.presentingViewController) {
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(close)] autorelease];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)close{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)showPoints{
    isShowingPoints = !isShowingPoints;
    UIBarButtonItemStyle newStyle = isShowingPoints ? UIBarButtonItemStyleDone : UIBarButtonItemStyleBordered;
    self.navigationItem.rightBarButtonItem.style = newStyle;
    [UIView animateWithDuration:.3 animations:^{
        UIScrollView *scrollView = (UIScrollView *)self.view;
        CGFloat y = (scrollView.bounds.size.height - kCardHeight) * .4;
        CGFloat margin = 10;
        int iCardPointsCount=0;
        for (int i=0; i<currentPlayer.collectedCards.count; i++) {
            TablanetCardView *playerCard = (TablanetCardView*)[scrollView.subviews objectAtIndex:i];            
            int ii = isShowingPoints ? iCardPointsCount : i;
            playerCard.frame = CGRectMake(margin + kCardWidth * ii, y, kCardWidth, kCardHeight);
            playerCard.alpha = !isShowingPoints || playerCard.card.points>0;
            if(isShowingPoints && playerCard.card.points>0){
                iCardPointsCount++;
            }
        }
        if (currentPlayer.hasMoreCards) {
            int ii = isShowingPoints ? iCardPointsCount : currentPlayer.collectedCards.count;
            plusThree.frame = CGRectMake(margin + kCardWidth * ii, y, kCardWidth, kCardHeight);
            if(isShowingPoints){
                iCardPointsCount++;
            }
        }
        int ii = isShowingPoints ? iCardPointsCount : currentPlayer.collectedCards.count + 1 * currentPlayer.hasMoreCards;
        scrollView.contentSize = CGSizeMake(margin*2 + kCardWidth * ii, kCardHeight *2);
    }];
}

-(void)dealloc{
    [currentPlayer release];
    [super dealloc];
}
@end
