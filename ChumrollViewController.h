//
//  PesterchumViewController.h
//  Pesterchum
//
//  Created by Antiscient on 9/22/12.
//  Copyright (c) 2012 Systech Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chat.h"

@interface ChumrollViewController : UIViewController <UITabBarDelegate, UITableViewDelegate, UITableViewDataSource>
{
    NSString *chumhandle;
    NSMutableArray *chums;
    
    Chat *newChat;
}

@property (weak, nonatomic) IBOutlet UITableView *chumTable;
@property (strong, nonatomic) NSMutableArray *chums;
@property (strong, nonatomic) NSMutableDictionary *chumMoods;

-(void)setHandle:(NSString*)handle;
-(Boolean)addChum:(NSString*)theChum;
-(void)startChat;
-(void)reloadTable;

@end
