//
//  EditProfileVC.m
//  Tinder
//
//  Created by Elluminati - macbook on 14/05/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import "EditProfileVC.h"

#import "UIImageView+Download.h"
#import "EditProfile.h"
#import "UserImage.h"
#import "Base64.h"

@interface EditProfileVC ()

@end

@implementation EditProfileVC

@synthesize strStatus;

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
    
    [self.navigationItem setTitle:@"Edit"];
    [self addrightButton:self.navigationItem];
    
    selectedBtnTag=-1;
    
    arrImages=[[NSMutableArray alloc]init];
    
    //UIImageView *img=(UIImageView *)[self.view viewWithTag:1000];
    //[img downloadFromURL:[User currentUser].profile_pic withPlaceholder:[UIImage imageNamed:@"pfImage.png"]];
    
    [self getUserPhotos];
    
    self.txtStatus.text=strStatus;
}

#pragma mark -
#pragma mark - NavBar Methods

-(void)addrightButton:(UINavigationItem*)naviItem
{
    //UIImage *imgButton = [UIImage imageNamed:@"chat_icon_off_line.png"];
	UIButton *rightbarbutton = [UIButton buttonWithType:UIButtonTypeCustom];
	[rightbarbutton setFrame:CGRectMake(0, 0, 75, 23)];
    [rightbarbutton setTitle:@"Done" forState:UIControlStateNormal];
    [rightbarbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightbarbutton setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [[rightbarbutton titleLabel] setFont:[UIFont fontWithName:HELVETICALTSTD_LIGHT size:15.0]];
    
    [rightbarbutton addTarget:self action:@selector(doneEditing) forControlEvents:UIControlEventTouchUpInside];
    naviItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightbarbutton];
    
}

-(void)doneEditing
{
    [self dismissViewControllerAnimated:NO completion:nil];
    /*
    [UIView animateWithDuration:0.15
                          delay:0
                        options:UIViewAnimationOptionTransitionCurlUp
                     animations:^{
                         self.view.transform= CGAffineTransformMakeScale(1.3, 1.5);
                         
                         
                     }
                     completion:^(BOOL finished) {
                         self.view.transform = CGAffineTransformIdentity;
                         [self dismissViewControllerAnimated:NO completion:nil];
                     }];
     */
}

#pragma mark -
#pragma mark - Methods

-(void)getUserPhotos
{
    [[ProgressIndicator sharedInstance]showPIOnView:self.view withMessage:@"Loading..."];
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_GET_USER_PROFILE_PIC withParamData:dictParam withBlock:^(id response, NSError *error) {
        if (response) {
            if ([[response objectForKey:@"errFlag"] intValue]==0) {
                [arrImages removeAllObjects];
                NSArray *arr=[response objectForKey:@"Userphotos"];
                for (NSDictionary *dict in arr) {
                    UserImage *ui=[[UserImage alloc]init];
                    ui.image_id=[dict objectForKey:@"image_id"];
                    ui.image_url=[dict objectForKey:@"image_url"];
                    ui.index_id=[dict objectForKey:@"index_id"];
                    [arrImages addObject:ui];
                }
                [self reloadAllImages];
            }
        }
        [[ProgressIndicator sharedInstance]hideProgressIndicator];
    }];
}

-(void)reloadAllImages
{
    for (int i=0; i<6; i++) {
        UIImageView *img=(UIImageView *)[self.view viewWithTag:i+1000];
        img.image=[UIImage imageNamed:@"pfImage.png"];
    }
    
    for (int i=0; i<[arrImages count]; i++) {
        UserImage *ui=[arrImages objectAtIndex:i];
        int tag=[ui.index_id intValue];
        UIImageView *img=(UIImageView *)[self.view viewWithTag:tag+1000];
        [img downloadFromURL:ui.image_url withPlaceholder:[UIImage imageNamed:@"pfImage.png"]];
        UIButton *btn=(UIButton *)[self.view viewWithTag:tag+2000];
        btn.selected=YES;
    }
}

-(void)deleteImage{
    
    [[ProgressIndicator sharedInstance]showPIOnView:self.view withMessage:@"Deleting..."];
    
    UserImage *ui=nil;
    for (int i=0; i<[arrImages count]; i++) {
        UserImage *u=[arrImages objectAtIndex:i];
        if ([u.index_id intValue]==selectedBtnTag) {
            ui=u;
        }
    }
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    [dictParam setObject:ui.image_id forKey:PARAM_ENT_IMAGE_ID];
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_DELETE_USER_IMAGE withParamData:dictParam withBlock:^(id response, NSError *error) {
        if (response) {
            if ([[response objectForKey:@"errFlag"] intValue]==0) {
                [arrImages removeObject:ui];
                [self reloadAllImages];
            }
        }
        [[ProgressIndicator sharedInstance]hideProgressIndicator];
    }];
}

#pragma mark -
#pragma mark - Actions

-(IBAction)onClickChangeStatus:(id)sender{
    [self.txtStatus resignFirstResponder];
    
    if (self.txtStatus.text.length==0) {
        return;
    }

    [[ProgressIndicator sharedInstance]showPIOnView:self.view withMessage:@"Loading..."];
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    [dictParam setObject:self.txtStatus.text forKey:PARAM_ENT_STATUS];
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_UPDATE_STATUS withParamData:dictParam withBlock:^(id response, NSError *error) {
        if (response) {
            if ([[response objectForKey:@"errFlag"] intValue]==0) {
                [[TinderAppDelegate sharedAppDelegate]showToastMessage:[response objectForKey:@"errMsg"]];
            }
        }
        [[ProgressIndicator sharedInstance]hideProgressIndicator];
    }];
    
}

-(IBAction)onClickBtn:(id)sender
{
    
    UIButton *btn=(UIButton *)sender;
    selectedBtnTag=btn.tag-2000;
    
    if (btn.selected) {
        btn.selected=NO;
        [self deleteImage];
    }
    else{
        UIActionSheet *as=[[UIActionSheet alloc]initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open camera",@"Choose from libaray", nil];
        as.tag=selectedBtnTag;
        [as showInView:self.view];
    }
}

-(IBAction)onClickImage:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    int tag=btn.tag-3000;
    
    UserImage *ui=nil;
    for (int i=0; i<[arrImages count]; i++) {
        UserImage *u=[arrImages objectAtIndex:i];
        if ([u.index_id intValue]==tag) {
            ui=u;
        }
    }
    
    if (ui==nil) {
        return;
    }
    
    
    UIAlertView *alt=[[UIAlertView alloc]initWithTitle:@"Profile Picture" message:@"Set as profile picture?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alt.tag=tag;
    [alt show];
    
}

#pragma mark -
#pragma mark - UIAlertView delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex==0) {
        return;
    }
    
    UserImage *ui=nil;
    for (int i=0; i<[arrImages count]; i++) {
        UserImage *u=[arrImages objectAtIndex:i];
        if ([u.index_id intValue]==alertView.tag) {
            ui=u;
        }
    }
    
    if (ui==nil) {
        return;
    }
    
    [[ProgressIndicator sharedInstance]showPIOnView:self.view withMessage:@"Loading..."];
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    [dictParam setObject:ui.image_id forKey:PARAM_ENT_NEW_IMAGE_ID];
    [dictParam setObject:ui.index_id forKey:PARAM_ENT_NEW_PRF_INDEX_ID];
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_UPDATE_PROFILE_PIC withParamData:dictParam withBlock:^(id response, NSError *error) {
        if (response) {
            if ([[response objectForKey:@"errFlag"] intValue]==0) {
                [arrImages removeAllObjects];
                NSArray *arr=[response objectForKey:@"Userphotos"];
                for (NSDictionary *dict in arr) {
                    UserImage *ui=[[UserImage alloc]init];
                    ui.image_id=[dict objectForKey:@"image_id"];
                    ui.image_url=[dict objectForKey:@"image_url"];
                    ui.index_id=[dict objectForKey:@"index_id"];
                    [arrImages addObject:ui];
                }
                [self reloadAllImages];
                
                if([[UserDefaultHelper sharedObject]facebookLoginRequest]!=nil) {
                    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]initWithDictionary:[[UserDefaultHelper sharedObject] facebookLoginRequest]];
                    UserImage *uiPP=nil;
                    for (int i=0; i<[arrImages count]; i++) {
                        UserImage *u=[arrImages objectAtIndex:i];
                        if ([u.index_id intValue]==0) {
                            uiPP=u;
                        }
                    }
                    if (uiPP!=nil) {
                        [dictParam setObject:uiPP.image_url forKey:PARAM_ENT_PROFILE_PIC];
                        [[UserDefaultHelper sharedObject]setFacebookLoginRequest:dictParam];
                    }
                    [User currentUser].profile_pic=[dictParam objectForKey:PARAM_ENT_PROFILE_PIC];
                }
            }
        }
        [[ProgressIndicator sharedInstance]hideProgressIndicator];
    }];
}

#pragma mark -
#pragma mark - UIActionSheet delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
            [self openCamera];
            break;
        case 1:
            [self chooseFromLibaray];
            break;
        case 2:
            break;
    }
}

-(void)openCamera
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.view.tag=selectedBtnTag;
        imagePickerController.delegate = self;
        imagePickerController.sourceType =
        UIImagePickerControllerSourceTypeCamera;
        imagePickerController.editing=YES;
        [self presentViewController:imagePickerController animated:YES completion:^{
            
        }];
    }
    else{
        UIAlertView *alt=[[UIAlertView alloc]initWithTitle:@"" message:@"Camera Not Available" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alt show];
    }
}

-(void)chooseFromLibaray
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.view.tag=selectedBtnTag;
    imagePickerController.delegate = self;
    imagePickerController.sourceType =
    UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.editing=YES;
    [self presentViewController:imagePickerController animated:YES completion:^{
        
    }];
}

#pragma mark -
#pragma mark - UIImagePickerController Delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    [[ProgressIndicator sharedInstance]showPIOnView:self.view withMessage:@"Uploading..."];
    
    UIImage *img=[[UtilityClass sharedObject] scaleAndRotateImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
    
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setObject:[User currentUser].fbid forKey:PARAM_ENT_USER_FBID];
    [dictParam setObject:[NSString stringWithFormat:@"%d",picker.view.tag] forKey:PARAM_ENT_INDEX_ID];
    
    NSData *imageToUpload = UIImageJPEGRepresentation(img, 1.0);
    if (imageToUpload) {
        NSString *strImage=[Base64 encode:imageToUpload];
        if (strImage) {
            [dictParam setObject:strImage forKey:PARAM_ENT_USERIMAGE];
        }
    }
    
    AFNHelper *afn=[[AFNHelper alloc]init];
    [afn getDataFromPath:METHOD_UPLOAD_USER_IMAGE withParamData:dictParam withBlock:^(id response, NSError *error) {
        if (response) {
            if ([[response objectForKey:@"errFlag"] intValue]==0) {
                UserImage *ui=[[UserImage alloc]init];
                ui.index_id=[NSString stringWithFormat:@"%d",selectedBtnTag];
                ui.image_id=[response objectForKey:@"ent_image_id"];
                ui.image_url=[response objectForKey:@"picURL"];
                [arrImages addObject:ui];
                [self reloadAllImages];
            }
        }
        [[ProgressIndicator sharedInstance]hideProgressIndicator];
    }];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    CGRect rect=self.view.frame;
    if (IS_IPHONE_5) {
        rect.origin.y=-100;
    }else{
        rect.origin.y=-160;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame=rect;
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    CGRect rect=self.view.frame;
    rect.origin.y=44;
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame=rect;
    }];
}

#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
