//
//  TinderAppDelegate.h
//  Tinder
//
//  Created by Rahul Sharma on 24/11/13.
//  Copyright (c) 2013 3Embed. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LoginViewController.h"
#import "MenuViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "PPRevealSideViewController.h"
#import <CoreData/CoreData.h>
#import "ChatViewController.h"



extern NSString *const FBSessionStateChangedNotification;
@class SplashVC;

@interface TinderAppDelegate : UIResponder <UIApplicationDelegate,PPRevealSideViewControllerDelegate>
{
@private
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
    UIAlertView *doneAlert;
}
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SplashVC *vcSplash;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) FBSession *loggedInSession;
@property (strong, nonatomic) PPRevealSideViewController *revealSideViewController;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;


- (void) closeSession;
-(void)addBackButton:(UINavigationItem*)naviItem;
-(void)addrightButton:(UINavigationItem*)naviItem;

+(TinderAppDelegate *)sharedAppDelegate;
-(void)showToastMessage:(NSString *)message;

@end
