//
//  OAuthTwitterDemoViewController.h
//  OAuthTwitterDemo
//
//  Created by Ben Gottlieb on 7/24/09.
//  Copyright Stand Alone, Inc. 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TwitterUtility.h"
#import "FHSTwitterEngine.h"

#define kOAuthConsumerKey				@"SvQLp9MmQuSNowWQoiYng"		//REPLACE ME//
#define kOAuthConsumerSecret			@"eirqKfLbjdf7z3Z8Rsd34g9Z0WMWRLF6iYQ0UYI6QE"		//REPLACE ME//

typedef void (^CompletionBlock)(BOOL success, NSError *error);
typedef void(^CompletionBlockForData)(NSDictionary *data, NSError *error);

@interface TwitterUtility : NSObject <FHSTwitterEngineAccessTokenDelegate>//old<SA_OAuthTwitterControllerDelegate>
{
	//SA_OAuthTwitterEngine				*_engine;
    CompletionBlock complate;
}

-(id) init;
+ (TwitterUtility *)sharedObject;

-(BOOL)isLogin;
-(NSString *)getTwitterUserName;
- (void) LoginInTwitter:(UIViewController *)vcLogin withLoginBlock:(CompletionBlock)isLogin;
- (void)logoutOfTwitter;

-(void)tweetWithText:(NSString *)strTweet withCompletionBlock:(CompletionBlock)sendTweet;
-(void)sendDirectMsg:(NSString *)strMsg toUser:(NSString *)strUserName withCompletionBlock:(CompletionBlockForData)userData;

//-(void)sendMessage;

-(void)getUserInfo:(CompletionBlockForData)userData;

-(void)searchKeyword:(NSString *)keyword withCompletionBlock:(CompletionBlockForData)userData;

-(void)getFollowersWithCompletionBlock:(CompletionBlockForData)userData;

@end

