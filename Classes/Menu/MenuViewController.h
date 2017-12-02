//
//  MenuViewController.h
//  Tinder
//
//  Created by Rahul Sharma on 29/11/13.
//  Copyright (c) 2013 3Embed. All rights reserved.
//

#import "BaseVC.h"

#import "SettingsViewController.h"
#import "PPRevealSideViewController.h"
#import "ProfileViewController.h"

@interface MenuViewController : BaseVC<PPRevealSideViewControllerDelegate,UIActionSheetDelegate>
{
    IBOutlet UIButton *btnProfile;
}
-(IBAction)btnAction:(id)sender;

@end
