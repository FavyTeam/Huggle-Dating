//
//  ProfileVC.h
//  Tinder
//
//  Created by Elluminati - macbook on 12/06/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileVC : UIViewController<UIScrollViewDelegate,PPRevealSideViewControllerDelegate>{
    NSMutableArray *arrImages;
    int currentPage;
}
@property(nonatomic,strong)User *user;

@property(nonatomic,weak)IBOutlet UIScrollView *scrImage;
@property(nonatomic,weak)IBOutlet UIPageControl *pcImage;
@property(nonatomic,weak)IBOutlet UILabel *lblNameAndAge;
@property(nonatomic,weak)IBOutlet UITextView *txtAbout;
@property(nonatomic,weak)IBOutlet UILabel *lblAway;
@property(nonatomic,weak)IBOutlet UILabel *lblActive;

@end
