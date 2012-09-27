//
//  PesterchumViewController.h
//  Pesterchum
//
//  Created by Hanzilla on 9/22/12.
//  Copyright (c) 2012 Systech Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChumrollViewController : UIViewController <UITabBarDelegate, UITableViewDelegate, UITableViewDataSource>
{
    NSString *chumhandle;
    NSMutableArray *chums;
}

@property (weak, nonatomic) IBOutlet UITableView *chumTable;
@property (weak, nonatomic) IBOutlet UINavigationBar *headerBar;
@property (strong, nonatomic) NSArray *chums;

-(void)setHandle:(NSString*)handle;

@end
