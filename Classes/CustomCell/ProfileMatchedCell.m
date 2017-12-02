//
//  ProfileMatchedCell.m
//  TinderChatModule
//
//  Created by Rahul Sharma on 05/12/13.
//  Copyright (c) 2013 Rahul Sharma. All rights reserved.
//

#import "ProfileMatchedCell.h"
#import "Helper.h"
#import <QuartzCore/QuartzCore.h>

@implementation ProfileMatchedCell
@synthesize labelFirstName;
@synthesize labelLastMessage;
@synthesize imageViewStatus;
@synthesize thumbNailImage;
@synthesize imageViewLine;



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    
    if (!self.thumbNailImage) {
    
        
        //Configring the rounded imageview by setting appropriate image and offset.
      
        self.thumbNailImage = [[RoundedImageView alloc]initWithFrame:CGRectMake(10, 10, 45, 45)];
        //self.thumbNailImage.imageOffset = 2.5;
        self.thumbNailImage.backgroundColor = [UIColor clearColor];
        self.thumbNailImage.layer.masksToBounds = YES;
        self.thumbNailImage .layer.borderColor = [UIColor whiteColor].CGColor;
       
    

        [self.contentView addSubview:self.thumbNailImage];
    }
    if (!self.imageViewLine) {
        self.imageViewLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, 64, 273, 1)];
        self.imageViewLine.image = [UIImage imageNamed:@"horizontal_line.png"];
        self.imageViewLine.layer.masksToBounds = YES;
        [self.contentView addSubview:self.imageViewLine];
    }

    if(!self.labelFirstName){
        self.labelFirstName = [[UILabel alloc]initWithFrame:CGRectMake(70, 15, 100, 20)];
        self.labelFirstName.backgroundColor = [UIColor clearColor];
    
        [Helper setToLabel:labelFirstName Text:nil WithFont:HESTERISTICO_BOLD FSize:14 Color:[UIColor whiteColor]];
        [self.contentView addSubview:self.labelFirstName];
    }
    if(!self.labelLastMessage){
        self.labelLastMessage = [[UILabel alloc]initWithFrame:CGRectMake(70, 35, 100, 20)];
          self.labelLastMessage.backgroundColor = [UIColor clearColor];
        [Helper setToLabel:labelLastMessage Text:nil WithFont:HESTERISTICO FSize:14 Color:[UIColor whiteColor]];
        [self.contentView addSubview:self.labelLastMessage];
    }
    if (!self.imageViewStatus) {
        self.imageViewStatus = [[UIImageView alloc]initWithFrame:CGRectMake(280, 10, 30, 30)];
        [self.contentView addSubview:self.imageViewStatus];
    }

        
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
