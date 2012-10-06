//
//  PesterlistViewController.m
//  Pesterchum
//
//  Created by Antiscient on 9/22/12.
//  Copyright (c) 2012 Systech Studio. All rights reserved.
//

#import "PesterlistViewController.h"
#import "PesterphoneAppDelegate.h"

@interface PesterlistViewController ()

@end

@implementation PesterlistViewController
@synthesize headerBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if( item.tag == 1 )
        [self performSegueWithIdentifier: @"flipToChumroll" sender: self];
}

- (void)setHandle:(NSString *)handle
{
    chumhandle = handle;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    PesterphoneAppDelegate *appDelegate = (PesterphoneAppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.pesterlist = self;
    
    [[headerBar topItem] setTitle:chumhandle];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setHeaderBar:nil];
    [super viewDidUnload];
}
@end
