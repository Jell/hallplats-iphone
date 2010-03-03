/**
 Protocol defining the mandatory member functions of an ARViewController
 */

/*
 *  MPNViewDisplayProtocol.h
 *  AugmentedMPN
 *
 *  Created by Jean-Louis on 2010-02-03.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */
@protocol ARViewDelegate <CLLocationManagerDelegate>

@property int selectedPoi; /**< Currently selected POI index */

/** Notify that acceleration data changed
@param x acceleration on X axis
@param y acceleration on Y axis 
@param z acceleration on Z axis */
-(void)accelerationChangedX:(float)x y:(float)y z:(float)z;

/** Update the cuttent location */
-(void)setCurrentLocation:(CLLocation *)location;

/** Set the annotation list
 @param newList NSArray of VTAnnotation*/
-(void)setAnnotationList:(NSArray *)newList;

/** Notify that the orientation of the device changed */
-(void)setOrientation:(UIInterfaceOrientation)orientation;
@end

