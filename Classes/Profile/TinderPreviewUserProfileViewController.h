//
//  TinderPreviewUserProfileViewController.h
//  Tinder
//
//  Created by Vinay Raja on 10/12/13.
//  Copyright (c) 2013 3Embed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TinderAppDelegate.h"

@interface TinderPreviewUserProfileViewController :UIViewController<UIScrollViewDelegate,UIGestureRecognizerDelegate,PPRevealSideViewControllerDelegate>
{
    
}
@property(nonatomic,strong)User *userFriend;

@property (nonatomic, strong) IBOutlet UIPageControl *pageCtrl;
@property (nonatomic, strong) IBOutlet UIImageView *mainImageView;
@property (nonatomic, strong) IBOutlet UIScrollView *mainScrollView;
@property (nonatomic, strong) IBOutlet UILabel *lblNameAndAge;
@property (nonatomic, strong) IBOutlet UILabel *lbllastActive;
@property (nonatomic, strong) IBOutlet UILabel *lblDistanceAway;

@property (nonatomic, strong) NSMutableDictionary *userProfile;

@end
