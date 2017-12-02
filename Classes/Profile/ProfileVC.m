//
//  ProfileVC.m
//  Tinder
//
//  Created by Elluminati - macbook on 12/06/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "ProfileVC.h"
#import "UIImageView+Download.h"
#import "EditProfileVC.h"

@interface ProfileVC ()

@end

@implementation ProfileVC

@synthesize user;

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
    
    arrImages=[[NSMutableArray alloc]init];
    currentPage=0;
    
    [self.navigationItem setTitle:@"Profile"];
    self.navigationController.navigationBarHidden = NO;
    
    if (user==nil) {
        [self addrightButton:self.navigationItem];
        self.lblActive.hidden=YES;
        self.lblAway.hidden=YES;
        [APPDELEGATE addBackButton:self.navigationItem];
    }else{
        self.lblActive.hidden=NO;
        self.lblAway.hidden=NO;
        [self addLeftButton:self.navigationItem];
    }
    
    
    [self.pcImage setNumberOfPages:[arrImages count]];
    [self.pcImage setCurrentPage:currentPage];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (user==nil) {
        [self getUserProfile:[User currentUser].fbid];
    }else{
        [self getUserProfile:user.fbid];
    }
}

#pragma mark -
#pragma mark - NavButton Methods

-(void)addrightButton:(UINavigationItem*)naviItem
{
	UIButton *rightbarbutton = [UIButton buttonWithType:UIButtonTypeCustom];
	[rightbarbutton setFrame:CGRectMake(0, 0,51, 25)];
    //[rightbarbutton setTitle:@"Edit" forState:UIControlStateNormal];
    [rightbarbutton setImage:[UIImage imageNamed:@"btnEditProfile"] forState:UIControlStateNormal];
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
-(void)done:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark -
#pragma mark - Methods

-(void)getUserProfile:(NSString *)fbid
{
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:fbid forKey:PARAM_ENT_USER_FBID];
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_GETPROFILE withParamData:dictParam withBlock:^(id response, NSError *error) {
        if (response) {
            if ([[response objectForKey:@"errFlag"] intValue]==0) {
                NSMutableArray *arr=[[NSMutableArray alloc]initWithArray:[response objectForKey:@"images"]];
                if (arr) {
                    [arr removeObject:[response objectForKey:@"profilePic"]];
                    [arrImages removeAllObjects];
                    [arrImages addObject:[response objectForKey:@"profilePic"]];
                    [arrImages addObjectsFromArray:arr];
                    [self setScroll];
                }
                if ([response objectForKey:@"age"]!=nil) {
                    self.lblNameAndAge.text=[NSString stringWithFormat:@"%@(%@)",[response objectForKey:@"firstName"],[response objectForKey:@"age"]];
                }else{
                    self.lblNameAndAge.text=[response objectForKey:@"firstName"];
                }
                if ([response objectForKey:@"status"]==nil || [[response objectForKey:@"status"]isEqualToString:@""]) {
                    self.txtAbout.text=[NSString stringWithFormat:@"Status: n/a"];
                }
                else{
                    self.txtAbout.text=[NSString stringWithFormat:@"Status: %@",[response objectForKey:@"status"]];
                }
                
                NSString *strActiveText = [Helper ConverGMTtoLocal:response[@"lastActive"]];
                self.lblActive.text=[NSString stringWithFormat:@"active %@ hour ago",strActiveText];
                
                CLLocationDistance distance;
                NSString *userLati=[response valueForKey:@"lati"];
                NSString *userLongi=[response valueForKey:@"long"];
                CLLocation *locB = [[CLLocation alloc] initWithLatitude:[[[UserDefaultHelper sharedObject] currentLatitude] floatValue] longitude:[[[UserDefaultHelper sharedObject] currentLongitude] floatValue]];
                CLLocation *locA = [[CLLocation alloc] initWithLatitude:[userLati floatValue] longitude:[userLongi floatValue]];
                distance=[locA distanceFromLocation:locB];
                int Km=distance/1000;
                self.lblAway.text=[NSString stringWithFormat:@"less than %dkm away",Km];
                
            }
        }
    }];
}

-(void)setScroll{
    int x=0;
    for (int i=0; i<[arrImages count]; i++) {
        UIImageView *img=[[UIImageView alloc]initWithFrame:CGRectMake(x, 0, self.scrImage.frame.size.width, self.scrImage.frame.size.height)];
        [img downloadFromURL:[arrImages objectAtIndex:i] withPlaceholder:nil];
        img.tag=1000+i;
        [self.scrImage addSubview:img];
        x+=self.scrImage.frame.size.width;
    }
    [self.scrImage setContentSize:CGSizeMake(x, self.scrImage.frame.size.height)];
    [self.pcImage setNumberOfPages:[arrImages count]];
    [self.pcImage setCurrentPage:currentPage];
}

-(void)editProfile
{
    EditProfileVC *editPC=[[EditProfileVC alloc]initWithNibName:@"EditProfileVC" bundle:nil];
    editPC.strStatus=[self.txtAbout.text stringByReplacingOccurrencesOfString:@"Status: " withString:@""];
    UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:editPC];
    [self presentViewController:navC animated:NO completion:nil];
}

#pragma mark -
#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat pageWidth = self.scrImage.frame.size.width;
    currentPage = floor((self.scrImage.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pcImage.currentPage=currentPage;
}

#pragma mark -
#pragma mark - PPRevealSideViewController Delegate

- (BOOL) pprevealSideViewController:(PPRevealSideViewController *)controller shouldDeactivateGesture:(UIGestureRecognizer*)gesture forView:(UIView*)view
{
    if ([view isEqual:self.scrImage] || [view isKindOfClass:[UITableViewCell class]] || [NSStringFromClass([view class]) hasPrefix:@"UITableView"]) {
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
