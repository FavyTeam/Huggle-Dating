//
//  SplashVC.h
//  Tinder
//
//  Created by Elluminati - macbook on 12/04/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "BaseVC.h"
#import "PPRevealSideViewController.h"

@interface SplashVC : BaseVC<PPRevealSideViewControllerDelegate>
{
    
}
@property(nonatomic,weak)IBOutlet UIImageView *imgSplash;

@end
