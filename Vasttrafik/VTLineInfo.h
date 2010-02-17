//
//  VTLineInfo.h
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-02-17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface VTLineInfo : NSObject {
	NSString *lineNumber;
	UIColor *foregroundColor;
	UIColor *backgroundColor;
	NSString *imageType;
}

@property(assign) NSString *lineNumber;
@property(assign) UIColor *foregroundColor;
@property(assign) UIColor *backgroundColor;
@property(assign) NSString *imageType;

@end
