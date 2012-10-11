//
//  MemoViewController.m
//  Pesterchum
//
//  Created by Antiscient on 10/8/12.
//  Copyright (c) 2012 Systech Studio. All rights reserved.
//

#import "MemoViewController.h"
#import "PesterphoneAppDelegate.h"

@implementation MemoViewController

- (IBAction)goBack:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)joinMemo:(id)sender
{
    if( [selectedMemo length] < 1 )
        return;
    
    PesterphoneAppDelegate *appDelegate = (PesterphoneAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    //
    // Open new chat here...
    //
    
    Chat *newChat;
    
    if( [appDelegate.chatList valueForKey:selectedMemo] )
        newChat = [appDelegate.chatList valueForKey:selectedMemo];
    else
        newChat = [[Chat alloc] initWithName:selectedMemo];
    
    appDelegate.activeChat = newChat;
    [appDelegate.chatList setValue:newChat forKey:selectedMemo];
    
    [(id)[(UINavigationController*)[self presentingViewController] topViewController] startChat];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
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
    //cell.textLabel.text = [self.chums objectAtIndex: [indexPath row]];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedMemo = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
}

- (void)viewDidLoad
{
    selectedMemo = @"";
}


@end
