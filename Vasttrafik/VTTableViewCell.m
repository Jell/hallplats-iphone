//
//  VTTableViewCell.m
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-02-19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VTTableViewCell.h"


@implementation VTTableViewCell

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
