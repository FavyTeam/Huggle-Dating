//
//  Created by Jesse Squires
//  http://www.hexedbits.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSMessagesViewController
//
//
//  The MIT License
//  Copyright (c) 2013 Jesse Squires
//  http://opensource.org/licenses/MIT
//



#import "JSDemoViewController.h"
#import "Helper.h"
#import "AFNetworking.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"
#import "WebServiceHandler.h"
#import "MessageTable.h"
#import "MatchedUserList.h"
#import "TinderAppDelegate.h"
#import "DataBase.h"
#import "UploadImages.h"
#import "ProfileViewController.h"
#import "TinderPreviewUserProfileViewController.h"
#import "AFNHelper.h"

#import "ActionSheetStringPicker.h"

#import "User.h"
#import "ProfileVC.h"

@implementation JSDemoViewController
{
    NSTimer *timer;
    BOOL isTime;
    int unitIndex;
    NSString *strTime;
    NSMutableArray *arrForSecond;
    
}
@synthesize userFriend;

@synthesize mResponseDict;
@synthesize currentMessage;
@synthesize customSlidingView;
@synthesize friendFbId;
@synthesize status;
@synthesize dataBase;
@synthesize ChatPersonNane;
@synthesize matchedUserProfileImagePath;
@synthesize dictUser;

#pragma mark -
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setMoreView];
    
    arrMessage=[[NSMutableArray alloc]init];
    
    self.delegate = self;
    self.dataSource = self;
    
    NSUserDefaults * ud =[NSUserDefaults standardUserDefaults];
    NSDictionary * dictP =[ud objectForKey:UD_FB_USER_DETAIL];
    self.userFbId= [dictP objectForKey:FACEBOOK_ID];
    
    NSArray * arrProfile = [self getProfileImages:self.userFbId];
    
    if(arrProfile.count>0)
    {
        if ([(UploadImages*)[arrProfile objectAtIndex:0] imageUrlLocal]==nil) {
            
        }
        else{
            strProfile = [(UploadImages*)[arrProfile objectAtIndex:0] imageUrlLocal];
        }
    }
    self.messageInputView.textView.placeHolder = @"New Message";
    [self setBackgroundColor:[UIColor whiteColor]];

    isTime=NO;
    arrForSecond = [[NSMutableArray alloc]initWithObjects:@"Never",@"5 Seconds",@"10 Seconds",@"15 Seconds",@"20 Seconds",@"25 Seconds",@"30 Seconds",@"35 Seconds",@"40 Seconds",@"45 Seconds",@"50 Seconds",@"55 Seconds",@"60 Seconds", nil];
    
    [self messageTableReload];
}

- (void) viewDidAppear:(BOOL)animated
{
    [[UIApplication sharedApplication]setStatusBarHidden:YES];
    [self.navigationItem setTitle:ChatPersonNane];
/*
    buttonUserPic = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonUserPic.frame= CGRectMake(110, 2, 43,43);
    UIImage *matchedPersonImageOnNavigationBar=[JSAvatarImageFactory avatarImageNamed:self.matchedUserProfileImagePath style:JSAvatarImageStyleFlat shape:JSAvatarImageShapeCircle];
    [buttonUserPic setBackgroundImage:matchedPersonImageOnNavigationBar forState:UIControlStateNormal];
    [buttonUserPic addTarget:self action:@selector(buttonUserProfileTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.view addSubview:buttonUserPic];
    
    buttonUserTitle = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonUserTitle.frame= CGRectMake(buttonUserPic.frame.origin.x+buttonUserPic.frame.size.width-16, 9, 100,30);
    [buttonUserTitle setTintColor:[UIColor whiteColor]];
    [buttonUserTitle setTitle:ChatPersonNane forState:UIControlStateNormal];
    [buttonUserTitle addTarget:self action:@selector(buttonUserProfileTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.view addSubview:buttonUserTitle];
    
    */
    
   [self performSelector:@selector(messageTableReload) withObject:nil afterDelay:10];
}

- (void) viewWillDisappear:(BOOL)animated
{
    buttonUserPic.hidden = YES;
    buttonUserTitle.hidden = YES;
    
    isReloding=NO;
    [super viewWillDisappear:animated];
}

-(void)messageTableReload
{
    if (!isReloding)
    {
        isReloding=YES;
        NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
        
        NSString *userFBID=[[[UserDefaultHelper sharedObject] facebookUserDetail] objectForKey:FACEBOOK_ID];
        
        NSNumber *numfriendFbId=[NSNumber numberWithLongLong:[self.friendFbId longLongValue]];
        NSNumber *numUserFbId=[NSNumber numberWithLongLong:[userFBID longLongValue]];
        
        NSNumber *mid=[[DBHelper sharedObject]getLastMsgID:numfriendFbId andRecever:numUserFbId];
        
        [dictParam setObject:[NSString stringWithFormat:@"%@",mid] forKey:PARAM_ENT_LAST_MESS_ID];
        [dictParam setObject:self.friendFbId forKey:PARAM_ENT_RECEVER_USER_FBID];
        [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
        
        AFNHelper *afn=[[AFNHelper alloc]init];
        [afn getDataFromPath:METHOD_GETCHATSYNC withParamData:dictParam withBlock:^(id response, NSError *error) {
            if (response) {
                NSMutableArray *arrChat=[[NSMutableArray alloc]initWithArray:[response objectForKey:@"chat"]];
               
                NSString *uniqueId =[NSString stringWithFormat:@"%@%@",self.userFbId,self.friendFbId];
                [[DBHelper sharedObject]insertMsgToDB:arrChat uniqueId:uniqueId];
                [self dataInserted];
                
            }
            isReloding=NO;
        }];
        
        [self performSelector:@selector(messageTableReload) withObject:nil afterDelay:10];
        
    }
}

- (void)dataInserted
{
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"senderId = %@ OR receiverId = %@",[NSNumber numberWithLongLong:self.friendFbId.longLongValue],[NSNumber numberWithLongLong:self.friendFbId.longLongValue]];
    NSArray *storedMessages=[[DBHelper sharedObject]getObjectsforEntity:ENTITY_MESSAGETABLE ShortBy:@"messageDate" isAscending:YES predicate:predicate];
    
    if (storedMessages.count > 0) {
        [arrMessage removeAllObjects];
        [arrMessage addObjectsFromArray:storedMessages];
    }
    else{
        [arrMessage removeAllObjects];
    }
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark - NavigationButton Methods

-(void)addrightButton:(UINavigationItem*)naviItem
{
    // UIImage *imgButton = [UIImage imageNamed:@"chat_icon_off_line.png"];
	UIButton *rightbarbutton = [UIButton buttonWithType:UIButtonTypeCustom];
	[rightbarbutton setFrame:CGRectMake(0, 0,60, 25)];
    [rightbarbutton setTitle:@"More" forState:UIControlStateNormal];
    rightbarbutton.tag=100;
    [rightbarbutton addTarget:self action:@selector(buttonSliderPressed:) forControlEvents:UIControlEventTouchUpInside];
    naviItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightbarbutton];
}

-(void)addBack:(UINavigationItem*)naviItem
{
    UIImage *imgButton = [UIImage imageNamed:@"chat_icon_off_line.png"];
	UIButton *rightbarbutton = [UIButton buttonWithType:UIButtonTypeCustom];
	[rightbarbutton setFrame:CGRectMake(0, 0, imgButton.size.width+20, imgButton.size.height)];
    [rightbarbutton setTitle:@"Back" forState:UIControlStateNormal];
    [rightbarbutton addTarget:self action:@selector(buttonBackPressed:) forControlEvents:UIControlEventTouchUpInside];
    naviItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightbarbutton];
}

- (void)buttonSliderPressed:(UIBarButtonItem *)sender
{
    if (sender.tag == 100) {  //sliding is not done
        sender.tag = 200;       //done button
        float y=0;
        if (IS_IOS7) {
            y=0;
        }
        CGRect rect = CGRectMake(0, 0, customSlidingView.frame.size.width, customSlidingView.frame.size.height);
        rect.origin.y = y;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [customSlidingView setFrame:rect];
        [UIView commitAnimations];
    }else{
        sender.tag = 100; //More button
        float y=-46;
        if (IS_IOS7) {
            y=-46;
        }
        CGRect rect = CGRectMake(0, 0, customSlidingView.frame.size.width, customSlidingView.frame.size.height);
        rect.origin.y = y;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [customSlidingView setFrame:rect];
        [UIView commitAnimations];
    }
}

- (void)buttonBackPressed:(UIBarButtonItem *)sender
{
    //done button
    self.navigationItem.rightBarButtonItem.title =@"Back";
    self.navigationItem.rightBarButtonItem.tintColor =[UIColor whiteColor];
    HomeViewController *c;
    if (IS_IPHONE_5) {
        c = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    }
    else{
        c = [[HomeViewController alloc] initWithNibName:@"HomeViewController_ip4" bundle:nil];
    }
    c.didUserLoggedIn = YES;
    UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:c];
    [self.revealSideViewController popViewControllerWithNewCenterController:n
                                                                   animated:YES];
    PP_RELEASE(c);
    PP_RELEASE(n);
}

#pragma mark -
#pragma mark - MoreView Methods

-(void)setMoreView
{
    /* add sliding view to self.view */
    float y=-46;
    if (IS_IOS7) {
        y=-46;
    }
    self.customSlidingView = [[UIView alloc]initWithFrame:CGRectMake(0, y, 320, 46)];
    self.customSlidingView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_tab.png"]];
    [self.view addSubview:self.customSlidingView];
    
    [self addrightButton:self.navigationItem];
    [self addBack:self.navigationItem];
    
    /* add button to customSlidingview */
    UIImage * imgShowProfile = [UIImage imageNamed:@"show_profile.png"];
    UIButton *buttonShowProfile = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonShowProfile.frame = CGRectMake(25, 5, imgShowProfile.size.width, imgShowProfile.size.height);
    [buttonShowProfile setBackgroundImage:imgShowProfile forState:UIControlStateNormal];
    [buttonShowProfile addTarget:self action:@selector(showProfile) forControlEvents:UIControlEventTouchUpInside];
    [Helper setButton:buttonShowProfile Text:nil WithFont:nil FSize:12.0 TitleColor:nil ShadowColor:nil];
    [self.customSlidingView addSubview:buttonShowProfile];
    
    
    UIImage * imgFlag = [UIImage imageNamed:@"flag_icon.png"];
    UIButton *buttonFlagReport = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonFlagReport.frame = CGRectMake(100, 5, imgFlag.size.width, imgFlag.size.height);
    [buttonFlagReport setBackgroundImage:imgFlag forState:UIControlStateNormal];
    [Helper setButton:buttonFlagReport Text:nil WithFont:nil FSize:12.0 TitleColor:nil ShadowColor:nil];
    [buttonFlagReport addTarget:self action:@selector(buttonReportTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.customSlidingView addSubview:buttonFlagReport];
    
    
    UIImage * imgblock = [UIImage imageNamed:@"block_icon.png"];
    UIImage * imgunblock = [UIImage imageNamed:@"unblock_icon.png"];
    buttonBlockUser = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonBlockUser.frame = CGRectMake(175, 5, imgblock.size.width, imgblock.size.height);
    [buttonBlockUser setImage:imgblock forState:UIControlStateNormal];
    [buttonBlockUser setImage:imgunblock forState:UIControlStateSelected];
    [buttonBlockUser addTarget:self action:@selector(buttonBlockTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.customSlidingView addSubview:buttonBlockUser];
    if (userFriend.flag==EntFlagBlock){
        buttonBlockUser.selected=YES;
    }else{
        buttonBlockUser.selected=NO;
    }
}

-(void)showProfile
{
    ProfileVC *vc=[[ProfileVC alloc]initWithNibName:@"ProfileVC" bundle:nil];
    User *user=[[User alloc]init];
    user.fbid=[dictUser objectForKey:@"fbId"];
    user.first_name=[dictUser objectForKey:@"fName"];
    user.profile_pic=[dictUser objectForKey:@"proficePic"];
    vc.user=user;
    [self.navigationController pushViewController:vc animated:NO];
    /*
    TinderPreviewUserProfileViewController *pc ;
    if (IS_IPHONE_5) {
        pc = [[TinderPreviewUserProfileViewController alloc] initWithNibName:@"TinderPreviewUserProfileViewController" bundle:nil];
    }
    else{
        pc = [[TinderPreviewUserProfileViewController alloc] initWithNibName:@"TinderPreviewUserProfileViewController_ip4" bundle:nil];
        
    }
    pc.userProfile = dictUser;
    pc.userFriend=userFriend;
    buttonUserTitle.hidden = YES;
    buttonUserPic.hidden = YES;
    [self.navigationController pushViewController:pc animated:NO];
     */
}

- (void) buttonReportTapped:(UIButton *)sender{
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:@"Flamer App!"];
    [controller setMessageBody:@"" isHTML:NO];
    NSMutableArray *emails = [[NSMutableArray alloc] initWithObjects:@"info@appdupe.com", nil];
    [controller setToRecipients:[NSArray arrayWithArray:(NSArray *)emails]];
    if (controller) [self presentViewController:controller animated:YES completion:nil];
}

- (void) buttonBlockTapped:(UIButton *)sender
{
    if (userFriend.flag==EntFlagBlock){
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Alert!" message:@"Are you sure you want to Unblock this user?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alertView.tag =100;
        [alertView show];
    }
    else if(userFriend.flag==EntFlagUnblock){
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Alert!" message:@"Are you sure you want to block this user?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alertView.tag =200;
        [alertView show];
    }
}

#pragma mark -
#pragma mark - Time selection

- (void)setTimeBtnPressed:(id)sender
{
    [ActionSheetStringPicker showPickerWithTitle:NSLocalizedString(@"Select Time", @"") rows:arrForSecond initialSelection:unitIndex target:self sucessAction:@selector(choiceWasSelectedd:element:) cancelAction:nil origin:sender];
}

- (void) choiceWasSelectedd:(NSNumber *)selectedIndex element:(id)element
{
    unitIndex=[selectedIndex intValue];
    strTime=[arrForSecond objectAtIndex:unitIndex];
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    if(unitIndex==0)
    {
        [pref setInteger:0 forKey:@"time"];
    }
    else
    {
        [pref setInteger:[[NSString stringWithFormat:@"%@",strTime] intValue] forKey:@"time"];
    }
    
    strTime=[NSString stringWithFormat:@"Time-%d",[[NSUserDefaults standardUserDefaults]integerForKey:@"time"]];
    
    if ([[NSUserDefaults standardUserDefaults]integerForKey:@"time"]==0) {
        strTime=@"Time-Never";
    }
    [Helper setButton:btnTime Text:strTime WithFont:nil FSize:12.0 TitleColor:[UIColor blueColor] ShadowColor:nil];
    
}

#pragma mark -
#pragma mark - NSURLConnection Methods and Delegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data
{
    [self.tableView reloadData];
    [self deleteAllDbObject];
    [self.tableView reloadData];
    [timer invalidate];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Error");
    [timer invalidate];
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"ERROR" message:nil delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [timer invalidate];
    NSLog(@"Connection Finished");
}

-(NSArray*)getProfileImages :(NSString*)FBId
{
    TinderAppDelegate *appDelegate =(TinderAppDelegate*) [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UploadImages" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSArray *result=nil;
    
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"(fbId== %@)",
                              FBId];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    result = [context executeFetchRequest:fetchRequest error:&error];
    return  result;
}



#pragma mark -
#pragma mark - UIButton Action

- (void) buttonUserProfileTapped :(UIButton *)sender
{
    [self showProfile];
    /*
    TinderPreviewUserProfileViewController *pc ;
    
    if (IS_IPHONE_5) {
        pc = [[TinderPreviewUserProfileViewController alloc] initWithNibName:@"TinderPreviewUserProfileViewController" bundle:nil];
    }
    else{
        pc = [[TinderPreviewUserProfileViewController alloc] initWithNibName:@"TinderPreviewUserProfileViewController_ip4" bundle:nil];
    }
    pc.userFriend=userFriend;
    pc.userProfile = dictUser;
    buttonUserTitle.hidden = YES;
    buttonUserPic.hidden = YES;
    [self.navigationController pushViewController:pc animated:NO];
     */
}

-(void)deleteAllDbObject
{
    TinderAppDelegate *appDelegate =(TinderAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MessageTable" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray*fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    NSMutableArray *fetchedCategorList=[[NSMutableArray alloc]initWithArray:fetchedObjects];
    
    for (NSManagedObject *managedObject in fetchedCategorList)
    {
    	[context deleteObject:managedObject];
    }
}

#pragma mark -
#pragma mark - Messages view delegate: OPTIONAL

-(void) moveSlidingViewToDefaultFrame{
    UIBarButtonItem * btn = self.navigationItem.rightBarButtonItem;
    if (btn.tag == 200) {
        [self buttonSliderPressed:btn];
    }
}

#pragma mark -
#pragma mark - Messages view delegate: REQUIRED

- (void)didSendText:(NSString *)text
{
    if (text.length==0) {
        return;
    }
    self.currentMessage = text;
    
    if (userFriend.flag==EntFlagBlock) { // Blocked
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Do you want to unblock user?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alert.tag = 100;
        [alert show];
    }else{
        NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
        NSDictionary * dictUser1 =[ud objectForKey:UD_FB_USER_DETAIL];
        
        MessageTable *msgTbl=(MessageTable *)[[DBHelper sharedObject]createObjectForEntity:ENTITY_MESSAGETABLE];
        msgTbl.message=text;
        msgTbl.fId=self.userFbId;
        msgTbl.name=[dictUser1 objectForKey:FACEBOOK_FIRSTNAME];
        msgTbl.uniqueId=[NSString stringWithFormat:@"%@%@",self.userFbId,self.friendFbId];
        msgTbl.messageDate=[Helper getCurrentTime];
        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
        msgTbl.date=[NSNumber numberWithDouble:interval];
        
        msgTbl.senderId=[NSNumber numberWithLongLong:[self.userFbId longLongValue]];
        msgTbl.receiverId=[NSNumber numberWithLongLong:[self.friendFbId longLongValue]];
        [[DBHelper sharedObject]saveContext];
        
        [arrMessage insertObject:msgTbl atIndex:arrMessage.count];
        
        
        [self.tableView beginUpdates];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:arrMessage.count-1 inSection:0];
        NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        
        
        NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
        [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
        [dictParam setObject:text forKey:PARAM_ENT_MESSAGE];
        [dictParam setObject:self.friendFbId forKey:PARAM_ENT_USER_RECEVER_FBID];
        
        
        AFNHelper *afn=[[AFNHelper alloc]init];
        [afn getDataFromPath:METHOD_SENDMESSAGE withParamData:dictParam withBlock:^(id response, NSError *error) {
            if (response) {
                
            }
        }];
        [self finishSend];
        [self scrollToBottomAnimated:YES];
    }
}

//For Hide Status bar
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

#pragma mark -
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrMessage.count;
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageTable *msgTbl=[arrMessage objectAtIndex:indexPath.row];
    NSString *senderId=msgTbl.fId;
    
    if ([senderId isEqualToString:self.userFbId]) {
        return  JSBubbleMessageTypeOutgoing;
    }else{
        return JSBubbleMessageTypeIncoming;
    }
}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type
                       forRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageTable *msgTbl=[arrMessage objectAtIndex:indexPath.row];
    NSString *senderId=msgTbl.fId;
    
    if ([senderId isEqualToString:self.userFbId]) {
        
        return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                          color:[UIColor js_iOS7lightGrayColor]];
    }
    else{
        return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                          color:[UIColor js_iOS7blueColor]];
    }
}

- (JSMessagesViewTimestampPolicy)timestampPolicy
{
    return JSMessagesViewTimestampPolicyEveryThree;
}

- (JSMessagesViewAvatarPolicy)avatarPolicy
{
    return JSMessagesViewAvatarPolicyAll;
}

- (JSMessagesViewSubtitlePolicy)subtitlePolicy
{
    return JSMessagesViewSubtitlePolicyAll;
}

- (JSMessageInputViewStyle)inputViewStyle
{
    return JSMessageInputViewStyleFlat;
}

#pragma mark - Messages view delegate: OPTIONAL

//
//  *** Implement to customize cell further
//
- (void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    //  NSLog(@"configureCell");
    if([cell messageType] == JSBubbleMessageTypeOutgoing) {
        [cell.bubbleView setTextColor:[UIColor whiteColor]];
    }
    else{
        [cell.bubbleView setTextColor:[UIColor blackColor]];
    }
    if(cell.timestampLabel) {
        cell.timestampLabel.textColor = [UIColor lightGrayColor];
        cell.timestampLabel.shadowOffset = CGSizeZero;
    }
    
    if(cell.subtitleLabel) {
        cell.subtitleLabel.textColor = [UIColor lightGrayColor];
    }
}

- (BOOL)shouldPreventScrollToBottomWhileUserScrolling
{
    return YES;
}

#pragma mark - Messages view data source: REQUIRED

- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageTable *msgTbl=[arrMessage objectAtIndex:indexPath.row];
    return msgTbl.message;
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [NSDate date];
}

- (UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageTable *msgTbl=[arrMessage objectAtIndex:indexPath.row];
    NSString *senderId=msgTbl.fId;
    
    //NSString  *senderId = mResponseArray[indexPath.row][@"sfId"];
    UIImage *img = Nil;
    //  UIImage *imgP = [UIImage imageWithContentsOfFile:strProfile];
    if ([senderId isEqualToString:self.userFbId]) {
        
        img =  [JSAvatarImageFactory avatarImageNamed:strProfile style:JSAvatarImageStyleFlat shape:JSAvatarImageShapeCircle];
        // img = imgP;
    }else{
        img =  [JSAvatarImageFactory avatarImageNamed:matchedUserProfileImagePath style:JSAvatarImageStyleFlat shape:JSAvatarImageShapeCircle];
    }
    return [[UIImageView alloc] initWithImage:img];
    
}

- (NSString *)subtitleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return Nil;
}

#pragma mark -
#pragma mark - Webservice response Delegate

- (void)getServiceResponseDelegate:(NSDictionary *)responseDict serviceType:(int)type error:(NSError *)error
{
    ProgressIndicator *pi =[ProgressIndicator sharedInstance];
    [pi hideProgressIndicator];
    
    if (error == nil) {
        if ([[responseDict objectForKey:@"errFlag"]intValue] == 0) {
            //[self deleteAllDbObject];
            NSLog(@"success");
            if (type == 4 || type == 5) {  //blockUser or UnblockUser Response
                /* update MatchedUserList Table in database  */
                
                TinderAppDelegate *appDelegate = (TinderAppDelegate *)[[UIApplication sharedApplication] delegate];
                NSManagedObjectContext *context = [appDelegate managedObjectContext];
                
                NSPredicate *predicate=[NSPredicate predicateWithFormat:@"fId == %@",self.friendFbId];
                NSArray *blockedUserProfile=[[DBHelper sharedObject]getObjectsforEntity:ENTITY_MATCHEDUSERLIST ShortBy:nil isAscending:YES predicate:predicate];
                
                if (blockedUserProfile.count > 0) {
                    MatchedUserList *matchedUser = [blockedUserProfile objectAtIndex:0];
                    if (type == 4) {
                        matchedUser.status = @"4"; //blocking user
                        self.status = @"4";
                    }else{
                        matchedUser.status = @"3"; // unblocking user
                        self.status = @"3";
                    }
                    NSError *error;
                    if ( [context save:&error]) {
                        
                    }
                }
            }
        }
    }else{
        NSLog(@"error");
    }
}

#pragma mark -
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    WebServiceHandler *webserviceHandler = [[WebServiceHandler alloc]init];
    webserviceHandler.delegate = self;
    NSUserDefaults *userDeafults = [NSUserDefaults standardUserDefaults];
    if(buttonIndex == 1){
        if (alertView.tag == 100) {
            // unblock user
            buttonBlockUser.selected=NO;
            userFriend.flag=EntFlagUnblock;
            
            NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
            
            [dictParam setObject:[NSString stringWithFormat:@"%d",EntFlagUnblock] forKey:PARAM_ENT_FLAG];
            [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
            [dictParam setObject:userFriend.fbid forKey:PARAM_ENT_USER_BLOCK_FBID];
            
            AFNHelper *afn=[[AFNHelper alloc]init];
            [afn getDataFromPath:METHOD_BLOCKUSER withParamData:dictParam withBlock:^(id response, NSError *error) {
                if (response) {
                    if ([[response objectForKey:@"errFlag"] intValue]==0) {
                        [[TinderAppDelegate sharedAppDelegate]showToastMessage:[response objectForKey:@"errMsg"]];
                    }
                }
            }];
            
        }
        else
        {/*block user service call */
            buttonBlockUser.selected=YES;
            userFriend.flag=EntFlagBlock;
            UIBarButtonItem * btn = self.navigationItem.rightBarButtonItem;
            if (btn.tag == 200) {
                
                [self buttonSliderPressed:btn];
            }
            NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
            
            [dictParam setObject:[NSString stringWithFormat:@"%d",EntFlagBlock] forKey:PARAM_ENT_FLAG];
            [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
            [dictParam setObject:userFriend.fbid forKey:PARAM_ENT_USER_BLOCK_FBID];
            
            
            AFNHelper *afn=[[AFNHelper alloc]init];
            [afn getDataFromPath:METHOD_BLOCKUSER withParamData:dictParam withBlock:^(id response, NSError *error) {
                if (response) {
                    if ([[response objectForKey:@"errFlag"] intValue]==0) {
                        [[TinderAppDelegate sharedAppDelegate]showToastMessage:[response objectForKey:@"errMsg"]];
                    }
                }
            }];
            
        }
        [userDeafults synchronize];
    }
}

#pragma mark-
#pragma mark- MailDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        NSLog(@"It's away!");
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -
#pragma mark - Utility Methods

- (NSDate *) stringFromDate :(NSString *)strDate{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:strDate];
    return date;
}

- (NSString *) convertGmtToLocal:(NSString *)stringTime
{
    NSString *dateString = @"2013-12-04 11:10:27 GMT";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"EN"]];
    NSDate *date = [dateFormatter dateFromString:dateString];
    
    [dateFormatter setLocale:[NSLocale systemLocale]];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *localDateString = [dateFormatter stringFromDate:date];
    NSDate *lacalDate = [dateFormatter dateFromString:localDateString];
    NSDateFormatter *dateParser = [[NSDateFormatter alloc] init];
    [dateParser setDateFormat:@"dd-MMM-yyy"];
    NSString *chatLocalDateString = [dateParser stringFromDate:lacalDate];
    NSLog(@"Chat date :%@",chatLocalDateString);
    return chatLocalDateString;
}

@end
