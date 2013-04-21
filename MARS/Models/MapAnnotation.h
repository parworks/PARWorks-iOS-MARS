

#import <MapKit/MapKit.h>
#import "ARSite+MARS_Extensions.h"

@interface MapAnnotation : NSObject <MKAnnotation>{
    
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) ARSite *site;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

- (id)initWithSite:(ARSite*)site;


@end