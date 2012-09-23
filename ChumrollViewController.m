//
//  PesterchumViewController.m
//  Pesterchum
//
//  Created by Hanzilla on 9/22/12.
//  Copyright (c) 2012 Systech Studio. All rights reserved.
//

#import "ChumrollViewController.h"

@interface ChumrollViewController ()

@end

@implementation ChumrollViewController

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
        [self performSegueWithIdentifier: @"flipToPesterlist" sender: self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setChumTable:nil];
    [super viewDidUnload];
}
@end
