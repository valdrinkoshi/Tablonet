//
//  TablanetHelpViewController.m
//  Tablanet
//
//  Created by Valdrin on 12/11/13.
//  Copyright (c) 2013 Valdrin. All rights reserved.
//

#import "TablanetHelpViewController.h"

@interface TablanetHelpViewController ()

@end

@implementation TablanetHelpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close)] autorelease];
        self.navigationItem.title = @"Help";
    }
    return self;
}

-(void)loadView{
    UIWebView *wv = [[UIWebView alloc] init];
    wv.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.view = wv;
    [wv release];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    NSString *page = [[NSBundle mainBundle] pathForResource:language ofType:@"html"];
    if (!page){
        page = [[NSBundle mainBundle] pathForResource:@"en" ofType:@"html"];
    }
    NSString* htmlString = [NSString stringWithContentsOfFile:page encoding:NSUTF8StringEncoding error:nil];
    [(UIWebView*)self.view loadHTMLString:htmlString baseURL:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)close{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
