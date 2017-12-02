//
//  TinderPreviewUserProfileViewController.m
//  Tinder
//
//  Created by Vinay Raja on 10/12/13.
//  Copyright (c) 2013 3Embed. All rights reserved.
//

#import "TinderPreviewUserProfileViewController.h"
#import "MyTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageDownloader.h"
#import "RoundedImageView.h"
#import "TinderGenericUtility.h"
#import "Helper.h"

@interface TinderPreviewUserProfileViewController (){
    NSArray *imageArr;
    NSArray * profileImage;
}

@end

@implementation TinderPreviewUserProfileViewController

@synthesize userProfile;
@synthesize userFriend;

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
    
    /***** navigation Item*****/
    self.navigationController.navigationBarHidden = NO;
    [self.navigationItem setTitle:@"Profile"];
    [self addLeftButton:self.navigationItem];
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:NO];
    self.pageCtrl = [[UIPageControl alloc]initWithFrame:CGRectMake(60, 20, 320-120, 27)];
    [self.navigationController.view addSubview:self.pageCtrl];
    
    self.lblNameAndAge . frame = CGRectMake(12, 4, 295, 30);

    self.pageCtrl.pageIndicatorTintColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"image_slider_off.png"]];
    self.pageCtrl.currentPageIndicatorTintColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"simage_slider_on.png"]];
    
    [self.mainImageView setImageWithURL:[NSURL URLWithString:userFriend.profile_pic]
                       placeholderImage:nil
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                  
                              }];
    
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    
    // Setting the swipe direction.
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    // Adding the swipe gesture on image view
    [self.mainImageView addGestureRecognizer:swipeLeft];
    [self.mainImageView addGestureRecognizer:swipeRight];
    
    
    [self getUserProfile];
}

-(void)addLeftButton:(UINavigationItem*)naviItem
{
	UIButton *rightbarbutton = [UIButton buttonWithType:UIButtonTypeCustom];
	[rightbarbutton setFrame:CGRectMake(0, 0, 60, 42)];
    [rightbarbutton setTitle:@"Done" forState:UIControlStateNormal];
    [rightbarbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    rightbarbutton.titleLabel.font = [UIFont fontWithName:HELVETICALTSTD_LIGHT size:15];
    
    [rightbarbutton addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    naviItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightbarbutton];
}

-(void)addRightButton:(UINavigationItem*)naviItem
{
    UIImage *imgButton = [UIImage imageNamed:@"edit_close_btn.png"];
    UIButton *rightbarbutton = [UIButton buttonWithType:UIButtonTypeCustom];
	[rightbarbutton setFrame:CGRectMake(0, 0, imgButton.size.width, imgButton.size.height)];
    [rightbarbutton setImage:imgButton forState:UIControlStateNormal];
    [rightbarbutton addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIImage *imgButton1 = [UIImage imageNamed:@"heart_btn.png"];
    UIButton *rightbarbutton1 = [UIButton buttonWithType:UIButtonTypeCustom];
	[rightbarbutton1 setFrame:CGRectMake(0, 0, imgButton1.size.width, imgButton1.size.height)];
    [rightbarbutton1 setImage:imgButton1 forState:UIControlStateNormal];
    
    [rightbarbutton1 addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithCustomView:rightbarbutton];
    UIBarButtonItem *rightBtn1 = [[UIBarButtonItem alloc] initWithCustomView:rightbarbutton1];
    rightbarbutton.tag = 2;
    rightbarbutton1.tag = 1;
    
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [fixedSpace setWidth:20];
    self.navigationItem.rightBarButtonItems = @[rightBtn1, fixedSpace, rightBtn];
}

-(IBAction)done:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
    self.pageCtrl.hidden = YES;
}

-(void)makeFrameForTable
{
    self.mainScrollView.minimumZoomScale = 1.0f;
    self.mainScrollView.maximumZoomScale = 1.0f;
    self.mainScrollView.delegate = self;
    self.mainScrollView.bounces = YES;
    self.mainScrollView.bouncesZoom = NO;
    self.mainScrollView.alwaysBounceVertical = YES;
    
}

-(void)getUserProfile
{
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:userFriend.fbid forKey:PARAM_ENT_USER_FBID];
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_GETPROFILE withParamData:dictParam withBlock:^(id response, NSError *error) {
        if (response) {
            [self userProfileResponse:response];
        }
    }];
    
}

-(void)userProfileResponse:(NSDictionary*)response
{
    NSDictionary *dict = response[@"ItemsList"];
    if ([dict[@"errFlag"] integerValue] == 0)
    {
        if (dict[@"age"])
        {
            NSString *strAge=[dict valueForKey:@"age"];
            int age=[strAge intValue];
            self.lblNameAndAge.text = [NSString stringWithFormat:@"%@, %d", dict[@"firstName"], age];
        }
        else {
            self.lblNameAndAge.text = dict[@"firstname"];
        }
        
        NSString *  strActiveText = [Helper ConverGMTtoLocal:dict[@"lastActive"]];
       
        CLLocationDistance distance;
        NSString *userLati=[dict valueForKey:@"lati"];
        NSString *userLongi=[dict valueForKey:@"long"];
        // userLati=@"20";
        // userLongi=@"73";
        CLLocation *locB = [[CLLocation alloc] initWithLatitude:[[[UserDefaultHelper sharedObject] currentLatitude] floatValue] longitude:[[[UserDefaultHelper sharedObject] currentLongitude] floatValue]];
        CLLocation *locA = [[CLLocation alloc] initWithLatitude:[userLati floatValue] longitude:[userLongi floatValue]];
        distance=[locA distanceFromLocation:locB];
        
        int Km=distance/1000;
        
        int dist=[[[NSUserDefaults standardUserDefaults]objectForKey:@"DISTANCE"] intValue];
        if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"DIST"] intValue]==MILE) {
            dist*=1.60934;
        }
        if (Km>dist) {
            Km=dist;
        }
        
        self.lblNameAndAge.text=[NSString stringWithFormat:@"%@",[response objectForKey:@"firstName"]];
        
        [Helper setToLabel:self.lblDistanceAway Text:[NSString stringWithFormat:@"less than %dkm away",Km] WithFont:HELVETICALTSTD_ROMAN FSize:13 Color:[Helper getColorFromHexString:@"#5c5c5c" :1.0]];
        
        [Helper setToLabel:self.lbllastActive Text:[NSString stringWithFormat:@"active %@ hour ago",strActiveText] WithFont:HELVETICALTSTD_ROMAN FSize:13 Color:[Helper getColorFromHexString:@"#838383" :1.0]];
        
        
        profileImage = dict[@"images"];
        if (profileImage.count > 0) {
            if ([profileImage[0] isKindOfClass:[NSNull class]]) {
                
                return;
            }
        }
        //profileImage = [profileImage arrayByAddingObjectsFromArray:images];
        [self.pageCtrl setNumberOfPages:[profileImage count]];
        [self.pageCtrl setCurrentPage:0];
        
    }
}



-(IBAction)handleSwipe:(UISwipeGestureRecognizer*)recognizer
{
    UIActivityIndicatorView *activityIndicator =[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(self.mainImageView.frame.size.width/2-20/2, self.mainImageView.frame.size.height/2-20/2, 20, 20)];
    [self.mainImageView addSubview:activityIndicator];
    
    activityIndicator.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
    [activityIndicator startAnimating];
    [activityIndicator hidesWhenStopped];
    
    switch (recognizer.direction)
    {
        case UISwipeGestureRecognizerDirectionLeft:
        {
            if (self.pageCtrl.currentPage == [profileImage count] - 1){
                [activityIndicator stopAnimating];
                return;
            }
            else {
                NSString *url = [profileImage objectAtIndex:self.pageCtrl.currentPage+1];
                CATransition *animation = [CATransition animation];
                animation.duration = 0.5;
                animation.type = kCATransitionMoveIn;
                animation.subtype = kCATransitionFromRight;
                [self.mainImageView.layer addAnimation:animation forKey:@"imageTransition"];
                [self.mainImageView setImageWithURL:[NSURL URLWithString:url]
                                   placeholderImage:nil
                                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                              [activityIndicator stopAnimating];
                                              
                                          }];
                self.pageCtrl.currentPage += 1;
                
            }
            
            break;
        }
        case UISwipeGestureRecognizerDirectionRight:
        {
            if (self.pageCtrl.currentPage == 0){
                [activityIndicator stopAnimating];
                return;
            }
            
            else {
                NSString *url = [profileImage objectAtIndex:self.pageCtrl.currentPage-1];
                CATransition *animation = [CATransition animation];
                animation.duration = 0.5;
                animation.type = kCATransitionMoveIn;
                animation.subtype = kCATransitionFromLeft;
                [self.mainImageView.layer addAnimation:animation forKey:@"imageTransition"];
                [self.mainImageView setImageWithURL:[NSURL URLWithString:url]
                                   placeholderImage:nil
                                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                              [activityIndicator stopAnimating];
                                              
                                          }];
                self.pageCtrl.currentPage -= 1;
                
                
            }
            
            break;
        }
        case UISwipeGestureRecognizerDirectionUp:
        case UISwipeGestureRecognizerDirectionDown:
            break;
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView                                              // any offset changes
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
#pragma mark - Memory mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
