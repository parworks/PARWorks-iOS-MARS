

#import <MapKit/MapKit.h>


@interface MapAnnotation : NSObject <MKAnnotation>{
    
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

- (id)initWithCoordinate:(CLLocationCoordinate2D)c andTitle:(NSString*)sTitle andSubtitle:(NSString*)sSubtitle;


@end