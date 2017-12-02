//
//  ProfileMatchedCell.h
//  TinderChatModule
//
//  Created by Rahul Sharma on 05/12/13.
//  Copyright (c) 2013 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoundedImageView.h"

@interface ProfileMatchedCell : UITableViewCell

//@property (strong , nonatomic) UIImageView *thumbNailImage;
@property (strong , nonatomic) UILabel *labelFirstName;
@property (strong , nonatomic) UILabel *labelLastMessage;
@property (strong , nonatomic) UIImageView *imageViewStatus;
@property (strong , nonatomic) UIImageView *imageViewLine;
@property(strong,nonatomic) RoundedImageView * thumbNailImage;

@end
