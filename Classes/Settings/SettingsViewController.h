//
//  SettingsViewController.h
//  Tinder
//
//  Created by Rahul Sharma on 30/11/13.
//  Copyright (c) 2013 3Embed. All rights reserved.
//

#import "BaseVC.h"
#import "TinderAppDelegate.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@class RangeSlider;
@class TinderAppDelegate;
@interface SettingsViewController : BaseVC<PPRevealSideViewControllerDelegate,MFMailComposeViewControllerDelegate>
{
  IBOutlet  UIButton *btnMale;
  IBOutlet  UIButton *btnFemale;
  IBOutlet  UISwitch *switchMale;
  IBOutlet  UISwitch *swichFemale;
  IBOutlet  UISlider *sliderDistance;
  IBOutlet  UISlider *sliderAgePrefrence;
  RangeSlider *slider;
  UILabel *reportLabel;
  IBOutlet UILabel *lblAgeMin;
  IBOutlet UILabel *lblShowAges;
  IBOutlet UILabel *lblIAM;
  IBOutlet UILabel *lblShowMe;
  IBOutlet UILabel *lblLimitSearch;
  IBOutlet UILabel *lblMen;
  IBOutlet UILabel *lblWomen;
  TinderAppDelegate * appDelagte;
  IBOutlet UIScrollView * scrollview;
  IBOutlet UIButton  *btnLogout;
  IBOutlet UIButton  *btncontactUs;
  IBOutlet UIButton  *btnSubmitt;
  IBOutlet UILabel   *lblDistanceTxt;
  IBOutlet UIImageView *imgBox;
  IBOutlet UIView * viewBG;
  IBOutlet UIButton * btnMile;
  IBOutlet UIButton * btnKm;
  IBOutlet UIButton * btnAccountDelete;
  IBOutlet UIImageView * sliderDistanceBox;
    IBOutlet UIImageView * sliderAgeBox;
  int Intested_in;
  int sex;

   
}

@property (weak, nonatomic) IBOutlet UISwitch *switchTime;
- (IBAction)setTimeBtnPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *lblTIme;
-(IBAction)btnAction:(id)sender;
- (IBAction)setState:(id)sender;
 @property (weak, nonatomic) IBOutlet UILabel *lblDistance;
-(IBAction)sliderChange:(UISlider*)sender;
-(IBAction)btnActionBottom:(id)sender;
-(void)saveUpdatedValue;
@end
