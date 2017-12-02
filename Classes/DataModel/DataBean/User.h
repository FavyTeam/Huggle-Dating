//
//  User.h
//  Tinder
//
//  Created by Elluminati - macbook on 07/05/14.
//  Copyright (c) 2014 AppDupe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
{
    
}
@property(nonatomic,copy)NSString *fbid;
@property(nonatomic,copy)NSString *first_name;
@property(nonatomic,copy)NSString *last_name;
@property(nonatomic,copy)NSString *sex;
@property(nonatomic,copy)NSString *push_token;
@property(nonatomic,copy)NSString *curr_lat;
@property(nonatomic,copy)NSString *curr_long;
@property(nonatomic,copy)NSString *dob;
@property(nonatomic,copy)NSString *profile_pic;

@property(nonatomic,assign)int flag;

+(User *)currentUser;
-(void)setUser;

@end
