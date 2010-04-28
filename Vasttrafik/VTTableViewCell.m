//
//  VTTableViewCell.m
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-02-19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VTTableViewCell.h"


@implementation VTTableViewCell
/*
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        tramNumber = [[UILabel alloc ] initWithFrame:CGRectMake(15.0, 7.0, 30.0, 30.0)];
		tramNumber.textAlignment =  UITextAlignmentCenter;
		tramNumber.lineBreakMode = UILineBreakModeClip;
		tramNumber.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(12.0)];
		[self addSubview:tramNumber];
		
		destinationLabel = [[UILabel alloc ] initWithFrame:CGRectMake(55.0, 0.0, 225.0, 20.0)];
		destinationLabel.textAlignment =  UITextAlignmentLeft;
		destinationLabel.lineBreakMode = UILineBreakModeClip;
		destinationLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(14.0)];
		destinationLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:destinationLabel];
		
		UILabel *nastaTitleLabel = [[UILabel alloc ] initWithFrame:CGRectMake(55.0, 20.0, 70.0, 20.0)];
		nastaTitleLabel.textAlignment =  UITextAlignmentLeft;
		nastaTitleLabel.lineBreakMode = UILineBreakModeClip;
		nastaTitleLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(14.0)];
		nastaTitleLabel.backgroundColor = [UIColor clearColor];
		nastaTitleLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"Next", @"Next")];
		[self addSubview:nastaTitleLabel];
		[nastaTitleLabel release];
		
		nastaLabel = [[UILabel alloc ] initWithFrame:CGRectMake(125.0, 20.0, 80.0, 20.0)];
		nastaLabel.textAlignment =  UITextAlignmentRight;
		nastaLabel.lineBreakMode = UILineBreakModeClip;
		nastaLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(14.0)];
		nastaLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:nastaLabel];
		
		nastaHandicap = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"handicap.gif"]];
		nastaHandicap.frame = CGRectMake(115, 23, 15, 15);
		nastaHandicap.hidden = YES;
		[self addSubview:nastaHandicap];
		
		darefterLabel = [[UILabel alloc ] initWithFrame:CGRectMake(210.0, 20.0, 70.0, 20.0)];
		darefterLabel.textAlignment =  UITextAlignmentRight;
		darefterLabel.lineBreakMode = UILineBreakModeClip;
		darefterLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(14.0)];
		darefterLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:darefterLabel];
		
		darefterHandicap = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"handicap.gif"]];
		darefterHandicap.frame = CGRectMake(205, 23, 15, 15);
		darefterHandicap.hidden = YES;
		[self addSubview:darefterHandicap];
    }
    return self;
}
*/
-(void)setForecast:(VTForecast *)forecast{
	tramNumber.text = forecast.lineNumber;
	tramNumber.textColor = forecast.foregroundColor;
	tramNumber.backgroundColor = forecast.backgroundColor;
	destinationLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"To", @"To"), forecast.destination];
	nastaTitleLabel.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"Next", @"Next")];
	if(![forecast.nastaTime isEqual:@"0"]){
		nastaLabel.text = [NSString stringWithFormat:@"%@ %@", forecast.nastaTime, NSLocalizedString(@"min", @"min")];
	}else {
		nastaLabel.text = [NSString stringWithFormat:@"%@", NSLocalizedString(@"Now", @"Now")];
	}

	nastaHandicap.hidden = !forecast.nastaHandicap;
	nastaLowFloor.hidden = !forecast.nastaLowFloor;
	if(![forecast.darefterTime isEqual:@""]){
		darefterLabel.text = [NSString stringWithFormat:@"%@ %@", forecast.darefterTime, NSLocalizedString(@"min", @"min")];
	}else{
		darefterLabel.hidden = YES;
	}
	darefterHandicap.hidden = !forecast.darefterHandicap;
	darefterLowFloor.hidden = !forecast.darefterLowFloor;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    //[super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	[darefterHandicap release];
	[darefterLabel release];
	[nastaHandicap release];
	[nastaLabel release];
	[destinationLabel release];
	[tramNumber release];
    [super dealloc];
}


@end
