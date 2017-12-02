//
//  SettingsViewController.m
//  Tinder
//
//  Created by Rahul Sharma on 30/11/13.
//  Copyright (c) 2013 3Embed. All rights reserved.
//

#import "SettingsViewController.h"
#import <FacebookSDK/FBSessionTokenCachingStrategy.h>
#import "RangeSlider.h"
#import "LoginViewController.h"
#import "Helper.h"
#import "ProgressIndicator.h"
#import "Service.h"
#import "ActionSheetStringPicker.h"

#import "UserSettings.h"

@interface SettingsViewController ()
{
    BOOL isTime;
    int unitIndex;
    
    NSMutableArray *arrForSecond;
}

@end

@implementation SettingsViewController

@synthesize lblDistance;

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
    self.navigationController.navigationBar.translucent = NO;
    
    CGRect screen = [[UIScreen mainScreen]bounds];
    if (IS_IPHONE_5) {
        scrollview.frame = CGRectMake(0, 44, 320, screen.size.height);
    }
    appDelagte =(TinderAppDelegate*) [[UIApplication sharedApplication]delegate];
    self.navigationController.navigationBarHidden = NO;
    [appDelagte addBackButton:self.navigationItem];
    [self.navigationItem setTitle:@"Settings"];
    [appDelagte addrightButton:self.navigationItem];
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:NO];
    
    // ui settings
    
    [Helper setToLabel:lblDistance Text:@"I Am :" WithFont:HELVETICALTSTD_LIGHT FSize:19 Color:BLACK_COLOR];
    [Helper setToLabel:lblShowMe Text:@"Show Me :" WithFont:HELVETICALTSTD_LIGHT FSize:19 Color:BLACK_COLOR];
    [Helper setToLabel:lblLimitSearch Text:@"Limit Search To :" WithFont:HELVETICALTSTD_LIGHT FSize:19 Color:BLACK_COLOR];
    [Helper setToLabel:lblShowAges Text:@"Show Ages :" WithFont:HELVETICALTSTD_LIGHT FSize:19 Color:BLACK_COLOR];
    [Helper setToLabel:lblMen Text:@"Men" WithFont:HELVETICALTSTD_LIGHT FSize:19 Color:[Helper getColorFromHexString:@"#999999" :1.0]];
    [Helper setToLabel:lblWomen Text:@"Women" WithFont:HELVETICALTSTD_LIGHT FSize:19 Color:[Helper getColorFromHexString:@"#999999" :1.0]];
    [Helper setToLabel:lblDistanceTxt Text:nil WithFont:HELVETICALTSTD_LIGHT FSize:19 Color:[Helper getColorFromHexString:@"#999999" :1.0]];
    [Helper setToLabel:lblAgeMin Text:Nil WithFont:HELVETICALTSTD_ROMAN FSize:19 Color:BLACK_COLOR];
    [Helper setToLabel:lblDistance Text:nil WithFont:HELVETICALTSTD_ROMAN FSize:19 Color:BLACK_COLOR];
    [Helper setButton:btncontactUs Text:@"Contact Us" WithFont:HELVETICALTSTD_LIGHT FSize:15 TitleColor:[Helper getColorFromHexString:@"#999999" :1.0] ShadowColor:nil];
    [Helper setButton:btnLogout Text:@"Log Out" WithFont:HELVETICALTSTD_LIGHT FSize:15 TitleColor:[Helper getColorFromHexString:@"#999999" :1.0] ShadowColor:nil];
    [Helper setButton:btnSubmitt Text:@"Update" WithFont:HELVETICALTSTD_LIGHT FSize:15 TitleColor:[Helper getColorFromHexString:@"#999999" :1.0] ShadowColor:nil];
    
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0"))
    {
        swichFemale.onTintColor = [UIColor greenColor];
        switchMale.onTintColor = [UIColor greenColor];
    }
    UIImage *minImage = [[UIImage imageNamed:@"slider_blue.png"]
                         resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    UIImage *maxImage = [[UIImage imageNamed:@"slider_gray.png"]
                         resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    UIImage *thumbImage = [UIImage imageNamed:@"slider_btn.png"];
    
    [[UISlider appearance] setMaximumTrackImage:maxImage
                                       forState:UIControlStateNormal];
    [[UISlider appearance] setMinimumTrackImage:minImage
                                       forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:thumbImage
                                forState:UIControlStateNormal];
    
    
    slider = [[RangeSlider alloc] initWithFrame:CGRectMake(18, 375, 286, 26)];
    // the slider enforces a height of 30, although I'm not sure that this is necessary
    slider.minimumRangeLength = 0.1;
	[slider setMinThumbImage:[UIImage imageNamed:@"slider_btn.png"]]; // the two thumb controls are given custom images
	[slider setMaxThumbImage:[UIImage imageNamed:@"slider_btn.png"]];
    //slider.min =(min-18)/40;
    //slider.max =(max-18)/40;
    [scrollview addSubview:slider];
    
    
    
    [[ProgressIndicator sharedInstance]showPIOnView:self.view withMessage:@"User setting.."];
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_GETPREFERENCES withParamData:dictParam withBlock:^(id response, NSError *error) {
        if (response) {
            if ([[response objectForKey:@"errFlag"] intValue]==0) {
                [UserSettings currentSetting].sex=[response objectForKey:@"sex"];
                [UserSettings currentSetting].prRad=[response objectForKey:@"prRad"];
                [UserSettings currentSetting].prSex=[response objectForKey:@"prSex"];
                [UserSettings currentSetting].prLAge=[response objectForKey:@"prLAge"];
                [UserSettings currentSetting].prUAge=[response objectForKey:@"prUAge"];
            }
        }
        
        [self upDatePrefControls];
        
        [[ProgressIndicator sharedInstance]hideProgressIndicator];
    }];
    
    
    viewBG.frame = CGRectMake(0,44, 320,  btnSubmitt.frame.origin.y+btnSubmitt.frame.size.height+50);
    viewBG.backgroundColor = [UIColor clearColor];
    if (IS_IPHONE_5) {
        scrollview.contentSize = CGSizeMake(320, btnSubmitt.frame.origin.y+btnSubmitt.frame.size.height+100);
    }
    else{
        scrollview.contentSize = CGSizeMake(320, btnSubmitt.frame.origin.y+btnSubmitt.frame.size.height+170);
    }
    
    /*
    btnAccountDelete.frame = CGRectMake(13, btnSubmitt.frame.origin.y+btnSubmitt.frame.size.height+100, 296, 49);
    
    viewBG.frame = CGRectMake(0,44, 320,  btnAccountDelete.frame.origin.y+btnAccountDelete.frame.size.height+50);
    btnAccountDelete.userInteractionEnabled = YES;
    viewBG.backgroundColor = [UIColor clearColor];
    
    [Helper setButton:btnAccountDelete Text:@"Delete Account" WithFont:HELVETICALTSTD_LIGHT FSize:19 TitleColor:WHITE_COLOR  ShadowColor:nil];
    
    if (IS_IPHONE_5) {
        scrollview.contentSize = CGSizeMake(320, btnAccountDelete.frame.origin.y+btnAccountDelete.frame.size.height+100);
    }
    else{
        scrollview.contentSize = CGSizeMake(320, btnAccountDelete.frame.origin.y+btnAccountDelete.frame.size.height+130);
    }
    */
}

-(void)upDatePrefControls{
    /***** settings For gender******/
    if ([UserSettings currentSetting].sex==nil) {
        [UserSettings currentSetting].sex=@"1";
    }
    
    if ([[UserSettings currentSetting].sex intValue]==1) {
        [btnMale setTitleColor:WHITE_COLOR forState:UIControlStateSelected];
        [btnMale setBackgroundImage:[UIImage imageNamed:@"indicator_tab.png"] forState:UIControlStateSelected];
        btnMale.titleLabel.font = [UIFont fontWithName:HELVETICALTSTD_LIGHT size:19.0];
        [btnMale setSelected:YES];
        
        [btnFemale setTitleColor:[Helper getColorFromHexString:@"#999999" :1.0] forState:UIControlStateNormal];
        btnFemale.titleLabel.font = [UIFont fontWithName:HELVETICALTSTD_LIGHT size:19.0];
        [btnFemale setBackgroundImage:nil forState:UIControlStateNormal];
        [btnFemale setSelected:NO];
    }
    else{
        [btnFemale setTitleColor:WHITE_COLOR forState:UIControlStateSelected];
        [btnFemale setBackgroundImage:[UIImage imageNamed:@"indicator_tab.png"] forState:UIControlStateSelected];
        btnFemale.titleLabel.font = [UIFont fontWithName:HELVETICALTSTD_LIGHT size:19.0];
        [btnFemale setSelected:YES];
        
        [btnMale setTitleColor:[Helper getColorFromHexString:@"#999999" :1.0] forState:UIControlStateNormal];
        btnMale.titleLabel.font = [UIFont fontWithName:HELVETICALTSTD_LIGHT size:19.0];
        [btnMale setBackgroundImage:nil forState:UIControlStateNormal];
        [btnMale setSelected:NO];
    }
    
    
    /***** settings For Intrest ******/
    if ([UserSettings currentSetting].prSex==nil) {
        [UserSettings currentSetting].prSex=@"3";
    }
    
    if ([[UserSettings currentSetting].prSex intValue]==1) {
        [switchMale setOn:YES animated:YES];
        [swichFemale setOn:NO animated:YES];
    }
    else if ([[UserSettings currentSetting].prSex intValue]==2) {
        [swichFemale setOn:YES animated:YES];
        [switchMale setOn:NO animated:YES];
    }
    else{
        [swichFemale setOn:YES animated:YES];
        [switchMale setOn:YES animated:YES];
    }
    
    /***** settings For distance slider******/
    sliderDistance.maximumValue =100;
    sliderDistance.minimumValue = 0;
    if ([UserSettings currentSetting].prRad==nil) {
        [UserSettings currentSetting].prRad=@"50";
    }
    [sliderDistance setValue:[[UserSettings currentSetting].prRad intValue] animated:YES];
    lblDistance.text = [NSString stringWithFormat:@"%dkm", [[UserSettings currentSetting].prRad intValue]];
    
    
    
    /***** settings For max and Min age slider******/
    if ([UserSettings currentSetting].prLAge==nil) {
        [UserSettings currentSetting].prLAge=@"18";
    }
    if ([UserSettings currentSetting].prUAge==nil) {
        [UserSettings currentSetting].prUAge=@"58";
    }
    
    int min = [[UserSettings currentSetting].prLAge intValue];
    int max = [[UserSettings currentSetting].prUAge intValue];
	
	[slider setTrackImage:[[UIImage imageNamed:@"slider_gray.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(9.0, 9.0, 9.0, 9.0)]];
	[slider setInRangeTrackImage:[UIImage imageNamed:@"slider_blue.png"]];
    
	[slider addTarget:self action:@selector(report:) forControlEvents:UIControlEventValueChanged];
    
    
    lblAgeMin.text = [NSString stringWithFormat:@"%d-%d+",min,max];
    if (min>18) {
        float val = (min-18.0)/40.0;
        [slider setMin:val];
    }
    if (max > 18 && max < 58)
    {
        float val = (max-18.0)/40.0;
        [slider setMax:val];
    }
    
}


-(void)saveUpdatedValue
{
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    
    NSDictionary * dictAge = [[[UserDefaultHelper sharedObject] facebookUserDetail] objectForKey:FACEBOOK_AGERANGE];
    NSArray * arrIntrest = [[[UserDefaultHelper sharedObject] facebookUserDetail] objectForKey:FACEBOOK_INTRESTED_IN];
    
    /***** settings For Intrest ******/
    
    if ([ud integerForKey:@"INTREST"]==0) {
        
        if ( arrIntrest.count>1)
        {
            [swichFemale setOn:YES animated:YES];
            [switchMale setOn:YES animated:YES];
            Intested_in = 3;
            
        }
        else{
            if ([[arrIntrest objectAtIndex:0] isEqualToString:@"female"]) {
                [swichFemale setOn:YES animated:YES];
                [switchMale setOn:NO animated:YES];
                Intested_in = 2;
            }
            else if([[arrIntrest objectAtIndex:0] isEqualToString:@"male"])
            {
                [switchMale setOn:YES animated:YES];
                [swichFemale setOn:NO animated:YES];
                Intested_in = 1;
            }
            else
            {
                [switchMale setOn:NO animated:YES];
                [swichFemale setOn:YES animated:YES];
                Intested_in = 1;
            }
        }
    }
    else{
        
        if ([ud integerForKey:@"INTREST"]==1) {
            [switchMale setOn:YES animated:YES];
            [swichFemale setOn:NO animated:YES];
            Intested_in = 1;
        }
        else if([ud integerForKey:@"INTREST"]==2)
        {
            [swichFemale setOn:YES animated:YES];
            [switchMale setOn:NO animated:YES];
            Intested_in = 2;
        }
        else if([ud integerForKey:@"INTREST"]==3)
        {
            [swichFemale setOn:YES animated:YES];
            [switchMale setOn:YES animated:YES];
            Intested_in = 3;
        }
        
        
    }
    
    
    /***** settings For gender******/
    
    if ([ud integerForKey:@"GENDER"]==0) {
        
        if ([[[[UserDefaultHelper sharedObject] facebookUserDetail] objectForKey:FACEBOOK_GENDER] isEqualToString:@"female"])
        {
            
            [btnFemale setTitleColor:WHITE_COLOR forState:UIControlStateSelected];
            [btnMale setTitleColor:[Helper getColorFromHexString:@"#999999" :1.0] forState:UIControlStateNormal];
            btnFemale.titleLabel.font = [UIFont fontWithName:HELVETICALTSTD_LIGHT size:19.0];
            [btnFemale setBackgroundImage:[UIImage imageNamed:@"indicator_tab.png"] forState:UIControlStateSelected];
            btnMale.titleLabel.font = [UIFont fontWithName:HELVETICALTSTD_LIGHT size:19.0];
            [btnMale setBackgroundImage:nil forState:UIControlStateNormal];
            [btnFemale setSelected:YES];
            [btnMale setSelected:NO];
            
            sex =FEMALE;
        }
        else
        {
            [btnMale setTitleColor:WHITE_COLOR forState:UIControlStateSelected];
            [btnFemale setTitleColor:[Helper getColorFromHexString:@"#999999" :1.0] forState:UIControlStateNormal];
            [btnMale setBackgroundImage:[UIImage imageNamed:@"indicator_tab.png"] forState:UIControlStateSelected];
            btnFemale.titleLabel.font = [UIFont fontWithName:HELVETICALTSTD_LIGHT size:19.0];
            btnMale.titleLabel.font = [UIFont fontWithName:HELVETICALTSTD_LIGHT size:19.0];
            [btnFemale setBackgroundImage:nil forState:UIControlStateNormal];
            [btnMale setSelected:YES];
            [btnFemale setSelected:NO];
            sex=MALE;
            
            
        }
    }
    else
    {
        
        if ([ud integerForKey:@"GENDER"]==FEMALE)
        {
            [btnFemale setTitleColor:WHITE_COLOR forState:UIControlStateSelected];
            [btnFemale setTitleColor:[Helper getColorFromHexString:@"#999999" :1.0] forState:UIControlStateNormal];
            btnFemale.titleLabel.font = [UIFont fontWithName:HELVETICALTSTD_LIGHT size:19.0];
            [btnFemale setBackgroundImage:[UIImage imageNamed:@"indicator_tab.png"] forState:UIControlStateSelected];
            btnMale.titleLabel.font = [UIFont fontWithName:HELVETICALTSTD_LIGHT size:19.0];
            [btnMale setBackgroundImage:nil forState:UIControlStateNormal];
            [btnFemale setSelected:YES];
            [btnMale setSelected:NO];
            sex=FEMALE;
            
            
        }
        else{
            
            [btnMale setTitleColor:WHITE_COLOR forState:UIControlStateSelected];
            [btnFemale setTitleColor:[Helper getColorFromHexString:@"#999999" :1.0] forState:UIControlStateNormal];
            [btnMale setBackgroundImage:[UIImage imageNamed:@"indicator_tab.png"] forState:UIControlStateSelected];
            btnFemale.titleLabel.font = [UIFont fontWithName:HELVETICALTSTD_LIGHT size:19.0];
            btnMale.titleLabel.font = [UIFont fontWithName:HELVETICALTSTD_LIGHT size:19.0];
            [btnFemale setBackgroundImage:nil forState:UIControlStateNormal];
            [btnMale setSelected:YES];
            [btnFemale setSelected:NO];
            sex =MALE;
            
        }
        
    }
    
    /***** settings For distance slider******/
    
    [sliderDistance setValue:50 animated:YES];
    sliderDistance.maximumValue =100;
    sliderDistance.minimumValue = 0;
    
    UIImage *minImage = [[UIImage imageNamed:@"slider_blue.png"]
                         resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    UIImage *maxImage = [[UIImage imageNamed:@"slider_gray.png"]
                         resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    UIImage *thumbImage = [UIImage imageNamed:@"slider_btn.png"];
    
    [[UISlider appearance] setMaximumTrackImage:maxImage
                                       forState:UIControlStateNormal];
    [[UISlider appearance] setMinimumTrackImage:minImage
                                       forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:thumbImage
                                forState:UIControlStateNormal];
    
    if (![ud objectForKey:@"DISTANCE"])
    {
        if ([ud integerForKey:@"DIST"] ==3) {
            lblDistance.text = [NSString stringWithFormat:@"%dmi", 50];
        }
        else if ([ud integerForKey:@"DIST"] ==4) {
            lblDistance.text = [NSString stringWithFormat:@"%dkm", 50];
        }
        else{
            lblDistance.text =@"50mi";
        }
        sliderDistance.value =50;
    }
    else{
        if ([ud integerForKey:@"DIST"] ==3) {
            lblDistance.text = [NSString stringWithFormat:@"%dmi", [[ud objectForKey:@"DISTANCE"] intValue]];
        }
        else if ([ud integerForKey:@"DIST"] ==4) {
            lblDistance.text = [NSString stringWithFormat:@"%dkm", [[ud objectForKey:@"DISTANCE"] intValue]];
        }
        else{
            lblDistance.text =@"50mi";
        }
        
        
        sliderDistance.value =[[ud objectForKey:@"DISTANCE"]intValue];
    }
    
    
    
    
    /***** settings For max and Min age slider******/
    int min = [[dictAge objectForKey:AGERANGE_MIN] intValue];
    int max = [[dictAge objectForKey:AGERANGE_MAX] intValue];

    // there are two track images, one for the range "track", and one for the filled in region of the track between the slider thumbs
	
    [slider setTrackImage:[[UIImage imageNamed:@"slider_gray.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(9.0, 9.0, 9.0, 9.0)]];
	[slider setInRangeTrackImage:[UIImage imageNamed:@"slider_blue.png"]];
    
    if ([ud integerForKey:@"PrefMin"] ||[ud integerForKey:@"PrefMax"]) {
        lblAgeMin.text = [NSString stringWithFormat:@"%d-%d+",[ud integerForKey:@"PrefMin"],[ud integerForKey:@"PrefMax"]];
        if ([ud integerForKey:@"PrefMin"]>18) {
            float val = ([ud integerForKey:@"PrefMin"]-18.0)/40.0;
            [slider setMin:val];
        }
        if ([ud integerForKey:@"PrefMax"] > 18 && [ud integerForKey:@"PrefMax"] < 58)
        {
            float val = ([ud integerForKey:@"PrefMax"]-18.0)/40.0;
            [slider setMax:val];
        }
    }
    else{
        lblAgeMin.text = [NSString stringWithFormat:@"18-58+"];
        if (min > 18) {
            float val = (min-18.0)/40.0;
            [slider setMin:val];
        }
        if (max > 18 && max < 58) {
            [slider setMax:(max-18.0)/40.0];
        }
        
        
    }
    //[self report:slider];
    [super viewDidLoad];
    
}

#pragma mark -Button Action(GENDER AND DISTANCE)

-(IBAction)btnAction:(id)sender{
    
    UIButton * btn = (UIButton*)sender;
    switch (btn.tag) {
        case MALE:
        {
            [UserSettings currentSetting].sex=[NSString stringWithFormat:@"%d",MALE];
            break;
        }
        case FEMALE:
        {
            [UserSettings currentSetting].sex=[NSString stringWithFormat:@"%d",FEMALE];
            break;
        }
        default:
            break;
    }
    [self upDatePrefControls];
}

#pragma mark -
#pragma mark - switch method For male and female

- (void)setState:(id)sender
{
    UISwitch * swch = (UISwitch*)sender;
    switch (swch.tag) {
        case 0:
            if ([switchMale isOn]==NO && [swichFemale isOn]==NO) {
                [swichFemale setOn:YES animated:YES];
                Intested_in =2;
            }
            else if([switchMale isOn]==YES && [swichFemale isOn]==YES){
                Intested_in =3;
            }
            else if([switchMale isOn]==YES && [swichFemale isOn]==NO){
                Intested_in =1;
            }
            else if([switchMale isOn]==NO && [swichFemale isOn]==YES){
                Intested_in =2;
            }
            break;
            
        case 1:
            if ([switchMale isOn]==NO && [swichFemale isOn]==NO) {
                [switchMale setOn:YES animated:YES];
                Intested_in =1;
            }
            else if([switchMale isOn]==YES && [swichFemale isOn]==YES){
                Intested_in =3;
            }
            else if([switchMale isOn]==YES && [swichFemale isOn]==NO){
                Intested_in =1;
            }
            else if([switchMale isOn]==NO && [swichFemale isOn]==YES){
                Intested_in =2;
            }
            break;
            
        default:
            break;
    }
    [UserSettings currentSetting].prSex=[NSString stringWithFormat:@"%d",Intested_in];
}

#pragma mark -
#pragma mark - slider Distance value Change method

-(IBAction)sliderChange:(UISlider*)sender {

    NSString *newText = [[NSString alloc] initWithFormat:@"%d",(int)[sender value]];
    
    lblDistance.text=[NSString stringWithFormat:@"%@km", newText];
    [UserSettings currentSetting].prRad=newText;
}

#pragma mark -
#pragma mark - slider age(MAX and MIN)

- (void)report:(RangeSlider *)sender {

    int min = sender.min*40+18;
    int max = sender.max*40+18;
    
    [UserSettings currentSetting].prLAge=[NSString stringWithFormat:@"%d",min];
    [UserSettings currentSetting].prUAge=[NSString stringWithFormat:@"%d",max];
    
	NSString *report = nil;
    if (max >= 58) {
        report = [NSString stringWithFormat:@"%d-58+", min];
        
    }
    else {
        report = [NSString stringWithFormat:@"%d-%d", min, max];
        
    }
	lblAgeMin.text = report;
}

#pragma mark -
#pragma mark - Button Action (Update Prefrance ,Logout,mail and Delete)

-(IBAction)btnActionBottom:(id)sender
{
    UIButton * btn = (UIButton*)sender;
    switch (btn.tag) {
        case 11:
        {
            [self openMail];
            break;
        }
        case 12:
        {
            [self sendRequestForLogOut];
            break;
        }
        case 13:
        {
            [self sendRequestForUpdate];
            break;
        }
        case 14:
        {
            [self sendRequestForDeleteAccount];
            break;
        }
        default:
            break;
    }
}

#pragma mark -
#pragma mark - Request And Response For Delete Account

-(void)sendRequestForDeleteAccount
{
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    [paramDict setObject:[[UserDefaultHelper sharedObject] facebookToken] forKey:PARAM_ENT_SESS_TOKEN];
    [paramDict setObject:[[UserDefaultHelper sharedObject] uuid]  forKey:PARAM_ENT_DEV_ID];
    
    WebServiceHandler *handler = [[WebServiceHandler alloc] init];
    handler.requestType = eParseKey;
    NSMutableURLRequest * request = [Service parseDeleteAccount:paramDict];
    
    [handler placeWebserviceRequestWithString:request Target:self Selector:@selector(DeleteAccount:)];
}

-(void)DeleteAccount:(NSDictionary*)_response
{
    ProgressIndicator * pi = [ProgressIndicator sharedInstance];
    if (_response == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Connection Timeout." delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:nil, nil];
        alert.tag = 400;
        [alert show];
    }
    else
    {
        if (_response != nil) {
            NSDictionary *dict = [_response objectForKey:@"ItemsList"];
            if ([[dict objectForKey:@"errFlag"]intValue]==0 && [[dict objectForKey:@"errNum"]intValue]==61)
            {
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Message" message:@"You are about to delete all your account details incliuding matches and chat too. Are you sure?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                alert.tag =102;
                [alert show];
            }
            else if ([[dict objectForKey:@"errFlag"]intValue]==1 && [[dict objectForKey:@"errNum"]intValue]==31)
            {
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Message" message:@"You are about to delete all your account details incliuding matches and chat too. Are you sure?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                alert.tag =102;
                [alert show];
            }
            else if ([[dict objectForKey:@"errFlag"]intValue]==1 && [[dict objectForKey:@"errNum"]intValue]==62)
            {
                [pi showMessage:[dict objectForKey:@"errMsg"] On:self.view];
            }
        }
    }
    [pi hideProgressIndicator];
}

#pragma mark- Request And Response For Logout

-(void)sendRequestForLogOut
{
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Message" message:@"Are you sure to logout from your account?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alert.tag =101;
    [alert show];
    /*
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    [paramDict setObject:[[UserDefaultHelper sharedObject] facebookToken] forKey:PARAM_ENT_SESS_TOKEN];
    [paramDict setObject:[[UserDefaultHelper sharedObject] uuid]  forKey:PARAM_ENT_DEV_ID];
    WebServiceHandler *handler = [[WebServiceHandler alloc] init];
    handler.requestType = eParseKey;
    NSMutableURLRequest * request = [Service parseLogOut:paramDict];
    [handler placeWebserviceRequestWithString:request Target:self Selector:@selector(LogoutResponse:)];
     */
}

-(void)LogoutResponse:(NSDictionary*)_response
{
    ProgressIndicator * pi = [ProgressIndicator sharedInstance];
    if (_response == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Connection Timeout." delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:nil, nil];
        alert.tag = 400;
        [alert show];
        [pi hideProgressIndicator];
    }
    else{
        if (_response != nil) {
            NSDictionary *dict = [_response objectForKey:@"ItemsList"];
            if (!dict) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Connection Timeout." delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:nil, nil];
                [alert show];
                [pi hideProgressIndicator];
            }
            if ([[dict objectForKey:@"errFlag"]intValue]==0 && [[dict objectForKey:@"errNum"]intValue]==41)
            {
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Message" message:@"Are you sure to logout from your account?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                alert.tag =101;
                [alert show];
            }
            else{
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Message" message:@"Are you sure to logout from your account?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                alert.tag =101;
                [alert show];
            }
        }
    }
}

-(void)logout{
    
    [[FacebookUtility sharedObject]logOutFromFacebook];
    
    [self resetDefaults];
    
    LoginViewController *login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [TinderAppDelegate sharedAppDelegate].navigationController = [[UINavigationController alloc] initWithRootViewController:login];
    
    [TinderAppDelegate sharedAppDelegate].revealSideViewController= [[PPRevealSideViewController alloc] initWithRootViewController:[TinderAppDelegate sharedAppDelegate].navigationController];
    [TinderAppDelegate sharedAppDelegate].revealSideViewController.delegate = self;
    [TinderAppDelegate sharedAppDelegate].window.rootViewController = [TinderAppDelegate sharedAppDelegate].revealSideViewController;
    
    [[TinderAppDelegate sharedAppDelegate].window makeKeyAndVisible];
}

- (void)resetDefaults
{
    /*
     NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
     [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
     */
    
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [defs dictionaryRepresentation];
    for (id key in dict) {
        if ([key isEqualToString:UD_UUID] || [key isEqualToString:UD_DEVICETOKEN]) {
            
        }else{
            [defs removeObjectForKey:key];
        }
        
    }
    [defs synchronize];
}


/*
-(void)logout{
    
    ProgressIndicator * pi = [ProgressIndicator sharedInstance];
    
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:UD_FB_TOKEN];
    [FBSession.activeSession closeAndClearTokenInformation];
    
    [[UserDefaultHelper sharedObject]setIsFirstLaunchForMatchedList:NO];
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"isFirstLaunchOver"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"PrefMin"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"PrefMax"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"INTREST"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"GENDER"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"DISTANCE"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"DIST"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[FacebookUtility sharedObject]logOutFromFacebook];
    
    LoginViewController *login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [self.navigationController pushViewController:login animated:YES];
    
    [pi hideProgressIndicator];
}
*/
 
#pragma mark -
#pragma mark - Mail Methods

- (void)openMail
{
    [super sendMailSubject:@"Flamer App!" toRecipents:[NSArray arrayWithObject:@"info@appdupe.com"] withMessage:@""];
}

#pragma mark -
#pragma mark - Request And Response For Update Prefrence

-(void)sendRequestForUpdate
{
    ProgressIndicator * pi = [ProgressIndicator sharedInstance];
    [pi showPIOnView:self.view withMessage:@"updating.."];

    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    [dictParam setObject:[UserSettings currentSetting].sex forKey:PARAM_ENT_SEX];
    [dictParam setObject:[UserSettings currentSetting].prSex forKey:PARAM_ENT_PREF_SEX];
    
    [dictParam setObject:[UserSettings currentSetting].prLAge forKey:PARAM_ENT_PREF_LOWER_AGE];
    [dictParam setObject:[UserSettings currentSetting].prUAge forKey:PARAM_ENT_PREF_UPPER_AGE];
    [dictParam setObject:[UserSettings currentSetting].prRad forKey:PARAM_ENT_PREF_RADIUS];
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_UPDATEPREFERENCES withParamData:dictParam withBlock:^(id response, NSError *error) {
        [pi hideProgressIndicator];
        if (response) {
            if ([[response objectForKey:@"errFlag"] intValue]==0) {
                [[TinderAppDelegate sharedAppDelegate]showToastMessage:[response objectForKey:@"errMsg"]];
            }else{
                [[TinderAppDelegate sharedAppDelegate]showToastMessage:[response objectForKey:@"errMsg"]];
            }
            //[self settingResponse:response];
        }
        else{
            [[TinderAppDelegate sharedAppDelegate]showToastMessage:@"Failed to update, try again."];
        }
    }];
}

-(void)settingResponse:(NSDictionary*)_response
{
    ProgressIndicator * pi = [ProgressIndicator sharedInstance];
    if (_response == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Connection Timeout." delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:nil, nil];
        alert.tag = 400;
        [alert show];
    }
    else{
        if (_response != nil) {
            NSDictionary *dict = [_response objectForKey:@"ItemsList"];
            if (!dict) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Connection Timeout." delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:nil, nil];
                [alert show];
                
                [pi hideProgressIndicator];
            }
            else{
                if ([[dict objectForKey:@"errFlag"]intValue]==0 && [[dict objectForKey:@"errNum"]intValue]==13) {
                    [pi showMessage:[dict objectForKey:@"errMsg"] On:self.view];
                }
                else if ([[dict objectForKey:@"errFlag"]intValue]==1 && [[dict objectForKey:@"errNum"]intValue]==14){
                    
                    [pi showMessage:[dict objectForKey:@"errMsg"] On:self.view];
                    
                }
                else if ([[dict objectForKey:@"errFlag"]intValue]==1 && [[dict objectForKey:@"errNum"]intValue]==14)
                {
                    [pi showMessage:[dict objectForKey:@"errMsg"] On:self.view];
                }
                else{
                    [pi showMessage:[dict objectForKey:@"errMsg"] On:self.view];
                }
                [pi hideProgressIndicator];
            }
        }
    }
}

#pragma mark -
#pragma mark - PPRevealSlider Delegte method

- (BOOL) pprevealSideViewController:(PPRevealSideViewController *)controller shouldDeactivateGesture:(UIGestureRecognizer*)gesture forView:(UIView*)view
{
    if ([view isEqual:slider] || [view isEqual:sliderDistance]||[view isEqual:sliderAgeBox]||[view isEqual:sliderDistanceBox]) {
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark - UIALertView Delegte method

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==101) {
        if (buttonIndex!=0) {
            [self logout];
        }
    }
    else if (alertView.tag==102) {
        if (buttonIndex!=0) {
            [self logout];
        }
    }
}

-(IBAction)setTimeBtnPressed:(id)sender{
    [ActionSheetStringPicker showPickerWithTitle:NSLocalizedString(@"Select Time", @"") rows:arrForSecond initialSelection:unitIndex target:self sucessAction:@selector(choiceWasSelectedd:element:) cancelAction:nil origin:sender];
}

-(void)choiceWasSelectedd:(NSNumber *)selectedIndex element:(id)element
{
    unitIndex=[selectedIndex intValue];
    self.lblTIme.text=[arrForSecond objectAtIndex:unitIndex];
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    if(unitIndex==0)
    {
        [pref setInteger:0 forKey:@"time"];
    }
    else{
        [pref setInteger:[[NSString stringWithFormat:@"%@",self.lblTIme.text] intValue] forKey:@"time"];
    }
}

#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
