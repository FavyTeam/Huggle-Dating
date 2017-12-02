//
//  SplashVC.m
//  Tinder
//
//  Created by Elluminati - macbook on 12/04/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "SplashVC.h"
#import "TinderAppDelegate.h"

@interface SplashVC ()

@end

@implementation SplashVC

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

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.imgSplash.image= [UIImage imageNamed:@"Default.png"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(removeSplash) userInfo:nil repeats:NO];
}

#pragma mark -
#pragma mark - Methods

- (void)removeSplash
{
    
    if ([[FacebookUtility sharedObject]isLogin]) {
        // load view if usser is logged in already
        
        HomeViewController *home ;
        home._loadViewOnce = NO;
        if (IS_IPHONE_5) {
            home = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
        }
        else{
            home = [[HomeViewController alloc] initWithNibName:@"HomeViewController_ip4" bundle:nil];
        }
        home.didUserLoggedIn = YES;
        home._loadViewOnce = NO;
        //PromotedVC *vc=[[PromotedVC alloc]initWithNibName:@"PromotedVC" bundle:nil];
        //[self.navigationController pushViewController:home animated:YES];
        [TinderAppDelegate sharedAppDelegate].navigationController = [[UINavigationController alloc] initWithRootViewController:home];
    }
    else{
        LoginViewController *login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [TinderAppDelegate sharedAppDelegate].navigationController = [[UINavigationController alloc] initWithRootViewController:login];
    }
    [TinderAppDelegate sharedAppDelegate].revealSideViewController= [[PPRevealSideViewController alloc] initWithRootViewController:[TinderAppDelegate sharedAppDelegate].navigationController];
    [TinderAppDelegate sharedAppDelegate].revealSideViewController.delegate = self;
    [TinderAppDelegate sharedAppDelegate].window.rootViewController = [TinderAppDelegate sharedAppDelegate].revealSideViewController;
    
    [[TinderAppDelegate sharedAppDelegate].window makeKeyAndVisible];
}

#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
