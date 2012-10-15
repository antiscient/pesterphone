//
//  PesterlistViewController.h
//  Pesterchum
//
//  Created by Antiscient on 9/22/12.
//  Copyright (c) 2012 Systech Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chat.h"

@interface PesterlistViewController : UIViewController <UITabBarDelegate, UITableViewDelegate, UITableViewDataSource>
{
    NSString *chumhandle;
    
    Chat *newChat;
}

@property (weak, nonatomic) IBOutlet UINavigationBar *headerBar;
@property (weak, nonatomic) IBOutlet UITableView *pesterlistTable;

-(void)setHandle:(NSString*)handle;
-(void)startChat;
-(void)startChatPush;
-(void)reloadTable;

@end
