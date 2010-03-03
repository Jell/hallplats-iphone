//
//  VTTableViewCell.m
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-02-19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VTTableViewCell.h"


@implementation VTTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        tramNumber = [[UILabel alloc ] initWithFrame:CGRectMake(15.0, 7.0, 30.0, 30.0)];
		tramNumber.textAlignment =  UITextAlignmentCenter;
		tramNumber.lineBreakMode = UILineBreakModeClip;
		tramNumber.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(12.0)];
		[self addSubview:tramNumber];
		[tramNumber release];
		
		destinationLabel = [[UILabel alloc ] initWithFrame:CGRectMake(55.0, 0.0, 240.0, 20.0)];
		destinationLabel.textAlignment =  UITextAlignmentLeft;
		destinationLabel.lineBreakMode = UILineBreakModeClip;
		destinationLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(14.0)];
		destinationLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:destinationLabel];
		[destinationLabel release];
		
		nastaLabel = [[UILabel alloc ] initWithFrame:CGRectMake(55.0, 20.0, 240.0, 20.0)];
		nastaLabel.textAlignment =  UITextAlignmentLeft;
		nastaLabel.lineBreakMode = UILineBreakModeClip;
		nastaLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(14.0)];
		nastaLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:nastaLabel];
		[nastaLabel release];
		
		nastaHandicap = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"handicap.gif"]];
		nastaHandicap.frame = CGRectMake(120, 23, 15, 15);
		nastaHandicap.hidden = YES;
		[self addSubview:nastaHandicap];
		[nastaHandicap release];
		
		darefterLabel = [[UILabel alloc ] initWithFrame:CGRectMake(220.0, 20.0, 240.0, 20.0)];
		darefterLabel.textAlignment =  UITextAlignmentLeft;
		darefterLabel.lineBreakMode = UILineBreakModeClip;
		darefterLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(14.0)];
		darefterLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:darefterLabel];
		[darefterLabel release];
		
		darefterHandicap = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"handicap.gif"]];
		darefterHandicap.frame = CGRectMake(200, 23, 15, 15);
		darefterHandicap.hidden = YES;
		[self addSubview:darefterHandicap];
		[darefterHandicap release];
		
    }
    return self;
}

-(void)setForecast:(VTForecast *)forecast{
	tramNumber.text = forecast.lineNumber;
	tramNumber.textColor = forecast.foregroundColor;
	tramNumber.backgroundColor = forecast.backgroundColor;
	destinationLabel.text = [NSString stringWithFormat:@"Till: %@", forecast.destination];
	nastaLabel.text = [NSString stringWithFormat:@"Nästa:       %@min", forecast.nastaTime];
	nastaHandicap.hidden = !forecast.nastaHandicap;
	if(![forecast.darefterTime isEqual:@""]){
		darefterLabel.text = [NSString stringWithFormat:@"%@min", forecast.darefterTime];
		darefterHandicap.hidden = !forecast.darefterHandicap;
	}
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
