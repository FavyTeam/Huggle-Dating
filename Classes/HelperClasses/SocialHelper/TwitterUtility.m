//
//  OAuthTwitterDemoViewController.m
//  OAuthTwitterDemo
//
//  Created by Ben Gottlieb on 7/24/09.
//  Copyright Stand Alone, Inc. 2009. All rights reserved.
//

#import "TwitterUtility.h"

@implementation TwitterUtility

#pragma mark -
#pragma mark - Init And Shared Object

-(id) init
{
    if((self = [super init]))
    {
        [[FHSTwitterEngine sharedEngine]permanentlySetConsumerKey:kOAuthConsumerKey andSecret:kOAuthConsumerSecret];
        [[FHSTwitterEngine sharedEngine]setDelegate:self];
        
        [[FHSTwitterEngine sharedEngine]loadAccessToken];
    }
    return self;
}

+ (TwitterUtility *)sharedObject
{
    static TwitterUtility *objTwitterUtility = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objTwitterUtility = [[TwitterUtility alloc] init];
    });
    return objTwitterUtility;
}

#pragma mark -
#pragma mark - TwitterMethods

-(BOOL)isLogin
{
    return [[FHSTwitterEngine sharedEngine]isAuthorized];
}

-(NSString *)getTwitterUserName
{
    return [[FHSTwitterEngine sharedEngine]loggedInUsername];
}

- (void)storeAccessToken:(NSString *)accessToken {
    [[NSUserDefaults standardUserDefaults]setObject:accessToken forKey:@"SavedAccessHTTPBody"];
}

- (NSString *)loadAccessToken {
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"SavedAccessHTTPBody"];
}

- (void) LoginInTwitter:(UIViewController *)vcLogin withLoginBlock:(CompletionBlock)isLogin
{
    complate=[isLogin copy];
    [[FHSTwitterEngine sharedEngine]showOAuthLoginControllerFromViewController:vcLogin withCompletion:^(BOOL success) {
        NSLog(success?@"L0L success":@"O noes!!! Loggen faylur!!!");
        if (success) {
            if (isLogin) {
                isLogin(success,nil);
            }
        }else{
            complate(success,[NSError errorWithDomain:@"TwitterLogin" code:69001 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Authentication Failed!",@"Info", nil]]);
        }
        
    }];
}

- (void)logoutOfTwitter
{
    [[FHSTwitterEngine sharedEngine]clearAccessToken];
}

-(void)tweetWithText:(NSString *)strTweet withCompletionBlock:(CompletionBlock)sendTweet
{
    complate=[sendTweet copy];
    dispatch_async(GCDBackgroundThread, ^{
        @autoreleasepool {
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            NSError *returnCode = [[FHSTwitterEngine sharedEngine]postTweet:strTweet];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            NSString *title = nil;
            NSString *message = nil;
            
            if (returnCode) {
                title = [NSString stringWithFormat:@"Error %d",returnCode.code];
                message = returnCode.domain;
            } else {
                title = @"Tweet Posted";
                message = strTweet;
            }
            
            dispatch_sync(GCDMainThread, ^{
                @autoreleasepool {
                    if (!returnCode) {
                        complate(TRUE,nil);
                    }else{
                        complate(FALSE,returnCode);
                    }
                }
            });
        }
    });
}

-(void)sendDirectMsg:(NSString *)strMsg toUser:(NSString *)strUserName withCompletionBlock:(CompletionBlockForData)userData
{
    id responce=[[FHSTwitterEngine sharedEngine] sendDirectMessage:strMsg toUser:strUserName isID:NO];
    if ([responce isKindOfClass:[NSError class]]) {
        userData(nil,responce);
    }
    else if([responce isKindOfClass:[NSDictionary class]]){
        userData(responce,nil);
    }
}

-(void)getUserInfo:(CompletionBlockForData)userData
{
    id responce=[[FHSTwitterEngine sharedEngine] getProfileForUsername:[self getTwitterUserName]];
    if ([responce isKindOfClass:[NSError class]]) {
        userData(nil,responce);
    }
    else if([responce isKindOfClass:[NSDictionary class]]){
        userData(responce,nil);
    }
}

-(void)searchKeyword:(NSString *)keyword withCompletionBlock:(CompletionBlockForData)userData
{
    id responce=[[FHSTwitterEngine sharedEngine]searchTweetsWithQuery:keyword count:20 resultType:FHSTwitterEngineResultTypeMixed unil:nil sinceID:nil maxID:nil];
    if ([responce isKindOfClass:[NSError class]]) {
        userData(nil,responce);
    }
    else if([responce isKindOfClass:[NSDictionary class]]){
        userData(responce,nil);
    }
}

-(void)getFollowersWithCompletionBlock:(CompletionBlockForData)userData
{
    id responce=[[FHSTwitterEngine sharedEngine]getFollowersLists];
    if ([responce isKindOfClass:[NSError class]]) {
        userData(nil,responce);
    }
    else if([responce isKindOfClass:[NSDictionary class]]){
        userData(responce,nil);
    }
}

@end
