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
@synthesize memoTable;

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
    NSString *chatName = [@"#" stringByAppendingString:selectedMemo];
    
    Chat *newChat;
    
    if( [appDelegate.chatList valueForKey:chatName] )
        newChat = [appDelegate.chatList valueForKey:chatName];
    else
    {
        newChat = [[Chat alloc] initWithName:chatName];
        newChat.isMemo = true;
        [newChat addChum:appDelegate.connection.handle withMood:0];        //          Should be own current mood!
    }
    
    appDelegate.activeChat = newChat;
    [appDelegate.chatList setValue:newChat forKey:chatName];
    
    [(id)[(UINavigationController*)[self presentingViewController] topViewController] startChat];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    PesterphoneAppDelegate *appDelegate = (PesterphoneAppDelegate*)[[UIApplication sharedApplication] delegate];
    return [appDelegate.memoList count];
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
    PesterphoneAppDelegate *appDelegate = (PesterphoneAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    cell.textLabel.text = [appDelegate.memoList objectAtIndex: [indexPath row]];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedMemo = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
}

- (void)reloadTable
{
    [memoTable reloadData];
}

- (void)viewDidLoad
{
    selectedMemo = @"";
    PesterphoneAppDelegate *appDelegate = (PesterphoneAppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.memoView = self;
    [appDelegate.connection dataSending:@"LIST\n"];
}


- (void)viewDidUnload {
    [self setMemoTable:nil];
    [super viewDidUnload];
}
@end
