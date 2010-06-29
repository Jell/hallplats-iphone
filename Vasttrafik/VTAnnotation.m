//
//  VTAnnotation.m
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-02-17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VTAnnotation.h"


@implementation VTAnnotation
@synthesize coordinate;
@synthesize distance, stop_name, stop_id,stop_type, forecastList;

- (NSString *)subtitle{
		return [NSString stringWithFormat:@"%@", mSubTitle];
}

- (NSString *)title{
		return [NSString stringWithFormat:@"%@", mTitle];
}

-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
	coordinate=c;
	// NSLog(@"%f,%f",c.latitude,c.longitude);
	return self;
}

-(void)setTitle:(NSString *)title subtitle:(NSString *)subtitle{
		[mTitle release];
		mTitle = title;
		[mTitle retain];
		
		[mSubTitle release];
		mSubTitle = subtitle;
		[mSubTitle retain];
}
-(void)setSubtitle:(NSString *)subtitle{
		[mSubTitle release];
		mSubTitle = subtitle;
		[mSubTitle retain];
}

-(NSArray *)getLineList{
	NSMutableArray *lineNumbers = [[NSMutableArray alloc] init];
	NSMutableArray *lineList = [[[NSMutableArray alloc] init] autorelease];
	for(VTForecast *forecast in forecastList){
		NSString *lineNumber = forecast.lineNumber;
		if(![lineNumbers containsObject:lineNumber]){
			[lineNumbers addObject:lineNumber];
			VTLineInfo *info = [[VTLineInfo alloc] init];
			info.lineNumber = lineNumber;
			info.backgroundColor = forecast.backgroundColor;
			info.foregroundColor = forecast.foregroundColor;
			info.imageType = forecast.imageType;
			[lineList addObject:info];
			[info release];
		}
	}
	
	[lineNumbers release];
	return (NSArray *)lineList;
}

-(void)updateDistanceFrom:(CLLocationCoordinate2D)origin
{
	float lat1 = origin.latitude * 3.14 / 180.0;
	float lon1 = origin.longitude * 3.14 / 180.0;
	
	float lat2 = coordinate.latitude * 3.14 / 180.0;
	float lon2 = coordinate.longitude * 3.14 / 180.0;
	
	const float R = 6371000.0; // m
	distance = acos(sin(lat1)*sin(lat2) + cos(lat1)*cos(lat2) * cos(lon2-lon1)) * R;
	[self setSubtitle:[NSString stringWithFormat:@"%dm", (int)distance]];
}

-(void)dealloc{
	[mTitle release];
	[mSubTitle release];
	[stop_name release];
	[stop_id release];
	[stop_type release];
	
	[forecastList release];
	
	[super dealloc];
}
@end
