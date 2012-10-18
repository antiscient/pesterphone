//
//  ChatMenuViewController.h
//  Pesterchum
//
//  Created by Anticient on 10/14/12.
//  Copyright (c) 2012 Systech Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChatViewController;
@interface ChatMenuViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSString *selectedChum;
}

@property (weak, nonatomic) IBOutlet UITableView *chumTable;
@property (weak, nonatomic) ChatViewController *parent;

- (IBAction)pester:(id)sender;
- (IBAction)addChum:(id)sender;
- (void)reloadTable;

@end
