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
    self.navigationItem.title = chumhandle;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"flipToChumroll"])
	{
		ChumrollViewController *newController = ((UINavigationController*)segue.destinationViewController).viewControllers[0];
        [newController setHandle:chumhandle];
	}
    if ([segue.identifier isEqualToString:@"pushChatView"])
    {
        ChatViewController *newController = segue.destinationViewController;
        newController.chat = newChat;
    }
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
            newChat = [[Chat alloc] initWithName:chum];
        
        appDelegate.activeChat = newChat;
        [appDelegate.chatList setValue:newChat forKey:chum];
        
        [self performSegueWithIdentifier: @"pushChatView" sender: self];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    PesterphoneAppDelegate *appDelegate = (PesterphoneAppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.pesterlist = self;
    
    self.navigationItem.title = chumhandle;
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
