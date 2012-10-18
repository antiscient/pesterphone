//
//  ChatMenuViewController.m
//  Pesterchum
//
//  Created by Antiscient on 10/14/12.
//  Copyright (c) 2012 Systech Studio. All rights reserved.
//

#import "ChatMenuViewController.h"
#import "ChatViewController.h"
#import "PesterphoneAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@implementation ChatMenuViewController
@synthesize chumTable, parent;

- (IBAction)goBack:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)pester:(id)sender
{
    if( [selectedChum length] < 1 )
    {
        return;
    }
    if( [selectedChum isEqualToString:parent.chat.name] )
    {
        [parent hideMenu:self];
        return;
    }
    
    PesterphoneAppDelegate *appDelegate = (PesterphoneAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    //
    // Open new chat here...
    //
    NSString *chum = selectedChum;
    Chat *newChat;
    
    for( NSString* key in [appDelegate.chatList allKeys] )
    {
        if( [[((Chat *)[appDelegate.chatList valueForKey:key]).name lowercaseString] isEqualToString:[chum lowercaseString]]  )
        {
            newChat = [appDelegate.chatList valueForKey:key];
            chum = ((Chat*)[appDelegate.chatList valueForKey:key]).name;
            break;
        }
    }
    
    if( !newChat )
        newChat = [[Chat alloc] initWithName:chum];
    
    appDelegate.activeChat = newChat;
    [appDelegate.chatList setValue:newChat forKey:chum];
    
    [[(id)[[parent navigationController] viewControllers] objectAtIndex:0] startChatPush];
}

- (IBAction)addChum:(id)sender
{
    if( [selectedChum length] < 1 )
    {
        return;
    }
    
    PesterphoneAppDelegate *appDelegate = (PesterphoneAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if( ![appDelegate.chumroll addChum:selectedChum] )
    {
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSMutableArray *chums = [[prefs arrayForKey:@"chumlistArray"] mutableCopy];
        NSString *chum = @"NOHANDLE";
        
        for( chum in chums )
        {
            if( [[chum lowercaseString] isEqualToString:[selectedChum lowercaseString]] )
            {
                break;
            }
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Already On Chumroll" message:[NSString stringWithFormat:@"%@ is already your chum.", chum] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Chum added!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [parent.chat.chatMoodList count];
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
    
    cell.textLabel.text = [[parent.chat.chatMoodList allKeys] objectAtIndex:[indexPath row]];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedChum = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
}

- (void)reloadTable
{
    [chumTable reloadData];
}

- (void)viewDidLoad
{
    selectedChum = @"";
    self.view.layer.masksToBounds = NO;
    self.view.layer.shadowOffset = CGSizeMake(0,3);
    self.view.layer.shadowRadius = 10;
    self.view.layer.shadowOpacity = 0.5;
}


- (void)viewDidUnload
{
    [self setChumTable:nil];
    [super viewDidUnload];
}
@end