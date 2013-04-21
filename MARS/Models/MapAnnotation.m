

#import "MapAnnotation.h"

@implementation MapAnnotation


- (id)initWithSite:(ARSite*)site{
    _site = site;
	self.coordinate = _site.location;
    self.title = ([_site.name length] > 0) ? _site.name :  @"No name available";
    self.subtitle = ([_site.address length] > 0) ? _site.address : @"No address available";
    
	return self;
}



@end
