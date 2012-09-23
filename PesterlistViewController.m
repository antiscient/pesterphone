//
//  PesterlistViewController.m
//  Pesterchum
//
//  Created by Hanzilla on 9/22/12.
//  Copyright (c) 2012 Systech Studio. All rights reserved.
//

#import "PesterlistViewController.h"

@interface PesterlistViewController ()

@end

@implementation PesterlistViewController

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

@end
