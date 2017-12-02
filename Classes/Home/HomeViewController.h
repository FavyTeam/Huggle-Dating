//
//  HomeViewController.h
//  Tinder
//
//  Created by Rahul Sharma on 24/11/13.
//  Copyright (c) 2013 3Embed. All rights reserved.
//

#import "BaseVC.h"

#import "PPRevealSideViewController.h"
#import "TinderAppDelegate.h"
#import <FacebookSDK/FBSessionTokenCachingStrategy.h>
#import <FacebookSDK/FacebookSDK.h>
#import "TinderFBFQL.h"

@interface HomeViewController : BaseVC<PPRevealSideViewControllerDelegate,FBLoginViewDelegate, TinderFBFQLDelegate>
{
    IBOutlet  UIImageView *imgProfile;
    NSString * strProfileUrl;
    int flag;
    IBOutlet UIView *viewGetMatched;
    IBOutlet UIButton *btnInvite;
    IBOutlet UIView *viewItsMatched;
    IBOutlet UILabel *lblItsMatched;
    IBOutlet UILabel *lblItsMatchedSubText;
    IBOutlet UILabel *lblNoFriendAround;
}
@property(strong ,nonatomic) NSDictionary *dictLoginUsrdetail;
@property(strong ,nonatomic) NSMutableArray *arrFBImageUrl;
@property(strong ,nonatomic)  NSString * strProfileUrl;
@property(assign ,nonatomic)  int flag;

@property (strong, nonatomic) IBOutlet FBLoginView *loginView;

@property(nonatomic,strong)IBOutlet UIView *viewPercentMatch;
@property(nonatomic,strong)IBOutlet UILabel *lblPercentMatch;

-(IBAction)openMail :(id)sender;
-(IBAction)btnActionForItsMatchedView :(id)sender;

//surender
@property(nonatomic,assign) BOOL didUserLoggedIn;
@property(nonatomic,assign) BOOL _loadViewOnce;

@end
