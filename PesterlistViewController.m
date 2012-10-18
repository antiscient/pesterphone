//
//  PesterlistViewController.m
//  Pesterchum
//
//  Created by Antiscient on 9/22/12.
//  Copyright (c) 2012 Systech Studio. All rights reserved.
//

#import "PesterlistViewController.h"
#import "PesterphoneAppDelegate.h"
#import "ChatViewController.h"

@interface PesterlistViewController ()

@end

@implementation PesterlistViewController
@synthesize headerBar, pesterlistTable;

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if( item.tag == 0 )
        [self performSegueWithIdentifier: @"ShowMemos" sender: self];
    else if( item.tag == 1 )
        [self flipToChumroll];
    else if( item.tag == 2 )
        [self performSegueWithIdentifier: @"ShowPesterUser" sender: self];
    
    [tabBar setSelectedItem:nil];
}

- (void)setHandle:(NSString *)handle
{
    chumhandle = handle;
    self.navigationItem.title = chumhandle;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"pushChatView"])
    {
        ChatViewController *newController = segue.destinationViewController;
        newController.chat = newChat;
    }
}

- (void) flipToChumroll
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    ChumrollViewController *chumrollController = (ChumrollViewController*)[sb instantiateViewControllerWithIdentifier:@"ChumrollView"];
    [chumrollController setHandle:chumhandle];
    [UIView transitionWithView:self.navigationController.view duration:0.6 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{[self.navigationController setViewControllers:[NSArray arrayWithObject:chumrollController] animated:NO];} completion:NULL];
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
    [pesterlistTable reloadData];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    PesterphoneAppDelegate *appDelegate = (PesterphoneAppDelegate*)[[UIApplication sharedApplication] delegate];
    return [appDelegate.chatList count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PesterphoneAppDelegate *appDelegate = (PesterphoneAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell.
    cell.textLabel.text = ((Chat*)[appDelegate.chatList valueForKey:[[appDelegate.chatList allKeys] objectAtIndex:indexPath.row]]).name;
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
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
        [self reloadTable];
        return;
    }
    
    appDelegate.activeChat = newChat;
    [appDelegate.chatList setValue:newChat forKey:chum];
    
    [self performSegueWithIdentifier: @"pushChatView" sender: self];
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
    appDelegate.pesterlist = self;
    
    self.navigationItem.title = chumhandle;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navBarTap)];
    tap.numberOfTapsRequired = 1;
    
    [[self.navigationController.navigationBar.subviews objectAtIndex:1] setUserInteractionEnabled:YES];
    [[self.navigationController.navigationBar.subviews objectAtIndex:1] addGestureRecognizer:tap];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self reloadTable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setHeaderBar:nil];
    [self setPesterlistTable:nil];
    [super viewDidUnload];
}
@end
