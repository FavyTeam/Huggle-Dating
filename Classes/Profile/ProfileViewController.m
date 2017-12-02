//
//  ProfileViewController.m
//  Tinder
//
//  Created by Rahul Sharma on 03/12/13.
//  Copyright (c) 2013 3Embed. All rights reserved.
//

#import "ProfileViewController.h"
#import "MyTableViewCell.h"
#import "UploadImages.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageDownloader.h"
#import "RoundedImageView.h"
#import "Login.h"
#import "JSDemoViewController.h"
#import "TinderGenericUtility.h"

#import "DataBase.h"

#import "AFNHelper.h"


#import "CellQuestion.h"

#import "DetailQue.h"
#import "Question.h"
#import "AboutQue.h"

#import "EditProfileVC.h"
#import "UIImageView+Download.h"

@interface ProfileViewController ()
{
    NSArray * profileImage;
}

@end

@implementation ProfileViewController

@synthesize lblNameAndAge;

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
    [self.navigationItem setTitle:@"Profile"];
    
    self.navigationController.navigationBarHidden = NO;
    
    [APPDELEGATE addBackButton:self.navigationItem];
    [self addrightButton:self.navigationItem];
    
    [Helper setToLabel:lblNameAndAge Text:nil WithFont:HELVETICALTSTD_ROMAN FSize:22 Color:[Helper getColorFromHexString:@"#7c7c7c" :1.0]];
   
    self.pageCtrl = [[UIPageControl alloc]initWithFrame:CGRectMake(50, 20, 320-100, 33)];
    //[self.navigationController.view addSubview:self.pageCtrl];
    
    self.pageCtrl.pageIndicatorTintColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"image_slider_off.png"]];
    self.pageCtrl.currentPageIndicatorTintColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"simage_slider_on.png"]];
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:NO];
    
    NSUserDefaults * ud =[NSUserDefaults standardUserDefaults];
    NSDictionary * dictP =[ud objectForKey:UD_FB_USER_DETAIL];
    
    profileImage= [self getProfileImages:[dictP objectForKey:FACEBOOK_ID]];
    NSLog(@"profileImagecount%@",profileImage);
    self.mainImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.mainImageView.clipsToBounds = YES;
    
    if ([profileImage count] > 0){
        self.mainImageView.image =[UIImage imageWithContentsOfFile:[(UploadImages*)[profileImage objectAtIndex:0] imageUrlLocal]];
    }
    else{
        self.mainImageView.image = [UIImage imageNamed:@"pfImage.png"];
    }
    
    if ([User currentUser].profile_pic!=nil) {
        [self.mainImageView downloadFromURL:[User currentUser].profile_pic withPlaceholder:[UIImage imageNamed:@"pfImage.png"]];
    }
    
    self.lblNameAndAge.text = [NSString stringWithFormat:@"%@", [User currentUser].first_name];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    
    // Setting the swipe direction.
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    // Adding the swipe gesture on image view
    [self.mainImageView addGestureRecognizer:swipeLeft];
    [self.mainImageView addGestureRecognizer:swipeRight];
    
    
    [self.pageCtrl setNumberOfPages:[profileImage count]];
    [self.pageCtrl setCurrentPage:0];
    [self.view bringSubviewToFront:self.pageCtrl];

    //self.mainScrollView.contentSize = CGSizeMake(320, self.mainImageView.frame.size.height + self.bottomContainer.frame.size.height+60);
    
    self.mainScrollView.minimumZoomScale = 1.0f;
    self.mainScrollView.maximumZoomScale = 1.0f;
    self.mainScrollView.delegate = self;
    self.mainScrollView.bounces = YES;
    self.mainScrollView.bouncesZoom = NO;
    self.mainScrollView.alwaysBounceVertical = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.view addSubview:self.pageCtrl];
    if ([User currentUser].profile_pic!=nil) {
        [self.mainImageView downloadFromURL:[User currentUser].profile_pic withPlaceholder:[UIImage imageNamed:@"pfImage.png"]];
    }
}


#pragma mark -
#pragma mark - NavButton Methods

-(void)addrightButton:(UINavigationItem*)naviItem
{
	UIButton *rightbarbutton = [UIButton buttonWithType:UIButtonTypeCustom];
	[rightbarbutton setFrame:CGRectMake(0, 0,60, 25)];
    [rightbarbutton setTitle:@"Edit" forState:UIControlStateNormal];
    [rightbarbutton addTarget:self action:@selector(editProfile) forControlEvents:UIControlEventTouchUpInside];
    naviItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightbarbutton];
}

-(void)addBackToMessage:(UINavigationItem*)naviItem
{
    UIImage *imgButton = [UIImage imageNamed:@"chat_icon_off_line.png"];
	UIButton *rightbarbutton = [UIButton buttonWithType:UIButtonTypeCustom];
	[rightbarbutton setFrame:CGRectMake(0, 0, imgButton.size.width+20, imgButton.size.height)];
    [rightbarbutton setTitle:@"Done" forState:UIControlStateNormal];
    [rightbarbutton addTarget:self action:@selector(BackToMassageController:) forControlEvents:UIControlEventTouchUpInside];
    naviItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightbarbutton];
}
-(void)BackToMassageController:(UIButton*)sender
{
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark - Methods

-(void)editProfile
{
    EditProfileVC *editPC=[[EditProfileVC alloc]initWithNibName:@"EditProfileVC" bundle:nil];
    
    UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:editPC];
    
    [self presentViewController:navC animated:NO completion:nil];
    /*
    [UIView animateWithDuration:0.15
                          delay:0
                        options:UIViewAnimationOptionTransitionCurlUp
                     animations:^{
                         self.mainImageView.transform=CGAffineTransformConcat(CGAffineTransformMakeTranslation(-50, -100), CGAffineTransformMakeScale(0.8, 0.6));
                         
                         
                     }
                     completion:^(BOOL finished) {
                         self.mainImageView.transform = CGAffineTransformIdentity;
                         [self presentViewController:navC animated:NO completion:nil];
                         //[editPC setUpImages:profileImage];
                     }];
     */
}

-(NSArray*)getProfileImages :(NSString*)FBId
{
    NSManagedObjectContext *context = [APPDELEGATE managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UploadImages" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSArray *result=nil;
    
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"(fbId== %@)",
                              FBId];
    [fetchRequest setPredicate:predicate];
    
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"imageUrlLocal" ascending:YES]];
    
    NSError *error = nil;
    result = [context executeFetchRequest:fetchRequest error:&error];
    return  result;
    
}

#pragma mark -
#pragma mark - Actions

-(IBAction)handleSwipe:(UISwipeGestureRecognizer*)recognizer
{
    if (profileImage==nil || [profileImage count]==0) {
        return;
    }
    switch (recognizer.direction)
    {
        case UISwipeGestureRecognizerDirectionLeft:
        {
            if (self.pageCtrl.currentPage == [profileImage count] - 1)
                return;
            else {
                UploadImages * Upload = [profileImage objectAtIndex:self.pageCtrl.currentPage+1];
                CATransition *animation = [CATransition animation];
                animation.duration = 0.5;
                animation.type = kCATransitionMoveIn;
                animation.subtype = kCATransitionFromRight;
                [self.mainImageView.layer addAnimation:animation forKey:@"imageTransition"];
                self.mainImageView.image =[UIImage imageWithContentsOfFile:Upload.imageUrlLocal];
                self.pageCtrl.currentPage += 1;
            }
            break;
        }
        case UISwipeGestureRecognizerDirectionRight:
        {
            if (self.pageCtrl.currentPage == 0)
                return;
            else {
                UploadImages * Upload = [profileImage objectAtIndex:self.pageCtrl.currentPage-1];
                CATransition *animation = [CATransition animation];
                animation.duration = 0.5;
                animation.type = kCATransitionMoveIn;
                animation.subtype = kCATransitionFromLeft;
                [self.mainImageView.layer addAnimation:animation forKey:@"imageTransition"];
                self.mainImageView.image =[UIImage imageWithContentsOfFile:Upload.imageUrlLocal];
                self.pageCtrl.currentPage -= 1;
            }
            break;
        }
        case UISwipeGestureRecognizerDirectionUp:
        case UISwipeGestureRecognizerDirectionDown:
            break;
    }
}

#pragma mark -
#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView != self.mainScrollView) {
        return;
    }
    
    if (scrollView.contentOffset.y < 0) {
        CGRect fr = [self.mainImageView frame];
        fr.origin.y = scrollView.contentOffset.y;
        fr.size.height = 320 + (-1 * scrollView.contentOffset.y);
        fr.origin.x = scrollView.contentOffset.y/2;
        fr.size.width = 320 + ((-1 * scrollView.contentOffset.y));
        self.mainImageView.frame = fr;
    }
    if (scrollView.contentOffset.y == 0) {
        self.mainImageView.frame = CGRectMake(0, 0, 320, 320);
    }
}

#pragma mark -
#pragma mark - PPRevealSideViewController Delegate

- (BOOL) pprevealSideViewController:(PPRevealSideViewController *)controller shouldDeactivateGesture:(UIGestureRecognizer*)gesture forView:(UIView*)view
{
    if ([view isEqual:self.mainImageView] || [view isKindOfClass:[UITableViewCell class]] || [view isKindOfClass:[RoundedImageView class]] || [NSStringFromClass([view class]) hasPrefix:@"UITableView"]) {
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
