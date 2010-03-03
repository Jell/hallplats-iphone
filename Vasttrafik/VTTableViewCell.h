/**
 View for a VTForecast to be displayed in a Table view.
 */

//
//  VTTableViewCell.h
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-02-19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VTForecast.h"

@interface VTTableViewCell : UITableViewCell {
	UILabel *tramNumber;
	UILabel *destinationLabel;
	UILabel *nastaLabel;
	UIImage *nastaHandicapImage;
	UILabel *darefterLabel;
	UIImage *darefterHandicapImage;
	UIImageView *nastaHandicap;
	UIImageView *darefterHandicap;
	
}

-(void)setForecast:(VTForecast *)forecast;

@end

