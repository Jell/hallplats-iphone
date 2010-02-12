//
//  AugmentedPoiView.m
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-02-12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AugmentedPoiView.h"


@implementation AugmentedPoiView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor clearColor];
		
		infoLabel = [[UILabel alloc ] initWithFrame:CGRectMake(0.0, 0.0, 180.0, 24.0)];
		infoLabel.textAlignment =  UITextAlignmentCenter;
		infoLabel.textColor = [UIColor whiteColor];
		infoLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"fancy_title_main.png"]];
		infoLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(12.0)];
		infoLabel.text = @"";
		infoLabel.clipsToBounds = NO;
		
		[self addSubview:infoLabel];
		
		UIImageView *anImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowdown.png"]];
		CGPoint center = {90.0, 30.0};
		anImage.center = center;
		anImage.clipsToBounds = NO;
		[self addSubview:anImage];
		[anImage release];
		
		UIImageView *leftCornerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fancy_title_left.png"]];
		CGPoint left = {-7.0, 14.0};
		leftCornerImage.center = left;
		leftCornerImage.clipsToBounds = NO;
		[self addSubview:leftCornerImage];
		[leftCornerImage release];
		
		UIImageView *rightCornerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fancy_title_right.png"]];
		CGPoint right = {187.0, 14.0};
		rightCornerImage.center = right;
		rightCornerImage.clipsToBounds = NO;
		[self addSubview:rightCornerImage];
		[rightCornerImage release];
	}
    return self;
}

-(void)setText:(NSString *) text{
	[infoLabel setText:text];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
	[infoLabel release];
    [super dealloc];
}


@end
