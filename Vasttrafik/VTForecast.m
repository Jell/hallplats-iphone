//
//  VTForecast.m
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-02-17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VTForecast.h"


@implementation VTForecast

@synthesize lineNumber, foregroundColor, backgroundColor, imageType, destination, nastaTime, nastaHandicap, darefterTime, darefterHandicap;

-(NSComparisonResult)compareWith:(VTForecast *)anotherForecast{
	int value1 = [[self lineNumber] intValue];
	int value2 = [[anotherForecast lineNumber] intValue];
	
	if(value1 > value2){
		return NSOrderedDescending;
	}else{
		if(value1 == value2){
			return NSOrderedSame;
		}else{
			return NSOrderedAscending;
		}
	}
}

-(void)dealloc{
	[lineNumber release];
	[foregroundColor release];
	[backgroundColor release];
	[imageType release];
	[destination release];
	[nastaTime release];
	[darefterTime release];
	[super dealloc];
}
@end
