//
//  ChatViewController.h
//  Tinder
//
//  Created by Rahul Sharma on 08/12/13.
//  Copyright (c) 2013 3Embed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebServiceHandler.h"
#import "DataBase.h"
#import"MatchedUserList.h"
#import "PPRevealSideViewController.h"
#import "JSDemoViewController.h"

@interface ChatViewController : UIViewController
{
    NSMutableArray *arrAllMatch;
}
@property (strong , nonatomic) IBOutlet UITableView *tblView;

@end

