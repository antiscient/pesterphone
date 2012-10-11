//
//  MemoViewController.h
//  Pesterchum
//
//  Created by Antiscient on 10/8/12.
//  Copyright (c) 2012 Systech Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MemoViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSString *selectedMemo;
}

- (IBAction)joinMemo:(id)sender;
- (IBAction)goBack:(id)sender;

@end
