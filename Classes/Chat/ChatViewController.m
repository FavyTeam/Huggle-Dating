//
//  ChatViewController.m
//  Tinder
//
//  Created by Rahul Sharma on 29/11/13.
//  Copyright (c) 2013 3Embed. All rights reserved.
//

#import "ChatViewController.h"
#import "ProfileMatchedCell.h"
#import "MatchedUserList.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageDownloader.h"
#import "JSDemoViewController.h"
#import "ProgressIndicator.h"
#import "MessageTable.h"

#import "UIImageView+Download.h"

@interface ChatViewController ()

@end

@implementation ChatViewController

@synthesize tblView;

#pragma mark -
#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark -
#pragma mark - ViewLife Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [Helper getColorFromHexString:@"#333333" :1.0];
    self.title = @"Matched List";
    
    arrAllMatch=[[NSMutableArray alloc]init];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[ProgressIndicator sharedInstance] showPIOnView:self.view withMessage:@"loading"];
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_GETPROFILEMATCHES withParamData:dictParam withBlock:^(id response, NSError *error) {
        if (response) {
            if ([[response objectForKey:@"errFlag"] intValue]==0) {
                [arrAllMatch removeAllObjects];
                NSArray *arr=[response objectForKey:@"likes"];
                for (NSDictionary *dict in arr) {
                    User *user=[[User alloc]init];
                    user.first_name=[dict objectForKey:@"fName"];
                    user.fbid=[dict objectForKey:@"fbId"];
                    user.profile_pic=[dict objectForKey:@"pPic"];
                    user.flag=[[dict objectForKey:@"flag"] intValue];
                    [arrAllMatch addObject:user];
                }
                [[ProgressIndicator sharedInstance] hideProgressIndicator];
                [self.tblView reloadData];
            }
            else{
                [[ProgressIndicator sharedInstance] hideProgressIndicator];
            }
        }else{
            [[ProgressIndicator sharedInstance] hideProgressIndicator];
        }
    }];
}

#pragma mark -
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrAllMatch count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"CellIdentifier";
	ProfileMatchedCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell) {
        cell = [[ProfileMatchedCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		[cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    User *user=[arrAllMatch objectAtIndex:indexPath.row];
    
    cell.labelFirstName.text = user.first_name;
    
    NSPredicate *predict=[NSPredicate predicateWithFormat:@"senderId = %@ AND receiverId = %@",user.fbid,user.fbid];
    
    NSArray *storedMessages =[[DBHelper sharedObject]getObjectsforEntity:ENTITY_MESSAGETABLE ShortBy:nil isAscending:YES predicate:predict];
    if (storedMessages.count > 0)
    {
        MessageTable *msg = [storedMessages lastObject];
        cell.labelLastMessage.text = msg.message;
    }
    [cell.thumbNailImage downloadFromURL:user.profile_pic withPlaceholder:[UIImage imageNamed:@"placeholder.png"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    
    User *user=[arrAllMatch objectAtIndex:indexPath.row];
    
    JSDemoViewController *vc = [[JSDemoViewController alloc] init];
    vc.userFriend=user;
    vc.friendFbId = user.fbid;
    vc.status = @"";
    vc.ChatPersonNane =user.first_name;
    vc.matchedUserProfileImagePath = user.profile_pic;
    [dict setValue:user.fbid forKey:@"fbId"];
    [dict setValue:@"" forKey:@"status"];
    [dict setValue:user.first_name forKey:@"fName"];
    [dict setValue:user.profile_pic forKey:@"proficePic"];
    vc.dictUser = dict;
    UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.revealSideViewController popViewControllerWithNewCenterController:n
                                                                   animated:YES];
}

#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
