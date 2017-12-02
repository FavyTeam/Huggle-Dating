//
//  EditProfileVC.h
//  Tinder
//
//  Created by Elluminati - macbook on 14/05/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditProfileVC : UIViewController<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate,UITextFieldDelegate>
{
    int selectedBtnTag;
    NSMutableArray *arrImages;
}
@property(nonatomic,copy)NSString *strStatus;
@property(nonatomic,weak)IBOutlet UITextField *txtStatus;

-(IBAction)onClickChangeStatus:(id)sender;
-(IBAction)onClickBtn:(id)sender;
-(IBAction)onClickImage:(id)sender;

@end
