//
//  VTLineInfo.m
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-02-17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VTLineInfo.h"


@implementation VTLineInfo
@synthesize lineNumber, foregroundColor, backgroundColor, imageType;

-(NSComparisonResult)compareWith:(VTLineInfo *)anotherLine{
	int value1 = [[self lineNumber] intValue];
	int value2 = [[anotherLine lineNumber] intValue];
	
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
@end
