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
#import "ChatViewController.h"

@interface ChumrollViewController ()

@end

@implementation ChumrollViewController
@synthesize chumTable, chums, chumMoods;

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if( item.tag == 0 )
        [self performSegueWithIdentifier:@"ShowMemos" sender:self];
    else if( item.tag == 1 )
        [self flipToPesterlist];
    else if( item.tag == 2 )
        [self performSegueWithIdentifier: @"ShowPesterUser" sender: self];
    
    [tabBar setSelectedItem:nil];
}

- (void)setHandle:(NSString *)handle
{
    chumhandle = handle;
    self.navigationItem.title = chumhandle;
}

- (Boolean) addChum:(NSString *)theChum
{
    PesterphoneAppDelegate *appDelegate = (PesterphoneAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    for( NSString *chum in chums )
    {
        if( [[chum lowercaseString] isEqualToString:[theChum lowercaseString]] )
        {
            return false;
        }
    }
    [chums addObject:theChum];
    [chumMoods setValue:[NSNumber numberWithInt:0] forKey:theChum];
    [appDelegate.connection sendMsg:[NSString stringWithFormat:@"GETMOOD %@", theChum] to:@"#pesterchum"];
    
    NSLog(@"\n\n           Adding chum %@....             \n\n", theChum );
    [prefs setObject:chums forKey:@"chumlistArray"];
    [prefs synchronize];
    return true;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"pushChatView"])
	{
		ChatViewController *newController = segue.destinationViewController;
        newController.chat = newChat;
	}
}

- (void) flipToPesterlist
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    PesterlistViewController *pesterlistController = (PesterlistViewController*)[sb instantiateViewControllerWithIdentifier:@"PesterlistView"];
    [pesterlistController setHandle:chumhandle];
    [UIView transitionWithView:self.navigationController.view duration:0.6 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{[self.navigationController setViewControllers:[NSArray arrayWithObject:pesterlistController] animated:NO];} completion:NULL];
}

- (void) startChat
{
    [[self modalViewController] dismissModalViewControllerAnimated:YES];
    [self performSegueWithIdentifier: @"pushChatView" sender: self];
}

- (void) startChatPush
{
    [[self navigationController] popToRootViewControllerAnimated:NO];
    [self performSegueWithIdentifier: @"pushChatView" sender: self];
}

- (void)reloadTable
{
    [chumTable reloadData];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.chums count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell.
    NSString *chumName = [self.chums objectAtIndex: [indexPath row]];
    cell.textLabel.text = chumName;
    if( [chumMoods valueForKey:chumName] == nil || [[chumMoods valueForKey:chumName] integerValue] == 0 )
        cell.textLabel.textColor = [UIColor darkGrayColor];
    else
        cell.textLabel.textColor = [UIColor whiteColor];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if( [tableView cellForRowAtIndexPath:indexPath].textLabel.textColor == [UIColor whiteColor] )
    {
        PesterphoneAppDelegate *appDelegate = (PesterphoneAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        //
        // Open new chat here...
        //
        NSString *chum = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
        
        if( [appDelegate.chatList valueForKey:chum] )
            newChat = [appDelegate.chatList valueForKey:chum];
        else
        {
            newChat = [[Chat alloc] initWithName:chum];
            [newChat addChum:chum withMood:0];
        }
        
        appDelegate.activeChat = newChat;
        [appDelegate.chatList setValue:newChat forKey:chum];
        
        [self performSegueWithIdentifier: @"pushChatView" sender: self];
    }
}


- (void) navBarTap
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"You tapped the bar!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    PesterphoneAppDelegate *appDelegate = (PesterphoneAppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.chumroll = self;
    
    self.navigationItem.title = chumhandle;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navBarTap)];
    tap.numberOfTapsRequired = 1;
    
    [[self.navigationController.navigationBar.subviews objectAtIndex:1] setUserInteractionEnabled:YES];
    [[self.navigationController.navigationBar.subviews objectAtIndex:1] setGestureRecognizers:[NSArray arrayWithObject:tap]];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    self.chums = [[prefs arrayForKey:@"chumlistArray"] mutableCopy];
    chumMoods = [NSMutableDictionary dictionary];
    
    if( !self.chums )
    {
        NSLog(@"\n\n           No chums! Initializing...             \n\n");
        self.chums = [[NSMutableArray alloc] initWithObjects:@"volatileSchematic", nil];
        [prefs setObject:self.chums forKey:@"chumlistArray"];
        [prefs synchronize];
    }
    
    for( int i = 0; i < [chums count]; i++ )
    {
        [chumMoods setValue:[NSNumber numberWithInt:0] forKey:[chums objectAtIndex:i]];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self reloadTable];
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
