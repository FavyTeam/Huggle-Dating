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

#import "JSMessagesViewController.h"
#import "WebServiceHandler.h"
#import <MessageUI/MessageUI.h>
#import "DataBase.h"
#import "MatchedUserList.h"
#import "ChatViewController.h"

@class User;
@interface JSDemoViewController : JSMessagesViewController <JSMessagesViewDataSource, JSMessagesViewDelegate,sendMessageDelegate,MFMailComposeViewControllerDelegate, PPRevealSideViewControllerDelegate,sendMessageDelegate,PPRevealSideViewControllerDelegate,UIActionSheetDelegate>
{
    NSString * strProfile;
    UIButton *buttonUserPic;
    UIButton *buttonUserTitle;
    UIButton *buttonBlockUser;
    
    UIButton *btnTime;
    
    BOOL isReloding;
    NSMutableArray *arrMessage;
    
}
@property (nonatomic,strong)User *userFriend;

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableArray *timestamps;
@property (strong, nonatomic) NSMutableArray *subtitles;
@property (strong, nonatomic) NSDictionary *avatars;
@property (strong, nonatomic) NSDictionary *mResponseDict;
@property (strong, nonatomic) NSString *currentMessage;
@property (strong , nonatomic) UIView *customSlidingView;

@property (strong , nonatomic) NSString *userFbId;
@property (strong , nonatomic) NSString *friendFbId;
@property (strong , nonatomic) NSString *status;
@property (strong , nonatomic) NSString *matchedUserProfileImagePath;
@property (strong , nonatomic) DataBase *dataBase;
@property (strong , nonatomic) NSString *ChatPersonNane;
@property (strong,nonatomic)   NSMutableDictionary * dictUser;

//@property(nonatomic,assign)id <LastMessageInfo>delegate1;

@end
