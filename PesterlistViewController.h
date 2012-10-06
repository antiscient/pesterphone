//
//  PesterlistViewController.h
//  Pesterchum
//
//  Created by Antiscient on 9/22/12.
//  Copyright (c) 2012 Systech Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PesterlistViewController : UIViewController <UITabBarDelegate>
{
    NSString *chumhandle;
}

@property (weak, nonatomic) IBOutlet UINavigationBar *headerBar;

-(void)setHandle:(NSString*)handle;

@end
