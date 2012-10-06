//
//  ChumrollViewController.m
//  Pesterchum
//
//  Created by Antiscient on 9/22/12.
//  Copyright (c) 2012 Systech Studio. All rights reserved.
//

#import "ChumrollViewController.h"
#import "PesterlistViewController.h"
#import "PesterphoneAppDelegate.h"

@interface ChumrollViewController ()

@end

@implementation ChumrollViewController
@synthesize chumTable, headerBar, chums;

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

- (void)setHandle:(NSString *)handle
{
    chumhandle = handle;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"flipToPesterlist"])
	{
		PesterlistViewController *newController = segue.destinationViewController;
        [newController setHandle:chumhandle];
	}
}



// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.chums count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell.
    cell.textLabel.text = [self.chums objectAtIndex: [indexPath row]];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( [tableView cellForRowAtIndexPath:indexPath].textLabel.textColor == [UIColor whiteColor] )
    {
        PesterphoneAppDelegate *appDelegate = (PesterphoneAppDelegate*)[[UIApplication sharedApplication] delegate];
        appDelegate.activeChat = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
        
        //
        // Open new chat here...
        //
    }
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    PesterphoneAppDelegate *appDelegate = (PesterphoneAppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.chumroll = self;
    
    [[headerBar topItem] setTitle:chumhandle];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    self.chums = [prefs arrayForKey:@"chumlistArray"];
    
    if( !self.chums )
    {
        NSLog(@"\n\n           No chums! Initializing...             \n\n");
        self.chums = [[NSMutableArray alloc] initWithObjects:@"volatileSchematic", nil];
        [prefs setObject:self.chums forKey:@"chumlistArray"];
        [prefs synchronize];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setChumTable:nil];
    [self setHeaderBar:nil];
    [super viewDidUnload];
}
@end
