

#import "MapAnnotation.h"

@implementation MapAnnotation


- (id)initWithCoordinate:(CLLocationCoordinate2D)c andTitle:(NSString*)sTitle andSubtitle:(NSString*)sSubtitle {
	self.coordinate = c;
    self.title = sTitle;
    self.subtitle = sSubtitle;
    
	return self;
}



@end
